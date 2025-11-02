#!/bin/bash
# demo1-nonroot.sh
# Author: nirgeier@gmail.com
# Description: Demo of non-root user execution in Docker

set -e

echo "=== Demo 1: Non-Root User Execution ==="
echo "Creating a Dockerfile with non-root user..."

cat << 'EOF' > Dockerfile.nonroot
FROM alpine:latest

# Create a non-root user
RUN adduser -D appuser

# Set ownership and switch user
RUN mkdir /app && chown -R appuser:appuser /app
USER appuser

WORKDIR /app

# Simple command to show user
CMD ["sh", "-c", "echo 'Running as user: $(whoami) with UID: $(id -u)'"]
EOF

echo "Building and running non-root container..."
docker build -f Dockerfile.nonroot -t nonroot-demo .
docker run --rm nonroot-demo

echo ""
echo "Cleanup..."
docker rmi nonroot-demo 2>/dev/null || true
rm -f Dockerfile.nonroot

echo "=== Demo 1 completed ==="