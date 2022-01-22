#!/bin/bash

set -x

sudo rm -rf registry

# Update docker to latest verison
sudo apt install docker-ce docker-ce-cli containerd.io

# Create the required directories for the advanced configuration
mkdir -p                \
  registry/nginx        \
  registry/nginx/conf.d \
  registry/nginx/ssl    \
  registry/auth

# On GCP shell we cont have tree by default, so lets install it
sudo apt install -y tree

# Verify that the directories were created
cd registry && tree

# move back to parent dicrectory
cd ..

# Create the docker-compose file in the registry directory
cat <<EOF > registry/docker-compose.yml
version: '3'
services:
  # The docker registry service
  registry:
  
    # The name of the container
    container_name: registry

    # The registry image which we will use
    image: registry:2
    # Ensures to start Docker Registry
    restart: always
    # The port on which the registry will be listen on
    ports:
    - "5000:5000"
    # Registry environment variables
    
    # The service will mount the docker volume "registrydata" and
    # the local directory "auth", 
    # along with its authentication file "registry.passwd".
    environment:
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry-Realm
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/registry.passwd
      REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data

    # mounted volumes
    volumes:
      - registrydata:/data
      - ./auth:/auth
    
    # The desired network
    networks:
      - bridge_network

  #### Nginx Service
  nginx:

    # The name of the container
    container_name: nginx

    # We depends on the registry service
    depends_on:
      - registry

    # nginx image
    image: nginx:alpine
    container_name: nginx
    restart: unless-stopped
    tty: true
    
    # The desired listen ports
    ports:
      - "80:80"
      - "443:443"

    # The mounted volumes for the configuration files
    # Mount the local directory for virtual configuration (conf.d) 
    # and SSL certificates (ssl).
    volumes:
      - ./nginx/conf.d/:/etc/nginx/conf.d/
      - ./nginx/ssl/:/etc/nginx/ssl/
    
    # The desired network
    networks:
      - bridge_network

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    # environment:
    #   ADMIN_USERNAME: admin 
    #   ADMIN_PASS: 12345678
    # security_opt:
    #   - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime
      - /var/run/docker.sock:/var/run/docker.sock
      - ./portainer-data:/data
    ports:
      - 9000:9000
    networks:
      - bridge_network
# Docker Networks for those services
networks:
  # Define a bridge network names "bridge_network"
  bridge_network:
    driver: bridge

# Define custom volume for the registry data named "registrydata"
# using the "local" driver
volumes:
  registrydata:
    driver: local
EOF

# Create a new virtual host file for our nginx service
cat << EOF > registry/nginx/conf.d/registry.conf
upstream docker-registry {
  server registry:5000;
}

server {
  listen      443 ssl http2;
  
  # SSL
  ssl_certificate     /etc/nginx/ssl/registry.crt;
  ssl_certificate_key /etc/nginx/ssl/registry.key;
  ssl_protocols       TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
  ssl_ciphers         TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:TLS-AES-128-GCM-SHA256:HIGH:!aNULL:!MD5;

  # disable any limits to avoid HTTP 413 for large image uploads
  # We will use `/etc/nginx/conf.d/additional.conf` as well later below
  client_max_body_size 0;

  # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
  chunked_transfer_encoding on;

  location /v2/ {
    # Do not allow connections from docker 1.5 and earlier
    # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
    if (\$http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*$" ) {
      return 404;
    }

    # To add basic authentication to v2 use auth_basic setting plus add_header
    auth_basic "localhost";
    auth_basic_user_file /auth/registry.passwd;
    add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;

    proxy_pass                          http://docker-registry;
    proxy_set_header  Host              \$http_host;   # required for docker client's sake
    proxy_set_header  X-Real-IP         \$remote_addr; # pass on real client's IP
    proxy_set_header  X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto \$scheme;
    proxy_read_timeout                  900;
  }
}
EOF

# Increase the maximum file upload size to 2GB
echo  'client_max_body_size 2G;' > registry/nginx/conf.d/additional.conf

# Generate the self-signed certificate    
openssl \
    req                         \
    -x509                       \
    -sha256                     \
    -newkey   rsa:4096          \
    -days     3650              \
    -nodes                      \
    -subj     "/CN=localhost"   \
    -addext   "subjectAltName=DNS:localhost,DNS:localhost,IP:127.0.0.1" \
    -keyout   registry/nginx/ssl/registry.key  \
    -out      registry/nginx/ssl/registry.crt 
    

# Verify the certificate and the key
openssl x509 -text  -noout -in registry/nginx/ssl/registry.crt     

# Verify that the key and the certificate matches
openssl rsa -check -noout -in registry/nginx/ssl/registry.key

# We search a matching certificate and key md5 fingerprint
echo 'registry.key Checksum is: ' \
      $(openssl rsa -modulus -noout -in registry/nginx/ssl/registry.key | openssl md5)

echo 'registry.crt Checksum is: '  \
      $(openssl x509 -modulus -noout -in registry/nginx/ssl/registry.crt | openssl md5)

# Generate a random password
REGISTRY_USER_PASSWORD=$(openssl passwd -crypt PASSWORD)
printf \
      "USER:$REGISTRY_USER_PASSWORD\n" > \
      registry/auth/registry.passwd

# Verify that the password was generated
cat   registry/auth/registry.passwd

# Create the required folders for the certificate
sudo  mkdir -p /etc/docker/certs.d/localhost

# Copy the certificate to the docker certificates folder
sudo  cp \
        registry/nginx/ssl/registry.crt \
        /etc/docker/certs.d/localhost/registry.docker.local.crt

# Copy the certificate into /usr/share/ca-certificate/extra        
sudo  mkdir -p /usr/local/share/ca-certificates/
sudo  cp \
        registry/nginx/ssl/registry.crt \
        /usr/local/share/ca-certificates/registry.docker.local.crt

# Add the certificate to the list of trusted certificates
sudo update-ca-certificates

# Restart doclker service 
sudo service docker restart

###
### Debug 
### 

# Start the registry with docker-compose
cd registry
docker-compose up -d
docker-compose ps
cd ..

# Login to the docker regisrty
docker login https://localhost:5000 -u USER -p $REGISTRY_USER_PASSWORD

# check the registry
docker pull nginx
docker image tag nginx localhost:5000/nginx
docker push localhost:5000/nginx

# check the registry images
curl -vvv https://localhost:5000/v2/_catalog