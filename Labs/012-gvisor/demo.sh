#!/bin/bash

# demo.sh - Demonstrate blocking user creation with gVisor seccomp profile

set -e

PROFILE="block-user-creation.json"
PROFILE_PATH="./block-user-creation.json"
IMAGE="ubuntu"
CONTAINER_NAME="gvisor-block-user-demo"

cat << EOF > $PROFILE_PATH
{
  "defaultAction": "SCMP_ACT_ALLOW",
  "syscalls": [
    {
      "names": ["setuid", "setgid", "setgroups", "setreuid", "setregid", "openat", "unlinkat", "write", "rename", "chmod", "fchmod", "fchmodat"],
      "action": "SCMP_ACT_ERRNO"
    }
  ]
}
EOF

echo "=== gVisor User Creation Block Demo ==="
echo "Using seccomp profile: $PROFILE_PATH"

# Pull Ubuntu image if not present
docker image inspect $IMAGE >/dev/null 2>&1 || docker pull $IMAGE

# Run container with gVisor and seccomp profile
echo "Attempting to create a user inside the container (should fail)..."
docker run --rm \
  --runtime=runsc \
  --security-opt seccomp=$PROFILE_PATH \
  --name $CONTAINER_NAME \
  $IMAGE useradd testuser

EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  echo "✅ User creation was blocked as expected (exit code: $EXIT_CODE)."
else
  echo "❌ User creation succeeded (unexpected)."
fi