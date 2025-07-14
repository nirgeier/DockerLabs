#!/bin/bash

### In this lab we will create multi-stage Docker builds

# Preparations

source ../../_utils/common.sh

# Define the file path
COMMON_FILE="../../_utils/common.sh"

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
  Red='\033[0;31m'          # Red
  Blue='\033[0;34m'         # Blue
fi

# Set the location for our demo 
BASE_FOLDER="/tmp/docker/003-MultiStage"

# Clear any previous data
echo -e "* ${Yellow}Setting up demo environment${Color_Off}"
rm    -rf   $BASE_FOLDER
mkdir -p    $BASE_FOLDER
cd          $BASE_FOLDER

echo -e "* ${Yellow}Creating multi-stage ${Green}Dockerfile${Color_Off} [ $BASE_FOLDER/Dockerfile ]"
cat << EOF > $BASE_FOLDER/Dockerfile
# Get the value of the desired image to build
ARG     BASE_IMG=curl

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
# We can also use image index instead
# COPY  --from=build-\${BASE_IMG} image.txt . to copy a specific content
RUN     cat image.txt
CMD     ["cat", "image.txt"]
EOF

echo -e "* ${Yellow}Building the docker images with different build arguments${Color_Off}"

# Clean up any existing images
echo -e "* ${Yellow}Cleaning up existing images${Color_Off}"
docker rmi curl1 curl2 bash1 bash2 2>/dev/null || true

echo -e "* ${Yellow}Building curl-based image (no-cache)${Color_Off}"
docker build --build-arg BASE_IMG=curl --no-cache -t curl1 . >/dev/null 2>&1 || true

echo -e "* ${Yellow}Building bash-based image (no-cache)${Color_Off}"
docker build --build-arg BASE_IMG=bash --no-cache -t bash1 . >/dev/null 2>&1 || true

### Build with cache
echo -e ""
echo -e "${Blue}========================================${Color_Off}"
echo -e "${Blue}= ${Yellow}Building with cache enabled${Color_Off}"
echo -e "${Blue}========================================${Color_Off}"
echo -e ""

echo -e "   * ${Yellow}Building curl-based image (with cache)${Color_Off}"
docker build --build-arg BASE_IMG=curl -t curl2 . >/dev/null >/dev/null 2>&1 || true

echo -e "   * ${Yellow}Building bash-based image (with cache)${Color_Off}"
docker build --build-arg BASE_IMG=bash -t bash2 . >/dev/null >/dev/null 2>&1 || true


echo -e "* ${Yellow}Testing the built images${Color_Off}"

echo -e "* ${Yellow}Testing curl1 image:${Color_Off}"
echo -e "  ${Green}$(docker run --rm curl1)${Color_Off}"

echo -e "* ${Yellow}Testing curl2 image:${Color_Off}"
echo -e "  ${Green}$(docker run --rm curl2)${Color_Off}"

echo -e "* ${Yellow}Testing bash1 image:${Color_Off}"
echo -e "  ${Green}$(docker run --rm bash1)${Color_Off}"

echo -e "* ${Yellow}Testing bash2 image:${Color_Off}"
echo -e "  ${Green}$(docker run --rm bash2)${Color_Off}"

echo -e ""
echo -e "${Blue}==========================================================${Color_Off}"
echo -e "${Blue}= ${Yellow}Creating second Dockerfile for advanced example${Color_Off}"
echo -e "${Blue}==========================================================${Color_Off}"

cat << EOF > $BASE_FOLDER/Dockerfile2
# Build the base image
FROM    alpine AS base_image

# Add some packages to the base image
FROM    base_image  AS build-curl
RUN     echo -e "\033[1;33mThis file is from curl image\033[0m" > image.txt

# Add some packages to the base image
FROM    base_image  AS build-bash
RUN     echo -e "\033[1;32mThis file is from bash image\033[0m" > image.txt

#   Build the desired image
FROM    build-curl
COPY    --from=2 image.txt .
RUN cat image.txt
CMD ["cat", "image.txt"]
EOF

echo -e "* ${Yellow}Building Dockerfile2 to demonstrate stage indexing${Color_Off}"
docker build -f Dockerfile2 -t multistage-example . >/dev/null 2>&1 || true

echo -e "* ${Yellow}Testing Dockerfile2 result:${Color_Off}"
echo -e "   ${Green}$(docker run --rm multistage-example)${Color_Off}"

echo -e "* ${Yellow}Building specific target (build-curl stage only)${Color_Off}"
docker build --target build-curl -f Dockerfile2 -t target-example . >/dev/null 2>&1 || true

echo -e "* ${Yellow}Testing target build:${Color_Off}"
echo -e "   ${Green}$(docker run --rm target-example cat image.txt)${Color_Off}"

echo -e ""
echo -e "${Blue}==========================================${Color_Off}"
echo -e "${Blue}= ${Yellow}Demonstrating image size differences${Color_Off}"
echo -e "${Blue}==========================================${Color_Off}"

echo -e "* ${Yellow}Image sizes:${Color_Off}"
docker images | grep -E "(curl1|curl2|bash1|bash2|multistage-example|target-example)" | while read line; do
    echo -e "   ${Green}$line${Color_Off}"
done

echo -e ""
echo -e "${Blue}===============================================${Color_Off}"
echo -e "${Blue}= ${Yellow}Showing build history for one of the images${Color_Off}"
echo -e "${Blue}===============================================${Color_Off}"

echo -e "* ${Yellow}Build history for curl1: ${Cyan}docker history curl1${Color_Off}"
docker history curl1

echo -e ""
echo -e "${Green}==========================================${Color_Off}"
echo -e "${Green}= Lab completed successfully!${Color_Off}"
echo -e "${Green}==========================================${Color_Off}"
echo -e ""
echo -e "* ${Yellow}Summary of what we accomplished:${Color_Off}"
echo -e "  1. Created a multi-stage Dockerfile with build arguments"
echo -e "  2. Built multiple images from the same Dockerfile using different arguments"
echo -e "  3. Demonstrated caching behavior in multi-stage builds"
echo -e "  4. Showed how to reference stages by index (--from=2)"
echo -e "  5. Built specific targets using --target flag"
echo -e "  6. Compared image sizes and build history"
echo -e ""

### Clean up
echo -e "* ${Yellow}Clean up${Color_Off}"
echo -e "   * ${Yellow}Removing test images${Color_Off}"
docker rmi curl1 curl2 bash1 bash2 multistage-example target-example >/dev/null 2>&1 || true

echo -e ""
echo -e "${Green}Multi-stage Docker lab completed!${Color_Off}"
