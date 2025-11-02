#!/bin/bash

###############################################################################
# crictl Demo Script
# This script demonstrates basic crictl usage for debugging containers
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

###############################################################################
# Step 1: Setup and Configuration
###############################################################################

print_header "Step 1: Setup crictl Configuration"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_info "Detected macOS - Using Docker Desktop containerd socket"
    SOCKET_PATH="unix:///var/run/containerd/containerd.sock"
    CONFIG_DIR="$HOME/.config/crictl"
else
    print_info "Detected Linux - Checking for containerd socket"
    if [ -S "/run/containerd/containerd.sock" ]; then
        SOCKET_PATH="unix:///run/containerd/containerd.sock"
    elif [ -S "/var/run/containerd/containerd.sock" ]; then
        SOCKET_PATH="unix:///var/run/containerd/containerd.sock"
    else
        print_error "Containerd socket not found!"
        exit 1
    fi
    CONFIG_DIR="/etc/crictl"
fi

print_info "Socket path: $SOCKET_PATH"
print_info "Config directory: $CONFIG_DIR"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Create crictl config
print_info "Creating crictl configuration..."
cat > "$CONFIG_DIR/crictl.yaml" <<EOF
runtime-endpoint: $SOCKET_PATH
image-endpoint: $SOCKET_PATH
timeout: 10
debug: false
pull-image-on-create: false
EOF

print_success "Configuration created at $CONFIG_DIR/crictl.yaml"

###############################################################################
# Step 2: Verify crictl Installation and Connection
###############################################################################

print_header "Step 2: Verify crictl Installation"

# Check if crictl is installed
if ! command -v crictl &> /dev/null; then
    print_error "crictl is not installed!"
    print_info "Install with: brew install crictl (macOS) or download from GitHub releases"
    exit 1
fi

print_success "crictl is installed"

# Get version
print_info "crictl version:"
crictl version || {
    print_error "Failed to connect to runtime!"
    print_info "Make sure Docker Desktop is running (macOS) or containerd is running (Linux)"
    exit 1
}

print_success "Successfully connected to container runtime"

###############################################################################
# Step 3: Working with Images
###############################################################################

print_header "Step 3: Working with Container Images"

# List existing images
print_info "Listing existing images..."
crictl images

# Pull a test image
print_info "Pulling nginx:alpine image..."
crictl pull nginx:alpine
print_success "Image pulled successfully"

# Inspect the image
print_info "Inspecting nginx:alpine image..."
crictl inspecti nginx:alpine | head -20

###############################################################################
# Step 4: Create Pod Configuration
###############################################################################

print_header "Step 4: Creating Pod and Container Configurations"

# Create pod config
print_info "Creating pod configuration..."
cat > /tmp/crictl-pod-config.json <<EOF
{
    "metadata": {
        "name": "crictl-demo-pod",
        "namespace": "default",
        "uid": "crictl-demo-uid-$(date +%s)"
    },
    "log_directory": "/tmp",
    "linux": {}
}
EOF

print_success "Pod config created: /tmp/crictl-pod-config.json"

# Create container config
print_info "Creating container configuration..."
cat > /tmp/crictl-container-config.json <<EOF
{
    "metadata": {
        "name": "nginx-container"
    },
    "image": {
        "image": "nginx:alpine"
    },
    "command": [
        "sh",
        "-c",
        "echo 'Container started at: \$(date)' && nginx -g 'daemon off;'"
    ],
    "log_path": "nginx-container.log",
    "linux": {}
}
EOF

print_success "Container config created: /tmp/crictl-container-config.json"

###############################################################################
# Step 5: Create and Start Pod and Container
###############################################################################

print_header "Step 5: Creating and Starting Pod/Container"

# Create pod sandbox
print_info "Creating pod sandbox..."
POD_ID=$(crictl runp /tmp/crictl-pod-config.json)
print_success "Pod created with ID: $POD_ID"

# List pods
print_info "Current pods:"
crictl pods

# Create container
print_info "Creating container..."
CONTAINER_ID=$(crictl create "$POD_ID" /tmp/crictl-container-config.json /tmp/crictl-pod-config.json)
print_success "Container created with ID: $CONTAINER_ID"

