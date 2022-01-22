<a href="https://stackoverflow.com/users/1755598">
    <img src="https://stackexchange.com/users/flair/1951642.png" width="208" height="58">
</a>

![Visitor Badge](https://visitor-badge.laobi.icu/badge?page_id=nirgeier)

![](../../resources/docker-logos.png)

---

# Docker Hands-on Repository

- A collection of Hands-on Docker labs.
- Each lab is a standalone lab and does not require to complete the previous labs.

![](../../resources/lab.jpg)

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/nirgeier/DockerLabs)

### **<kbd>CTRL</kbd> + click to open in new window**

---

### Pre-Requirements

- Docker installation

---

# Lab 0201. Setup Advanced Local Docker Registry

- In the previous lab we created a basic local registry.
- In this lab we will create a local registry with advanced features.
- The local registry will be accessible from the host machine and will be build upon
  - Nginx
  - Docker registry image
  - Docker compose
  - Secured with certificates

## Step 01. Create Registry Directories

```sh
# Create the required directories for the advanced configuration
mkdir -p                      \
      registry/nginx          \
      registry/nginx/conf.d   \
      registry/nginx/ssl      \
      registry/auth
echo 'Docker rocks !!!' | docker run -it -a stdin alpine cat -
# On GCP shell we cont have tree by default, so lets install it
sudo apt install -y tree

# Verify that the directories were created
cd registry && tree

# We should see the following structure
.
├── auth
└── nginx
    ├── conf.d
    └── ssl
```

### Step 02. Create Docker-Compose for the registry services

```yaml
# Create the docker-compose file in the registry directory
cat << EOF > registry/docker-compose.yml
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
```

### Step 03. Create the Nginx configuration file

- The next step is configuring a Nginx virtual host for the Nginx service.
- Create a new virtual host file named `registry.conf` under `nginx/conf.d/`

```sh
# Create a new virtual host file for our nginx service
cat << EOF > nginx/conf.d/registry.conf
upstream docker-registry {
  server registry:5000;
}

server {
  listen      443 ssl http2;

  # SSL
  ssl on;
  ssl_certificate /etc/nginx/ssl/registry.crt;
  ssl_certificate_key /etc/nginx/ssl/registry.key;

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
    # auth_basic "registry.localhost";
    # auth_basic_user_file /etc/nginx/conf.d/registry.password;
    # add_header 'Docker-Distribution-Api-Version' 'registry/2.0' always;

    proxy_pass                          http://docker-registry;
    proxy_set_header  Host              \$http_host;   # required for docker client's sake
    proxy_set_header  X-Real-IP         \$remote_addr; # pass on real client's IP
    proxy_set_header  X-Forwarded-For   \$proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto \$scheme;
    proxy_read_timeout                  900;
  }
}
EOF
```

### Step 04. Increase Nginx File Upload Size

- By default, Nginx limits the file upload size to `1MB`.
- Most Docker images exceed `1MB` in size so we will increase the maximum file size on our Nginx service to `2GB`.

```sh
# Increase the maximum file upload size to 2GB
echo  'client_max_body_size 2G;' > registry/nginx/conf.d/additional.conf
```

### Step 05. Configure SSL Certificate

- For our secured authentication we will use self-signed certificates.
- lets generate the certificate and key files

```sh
# Generate the self-signed certificate
openssl \
    req                     \
    -x509                   \
    -sha256                 \
    -newkey   rsa:4096      \
    -days     3650          \
    -nodes                  \
    -subj "/CN=localhost"   \
    -addext "subjectAltName=DNS:localhost,DNS:localhost,IP:127.0.0.1" \
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
```

### Step 06. Configure authentication

- There are several ways to generate a password file for the registry.

  #### Option 01. using `htpasswd`

  - The `htpasswd` utility is a simple utility that can be used to create a password file.
  - If you don't have this installed, first we need to instal it if is not installed.

  ```sh
  # install htpasswd
  sudo apt install -y apache2-utils

  # Now generate the password file
  # Note: You will need to enter the password twice
  #       `-c` - Create a new file.
  #       -B   - Force bcrypt encryption of the password (very secure).
  htpasswd -Bc registry/nginx/ssl/registry.passwd $USER
  ```

  #### Option 02. using `openssl`

  ```sh
  # Generate a random password
  printf \
          "USER:$(openssl passwd -crypt PASSWORD)\n" >> \
          registry/nginx/ssl/registry.passwd

  # Verify that the password was generated
  cat registry/nginx/ssl/registry.passwd
  ```

### Step 07. Add the Root CA Certificate

- Next step is to add the Root CA certificate to Docker
- We will place certificates under the docker certificates folder for our domain

```sh
# Create the required folders for the certificate
sudo mkdir -p /etc/docker/certs.d/registry.codewizard.co.il

# Copy the certificate to the docker certificates folder
sudo cp \
        registry/nginx/ssl/registry.crt \
        /etc/docker/certs.d/registry.codewizard.co.il/rootCA.crt

# Create the second folder for the certificate
sudo mkdir -p /etc/docker/certs.d/codewizard.co.il

# Copy the certificate to the second certificates folder
sudo cp \
        registry/nginx/ssl/registry.crt \
        /etc/docker/certs.d/codewizard.co.il/rootCA.crt

# Copy the certificate into /usr/share/ca-certificate/extra
sudo mkdir -p /usr/local/share/ca-certificates/
sudo cp \
        registry/nginx/ssl/registry.crt \
        /usr/local/share/ca-certificates/rootCA.crt
```

- Once we have the certificates in place we can add them to the list of trusted certificates.

```sh
# Add the certificate to the list of trusted certificates
sudo update-ca-certificates
```

### Step 08. Restart Docker registry

/etc/docker/daemon.json
