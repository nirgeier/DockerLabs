#!/bin/bash

### In this lab we will create our first conteiner

# Preperations

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
fi

# Set the location for our demo 
BASE_FOLDER="/tmp/docker/000-FirstContainer"

# Clear any prevoius data
rm    -rf   $BASE_FOLDER
mkdir -p    $BASE_FOLDER
cd          $BASE_FOLDER

# Create the server code
echo -e "${Yellow}Creating ${Green}server.js${Color_Off} [ $BASE_FOLDER/server.js ]"
cat << EOF > $BASE_FOLDER/server.js
//
// Simple NodeJs Server
// The server is listening by default to port 8888
//
 
// import the HTTP module
var http = require('http');

// Define a port we want to listen to
// Later on we will pass the port as env parameter
// Default port is set to 8888
const PORT= process.env.PORT || 8888; 

// Create the server and listen for requests
http.createServer((request, response)=>{
    response.end('Server is running.!! You asked for: ' + request.url);
}).listen(PORT, ()=>{
    // Callback is triggered when server is getting a request
    console.log("Server listening on: http://localhost:%s", PORT);
});
EOF

# Create the server code
echo -e "${Yellow}Test the ${Green}server.js${Color_Off} [ $PWD ]"

echo -e "   * ${Yellow}Remove any existing test server container${Color_Off}"
docker stop node_server 2&> /dev/null
docker rm node_server   2&> /dev/null

echo -e "   * ${Yellow}Spin a nodejs container${Color_Off}"
# Test the node code
#   --rm            =   remove the container when done
#   -d              =   run in detached mode
#   -p              =   open the required ports
#   -v              =   volume
#   -w              =   workdir
#   --name          =   the container name
#   node            =   Execute a nodejs container to test our code
#   node script.js  =   Execute the code
docker   run --rm -d          \
   -v     $(pwd):/usr/src \
   -w     /usr/src        \
   -p     8888:8888           \
   --name node_server         \
   node                       \
   node server.js 2&> /dev/null         

# Wait for the container to start  
echo -e "   * ${Yellow}Waiting for the server${Color_Off}"
sleep 3

# Test out demo server code
echo -e "   * ${Yellow}Test the server${Color_Off}"
echo -e "   * ${Yellow}Server response: ${Green}$(curl -sL localhost:8888)${Color_Off}"

# Remove the docker container
echo -e "   * ${Yellow}Removing the docker test container${Color_Off}"
docker kill node_server 2&> /dev/null 

# Remove the docker container
echo -e "* ${Yellow}Creating Dockerfile${Color_Off}"

# Fetch the latest release from the official Node.js GitHub repository
echo -e "   * ${Yellow}Fetch the latest release from the official Node.js GitHub repository${Color_Off}"
NODEJS_RELEASE=$(curl --silent \
  "https://api.github.com/repos/nodejs/node/releases/latest" \
  | grep '"tag_name":' \
  | sed -n -e 's/^.*"tag_name": "v\([^"]*\)".*$/\1/p')

echo -e "   * ${Yellow}The latest Node.js version is: ${Green}$NODEJS_RELEASE${Color_Off}"

cat << EOF > $BASE_FOLDER/Dockerfile
#
# Filename: Dockerfile
#
# Use node as our base image
FROM  node:$NODEJS_RELEASE

# Optional: Set working directory
WORKDIR  /usr/src

# Copy the server code to our working directory [.]
COPY     server.js .

# Mark the port which will required for the server
EXPOSE   8888

# Start the server when the container is started
CMD ["node", "server.js"]
EOF

echo -e "* ${Yellow}Verifying Dockerfile (linting)${Color_Off}"
docker run --rm -i hadolint/hadolint < Dockerfile

echo -e "* ${Yellow}Building the docker image${Color_Off}"  
echo -e "   * ${Green}Tagging the docker image: ${Green}nirgeier/docker-labs-000${Color_Off}"  
docker build -t nirgeier/docker-labs-000 .

echo -e "* ${Yellow}Pushing the docker image to docker registry${Color_Off}"  
docker push nirgeier/docker-labs-000

echo -e "* ${Yellow}Removing old docker container${Color_Off}"  
docker kill 000-container
docker rm 000-container

echo -e "* ${Yellow}Verifying the docker container${Color_Off}"  
docker   run -d --rm              \
         -p     8888:8888         \
         --name 000-container     \
         nirgeier/docker-labs-000

echo -e -n "* ${Yellow}Waiting for the container to start ${Color_Off}"  
for i in {1..50}; 
do 
    echo -e -n "${Red}.${Color_Off}"
    sleep 0.1
done
echo -e "${Color_Off}"

### Check that the container is working as expected
echo -e "* ${Yellow}View the logs${Color_Off}"  
docker logs 000-container  

### Test that the container is working as expected
echo -e "* ${Yellow}Test the container${Color_Off}"  
echo -e ""
echo -e "${Green}-------------------------------------------${Color_Off}"  
echo -e "${Green}$(curl -s localhost:8888)"  
echo -e "${Green}-------------------------------------------${Color_Off}"  


### Clean up
echo -e "* ${Yellow}Clean up${Color_Off}"  
docker kill 000-container
