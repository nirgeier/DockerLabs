#!/bin/bash -x

# Create the required directories for the advanced configuration
rm -rf  ./registry
mkdir   -p  ./registry/certs \
            ./registry/auth \
            ./registry/data
# Files            
REGISTRY_DATA_FOLDER="registry/data"
REGISTRY_CERT_FOLDER="registry/certs"
REGISTRY_AUTH_FOLDER="registry/auth"

CERT_FILE="${REGISTRY_CERT_FOLDER}/registry.pem"
KEY_FILE="${REGISTRY_CERT_FOLDER}/registry_key.pem"
AUTH_FILE="${REGISTRY_AUTH_FOLDER}/htpasswd"

USER_PASSWORD=$RANDOM$RANDOM 
# print the env variables to file
cat << EOF > .env
#
# Auth generated .env file 
#
REGISTRY_DATA_FOLDER=$REGISTRY_DATA_FOLDER
REGISTRY_CERT_FOLDER=$REGISTRY_CERT_FOLDER
REGISTRY_AUTH_FOLDER=$REGISTRY_AUTH_FOLDER
REGISTRY_HTTP_SECRET=$USER_PASSWORD

KEY_FILE=$KEY_FILE
CERT_FILE=$CERT_FILE
AUTH_FILE=$AUTH_FILE

USER_PASSWORD=$USER_PASSWORD
EOF

# Create password for user
docker run --rm --entrypoint htpasswd httpd:2 -Bbn User $USER_PASSWORD > ./${AUTH_FILE} 

# Generate the self-signed certificate [silently]   
openssl \
    req                         \
    -x509                       \
    -sha256                     \
    -newkey   rsa:4096          \
    -days     3650              \
    -nodes                      \
    -subj     "/CN=localhost"   \
    -addext   "subjectAltName=DNS:localhost,DNS:localhost,IP:127.0.0.1" \
    -out      ${CERT_FILE} \
    -keyout   ${KEY_FILE}  \
    2> /dev/null     

# Start the registry container
docker-compose down
docker-compose up -d

# Pull the test image
docker pull busybox 

# tag the image with the local registry tag
docker tag busybox localhost/busybox:v1

# login to the local registry 
echo $USER_PASSWORD
docker login https://localhost -u User -p $USER_PASSWORD

# Push to the local registry
docker push localhost/busybox:v1
docker rmi localhost/busybox:v1
docker pull localhost/busybox:v1

#curl -vsL --insecure https://localhost/v2/_catalog

# Get the logged in user(s)
docker-credential-desktop list
# docker-credential-$(
#   jq -r .credsStore ~/.docker/config.json
# ) list | jq -r '
#   . |
#     to_entries[] |
#     select(
#       .key |
#       contains("docker.io")
#     ) |
#     last(.value)
# '