#!/bin/bash
# demo.sh
# Author: nirgeier@gmail.com
# Description: A simple demo of using the dive tool to inspect an image

docker pull wagoodman/dive

# Check if dive is installed
if ! command -v dive &> /dev/null
then
  echo "dive could not be found, installing..."
else
  # Install dive if not installed
  alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock docker.io/wagoodman/dive"
fi

cat << EOF > Dockerfile
### Layer 00
FROM alpine

## Layer 01
WORKDIR /__app

## Layer 02
RUN echo "Hello World" > file1.txt

## Layer 03
RUN echo "10.10.10.10" > /etc/hosts

## Layer 04
RUN cat /etc/hosts > hosts.txt

EOF

# Build the image
docker  build -t nirgeier/docker-labs-07-dive -f Dockerfile .

###
# Print the contents of the Dockerfile layers
echo "=== Dockerfile Layers ==="
echo "Layer 00: FROM alpine"
echo "Layer 01: WORKDIR /__app"
echo "Layer 02: RUN echo \"Hello World\" > file1.txt"
echo "Layer 03: RUN echo \"10.10.10.10\" > /etc/hosts"
echo "Layer 04: RUN cat /etc/hosts > hosts.txt"
echo "========================="


# Run the image with dive
dive nirgeier/docker-labs-07:latest --json output.json

# Search for the files we changed
jq '.layer[] | select(.index >= 2) | "\(.command) -> \(.fileList[]?.path)"' output.json