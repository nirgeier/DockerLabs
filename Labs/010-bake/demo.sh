#!/bin/bash
# demo.sh
# Author: nirgeier@gmail.com
# Description: A demo of using Docker Bake to build multiple images

set -e  # Exit on any error

# Ensure BuildKit is enabled
export DOCKER_BUILDKIT=1

# Create a sample docker-bake.hcl file
cat << 'EOF' > docker-bake.hcl
# Define variables
variable "tag" {
  default = "latest"
}

variable "user" {
  default = "nirgeier"
}

# Define a group of targets for default builds
group "default" {
  targets = ["frontend", "backend"]
}

# Frontend service
target "frontend" {
  context = "./frontend"
  dockerfile = "Dockerfile"
  tags = ["${user}/frontend:${tag}"]
  platforms = ["linux/amd64"]
  args = {
    NODE_ENV = "production"
  }
}

# Backend service
target "backend" {
  context = "./backend"
  dockerfile = "Dockerfile"
  tags = ["${user}/backend:${tag}"]
  platforms = ["linux/amd64"]
  args = {
    NODE_ENV = "production"
  }
}
EOF

echo "=== Created docker-bake.hcl ==="
cat docker-bake.hcl
echo "================================"

# Create frontend directory and files
mkdir -p frontend
cat << 'EOF' > frontend/Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF

cat << 'EOF' > frontend/package.json
{
  "name": "frontend",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat << 'EOF' > frontend/server.js
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Hello from Frontend!');
});

app.listen(port, () => {
  console.log(`Frontend listening on port ${port}`);
});
EOF

# Create backend directory and files
mkdir -p backend
cat << 'EOF' > backend/Dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 4000
CMD ["npm", "start"]
EOF

cat << 'EOF' > backend/package.json
{
  "name": "backend",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat << 'EOF' > backend/server.js
const express = require('express');
const app = express();
const port = 4000;

app.get('/', (req, res) => {
  res.send('Hello from Backend!');
});

app.listen(port, () => {
  console.log(`Backend listening on port ${port}`);
});
EOF

echo "=== Created sample frontend and backend apps ==="

# Show the bake configuration
echo "=== Bake Configuration ==="
docker buildx bake --print
echo "==========================="

# Build the default group
echo "=== Building default group (frontend and backend) ==="
docker buildx bake

# List the built images
echo "=== Built Images ==="
docker images | grep nirgeier
echo "===================="

# Build only frontend
echo "=== Building only frontend ==="
docker buildx bake frontend

# Build with custom tag
echo "=== Building with custom tag ==="
export BAKE_TAG=v1.0
docker buildx bake
unset BAKE_TAG

# List the built images with custom tag
docker images | grep nirgeier

# Use read command to wait for user inuput
read -p "Press [Enter] key to continue..."

# Clean up
echo "=== Cleaning up ==="
docker rmi $(docker images -q nirgeier/*) 2>/dev/null || true
rm -rf frontend backend docker-bake.hcl

echo "=== Demo completed ==="