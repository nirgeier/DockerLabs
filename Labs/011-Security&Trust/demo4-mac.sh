#!/bin/bash
# demo4-mac.sh
# Author: nirgeier@gmail.com
# Description: Demo of Mandatory Access Control (Seccomp and AppArmor)

set -e

echo "=== Demo 4: Mandatory Access Control (MAC) ==="
echo "Checking Seccomp and AppArmor status..."

echo "Seccomp status:"
docker run --rm alpine sh -c "grep Seccomp /proc/1/status 2>/dev/null || echo 'Seccomp info not available'" 2>/dev/null || echo "Cannot check Seccomp in container"

echo ""
echo "AppArmor status:"
docker run --rm alpine sh -c "cat /proc/1/attr/current 2>/dev/null || echo 'AppArmor not available'" 2>/dev/null || echo "Cannot check AppArmor in container"

echo ""
echo "Docker uses default profiles:"
echo "- Seccomp: restrictive default profile blocks dangerous syscalls"
echo "- AppArmor: docker-default profile provides moderate protection"

echo ""
echo "To use custom profiles:"
echo "docker run --rm --security-opt seccomp=/path/to/profile.json alpine"
echo "docker run --rm --security-opt apparmor=profile-name alpine"

echo ""
echo "Note: Custom profiles require profile files to be available on the host."

echo "=== Demo 4 completed ==="