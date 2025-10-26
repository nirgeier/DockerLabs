![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 015 - Docker Networking

- This lab covers Docker networking fundamentals, including network drivers, custom networks, and advanced networking features.
- You'll learn how to create and manage container networks, configure network connectivity, and implement service discovery.
- Topics include bridge networks, overlay networks, host networking, and network troubleshooting.
- By the end of this lab, you'll understand how to design and manage container networking for various deployment scenarios.

---

<!-- omit in toc -->
## Table of Contents

- [🌐 Understanding Docker Networking](#-understanding-docker-networking)
- [🔗 Network Drivers](#-network-drivers)
  - [Bridge Network](#bridge-network)
  - [Host Network](#host-network)
  - [None Network](#none-network)
  - [Overlay Network](#overlay-network)
  - [Macvlan Network](#macvlan-network)
- [⚙️ Custom Networks](#️-custom-networks)
  - [Creating Custom Networks](#creating-custom-networks)
  - [Network Configuration](#network-configuration)
- [🔌 Container Networking](#-container-networking)
  - [Connecting Containers](#connecting-containers)
  - [Port Mapping](#port-mapping)
  - [Service Discovery](#service-discovery)
- [🚀 Advanced Networking](#-advanced-networking)
  - [Network Plugins](#network-plugins)
  - [DNS Configuration](#dns-configuration)
  - [Network Security](#network-security)
- [🔧 Networking Commands](#-networking-commands)
- [📊 Monitoring and Troubleshooting](#-monitoring-and-troubleshooting)
- [🔒 Networking Best Practices](#-networking-best-practices)

---

## 🌐 Understanding Docker Networking

Docker networking enables containers to communicate with each other and external networks. Docker provides several network drivers to suit different use cases.

### Key Concepts

- **Network Drivers**: Define how containers connect to networks
- **Bridge Networks**: Default network for single-host communication
- **Overlay Networks**: Multi-host networking for Swarm clusters
- **Host Networks**: Direct access to host network stack
- **None Networks**: Isolated containers with no networking

### Default Networks

Docker creates three default networks:

```bash
# List all networks
docker network ls

# Inspect default bridge network
docker network inspect bridge
```

---

## 🔗 Network Drivers

### Bridge Network

The default network driver for containers. Creates an internal network on the host.

**Characteristics:**

- Containers can communicate with each other
- Containers get IP addresses from Docker's subnet
- Port mapping required for external access

**Example:**

```bash
# Run container on bridge network
docker run -d --name web nginx

# Inspect container network
docker inspect web | grep -A 10 NetworkSettings
```

### Host Network

Containers share the host's network stack directly.

**Characteristics:**

- No network isolation
- Best performance
- No port conflicts
- Limited to single host

**Example:**

```bash
# Run container with host networking
docker run -d --network host --name web nginx
```

### None Network

Completely isolated containers with no network access.

**Characteristics:**

- No network interfaces
- Maximum isolation
- Manual network setup required

**Example:**

```bash
# Run container with no networking
docker run -d --network none --name isolated alpine sleep 3600
```

### Overlay Network

Multi-host networking for Docker Swarm clusters.

**Characteristics:**

- Spans multiple hosts
- Built-in service discovery
- Load balancing
- Requires Swarm mode

**Example:**

```bash
# Create overlay network (in Swarm)
docker network create -d overlay my-overlay

# Run service on overlay network
docker service create --network my-overlay --name web nginx
```

### Macvlan Network

Assigns MAC addresses to containers, making them appear as physical devices.

**Characteristics:**

- Layer 2 networking
- Direct layer 2 access
- No port mapping needed
- Requires promiscuous mode on host interface

**Example:**

```bash
# Create macvlan network
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=192.168.1.1 \
  -o parent=eth0 \
  my-macvlan

# Run container on macvlan
docker run -d --network my-macvlan --name web nginx
```

---

## ⚙️ Custom Networks

### Creating Custom Networks

Create user-defined networks for better control.

```bash
# Create bridge network
docker network create my-bridge

# Create network with custom subnet
docker network create --subnet 172.20.0.0/16 my-custom-net

# Create network with options
docker network create \
  --driver bridge \
  --subnet 172.25.0.0/16 \
  --gateway 172.25.0.1 \
  --opt "com.docker.network.bridge.name"="my-bridge" \
  my-network
```

### Network Configuration

Configure network settings for containers.

```bash
# Connect container to network
docker network connect my-network web

# Disconnect from network
docker network disconnect bridge web

# Run container with specific IP
docker run -d --network my-network --ip 172.20.0.10 --name web nginx

# Inspect network
docker network inspect my-network
```

---

## 🔌 Container Networking

### Connecting Containers

Enable communication between containers.

```bash
# Create network
docker network create app-network

# Run database
docker run -d --network app-network --name db postgres

# Run app connected to same network
docker run -d --network app-network --name app myapp

# Containers can communicate by name
docker exec app ping db
```

### Port Mapping

Expose container ports to host.

```bash
# Map single port
docker run -d -p 8080:80 --name web nginx

# Map multiple ports
docker run -d -p 8080:80 -p 8443:443 --name web nginx

# Map to specific host interface
docker run -d -p 192.168.1.100:8080:80 --name web nginx

# Dynamic port mapping
docker run -d -P --name web nginx
```

### Service Discovery

Automatic service discovery in user-defined networks.

```bash
# Create network
docker network create --driver bridge app-net

# Run services
docker run -d --network app-net --name redis redis
docker run -d --network app-net --name web -e REDIS_HOST=redis myapp

# Services resolve by container name
docker exec web nslookup redis
```

---

## 🚀 Advanced Networking

### Network Plugins

Extend Docker networking with plugins.

```bash
# Install network plugin (example: weave)
docker plugin install weaveworks/net-plugin:latest_release

# Create network with plugin
docker network create -d weave my-weave-net
```

### DNS Configuration

Configure DNS for containers.

```bash
# Use custom DNS
docker run -d --dns 8.8.8.8 --name web nginx

# Use custom DNS search domains
docker run -d --dns-search example.com --name web nginx

# Inspect DNS configuration
docker exec web cat /etc/resolv.conf
```

### Network Security

Secure container communications.

```bash
# Create encrypted overlay network
docker network create -d overlay \
  --opt encrypted \
  my-secure-net

# Use network with iptables rules
docker network create --driver bridge \
  --opt "com.docker.network.bridge.enable_icc"="false" \
  isolated-net
```

---

## 🔧 Networking Commands

### Network Management

```bash
# List networks
docker network ls

# Create network
docker network create my-network

# Remove network
docker network rm my-network

# Prune unused networks
docker network prune
```

### Container Network Commands

```bash
# Connect container to network
docker network connect my-network container_name

# Disconnect container from network
docker network disconnect bridge container_name

# Inspect container networks
docker inspect container_name | jq .NetworkSettings.Networks
```

### Troubleshooting Commands

```bash
# Check network connectivity
docker exec web ping google.com

# View network interfaces
docker exec web ip addr

# Check routing table
docker exec web ip route

# View iptables rules
sudo iptables -L -n
```

---

## 📊 Monitoring and Troubleshooting

### Network Monitoring

```bash
# View network usage
docker network ls -q | xargs docker network inspect | jq '.[].Containers | length'

# Monitor network traffic (requires tools)
docker run -d --net container:web nicolaka/netshoot tcpdump -i eth0

# Check container connectivity
docker exec web curl -I http://other-container
```

### Common Issues

- **Container can't reach internet**: Check DNS and gateway configuration
- **Containers can't communicate**: Verify network connectivity and firewall rules
- **Port conflicts**: Check host port usage
- **Network isolation**: Ensure containers are on the same network

### Debugging Steps

```bash
# 1. Check container network settings
docker inspect container_name | jq .NetworkSettings

# 2. Verify network connectivity
docker exec container_name ping 8.8.8.8

# 3. Check DNS resolution
docker exec container_name nslookup google.com

# 4. Inspect network details
docker network inspect network_name

# 5. View Docker daemon logs
sudo journalctl -u docker -f
```

---

## 🔒 Networking Best Practices

- ### 🌉 Use User-Defined Networks

  Prefer user-defined networks over default bridge for better isolation and service discovery.

  ```bash
  docker network create app-network
  docker run -d --network app-network --name app myapp
  ```

- ### 🔒 Implement Network Segmentation

  Separate applications into different networks for security.

  ```bash
  docker network create frontend
  docker network create backend
  docker network create database
  ```

- ### 🚪 Minimize Port Exposure

  Only expose necessary ports and use specific IP bindings.

  ```bash
  docker run -d -p 127.0.0.1:8080:80 --name web nginx
  ```

- ### 🔐 Use Encrypted Networks

  Enable encryption for sensitive communications.

  ```bash
  docker network create -d overlay --opt encrypted secure-net
  ```

- ### 📊 Monitor Network Traffic

  Regularly monitor and audit network communications.

  ```bash
  docker network ls
  docker network inspect <network> | jq .Containers
  ```

- ### 🧹 Clean Up Unused Networks

  Remove unused networks to prevent clutter.

  ```bash
  docker network prune
  ```

---

## 📋 Lab Exercises

1. **Explore Default Networks**
      - List all Docker networks
      - Inspect the bridge network configuration
      - Run containers on default networks

2. **Create Custom Networks**
      - Create a user-defined bridge network
      - Run containers on the custom network
      - Test service discovery between containers

3. **Port Mapping and Exposure**
      - Run a web server with port mapping
      - Access the application from host
      - Test different port mapping options

4. **Network Isolation**
      - Create multiple networks
      - Connect containers to specific networks
      - Verify isolation between networks

5. **Advanced Networking**
      - Set up overlay networking (if Swarm available)
      - Configure DNS settings
      - Implement network security measures

---

## 🔗 Additional Resources

- [Docker Networking Overview](https://docs.docker.com/network/)
- [Network Drivers](https://docs.docker.com/network/drivers/)
- [Docker Swarm Networking](https://docs.docker.com/network/overlay/)
- [Network Security](https://docs.docker.com/network/security/)
- [Networking Best Practices](https://docs.docker.com/develop/dev-best-practices/networking/)
