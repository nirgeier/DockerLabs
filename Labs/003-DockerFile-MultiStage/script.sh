#!/bin/bash

# Preperations

source ../../_utils/common.sh

# Define the file path
COMMON_FILE="../../_utils/common.sh"

# Set the location for our demo 
BASE_FOLDER="/tmp/docker/003-MultiStage"
rm    -rf $BASE_FOLDER
mkdir -p  $BASE_FOLDER
cd        $BASE_FOLDER

# Check if we have the common file in our path
if [ -f "$COMMON_FILE" ];
then
  # Load the shared (common) file
  source "$COMMON_FILE"
else
  # File does not exist 
  echo "$COMMON_FILE was not found."
  ########################################
  ### Colors 
  ########################################
  # Reset
  Color_Off='\033[0m'       # Text Reset

  # Regular Colors
  Green='\033[0;32m'        # Green
  Yellow='\033[0;33m'       # Yellow
fi

echo -e "* ${Yellow}Creating ${Green}Dockerfile${Color_Off}"
cat << EOF > $BASE_FOLDER/Dockerfile
# Get the value of the desired image to build
ARG     BASE_IMG=\${BASE_IMG}

# Build the base image 
FROM    alpine AS base_image

# Add some content to the 2nd image
FROM    base_image  AS build-curl
RUN     echo -e "This file is from curl image" > image.txt

# Add some content to the 3rd image
FROM    base_image  AS build-bash
RUN     echo -e "This file is from bash image" > image.txt

# Build the desired image
FROM    build-\${BASE_IMG}

# We can use the FROM command as we see in the previous line or use the
# We can alos use image index instead
# COPY  --from=build-\${BASE_IMG} image.txt . to copy a specific content
RUN     cat image.txt
CMD     cat image.txt
EOF

echo -e "* ${Yellow}Building the docker image(s) ${Green}Dockerfile${Color_Off}"

# Build The curl based image (no-cache)
docker build --build-arg BASE_IMG=curl --no-cache -t curl1 .

# Build The bash based image (no-cache)
docker build --build-arg BASE_IMG=bash --no-cache -t bash1 .

### Build with cache
echo -e ""
echo -e "---------------------------------"
echo -e ""
# Build The curl based image (no-cache)
docker build --build-arg BASE_IMG=curl -t curl2 .

# Build The bash based image (no-cache)
docker build --build-arg BASE_IMG=bash -t bash2 .

# Test the output images
docker run curl1
docker run curl2
docker run bash1
docker run bash2
