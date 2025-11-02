#!/bin/bash
# demo.sh
# Author: nirgeier@gmail.com
# Description: A demo of advanced Docker builds using BuildKit and BuildX for multi-platform images

set -e  # Exit on any error

echo "=== Advanced Docker Build Demo ==="
echo "This demo shows BuildKit and BuildX features for multi-platform builds"
echo ""

# Ensure BuildKit is enabled
export DOCKER_BUILDKIT=1
echo "✓ BuildKit enabled (DOCKER_BUILDKIT=1)"

# Check if BuildX is available
if ! docker buildx version >/dev/null 2>&1; then
    echo "❌ BuildX is not available. Please install Docker Desktop or BuildX plugin."
    exit 1
fi
echo "✓ BuildX is available"

# Enable multi-platform support using Docker image
echo "=== Enabling multi-platform support ==="
docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64c
echo "✓ Multi-platform support enabled"

# Create a new builder instance
echo "=== Creating multi-platform builder ==="
docker buildx create --use --name advanced-builder --driver docker-container
echo "✓ Created builder 'advanced-builder'"

# Inspect the builder
echo "=== Builder Information ==="
docker buildx inspect advanced-builder
echo ""

# Create a sample multi-platform application
echo "=== Creating sample application ==="
mkdir -p multi-platform-app

# Create Dockerfile
cat << 'EOF' > multi-platform-app/Dockerfile
FROM node:18-alpine

# Add metadata
LABEL maintainer="nirgeier@gmail.com"
LABEL description="Multi-platform Node.js application demo"

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Change ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

CMD ["npm", "start"]
EOF

# Create package.json
cat << 'EOF' > multi-platform-app/package.json
{
  "name": "multi-platform-demo",
  "version": "1.0.0",
  "description": "Demo app for multi-platform Docker builds",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "keywords": ["docker", "multi-platform", "demo"],
  "author": "nirgeier@gmail.com",
  "license": "MIT"
}
EOF

# Create main application
cat << 'EOF' > multi-platform-app/index.js
const express = require('express');
const os = require('os');

const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from Advanced Docker Build!',
    platform: process.arch,
    platform_full: os.platform(),
    architecture: os.arch(),
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    buildkit: process.env.DOCKER_BUILDKIT || 'not set'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`🚀 Server running on port ${port}`);
  console.log(`📍 Platform: ${os.platform()} ${os.arch()}`);
});
EOF

# Create health check script
cat << 'EOF' > multi-platform-app/healthcheck.js
const http = require('http');

const options = {
  host: 'localhost',
  port: 3000,
  path: '/health',
  timeout: 2000
};

const request = http.request(options, (res) => {
  console.log(`STATUS: ${res.statusCode}`);
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
});

request.on('error', function(err) {
  console.log('ERROR');
  process.exit(1);
});

request.end();
EOF

echo "✓ Sample application created"

# Build for multiple platforms
echo "=== Building for multiple platforms ==="
echo "Building for: linux/amd64, linux/arm64, linux/arm/v7"
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t multi-platform-demo:latest \
  --load \
  ./multi-platform-app

echo "✓ Multi-platform build completed"

# List the built images
echo "=== Built Images ==="
docker images multi-platform-demo
echo ""

# Test the built image
echo "=== Testing the built image ==="
docker run -d --name test-multi-platform -p 3000:3000 multi-platform-demo:latest
sleep 3

# Make a request to the application
curl -s http://localhost:3000 | jq . 2>/dev/null || curl -s http://localhost:3000
echo ""

# Clean up test container
docker stop test-multi-platform
docker rm test-multi-platform

# Demonstrate build with custom output
echo "=== Building with custom output (export to local directory) ==="
mkdir -p ./build-output
docker buildx build \
  --platform linux/amd64 \
  -t multi-platform-demo:export \
  --output type=local,dest=./build-output \
  ./multi-platform-app

echo "✓ Build artifacts exported to ./build-output"
ls -la ./build-output
echo ""

# Demonstrate Bake functionality
echo "=== Demonstrating Docker Bake ==="

# Create docker-bake.hcl
cat << 'EOF' > docker-bake.hcl
group "default" {
  targets = ["web", "api"]
}

target "web" {
  context = "./multi-platform-app"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["multi-platform-demo:web"]
  args = {
    SERVICE_NAME = "web"
  }
}

target "api" {
  context = "./multi-platform-app"
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["multi-platform-demo:api"]
  args = {
    SERVICE_NAME = "api"
  }
}
EOF

echo "✓ Created docker-bake.hcl"

# Show bake plan
echo "=== Bake Plan ==="
docker buildx bake --print
echo ""

# Build using bake
echo "=== Building with Bake ==="
docker buildx bake

echo "✓ Bake build completed"

# List all built images
echo "=== All Built Images ==="
docker images | grep multi-platform-demo
echo ""

# Clean up
echo "=== Cleaning up ==="
docker rmi $(docker images -q multi-platform-demo) 2>/dev/null || true
docker buildx rm advanced-builder
rm -rf multi-platform-app build-output docker-bake.hcl

echo "✓ Cleanup completed"
echo ""
echo "🎉 Demo completed successfully!"
echo ""
echo "Key takeaways:"
echo "- BuildKit provides faster, more efficient builds"
echo "- BuildX enables multi-platform builds"
echo "- Use docker/binfmt image for local multi-platform support"
echo "- Bake allows complex, multi-target builds"
echo "- Multi-platform images work across different architectures"</content>
<parameter name="filePath">/Users/nirg/repositories/DockerLabs/Labs/016-Advanced-Build/demo.sh