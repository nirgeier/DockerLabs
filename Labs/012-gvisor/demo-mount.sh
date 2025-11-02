#!/bin/bash

# demo-mount.sh - Demonstrate blocking mount operations with gVisor seccomp profile

set -e

PROFILE="block-mount.json"
PROFILE_PATH="./block-mount.json"
IMAGE="alpine"
CONTAINER_NAME="gvisor-block-mount-demo"

cat << EOF > $PROFILE_PATH
{
  "defaultAction": "SCMP_ACT_ALLOW",
  "syscalls": [
    {
      "names": ["mount", "umount", "umount2"],
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
EOF

echo "=== gVisor Mount Block Demo ==="
echo "Using seccomp profile: $PROFILE_PATH"

# Build the image if not present
if ! docker image inspect gvisor-mount >/dev/null 2>&1; then
  echo "Building gvisor-mount image..."
  docker build -t gvisor-mount .
fi

# Run container with gVisor and seccomp profile
echo "Attempting to mount tmpfs inside the container (should fail)..."
docker run --rm \
  --runtime=runsc \
  --security-opt seccomp=$PROFILE_PATH \
  --name $CONTAINER_NAME \
  gvisor-mount

EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "✅ Mount operation was blocked as expected (exit code: $EXIT_CODE)."
else
  echo "❌ Mount operation succeeded (unexpected)."
fi