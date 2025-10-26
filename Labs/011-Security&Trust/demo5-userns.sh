#!/bin/bash
# demo5-userns.sh
# Author: nirgeier@gmail.com
# Description: Demo of User Namespace Remapping

set -e

echo "=== Demo 5: User Namespace Remapping ==="
echo "Checking user namespace availability and configuration..."

if [ -f /proc/sys/kernel/unprivileged_userns_clone ]; then
    echo "User namespaces available: $(cat /proc/sys/kernel/unprivileged_userns_clone)"
    if [ "$(cat /proc/sys/kernel/unprivileged_userns_clone)" = "1" ]; then
        echo "✓ User namespaces are enabled"
    else
        echo "✗ User namespaces are disabled"
    fi
else
    echo "User namespaces not supported in this kernel"
fi

echo ""
echo "Checking if Docker daemon has user namespace remapping enabled..."

# Try to check Docker daemon config
if command -v docker &> /dev/null; then
    echo "Docker info (user namespaces):"
    docker info 2>/dev/null | grep -i "userns" || echo "No userns info available"
else
    echo "Docker command not found"
fi

echo ""
echo "To enable user namespace remapping:"
echo "1. Create /etc/docker/daemon.json with:"
echo '   { "userns-remap": "default" }'
echo "2. Or specify a user: { \"userns-remap\": \"myuser\" }"
echo "3. Restart Docker daemon: sudo systemctl restart docker"
echo ""
echo "When enabled, root in container (UID 0) maps to unprivileged user on host."
echo "This prevents container breakout from gaining host root access."

echo ""
echo "Testing user namespace isolation (if enabled)..."
# This would require userns to be enabled to show different behavior

echo "=== Demo 5 completed ==="