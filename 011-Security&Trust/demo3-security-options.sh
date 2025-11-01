#!/bin/bash
# demo3-security-options.sh
# Author: nirgeier@gmail.com
# Description: Demo of Docker security options (no-new-privileges)

set -e

echo "=== Demo 3: Security Options - no-new-privileges ==="
echo "Demonstrating prevention of privilege escalation..."

# Create a container that tries to escalate privileges
cat << 'EOF' > Dockerfile.priv
FROM alpine:latest

RUN apk add --no-cache su-exec

# Create a setuid binary (simulated privilege escalation attempt)
RUN echo '#!/bin/sh' > /usr/local/bin/escalate && \
    echo 'echo "Attempting privilege escalation..."' >> /usr/local/bin/escalate && \
    chmod +x /usr/local/bin/escalate

CMD ["sh", "-c", "echo 'Container started with UID: $(id -u)'; /usr/local/bin/escalate"]
EOF

docker build -f Dockerfile.priv -t priv-demo .

echo "Running without no-new-privileges (normal behavior)..."
docker run --rm priv-demo

echo ""
echo "Running with --security-opt=no-new-privileges..."
docker run --rm --security-opt=no-new-privileges priv-demo

echo ""
echo "Cleanup..."
docker rmi priv-demo 2>/dev/null || true
rm -f Dockerfile.priv

echo "=== Demo 3 completed ==="