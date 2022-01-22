#!/bin/bash  -x

# Build The curl based image (no-cache)
docker build --build-arg BASE_IMG=curl --no-cache -t curl1 .

# Build The bash based image (no-cache)
docker build --build-arg BASE_IMG=bash --no-cache -t bash1 .

### Build with cache
echo -e ""
echo -e "\033[1;33m---------------------------------\033[0m"
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
