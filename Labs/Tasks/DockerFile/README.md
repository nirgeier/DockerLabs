![DockerLabs Banner](../../assets/images/docker-logos.png)

---

# Dockerfile Tasks

- Hands-on Dockerfile exercises covering essential image building concepts, optimization techniques, and advanced containerization patterns.
- Each task includes a clear scenario description, helpful hints, and detailed solutions with explanations.
- Practice these tasks to master Dockerfile best practices, multi-stage builds, and image optimization.

---

#### Table of Contents

- [01. Basic Dockerfile Structure](#01-basic-dockerfile-structure)
- [02. Build Arguments and Environment Variables](#02-build-arguments-and-environment-variables)
- [03. Multi-Stage Build Basics](#03-multi-stage-build-basics)
- [04. Working Directory and File Operations](#04-working-directory-and-file-operations)
- [05. User Management and Security](#05-user-management-and-security)
- [06. Port Exposure and Networking](#06-port-exposure-and-networking)
- [07. Health Checks Implementation](#07-health-checks-implementation)
- [08. Labels and Metadata](#08-labels-and-metadata)
- [09. Build Context Optimization](#09-build-context-optimization)
- [10. Multi-Stage Build with Go Application](#10-multi-stage-build-with-go-application)
- [11. Python Application Containerization](#11-python-application-containerization)
- [12. Image Layer Caching Optimization](#12-image-layer-caching-optimization)
- [13. Build Secrets Management](#13-build-secrets-management)
- [14. Advanced Multi-Stage Build Patterns](#14-advanced-multi-stage-build-patterns)
- [15. Dockerfile Security Best Practices](#15-dockerfile-security-best-practices)
- [16. BuildKit Advanced Features](#16-buildkit-advanced-features)
- [17. Image Size Optimization](#17-image-size-optimization)
- [18. Complex Application Stack](#18-complex-application-stack)

---

#### 01. Basic Dockerfile Structure

* Create a simple Dockerfile that builds a basic web server using Nginx to serve static HTML content.

    #### **Scenario:** 
    * As a web developer, you need to quickly containerize a static website for local development and testing before deploying to production. 
    * Using a basic Dockerfile allows you to package your HTML, CSS, and JavaScript files into a portable container that can run consistently across different environments.

    #### **Resources:**
    * Create `index.html`:
      ```html
      <!DOCTYPE html>
      <html>
      <head>
          <title>My First Docker App</title>
      </head>
      <body>
          <h1>Hello from Docker!</h1>
          <p>This page is served from a container.</p>
      </body>
      </html>
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use `FROM`, `COPY`, `EXPOSE`, and `CMD` instructions

<details markdown="1">
<summary>Solution</summary>

**Solution:**

Create the following files:

**index.html**
```html
<!DOCTYPE html>
<html>
<head>
    <title>My First Docker App</title>
</head>
<body>
    <h1>Hello from Docker!</h1>
    <p>This page is served from a container.</p>
</body>
</html>
```

**Dockerfile**
```dockerfile
FROM nginx:alpine

# Copy custom HTML file to nginx default location
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Use default nginx command
CMD ["nginx", "-g", "daemon off;"]
```

**Build and run:**
```bash
# Build the image
docker build -t basic-nginx .

# Run the container
docker run -d -p 8080:80 --name basic-web basic-nginx

# Test
curl http://localhost:8080
```

**Explanation:**

- **FROM**: Specifies the base image to build upon
- **COPY**: Copies files from build context to the image
- **EXPOSE**: Documents which ports the container listens on
- **CMD**: Specifies the command to run when the container starts
- **nginx:alpine**: Lightweight base image for web serving

</details>

---

#### 02. Build Arguments and Environment Variables

* Build a configurable Node.js application that accepts build-time arguments for version and port configuration.

    #### **Scenario:** 
    * You're deploying the same application across multiple environments (development, staging, production) with different configurations. 
    * Build arguments allow you to customize the image at build time, while environment variables enable runtime configuration flexibility.

    #### **Resources:**
    * Create `app.js`:
      ```javascript
      const http = require('http');
      const port = process.env.PORT || 3000;
      const version = process.env.VERSION || '1.0.0';
      
      const server = http.createServer((req, res) => {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end(`App Version: ${version}, Running on port: ${port}\n`);
      });
      
      server.listen(port, '0.0.0.0', () => {
        console.log(`Server running on port ${port}`);
      });
      ```
    * Create `package.json`:
      ```json
      {
        "name": "configurable-app",
        "version": "1.0.0",
        "main": "app.js",
        "scripts": {
          "start": "node app.js"
        }
      }
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use `ARG` for build-time variables and `ENV` for runtime environment variables

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**app.js**
```javascript
const http = require('http');
const port = process.env.PORT || 3000;
const version = process.env.VERSION || '1.0.0';

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(`App Version: ${version}, Running on port: ${port}\n`);
});

server.listen(port, '0.0.0.0', () => {
  console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
  "name": "configurable-app",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  }
}
```

**Dockerfile**
```dockerfile
FROM node:18-alpine

# Build-time argument
ARG APP_VERSION=1.0.0

# Set environment variable from build arg
ENV VERSION=${APP_VERSION}
ENV PORT=3000

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY app.js ./

# Expose the port
EXPOSE ${PORT}

# Run the application
CMD ["npm", "start"]
```

**Build and test:**
```bash
# Build with custom version
docker build --build-arg APP_VERSION=2.1.0 -t configurable-app .

# Run the container
docker run -d -p 3000:3000 --name config-app configurable-app

# Test
curl http://localhost:3000
```

**Explanation:**

- **ARG**: Defines build-time variables that can be passed with --build-arg
- **ENV**: Sets environment variables that persist in the final image
- **Build-time vs runtime**: ARG is only available during build, ENV persists in containers
- **Default values**: Both ARG and ENV can have fallback values
- **EXPOSE with variables**: Can use environment variables for port exposure

</details>

---

#### 03. Multi-Stage Build Basics

* Create a multi-stage Dockerfile that compiles a C application in one stage and copies the binary to a minimal runtime image.

    #### **Scenario:** 
    * You're building a compiled application that requires heavy build tools and dependencies, but you want to minimize the production image size and attack surface. 
    * Multi-stage builds allow you to use a full development environment for compilation, then copy only the resulting binary to a minimal runtime image.

    #### **Resources:**
    * Create `hello.c`:
      ```c
      #include <stdio.h>
      
      int main() {
          printf("Hello from multi-stage build!\n");
          return 0;
      }
      ```
    * Use this basic `Dockerfile` snippet to get started:
      ```dockerfile

      # Build stage
      FROM gcc:9-alpine AS builder

      WORKDIR /src

      # Copy source code
      COPY hello.c .

      # Compile the application
      RUN gcc -o hello hello.c
      ```

**Hint:** Use `FROM ... AS` to define stages and `COPY --from=` to transfer artifacts

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**hello.c**
```c
#include <stdio.h>

int main() {
    printf("Hello from multi-stage build!\n");
    return 0;
}
```

**Dockerfile**
```dockerfile
# Build stage
FROM gcc:9-alpine AS builder

WORKDIR /src

# Copy source code
COPY hello.c .

# Compile the application
RUN gcc -o hello hello.c

# Runtime stage
FROM alpine:latest

# Copy binary from build stage
COPY --from=builder /src/hello /usr/local/bin/hello

# Run the application
CMD ["hello"]
```

**Build and run:**
```bash
# Build the multi-stage image
docker build -t multi-stage-hello .

# Run the container
docker run --rm multi-stage-hello
```

**Expected output:**
```
Hello from multi-stage build!
```

**Explanation:**

- **Multi-stage builds**: Separate build dependencies from runtime image
- **AS builder**: Names the build stage for reference
- **COPY --from=builder**: Copies files from the named build stage
- **Smaller final images**: Only runtime dependencies in final image
- **Build optimization**: No need for GCC in the final running container

</details>

---

#### 04. Working Directory and File Operations

* Create a Dockerfile that demonstrates proper working directory management and file operations for a Python application.

    #### **Scenario:** 
    * You're containerizing a Python application with multiple source files, configuration files, and dependencies that need to be organized properly within the container. 
    * Proper working directory management ensures that your application runs from the correct location and can access its files reliably.

    #### **Resources:**
    * Create `app.py`:
      ```python
      #!/usr/bin/env python3
      print("Hello from Python application!")
      print("Current working directory:", __file__)
      ```
    * Create `requirements.txt`:
      ```text
      # No dependencies for this simple example
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use `WORKDIR`, `COPY`, `ADD`, and proper file permissions

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**app.py**
```python
#!/usr/bin/env python3
print("Hello from Python application!")
print("Current working directory:", __file__)
```

**requirements.txt**
```text
# No dependencies for this simple example
```

**Dockerfile**
```dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install dependencies (if any)
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Make script executable
RUN chmod +x app.py

# Set working directory again (can be set multiple times)
WORKDIR /app

# Run the application
CMD ["python", "app.py"]
```

**Build and run:**
```bash
docker build -t workdir-demo .
docker run --rm workdir-demo
```

**Explanation:**

- **WORKDIR**: Sets the working directory for subsequent instructions
- **Layer optimization**: Copy requirements first for better Docker layer caching
- **File permissions**: Use RUN chmod to set executable permissions
- **Working directory persistence**: Affects COPY, RUN, and CMD instructions
- **Absolute vs relative paths**: WORKDIR helps avoid full path specifications

</details>

---

#### 05. User Management and Security

* Create a Dockerfile that runs as a non-root user for security, demonstrating proper user creation and permission management.

    #### **Scenario:** 
    * Security auditors require that your production containers don't run as root user to minimize potential security vulnerabilities. 
    * Implementing non-root user execution ensures that even if an attacker compromises your application, they have limited system access.

    #### **Resources:**
    * Create `app.py`:
      ```python
      #!/usr/bin/env python3
      import os
      print(f"Running as user: {os.getuid()}")
      print(f"Username: {os.getenv('USER', 'unknown')}")
      print("Application is running securely!")
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use `RUN` to create users, `USER` to switch, and proper file ownership

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**app.py**
```python
#!/usr/bin/env python3
import os
print(f"Running as user: {os.getuid()}")
print(f"Username: {os.getenv('USER', 'unknown')}")
print("Application is running securely!")
```

**Dockerfile**
```dockerfile
FROM python:3.9-slim

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy application files
COPY app.py .

# Change ownership of the app directory
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Run the application
CMD ["python", "app.py"]
```

**Build and run:**
```bash
docker build -t secure-app .
docker run --rm secure-app
```

**Expected output:**
```
Running as user: 1000
Username: appuser
Application is running securely!
```

**Explanation:**

- **Non-root security**: Running as non-root user reduces security risks
- **groupadd/useradd**: Creates system users and groups
- **chown**: Changes file ownership to the application user
- **USER instruction**: Switches the user context for subsequent commands
- **Principle of least privilege**: Application runs with minimal required permissions

</details>

---

#### 06. Port Exposure and Networking

* Create a Dockerfile for a web application that properly exposes ports and demonstrates networking concepts.

    #### **Scenario:** 
    * You're deploying a web service that needs to accept HTTP requests from external clients while maintaining proper network isolation. 
    * Correct port exposure ensures your application is accessible to other services and clients while documenting the intended network interface.

    #### **Resources:**
    * Create `server.js`:
      ```javascript
      const http = require('http');
      
      const server = http.createServer((req, res) => {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end(`Hello from container!\nRequest from: ${req.connection.remoteAddress}\n`);
      });
      
      const port = process.env.PORT || 8080;
      server.listen(port, '0.0.0.0', () => {
        console.log(`Server listening on port ${port}`);
      });
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use `EXPOSE` for documentation and port mapping, understand the difference between exposing and publishing ports

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**server.js**
```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(`Hello from container!\nRequest from: ${req.connection.remoteAddress}\n`);
});

const port = process.env.PORT || 8080;
server.listen(port, '0.0.0.0', () => {
  console.log(`Server listening on port ${port}`);
});
```

**Dockerfile**
```dockerfile
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application
COPY server.js .

# Expose port (documentation)
EXPOSE 8080

# Environment variable for port
ENV PORT=8080

# Run the server
CMD ["node", "server.js"]
```

**Build and test:**
```bash
docker build -t networking-demo .

# Run with port mapping
docker run -d -p 8080:8080 --name net-demo networking-demo

# Test from host
curl http://localhost:8080

# Test from another container
docker run --rm --network container:net-demo alpine wget -qO- http://localhost:8080
```

**Explanation:**

- **EXPOSE**: Documents which ports the container listens on (metadata only)
- **Port mapping**: `-p` flag maps host port to container port
- **0.0.0.0 binding**: Allows connections from outside the container
- **Container networking**: Containers can communicate via exposed ports
- **Environment variables**: Configure ports dynamically

</details>

---

#### 07. Health Checks Implementation

* Implement health checks in a Dockerfile to monitor container health and enable automatic restarts.

    #### **Scenario:** 
    * Your production application needs to automatically recover from failures without manual intervention. 
    * Health checks allow the container orchestrator to detect when your application becomes unresponsive and automatically restart the container to maintain service availability.

    #### **Resources:**
    * Create `healthcheck.sh`:
      ```bash
      #!/bin/sh
      # Health check script
      curl -f http://localhost:8080/health || exit 1
      ```
    * Create `server.js`:
      ```javascript
      const http = require('http');
      
      const server = http.createServer((req, res) => {
        if (req.url === '/health') {
          res.writeHead(200, {'Content-Type': 'text/plain'});
          res.end('OK');
        } else {
          res.writeHead(200, {'Content-Type': 'text/plain'});
          res.end('Hello World!\n');
        }
      });
      
      server.listen(8080, '0.0.0.0', () => {
        console.log('Server running on port 8080');
      });
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use `HEALTHCHECK` instruction with appropriate intervals, timeouts, and retry logic

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**healthcheck.sh**
```bash
#!/bin/sh
# Health check script
curl -f http://localhost:8080/health || exit 1
```

**server.js**
```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('OK');
  } else {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello World!\n');
  }
});

server.listen(8080, '0.0.0.0', () => {
  console.log('Server running on port 8080');
});
```

**Dockerfile**
```dockerfile
FROM node:18-alpine

# Install curl for health checks
RUN apk add --no-cache curl

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY server.js .
COPY healthcheck.sh .

# Make health check script executable
RUN chmod +x healthcheck.sh

# Expose port
EXPOSE 8080

# Health check configuration
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ./healthcheck.sh

CMD ["node", "server.js"]
```

**Build and test:**
```bash
docker build -t healthcheck-demo .

# Run the container
docker run -d -p 8080:8080 --name health-demo healthcheck-demo

# Check health status
docker ps
docker inspect health-demo | grep -A 10 "Health"
```

**Explanation:**

- **HEALTHCHECK**: Defines how Docker determines container health
- **--interval**: How often to run the health check
- **--timeout**: Maximum time for health check to complete
- **--start-period**: Grace period before health checks begin
- **--retries**: Number of consecutive failures before marking unhealthy
- **Automatic restarts**: Docker can restart unhealthy containers

</details>

---

#### 08. Labels and Metadata

* Add comprehensive labels to a Dockerfile to provide metadata about the image, maintainer, and build information.

    #### **Scenario:** 
    * Your organization needs to track image versions, maintainers, and build information for compliance and operational purposes. 
    * Labels provide structured metadata that can be inspected and used by automated tools for inventory management, security scanning, and deployment decisions.

    #### **Resources:**
    * Create `nginx.conf`:
      ```nginx
      events {
          worker_connections 1024;
      }
      
      http {
          server {
              listen 80;
              server_name localhost;
      
              location / {
                  root /usr/share/nginx/html;
                  index index.html;
              }
      
              location /health {
                  access_log off;
                  return 200 "healthy\n";
                  add_header Content-Type text/plain;
              }
          }
      }
      ```
    * Create `index.html`:
      ```html
      <!DOCTYPE html>
      <html>
      <head><title>Labeled Image</title></head>
      <body><h1>This image has comprehensive labels!</h1></body>
      </html>
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use `LABEL` instruction to add key-value metadata that can be inspected with `docker inspect`

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Dockerfile**
```dockerfile
FROM nginx:alpine

# Image metadata labels
LABEL maintainer="DockerLabs Team <team@dockerlabs.com>" \
      version="1.0.0" \
      description="Nginx web server with custom configuration" \
      build_date="2024-01-01" \
      vcs_ref="abc123def" \
      vcs_url="https://github.com/dockerlabs/web-server" \
      vendor="DockerLabs" \
      license="MIT"

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

**nginx.conf**
```nginx
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

**index.html**
```html
<!DOCTYPE html>
<html>
<head><title>Labeled Image</title></head>
<body><h1>This image has comprehensive labels!</h1></body>
</html>
```

**Build and inspect:**
```bash
docker build -t labeled-nginx .

# Inspect labels
docker inspect labeled-nginx | grep -A 20 "Labels"

# Run the container
docker run -d -p 8080:80 labeled-nginx
```

**Explanation:**

- **LABEL**: Adds metadata to images as key-value pairs
- **Maintainer info**: Contact information for image support
- **Version tracking**: Build version and date information
- **Source control**: Git commit and repository information
- **Licensing**: Legal information about the image
- **Inspection**: Labels can be viewed with `docker inspect`

</details>

---

#### 09. Build Context Optimization

* Optimize the build context by using .dockerignore to exclude unnecessary files and improve build performance.

    #### **Scenario:** 
    * Your application repository contains large files, dependencies, and temporary files that slow down Docker builds and increase build context size. 
    * Optimizing the build context with .dockerignore improves build performance, reduces network transfer, and prevents sensitive files from being included in images.

    #### **Resources:**
    * Create `.dockerignore`:
      ```
      # Node modules (will be installed in container)
      node_modules
      npm-debug.log*
      
      # Git repository
      .git
      .gitignore
      
      # Environment files
      .env
      .env.local
      
      # Logs and temporary files
      logs
      *.log
      temp/
      *.tmp
      
      # IDE files
      .vscode
      .idea
      *.swp
      *.swo
      
      # OS files
      .DS_Store
      Thumbs.db
      
      # Documentation (not needed for build)
      README.md
      docs/
      
      # Test files (if not running tests in container)
      test/
      *.test.js
      ```
    * Create `app.js`:
      ```javascript
      const http = require('http');
      
      const server = http.createServer((req, res) => {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end('Optimized build context!\n');
      });
      
      server.listen(3000, '0.0.0.0', () => {
        console.log('Server running on port 3000');
      });
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Create a `.dockerignore` file to exclude files that aren't needed in the build context

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Project structure:**
```
my-app/
├── Dockerfile
├── .dockerignore
├── package.json
├── app.js
├── README.md
├── .git/
├── node_modules/
├── .env
├── logs/
└── temp/
```

**.dockerignore**
```
# Node modules (will be installed in container)
node_modules
npm-debug.log*

# Git repository
.git
.gitignore

# Environment files
.env
.env.local

# Logs and temporary files
logs
*.log
temp/
*.tmp

# IDE files
.vscode
.idea
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Documentation (not needed for build)
README.md
docs/

# Test files (if not running tests in container)
test/
*.test.js
```

**app.js**
```javascript
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Optimized build context!\n');
});

server.listen(3000, '0.0.0.0', () => {
  console.log('Server running on port 3000');
});
```

**Dockerfile**
```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code (excluding .dockerignore files)
COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

**Build comparison:**
```bash
# Time the build with .dockerignore
time docker build -t optimized-app .

# Compare build context size
docker build --no-cache --progress=plain -t optimized-app . 2>&1 | grep "Sending build context"
```

**Explanation:**

- **.dockerignore**: Excludes files from build context to improve performance
- **Build context**: All files in the directory are sent to the Docker daemon
- **Performance**: Smaller context means faster builds and less network transfer
- **Security**: Prevents sensitive files from being included in images
- **Caching**: Better layer caching when unnecessary files aren't included

</details>

---

#### 10. Multi-Stage Build with Go Application

* Create an optimized multi-stage Dockerfile for a Go web application that compiles in one stage and runs in a minimal distroless image.

    #### **Scenario:** 
    * You're deploying a Go application to production where security and minimal image size are critical requirements. 
    * Using distroless base images with multi-stage builds eliminates unnecessary packages and shell access, significantly reducing the attack surface while maintaining functionality.

    #### **Resources:**
    * Create `main.go`:
      ```go
      package main
      
      import (
          "fmt"
          "log"
          "net/http"
      )
      
      func handler(w http.ResponseWriter, r *http.Request) {
          fmt.Fprintf(w, "Hello from Go multi-stage build!\n")
      }
      
      func main() {
          http.HandleFunc("/", handler)
          log.Println("Server starting on :8080")
          log.Fatal(http.ListenAndServe(":8080", nil))
      }
      ```
    * Create `go.mod`:
      ```go
      module github.com/dockerlabs/go-app
      
      go 1.21
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use multi-stage builds to separate compilation from runtime, and use distroless base images for security

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**main.go**
```go
package main

import (
    "fmt"
    "log"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hello from Go multi-stage build!\n")
}

func main() {
    http.HandleFunc("/", handler)
    log.Println("Server starting on :8080")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

**go.mod**
```go
module github.com/dockerlabs/go-app

go 1.21
```

**Dockerfile**
```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Runtime stage
FROM gcr.io/distroless/static-debian12

# Copy binary from build stage
COPY --from=builder /app/main /

# Expose port
EXPOSE 8080

# Run the binary
CMD ["/main"]
```

**Build and run:**
```bash
docker build -t go-multi-stage .
docker run -d -p 8080:8080 --name go-app go-multi-stage
curl http://localhost:8080
```

**Explanation:**

- **Multi-stage optimization**: Separate build and runtime environments
- **Distroless images**: Minimal images with no shell or package manager
- **Static compilation**: CGO_ENABLED=0 creates statically linked binaries
- **Security**: Smaller attack surface with minimal base images
- **Go optimization**: -a flag forces rebuild, -installsuffix cgo avoids caching issues

</details>

---

#### 11. Python Application Containerization

* Containerize a Python Flask application with proper dependency management and optimization.

    #### **Scenario:** 
    * You're deploying a Python web application that needs to run consistently across development, testing, and production environments. 
    * Proper containerization ensures that all dependencies are correctly managed and the application runs with the same configuration regardless of the host system.

    #### **Resources:**
    * Create `app.py`:
      ```python
      from flask import Flask
      import os
      
      app = Flask(__name__)
      
      @app.route('/')
      def hello():
          return f'Hello from Python container! Version: {os.getenv("APP_VERSION", "1.0.0")}\n'
      
      if __name__ == '__main__':
          app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)))
      ```
    * Create `requirements.txt`:
      ```text
      Flask==3.0.0
      gunicorn==21.2.0
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use virtual environments, multi-stage builds, and proper Python packaging

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**app.py**
```python
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f'Hello from Python container! Version: {os.getenv("APP_VERSION", "1.0.0")}\n'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', 5000)))
```

**requirements.txt**
```text
Flask==3.0.0
gunicorn==21.2.0
```

**Dockerfile**
```dockerfile
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_VERSION=1.0.0 \
    PORT=5000

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app.py .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

**Build and run:**
```bash
docker build -t python-flask .
docker run -d -p 5000:5000 python-flask
curl http://localhost:5000
```

**Explanation:**

- **Python optimization**: PYTHONDONTWRITEBYTECODE prevents .pyc files
- **Dependency management**: Separate requirements copying for better caching
- **Gunicorn**: Production WSGI server instead of development server
- **System dependencies**: Install build tools only when needed
- **Non-root user**: Security best practice for Python applications

</details>

---

#### 12. Image Layer Caching Optimization

* Optimize Dockerfile layer caching by ordering instructions properly and combining RUN commands.

    #### **Scenario:** 
    * Your development team frequently rebuilds Docker images during development, and slow build times are impacting productivity. 
    * Optimizing layer caching ensures that only changed parts of the application trigger rebuilds, significantly reducing build times and improving the development workflow.

**Hint:** Order COPY commands from least to most frequently changing, combine RUN commands, and use multi-stage builds

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Dockerfile (Optimized)**
```dockerfile
FROM ubuntu:20.04

# Update and install system packages in one layer
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files first (rarely change)
COPY requirements.txt package.json ./

# Install dependencies (changes less frequently)
RUN pip install -r requirements.txt && \
    npm install

# Copy application code (changes most frequently)
COPY . .

# Set permissions and create directories in one command
RUN chmod +x scripts/* && \
    mkdir -p /app/logs /app/data && \
    chown -R www-data:www-data /app

EXPOSE 8080

CMD ["./start.sh"]
```

**Dockerfile (Poor - for comparison)**
```dockerfile
FROM ubuntu:20.04

# Poor: Update in separate layer
RUN apt-get update

# Poor: Install packages one by one
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git

# Poor: Copy application code before dependencies
COPY . .

# Poor: Install dependencies after copying code
RUN pip install -r requirements.txt
RUN npm install

EXPOSE 8080
CMD ["./start.sh"]
```

**Build comparison:**
```bash
# Build optimized version
docker build -f Dockerfile.optimized -t optimized-image .

# Make small change to app code
echo "# comment" >> app.py

# Rebuild - notice how many layers are cached
docker build -f Dockerfile.optimized -t optimized-image .

# Compare with poor version
docker build -f Dockerfile.poor -t poor-image .
echo "# comment" >> app.py
docker build -f Dockerfile.poor -t poor-image .
```

**Explanation:**

- **Layer ordering**: Least changing instructions first (system packages, dependencies)
- **RUN command combining**: Single RUN for related operations to reduce layers
- **Dependency copying**: Copy requirements before code for better caching
- **Cache invalidation**: Changing code doesn't invalidate dependency layers
- **Cleanup**: Remove package manager cache to reduce image size

</details>

---

#### 13. Build Secrets Management

* Use BuildKit secrets to handle sensitive information during the build process without embedding them in the final image.

    #### **Scenario:** 
    * Your build process requires access to sensitive information like API keys, database credentials, or authentication tokens for private repositories. 
    * BuildKit secrets allow you to use these credentials during the build process without embedding them in the final image layers, maintaining security compliance.

**Hint:** Use `--secret` flag with BuildKit and `RUN --mount=type=secret` to access secrets during build

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Dockerfile**
```dockerfile
# syntax=docker/dockerfile:1

FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source
COPY . .

# Use secret during build (e.g., for API keys, tokens)
RUN --mount=type=secret,id=npm_token \
    echo "//registry.npmjs.org/:_authToken=$(cat /run/secrets/npm_token)" > ~/.npmrc && \
    npm publish

FROM node:18-alpine AS runtime

WORKDIR /app

# Copy from builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/src ./src

EXPOSE 3000

CMD ["npm", "start"]
```

**Build with secrets:**
```bash
# Create a secret file (never commit this)
echo "your-npm-token-here" > npm_token.txt

# Build with secret
DOCKER_BUILDKIT=1 docker build \
  --secret id=npm_token,src=npm_token.txt \
  -t secret-build .

# Clean up
rm npm_token.txt
```

**Alternative approach with environment variables:**
```dockerfile
FROM node:18-alpine

# Use ARG for build-time secrets (less secure)
ARG NPM_TOKEN

RUN echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

# Rest of the build...
```

**Explanation:**

- **BuildKit secrets**: Secure way to pass sensitive data during build
- **--mount=type=secret**: Mounts secret files into build container
- **Runtime security**: Secrets not embedded in final image layers
- **Environment variables**: Less secure alternative for build-time secrets
- **Secret management**: Proper handling of tokens, keys, and credentials

</details>

---

#### 14. Advanced Multi-Stage Build Patterns

* Implement advanced multi-stage build patterns including shared base stages and conditional builds.

    #### **Scenario:** 
    * You're managing complex applications that need different configurations for development, testing, and production environments. 
    * Advanced multi-stage patterns allow you to create optimized images for each environment while sharing common build steps, improving both build efficiency and maintainability.

    #### **Resources:**
    * Create `nginx.production.conf`:
      ```nginx
      events { worker_connections 1024; }
      http {
          server {
              listen 80;
              root /usr/share/nginx/html;
              index index.html;
              location / {
                  try_files $uri $uri/ /index.html;
              }
          }
      }
      ```
    * Create `nginx.staging.conf`:
      ```nginx
      events { worker_connections 1024; }
      http {
          server {
              listen 80;
              root /usr/share/nginx/html;
              index index.html;
              add_header X-Environment staging;
              location / {
                  try_files $uri $uri/ /index.html;
              }
          }
      }
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use shared base stages, target builds, and conditional logic with build arguments

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Dockerfile**
```dockerfile
# syntax=docker/dockerfile:1

# Shared base stage
FROM node:18-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci

# Development stage
FROM base AS development
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

# Build stage
FROM base AS build
COPY . .
RUN npm run build

# Test stage
FROM build AS test
RUN npm run test

# Production stage
FROM nginx:alpine AS production
ARG BUILD_ENV=production

# Copy built assets from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy nginx config based on environment
COPY nginx.${BUILD_ENV}.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

**nginx.production.conf**
```nginx
events { worker_connections 1024; }
http {
    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
```

**nginx.staging.conf**
```nginx
events { worker_connections 1024; }
http {
    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;
        add_header X-Environment staging;
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
```

**Build different targets:**
```bash
# Build for development
docker build --target development -t myapp:dev .

# Build for production
docker build --target production -t myapp:prod .

# Build for staging
docker build --build-arg BUILD_ENV=staging --target production -t myapp:staging .

# Run tests
docker build --target test -t myapp:test .
```

**Explanation:**

- **Shared base stages**: Common setup shared across multiple targets
- **Target builds**: Build specific stages with --target flag
- **Conditional configuration**: Build args to customize builds
- **Development workflow**: Separate dev, test, and production stages
- **Multi-environment**: Different configurations for staging/production

</details>

---

#### 15. Dockerfile Security Best Practices

* Implement security best practices in a Dockerfile including non-root users, minimal attack surface, and proper secret handling.

    #### **Scenario:** 
    * Your organization requires container images to meet strict security standards for production deployment. 
    * Implementing security best practices ensures that your containers minimize vulnerabilities, follow the principle of least privilege, and protect sensitive information throughout the build and runtime lifecycle.

    #### **Resources:**
    * Create `app.py`:
      ```python
      from flask import Flask
      import os
      
      app = Flask(__name__)
      
      @app.route('/')
      def hello():
          return f'Running as user: {os.getuid()}\n'
      
      @app.route('/health')
      def health():
          return 'OK'
      
      if __name__ == '__main__':
          port = int(os.getenv('PORT', 8000))
          app.run(host='0.0.0.0', port=port)
      ```
    * Create `requirements.txt`:
      ```text
      Flask==3.0.0
      ```
    * Create `Dockerfile` (see solution for content)

**Hint:** Use non-root users, minimal base images, update packages, avoid secrets in images, and implement proper file permissions

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Dockerfile**
```dockerfile
# syntax=docker/dockerfile:1

# Use specific, minimal base image
FROM python:3.11-slim

# Update packages and install security updates
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        curl \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean

# Create non-root user early
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory with proper permissions
WORKDIR /app
RUN chown appuser:appuser /app

# Copy only necessary files
COPY --chown=appuser:appuser requirements.txt .

# Install dependencies as root, then switch user
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application code with correct ownership
COPY --chown=appuser:appuser app.py .

# Switch to non-root user
USER appuser

# Don't run as root
# Don't expose sensitive ports unnecessarily
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Use exec form of CMD
CMD ["python", "app.py"]
```

**app.py**
```python
from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return f'Running as user: {os.getuid()}\n'

@app.route('/health')
def health():
    return 'OK'

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    app.run(host='0.0.0.0', port=port)
```

**requirements.txt**
```text
Flask==3.0.0
```

**Security scanning:**
```bash
# Build the secure image
docker build -t secure-app .

# Scan for vulnerabilities (requires security scanner)
# docker scan secure-app

# Run security checks
docker run --rm secure-app whoami
docker run --rm secure-app id
```

**Explanation:**

- **Non-root user**: Application runs with limited privileges
- **Minimal base images**: Smaller attack surface
- **Package updates**: Install security patches
- **File permissions**: Proper ownership and access controls
- **No secrets in image**: Sensitive data not embedded in layers
- **Health checks**: Monitor container health and security
- **Exec form CMD**: Proper signal handling

</details>

---

#### 16. BuildKit Advanced Features

* Utilize advanced BuildKit features including mounts, cache mounts, and SSH forwarding for improved build performance and capabilities.

    #### **Scenario:** 
    * Your build process involves downloading large dependencies, accessing private repositories, and requires optimal caching for faster CI/CD pipelines. 
    * BuildKit advanced features provide sophisticated caching mechanisms and secure access methods that significantly improve build performance and reliability.

**Hint:** Use `--mount=type=cache`, `--mount=type=ssh`, and other BuildKit mount types

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Dockerfile**
```dockerfile
# syntax=docker/dockerfile:1

FROM golang:1.21-alpine AS builder

# Enable BuildKit
ENV DOCKER_BUILDKIT=1

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Cache mount for Go modules
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Copy source
COPY . .

# Cache mount for Go build cache
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binary
COPY --from=builder /app/main .

EXPOSE 8080

CMD ["./main"]
```

**Advanced Dockerfile with SSH:**
```dockerfile
FROM node:18-alpine

RUN apk add --no-cache openssh-client git

WORKDIR /app

# SSH mount for private repositories
RUN --mount=type=ssh \
    git clone git@github.com:private/repo.git .

# Cache mount for npm
RUN --mount=type=cache,target=/root/.npm \
    npm install

COPY . .

CMD ["npm", "start"]
```

**Build with BuildKit:**
```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with cache mounts
docker build -t buildkit-demo .

# Build with SSH access
docker build \
  --ssh default \
  -t ssh-build .

# Use build secrets
echo "secret-token" | docker build \
  --secret id=mysecret \
  -t secret-build .
```

**Explanation:**

- **Cache mounts**: Persistent cache between builds for faster subsequent builds
- **SSH mounts**: Access to private repositories during build
- **Secret mounts**: Secure handling of sensitive build-time data
- **BuildKit**: Modern build system with advanced features
- **Performance**: Faster builds through intelligent caching

</details>

---

#### 17. Image Size Optimization

* Optimize image size through various techniques including multi-stage builds, package cleanup, and efficient layer management.

    #### **Scenario:** 
    * Your production environment has limited storage and network bandwidth, and you need to minimize deployment times and storage costs. 
    * Image size optimization techniques reduce the attack surface, improve deployment speed, and lower infrastructure costs while maintaining full application functionality.

**Hint:** Use multi-stage builds, remove unnecessary packages, combine RUN commands, and use smaller base images

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Dockerfile (Optimized)**
```dockerfile
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go mod
COPY go.mod go.sum ./
RUN go mod download

# Copy source
COPY . .

# Build static binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -a -installsuffix cgo \
    -ldflags '-w -s' \
    -o main .

# Strip binary
RUN strip main

# Runtime stage - use scratch for minimal size
FROM scratch

# Copy CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary
COPY --from=builder /app/main /main

EXPOSE 8080

CMD ["/main"]
```

**Compare with unoptimized:**
```dockerfile
FROM golang:1.21-alpine

WORKDIR /app

COPY . .

RUN go build -o main .

CMD ["./main"]
```

**Size comparison:**
```bash
# Build optimized version
docker build -f Dockerfile.optimized -t optimized-app .

# Build unoptimized version
docker build -f Dockerfile.unoptimized -t unoptimized-app .

# Compare sizes
docker images | grep -E "(optimized|unoptimized)"

# Expected result: optimized image much smaller
```

**Additional optimization techniques:**
```dockerfile
# Use .dockerignore
# Combine RUN commands
# Remove package manager cache
# Use smaller base images
# Strip binaries
# Use scratch base for static binaries
```

**Explanation:**

- **Multi-stage builds**: Separate build and runtime environments
- **Scratch base**: Minimal possible image size for static binaries
- **Binary stripping**: Remove debug symbols to reduce size
- **Package cleanup**: Remove build dependencies from final image
- **Layer optimization**: Combine commands to reduce layer count

</details>

---

#### 18. Complex Application Stack

* Create a multi-service application stack with a web frontend, API backend, and database using Docker Compose and optimized Dockerfiles.

    #### **Scenario:** 
    * You're developing a full-stack web application with multiple interconnected services that need to work together seamlessly. 
    * Containerizing the entire stack ensures consistent deployment across development, testing, and production environments while maintaining service dependencies and network isolation.

    #### **Resources:**
    * Create project structure:
      ```
      complex-app/
      ├── docker-compose.yml
      ├── frontend/
      │   ├── Dockerfile
      │   ├── package.json
      │   └── src/
      ├── backend/
      │   ├── Dockerfile
      │   ├── requirements.txt
      │   └── app.py
      └── database/
          └── init.sql
      ```
    * Create `docker-compose.yml` (see solution for content)
    * Create `frontend/Dockerfile` (see solution for content)
    * Create `backend/Dockerfile` (see solution for content)

**Hint:** Create separate Dockerfiles for each service, use multi-stage builds, and coordinate with docker-compose.yml

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**Project structure:**
```
complex-app/
├── docker-compose.yml
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   └── src/
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
└── database/
    └── init.sql
```

**frontend/Dockerfile**
```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**backend/Dockerfile**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

**docker-compose.yml**
```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:80"
    depends_on:
      - backend

  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/app
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql

volumes:
  db_data:
```

**Build and run:**
```bash
# Build all services
docker-compose build

# Start the stack
docker-compose up -d

# Check services
docker-compose ps

# Test the application
curl http://localhost:3000
curl http://localhost:8000
```

**Explanation:**

- **Multi-service architecture**: Separate concerns with microservices
- **Service dependencies**: Proper startup ordering with depends_on
- **Optimized builds**: Multi-stage for frontend, minimal for backend
- **Environment configuration**: Runtime configuration through environment variables
- **Volume management**: Persistent database storage
- **Port mapping**: Proper service exposure and communication