# Start container
print_info "Starting container..."
crictl start "$CONTAINER_ID"
print_success "Container started"

# Wait a moment for container to initialize
sleep 2

###############################################################################
# Step 6: Inspect and Debug Container
###############################################################################

print_header "Step 6: Inspecting and Debugging Container"

# List running containers
print_info "Running containers:"
crictl ps

# Get container stats
print_info "Container statistics:"
crictl stats "$CONTAINER_ID"

# Inspect container
print_info "Container details (first 30 lines):"
crictl inspect "$CONTAINER_ID" | head -30

# View logs
print_info "Container logs:"
crictl logs "$CONTAINER_ID"

# Execute command in container
print_info "Executing 'ps aux' in container:"
crictl exec "$CONTAINER_ID" ps aux

print_info "Checking nginx process:"
crictl exec "$CONTAINER_ID" sh -c "ps aux | grep nginx"

###############################################################################
# Step 7: Advanced Debugging
###############################################################################

print_header "Step 7: Advanced Debugging Examples"

# Get container IP
print_info "Container IP address:"
CONTAINER_IP=$(crictl inspect "$CONTAINER_ID" | grep -o '"ip":"[^"]*"' | cut -d'"' -f4 | head -1)
if [ -n "$CONTAINER_IP" ]; then
    print_success "Container IP: $CONTAINER_IP"
else
    print_warning "Could not determine container IP"
fi

# Check environment variables
print_info "Container environment variables:"
crictl exec "$CONTAINER_ID" env | head -10

# Check file system
print_info "Container root directory contents:"
crictl exec "$CONTAINER_ID" ls -la /

# Check nginx configuration
print_info "Nginx configuration:"
crictl exec "$CONTAINER_ID" cat /etc/nginx/nginx.conf | head -20

###############################################################################
# Step 8: Monitoring
###############################################################################

print_header "Step 8: Monitoring Container"

print_info "Getting real-time stats (5 seconds)..."
timeout 5 crictl stats || true

###############################################################################
# Step 9: Cleanup
###############################################################################

print_header "Step 9: Cleanup"

print_warning "Cleaning up demo resources..."

# Stop container
print_info "Stopping container..."
crictl stop "$CONTAINER_ID" &>/dev/null || true
print_success "Container stopped"

# Remove container
print_info "Removing container..."
crictl rm "$CONTAINER_ID" &>/dev/null || true
print_success "Container removed"

# Stop pod
print_info "Stopping pod..."
crictl stopp "$POD_ID" &>/dev/null || true
print_success "Pod stopped"

# Remove pod
print_info "Removing pod..."
crictl rmp "$POD_ID" &>/dev/null || true
print_success "Pod removed"

# Clean up config files
print_info "Removing temporary config files..."
rm -f /tmp/crictl-pod-config.json /tmp/crictl-container-config.json
print_success "Temporary files removed"

# Optionally remove the demo image
read -p "Do you want to remove the nginx:alpine image? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Removing nginx:alpine image..."
    crictl rmi nginx:alpine || true
    print_success "Image removed"
fi

###############################################################################
# Summary
###############################################################################

print_header "Demo Complete!"

print_success "Summary of what we did:"
echo "1. ✓ Configured crictl to use containerd socket"
echo "2. ✓ Verified crictl installation and connectivity"
echo "3. ✓ Pulled and inspected container images"
echo "4. ✓ Created pod and container configurations"
echo "5. ✓ Started a pod with an nginx container"
echo "6. ✓ Inspected container details and viewed logs"
echo "7. ✓ Executed commands inside the container"
echo "8. ✓ Monitored container resource usage"
echo "9. ✓ Cleaned up all demo resources"

print_info "\nUseful crictl commands for debugging:"
echo "  crictl ps          - List running containers"
echo "  crictl ps -a       - List all containers"
echo "  crictl logs <id>   - View container logs"
echo "  crictl exec <id>   - Execute command in container"
echo "  crictl inspect <id> - Get detailed container info"
echo "  crictl stats       - Show resource usage"
echo "  crictl pods        - List pods"

print_success "\nFor more information, see the README.md"
