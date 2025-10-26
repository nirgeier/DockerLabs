![DockerLabs Banner](../../assets/images/docker-logos.png)

---

# Docker Compose Tasks

- Hands-on Docker Compose exercises covering multi-container application orchestration, service configuration, networking, and deployment patterns.
- Each task includes a clear scenario description, helpful hints, and detailed solutions with explanations.
- Practice these tasks to master Docker Compose for complex application stacks and microservices architectures.

---

#### Table of Contents

- [01. Basic Docker Compose Setup](#01-basic-docker-compose-setup)
- [02. Multi-Service Application](#02-multi-service-application)
- [03. Environment Variables and Configuration](#03-environment-variables-and-configuration)
- [04. Volumes and Data Persistence](#04-volumes-and-data-persistence)
- [05. Networking Between Services](#05-networking-between-services)
- [06. Health Checks and Dependencies](#06-health-checks-and-dependencies)
- [07. Scaling Services](#07-scaling-services)
- [08. Build Configuration](#08-build-configuration)
- [09. Override Files](#09-override-files)
- [10. Secrets Management](#10-secrets-management)
- [11. Logging Configuration](#11-logging-configuration)
- [12. Resource Limits](#12-resource-limits)
- [13. Profiles and Selective Services](#13-profiles-and-selective-services)
- [14. External Networks](#14-external-networks)
- [15. Custom Networks](#15-custom-networks)
- [16. Load Balancing](#16-load-balancing)
- [17. Multi-Stage Deployments](#17-multi-stage-deployments)
- [18. Production-Ready Stack](#18-production-ready-stack)
- [19. Basic YAML Anchors and References](#19-basic-yaml-anchors-and-references)
- [20. Merging Service Configurations](#20-merging-service-configurations)
- [21. Using Includes for Modular Compose Files](#21-using-includes-for-modular-compose-files)
- [22. Environment-Specific Fragments](#22-environment-specific-fragments)
- [23. Complex Fragment Hierarchies](#23-complex-fragment-hierarchies)
- [24. Fragment-Based Service Templates](#24-fragment-based-service-templates)

---

#### 01. Basic Docker Compose Setup

* Create a simple docker-compose.yml file to run a single web service with port mapping and volume mounting.

    #### **Scenario:**
    * As a developer, you need to quickly set up a development environment for a web application that requires consistent configuration across team members.
    * Docker Compose allows you to define and run multi-container applications with a single command, ensuring everyone uses the same setup.

    #### Resources:
    * `index.html` ➤ `/usr/share/nginx/html`
        ```html
        <!DOCTYPE html>
        <html>
        <head>
            <title>Docker Compose App</title>
        </head>
        <body>
            <h1>Hello from Docker Compose!</h1>
            <p>This page is served by a container managed by Docker Compose.</p>
        </body>
        </html>
        ```


**Hint:** Use `version`, `services`, `image`, `ports`, and `volumes` keys


<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

**Commands:**
```bash
# Start the services
docker-compose up -d

# Check running services
docker-compose ps

# View logs
docker-compose logs

# Stop and remove services
docker-compose down
```

**Explanation:**

- **version**: Specifies the Compose file format version
- **services**: Defines the containers to run
- **image**: Specifies the Docker image to use
- **ports**: Maps host ports to container ports
- **volumes**: Mounts host directories into containers
- **docker-compose up -d**: Starts services in detached mode
- **docker-compose down**: Stops and removes containers and networks

</details>

---

#### 02. Multi-Service Application

* Create a docker-compose.yml file that runs a web application with a database backend, demonstrating service communication.

    #### **Scenario:**
    * You're developing a full-stack application that requires both a web server and a database to work together.
    * Docker Compose enables you to define and manage multiple interconnected services that can communicate with each other securely.

    #### Resources:
    * `web/index.html` ➤ `/usr/share/nginx/html`
        ```html
        <!DOCTYPE html>
        <html>
        <head><title>Multi-Service App</title></head>
        <body>
            <h1>Web App with Database</h1>
            <p>Connected to PostgreSQL database via Docker Compose networking.</p>
        </body>
        </html>
        ```

**Hint:** Use `depends_on` for service dependencies and named volumes for data persistence

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html
    depends_on:
      - db
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

**web/index.html**
```html
<!DOCTYPE html>
<html>
<head><title>Multi-Service App</title></head>
<body>
    <h1>Web App with Database</h1>
    <p>Connected to PostgreSQL database via Docker Compose networking.</p>
</body>
</html>
```

**Commands:**
```bash
# Start all services
docker-compose up -d

# Check service connectivity
docker-compose exec web ping -c 2 db

# View database logs
docker-compose logs db

# Stop services
docker-compose down
```

**Explanation:**

- **depends_on**: Ensures services start in the correct order
- **environment**: Sets environment variables for service configuration
- **volumes**: Persists database data between container restarts
- **Service networking**: Services can communicate using service names as hostnames
- **docker-compose exec**: Runs commands in running service containers

</details>

---

#### 03. Environment Variables and Configuration

* Create a configurable application stack using environment variables and .env files for different deployment environments.

    #### **Scenario:**
    * Your application needs to run in multiple environments (development, staging, production) with different configurations like database credentials, ports, and feature flags.
    * Docker Compose allows you to manage environment-specific configurations using environment variables and .env files.

    #### Resources:
    * `.env` ➤ Environment configuration file
        ```
        APP_ENV=development
        WEB_PORT=8080
        DB_NAME=myapp
        DB_USER=user
        DB_PASSWORD=password
        ```
    * `web/index.html` ➤ `/usr/share/nginx/html`
        ```html
        <!DOCTYPE html>
        <html>
        <head><title>Configurable App</title></head>
        <body>
            <h1>Environment: ${ENV}</h1>
            <p>Configuration loaded from environment variables.</p>
        </body>
        </html>
        ```

**Hint:** Use `${VARIABLE_NAME}` syntax and .env files for configuration management

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-8080}:80"
    environment:
      - ENV=${APP_ENV:-development}
    volumes:
      - ./web:/usr/share/nginx/html
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

**.env**
```
APP_ENV=development
WEB_PORT=8080
DB_NAME=myapp
DB_USER=user
DB_PASSWORD=password
```

**web/index.html**
```html
<!DOCTYPE html>
<html>
<head><title>Configurable App</title></head>
<body>
    <h1>Environment: ${ENV}</h1>
    <p>Configuration loaded from environment variables.</p>
</body>
</html>
```

**Commands:**
```bash
# Start with default .env
docker-compose up -d

# Override environment variables
WEB_PORT=3000 docker-compose up -d

# Use different .env file
docker-compose --env-file .env.production up -d

# Check environment in container
docker-compose exec web env | grep ENV
```

**Explanation:**

- **${VARIABLE}**: Substitutes environment variable values
- **${VARIABLE:-default}**: Provides default values for missing variables
- **.env file**: Automatically loaded by docker-compose
- **--env-file**: Specify custom environment file
- **Runtime overrides**: Command-line variables override file values

</details>

---

#### 04. Volumes and Data Persistence

* Implement different types of volumes (named, bind mounts, tmpfs) for data persistence and performance optimization.

    #### **Scenario:**
    * Your application stack requires different data persistence strategies - some data needs to persist across container restarts, some needs high performance, and some should be temporary.
    * Docker Compose provides flexible volume management to handle various data persistence requirements.

**Hint:** Use named volumes, bind mounts, and tmpfs for different data persistence needs

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html:ro
      - logs:/var/log/nginx
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
  
  cache:
    image: redis:alpine
    volumes:
      - cache_data:/data
      - type: tmpfs
        target: /tmp
        tmpfs:
          size: 100m

volumes:
  db_data:
  logs:
  cache_data:
```

**Commands:**
```bash
# Start services
docker-compose up -d

# Check volume usage
docker volume ls

# Inspect a volume
docker volume inspect $(docker-compose ps -q db)_db_data

# View logs volume content
docker-compose exec web ls -la /var/log/nginx/

# Clean up volumes
docker-compose down -v
```

**Explanation:**

- **Named volumes**: Managed by Docker, persist across container lifecycle
- **Bind mounts**: Host directories mounted into containers
- **:ro**: Read-only mount for security
- **tmpfs**: Temporary filesystem in memory
- **Volume lifecycle**: Separate from container lifecycle
- **docker-compose down -v**: Removes containers and volumes

</details>

---

#### 05. Networking Between Services

* Configure custom networks in Docker Compose to control service communication and isolation.

    #### **Scenario:**
    * Your application has multiple services that need controlled communication - some services should be publicly accessible, others should only communicate internally, and some need complete isolation.
    * Docker Compose networking allows you to create custom networks with specific connectivity rules.

**Hint:** Use custom networks with `internal: true` for backend isolation and multiple network connections

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
      - frontend
      - backend
  
  api:
    image: alpine:latest
    networks:
      - backend
    command: sh -c "busybox httpd -f -p 8000 -h /tmp"
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

**Commands:**
```bash
# Start services
docker-compose up -d

# Check networks
docker network ls

# Test connectivity
docker-compose exec web ping -c 2 api
docker-compose exec web ping -c 2 db
docker-compose exec api ping -c 2 db

# Check network isolation (should fail)
curl http://localhost:8000
```

**Explanation:**

- **Custom networks**: Isolated communication channels
- **internal: true**: Prevents external access to backend network
- **Multiple networks**: Services can connect to multiple networks
- **Network isolation**: Frontend accessible, backend internal only
- **Service discovery**: Services communicate using service names

</details>

---

#### 06. Health Checks and Dependencies

* Implement health checks and service dependencies to ensure proper startup order and fault tolerance.

    #### **Scenario:**
    * Your application services have complex dependencies and need to verify they're healthy before other services start depending on them.
    * Docker Compose health checks ensure services are ready before dependent services start, improving application reliability.

**Hint:** Use `healthcheck` with `depends_on.condition: service_healthy` for proper service startup sequencing

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    volumes:
      - db_data:/var/lib/postgresql/data
  
  api:
    image: alpine:latest
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    command: sh -c 'echo "OK" > /tmp/index.html && busybox httpd -f -p 8000 -h /tmp'
  
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    depends_on:
      api:
        condition: service_healthy
    volumes:
      - ./web:/usr/share/nginx/html

volumes:
  db_data:
```

**Commands:**
```bash
# Start services (will wait for health checks)
docker-compose up -d

# Monitor startup process
docker-compose logs -f

# Check service health
docker-compose ps

# Test health endpoints
docker-compose exec api curl http://localhost:8000/health
```

**Explanation:**

- **healthcheck**: Defines how to check service health
- **depends_on.condition**: Waits for healthy dependencies
- **Startup sequencing**: Services start only when dependencies are ready
- **Fault tolerance**: Automatic restarts for unhealthy services
- **Health monitoring**: Continuous health checking during runtime

</details>

---

#### 07. Scaling Services

* Scale services horizontally to handle increased load and implement load balancing.

    #### **Scenario:**
    * Your application is experiencing high traffic and needs to handle more concurrent requests by running multiple instances of services.
    * Docker Compose scaling allows you to run multiple instances of services and distribute load across them.

    #### Resources:
    * `lb/nginx.conf` ➤ `/etc/nginx/nginx.conf`
        ```nginx
        events {
            worker_connections 1024;
        }
        
        http {
            upstream api_backend {
                server api:8000;
            }
            
            server {
                listen 80;
                
                location /api {
                    proxy_pass http://api_backend;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                }
                
                location / {
                    proxy_pass http://web;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                }
            }
        }
        ```

**Hint:** Use `deploy.replicas` to scale services and configure load balancing with nginx upstream

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html
    deploy:
      replicas: 3
  
  api:
    image: alpine:latest
    command: sh -c "
while true; do
  hostname=\$(hostname)
  { echo -e \"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nAPI Instance: \$hostname\"; } | nc -l -p 8000 -q 1 > /dev/null
done"
    deploy:
      replicas: 2
  
  loadbalancer:
    image: nginx:alpine
    ports:
      - "9090:80"
    volumes:
      - ./lb/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - api

networks:
  default:
    name: app-network
```

**lb/nginx.conf**
```nginx
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
        server api:8000;
    }
    
    server {
        listen 80;
        
        location /api {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location / {
            proxy_pass http://web;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

**Commands:**
```bash
# Start scaled services
docker-compose up -d

# Check running instances
docker-compose ps

# Scale services dynamically
docker-compose up -d --scale api=3

# Test load balancing
for i in {1..5}; do curl http://localhost:9090/api; done

# Scale down
docker-compose up -d --scale web=1
```

**Explanation:**

- **deploy.replicas**: Specifies number of service instances
- **Load balancing**: Nginx distributes requests across instances
- **Service discovery**: Automatic load balancing between replicas
- **Dynamic scaling**: Change replica count without recreation
- **Instance identification**: Each replica has unique hostname

</details>

---

#### 08. Build Configuration

* Build custom images within Docker Compose using build contexts and Dockerfiles.

    #### **Scenario:**
    * Your application requires custom Docker images that aren't available publicly, or you need to build images with specific configurations for your stack.
    * Docker Compose can build images from Dockerfiles as part of the service definition.

    #### Resources:
    * `web/Dockerfile` ➤ Web service Dockerfile
        ```dockerfile
        FROM node:18-alpine
        WORKDIR /app
        COPY package*.json ./
        RUN npm ci --only=production
        COPY . .
        EXPOSE 80
        CMD ["npm", "start"]
        ```
    * `api/Dockerfile` ➤ API service Dockerfile
        ```dockerfile
        FROM python:3.9-slim
        ARG APP_VERSION
        ENV VERSION=$APP_VERSION
        WORKDIR /app
        COPY requirements.txt .
        RUN pip install -r requirements.txt
        COPY . .
        EXPOSE 3000
        CMD ["python", "app.py"]
        ```

**Hint:** Use `build.context` and `build.args` to build custom images within Compose

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    build:
      context: ./web
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    environment:
      - NODE_ENV=production
  
  api:
    build:
      context: ./api
      dockerfile: Dockerfile
      args:
        APP_VERSION: 1.0.0
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    depends_on:
      - db
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

**web/Dockerfile**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 80
CMD ["npm", "start"]
```

**api/Dockerfile**
```dockerfile
FROM python:3.9-slim
ARG APP_VERSION
ENV VERSION=$APP_VERSION
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 3000
CMD ["python", "app.py"]
```

**Commands:**
```bash
# Build and start services
docker-compose up --build -d

# Rebuild specific service
docker-compose build api

# Build without cache
docker-compose build --no-cache

# View build logs
docker-compose build --progress plain
```

**Explanation:**

- **build.context**: Directory containing Dockerfile and build context
- **build.dockerfile**: Specify custom Dockerfile name/location
- **build.args**: Pass build arguments to Dockerfile
- **--build**: Force rebuild of images
- **Selective building**: Rebuild only specific services
- **Build caching**: Leverages Docker layer caching

</details>

---

#### 09. Override Files

* Use multiple docker-compose files to manage different environments and configurations.

    #### **Scenario:**
    * Your application needs different configurations for development, testing, and production environments with varying resource requirements, logging levels, and service configurations.
    * Docker Compose override files allow you to maintain a base configuration while applying environment-specific customizations.

    #### Resources:
    * `docker-compose.override.yml` ➤ Development overrides
        ```yaml
        version: '3.8'
        services:
          web:
            environment:
              - DEBUG=true
            volumes:
              - ./web:/usr/share/nginx/html
              - /app/node_modules
          
          db:
            ports:
              - "5432:5432"
            environment:
              POSTGRES_PASSWORD: devpassword
        ```
    * `docker-compose.prod.yml` ➤ Production overrides
        ```yaml
        version: '3.8'
        services:
          web:
            deploy:
              replicas: 3
              resources:
                limits:
                  memory: 512M
                  cpus: '0.5'
            environment:
              - NODE_ENV=production
          
          db:
            environment:
              POSTGRES_PASSWORD: ${DB_PASSWORD}
            deploy:
              resources:
                limits:
                  memory: 1G
                  cpus: '1.0'
        ```

**Hint:** Use `docker-compose.override.yml` for development and custom override files for production

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml** (base)
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```

**docker-compose.override.yml** (development)
```yaml
version: '3.8'
services:
  web:
    environment:
      - DEBUG=true
    volumes:
      - ./web:/usr/share/nginx/html
      - /app/node_modules
  
  db:
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: devpassword
```

**docker-compose.prod.yml** (production)
```yaml
version: '3.8'
services:
  web:
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
          cpus: '0.5'
    environment:
      - NODE_ENV=production
  
  db:
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '1.0'
```

**Commands:**
```bash
# Development (uses override automatically)
docker-compose up -d

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Staging with custom override
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# List all services from combined files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml config
```

**Explanation:**

- **Automatic override**: docker-compose.override.yml loaded automatically
- **Multiple files**: Use -f to specify multiple compose files
- **Merging rules**: Override files extend and modify base configuration
- **Environment separation**: Different settings for dev/staging/prod
- **docker-compose config**: Validate and view merged configuration

</details>

---

#### 10. Secrets Management

* Securely manage sensitive data like passwords and API keys using Docker Compose secrets.

    #### **Scenario:**
    * Your application requires sensitive information like database passwords, API keys, and certificates that shouldn't be stored in plain text in your compose files.
    * Docker Compose secrets provide a secure way to manage sensitive data and make it available to services at runtime.

**Hint:** Use `secrets` with `file` source to securely pass sensitive data to containers

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    secrets:
      - source: nginx_cert
        target: /etc/ssl/certs/nginx.crt
      - source: nginx_key
        target: /etc/ssl/private/nginx.key
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
    secrets:
      - source: db_password
        target: postgres_password
    command: >
      sh -c "
      export POSTGRES_PASSWORD=$(cat /run/secrets/postgres_password) &&
      docker-entrypoint.sh postgres
      "
    volumes:
      - db_data:/var/lib/postgresql/data
  
  api:
    image: alpine:latest
    secrets:
      - source: api_key
        target: /run/secrets/api_key
    environment:
      - API_KEY_FILE=/run/secrets/api_key

secrets:
  nginx_cert:
    file: ./secrets/nginx.crt
  nginx_key:
    file: ./secrets/nginx.key
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    file: ./secrets/api_key.txt

volumes:
  db_data:
```

**Commands:**
```bash
# Create secrets directory
mkdir -p secrets

# Create secret files (never commit these)
echo "mysecretpassword" > secrets/db_password.txt
echo "sk-1234567890abcdef" > secrets/api_key.txt

# Start services
docker-compose up -d

# Check secrets in containers
docker-compose exec api cat /run/secrets/api_key

# Clean up (remove secrets)
docker-compose down
rm -rf secrets/
```

**Explanation:**

- **secrets**: Secure way to pass sensitive data to containers
- **file source**: Load secrets from external files
- **target**: Location where secret is mounted in container
- **Runtime only**: Secrets not stored in image layers
- **Access control**: Secrets only available to specified services
- **External management**: Secrets can be managed by external systems

</details>

---

#### 11. Logging Configuration

* Configure centralized logging for all services in a Docker Compose stack.

    #### **Scenario:**
    * Your multi-service application generates logs from different components, and you need to centralize logging for monitoring, debugging, and compliance purposes.
    * Docker Compose logging configuration allows you to define logging drivers and options for consistent log management across all services.

**Hint:** Use `logging.driver` and `logging.options` to configure log rotation and formatting

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
  
  api:
    image: alpine:latest
    logging:
      driver: json-file
      options:
        max-size: "20m"
        max-file: "5"
        labels: "service"
    command: sh -c "
while true; do
  echo \"\$(date '+%Y-%m-%d %H:%M:%S') - INFO - API request processed\"
  sleep 5
done"
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "2"
    volumes:
      - db_data:/var/lib/postgresql/data
  
  log-collector:
    image: fluent/fluent-bit:latest
    volumes:
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf
    logging:
      driver: json-file

volumes:
  db_data:
```

**Commands:**
```bash
# Start services
docker-compose up -d

# View logs for specific service
docker-compose logs web

# View logs with timestamps
docker-compose logs --timestamps api

# Follow logs in real-time
docker-compose logs -f

# View logs for all services
docker-compose logs

# Export logs to file
docker-compose logs > app_logs.txt
```

**Explanation:**

- **logging.driver**: Specifies the logging driver (json-file, syslog, etc.)
- **max-size**: Maximum size of log files before rotation
- **max-file**: Maximum number of log files to keep
- **Log rotation**: Automatic log file management
- **Centralized logging**: Collect logs from multiple services
- **Log filtering**: View logs by service or time range

</details>

---

#### 12. Resource Limits

* Set CPU and memory limits for services to ensure fair resource allocation and prevent resource exhaustion.

    #### **Scenario:**
    * Your application runs multiple services on shared infrastructure, and you need to ensure that no single service can consume all available resources and impact other services.
    * Docker Compose resource limits allow you to control CPU and memory usage for each service.

**Hint:** Use `deploy.resources.limits` and `deploy.resources.reservations` for CPU and memory control

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
        reservations:
          memory: 128M
          cpus: '0.25'
  
  api:
    image: alpine:latest
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'
    command: sh -c "
while true; do
  mem=\$(free | grep Mem | awk '{printf \"%.0f\", \$3/\$2 * 100.0}')
  cpu=\$(top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\([0-9.]*\)%* id.*/\1/' | awk '{print 100 - \$1}')
  echo \"Memory: \${mem}%, CPU: \${cpu}%\"
  sleep 10
done"
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '2.0'
        reservations:
          memory: 512M
          cpus: '1.0'
    volumes:
      - db_data:/var/lib/postgresql/data
  
  monitoring:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.25'

volumes:
  db_data:
```

**Commands:**
```bash
# Start services with resource limits
docker-compose up -d

# Check resource usage
docker stats

# View resource limits
docker-compose ps

# Monitor specific container
docker stats $(docker-compose ps -q api)

# Check if limits are enforced (try to consume more memory)
docker-compose exec api sh -c "
data=''
while true; do
  data=\"\$data\$data\"
  sleep 0.1
done"
```

**Explanation:**

- **limits**: Hard limits that containers cannot exceed
- **reservations**: Guaranteed minimum resources
- **memory**: RAM limits (supports m, g suffixes)
- **cpus**: CPU core limits (supports decimal values)
- **Resource enforcement**: Docker prevents exceeding limits
- **Monitoring**: Track resource usage with docker stats

</details>

---

#### 13. Profiles and Selective Services

* Use profiles to run different combinations of services for development, testing, and production.

    #### **Scenario:**
    * Your application has services that are only needed in certain environments - debugging tools for development, testing services for CI/CD, and monitoring services for production.
    * Docker Compose profiles allow you to define which services run in different scenarios without modifying the compose file.

**Hint:** Use `profiles` to group services and `--profile` flag to run specific combinations

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./web:/usr/share/nginx/html
    profiles:
      - web
      - full
  
  api:
    image: alpine:latest
    profiles:
      - api
      - full
    command: sh -c 'echo "API Response" > /tmp/index.html && busybox httpd -f -p 8000 -h /tmp'
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    profiles:
      - database
      - full
    volumes:
      - db_data:/var/lib/postgresql/data
  
  debug:
    image: alpine:latest
    profiles:
      - debug
    command: tail -f /dev/null
    volumes:
      - .:/app
  
  test:
    image: python:3.9-alpine
    profiles:
      - test
    command: python -m pytest /app/tests/
    volumes:
      - .:/app
  
  monitoring:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    profiles:
      - monitoring
      - production
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml

volumes:
  db_data:
```

**Commands:**
```bash
# Run only web service
docker-compose --profile web up -d

# Run web with database
docker-compose --profile web --profile database up -d

# Run full application stack
docker-compose --profile full up -d

# Run tests
docker-compose --profile test up

# Development with debug tools
docker-compose --profile full --profile debug up -d

# Production with monitoring
docker-compose --profile full --profile production up -d
```

**Explanation:**

- **profiles**: Assign services to specific profiles
- **--profile**: Activate specific profiles when running
- **Service grouping**: Logical grouping of related services
- **Environment-specific**: Different service combinations per environment
- **Selective deployment**: Run only needed services for each use case

</details>

---

#### 14. External Networks

* Connect Docker Compose services to existing external networks for integration with other applications.

    #### **Scenario:**
    * Your application needs to communicate with services running outside of Docker Compose, such as a company-wide database or legacy applications.
    * Docker Compose external networks allow services to connect to pre-existing Docker networks.

**Hint:** Use `external: true` and `name` to connect to existing Docker networks

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
        - app-network
        - external-network
  
  api:
    image: alpine:latest
    networks:
      - app-network
      - external-network
    command: sh -c "busybox httpd -f -p 8000 -h /tmp"
  
  legacy-connector:
    image: alpine:latest
    networks:
      - external-network
    command: ping -c 4 legacy-service

networks:
  app-network:
    driver: bridge
  external-network:
    external: true
    name: company-network
```

**Setup Commands:**
```bash
# Create external network (if not exists)
docker network create company-network

# Start external service
docker run -d --name legacy-service --network company-network alpine sleep infinity

# Start compose services
docker-compose up -d

# Test connectivity
docker-compose exec legacy-connector ping -c 2 legacy-service

# Check networks
docker network ls
docker network inspect company-network
```

**Explanation:**

- **external: true**: Connect to existing Docker network
- **name**: Specify the exact network name
- **Network sharing**: Services can communicate across compose files
- **Legacy integration**: Connect to existing infrastructure
- **Network isolation**: Control which services access external networks

</details>

---

#### 15. Custom Networks

* Create custom networks with specific configurations for advanced networking requirements.

    #### **Scenario:**
    * Your application requires specific network configurations like custom subnets, IP ranges, or network drivers for security, performance, or compliance reasons.
    * Docker Compose custom networks allow you to define network properties like IP ranges, subnets, and drivers.

**Hint:** Use `ipam.config` to define custom subnets and `ipv4_address` for static IP assignment

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
      frontend:
        ipv4_address: 172.20.0.10
  
  api:
    image: alpine:latest
    networks:
      frontend:
        ipv4_address: 172.20.0.11
      backend:
        ipv4_address: 172.21.0.10
    command: sh -c "busybox httpd -f -p 8000 -h /tmp"
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    networks:
      backend:
        ipv4_address: 172.21.0.11
    volumes:
      - db_data:/var/lib/postgresql/data
  
  monitoring:
    image: alpine:latest
    networks:
      frontend:
        ipv4_address: 172.20.0.12
      backend:
        ipv4_address: 172.21.0.12
    command: watch -n 5 'echo "Monitoring networks"'

networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
  backend:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.21.0.0/16
          gateway: 172.21.0.1

volumes:
  db_data:
```

**Commands:**
```bash
# Start services with custom networks
docker-compose up -d

# Check network configurations
docker network ls
docker network inspect $(docker-compose ps -q web | xargs docker inspect | jq -r '.[0].NetworkSettings.Networks | keys[]' | head -1)

# Test connectivity
docker-compose exec web ping -c 2 172.20.0.11
docker-compose exec api ping -c 2 172.21.0.11

# Check IP assignments
docker-compose exec web ip addr show eth0
```

**Explanation:**

- **ipam.config**: Define custom IP address management
- **subnet**: IP address range for the network
- **ipv4_address**: Assign static IP to specific services
- **internal: true**: Prevent external access to backend network
- **Network segmentation**: Separate frontend and backend traffic
- **IP predictability**: Static IPs for consistent service communication

</details>

---

#### 16. Load Balancing

* Implement load balancing across multiple service instances for high availability and scalability.

    #### **Scenario:**
    * Your application needs to handle high traffic loads and provide fault tolerance by distributing requests across multiple service instances.
    * Docker Compose load balancing works with service scaling to automatically distribute traffic across healthy instances.

    #### Resources:
    * `nginx/loadbalancer.conf` ➤ `/etc/nginx/nginx.conf`
        ```nginx
        events {
            worker_connections 1024;
        }
        
        http {
            upstream web_backend {
                server web:80;
            }
            
            upstream api_backend {
                server api:8000;
            }
            
            server {
                listen 80;
                
                location / {
                    proxy_pass http://web_backend;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                }
                
                location /api {
                    proxy_pass http://api_backend;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                }
            }
        }
        ```

**Hint:** Use nginx as load balancer with upstream blocks and deploy.replicas for scaling

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  loadbalancer:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx/loadbalancer.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
  
  web:
    image: nginx:alpine
    volumes:
      - ./web:/usr/share/nginx/html
    deploy:
      replicas: 3
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 10s
      timeout: 5s
      retries: 3
  
  api:
    image: alpine:latest
    deploy:
      replicas: 2
    command: sh -c "
while true; do
  hostname=\$(hostname)
  { echo -e \"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nAPI Response from \$hostname\"; } | nc -l -p 8000 -q 1 > /dev/null
done"
    healthcheck:
      test: ["CMD", "echo", "OK"]
      interval: 15s
      timeout: 5s
      retries: 3
  
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data

volumes:
  redis_data:
```

**nginx/loadbalancer.conf**
```nginx
events {
    worker_connections 1024;
}

http {
    upstream web_backend {
        server web:80;
    }
    
    upstream api_backend {
        server api:8000;
    }
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://web_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        location /api {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
```

**Commands:**
```bash
# Start load balanced services
docker-compose up -d

# Test load balancing
for i in {1..10}; do curl -s http://localhost:8080/api | grep "API Response"; done

# Check service instances
docker-compose ps

# Scale services
docker-compose up -d --scale web=5

# Test failover (stop one instance)
docker-compose exec web.1 nginx -s stop
# Requests should still work
curl http://localhost:8080/
```

**Explanation:**

- **upstream blocks**: Define backend server groups for load balancing
- **proxy_pass**: Forward requests to backend services
- **deploy.replicas**: Create multiple instances for load distribution
- **healthcheck**: Ensure only healthy instances receive traffic
- **Automatic failover**: Traffic rerouted when instances become unhealthy
- **Session persistence**: Optional sticky sessions for stateful applications

</details>

---

#### 17. Multi-Stage Deployments

* Implement blue-green or canary deployment strategies using Docker Compose.

    #### **Scenario:**
    * You need to deploy application updates with zero downtime and the ability to quickly rollback if issues occur.
    * Multi-stage deployments with Docker Compose allow you to run multiple versions of your application simultaneously and gradually shift traffic.

    #### Resources:
    * `nginx/nginx.conf` ➤ Load balancer configuration for canary deployment
        ```nginx
        events {
            worker_connections 1024;
        }
        
        http {
            upstream web_backend {
                server web-v1:80 weight=9;
                server web-v2:80 weight=1;
            }
            
            upstream api_backend {
                server api-v1:8000 weight=9;
                server api-v2:8000 weight=1;
            }
            
            server {
                listen 80;
                
                location / {
                    proxy_pass http://web_backend;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                }
                
                location /api {
                    proxy_pass http://api_backend;
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                }
            }
        }
        ```

**Hint:** Use profiles to control which version runs and nginx upstream weights for traffic shifting

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml** (base)
```yaml
version: '3.8'
services:
  loadbalancer:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
  
  web-v1:
    image: nginx:alpine
    volumes:
      - ./web/v1:/usr/share/nginx/html
    environment:
      - VERSION=v1
    deploy:
      replicas: 2
  
  web-v2:
    image: nginx:alpine
    volumes:
      - ./web/v2:/usr/share/nginx/html
    environment:
      - VERSION=v2
    deploy:
      replicas: 2
    profiles:
      - v2
  
  api-v1:
    image: alpine:latest
    environment:
      - VERSION=v1
    command: sh -c 'echo "API v1" > /tmp/index.html && busybox httpd -f -p 8000 -h /tmp'
    deploy:
      replicas: 2
  
  api-v2:
    image: alpine:latest
    environment:
      - VERSION=v2
    command: sh -c 'echo "API v2 - New Feature!" > /tmp/index.html && busybox httpd -f -p 8000 -h /tmp'
    deploy:
      replicas: 2
    profiles:
      - v2
```

**nginx/nginx.conf** (canary deployment - 90% v1, 10% v2)
```nginx
events {
    worker_connections 1024;
}

http {
    upstream web_backend {
        server web-v1:80 weight=9;
        server web-v2:80 weight=1;
    }
    
    upstream api_backend {
        server api-v1:8000 weight=9;
        server api-v2:8000 weight=1;
    }
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://web_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        location /api {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

**Commands:**
```bash
# Start with only v1
docker-compose up -d

# Test current version
for i in {1..10}; do curl -s http://localhost:8080/api; done

# Deploy v2 alongside v1 (canary)
docker-compose --profile v2 up -d

# Update nginx config for canary deployment
# (edit nginx.conf to add v2 with low weight)

# Reload nginx config
docker-compose exec loadbalancer nginx -s reload

# Test canary deployment
for i in {1..20}; do curl -s http://localhost:8080/api; done

# Full rollout to v2 (blue-green)
# Update nginx.conf to send all traffic to v2
docker-compose exec loadbalancer nginx -s reload

# Remove v1 services
docker-compose rm -f web-v1 api-v1
```

**Explanation:**

- **Canary deployment**: Route small percentage of traffic to new version
- **Blue-green deployment**: Switch all traffic to new version at once
- **Profiles**: Control which version services are running
- **Load balancer config**: Dynamic traffic shifting without downtime
- **Rollback capability**: Quickly switch back to previous version
- **Zero downtime**: New version tested before full rollout

</details>

---

#### 18. Production-Ready Stack

* Create a complete production-ready application stack with monitoring, logging, and security best practices.

    #### **Scenario:**
    * You're deploying a critical application to production that requires monitoring, centralized logging, security hardening, and automated backups.
    * A production-ready Docker Compose stack includes all necessary components for running applications reliably in production environments.

**Hint:** Combine all production best practices: health checks, secrets, resource limits, logging, monitoring, and backups

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./web:/usr/share/nginx/html:ro
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/ssl/certs:ro
    depends_on:
      - api
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
  
  api:
    image: alpine:latest
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    secrets:
      - source: api_key
        target: /run/secrets/api_key
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
    secrets:
      - source: db_password
        target: postgres_password
    volumes:
      - db_data:/var/lib/postgresql/data
      - ./backup:/backup
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '2.0'
    logging:
      driver: json-file
      options:
        max-size: "50m"
        max-file: "5"
  
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
  
  backup:
    image: postgres:13-alpine
    volumes:
      - db_data:/var/lib/postgresql/data:ro
      - ./backup:/backup
    command: >
      sh -c "
      while true; do
        pg_dump -U user -h db myapp > /backup/backup_$(date +%Y%m%d_%H%M%S).sql
        sleep 3600
      done
      "
    depends_on:
      - db
    profiles:
      - backup
  
  monitoring:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - monitoring_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    profiles:
      - monitoring
  
  log-aggregator:
    image: fluent/fluent-bit:latest
    volumes:
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf:ro
    profiles:
      - logging

secrets:
  api_key:
    file: ./secrets/api_key.txt
  db_password:
    file: ./secrets/db_password.txt

volumes:
  db_data:
    driver: local
  redis_data:
    driver: local
  monitoring_data:
    driver: local

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

**Commands:**
```bash
# Create secrets
mkdir -p secrets
echo "my-secret-api-key" > secrets/api_key.txt
echo "my-secret-db-password" > secrets/db_password.txt

# Start production stack
docker-compose up -d

# Start with monitoring
docker-compose --profile monitoring up -d

# Start with logging
docker-compose --profile logging up -d

# Start backup service
docker-compose --profile backup up -d

# Check all services
docker-compose ps

# View logs
docker-compose logs -f

# Monitor resources
docker stats

# Backup database
docker-compose exec backup ls /backup/
```

**Explanation:**

- **Production hardening**: Resource limits, health checks, secrets management
- **Monitoring**: Prometheus for metrics collection
- **Logging**: Centralized log aggregation with Fluent Bit
- **Backup**: Automated database backups
- **Security**: Secrets, read-only volumes, network isolation
- **High availability**: Health checks, restart policies, resource management
- **Scalability**: Profiles for optional services, resource limits
- **Maintainability**: Structured configuration, clear separation of concerns

</details>

---

#### 19. Basic YAML Anchors and References

* Learn the fundamentals of YAML anchors and references to avoid repetition in Docker Compose files.

    #### **Scenario:**
    * You have multiple services that share common configuration elements like environment variables, volumes, or network settings.
    * YAML anchors (&) and references (*) allow you to define reusable configuration blocks and reference them throughout your compose file.

    #### Resources:
    * `docker-compose.yml` ➤ Main compose file with anchors and references
        ```yaml
        version: '3.8'
        
        x-common-env: &common-env
          APP_ENV: production
          LOG_LEVEL: info
        
        x-common-volumes: &common-volumes
          - ./logs:/app/logs
          - ./config:/app/config:ro
        
        services:
          web:
            image: nginx:alpine
            environment:
              <<: *common-env
              SERVICE_NAME: web
            volumes: *common-volumes
            ports:
              - "8080:80"
          
          api:
            image: node:18-alpine
            environment:
              <<: *common-env
              SERVICE_NAME: api
            volumes: *common-volumes
            ports:
              - "3000:3000"
        ```

**Hint:** Use `&anchor-name` to define reusable blocks and `*anchor-name` to reference them

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'

x-common-env: &common-env
  APP_ENV: production
  LOG_LEVEL: info
  TZ: UTC

x-common-volumes: &common-volumes
  - ./logs:/app/logs
  - ./config:/app/config:ro

x-common-deploy: &common-deploy
  resources:
    limits:
      memory: 256M
      cpus: '0.5'
    restart_policy:
      condition: on-failure

services:
  web:
    image: nginx:alpine
    environment:
      <<: *common-env
      SERVICE_NAME: web
    volumes: *common-volumes
    ports:
      - "8080:80"
    deploy: *common-deploy
  
  api:
    image: node:18-alpine
    environment:
      <<: *common-env
      SERVICE_NAME: api
      DATABASE_URL: postgresql://db:5432/myapp
    volumes: *common-volumes
    ports:
      - "3000:3000"
    deploy: *common-deploy
    depends_on:
      - db
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    deploy: *common-deploy

volumes:
  db_data:
```

**Commands:**
```bash
# Start services
docker-compose up -d

# Check environment variables
docker-compose exec web env | grep APP_ENV
docker-compose exec api env | grep SERVICE_NAME

# View configuration
docker-compose config

# Stop services
docker-compose down
```

**Explanation:**

- **x- prefix**: Extension fields for reusable configurations
- **&anchor**: Defines a named anchor for later reference
- ***reference**: References the anchored configuration
- **<<: *anchor**: Merges the referenced configuration
- **DRY principle**: Avoids repetition in compose files
- **Maintainability**: Changes to common config affect all services

</details>

---

#### 20. Merging Service Configurations

* Use YAML merge keys to combine base configurations with service-specific overrides.

    #### **Scenario:**
    * Your services have a common base configuration but need individual customizations for ports, environment variables, or resource limits.
    * The merge key (<<) allows you to combine multiple configurations, with later values overriding earlier ones.

    #### Resources:
    * `docker-compose.yml` ➤ Compose file demonstrating merge operations
        ```yaml
        version: '3.8'
        
        x-base-service: &base-service
          image: alpine:latest
          environment:
            APP_ENV: production
          deploy:
            resources:
              limits:
                memory: 128M
                cpus: '0.25'
        
        services:
          web:
            <<: *base-service
            ports:
              - "8080:80"
            command: nginx -g 'daemon off;'
          
          worker:
            <<: *base-service
            environment:
              <<: *base-service.environment
              WORKER_TYPE: background
            command: sh -c 'while true; do echo "Working..."; sleep 30; done'
        ```

**Hint:** Use `<<: *anchor` to merge configurations and override specific values

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'

x-base-service: &base-service
  image: alpine:latest
  environment:
    APP_ENV: production
    LOG_LEVEL: info
    TZ: UTC
  deploy:
    resources:
      limits:
        memory: 128M
        cpus: '0.25'
    restart_policy:
      condition: on-failure
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

x-web-config: &web-config
  <<: *base-service
  ports:
    - "8080:80"
  healthcheck:
    test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]
    interval: 30s
    timeout: 10s
    retries: 3

x-api-config: &api-config
  <<: *base-service
  ports:
    - "3000:3000"
  environment:
    <<: *base-service.environment
    SERVICE_TYPE: api
    DATABASE_URL: postgresql://db:5432/myapp
  depends_on:
    - db

services:
  web:
    <<: *web-config
    command: sh -c 'echo "<h1>Web Service</h1>" > /tmp/index.html && busybox httpd -f -p 80 -h /tmp'
  
  api:
    <<: *api-config
    command: sh -c 'while true; do echo "API running on port 3000"; sleep 10; done'
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    deploy: *base-service.deploy

volumes:
  db_data:
```

**Commands:**
```bash
# Start services
docker-compose up -d

# Check merged configurations
docker-compose config

# Test services
curl http://localhost:8080
docker-compose logs api

# Inspect service configurations
docker inspect $(docker-compose ps -q web) | jq '.[0].Config.Env'

# Stop services
docker-compose down
```

**Explanation:**

- **<<: *anchor**: Merges the referenced configuration into the current block
- **Override behavior**: Later values override earlier ones with the same key
- **Nested merges**: Can merge multiple levels of configuration
- **Base + specific**: Common pattern of base config plus service-specific additions
- **Configuration inheritance**: Services inherit from base configurations

</details>

---

#### 21. Using Includes for Modular Compose Files

* Split large compose files into smaller, manageable modules using Docker Compose includes.

    #### **Scenario:**
    * Your application stack is complex with many services, networks, and volumes, making the compose file difficult to maintain.
    * Docker Compose includes allow you to split your configuration across multiple files for better organization and reusability.

    #### Resources:
    * `docker-compose.yml` ➤ Main compose file with includes
        ```yaml
        include:
          - services.yml
          - networks.yml
          - volumes.yml
        
        version: '3.8'
        
        services:
          proxy:
            image: nginx:alpine
            ports:
              - "80:80"
        ```
    * `services.yml` ➤ Service definitions
        ```yaml
        services:
          web:
            image: nginx:alpine
            networks:
              - frontend
          api:
            image: node:18-alpine
            networks:
              - frontend
              - backend
        ```
    * `networks.yml` ➤ Network definitions
        ```yaml
        networks:
          frontend:
            driver: bridge
          backend:
            driver: bridge
            internal: true
        ```

**Hint:** Use `include` directive to reference external compose files

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml** (main)
```yaml
include:
  - services.yml
  - networks.yml
  - volumes.yml

version: '3.8'

services:
  proxy:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./proxy/nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - frontend
    depends_on:
      - web
      - api
```

**services.yml**
```yaml
services:
  web:
    image: nginx:alpine
    volumes:
      - web_data:/usr/share/nginx/html
    networks:
      - frontend
    deploy:
      replicas: 2
  
  api:
    image: node:18-alpine
    environment:
      DATABASE_URL: postgresql://db:5432/myapp
    networks:
      - frontend
      - backend
    depends_on:
      - db
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - backend
```

**networks.yml**
```yaml
networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  backend:
    driver: bridge
    internal: true
    ipam:
      config:
        - subnet: 172.21.0.0/16
```

**volumes.yml**
```yaml
volumes:
  web_data:
  db_data:
```

**proxy/nginx.conf**
```nginx
events {
    worker_connections 1024;
}

http {
    upstream web_backend {
        server web:80;
    }
    
    upstream api_backend {
        server api:3000;
    }
    
    server {
        listen 80;
        
        location / {
            proxy_pass http://web_backend;
        }
        
        location /api {
            proxy_pass http://api_backend;
        }
    }
}
```

**Commands:**
```bash
# Start all services from modular files
docker-compose up -d

# Check included configurations
docker-compose config

# List all services from includes
docker-compose ps

# View logs from specific service
docker-compose logs web

# Stop all services
docker-compose down
```

**Explanation:**

- **include**: References external compose files to include their configurations
- **Modular organization**: Split large files into logical components
- **Reusability**: Include files can be shared across projects
- **Maintainability**: Easier to manage and version control smaller files
- **Override capability**: Main file can override included configurations

</details>

---

#### 22. Environment-Specific Fragments

* Create environment-specific configurations using fragments and conditional includes.

    #### **Scenario:**
    * You need different service configurations for development, staging, and production environments with varying resource allocations, logging levels, and monitoring.
    * Fragments combined with includes allow you to maintain environment-specific configurations while sharing common elements.

    #### Resources:
    * `docker-compose.yml` ➤ Main file with environment includes
        ```yaml
        include:
          - common.yml
          - path: environments/${ENVIRONMENT}.yml
        
        version: '3.8'
        ```
    * `environments/development.yml` ➤ Development-specific config
        ```yaml
        services:
          web:
            environment:
              DEBUG: true
            ports:
              - "8080:80"
        ```
    * `environments/production.yml` ➤ Production-specific config
        ```yaml
        services:
          web:
            deploy:
              replicas: 3
              resources:
                limits:
                  memory: 512M
            environment:
              NODE_ENV: production
        ```

**Hint:** Use environment variables in include paths and fragments for environment-specific configurations

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml** (main)
```yaml
include:
  - common.yml
  - path: environments/${ENVIRONMENT:-development}.yml

version: '3.8'

x-env-overrides: &env-overrides
  environment:
    ENVIRONMENT: ${ENVIRONMENT:-development}
  logging:
    driver: json-file
    options:
      max-size: ${LOG_MAX_SIZE:-10m}
      max-file: ${LOG_MAX_FILE:-3}
```

**common.yml**
```yaml
x-common-service: &common-service
  image: alpine:latest
  <<: *env-overrides
  deploy:
    resources:
      limits:
        memory: ${MEMORY_LIMIT:-128M}
        cpus: ${CPU_LIMIT:-0.25}
  healthcheck:
    test: ["CMD", "echo", "OK"]
    interval: 30s
    timeout: 10s
    retries: 3

services:
  web:
    <<: *common-service
    command: sh -c 'echo "<h1>Web Service - ${ENVIRONMENT}</h1>" > /tmp/index.html && busybox httpd -f -p 80 -h /tmp'
  
  api:
    <<: *common-service
    environment:
      <<: *common-service.environment
      SERVICE_NAME: api
    command: sh -c 'while true; do echo "API in ${ENVIRONMENT}"; sleep 10; done'
  
  db:
    image: postgres:13-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    <<: *env-overrides

volumes:
  db_data:
```

**environments/development.yml**
```yaml
services:
  web:
    ports:
      - "8080:80"
    environment:
      DEBUG: true
    volumes:
      - ./dev-logs:/app/logs
  
  api:
    ports:
      - "3000:3000"
  
  db:
    ports:
      - "5432:5432"
```

**environments/production.yml**
```yaml
services:
  web:
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
    environment:
      NODE_ENV: production
  
  api:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
  
  db:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '2.0'
```

**environments/staging.yml**
```yaml
services:
  web:
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
    environment:
      NODE_ENV: staging
  
  api:
    deploy:
      replicas: 1
      resources:
        limits:
          memory: 128M
          cpus: '0.25'
  
  db:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
```

**Commands:**
```bash
# Development environment
ENVIRONMENT=development docker-compose up -d

# Production environment
ENVIRONMENT=production docker-compose up -d

# Staging environment
ENVIRONMENT=staging docker-compose up -d

# Check current configuration
docker-compose config

# View environment-specific settings
docker-compose exec web env | grep ENVIRONMENT

# Stop services
docker-compose down
```

**Explanation:**

- **Environment variables in includes**: Dynamic file inclusion based on environment
- **Fragment overrides**: Environment files override common configurations
- **Conditional configuration**: Different settings per environment
- **Scalability**: Easy to add new environments
- **Maintainability**: Separate concerns for common vs environment-specific config

</details>

---

#### 23. Complex Fragment Hierarchies

* Build complex configuration hierarchies using nested anchors and multiple inheritance levels.

    #### **Scenario:**
    * Your application has services with multiple inheritance levels - base configurations, service-type configurations, and instance-specific overrides.
    * Complex fragment hierarchies allow you to build sophisticated configuration inheritance chains.

    #### Resources:
    * `docker-compose.yml` ➤ Complex fragment hierarchy
        ```yaml
        version: '3.8'
        
        x-base: &base
          environment:
            APP_ENV: production
        
        x-service-base: &service-base
          <<: *base
          deploy:
            resources:
              limits:
                memory: 128M
        
        x-web-service: &web-service
          <<: *service-base
          ports:
            - "8080:80"
        
        services:
          web-primary:
            <<: *web-service
            environment:
              <<: *web-service.environment
              INSTANCE: primary
          
          web-secondary:
            <<: *web-service
            environment:
              <<: *web-service.environment
              INSTANCE: secondary
            deploy:
              <<: *web-service.deploy
              replicas: 2
        ```

**Hint:** Create multi-level inheritance chains with anchors and merges

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'

x-global: &global
  environment:
    APP_ENV: production
    LOG_LEVEL: info
    TZ: UTC
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

x-infrastructure: &infrastructure
  <<: *global
  deploy:
    restart_policy:
      condition: on-failure
      delay: 5s
    resources:
      limits:
        memory: 128M
        cpus: '0.25'

x-web-infrastructure: &web-infrastructure
  <<: *infrastructure
  healthcheck:
    test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]
    interval: 30s
    timeout: 10s
    retries: 3

x-api-infrastructure: &api-infrastructure
  <<: *infrastructure
  environment:
    <<: *infrastructure.environment
    SERVICE_TYPE: api
  healthcheck:
    test: ["CMD", "echo", "API health check"]
    interval: 30s
    timeout: 10s
    retries: 3

x-database-infrastructure: &database-infrastructure
  <<: *infrastructure
  environment:
    <<: *infrastructure.environment
    SERVICE_TYPE: database
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
    interval: 10s
    timeout: 5s
    retries: 5

x-web-primary: &web-primary
  <<: *web-infrastructure
  environment:
    <<: *web-infrastructure.environment
    INSTANCE: primary
    ROLE: frontend
  ports:
    - "8080:80"
  deploy:
    <<: *web-infrastructure.deploy
    labels:
      - "service.role=primary"

x-web-secondary: &web-secondary
  <<: *web-infrastructure
  environment:
    <<: *web-infrastructure.environment
    INSTANCE: secondary
    ROLE: frontend
  ports:
    - "8081:80"
  deploy:
    <<: *web-infrastructure.deploy
    labels:
      - "service.role=secondary"

services:
  web-primary:
    <<: *web-primary
    image: nginx:alpine
    volumes:
      - ./web/primary:/usr/share/nginx/html:ro
  
  web-secondary:
    <<: *web-secondary
    image: nginx:alpine
    volumes:
      - ./web/secondary:/usr/share/nginx/html:ro
  
  api-main:
    <<: *api-infrastructure
    image: node:18-alpine
    ports:
      - "3000:3000"
    environment:
      <<: *api-infrastructure.environment
      DATABASE_URL: postgresql://db:5432/myapp
    depends_on:
      - db
  
  api-worker:
    <<: *api-infrastructure
    image: node:18-alpine
    environment:
      <<: *api-infrastructure.environment
      WORKER_TYPE: background
      DATABASE_URL: postgresql://db:5432/myapp
    deploy:
      <<: *api-infrastructure.deploy
      replicas: 2
    depends_on:
      - db
  
  db:
    <<: *database-infrastructure
    image: postgres:13-alpine
    environment:
      <<: *database-infrastructure.environment
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    deploy:
      <<: *database-infrastructure.deploy
      resources:
        limits:
          memory: 512M
          cpus: '1.0'

volumes:
  db_data:
```

**Commands:**
```bash
# Start complex hierarchy services
docker-compose up -d

# Check configuration hierarchy
docker-compose config | head -50

# View service inheritance
docker-compose exec web-primary env | grep INSTANCE
docker-compose exec api-worker env | grep WORKER_TYPE

# Check labels and metadata
docker inspect $(docker-compose ps -q web-primary) | jq '.[0].Config.Labels'

# Stop services
docker-compose down
```

**Explanation:**

- **Multi-level inheritance**: Global → Infrastructure → Service-type → Instance-specific
- **Complex merging**: Multiple levels of configuration inheritance
- **Override chains**: Each level can override previous configurations
- **Modular design**: Easy to add new service types or instances
- **Configuration clarity**: Clear separation of concerns across inheritance levels

</details>

---

#### 24. Fragment-Based Service Templates

* Create reusable service templates using fragments for common service patterns.

    #### **Scenario:**
    * Your application uses similar service patterns repeatedly (like web services, worker services, or API services) with slight variations.
    * Service templates using fragments allow you to define reusable patterns and instantiate them with specific configurations.

    #### Resources:
    * `docker-compose.yml` ➤ Service templates with fragments
        ```yaml
        version: '3.8'
        
        x-web-template: &web-template
          image: nginx:alpine
          environment:
            SERVICE_TYPE: web
          deploy:
            resources:
              limits:
                memory: 256M
        
        x-api-template: &api-template
          image: node:18-alpine
          environment:
            SERVICE_TYPE: api
          deploy:
            resources:
              limits:
                memory: 512M
        
        services:
          web-frontend:
            <<: *web-template
            ports:
              - "8080:80"
          
          web-admin:
            <<: *web-template
            ports:
              - "8081:80"
            environment:
              <<: *web-template.environment
              SECTION: admin
        ```

**Hint:** Define service templates as anchors and instantiate them with specific overrides

<details markdown="1">
<summary>Solution</summary>

**Solution:**

**docker-compose.yml**
```yaml
version: '3.8'

x-service-base: &service-base
  environment:
    APP_ENV: production
    LOG_LEVEL: info
    TZ: UTC
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"
  deploy:
    restart_policy:
      condition: on-failure
      delay: 5s

x-web-template: &web-template
  <<: *service-base
  image: nginx:alpine
  environment:
    <<: *service-base.environment
    SERVICE_TYPE: web
  healthcheck:
    test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost/"]
    interval: 30s
    timeout: 10s
    retries: 3
  deploy:
    <<: *service-base.deploy
    resources:
      limits:
        memory: 256M
        cpus: '0.5'

x-api-template: &api-template
  <<: *service-base
  image: node:18-alpine
  environment:
    <<: *service-base.environment
    SERVICE_TYPE: api
  healthcheck:
    test: ["CMD", "echo", "API OK"]
    interval: 30s
    timeout: 10s
    retries: 3
  deploy:
    <<: *service-base.deploy
    resources:
      limits:
        memory: 512M
        cpus: '1.0'

x-worker-template: &worker-template
  <<: *service-base
  image: python:3.9-alpine
  environment:
    <<: *service-base.environment
    SERVICE_TYPE: worker
  healthcheck:
    test: ["CMD", "echo", "Worker OK"]
    interval: 60s
    timeout: 10s
    retries: 3
  deploy:
    <<: *service-base.deploy
    resources:
      limits:
        memory: 128M
        cpus: '0.25'

x-database-template: &database-template
  <<: *service-base
  image: postgres:13-alpine
  environment:
    <<: *service-base.environment
    SERVICE_TYPE: database
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-user} -d ${POSTGRES_DB:-myapp}"]
    interval: 10s
    timeout: 5s
    retries: 5
  deploy:
    <<: *service-base.deploy
    resources:
      limits:
        memory: 1G
        cpus: '2.0'

services:
  # Web services
  web-frontend:
    <<: *web-template
    ports:
      - "8080:80"
    volumes:
      - ./web/frontend:/usr/share/nginx/html:ro
    environment:
      <<: *web-template.environment
      SECTION: frontend
  
  web-admin:
    <<: *web-template
    ports:
      - "8081:80"
    volumes:
      - ./web/admin:/usr/share/nginx/html:ro
    environment:
      <<: *web-template.environment
      SECTION: admin
  
  web-api-docs:
    <<: *web-template
    ports:
      - "8082:80"
    volumes:
      - ./web/docs:/usr/share/nginx/html:ro
    environment:
      <<: *web-template.environment
      SECTION: api-docs
    deploy:
      <<: *web-template.deploy
      resources:
        limits:
          memory: 128M
          cpus: '0.25'
  
  # API services
  api-users:
    <<: *api-template
    ports:
      - "3000:3000"
    environment:
      <<: *api-template.environment
      MODULE: users
      DATABASE_URL: postgresql://db:5432/myapp
    depends_on:
      - db
  
  api-products:
    <<: *api-template
    ports:
      - "3001:3000"
    environment:
      <<: *api-template.environment
      MODULE: products
      DATABASE_URL: postgresql://db:5432/myapp
    depends_on:
      - db
  
  # Worker services
  worker-email:
    <<: *worker-template
    environment:
      <<: *worker-template.environment
      WORKER_TYPE: email
      QUEUE_NAME: email_queue
    deploy:
      <<: *worker-template.deploy
      replicas: 2
  
  worker-reports:
    <<: *worker-template
    environment:
      <<: *worker-template.environment
      WORKER_TYPE: reports
      SCHEDULE: "0 */6 * * *"
  
  # Database
  db:
    <<: *database-template
    environment:
      <<: *database-template.environment
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - db_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  db_data:
```

**Commands:**
```bash
# Start templated services
docker-compose up -d

# Check template instantiation
docker-compose ps

# View service configurations
docker-compose config | grep -A 10 "web-frontend:"

# Test different service types
curl http://localhost:8080
curl http://localhost:8081
docker-compose logs api-users

# Scale templated services
docker-compose up -d --scale worker-email=3

# Stop services
docker-compose down
```

**Explanation:**

- **Service templates**: Reusable patterns for common service types
- **Template instantiation**: Create multiple services from the same template
- **Customization**: Override template defaults for specific instances
- **Consistency**: Ensure similar services follow the same patterns
- **Maintainability**: Changes to templates affect all instances
- **Scalability**: Easy to add new services following established patterns

</details>