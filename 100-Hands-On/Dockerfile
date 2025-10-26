# Base image for Node.js
FROM node:latest

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the server file into the container 
# (Don`t forget the dot at the end)
COPY server.js .

# Expose port 8080
# This is the port our server will listen to
EXPOSE 8080

# Start the Node.js server
CMD [ "node", "server.js" ]