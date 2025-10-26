![DockerLabs Banner](../../assets/images/docker-logos.png)

---

# Lab 000 - Docker Basics

- This lab covers the fundamental concepts and commands of Docker.
- You will learn basic Docker operations including running containers, managing images, and creating simple Dockerfiles.
- Each task is designed to be simple and atomic, focusing on one specific Docker command or concept.
- By the end of this lab, you will have hands-on experience with core Docker functionality.
- The lab includes 50 tasks divided into Docker CLI commands, Dockerfile creation, and Docker Compose orchestration.

---

## Tasks Overview

### Docker CLI Tasks
- [Task 01: Run hello-world container](#task-01-run-hello-world-container)
- [Task 02: List running containers](#task-02-list-running-containers)
- [Task 03: List all containers](#task-03-list-all-containers)
- [Task 04: Pull an image](#task-04-pull-an-image)
- [Task 05: List images](#task-05-list-images)
- [Task 06: Run container interactively](#task-06-run-container-interactively)
- [Task 07: Run container in background](#task-07-run-container-in-background)
- [Task 08: List running containers again](#task-08-list-running-containers-again)
- [Task 09: Stop a container](#task-09-stop-a-container)
- [Task 10: Remove a container](#task-10-remove-a-container)
- [Task 11: Inspect a container](#task-11-inspect-a-container)
- [Task 12: View container logs](#task-12-view-container-logs)
- [Task 13: Execute command in container](#task-13-execute-command-in-container)
- [Task 14: Copy file to container](#task-14-copy-file-to-container)
- [Task 15: Copy file from container](#task-15-copy-file-from-container)
- [Task 16: Run container with port mapping](#task-16-run-container-with-port-mapping)
- [Task 17: Run container with volume](#task-17-run-container-with-volume)
- [Task 18: Create container without starting](#task-18-create-container-without-starting)
- [Task 19: Start created container](#task-19-start-created-container)
- [Task 20: Kill a container](#task-20-kill-a-container)

### Dockerfile Tasks
- [Task 21: Create basic Dockerfile](#task-21-create-basic-dockerfile)
- [Task 22: Build image from Dockerfile](#task-22-build-image-from-dockerfile)
- [Task 23: Run built image](#task-23-run-built-image)
- [Task 24: Create Dockerfile with COPY](#task-24-create-dockerfile-with-copy)
- [Task 25: Create Dockerfile with RUN](#task-25-create-dockerfile-with-run)
- [Task 26: Docker commit - create image from container](#task-26-docker-commit---create-image-from-container)
- [Task 27: Advanced docker cp - copy directories](#task-27-advanced-docker-cp---copy-directories)
- [Task 28: Dockerfile with multiple RUN commands](#task-28-dockerfile-with-multiple-run-commands)
- [Task 29: Dockerfile with WORKDIR](#task-29-dockerfile-with-workdir)
- [Task 30: Dockerfile with ENV variables](#task-30-dockerfile-with-env-variables)
- [Task 31: Dockerfile with EXPOSE](#task-31-dockerfile-with-expose)
- [Task 32: Custom ENTRYPOINT in Dockerfile](#task-32-custom-entrypoint-in-dockerfile)
- [Task 33: Dockerfile with USER (non-root)](#task-33-dockerfile-with-user-non-root)
- [Task 34: Copy multiple files with COPY](#task-34-copy-multiple-files-with-copy)
- [Task 35: Build a simple web server image](#task-35-build-a-simple-web-server-image)

### Docker Compose Tasks
- [Task 36: Basic docker-compose.yml structure](#task-36-basic-docker-composeyml-structure)
- [Task 37: Docker Compose with multiple services](#task-37-docker-compose-with-multiple-services)
- [Task 38: Docker Compose with networks](#task-38-docker-compose-with-networks)
- [Task 39: Docker Compose with volumes](#task-39-docker-compose-with-volumes)
- [Task 40: Docker Compose with environment variables](#task-40-docker-compose-with-environment-variables)
- [Task 41: Docker Compose with build context](#task-41-docker-compose-with-build-context)
- [Task 42: Docker Compose with depends_on](#task-42-docker-compose-with-depends_on)
- [Task 43: Docker Compose with health checks](#task-43-docker-compose-with-health-checks)
- [Task 44: Docker Compose scaling services](#task-44-docker-compose-scaling-services)
- [Task 45: Docker Compose with logging](#task-45-docker-compose-with-logging)
- [Task 46: Docker Compose with environment files](#task-46-docker-compose-with-environment-files)
- [Task 47: Docker Compose overrides](#task-47-docker-compose-overrides)
- [Task 48: Docker Compose with profiles](#task-48-docker-compose-with-profiles)
- [Task 49: Docker Compose with secrets](#task-49-docker-compose-with-secrets)
- [Task 50: Docker Compose with extensions](#task-50-docker-compose-with-extensions)

---

## Docker CLI Tasks

#### Task 01: Run hello-world container

- Run the official hello-world container to verify Docker installation.
- This container will print a message and exit.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run hello-world
```

</details>

#### Task 02: List running containers

- Display all currently running containers.

<details markdown="1">
<summary>Solution</summary>

```sh
docker ps
```

</details>

#### Task 03: List all containers

- Display all containers, including stopped ones.

<details markdown="1">
<summary>Solution</summary>

```sh
docker ps -a
```

</details>

#### Task 04: Pull an image

- Download the alpine image from Docker Hub without running it.

<details markdown="1">
<summary>Solution</summary>

```sh
docker pull alpine
```

</details>

#### Task 05: List images

- Display all Docker images available locally.

<details markdown="1">
<summary>Solution</summary>

```sh
docker images
```

</details>

#### Task 06: Run container interactively

- Run an alpine container and open an interactive shell.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run -it alpine sh
```

</details>

#### Task 07: Run container in background

- Run an nginx container in the background.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run -d --name web nginx
```

</details>

#### Task 08: List running containers again

- Verify the nginx container is running.

<details markdown="1">
<summary>Solution</summary>

```sh
docker ps
```

</details>

#### Task 09: Stop a container

- Stop the running nginx container.

<details markdown="1">
<summary>Solution</summary>

```sh
docker stop web
```

</details>

#### Task 10: Remove a container

- Remove the stopped nginx container.

<details markdown="1">
<summary>Solution</summary>

```sh
docker rm web
```

</details>

#### Task 11: Inspect a container

- Run a container and inspect its details.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run -d --name test alpine sleep 100
docker inspect test
```

</details>

#### Task 12: View container logs

- View the logs of a running container.

<details markdown="1">
<summary>Solution</summary>

```sh
docker logs test
```

</details>

#### Task 13: Execute command in container

- Execute a command inside a running container.

<details markdown="1">
<summary>Solution</summary>

```sh
docker exec test echo "Hello from inside the container"
```

</details>

#### Task 14: Copy file to container

- Copy a file from the host to a running container.

<details markdown="1">
<summary>Solution</summary>

```sh
echo "test content" > testfile.txt
docker cp testfile.txt test:/tmp/
```

</details>

#### Task 15: Copy file from container

- Copy a file from a container back to the host.

<details markdown="1">
<summary>Solution</summary>

```sh
docker cp test:/tmp/testfile.txt copiedfile.txt
```

</details>

#### Task 16: Run container with port mapping

- Run nginx with port mapping to access it from the host.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run -d -p 8080:80 --name web2 nginx
curl localhost:8080
```

</details>

#### Task 17: Run container with volume

- Run a container with a volume mount.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run -d -v $(pwd):/data --name vol-test alpine sleep 100
```

</details>

#### Task 18: Create container without starting

- Create a container but don't start it.

<details markdown="1">
<summary>Solution</summary>

```sh
docker create --name created-test alpine echo "created"
```

</details>

#### Task 19: Start created container

- Start the previously created container.

<details markdown="1">
<summary>Solution</summary>

```sh
docker start -a created-test
```

</details>

#### Task 20: Kill a container

- Forcefully kill a running container.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run -d --name kill-test alpine sleep 100
docker kill kill-test
```

</details>

## Dockerfile Tasks

#### Task 21: Create basic Dockerfile

- Create a simple Dockerfile that uses alpine as base and runs a basic command.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine
CMD ["echo", "Hello Docker"]
```

</details>

#### Task 22: Build image from Dockerfile

- Build an image from the Dockerfile created in Task 21.

<details markdown="1">
<summary>Solution</summary>

```sh
docker build -t basic-image .
```

</details>

#### Task 23: Run built image

- Run the image built in Task 22.

<details markdown="1">
<summary>Solution</summary>

```sh
docker run basic-image
```

</details>

#### Task 24: Create Dockerfile with COPY

- Create a Dockerfile that copies a file and runs it.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine
COPY testfile.txt /tmp/
CMD ["cat", "/tmp/testfile.txt"]
```

</details>

#### Task 25: Create Dockerfile with RUN

- Create a Dockerfile that installs a package and runs a command.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine
RUN apk add --no-cache curl
CMD ["curl", "--version"]
```

</details>

#### Task 26: Docker commit - create image from container

- Modify a running container and create a new image from it using docker commit.

<details markdown="1">
<summary>Solution</summary>

```sh
# Run a container and modify it
docker run -d --name modify-me alpine sleep 100
docker exec modify-me sh -c "echo 'Modified content' > /modified.txt"

# Commit the changes to a new image
docker commit modify-me my-modified-image

# Run a container from the new image to verify
docker run --rm my-modified-image cat /modified.txt

# Clean up
docker stop modify-me
docker rm modify-me
docker rmi my-modified-image
```

</details>

#### Task 27: Advanced docker cp - copy directories

- Copy entire directories between host and container using docker cp.

<details markdown="1">
<summary>Solution</summary>

```sh
# Create a directory with files
mkdir test-dir
echo "file1 content" > test-dir/file1.txt
echo "file2 content" > test-dir/file2.txt

# Run a container
docker run -d --name copy-test alpine sleep 100

# Copy directory to container
docker cp test-dir copy-test:/tmp/

# Copy directory from container to host
docker cp copy-test:/tmp/test-dir copied-dir

# Verify
ls -la copied-dir/

# Clean up
docker stop copy-test
docker rm copy-test
rm -rf test-dir copied-dir
```

</details>

#### Task 28: Dockerfile with multiple RUN commands

- Create a Dockerfile with multiple RUN instructions to install packages and configure the image.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Update package index
RUN apk update

# Install multiple packages
RUN apk add --no-cache \
    curl \
    wget \
    git

# Create a directory
RUN mkdir -p /app

# Set permissions
RUN chmod 755 /app

CMD ["echo", "Multi-RUN Dockerfile completed"]
```

Build and run:
```sh
docker build -t multi-run-image .
docker run --rm multi-run-image
docker rmi multi-run-image
```

</details>

#### Task 29: Dockerfile with WORKDIR

- Use WORKDIR instruction to set the working directory for subsequent instructions.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Set working directory
WORKDIR /app

# Create files in the working directory
RUN echo "Hello from /app" > hello.txt

# Copy files to working directory
COPY testfile.txt .

# Run commands in working directory
CMD ["cat", "hello.txt"]
```

Build and run:
```sh
echo "test content" > testfile.txt
docker build -t workdir-image .
docker run --rm workdir-image
docker rmi workdir-image
rm testfile.txt
```

</details>

#### Task 30: Dockerfile with ENV variables

- Use ENV instruction to set environment variables in the Dockerfile.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Set environment variables
ENV APP_NAME="My Docker App" \
    APP_VERSION="1.0.0" \
    AUTHOR="Docker User"

# Use environment variables in RUN commands
RUN echo "Building $APP_NAME version $APP_VERSION by $AUTHOR" > /app/info.txt

# Use in CMD
CMD ["sh", "-c", "echo 'App: '$APP_NAME', Version: '$APP_VERSION', Author: '$AUTHOR && cat /app/info.txt"]
```

Build and run:
```sh
docker build -t env-image .
docker run --rm env-image
docker rmi env-image
```

</details>

#### Task 31: Dockerfile with EXPOSE

- Use EXPOSE instruction to document which ports the container listens on.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Install a simple HTTP server
RUN apk add --no-cache python3

# Create a simple HTML file
RUN echo "<html><body><h1>Hello from Docker!</h1></body></html>" > /index.html

# Expose port 8080
EXPOSE 8080

# Start a simple HTTP server
CMD ["python3", "-m", "http.server", "8080"]
```

Build and run:
```sh
docker build -t expose-image .
docker run -d -p 8080:8080 --name expose-test expose-image
sleep 2
curl localhost:8080
docker stop expose-test
docker rm expose-test
docker rmi expose-image
```

</details>

#### Task 32: Custom ENTRYPOINT in Dockerfile

- Use ENTRYPOINT instruction to set the default executable for the container.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Install curl
RUN apk add --no-cache curl

# Set entrypoint to curl
ENTRYPOINT ["curl"]

# Default arguments for curl
CMD ["--version"]
```

Build and run:
```sh
docker build -t entrypoint-image .

# Run with default CMD
docker run --rm entrypoint-image

# Run with custom arguments
docker run --rm entrypoint-image -I https://httpbin.org/get

docker rmi entrypoint-image
```

</details>

#### Task 33: Dockerfile with USER (non-root)

- Create a Dockerfile that runs as a non-root user for security.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Create a non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Create app directory and set ownership
RUN mkdir /app && chown appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# Create a file as non-root user
RUN echo "Running as $(whoami)" > user-info.txt

CMD ["cat", "user-info.txt"]
```

Build and run:
```sh
docker build -t user-image .
docker run --rm user-image
docker rmi user-image
```

</details>

#### Task 34: Copy multiple files with COPY

- Use COPY instruction to copy multiple files and directories into the container.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Create source files
RUN mkdir /source
RUN echo "config data" > /source/config.txt
RUN echo "script content" > /source/script.sh

# Copy multiple files
COPY /source/* /app/

# Copy entire directory
COPY /source /app/source/

# List copied files
CMD ["ls", "-la", "/app/"]
```

Build and run:
```sh
docker build -t copy-multi-image .
docker run --rm copy-multi-image
docker rmi copy-multi-image
```

</details>

#### Task 35: Build a simple web server image

- Create a complete Dockerfile for a simple web server that serves static files.

<details markdown="1">
<summary>Solution</summary>

```Dockerfile
FROM alpine:latest

# Install nginx
RUN apk add --no-cache nginx

# Create web directory
RUN mkdir -p /var/www/html

# Create a simple HTML page
RUN echo '<html><head><title>Docker Web Server</title></head><body><h1>Welcome to my Docker Web Server!</h1><p>This page is served from a custom Docker image.</p></body></html>' > /var/www/html/index.html

# Create nginx config
RUN echo 'server { listen 80; root /var/www/html; index index.html; location / { try_files $uri $uri/ =404; } }' > /etc/nginx/http.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
```

Build and run:
```sh
docker build -t web-server-image .
docker run -d -p 8080:80 --name web-server web-server-image
sleep 3
curl localhost:8080
docker stop web-server
docker rm web-server
docker rmi web-server-image
```

</details>

## Docker Compose Tasks

#### Task 36: Basic docker-compose.yml structure

- Create a basic docker-compose.yml file with a single service.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
```

Run and test:
```sh
docker-compose up -d
docker-compose ps
curl localhost:8080
docker-compose down
```

</details>

#### Task 37: Docker Compose with multiple services

- Create a docker-compose.yml with multiple services that communicate with each other.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
  api:
    image: alpine:latest
    command: ["sh", "-c", "while true; do echo 'API running'; sleep 30; done"]
```

Run and test:
```sh
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
```

</details>

#### Task 38: Docker Compose with networks

- Configure custom networks in docker-compose.yml for service isolation.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    networks:
      - frontend
  api:
    image: alpine:latest
    command: ["sh", "-c", "while true; do echo 'API running'; sleep 30; done"]
    networks:
      - backend
  proxy:
    image: nginx:latest
    ports:
      - "8081:80"
    networks:
      - frontend
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
```

Run and test:
```sh
docker-compose up -d
docker-compose ps
docker network ls
docker-compose down
```

</details>

#### Task 39: Docker Compose with volumes

- Use named volumes and bind mounts in docker-compose.yml.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html:ro
      - nginx-logs:/var/log/nginx
  data:
    image: alpine:latest
    volumes:
      - data-volume:/data
    command: ["sh", "-c", "echo 'Data stored' > /data/file.txt && sleep 3600"]

volumes:
  nginx-logs:
  data-volume:
```

Run and test:
```sh
mkdir html
echo "<h1>Hello from Docker Compose!</h1>" > html/index.html
docker-compose up -d
curl localhost:8080
docker-compose exec data cat /data/file.txt
docker-compose down -v
rm -rf html
```

</details>

#### Task 40: Docker Compose with environment variables

- Configure environment variables in docker-compose.yml.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    environment:
      - NGINX_PORT=80
      - APP_ENV=production
  app:
    image: alpine:latest
    environment:
      - DATABASE_URL=postgres://user:pass@db:5432/mydb
      - REDIS_URL=redis://cache:6379
    command: ["sh", "-c", "echo 'DB: '$DATABASE_URL && echo 'Redis: '$REDIS_URL && sleep 30"]
```

Run and test:
```sh
docker-compose up -d
docker-compose exec app env | grep -E "(DATABASE|REDIS)"
docker-compose down
```

</details>

#### Task 41: Docker Compose with build context

- Build custom images using docker-compose.yml.

<details markdown="1">
<summary>Solution</summary>

Create `Dockerfile`:
```dockerfile
FROM alpine:latest
RUN echo "Custom built image" > /message.txt
CMD ["cat", "/message.txt"]
```

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  custom-app:
    build: .
    ports:
      - "8080:8080"
```

Run and test:
```sh
docker-compose up --build -d
docker-compose logs
docker-compose down --rmi local
```

</details>

#### Task 42: Docker Compose with depends_on

- Use depends_on to control service startup order.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=mypassword
      - POSTGRES_DB=testdb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
  app:
    image: alpine:latest
    depends_on:
      db:
        condition: service_healthy
    command: ["sh", "-c", "echo 'App started after DB is healthy' && sleep 30"]
```

Run and test:
```sh
docker-compose up -d
docker-compose ps
docker-compose logs app
docker-compose down
```

</details>

#### Task 43: Docker Compose with health checks

- Configure health checks for services in docker-compose.yml.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
  monitor:
    image: alpine:latest
    depends_on:
      web:
        condition: service_healthy
    command: ["sh", "-c", "echo 'Web service is healthy!' && sleep 30"]
```

Run and test:
```sh
docker-compose up -d
docker-compose ps
docker-compose exec web curl -f http://localhost/
docker-compose down
```

</details>

#### Task 44: Docker Compose scaling services

- Scale services up and down using docker-compose.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080-8085:80"
```

Run and test:
```sh
docker-compose up -d --scale web=3
docker-compose ps
curl localhost:8080
curl localhost:8081
curl localhost:8082
docker-compose up -d --scale web=1
docker-compose down
```

</details>

#### Task 45: Docker Compose with logging

- Configure logging options in docker-compose.yml.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  app:
    image: alpine:latest
    command: ["sh", "-c", "for i in $(seq 1 10); do echo 'Log message '$i; sleep 2; done"]
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://localhost:514"
```

Run and test:
```sh
docker-compose up -d
docker-compose logs app
docker-compose logs -f --tail=5 web
docker-compose down
```

</details>

#### Task 46: Docker Compose with environment files

- Use .env files to manage environment variables.

<details markdown="1">
<summary>Solution</summary>

Create `.env` file:
```
APP_NAME=MyApp
APP_VERSION=1.0.0
DATABASE_URL=postgres://user:pass@localhost:5432/mydb
```

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  app:
    image: alpine:latest
    environment:
      - APP_NAME=${APP_NAME}
      - APP_VERSION=${APP_VERSION}
      - DATABASE_URL=${DATABASE_URL}
    command: ["sh", "-c", "echo 'App: '$APP_NAME' v'$APP_VERSION && echo 'DB: '$DATABASE_URL && sleep 30"]
```

Run and test:
```sh
docker-compose up -d
docker-compose exec app env | grep -E "(APP|DATABASE)"
docker-compose down
rm .env
```

</details>

#### Task 47: Docker Compose overrides

- Use multiple compose files for different environments.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml` (base):
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
```

Create `docker-compose.override.yml` (development):
```yaml
version: '3.8'
services:
  web:
    environment:
      - ENV=development
    volumes:
      - ./dev-html:/usr/share/nginx/html
  debug:
    image: alpine:latest
    command: ["sh", "-c", "while true; do echo 'Debug service running'; sleep 30; done"]
```

Run and test:
```sh
mkdir dev-html
echo "<h1>Development Environment</h1>" > dev-html/index.html
docker-compose up -d
curl localhost:8080
docker-compose ps
docker-compose down
rm -rf dev-html
```

</details>

#### Task 48: Docker Compose with profiles

- Use profiles to enable/disable services.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=mypassword
    profiles:
      - database
  cache:
    image: redis:latest
    profiles:
      - cache
  monitoring:
    image: alpine:latest
    command: ["sh", "-c", "while true; do echo 'Monitoring...'; sleep 30; done"]
    profiles:
      - monitoring
```

Run and test:
```sh
# Start only web service
docker-compose up -d
curl localhost:8080

# Start with database
docker-compose --profile database up -d
docker-compose ps

# Start with cache and monitoring
docker-compose --profile cache --profile monitoring up -d
docker-compose ps

docker-compose down
```

</details>

#### Task 49: Docker Compose with secrets

- Manage sensitive data using Docker secrets.

<details markdown="1">
<summary>Solution</summary>

Create secret files:
```sh
echo "mysecretpassword" > db_password.txt
echo "myappsecretkey" > app_secret.txt
```

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
  app:
    image: alpine:latest
    secrets:
      - app_secret
    command: ["sh", "-c", "cat /run/secrets/app_secret && sleep 30"]

secrets:
  db_password:
    file: ./db_password.txt
  app_secret:
    file: ./app_secret.txt
```

Run and test:
```sh
docker-compose up -d
docker-compose exec app cat /run/secrets/app_secret
docker-compose down
rm db_password.txt app_secret.txt
```

</details>

#### Task 50: Docker Compose with extensions

- Use extensions (x-) for reusable configurations.

<details markdown="1">
<summary>Solution</summary>

Create `docker-compose.yml`:
```yaml
version: '3.8'

x-app-defaults: &app-defaults
  image: alpine:latest
  environment:
    - LOG_LEVEL=info
  restart: unless-stopped

x-db-defaults: &db-defaults
  restart: unless-stopped
  environment:
    - POSTGRES_USER=app
    - POSTGRES_DB=myapp

services:
  web:
    <<: *app-defaults
    ports:
      - "8080:80"
    command: ["sh", "-c", "echo 'Web service with defaults' && sleep 3600"]
  
  api:
    <<: *app-defaults
    ports:
      - "8081:8081"
    environment:
      - LOG_LEVEL=debug
    command: ["sh", "-c", "echo 'API service with custom log level' && sleep 3600"]
  
  db:
    <<: *db-defaults
    image: postgres:13
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_PASSWORD=mypassword
```

Run and test:
```sh
docker-compose up -d
docker-compose ps
docker-compose exec web env | grep LOG_LEVEL
docker-compose exec api env | grep LOG_LEVEL
docker-compose down
```

</details>

- After completing all tasks, clean up containers and images.

<details markdown="1">
<summary>Clean Up Commands</summary>

```sh
# Remove all containers
docker rm $(docker ps -aq)

# Remove unused images
docker image prune -f
```

</details>

---

![Well Done](../../assets/images/well-done.png)