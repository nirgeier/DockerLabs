![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 014 - Docker Daemon

- This lab covers the Docker daemon (dockerd), its configuration, and advanced features.
- You'll learn how to customize the Docker daemon behavior, configure private registries, enable rootless mode, and implement various security and performance optimizations.
- Topics include daemon configuration file, logging options, storage drivers, network settings, and experimental features.
- By the end of this lab, you'll understand how to configure and manage the Docker daemon for production environments.

---

<!-- omit in toc -->
## Table of Contents

- [🐳 Understanding the Docker Daemon](#-understanding-the-docker-daemon)
- [⚙️ Docker Daemon Configuration](#️-docker-daemon-configuration)
  - [Configuration File Location](#configuration-file-location)
  - [Basic Configuration Structure](#basic-configuration-structure)
- [🔧 Common Daemon Configurations](#-common-daemon-configurations)
  - [Logging Configuration](#logging-configuration)
  - [Storage Configuration](#storage-configuration)
  - [Network Configuration](#network-configuration)
  - [Security Configuration](#security-configuration)
- [🏢 Private Registry Configuration](#-private-registry-configuration)
- [👤 Rootless Docker](#-rootless-docker)
- [🚀 Experimental Features](#-experimental-features)
- [📊 Monitoring and Debugging](#-monitoring-and-debugging)
- [🔒 Security Best Practices](#-security-best-practices)

---

## 🐳 Understanding the Docker Daemon

The Docker daemon (`dockerd`) is the persistent process that manages Docker containers, images, networks, and volumes. It listens for Docker API requests and manages Docker objects.

### Key Responsibilities

- **Container Management**: Creating, starting, stopping, and monitoring containers
- **Image Management**: Pulling, pushing, and building images
- **Network Management**: Creating and managing container networks
- **Volume Management**: Handling persistent data storage
- **API Server**: Providing REST API for Docker client communication

### Daemon Lifecycle

```bash
# Check if daemon is running
docker version

# View daemon info
docker info

# Restart daemon (Linux)
sudo systemctl restart docker

# View daemon logs (Linux)
sudo journalctl -u docker -f
```

---

## ⚙️ Docker Daemon Configuration

### Configuration File Location

The Docker daemon can be configured using a JSON configuration file:

**Linux/macOS**: `/etc/docker/daemon.json`
**Windows**: `C:\ProgramData\docker\config\daemon.json`

### Basic Configuration Structure

```json
{
  "debug": false,
  "tls": true,
  "tlscert": "/var/docker/server.pem",
  "tlskey": "/var/docker/serverkey.pem",
  "hosts": ["tcp://0.0.0.0:2376"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "insecure-registries": ["myregistry.com:5000"],
  "registry-mirrors": ["https://mirror.gcr.io"]
}
```

---

## 🔧 Common Daemon Configurations

### Logging Configuration

Configure how Docker logs container output and daemon events:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "labels": "production_status",
    "env": "os,customer"
  }
}
```

**Available log drivers:**

- `json-file` (default): JSON formatted logs
- `syslog`: System logging
- `journald`: systemd journal
- `fluentd`: Fluentd logging
- `awslogs`: Amazon CloudWatch
- `splunk`: Splunk logging

### Storage Configuration

Configure storage driver and options:

```json
{
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "data-root": "/var/lib/docker"
}
```

**Common storage drivers:**

- `overlay2` (recommended for modern Linux)
- `btrfs` (for Btrfs filesystems)
- `zfs` (for ZFS filesystems)
- `devicemapper` (legacy, device mapper)

### Network Configuration

Configure networking options:

```json
{
  "bridge": "docker0",
  "fixed-cidr": "192.168.65.0/24",
  "default-gateway": "192.168.65.1",
  "dns": ["8.8.8.8", "8.8.4.4"],
  "dns-opts": ["timeout:2"],
  "dns-search": ["example.com"],
  "iptables": true,
  "ip-forward": true
}
```

### Security Configuration

```json
{
  "userns-remap": "default",
  "no-new-privileges": true,
  "seccomp-profile": "/etc/docker/seccomp.json",
  "selinux-enabled": true,
  "live-restore": true,
  "icc": false,
  "userland-proxy": false
}
```

---

## 🏢 Private Registry Configuration

### Adding Insecure Registries

For registries without TLS certificates:

```json
{
  "insecure-registries": [
    "myregistry.com:5000",
    "registry.internal.company.com"
  ]
}
```

### Registry Mirrors

Use registry mirrors to cache images:

```json
{
  "registry-mirrors": [
    "https://mirror.gcr.io",
    "https://dockerhub.mirror.com"
  ]
}
```

### Authentication

Configure authentication for private registries:

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "dXNlcjpwYXNzd29yZA=="
    },
    "myregistry.com:5000": {
      "auth": "dXNlcjpwYXNzd29yZA=="
    }
  }
}
```

### Example: Working with Private Registry

```bash
# Tag image for private registry
docker tag myapp:latest myregistry.com:5000/myapp:v1.0

# Push to private registry
docker push myregistry.com:5000/myapp:v1.0

# Pull from private registry
docker pull myregistry.com:5000/myapp:v1.0

# Login to registry (if required)
docker login myregistry.com:5000
```

---

## 👤 Rootless Docker

Rootless Docker allows running the Docker daemon without root privileges, improving security by reducing the attack surface.

### Installation

```bash
# Install rootless Docker
curl -fsSL https://get.docker.com/rootless | sh

# Start rootless Docker
systemctl --user start docker

# Enable on boot
systemctl --user enable docker

# Add to PATH
export PATH=/home/$USER/bin:$PATH
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
```

### Configuration

Rootless Docker uses different paths and configurations:

```bash
# Rootless Docker socket
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

# Rootless Docker data directory
export XDG_DATA_HOME=/home/$USER/.local/share

# Rootless Docker config
export DOCKER_CONFIG=/home/$USER/.config/docker
```

### Limitations

- Some features may not work (e.g., AppArmor, checkpoint/restore)
- Port binding below 1024 requires additional setup
- Some storage drivers may have limitations
- Network features may be restricted

### Benefits

- **Security**: No root access required
- **Isolation**: User-specific Docker environment
- **Compliance**: Meets security requirements for multi-tenant environments

---

## 🚀 Experimental Features

Enable experimental features for cutting-edge functionality:

```json
{
  "experimental": true
}
```

**Available experimental features:**

- **BuildKit**: Advanced build engine with improved performance
- **Squash**: Squash layers to reduce image size
- **Checkpoint/Restore**: Save and restore container state
- **Rootless mode**: Run daemon without root (now stable)

### BuildKit Configuration

```json
{
  "experimental": true,
  "features": {
    "buildkit": true
  }
}
```

**Using BuildKit:**

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with BuildKit
docker build -t myapp .

# Use advanced BuildKit features
docker build --target production -t myapp .
```

---

## 📊 Monitoring and Debugging

### Daemon Monitoring

```bash
# View daemon info
docker info

# System-wide information
docker system info

# Disk usage
docker system df

# Events stream
docker events

# Daemon logs
sudo journalctl -u docker -f
```

### Debugging Configuration

```json
{
  "debug": true,
  "log-level": "debug",
  "metrics-addr": "127.0.0.1:9323"
}
```

### Health Checks

Monitor daemon health:

```bash
# Check daemon responsiveness
docker version

# System events
docker system events --since 1h

# Container events
docker events --filter type=container
```

---

## 🔒 Security Best Practices

- ### 🔐 TLS Configuration

  Always use TLS for daemon communication:

  ```json
  {
    "tls": true,
    "tlscert": "/etc/docker/server.pem",
    "tlskey": "/etc/docker/serverkey.pem",
    "tlsverify": true
  }
  ```

- ### 👥 User Namespace

  Enable user namespace remapping:

  ```json
  {
    "userns-remap": "default"
  }
  ```

- ### 🛡️ Seccomp Profiles

  Use custom seccomp profiles:

  ```json
  {
    "seccomp-profile": "/etc/docker/seccomp.json"
  }
  ```

- ### 🔒 SELinux/AppArmor

  Enable mandatory access control:

  ```json
  {
    "selinux-enabled": true
  }
  ```

- ### 📊 Audit Logging

  Enable detailed audit logging:

  ```json
  {
    "log-driver": "syslog",
    "log-opts": {
      "syslog-facility": "daemon"
    }
  }
  ```

- ### 🚫 Disable Insecure Features

  Avoid insecure configurations:

  ```json
  {
    "icc": false,
    "no-new-privileges": true,
    "userland-proxy": false
  }
  ```

---

## 📋 Lab Exercises

1. **Configure Basic Daemon Settings**
      - Create `/etc/docker/daemon.json` with basic configuration
      - Restart Docker daemon and verify settings

2. **Set Up Private Registry**
      - Configure insecure registry in daemon.json
      - Push and pull images from private registry

3. **Enable Rootless Docker**
      - Install and configure rootless Docker
      - Test container operations without root

4. **Configure Logging**
      - Set up JSON logging with rotation
      - View and analyze container logs

5. **Security Hardening**
      - Enable user namespaces
      - Configure seccomp profiles
      - Set up TLS authentication

---

## 🔗 Additional Resources

- [Docker Daemon Configuration](https://docs.docker.com/config/daemon/)
- [Private Registry Setup](https://docs.docker.com/registry/)
- [Rootless Docker](https://docs.docker.com/engine/security/rootless/)
- [Docker Security Best Practices](https://docs.docker.com/develop/dev-best-practices/security/)
- [BuildKit Documentation](https://docs.docker.com/develop/dev-best-practices/)
