

![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 006 - Multi-Environment Docker Compose Setup

- A comprehensive example of structuring Docker Compose files for multiple environments
- Demonstrates environment-specific overrides and configuration management
- Each environment is fully isolated with its own configuration and services

### Pre-Requirements <!-- omit in toc -->

- Docker installed
- Docker Compose knowledge
- Basic understanding of environment variables

---

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Step 01 - Understanding the Base Configuration](#step-01---understanding-the-base-configuration)
- [Step 02 - Development Environment](#step-02---development-environment)
- [Step 03 - Production Environment](#step-03---production-environment)
- [Step 04 - Environment Variables](#step-04---environment-variables)
  - [Shared Variables (`.env`)](#shared-variables-env)
  - [Development Variables (`.env.dev`)](#development-variables-envdev)
  - [Production Variables (`.env.prod`)](#production-variables-envprod)
- [Step 05 - Quick Start with Scripts](#step-05---quick-start-with-scripts)
  - [Using the run.sh Script](#using-the-runsh-script)
- [Step 06 - Manual Commands](#step-06---manual-commands)
  - [Start Specific Environment](#start-specific-environment)
  - [Stop Services](#stop-services)
  - [View Logs](#view-logs)
  - [Scale Services (Production)](#scale-services-production)
- [Step 07 - Testing the Setup](#step-07---testing-the-setup)
  - [Interactive Demo](#interactive-demo)
  - [Manual Testing](#manual-testing)
- [Step 08 - Clean Up](#step-08---clean-up)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Debugging Commands](#debugging-commands)
  - [Environment-Specific Notes](#environment-specific-notes)

## Overview

This lab demonstrates how to structure Docker Compose files for multiple environments using:

- **Base Configuration**: Common services shared across environments
- **Environment Overrides**: Specific configurations for development and production
- **Environment Variables**: Centralized configuration management
- **Utility Scripts**: Easy environment management

## Project Structure

```
Labs/006-DockerCompose-env/
├── docker-compose.yml          # Base services configuration
├── docker-compose.dev.yml      # Development overrides
├── docker-compose.prod.yml     # Production overrides
├── .env                        # Shared environment variables
├── .env.dev                    # Development-specific variables
├── .env.prod                   # Production-specific variables
├── README.md                   # This documentation
├── run.sh                      # Bash script for environment management
├── demo.sh                     # Interactive demonstration
├── init.sql                    # Database initialization
├── html/
│   └── index.html             # Sample web application
└── api/
    ├── package.json           # Node.js API dependencies
    └── server.js              # Sample API server
```

## Step 01 - Understanding the Base Configuration

The `docker-compose.yml` file contains the core service definitions that are common across all environments:

- **Web Service**: Nginx web server
- **API Service**: Node.js backend application  
- **Database Service**: PostgreSQL database
- **Cache Service**: Redis caching layer

All services use environment variables with default values using the `${VARIABLE:-default}` syntax for flexibility.

## Step 02 - Development Environment

The development environment (`docker-compose.dev.yml`) provides developer-friendly features:

```bash
# Start development environment
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml up -d
```

**Development Features:**

- Hot reload enabled for API service (nodemon)
- Debug ports exposed (9229 for Node.js debugging)
- Additional development tools:
  - Adminer for database management
  - MailCatcher for email testing
- Read-write volumes for live code editing
- Detailed logging enabled
- Non-standard ports to avoid conflicts (8000, 3001, 5433, 6380)

**Development Services Access:**

- Web Application: `http://localhost:8000`
- API: `http://localhost:3001`
- Database Admin (Adminer): `http://localhost:8080`
- Mail Catcher: `http://localhost:1080`

## Step 03 - Production Environment

The production environment (`docker-compose.prod.yml`) focuses on performance and security:

```bash
# Start production environment
docker-compose --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**Production Features:**

- Multiple service replicas for high availability
- Read-only volumes for security
- Optimized restart policies
- Structured logging with rotation
- Monitoring with Prometheus
- Standard service ports (80, 3000, 5432, 6379)

**Production Services Access:**

- Web Application: `http://localhost:80`
- API: `http://localhost:3000`
- Monitoring (Prometheus): `http://localhost:9090`

## Step 04 - Environment Variables

### Shared Variables (`.env`)

Common configuration across all environments:

| Variable      | Description                           |
|---------------|---------------------------------------|
| `APP_NAME`    | Application name for container naming |
| `ENVIRONMENT` | Current environment identifier        |
| `DB_NAME`     | Database name                         |
| `DB_USER`     | Database user                         |
| `API_SECRET`  | API authentication secret             |
| `LOG_LEVEL`   | Logging verbosity                     |

### Development Variables (`.env.dev`)

| Variable/Setting         | Description                              |
|-------------------------|------------------------------------------|
| Non-standard ports      | Avoid conflicts with other services       |
| Debug-friendly config   | Enables debug mode and verbose logging    |
| Dev DB credentials      | Uses development database credentials     |
| Enhanced logging        | More detailed logs for debugging          |

### Production Variables (`.env.prod`)

| Variable/Setting           | Description                                 |
|---------------------------|---------------------------------------------|
| Standard service ports     | Uses standard ports for production          |
| Strong, secure passwords  | Enforces strong credentials                 |
| Optimized timeouts         | Sets timeouts suitable for production       |
| Security-focused config    | Enables production security best practices  |

## Step 05 - Quick Start with Scripts

### Using the run.sh Script

```bash
# Development environment
./run.sh dev up        # Start development
./run.sh dev down      # Stop development
./run.sh dev logs      # View development logs
./run.sh dev ps        # Show service status

# Production environment
./run.sh prod up       # Start production
./run.sh prod down     # Stop production
./run.sh prod logs     # View production logs

# Help
./run.sh help          # Show usage information
```

## Step 06 - Manual Commands

### Start Specific Environment

```bash
# Development
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml up -d

# Production
docker-compose --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Stop Services

```bash
# Development
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml down

# Production  
docker-compose --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml down
```

### View Logs

```bash
# All services logs
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml logs -f

# Specific service logs
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml logs -f api
```

### Scale Services (Production)

```bash
# Scale API service to 5 replicas
docker-compose --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml up -d --scale api=5
```

## Step 07 - Testing the Setup

### Interactive Demo

Run the complete demonstration:

```bash
# Run the interactive demo
./demo.sh
```

The demo will:

1. Start development environment
2. Test the application
3. Switch to production environment  
4. Show differences between environments
5. Clean up

### Manual Testing

```bash
# Start development environment
./run.sh dev up

# Test the API
curl -s http://localhost:3001/health | python3 -m json.tool

# Test the web application
curl -s http://localhost:8000

# Check service status
./run.sh dev ps
```

## Step 08 - Clean Up

```bash
# Stop current environment
./run.sh dev down     # or ./run.sh prod down

# Complete cleanup (removes volumes)
./run.sh dev down && ./run.sh prod down
docker system prune -f

# Or manually
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml down -v
docker-compose --env-file .env.prod -f docker-compose.yml -f docker-compose.prod.yml down -v
```

## Best Practices

1. **Environment Separation**: Clear separation between dev, staging, and production configurations
2. **Security**: Different secrets and passwords per environment
3. **Scalability**: Production setup with multiple replicas and monitoring
4. **Development Experience**: Hot reload, debugging ports, and development tools
5. **Configuration Management**: Centralized environment variable management
6. **Volume Management**: Read-only volumes in production, read-write in development
7. **Logging**: Environment-appropriate logging levels and rotation
8. **Networking**: Consistent network setup across environments

## Advanced Docker Compose Techniques

### YAML Anchors and Aliases

Docker Compose supports YAML anchors (`&`) and aliases (`*`) to reduce duplication in your compose files. This is particularly useful when multiple services share common configuration.

**Basic Anchors Example:**

```yaml
# Define reusable configuration blocks
x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"

x-healthcheck: &default-healthcheck
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s

services:
  web:
    image: nginx:alpine
    logging: *default-logging
    healthcheck:
      <<: *default-healthcheck
      test: ["CMD", "curl", "-f", "http://localhost"]
  
  api:
    image: node:18-alpine
    logging: *default-logging
    healthcheck:
      <<: *default-healthcheck
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
```

### Extension Fields (x-*)

Extension fields are special YAML keys that start with `x-` and are ignored by Docker Compose. They're perfect for defining reusable configuration fragments.

**Common Configuration Patterns:**

```yaml
# Define common configurations as extension fields
x-common-variables: &common-vars
  TZ: UTC
  LOG_LEVEL: info

x-restart-policy: &restart-policy
  restart: unless-stopped

x-resource-limits: &resource-limits
  deploy:
    resources:
      limits:
        cpus: '0.50'
        memory: 512M
      reservations:
        cpus: '0.25'
        memory: 256M

services:
  service1:
    <<: *restart-policy
    <<: *resource-limits
    environment:
      <<: *common-vars
      SERVICE_NAME: service1
  
  service2:
    <<: *restart-policy
    <<: *resource-limits
    environment:
      <<: *common-vars
      SERVICE_NAME: service2
```

### Merge Keys (<<:)

The merge key `<<:` allows you to merge one or more mappings into the current mapping. You can merge multiple anchors:

```yaml
x-base-service: &base-service
  restart: unless-stopped
  networks:
    - app-network

x-logging-config: &logging-config
  logging:
    driver: json-file
    options:
      max-size: "10m"

x-health-config: &health-config
  healthcheck:
    interval: 30s
    timeout: 10s
    retries: 3

services:
  web:
    <<: [*base-service, *logging-config, *health-config]
    image: nginx:alpine
    ports:
      - "80:80"
  
  api:
    <<: [*base-service, *logging-config, *health-config]
    image: node:18-alpine
    ports:
      - "3000:3000"
```

### Complex Fragment Patterns

**Service Templates:**

```yaml
# Define a complete service template
x-app-template: &app-template
  restart: unless-stopped
  networks:
    - backend
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"
  deploy:
    resources:
      limits:
        cpus: '1.0'
        memory: 1G

# Define environment-specific configurations
x-dev-config: &dev-config
  build:
    context: .
    target: development
  volumes:
    - ./src:/app/src
  environment:
    NODE_ENV: development

x-prod-config: &prod-config
  image: myapp:latest
  read_only: true
  environment:
    NODE_ENV: production

services:
  # Development service
  app-dev:
    <<: [*app-template, *dev-config]
    ports:
      - "3001:3000"
  
  # Production service
  app-prod:
    <<: [*app-template, *prod-config]
    ports:
      - "3000:3000"
```

### Combining Anchors with Override

You can override specific values from anchors:

```yaml
x-database: &database-config
  image: postgres:15-alpine
  restart: unless-stopped
  networks:
    - db-network
  healthcheck:
    test: ["CMD-SHELL", "pg_isready"]
    interval: 10s
    timeout: 5s
    retries: 5

services:
  main-db:
    <<: *database-config
    container_name: main-database
    environment:
      POSTGRES_DB: maindb
    volumes:
      - main-db-data:/var/lib/postgresql/data
  
  test-db:
    <<: *database-config
    container_name: test-database
    environment:
      POSTGRES_DB: testdb
    volumes:
      - test-db-data:/var/lib/postgresql/data
    # Override the restart policy for test db
    restart: "no"
```

### Real-World Example: Microservices

```yaml
version: '3.8'

# Common configurations
x-service-defaults: &service-defaults
  restart: unless-stopped
  networks:
    - app-network
  logging: &logging-config
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

x-node-service: &node-service
  <<: *service-defaults
  image: node:18-alpine
  healthcheck:
    interval: 30s
    timeout: 10s
    retries: 3

x-environment-common: &env-common
  NODE_ENV: ${NODE_ENV:-production}
  LOG_LEVEL: ${LOG_LEVEL:-info}
  DATABASE_URL: postgresql://db:5432/${DB_NAME}

services:
  user-service:
    <<: *node-service
    container_name: user-service
    environment:
      <<: *env-common
      SERVICE_NAME: user-service
      PORT: 3001
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "-", "http://localhost:3001/health"]
    ports:
      - "3001:3001"

  order-service:
    <<: *node-service
    container_name: order-service
    environment:
      <<: *env-common
      SERVICE_NAME: order-service
      PORT: 3002
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "-", "http://localhost:3002/health"]
    ports:
      - "3002:3002"

  payment-service:
    <<: *node-service
    container_name: payment-service
    environment:
      <<: *env-common
      SERVICE_NAME: payment-service
      PORT: 3003
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "-", "http://localhost:3003/health"]
    ports:
      - "3003:3003"

networks:
  app-network:
    driver: bridge

volumes:
  db-data:
```

### Benefits of Using Fragments

1. **DRY Principle**: Don't Repeat Yourself - define common configuration once
2. **Consistency**: Ensure all services use the same base configuration
3. **Maintainability**: Update configuration in one place
4. **Readability**: Cleaner, more organized compose files
5. **Scalability**: Easy to add new services with standard configuration

### Tips for Using Fragments

- Use meaningful names for your anchors (e.g., `&common-logging`, `&base-service`)
- Group related configuration into logical fragments
- Place extension fields at the top of your compose file
- Document what each fragment contains
- Test your merged configuration with `docker compose config`
- Use fragments for environment-specific configurations
- Combine fragments with environment variables for maximum flexibility

## Troubleshooting

### Common Issues

- **Port conflicts**: Ensure no other services are using the same ports
- **Environment variables**: Verify all required variables are set in `.env` files
- **Docker daemon**: Ensure Docker is running and accessible

### Debugging Commands

```bash
# Check service logs
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml logs service_name

# Check service status
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml ps

# Inspect container
docker inspect container_name

# Execute command in container
docker-compose --env-file .env.dev -f docker-compose.yml -f docker-compose.dev.yml exec service_name bash
```

### Environment-Specific Notes

| Environment/Aspect | Notes                                                        |
|--------------------|--------------------------------------------------------------|
| Development        | Services may take longer to start due to volume mounts        |
| Production         | Services use restart policies and may auto-restart on failure |
| Networking         | All services communicate through Docker networks              |

---

![](../../resources/well-done.png)
