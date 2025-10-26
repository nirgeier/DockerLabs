# Task: Creating and Testing Docker Networks

![DockerLabs Banner](../../assets/images/docker-logos.png)

---

This task provides a detailed guide to creating and testing Docker networks. Docker networks enable containers to communicate with each other securely and efficiently.

## Prerequisites

- Docker installed and running
- Basic understanding of Docker containers
- Terminal access

## Task Overview

In this task, you will:

- List existing Docker networks
- Create custom networks with different configurations
- Run containers connected to networks
- Test connectivity between containers
- Manage network connections
- Clean up resources

<details markdown="1">
<summary>Solution</summary>

## Step-by-Step Solution

### 01: List Existing Networks

First, let's see what networks are already available on your Docker host.

```bash
docker network ls
```

This command will show the default networks:

- `bridge`: Default network for containers
- `host`: Uses the host's network stack
- `none`: No networking

### 02: Create a Custom Network

Create a custom bridge network for better isolation and control.

```bash
docker network create --driver bridge my-custom-network
```

- `--driver bridge`: Specifies the bridge driver (default)
- `my-custom-network`: Name of the network

Verify the network was created:

```bash
docker network ls
```

You should see `my-custom-network` in the list.

### 03: Inspect the Network

Get detailed information about the network.

```bash
docker network inspect my-custom-network
```

This will show:

- Network ID
- Driver
- Subnet and gateway
- Connected containers (initially empty)

### 04: Run Containers on the Network

Launch two containers connected to the custom network.

```bash
# Run a web server container
docker run -d --name web-server --network my-custom-network -p 8080:80 nginx

# Run a client container for testing
docker run -d --name test-client --network my-custom-network alpine sleep 3600
```

- `-d`: Run in detached mode
- `--name`: Assign container names
- `--network`: Connect to the custom network
- `-p 8080:80`: Port mapping for the web server

### 05: Verify Container Connectivity

Check that containers are connected to the network.

```bash
docker network inspect my-custom-network
```

You should now see the two containers listed under "Containers".

### 06: Test Network Communication

Test communication between containers on the same network.

```bash
# Get the IP address of the web server
docker inspect web-server | grep -A 10 "Networks"

# Or use container names for DNS resolution
docker exec test-client ping -c 4 web-server
```

Since containers on the same network can resolve each other by name, you can ping using the container name.

### 07: Test External Access

Test access to the web server from the host.

```bash
curl http://localhost:8080
```

You should see the default Nginx welcome page.

### 08: Connect Existing Container to Network

Demonstrate connecting a running container to the network.

```bash
# Run another container without specifying network
docker run -d --name standalone-container alpine sleep 3600

# Connect it to the custom network
docker network connect my-custom-network standalone-container

# Verify connection
docker network inspect my-custom-network
```

### 09: Disconnect Container from Network

Remove a container from the network.

```bash
docker network disconnect my-custom-network standalone-container
```

Verify the container is no longer connected.

### 10: Create Network with Custom Subnet

Create a network with a specific subnet.

```bash
docker network create --driver bridge --subnet 192.168.10.0/24 --gateway 192.168.10.1 custom-subnet-network
```

Inspect to verify the custom configuration.

### 11: Clean Up

Remove containers and networks.

```bash
# Stop and remove containers
docker stop web-server test-client standalone-container
docker rm web-server test-client standalone-container

# Remove networks
docker network rm my-custom-network custom-subnet-network
```

## Advanced Testing

### Test with Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  web:
    image: nginx
    networks:
      - my-network
  client:
    image: alpine
    command: sleep 3600
    networks:
      - my-network
networks:
  my-network:
    driver: bridge
```

Run with:

```bash
docker-compose up -d
```

### Test Network Isolation

Create two separate networks and verify containers can't communicate across them.

```bash
# Create two networks
docker network create network-a
docker network create network-b

# Run containers on each
docker run -d --name container-a --network network-a alpine sleep 3600
docker run -d --name container-b --network network-b alpine sleep 3600

# Try to ping across networks (should fail)
docker exec container-a ping -c 4 container-b  # This will fail
```

## Troubleshooting

### Common Issues

1. **Port already in use**: Change the port mapping
2. **Network not found**: Ensure the network name is correct
3. **Container can't resolve names**: Check if both containers are on the same network

### Useful Commands

- `docker network prune`: Remove unused networks
- `docker network connect/disconnect`: Manage container network connections
- `docker inspect <container>`: Get detailed container information including networks

## Explanation

- **docker network ls**: Lists all networks on the Docker host
- **docker network create**: Creates a new network with specified driver and options
- **docker network inspect**: Shows detailed network configuration and connected containers
- **docker run --network**: Connects a container to a specific network at startup
- **docker network connect/disconnect**: Dynamically connects or disconnects running containers from networks
- **Container name resolution**: Docker provides built-in DNS for containers on the same network
- **Network isolation**: Containers on different networks cannot communicate unless explicitly connected

</details>
