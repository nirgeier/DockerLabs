

![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 005 - Docker Compose - WordPress & MariaDB


* This lab demonstrates how to use Docker Compose to orchestrate a simple multi-container application: WordPress with a MariaDB database backend.

## Overview

- The provided `docker-compose.yaml` file defines two main services:
    - **db**: Runs a MariaDB database (can be switched to MySQL if desired).
    - **wordpress**: Runs the latest WordPress application, connected to the database.
- A named volume `db_data` is used to persist database data.

#### docker-compose.yaml Breakdown

##### **db service**

- Uses the `mariadb:10.6.4-focal` image (or optionally MySQL).
- Sets up environment variables for root password, database, user, and password.
- Persists data in a Docker volume.
- Exposes ports 3306 and 33060 (internal only).

##### **wordpress service**
- Uses the latest WordPress image.
- Maps port 80 on the host to port 80 in the container.
- Configures environment variables to connect to the database.

##### **volumes**
- `db_data`: Persists MariaDB data between container restarts.

##### Bonus Demo

- I prepared a demo of this lab, which you can view on KillerCoda: [Portainder Demo](https://killercoda.com/codewizard/scenario/Portainer).
- The demo is showcases for setting and running multuple containers using Docker Compose
- The demo is available on [KillerCoda](https://killercoda.com/codewizard/scenario/Portainer).

---


## How to Run the Lab

1. **Navigate to the lab directory:**
   ```sh
   cd Labs/005-DockerCompose
   ```

2. **Start the services:**
   ```sh
   docker compose up -d
   ```
   - This will pull the required images (if not already present) and start both the database and WordPress containers in detached mode.

3. **Access WordPress:**
   - Open your browser and go to [http://localhost](http://localhost)
   - Complete the WordPress setup wizard.

4. **Stop the services:**
   ```sh
   docker compose down
   ```
   This will stop and remove the containers, but the database data will persist in the `db_data` volume.

## Notes
- To use MySQL instead of MariaDB, uncomment the relevant line in the compose file and comment out the MariaDB image line.
- The database credentials are set for demonstration purposes. For production, use secure passwords.
- The `db` service is only accessible to the `wordpress` service (not exposed to the host).

## Advanced Concepts

### Docker Compose Networks

Docker Compose automatically creates a default network for your services. However, you can define custom networks for better isolation and control:

```yaml
services:
  wordpress:
    networks:
      - frontend
      - backend
  
  db:
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

**Network Types:**
- `bridge`: Default network driver for standalone containers
- `host`: Use the host's network directly
- `overlay`: For multi-host networking (Docker Swarm)
- `macvlan`: Assign MAC addresses to containers
- `none`: Disable networking

### Volume Management

**Named Volumes vs Bind Mounts:**

```yaml
services:
  wordpress:
    volumes:
      # Named volume (managed by Docker)
      - wp_data:/var/www/html
      
      # Bind mount (host directory)
      - ./my-theme:/var/www/html/wp-content/themes/my-theme
      
      # Anonymous volume
      - /var/www/html/tmp

volumes:
  wp_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/on/host
```

**Volume Best Practices:**
- Use named volumes for data persistence
- Use bind mounts for development (live code updates)
- Use anonymous volumes for temporary data
- Always backup volumes before major updates

### Health Checks

Add health checks to ensure services are running correctly:

```yaml
services:
  wordpress:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
  
  db:
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
```

### Resource Limits

Control resource allocation to prevent any service from consuming all resources:

```yaml
services:
  wordpress:
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

### Restart Policies

Configure how containers should restart:

```yaml
services:
  wordpress:
    restart: unless-stopped  # Options: no, always, on-failure, unless-stopped
```

### Dependency Management

Control startup order with `depends_on`:

```yaml
services:
  wordpress:
    depends_on:
      db:
        condition: service_healthy  # Wait for db to be healthy
```

### Logging Configuration

Configure log drivers and options:

```yaml
services:
  wordpress:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Best Practices

1. **Use Environment Variables**: Store configuration in `.env` files
   ```bash
   # .env file
   MYSQL_ROOT_PASSWORD=secure_password
   MYSQL_DATABASE=wordpress
   ```

2. **Version Your Compose Files**: Always specify the Compose version
   ```yaml
   version: '3.8'
   ```

3. **Use Specific Image Tags**: Avoid `latest` tag in production
   ```yaml
   image: mariadb:10.6.4-focal
   ```

4. **Organize Services Logically**: Group related services
   - Frontend services
   - Backend services
   - Database services
   - Cache services

5. **Use Multi-Stage Builds**: For custom images, use multi-stage Dockerfiles

6. **Implement Health Checks**: Always add health checks for critical services

7. **Secure Secrets**: Use Docker secrets or external secret management
   ```yaml
   services:
     db:
       secrets:
         - db_password
   
   secrets:
     db_password:
       file: ./secrets/db_password.txt
   ```

8. **Use .dockerignore**: Exclude unnecessary files from build context

9. **Network Isolation**: Use custom networks to isolate services

10. **Monitor Resources**: Set resource limits to prevent resource exhaustion

## Useful Docker Compose Commands

```bash
# View configuration (merged from all compose files)
docker compose config

# Validate compose file
docker compose config --quiet

# Pull all images
docker compose pull

# Build services
docker compose build

# Start services
docker compose up -d

# View running services
docker compose ps

# View logs
docker compose logs -f [service_name]

# Execute command in running container
docker compose exec wordpress bash

# Scale services
docker compose up -d --scale wordpress=3

# Stop services
docker compose stop

# Stop and remove containers
docker compose down

# Stop, remove containers and volumes
docker compose down -v

# Restart services
docker compose restart

# Pause services
docker compose pause

# Unpause services
docker compose unpause

# View resource usage
docker compose top
```

## Troubleshooting
- If you encounter port conflicts, ensure nothing else is running on port 80.
- To view logs for a service:
  ```sh
  docker compose logs wordpress
  docker compose logs db
  ```
- Check service health:
  ```sh
  docker compose ps
  ```
- Inspect network connectivity:
  ```sh
  docker network inspect 005-dockercompose_default
  ```
- Debug startup issues:
  ```sh
  docker compose up --no-start
  docker compose start
  ```

---

This lab is part of the DockerLabs series. See other labs for more Docker scenarios and hands-on exercises.
