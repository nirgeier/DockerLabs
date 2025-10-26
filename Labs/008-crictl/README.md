

![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 008 - Debugging Containers with crictl

- In this lab we will explore `crictl`, a command-line interface for CRI-compatible container runtimes
- `crictl` is designed for debugging and inspecting containers and images on Kubernetes nodes
- We will learn how to install, configure, and use `crictl` to debug Docker containers
- This tool is essential for troubleshooting container issues in Kubernetes environments
- The lab is divided into several tasks:
    
  - [01. What is crictl?](#01-what-is-crictl)
  - [02. Prerequisites](#02-prerequisites)
  - [03. Installation](#03-installation)
  - [04. Basic Configuration](#04-basic-configuration)
  - [05. Working with Container Images](#05-working-with-container-images)
  - [06. Container Operations](#06-container-operations)
  - [07. Pod Operations](#07-pod-operations)
  - [08. Debugging Containers](#08-debugging-containers)
  - [09. Inspecting Container Resources](#09-inspecting-container-resources)
  - [10. Logs and Troubleshooting](#10-logs-and-troubleshooting)
  - [11. Advanced Debugging Techniques](#11-advanced-debugging-techniques)
  - [12. Clean up](#12-clean-up)

---

## 01. What is crictl?

**crictl** (CRI CLI) is a command-line interface for interacting with CRI-compatible container runtimes. It provides:

- **Container Runtime Interface (CRI)**: Direct interaction with container runtimes like containerd, CRI-O, and Docker (via dockershim)
- **Debugging Tool**: Designed specifically for debugging containers in Kubernetes environments
- **Inspection Capabilities**: Detailed inspection of containers, pods, and images
- **Troubleshooting**: Essential for diagnosing container issues on Kubernetes nodes

### Key Features

- ✅ List and inspect containers and pods
- ✅ View container logs and execute commands
- ✅ Pull and manage container images
- ✅ Monitor container resource usage
- ✅ Debug container networking and storage
- ✅ Compatible with multiple container runtimes

### crictl vs docker CLI

| Feature | crictl | docker |
|---------|--------|--------|
| Purpose | Kubernetes debugging | General container management |
| Scope | CRI-compatible runtimes | Docker Engine only |
| Pod Support | Native | No |
| Use Case | K8s troubleshooting | Development & production |

---

## 02. Prerequisites

Before installing `crictl`, ensure you have:

- **Operating System**: Linux or macOS
- **Container Runtime**: One of the following:
  - containerd (standalone or via Kubernetes)
  - CRI-O
  - Docker Desktop (macOS/Windows)
  - Minikube, kind, or k3s (with containerd)
- **Root/Sudo Access**: Required for most operations
- **curl or wget**: For downloading the binary

!!! important "OrbStack Users"
    OrbStack doesn't expose containerd's CRI socket directly. To use crictl:
    
    1. **Option 1**: Use Minikube, kind, or k3s which provide CRI access
    2. **Option 2**: Use Docker CLI for container debugging instead
    3. **Option 3**: Use a Kubernetes cluster (local or remote)
    
    This lab is designed for environments with direct CRI access.

### Check Existing Runtime

```bash
# Check if containerd is running
systemctl status containerd

# Check if Docker is running
systemctl status docker

# Check runtime socket locations
ls -la /var/run/containerd/containerd.sock
ls -la /var/run/dockershim.sock
ls -la /var/run/crio/crio.sock
```

---

## 03. Installation

### Option 1: Download Pre-built Binary (Recommended)

```bash
# Set the version
VERSION="v1.28.0"

# Download crictl
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz

# Extract the binary
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin

# Remove the archive
rm -f crictl-$VERSION-linux-amd64.tar.gz

# Verify installation
crictl --version
```

### Option 2: Install via Package Manager

**On Ubuntu/Debian:**

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes repository
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install cri-tools
sudo apt-get update
sudo apt-get install -y cri-tools

# Verify installation
crictl --version
```

**On macOS:**

```bash
# Using Homebrew
brew install crictl

# Verify installation
crictl --version
```

### Option 3: Build from Source

```bash
# Install Go (if not already installed)
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Clone the repository
git clone https://github.com/kubernetes-sigs/cri-tools.git
cd cri-tools

# Build crictl
make

# Install the binary
sudo install -m 755 build/bin/linux/amd64/crictl /usr/local/bin/crictl

# Verify installation
crictl --version
```

---

## 04. Basic Configuration

### Create Configuration File

`crictl` uses a configuration file to determine which runtime socket to connect to:

```bash
# Create the config directory
sudo mkdir -p /etc/crictl

# Create the configuration file
sudo tee /etc/crictl/crictl.yaml > /dev/null <<EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: false
pull-image-on-create: false
EOF
```

### Configuration for Different Runtimes

**For Docker Desktop (macOS/Windows):**

!!! warning "Docker Desktop Uses Containerd"
    Docker Desktop uses containerd as its runtime. Use the containerd socket, not the Docker socket.

```bash
# For macOS with Docker Desktop
mkdir -p ~/.config/crictl
cat > ~/.config/crictl/crictl.yaml <<EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: false
EOF
```

**For Docker Engine on Linux (using containerd):**

```bash
# Docker Engine uses containerd, not CRI directly
sudo tee /etc/crictl/crictl.yaml > /dev/null <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF
```

**For CRI-O:**

```bash
sudo tee /etc/crictl/crictl.yaml > /dev/null <<EOF
runtime-endpoint: unix:///var/run/crio/crio.sock
image-endpoint: unix:///var/run/crio/crio.sock
timeout: 10
EOF
```

### Using Runtime Endpoint Flag

Instead of configuration file, you can specify the runtime endpoint directly:

```bash
# Using containerd (Docker Desktop on macOS)
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version

# Using containerd (Linux)
crictl --runtime-endpoint unix:///run/containerd/containerd.sock version

# Set as environment variable (macOS/Docker Desktop)
export CONTAINER_RUNTIME_ENDPOINT=unix:///var/run/containerd/containerd.sock
crictl version

# Set as environment variable (Linux)
export CONTAINER_RUNTIME_ENDPOINT=unix:///run/containerd/containerd.sock
crictl version
```

### Find Your Container Runtime Socket

```bash
# List all potential runtime sockets
ls -la /var/run/containerd/*.sock 2>/dev/null
ls -la /run/containerd/*.sock 2>/dev/null
ls -la /var/run/crio/*.sock 2>/dev/null

# For Docker Desktop on macOS
ls -la /var/run/containerd/containerd.sock

# Test connectivity
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version
```

### Verify Configuration

```bash
# Check runtime version
crictl version

# Get runtime info
crictl info

### Expected Output:
# {
#   "status": {
#     "conditions": [
#       {
#         "type": "RuntimeReady",
#         "status": true,
#         "message": ""
#       }
#     ]
#   }
# }
```

### Alternative: Using crictl with Minikube

If you're using OrbStack or another runtime without direct CRI access, you can use Minikube:

```bash
# Start Minikube with containerd
minikube start --container-runtime=containerd

# Get the socket path
minikube ssh "ls -la /run/containerd/containerd.sock"

# Configure crictl to use Minikube
cat > ~/.config/crictl/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF

# SSH into Minikube and use crictl
minikube ssh

# Now inside Minikube VM:
crictl version
crictl images
crictl ps
```

### Alternative: Using crictl with kind

```bash
# Create a kind cluster
kind create cluster --name crictl-demo

# Get the container ID of the kind control plane
KIND_CONTAINER=$(docker ps --filter "name=crictl-demo-control-plane" -q)

# Execute crictl commands in the kind container
docker exec $KIND_CONTAINER crictl version
docker exec $KIND_CONTAINER crictl images
docker exec $KIND_CONTAINER crictl ps -a
```

---

## 05. Working with Container Images

### List Images

```bash
# List all images
crictl images

# List images with detailed output
crictl images -v

# List specific image
crictl images nginx

# List images in JSON format
crictl images -o json
```

### Pull Images

```bash
# Pull an image
crictl pull nginx:latest

# Pull with specific registry
crictl pull docker.io/library/alpine:latest

# Pull from private registry (requires authentication)
crictl pull myregistry.com/myimage:v1.0
```

### Inspect Images

```bash
# Get detailed image information
crictl inspecti nginx:latest

# Get image in JSON format
crictl inspecti --output json nginx:latest | jq .

# Check image size and layers
crictl inspecti nginx:latest | grep -E 'size|layer'
```

### Remove Images

```bash
# Remove image by name
crictl rmi nginx:latest

# Remove image by ID
crictl rmi a1b2c3d4e5f6

# Remove all unused images
crictl rmi --prune

# Force remove image
crictl rmi -f nginx:latest
```

---

## 06. Container Operations

### List Containers

```bash
# List all running containers
crictl ps

# List all containers (including stopped)
crictl ps -a

# List containers with detailed information
crictl ps -v

# Filter containers by state
crictl ps --state running
crictl ps --state exited

# Filter by name
crictl ps --name nginx

# Filter by pod
crictl ps --pod mypod
```

### Create and Run Containers

First, we need to create a pod sandbox, then create containers within it:

**Step 1: Create Pod Configuration**

```bash
# Create pod config file
cat > pod-config.json <<EOF
{
    "metadata": {
        "name": "debug-pod",
        "namespace": "default",
        "uid": "debug-pod-uid"
    },
    "log_directory": "/tmp",
    "linux": {}
}
EOF
```

**Step 2: Create Container Configuration**

```bash
# Create container config file
cat > container-config.json <<EOF
{
    "metadata": {
        "name": "debug-container"
    },
    "image": {
        "image": "nginx:latest"
    },
    "command": [
        "nginx",
        "-g",
        "daemon off;"
    ],
    "log_path": "debug-container.log",
    "linux": {}
}
EOF
```

**Step 3: Create Pod and Container**

```bash
# Create the pod sandbox
POD_ID=$(crictl runp pod-config.json)
echo "Pod ID: $POD_ID"

# Create the container
CONTAINER_ID=$(crictl create $POD_ID container-config.json pod-config.json)
echo "Container ID: $CONTAINER_ID"

# Start the container
crictl start $CONTAINER_ID

# Verify the container is running
crictl ps
```

### Stop and Remove Containers

```bash
# Stop a container
crictl stop $CONTAINER_ID

# Stop with timeout
crictl stop --timeout 30 $CONTAINER_ID

# Remove a container
crictl rm $CONTAINER_ID

# Force remove a running container
crictl rm -f $CONTAINER_ID

# Remove all stopped containers
crictl rm $(crictl ps -a -q --state exited)
```

---

## 07. Pod Operations

### List Pods

```bash
# List all pods
crictl pods

# List pods with details
crictl pods -v

# List pods in specific namespace
crictl pods --namespace default

# Filter by pod state
crictl pods --state ready
crictl pods --state notready

# Get pod in JSON format
crictl pods -o json
```

### Inspect Pods

```bash
# Inspect specific pod
crictl inspectp $POD_ID

# Get pod details in JSON
crictl inspectp --output json $POD_ID | jq .

# Check pod metadata
crictl inspectp $POD_ID | grep -A 10 metadata
```

### Pod Lifecycle Management

```bash
# Create pod from config
crictl runp pod-config.json

# Stop a pod (stops all containers in the pod)
crictl stopp $POD_ID

# Remove a pod
crictl rmp $POD_ID

# Force remove a pod
crictl rmp -f $POD_ID

# Remove all stopped pods
crictl rmp $(crictl pods -q --state notready)
```

---

## 08. Debugging Containers

### Execute Commands in Containers

```bash
# Execute command in running container
crictl exec -it $CONTAINER_ID /bin/sh

# Execute specific command
crictl exec $CONTAINER_ID ls -la /etc

# Execute with environment variables
crictl exec -e ENV_VAR=value $CONTAINER_ID env

# Execute as specific user
crictl exec -u 1000 $CONTAINER_ID whoami
```

### Interactive Debugging Session

```bash
# Start interactive shell
crictl exec -it $CONTAINER_ID /bin/bash

# Once inside, you can:
# - Check running processes
ps aux

# - Check network configuration
ip addr
netstat -tulpn

# - Check file system
df -h
ls -la /

# - Check environment variables
env

# - Install debugging tools (if writable)
apt-get update && apt-get install -y procps net-tools
```

### Container Stats and Resources

```bash
# Get container stats (CPU, Memory, etc.)
crictl stats

# Get stats for specific container
crictl stats $CONTAINER_ID

# Continuous monitoring
watch -n 2 crictl stats

# Get stats in JSON format
crictl stats -o json
```

---

## 09. Inspecting Container Resources

### Inspect Container Details

```bash
# Full container inspection
crictl inspect $CONTAINER_ID

# Get specific fields using JSON query
crictl inspect $CONTAINER_ID | jq '.info.config'

# Check container mounts
crictl inspect $CONTAINER_ID | jq '.info.mounts'

# Check container environment
crictl inspect $CONTAINER_ID | jq '.info.config.envs'

# Check container labels
crictl inspect $CONTAINER_ID | jq '.info.config.labels'
```

### Check Container State

```bash
# Get container state
crictl inspect $CONTAINER_ID | jq '.status.state'

# Check exit code
crictl inspect $CONTAINER_ID | jq '.status.exitCode'

# Check started and finished times
crictl inspect $CONTAINER_ID | jq '.status | {started: .startedAt, finished: .finishedAt}'

# Check container PID
crictl inspect $CONTAINER_ID | jq '.info.pid'
```

### Inspect Container Networking

```bash
# Get container IP address
crictl inspect $CONTAINER_ID | jq '.status.network.ip'

# Check network namespace
crictl inspect $CONTAINER_ID | jq '.info.runtimeSpec.linux.namespaces[] | select(.type == "network")'

# List network interfaces
crictl exec $CONTAINER_ID ip link show

# Check DNS configuration
crictl exec $CONTAINER_ID cat /etc/resolv.conf
```

---

## 10. Logs and Troubleshooting

### View Container Logs

```bash
# View container logs
crictl logs $CONTAINER_ID

# Follow logs in real-time
crictl logs -f $CONTAINER_ID

# Get last N lines
crictl logs --tail 50 $CONTAINER_ID

# Show timestamps
crictl logs --timestamps $CONTAINER_ID

# Logs since specific time
crictl logs --since 1h $CONTAINER_ID
```

### Common Debugging Scenarios

**Scenario 1: Container Keeps Restarting**

```bash
# Check container status
crictl ps -a | grep mycontainer

# Get container ID
CONTAINER_ID=$(crictl ps -a --name mycontainer -q | head -1)

# Check logs for errors
crictl logs $CONTAINER_ID

# Inspect exit code
crictl inspect $CONTAINER_ID | jq '.status.exitCode'

# Check restart count (from pod perspective)
crictl inspectp $(crictl inspect $CONTAINER_ID | jq -r '.info.sandboxID')
```

**Scenario 2: Container Network Issues**

```bash
# Check container IP
crictl exec $CONTAINER_ID ip addr

# Test connectivity from container
crictl exec $CONTAINER_ID ping -c 3 8.8.8.8

# Check DNS resolution
crictl exec $CONTAINER_ID nslookup google.com

# Check listening ports
crictl exec $CONTAINER_ID netstat -tuln

# Inspect network configuration
crictl inspect $CONTAINER_ID | jq '.info.runtimeSpec.linux.namespaces'
```

**Scenario 3: Container Storage Issues**

```bash
# Check disk usage in container
crictl exec $CONTAINER_ID df -h

# List mounts
crictl inspect $CONTAINER_ID | jq '.info.mounts'

# Check for read-only file systems
crictl exec $CONTAINER_ID mount | grep ro

# Inspect volume mounts
crictl exec $CONTAINER_ID ls -la /var/lib/
```

**Scenario 4: High Resource Usage**

```bash
# Check container resource usage
crictl stats $CONTAINER_ID

# Check processes inside container
crictl exec $CONTAINER_ID ps aux

# Check memory usage
crictl exec $CONTAINER_ID free -h

# Check for memory leaks
crictl exec $CONTAINER_ID top -b -n 1
```

---

## 11. Advanced Debugging Techniques

### Attach to Running Container

```bash
# Attach to container's main process
crictl attach $CONTAINER_ID

# Note: This attaches to the main process (PID 1)
# Use Ctrl+P, Ctrl+Q to detach without stopping
```

### Port Forwarding for Debugging

```bash
# Get container IP
CONTAINER_IP=$(crictl inspect $CONTAINER_ID | jq -r '.status.network.ip')

# Access service from host
curl http://$CONTAINER_IP:80

# Check open ports
crictl exec $CONTAINER_ID netstat -tuln
```

### Debugging with nsenter

Access container namespaces directly from the host:

```bash
# Get container PID
PID=$(crictl inspect $CONTAINER_ID | jq -r '.info.pid')

# Enter network namespace
sudo nsenter -t $PID -n ip addr

# Enter mount namespace
sudo nsenter -t $PID -m ls /

# Enter all namespaces
sudo nsenter -t $PID -a /bin/bash
```

### Copy Files To/From Containers

While crictl doesn't have a built-in cp command, you can use alternative methods:

```bash
# Copy file from host to container
crictl exec $CONTAINER_ID sh -c 'cat > /tmp/file.txt' < local-file.txt

# Copy file from container to host
crictl exec $CONTAINER_ID cat /etc/config.yaml > local-config.yaml

# Using tar for directories
tar -cf - /local/dir | crictl exec -i $CONTAINER_ID tar -xf - -C /container/path
```

### Performance Profiling

```bash
# CPU profile
crictl exec $CONTAINER_ID top -b -n 1

# Memory profile
crictl exec $CONTAINER_ID cat /proc/meminfo

# I/O stats
crictl exec $CONTAINER_ID iostat -x 1 5

# Network stats
crictl exec $CONTAINER_ID cat /proc/net/dev
```

### Debugging Container Images

```bash
# Create a debug container with custom entrypoint
cat > debug-container.json <<EOF
{
    "metadata": {
        "name": "debug-container"
    },
    "image": {
        "image": "nginx:latest"
    },
    "command": [
        "/bin/sh",
        "-c",
        "sleep 3600"
    ],
    "log_path": "debug.log",
    "linux": {}
}
EOF

# Create and start debug container
DEBUG_CONTAINER=$(crictl create $POD_ID debug-container.json pod-config.json)
crictl start $DEBUG_CONTAINER

# Now you can exec into it
crictl exec -it $DEBUG_CONTAINER /bin/sh
```

---

## 12. Clean up

### Remove Test Resources

```bash
# Stop and remove containers
for container in $(crictl ps -q); do
    crictl stop $container
    crictl rm $container
done

# Remove all stopped containers
crictl rm $(crictl ps -a -q --state exited)

# Stop and remove pods
for pod in $(crictl pods -q); do
    crictl stopp $pod
    crictl rmp $pod
done

# Remove unused images
crictl rmi --prune

# Clean up test files
rm -f pod-config.json container-config.json debug-container.json
```

### Complete Cleanup

```bash
# Remove ALL containers (use with caution)
crictl rm -a -f

# Remove ALL pods (use with caution)
crictl rmp -a -f

# Remove ALL images (use with caution)
crictl rmi -a

# Remove crictl config
sudo rm -f /etc/crictl/crictl.yaml
```

---

## Additional Resources

### Quick Reference Commands

```bash
# Images
crictl images                  # List images
crictl pull <image>           # Pull image
crictl rmi <image>            # Remove image
crictl inspecti <image>       # Inspect image

# Containers
crictl ps                     # List running containers
crictl ps -a                  # List all containers
crictl inspect <container>    # Inspect container
crictl logs <container>       # View logs
crictl exec -it <container>   # Execute command
crictl stats                  # Container stats

# Pods
crictl pods                   # List pods
crictl runp <config>          # Create pod
crictl stopp <pod>            # Stop pod
crictl rmp <pod>              # Remove pod
crictl inspectp <pod>         # Inspect pod

# System
crictl version                # Version info
crictl info                   # Runtime info
```

### Useful Debugging Tips

1. **Always check logs first**: `crictl logs <container-id>`
2. **Use `-v` flag for verbose output**: Provides more details
3. **Combine with jq for JSON parsing**: `crictl inspect <id> | jq .`
4. **Use --state flag to filter**: Quickly find stopped containers
5. **Export CONTAINER_RUNTIME_ENDPOINT**: Save typing for repeated commands
6. **Use watch for monitoring**: `watch -n 2 crictl stats`

### Common Issues and Solutions

**Issue: "error reading server preface: http2: frame too large" or "CRI v1 image API" error**

```bash
# Problem: Trying to connect to Docker socket instead of containerd
# Docker doesn't support CRI protocol directly

# Solution 1: Use containerd socket (macOS/Docker Desktop)
mkdir -p ~/.config/crictl
cat > ~/.config/crictl/crictl.yaml <<EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
EOF

# Solution 2: Find correct socket location
ls -la /var/run/containerd/containerd.sock
ls -la /run/containerd/containerd.sock

# Solution 3: Test with explicit endpoint
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version
```

**Issue: "connection refused" error**

```bash
# Solution: Check runtime socket exists and crictl config
ls -la /var/run/containerd/containerd.sock
cat ~/.config/crictl/crictl.yaml
cat /etc/crictl/crictl.yaml

# Verify containerd is running (macOS/Docker Desktop)
ps aux | grep containerd

# Check Docker Desktop is running
docker version
```

**Issue: Permission denied**

```bash
# Solution: Run with sudo or add user to docker/containerd group
sudo crictl ps

# Or add user to docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker

# On macOS with Docker Desktop, usually no sudo needed
# Just ensure Docker Desktop is running
```

**Issue: Container not starting**

```bash
# Solution: Check logs and inspect container
crictl logs <container-id>
crictl inspect <container-id> | jq '.status'

# Check if container exists
crictl ps -a | grep <container-name>

# Check pod status
crictl pods
```

**Issue: "namespace not found" on macOS**

```bash
# crictl shows containers from containerd namespace, not Docker namespace
# To see Docker containers, you need to use Docker CLI

# List containerd namespaces
sudo ctr --address /var/run/containerd/containerd.sock namespaces list

# List containers in specific namespace
sudo ctr --address /var/run/containerd/containerd.sock --namespace k8s.io containers list

# Note: Docker containers run in 'moby' namespace usually
sudo ctr --address /var/run/containerd/containerd.sock --namespace moby containers list
```

### Documentation Links

- **Official Documentation**: https://github.com/kubernetes-sigs/cri-tools
- **CRI Specification**: https://github.com/kubernetes/cri-api
- **Containerd**: https://containerd.io/
- **Kubernetes Debugging**: https://kubernetes.io/docs/tasks/debug/

---

![Well Done](../assets/images/well-done.png)
