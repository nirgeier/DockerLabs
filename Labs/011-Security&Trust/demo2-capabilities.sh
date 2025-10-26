#!/bin/bash
# demo2-capabilities.sh
# Author: nirgeier@gmail.com
# Description: Demo of Linux capabilities in Docker

set -e

echo "=== Demo 2: Linux Capabilities ==="
echo "Demonstrating capability dropping and adding..."

# Create a simple netcat server that needs NET_BIND_SERVICE
cat << 'EOF' > Dockerfile.netcat
FROM alpine:latest

RUN apk add --no-cache netcat-openbsd

# Create non-root user
RUN adduser -D appuser

USER appuser

# Try to bind to port 80 (needs NET_BIND_SERVICE)
CMD ["nc", "-l", "-p", "80", "-c", "echo 'Hello from port 80!'"]
EOF

docker build -f Dockerfile.netcat -t netcat-demo .

echo "Trying to run with default capabilities (should fail on port 80)..."
docker run --rm -d --name netcat-test netcat-demo 2>/dev/null || echo "Failed as expected - no NET_BIND_SERVICE capability"

echo "Running with NET_BIND_SERVICE capability..."
docker run --rm -d --name netcat-test --cap-add=NET_BIND_SERVICE netcat-demo
sleep 2
docker logs netcat-test 2>/dev/null || echo "Container may have exited"
docker stop netcat-test 2>/dev/null || true

echo "Running with all capabilities dropped, then NET_BIND_SERVICE added..."
docker run --rm -d --name netcat-test --cap-drop=ALL --cap-add=NET_BIND_SERVICE netcat-demo
sleep 2
docker logs netcat-test 2>/dev/null || echo "Container may have exited"
docker stop netcat-test 2>/dev/null || true

echo ""
echo "Cleanup..."
docker rmi netcat-demo 2>/dev/null || true
rm -f Dockerfile.netcat

echo "=== Demo 2 completed ==="