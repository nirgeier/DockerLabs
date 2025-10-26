![DockerLabs Banner](../../assets/images/docker-logos.png)

---

# Docker CLI Tasks

- Hands-on Docker exercises covering essential CLI commands, debugging techniques, and advanced containerization concepts.
- Each task includes a description and a detailed solution with step-by-step instructions.
- Practice these tasks to master Docker from basic operations to advanced deployment scenarios.

---

#### Table of Contents

- [01. Docker Commit Workflow](#1-docker-commit-workflow)
- [02. Docker Container Debugging Challenge](#2-docker-container-debugging-challenge)
- [03. Docker Logs and Container Management](#3-docker-logs-and-container-management)
- [04. Run a docker container, write file to the container, export the container as a new image](#4-run-a-docker-container-write-file-to-the-container-export-the-container-as-a-new-image)
- [05. Run nginx container, map the ports, redirect the logs to a file on the host](#5-run-nginx-container-map-the-ports-redirect-the-logs-to-a-file-on-the-host)
- [06. Serve a local folder as a website using Nginx](#6-serve-a-local-folder-as-a-website-using-nginx)
- [07. Extract the default configuration file of an Apache server to use as a template](#7-extract-the-default-configuration-file-of-an-apache-server-to-use-as-a-template)
- [08. Run nginx and monitor the logs in real time](#8-run-nginx-and-monitor-the-logs-in-real-time)
- [09. Delete all stopped containers at once](#9-delete-all-stopped-containers-at-once)
- [10. Create a multi-stage build Dockerfile for a Go application](#10-create-a-multi-stage-build-dockerfile-for-a-go-application)
- [11. Use Docker volumes to persist data between container restarts](#11-use-docker-volumes-to-persist-data-between-container-restarts)
- [12. Set up a Docker network and connect multiple containers](#12-set-up-a-docker-network-and-connect-multiple-containers)
- [13. Build and push a custom image to Docker Hub](#13-build-and-push-a-custom-image-to-docker-hub)
- [14. Use docker-compose to run a multi-container application](#14-use-docker-compose-to-run-a-multi-container-application)
- [15. Implement health checks for a container](#15-implement-health-checks-for-a-container)
- [16. Use environment variables in a Dockerfile](#16-use-environment-variables-in-a-dockerfile)
- [17. Create a Dockerfile that runs as a non-root user](#17-create-a-dockerfile-that-runs-as-a-non-root-user)
- [18. Use docker exec to debug a running container](#18-use-docker-exec-to-debug-a-running-container)

---

#### 01. Docker Commit Workflow

* Start an `alpine` container and keep it running for modifications, create a new file inside the running container, use `docker commit` to capture a new image with the file included, run a container from the committed image and verify the file exists.

    #### **Scenario:** 
    * As a developer, you need to quickly customize a base image for testing by adding configuration files or debugging tools without rebuilding the entire image from source code. 
    * This workflow allows you to make runtime modifications and save them as a new reusable image.

**Hint:** `docker run`, `docker exec`, `docker commit`, and `docker run --rm`

<details markdown="1">
<summary>Solution</summary>

**Solution:**

- **Run a modifiable alpine container**

   ```bash
   docker run -d --name alpine-commit alpine:latest sleep infinity
   ```

- **Write a file inside the running container**

   ```bash
   docker exec alpine-commit sh -c "echo 'Persisted with docker commit' > /opt/commit-note.txt"
   ```

- **Validate the file inside the original container (optional check)**

   ```bash
   docker exec alpine-commit cat /opt/commit-note.txt
   ```

- **Create a new image from the modified container**

   ```bash
   docker commit alpine-commit alpine-with-note:latest
   ```

- **Run a container from the committed image and verify the file exists**

   ```bash
   docker run --rm alpine-with-note:latest cat /opt/commit-note.txt
   ```

   Expected output:

   ```text
   Persisted with docker commit
   ```

- **Clean up resources**

   ```bash
   docker rm -f alpine-commit
   docker image rm alpine-with-note:latest
   ```

**Explanation:**

- **docker run -d ... sleep infinity**: Starts a container that stays alive for edits
- **docker exec ... echo '...' > file**: Writes a file into the running container
- **docker commit**: Captures the container's filesystem changes into a new image
- **docker run --rm new-image cat file**: Launches the new image, verifies the persistent file, and removes the container when done
- **Cleanup commands**: Remove the temporary container and image to free resources

</details>


---

#### 02. Docker Container Debugging Challenge

* Run a container that encounters an error, use debugging techniques to identify the issue, and fix the problem.

    #### **Scenario:** 
    * Your production application container is failing to start, and you need to diagnose the root cause quickly. 
    * Using Docker's debugging tools, you can inspect logs, check exit codes, and test commands to identify and resolve the issue without affecting other services.

**Hint:** Use `docker logs`, `docker exec`, and `docker inspect` to troubleshoot container issues

<details markdown="1">
<summary>Solution</summary>

**Solution:**

- **Run a container that will fail**

   ```bash
   docker run --name failing-container alpine sh -c "echo 'Starting...' && nonexistent_command && echo 'Success'"
   ```

- **Check the container status**

   ```bash
   docker ps -a | grep failing-container
   ```

- **Examine the container logs**

   ```bash
   docker logs failing-container
   ```

   Expected output will show the error:

   ```text
   Starting...
   sh: nonexistent_command: not found
   ```

- **Inspect the container for more details**

   ```bash
   docker inspect failing-container | grep -A 10 "State"
   ```

- **Debug by running a successful command in a similar container**

   ```bash
   docker run --rm alpine sh -c "echo 'Debug: Container is working' && ls -la /"
   ```

- **Fix the original command and run a corrected version**

   ```bash
   docker run --rm alpine sh -c "echo 'Starting...' && echo 'This command exists' && echo 'Success'"
   ```

- **Clean up**

   ```bash
   docker rm failing-container
   ```

**Explanation:**

- **docker logs**: Shows stdout/stderr output from the container, crucial for debugging failures
- **docker inspect**: Provides detailed container information including exit codes and state
- **docker exec**: Allows running commands in running containers for interactive debugging
- **Exit codes**: Non-zero exit codes indicate failures that can be investigated with logs

**Bonus: Advanced Debugging Techniques**

```bash
# Check container exit code
docker inspect failing-container --format='{{.State.ExitCode}}'

# Run a debug container with the same image
docker run -it --rm alpine sh

# Inside the debug shell, test commands manually
# echo "Testing commands..."
# exit
```

</details>


---

#### 03. Docker Logs and Container Management

* Run a `cowsay` Docker container with a custom message, send a message to the cowsay container (e.g., "Hello from Docker!"), stop the container after execution, extract and save the container logs to the host machine for debugging purposes.

    #### **Scenario:** 
    * You're running a batch processing job in a container and need to capture its output for analysis or compliance purposes. 
    * By redirecting container logs to host files, you can preserve important output data even after the container terminates.

**Hint:** Use `docker run`, `docker logs`, and output redirection.

<details markdown="1">
<summary>Solution</summary>

**Solution:**

- **Run the cowsay container with a custom message**

   ```bash
   docker run --name my-cowsay docker/whalesay cowsay "Hello from Docker!"
   ```

- **Verify the container has stopped**

   The container stops automatically after execution. You can verify with:

   ```bash
   docker ps -a | grep my-cowsay
   ```

- **Grab the logs and save to host machine**

   ```bash
   docker logs my-cowsay > cowsay-logs.txt
   ```

- **View the saved logs**

   ```bash
   cat cowsay-logs.txt
   ```

   Expected output in `cowsay-logs.txt`:

   ```text
    ______________________
   < Hello from Docker! >
    ----------------------
       \
        \
         \
                       ##        .
                 ## ## ##       ==
              ## ## ## ##      ===
          /""""""""""""""""___/ ===
     ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
          \______ o          __/
           \    \        __/
             \____\______/
   ```

- **Clean up (optional)**

   ```bash
   # Remove the container
   docker rm my-cowsay

   # Remove the log file
   rm cowsay-logs.txt
   ```

**Alternative: Using a Different Cowsay Image**

If `docker/whalesay` is not available, you can build your own:

**Dockerfile:**

```dockerfile
FROM alpine:latest
RUN apk add --no-cache cowsay
ENTRYPOINT ["/usr/bin/cowsay"]
CMD ["Hello Docker!"]
```

**Build and run:**

```bash
docker build -t my-cowsay .
docker run --name cowsay-test my-cowsay "Hello from Docker!"
docker logs cowsay-test > cowsay-logs.txt
```

**Explanation:**

- **docker run --name**: Assigns a name to the container for easy reference
- **cowsay "message"**: Passes the message to the cowsay command
- **docker logs**: Retrieves all stdout/stderr output from the container
- **> cowsay-logs.txt**: Redirects the log output to a file on the host machine
- The container stops automatically after the command completes

**Bonus: Running in Detached Mode**

For containers that run longer:

```bash
# Run in detached mode
docker run -d --name my-cowsay-bg docker/whalesay /bin/sh -c "cowsay 'Background task' && sleep 30"

# Get logs while running
docker logs my-cowsay-bg

# Follow logs in real-time
docker logs -f my-cowsay-bg

# Stop the container
docker stop my-cowsay-bg

# Save logs after stopping
docker logs my-cowsay-bg > cowsay-bg-logs.txt
```

</details>

---

#### 04. Run a docker container, write file to the container, export the container as a new image

* Start an Alpine container, create a file inside it, and then commit the changes to create a new image.

    #### **Scenario:** 
    * You have a legacy application that requires manual configuration steps that can't be easily automated in a Dockerfile. 
    * You need to perform these configurations interactively and then save the configured state as a new image for deployment.

**Hint:** Use `docker run -it`, `docker commit`, and `docker run --rm`

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Run an Alpine container interactively
docker run -it --name alpine-modify alpine sh

# Inside the container, create a file
echo "Hello from modified container" > /hello.txt

# Exit the container (Ctrl+D or exit)

# Commit the container to a new image
docker commit alpine-modify my-alpine-modified:v1

# Verify the new image
docker images | grep my-alpine-modified

# Test the new image
docker run --rm my-alpine-modified cat /hello.txt

# Clean up
docker rm alpine-modify
```

**Explanation:**

- **docker run -it**: Runs a container interactively, allowing direct shell access
- **docker commit**: Creates a new image from a container's current state
- **docker images**: Lists all available images to verify the new image was created
- **docker run --rm**: Runs a container and automatically removes it when it exits

</details>

---

#### 05. Run nginx container, map the ports, redirect the logs to a file on the host

* Run an Nginx container with port mapping and redirect its logs to a file on the host system.

    #### **Scenario:** 
    * You're deploying a web application in production and need to centralize log collection for monitoring and troubleshooting. 
    * By mounting host directories as volumes, you can integrate container logs with your existing log aggregation system.

    #### **Resources:**
    * Create a logs directory: `mkdir -p ~/nginx-logs`

**Hint:** Use `docker run -d -p` and volume mounting with `-v`

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Create a directory for logs
mkdir -p ~/nginx-logs

# Run Nginx container with port mapping and log redirection
docker run -d --name nginx-logged \
  -p 8080:80 \
  -v ~/nginx-logs:/var/log/nginx \
  nginx

# Wait a moment for the container to start
sleep 3

# Test the container
curl http://localhost:8080

# Check that logs are being written to the host
ls -la ~/nginx-logs/
tail ~/nginx-logs/access.log

# Clean up
docker stop nginx-logged
docker rm nginx-logged
rm -rf ~/nginx-logs
```

**Explanation:**

- **docker run -d -p**: Runs container in detached mode and maps host port to container port
- **-v flag**: Mounts host directory as volume inside container for log persistence
- **curl**: Tests HTTP connectivity to verify the container is responding
- **tail**: Shows the last lines of log files to monitor access logs

</details>

---

#### 06. Serve a local folder as a website using Nginx

* Create a local HTML file and serve it using an Nginx container that mounts the local directory.

    #### **Scenario:** 
    * As a frontend developer, you want to quickly test your static website changes without setting up a full development server. 
    * Using Docker, you can instantly serve your local files through Nginx for testing across different devices on your network.

    #### **Resources:**
    * Create a website directory: `mkdir -p ~/my-website`
    * Create an HTML file: `echo "<html><body><h1>Hello from my local website!</h1></body></html>" > ~/my-website/index.html`

**Hint:** Use volume mounting to override Nginx's default web root directory

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Create a local directory and HTML file
mkdir -p ~/my-website
echo "<html><body><h1>Hello from my local website!</h1></body></html>" > ~/my-website/index.html

# Run Nginx container mounting the local directory
docker run -d --name nginx-website \
  -p 8080:80 \
  -v ~/my-website:/usr/share/nginx/html \
  nginx

# Wait for the container to start
sleep 3

# Test the website
curl http://localhost:8080

# Clean up
docker stop nginx-website
docker rm nginx-website
rm -rf ~/my-website
```

**Explanation:**

- **Volume mounting (-v)**: Maps host directory to container directory for file sharing
- **Nginx web root**: /usr/share/nginx/html is the default directory Nginx serves files from
- **curl**: Tests the web server to ensure content is being served correctly
- **Directory creation**: Creates local content that gets served by the container

</details>

---

#### 07. Extract the default configuration file of an Apache server to use as a template

* Run an Apache container, copy its default configuration file to the host, then stop and remove the container.

    #### **Scenario:** 
    * You're setting up a custom Apache configuration for your application and need a reference configuration file to start with. 
    * Rather than manually creating one, you can extract the default configuration from the official Apache image as a template.

**Hint:** Use `docker cp` to copy files from a running container to the host

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Run Apache container
docker run -d --name apache-config httpd

# Wait for it to start
sleep 3

# Copy the default configuration file
docker cp apache-config:/usr/local/apache2/conf/httpd.conf ~/apache-config-template.conf

# Verify the file was copied
ls -la ~/apache-config-template.conf
head -20 ~/apache-config-template.conf

# Clean up
docker stop apache-config
docker rm apache-config
```

**Explanation:**

- **docker cp**: Copies files between host and running containers
- **Configuration extraction**: Useful for getting default configs as templates for customization
- **head command**: Shows the first few lines of files to verify content
- **File permissions check**: ls -la shows detailed file information including permissions

</details>

---

#### 08. Run nginx and monitor the logs in real time

* Start an Nginx container and monitor its access logs in real time using docker logs.

    #### **Scenario:** 
    * Your web application is experiencing intermittent issues, and you need to monitor incoming requests in real-time to identify patterns or problematic traffic. 
    * Following logs live helps you correlate user actions with system behavior.

**Hint:** Use `docker logs -f` to follow logs in real time

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Run Nginx container
docker run -d --name nginx-monitor -p 8080:80 nginx

# In another terminal, monitor logs in real time
# docker logs -f nginx-monitor

# In the current terminal, generate some traffic
for i in {1..5}; do
  curl http://localhost:8080
  sleep 1
done

# Stop monitoring (Ctrl+C in the other terminal)

# Clean up
docker stop nginx-monitor
docker rm nginx-monitor
```

**Explanation:**

- **docker logs -f**: Follows log output in real-time (like tail -f)
- **Background monitoring**: Running logs command in separate terminal while generating traffic
- **Traffic generation**: Using curl in a loop to create access log entries
- **Real-time debugging**: Essential for monitoring live application behavior

</details>

---

#### 09. Delete all stopped containers at once

* Remove all containers that are not currently running.

    #### **Scenario:** 
    * After a development session with multiple container iterations, your Docker environment is cluttered with stopped containers consuming disk space. 
    * You need to clean up efficiently to free resources and maintain a tidy development environment.

**Hint:** Use `docker container prune` or filter containers by status

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# List all containers (running and stopped)
docker ps -a

# Remove all stopped containers
docker container prune -f

# Alternatively, using rm with ps
# docker rm $(docker ps -aq --filter status=exited)

# Verify cleanup
docker ps -a
```

**Explanation:**

- **docker container prune**: Removes all stopped containers at once
- **docker ps -a**: Shows all containers (running and stopped) for verification
- **Container lifecycle management**: Important for keeping Docker environment clean
- **Bulk operations**: More efficient than removing containers one by one

</details>

---

#### 10. Create a multi-stage build Dockerfile for a Go application

* Create a Dockerfile that uses multi-stage builds to compile a Go application and produce a minimal runtime image.

    #### **Scenario:** 
    * You're deploying a Go application to production and want to minimize the attack surface and image size. 
    * Multi-stage builds allow you to use heavy build tools in the first stage and copy only the compiled binary to a minimal runtime image.

    #### **Resources:**
    * Create `main.go`:
      ```go
      package main

      import (
          "fmt"
          "net/http"
      )

      func main() {
          http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
              fmt.Fprintf(w, "Hello from Go!")
          })
          http.ListenAndServe(":8080", nil)
      }
      ```
    * Create `go.mod`:
      ```
      module app
      go 1.21
      ```
    * Create `Dockerfile.multi-stage` (see solution for content)

**Hint:** Use `FROM ... AS` to define build stages and `COPY --from=` to copy artifacts between stages

<details markdown="1">
<summary>Solution</summary>

**Solution:**
Create a file named `Dockerfile.multi-stage`:
```Dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/main .

# Expose port
EXPOSE 8080

# Run the binary
CMD ["./main"]
```

Build and test:
```sh
# Assuming you have a simple Go app
echo 'package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello from Go!")
    })
    http.ListenAndServe(":8080", nil)
}' > main.go

echo 'module app
go 1.21' > go.mod

# Build the multi-stage image
docker build -f Dockerfile.multi-stage -t go-multi-stage .

# Run the container
docker run -d -p 8080:80 go-multi-stage

# Test
curl http://localhost:8080

# Clean up
docker stop $(docker ps -q --filter ancestor=go-multi-stage)
docker rm $(docker ps -aq --filter ancestor=go-multi-stage)
docker rmi go-multi-stage
```

**Explanation:**

- **Multi-stage builds**: Separate build and runtime stages for smaller final images
- **FROM ... AS**: Defines named build stages that can be referenced later
- **COPY --from=**: Copies artifacts from build stage to runtime stage
- **CGO_ENABLED=0**: Disables CGO for static binary compilation
- **Minimal runtime images**: Alpine Linux provides small, secure base images

</details>

---

#### 11. Use Docker volumes to persist data between container restarts

* Create a named volume, use it with a container to store data, restart the container, and verify data persistence.

    #### **Scenario:** 
    * Your application stores user data or configuration that must survive container updates or crashes. 
    * Using Docker volumes ensures that important data persists independently of container lifecycle.

**Hint:** Use `docker volume create` and mount volumes with `-v` flag

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Create a named volume
docker volume create my-data-volume

# Run a container that writes to the volume
docker run -d --name data-container \
  -v my-data-volume:/data \
  alpine sh -c "echo 'Persistent data' > /data/file.txt && sleep 30"

# Wait a moment
sleep 5

# Check the data in the volume
docker run --rm -v my-data-volume:/data alpine cat /data/file.txt

# Stop and remove the container
docker stop data-container
docker rm data-container

# Run a new container with the same volume
docker run --rm -v my-data-volume:/data alpine cat /data/file.txt

# Clean up
docker volume rm my-data-volume
```

**Explanation:**

- **docker volume create**: Creates named volumes for persistent data storage
- **Named volumes**: Managed by Docker and survive container deletion
- **Data persistence**: Volumes maintain data across container restarts and recreations
- **Volume mounting**: -v flag attaches volumes to containers at specific paths

</details>

---

#### 12. Set up a Docker network and connect multiple containers

* Create a custom Docker network, run two containers on it, and demonstrate inter-container communication.

    #### **Scenario:** 
    * You're deploying a microservices architecture where multiple containers need to communicate securely. 
    * Custom networks provide isolation and service discovery, allowing containers to communicate using predictable hostnames.

**Hint:** Use `docker network create` and `--network` flag when running containers

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Create a custom network
docker network create my-network

# Run a container that provides a service (simple HTTP server)
docker run -d --name web-server \
  --network my-network \
  -p 8080:80 \
  nginx

# Run another container that can communicate with the first
docker run --rm --network my-network \
  alpine wget -qO- http://web-server

# Test from host (should work via port mapping)
curl http://localhost:8080

# Inspect the network
docker network inspect my-network

# Clean up
docker stop web-server
docker rm web-server
docker network rm my-network
```

**Explanation:**

- **docker network create**: Creates isolated networks for container communication
- **--network flag**: Connects containers to specific networks
- **Service discovery**: Containers can communicate using container names as hostnames
- **Network isolation**: Provides security and organization for multi-container applications

</details>

---

#### 13. Build and push a custom image to Docker Hub

* Create a simple custom image, tag it appropriately, and push it to Docker Hub (requires a Docker Hub account).

    #### **Scenario:** 
    * You've developed a custom application image and want to share it with your team or deploy it across multiple environments. 
    * Pushing to Docker Hub makes the image accessible from any Docker host with internet access.

**Hint:** Use `docker build`, `docker tag`, `docker login`, and `docker push`

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Create a simple Dockerfile
echo 'FROM alpine:latest
RUN echo "Hello from my custom image" > /hello.txt
CMD ["cat", "/hello.txt"]' > Dockerfile

# Build the image
docker build -t my-custom-image:v1 .

# Tag for Docker Hub (replace 'yourusername' with your Docker Hub username)
# docker tag my-custom-image:v1 yourusername/my-custom-image:v1

# Login to Docker Hub
# docker login

# Push the image
# docker push yourusername/my-custom-image:v1

# Test pulling the image (after pushing)
# docker rmi yourusername/my-custom-image:v1
# docker pull yourusername/my-custom-image:v1

# Clean up
docker rmi my-custom-image:v1
rm Dockerfile
```

**Explanation:**

- **docker build**: Creates images from Dockerfiles
- **docker tag**: Assigns repository names and tags to images
- **docker login**: Authenticates with Docker Hub for pushing images
- **docker push**: Uploads images to remote registries like Docker Hub
- **Image distribution**: Enables sharing and deploying applications across environments

</details>

---

#### 14. Use docker-compose to run a multi-container application

* Create a docker-compose.yml file for a simple web application with a database, and run it.

    #### **Scenario:** 
    * You're developing a full-stack application with multiple components (web server, database, cache) that need to work together. 
    * Docker Compose allows you to define, configure, and run all services with a single command.

**Hint:** Define services, ports, volumes, and environment variables in docker-compose.yml

<details markdown="1">
<summary>Solution</summary>

**Solution:**
Create a `docker-compose.yml` file:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
  db:
    image: postgres:13
    environment:
      POSTGRES_PASSWORD: mypassword
      POSTGRES_DB: mydb
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

Run the application:
```sh
# Create a simple HTML file
mkdir -p html
echo "<html><body><h1>Web App with DB</h1></body></html>" > html/index.html

# Start the services
docker-compose up -d

# Check running services
docker-compose ps

# Test the web service
curl http://localhost:8080

# Stop and clean up
docker-compose down -v
rm -rf html docker-compose.yml
```

**Explanation:**

- **docker-compose.yml**: Defines multi-container applications with services, networks, and volumes
- **docker-compose up -d**: Starts all services defined in the compose file in detached mode
- **Service orchestration**: Manages complex applications with multiple interconnected containers
- **Environment variables**: Configure services through compose file declarations
- **Named volumes**: Persistent storage that survives container recreation

</details>

---

#### 15. Implement health checks for a container

* Create a Dockerfile with a health check and run a container to monitor its health status.

    #### **Scenario:** 
    * Your containerized application runs in production with auto-healing capabilities. 
    * Health checks allow the orchestrator to detect when a container becomes unresponsive and automatically restart it, ensuring high availability.

**Hint:** Use `HEALTHCHECK` instruction in Dockerfile and check status with `docker ps` or `docker inspect`

<details markdown="1">
<summary>Solution</summary>

**Solution:**
Create a `Dockerfile.health`:
```Dockerfile
FROM nginx:latest

# Copy a custom health check script
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD /healthcheck.sh

# Expose port
EXPOSE 80
```

Create the health check script:
```sh
#!/bin/sh
# Simple health check that verifies nginx is responding
curl -f http://localhost/ > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Health check passed"
    exit 0
else
    echo "Health check failed"
    exit 1
fi
```

Build and run:
```sh
# Build the image
docker build -f Dockerfile.health -t nginx-healthy .

# Run the container
docker run -d --name healthy-nginx -p 8080:80 nginx-healthy

# Wait for health check to run
sleep 10

# Check container health
docker ps
docker inspect healthy-nginx | grep -A 5 "Health"

# Clean up
docker stop healthy-nginx
docker rm healthy-nginx
docker rmi nginx-healthy
rm Dockerfile.health healthcheck.sh
```

**Explanation:**

- **HEALTHCHECK instruction**: Defines how Docker determines if a container is healthy
- **Health check intervals**: --interval, --timeout, --start-period, and --retries parameters
- **Custom health scripts**: Executable scripts that perform application-specific health checks
- **Container monitoring**: Docker automatically restarts unhealthy containers when configured
- **docker inspect**: Shows health status information for running containers

</details>

---

#### 16. Use environment variables in a Dockerfile

* Create a Dockerfile that uses environment variables for configuration and demonstrates their usage.

    #### **Scenario:** 
    * Your application needs different configurations for development, staging, and production environments. 
    * Environment variables allow you to build one image that can be configured differently at runtime without code changes.

**Hint:** Use `ENV` instruction in Dockerfile and override with `docker run -e`

<details markdown="1">
<summary>Solution</summary>

**Solution:**
Create a `Dockerfile.env`:
```Dockerfile
FROM alpine:latest

# Set environment variables
ENV GREETING="Hello" \
    NAME="Docker User"

# Use environment variables in a script
RUN echo '#!/bin/sh' > /greet.sh && \
    echo 'echo "$GREETING, $NAME!"' >> /greet.sh && \
    chmod +x /greet.sh

# Run the script
CMD ["/greet.sh"]
```

Build and test:
```sh
# Build the image
docker build -f Dockerfile.env -t env-example .

# Run with default environment variables
docker run --rm env-example

# Run with overridden environment variables
docker run --rm -e GREETING="Hi" -e NAME="Developer" env-example

# Clean up
docker rmi env-example
rm Dockerfile.env
```

**Explanation:**

- **ENV instruction**: Sets environment variables in the Docker image
- **docker run -e**: Overrides environment variables at runtime
- **Configuration flexibility**: Environment variables allow runtime customization
- **Build-time vs runtime**: ENV sets defaults, -e overrides them when running containers
- **Security considerations**: Avoid hardcoding sensitive values in images

</details>

---

#### 17. Create a Dockerfile that runs as a non-root user

* Create a Dockerfile that creates a non-root user and runs the container as that user for security.

    #### **Scenario:** 
    * Security best practices require running containers as non-root users to minimize the impact of potential vulnerabilities. 
    * This is especially important in multi-tenant environments where container escapes could compromise the host system.

**Hint:** Use `RUN` to create user/group, `USER` instruction, and proper file permissions

<details markdown="1">
<summary>Solution</summary>

**Solution:**
Create a `Dockerfile.nonroot`:
```Dockerfile
FROM alpine:latest

# Create a non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Create a directory for the app
RUN mkdir /app && chown appuser:appgroup /app

# Switch to non-root user
USER appuser

# Set working directory
WORKDIR /app

# Create a simple script
RUN echo '#!/bin/sh' > /app/hello.sh && \
    echo 'echo "Running as $(whoami) with UID $(id -u)"' >> /app/hello.sh && \
    chmod +x /app/hello.sh

# Run as non-root user
CMD ["/app/hello.sh"]
```

Build and test:
```sh
# Build the image
docker build -f Dockerfile.nonroot -t nonroot-example .

# Run the container
docker run --rm nonroot-example

# Verify it's running as non-root (should show appuser, not root)
# Clean up
docker rmi nonroot-example
rm Dockerfile.nonroot
```

**Explanation:**

- **USER instruction**: Specifies the user to run subsequent commands and the final container
- **Non-root security**: Running as non-root user reduces attack surface and follows security best practices
- **User creation**: RUN commands to create users/groups before switching with USER
- **File permissions**: Proper ownership and permissions for non-root users
- **whoami and id**: Commands to verify which user the container is running as

</details>

---

#### 18. Use docker exec to debug a running container

* Start a container, use docker exec to enter it and inspect its state, then make changes.

    #### **Scenario:** 
    * Your production container is behaving unexpectedly, and you need to investigate without stopping the service. 
    * Using docker exec, you can attach to the running container, examine its state, and make temporary fixes while maintaining service availability.

**Hint:** Use `docker exec -it` for interactive shell access and `docker exec` for running commands

<details markdown="1">
<summary>Solution</summary>

**Solution:**
```sh
# Run a container
docker run -d --name debug-container alpine sleep 1000

# Check what's running
docker ps

# Execute a command in the running container
docker exec debug-container echo "Hello from inside the container"

# Start an interactive shell in the container
docker exec -it debug-container sh

# Inside the shell, you can:
# - Check processes: ps aux
# - Check filesystem: ls -la /
# - Check environment: env
# - Create files: echo "test" > /tmp/test.txt
# - Exit with Ctrl+D

# After exiting, check if changes persist
docker exec debug-container cat /tmp/test.txt

# Check container logs
docker logs debug-container

# Inspect container details
docker inspect debug-container | grep -A 10 "State"

# Clean up
docker stop debug-container
docker rm debug-container
```

**Explanation:**

- **docker exec**: Runs commands inside running containers without stopping them
- **docker exec -it**: Interactive terminal access to running containers for debugging
- **Container inspection**: Examining processes, filesystem, and environment inside containers
- **Live debugging**: Essential for troubleshooting running applications
- **Non-destructive testing**: Debug without affecting the container's state

</details>