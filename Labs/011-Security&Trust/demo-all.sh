#!/bin/bash
# demo.sh
# Author: nirgeier@gmail.com
# Description: A demo of Docker security features and best practices

set -e  # Exit on any error

echo "=== Docker Security & Trust Demo ==="
echo "This demo covers various Docker security features."
echo ""

# Demo 1: Non-root user execution
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

# Demo 2: Linux Capabilities
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
docker run --rm -d --name netcat-test netcat-demo || echo "Failed as expected"

echo "Running with NET_BIND_SERVICE capability..."
docker run --rm -d --name netcat-test --cap-add=NET_BIND_SERVICE netcat-demo
sleep 2
docker logs netcat-test
docker stop netcat-test 2>/dev/null || true

echo ""

# Demo 3: Security Options
echo "=== Demo 3: Security Options ==="
echo "Demonstrating no-new-privileges..."

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

echo "Running with no-new-privileges..."
docker run --rm --security-opt=no-new-privileges priv-demo

echo ""

# Demo 4: Seccomp Profile
echo "=== Demo 4: Seccomp Profile ==="
echo "Checking current seccomp status..."

docker run --rm alpine sh -c "grep Seccomp /proc/1/status" || echo "Seccomp info not available"

echo "Running container with custom seccomp profile would require a JSON profile file."
echo "Docker uses a default restrictive profile."

echo ""

# Demo 5: AppArmor
echo "=== Demo 5: AppArmor ==="
echo "Checking AppArmor status..."

docker run --rm alpine sh -c "cat /proc/1/attr/current" 2>/dev/null || echo "AppArmor not available or not enforced"

echo "Docker applies docker-default AppArmor profile by default."

echo ""

# Demo 6: User Namespace Remapping
echo "=== Demo 6: User Namespace Remapping ==="
echo "Checking if user namespaces are enabled..."

if [ -f /proc/sys/kernel/unprivileged_userns_clone ]; then
    echo "User namespaces available: $(cat /proc/sys/kernel/unprivileged_userns_clone)"
else
    echo "User namespaces not available in this environment"
fi

echo "To enable user namespace remapping, modify /etc/docker/daemon.json:"
echo '{ "userns-remap": "default" }'
echo "Then restart Docker daemon."

echo ""

# Cleanup
echo "=== Cleanup ==="
docker rmi nonroot-demo netcat-demo priv-demo 2>/dev/null || true
rm -f Dockerfile.nonroot Dockerfile.netcat Dockerfile.priv

echo "=== Demo completed ==="
echo "Key takeaways:"
echo "- Always run containers as non-root users"
echo "- Drop unnecessary capabilities"
echo "- Use security options like no-new-privileges"
echo "- Leverage Seccomp and AppArmor for kernel protection"
echo "- Consider user namespace remapping for additional isolation"