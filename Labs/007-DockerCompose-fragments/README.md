

![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 007 - Advanced Docker Compose - Fragments, Includes & Extends <!-- omit in toc -->

This lab covers advanced Docker Compose techniques including YAML fragments, composition patterns, includes, and the extends keyword. Learn how to build maintainable, reusable, and DRY (Don't Repeat Yourself) Docker Compose configurations.

## Table of Contents 

- [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [YAML Anchors and Aliases](#yaml-anchors-and-aliases)
  - [Basic Anchors](#basic-anchors)
  - [Extension Fields](#extension-fields)
  - [Merge Keys](#merge-keys)
- [Docker Compose Include](#docker-compose-include)
  - [Basic Include Syntax](#basic-include-syntax)
  - [Include with Path](#include-with-path)
  - [Include Best Practices](#include-best-practices)
- [Docker Compose Extends (Legacy)](#docker-compose-extends-legacy)
  - [Extends Syntax](#extends-syntax)
  - [When to Use Extends](#when-to-use-extends)
- [Real-World Examples](#real-world-examples)
  - [Example 1: Microservices Architecture](#example-1-microservices-architecture)
  - [Example 2: Multi-Environment Setup](#example-2-multi-environment-setup)
  - [Example 3: Modular Configuration](#example-3-modular-configuration)
- [Best Practices](#best-practices)
- [Common Patterns](#common-patterns)
  - [Pattern 1: Base Service Template](#pattern-1-base-service-template)
  - [Pattern 2: Environment Overrides](#pattern-2-environment-overrides)
  - [Pattern 3: Multi-Container Application](#pattern-3-multi-container-application)
- [Troubleshooting](#troubleshooting)
  - [Common Issues and Solutions](#common-issues-and-solutions)
  - [Debugging Commands](#debugging-commands)
- [Hands-On Exercises](#hands-on-exercises)
  - [Exercise 1: Create a Microservices Setup](#exercise-1-create-a-microservices-setup)
  - [Exercise 2: Multi-Environment Configuration](#exercise-2-multi-environment-configuration)
  - [Exercise 3: Modular Infrastructure](#exercise-3-modular-infrastructure)
- [Useful Commands](#useful-commands)


---

## Overview

As Docker Compose configurations grow, managing multiple services with similar configurations becomes challenging. This lab teaches you advanced composition techniques to:

- **Reduce duplication** using YAML anchors and fragments
- **Modularize configurations** with includes
- **Share common settings** across services
- **Manage multi-environment setups** efficiently
- **Create reusable templates** for services

## Prerequisites

- Docker installed (version 20.10+)
- Docker Compose V2 (docker compose, not docker-compose)
- Basic understanding of YAML syntax
- Familiarity with basic Docker Compose concepts

Verify your setup:

```bash
docker compose version
# Should show: Docker Compose version v2.x.x or higher
```

---

## YAML Anchors and Aliases

YAML anchors (`&`) and aliases (`*`) allow you to define reusable configuration blocks within a single YAML file.

### Basic Anchors

**Syntax:**

- `&anchor-name` - Define an anchor
- `*anchor-name` - Reference an anchor
- `<<: *anchor-name` - Merge an anchor

**Simple Example:**

```yaml
version: '3.8'

# Define a logging configuration anchor
x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"

services:
  web:
    image: nginx:alpine
    logging: *default-logging
  
  api:
    image: node:18-alpine
    logging: *default-logging
  
  worker:
    image: python:3.11-alpine
    logging: *default-logging
```

### Extension Fields

Extension fields start with `x-` and are ignored by Docker Compose but can be used as anchors. This keeps your configuration organized.

**Complete Service Template:**

```yaml
version: '3.8'

# Extension fields - ignored by Docker Compose
x-common-variables: &common-vars
  TZ: UTC
  LOG_LEVEL: ${LOG_LEVEL:-info}
  ENVIRONMENT: ${ENVIRONMENT:-production}

x-restart-policy: &restart-policy
  restart: unless-stopped

x-healthcheck-defaults: &healthcheck-defaults
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s

x-resource-limits: &resource-limits
  deploy:
    resources:
      limits:
        cpus: '1.0'
        memory: 1G
      reservations:
        cpus: '0.5'
        memory: 512M

x-logging-config: &logging-config
  logging:
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"
      labels: "service"

# Actual services using the fragments
services:
  web:
    image: nginx:alpine
    <<: [*restart-policy, *logging-config, *resource-limits]
    environment:
      <<: *common-vars
      SERVICE_NAME: web
    healthcheck:
      <<: *healthcheck-defaults
      test: ["CMD", "curl", "-f", "http://localhost"]
    ports:
      - "80:80"
    networks:
      - frontend

  api:
    image: node:18-alpine
    <<: [*restart-policy, *logging-config, *resource-limits]
    environment:
      <<: *common-vars
      SERVICE_NAME: api
    healthcheck:
      <<: *healthcheck-defaults
      test: ["CMD", "wget", "-q", "-O", "-", "http://localhost:3000/health"]
    ports:
      - "3000:3000"
    networks:
      - frontend
      - backend

networks:
  frontend:
  backend:
```

### Merge Keys

The merge key (`<<:`) allows combining multiple anchors:

**Multiple Anchor Merging:**

```yaml
version: '3.8'

# Define separate configuration aspects
x-base-config: &base-config
  restart: unless-stopped
  networks:
    - app-network

x-monitoring: &monitoring
  labels:
    - "prometheus.scrape=true"
    - "prometheus.port=9090"

x-security: &security
  security_opt:
    - no-new-privileges:true
  read_only: true

x-node-service: &node-service
  image: node:18-alpine
  healthcheck:
    test: ["CMD", "node", "--version"]
    interval: 30s

services:
  # Merge multiple fragments
  user-service:
    <<: [*base-config, *monitoring, *security, *node-service]
    container_name: user-service
    environment:
      SERVICE: users
    ports:
      - "3001:3000"
  
  order-service:
    <<: [*base-config, *monitoring, *security, *node-service]
    container_name: order-service
    environment:
      SERVICE: orders
    ports:
      - "3002:3000"

networks:
  app-network:
    driver: bridge
```

---

## Docker Compose Include

The `include` directive (Compose V2.20+) allows you to split your configuration across multiple files and combine them at runtime.

### Basic Include Syntax

**Main compose file (`docker-compose.yml`):**

```yaml
include:
  - ./compose-services.yml
  - ./compose-networks.yml
  - ./compose-volumes.yml

# You can still define additional services here
services:
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
```

**Separate service file (`compose-services.yml`):**

```yaml
services:
  api:
    image: node:18-alpine
    ports:
      - "3000:3000"
  
  worker:
    image: python:3.11-alpine
```

### Include with Path

You can organize includes in subdirectories:

**Project Structure:**

```text
project/
├── docker-compose.yml
├── compose/
│   ├── databases.yml
│   ├── services.yml
│   ├── monitoring.yml
│   └── dev/
│       ├── overrides.yml
│       └── debug.yml
└── .env
```

**docker-compose.yml:**

```yaml
include:
  - path: ./compose/databases.yml
  - path: ./compose/services.yml
  - path: ./compose/monitoring.yml
  # Conditional includes based on environment
  - path: ./compose/dev/overrides.yml
    env_file: .env.dev
```

### Include Best Practices

1. **Logical Separation:**

```yaml
# docker-compose.yml - Main orchestration
include:
  - ./infrastructure/databases.yml      # All database services
  - ./infrastructure/cache.yml          # Redis, Memcached, etc.
  - ./infrastructure/queues.yml         # RabbitMQ, Kafka, etc.
  - ./application/backend-services.yml  # Backend microservices
  - ./application/frontend-services.yml # Frontend services
  - ./monitoring/observability.yml      # Prometheus, Grafana, etc.
```

1. **Environment-Specific Includes:**

```yaml
# docker-compose.yml
include:
  - ./base/services.yml
  - path: ./envs/${ENVIRONMENT:-dev}.yml
```

1. **Shared Fragments Across Includes:**

```yaml
# shared/fragments.yml
x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"

# services/api.yml
include:
  - path: ../shared/fragments.yml

services:
  api:
    image: node:18-alpine
    logging: *default-logging
```

---

## Docker Compose Extends (Legacy)

> **Note:** The `extends` keyword is considered legacy. Modern Docker Compose recommends using `include` and YAML anchors instead. However, it's still supported for backward compatibility.

### Extends Syntax

**Base service file (`common.yml`):**

```yaml
services:
  base-service:
    image: node:18-alpine
    restart: unless-stopped
    logging:
      driver: json-file
      options:
        max-size: "10m"
```

**Main compose file:**

```yaml
services:
  api:
    extends:
      file: common.yml
      service: base-service
    container_name: api-service
    ports:
      - "3000:3000"
    environment:
      SERVICE_NAME: api
```

### When to Use Extends

Use `extends` when:

- Working with legacy Compose files
- Sharing configuration between different Compose files
- Need to override specific service configurations

**Prefer `include` and YAML anchors** for new projects as they provide:

- Better performance
- Clearer composition
- More flexibility
- Better tooling support

---

## Real-World Examples

### Example 1: Microservices Architecture

**File Structure:**

```text
microservices/
├── docker-compose.yml
├── fragments/
│   └── common.yml
├── infrastructure/
│   ├── databases.yml
│   ├── cache.yml
│   └── messaging.yml
└── services/
    ├── user-service.yml
    ├── order-service.yml
    └── payment-service.yml
```

**fragments/common.yml:**

```yaml
# Common configurations as extension fields
x-service-defaults: &service-defaults
  restart: unless-stopped
  networks:
    - microservices
  logging: &logging
    driver: json-file
    options:
      max-size: "10m"
      max-file: "3"

x-healthcheck: &healthcheck
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s

x-node-service: &node-service
  <<: *service-defaults
  image: node:18-alpine
  healthcheck:
    <<: *healthcheck

x-environment-common: &env-common
  NODE_ENV: ${NODE_ENV:-production}
  LOG_LEVEL: ${LOG_LEVEL:-info}
  REDIS_URL: redis://cache:6379
  DB_HOST: postgres
```

**infrastructure/databases.yml:**

```yaml
include:
  - path: ../fragments/common.yml

services:
  postgres:
    <<: *service-defaults
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${DB_NAME:-appdb}
      POSTGRES_USER: ${DB_USER:-admin}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-admin}"]
      <<: *healthcheck

volumes:
  postgres-data:
```

**services/user-service.yml:**

```yaml
include:
  - path: ../fragments/common.yml

services:
  user-service:
    <<: *node-service
    build:
      context: ./user-service
      dockerfile: Dockerfile
    environment:
      <<: *env-common
      SERVICE_NAME: user-service
      PORT: 3001
    ports:
      - "3001:3001"
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "-", "http://localhost:3001/health"]
      <<: *healthcheck
    depends_on:
      postgres:
        condition: service_healthy
```

**docker-compose.yml (Main):**

```yaml
include:
  - ./infrastructure/databases.yml
  - ./infrastructure/cache.yml
  - ./infrastructure/messaging.yml
  - ./services/user-service.yml
  - ./services/order-service.yml
  - ./services/payment-service.yml

networks:
  microservices:
    driver: bridge
```

### Example 2: Multi-Environment Setup

**Structure:**

```text
project/
├── docker-compose.yml
├── compose/
│   ├── base.yml
│   ├── fragments.yml
│   ├── dev.yml
│   └── prod.yml
└── .env
```

**compose/fragments.yml:**

```yaml
x-app-base: &app-base
  restart: unless-stopped
  networks:
    - app-net

x-dev-settings: &dev-settings
  build:
    target: development
  volumes:
    - ./src:/app/src:rw
  environment:
    NODE_ENV: development
    DEBUG: "*"

x-prod-settings: &prod-settings
  image: ${REGISTRY}/app:${VERSION}
  read_only: true
  security_opt:
    - no-new-privileges:true
  environment:
    NODE_ENV: production
```

**compose/dev.yml:**

```yaml
include:
  - path: ./fragments.yml

services:
  app-dev:
    <<: [*app-base, *dev-settings]
    container_name: app-dev
    ports:
      - "3001:3000"
    command: npm run dev
  
  # Development tools
  adminer:
    image: adminer:latest
    ports:
      - "8080:8080"
    networks:
      - app-net
```

**compose/prod.yml:**

```yaml
include:
  - path: ./fragments.yml

services:
  app-prod:
    <<: [*app-base, *prod-settings]
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
    ports:
      - "3000:3000"
    command: npm start
```

**docker-compose.yml:**

```yaml
include:
  - compose/base.yml
  - path: compose/${ENVIRONMENT:-dev}.yml

networks:
  app-net:
    driver: bridge
```

**Usage:**

```bash
# Development
ENVIRONMENT=dev docker compose up

# Production
ENVIRONMENT=prod docker compose up
```

### Example 3: Modular Configuration

**Complete modular setup with fragments and includes:**

```yaml
# docker-compose.yml
include:
  # Core infrastructure
  - path: ./infrastructure/postgres.yml
  - path: ./infrastructure/redis.yml
  - path: ./infrastructure/nginx.yml
  
  # Application services
  - path: ./services/api.yml
  - path: ./services/worker.yml
  - path: ./services/scheduler.yml
  
  # Monitoring stack
  - path: ./monitoring/prometheus.yml
  - path: ./monitoring/grafana.yml
  
  # Environment-specific overrides
  - path: ./overrides/${ENV:-development}.yml
    env_file: .env.${ENV:-development}

# Global networks
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
  monitoring:
    driver: bridge

# Global volumes
volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:
```

---

## Best Practices

1. **Use Extension Fields for Reusable Fragments:**
   ```yaml
   x-logging: &logging
     driver: json-file
     options:
       max-size: "10m"
   ```

2. **Organize Includes Logically:**

      - Group by function (infrastructure, services, monitoring)
      - Separate environment-specific configurations
      - Use subdirectories for clarity

3. **Name Anchors Descriptively:**

    ```yaml
    x-node-service-defaults: &node-service-defaults
    x-python-service-defaults: &python-service-defaults
    x-database-healthcheck: &database-healthcheck
    ```

4. **Validate Merged Configuration:**
      * Use Docker Compose Config Command:

      ```bash
      docker compose config
      ```

5. **Use Environment Variables:**
    * Use Common Environment Variables:

    ```yaml
    x-common-env: &common-env
      ENVIRONMENT: ${ENVIRONMENT:-production}
      LOG_LEVEL: ${LOG_LEVEL:-info}
    ```

6. **Document Your Fragments:**
    * Include comments in your fragment files to explain their purpose and usage.

    ```yaml
    # Logging configuration - 10MB max size, 3 file rotation
    x-logging: &logging
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
    ```

7. **Keep Fragments DRY but Readable:**
      * Don't over-fragment
      * Balance reusability with readability
      * Use fragments for truly common configurations

8. **Version Control:**
    * Commit all fragment files
    * Document the composition structure in README
    * Use `.env.example` for required variables


---

## Common Patterns

### Pattern 1: Base Service Template

```yaml
x-app-template: &app
  restart: unless-stopped
  networks:
    - app-network
  logging:
    driver: json-file
    options:
      max-size: "10m"
  healthcheck:
    interval: 30s
    timeout: 10s
    retries: 3

services:
  service1:
    <<: *app
    image: service1:latest
  
  service2:
    <<: *app
    image: service2:latest
```

### Pattern 2: Environment Overrides

```yaml
x-base: &base
  image: app:latest

x-dev: &dev
  <<: *base
  volumes:
    - ./src:/app/src
  environment:
    DEBUG: "true"

x-prod: &prod
  <<: *base
  read_only: true
  environment:
    DEBUG: "false"
```

### Pattern 3: Multi-Container Application

```yaml
x-defaults: &defaults
  restart: unless-stopped
  networks:
    - app

services:
  web:
    <<: *defaults
    image: nginx
    depends_on:
      - api
  
  api:
    <<: *defaults
    image: node
    depends_on:
      - db
  
  db:
    <<: *defaults
    image: postgres
```

---

## Troubleshooting

### Common Issues and Solutions

1. **Anchor Not Found:**

    ```bash
    Error: Unknown anchor 'service-defaults'
    ```
    **Solution:** Ensure the anchor is defined before it's referenced. Anchors must be defined in the same file or in an included file that's loaded first.

2. **Merge Conflicts:**

    ```yaml
    # This will override, not merge
    service:
      <<: *base
      environment:  # This replaces entire environment from *base
        NEW_VAR: value

    # Correct way to merge:
    service:
      <<: *base
      environment:
        <<: *base-env  # Merge base environment
        NEW_VAR: value # Add new variable
    ```

3. **Include Path Issues:**

    ```bash
    Error: include path not found: ./compose/services.yml
    ```

    **Solution:** Use paths relative to the main compose file location.

4. **Circular Dependencies:**

    ```yaml
    # Avoid this
    include:
      - a.yml  # includes b.yml
      - b.yml  # includes a.yml
    ```

5. **Validation Errors:**

    ```bash
    # Validate your configuration
    docker compose config --quiet

    # View merged configuration
    docker compose config > merged-config.yml
    ```

### Debugging Commands

   * Debug with Docker Compose Config:
  
      ```bash
      # Show final merged configuration
      docker compose config

      # Validate without starting services
      docker compose config --quiet

      # Show configuration for specific service
      docker compose config api

      # List all services
      docker compose config --services

      # Show volumes
      docker compose config --volumes

      # Show networks
      docker compose config --networks

      # Resolve environment variables
      docker compose config --resolve-image-digests
      ```

---

## Hands-On Exercises

### Exercise 1: Create a Microservices Setup

Create a compose configuration with:

- 3 microservices using the same base template
- Shared logging configuration
- Individual health checks
- Common environment variables

### Exercise 2: Multi-Environment Configuration

Build a setup that supports:

- Development environment with hot-reload
- Staging environment with production-like settings
- Production environment with security hardening
- All using shared base configuration

### Exercise 3: Modular Infrastructure

Design a modular compose setup:

- Separate files for databases, caching, messaging
- Include-based composition
- Environment-specific overrides
- Shared network and volume definitions

---

## Useful Commands

```bash
# View merged configuration
docker compose config

# Validate compose file
docker compose config --quiet

# Start with specific environment
ENV=production docker compose up -d

# View specific service configuration
docker compose config service-name

# List all services
docker compose config --services

# Pull all images
docker compose pull

# Build all services
docker compose build

# Up with build
docker compose up --build

# Scale specific service
docker compose up -d --scale api=3

# View logs
docker compose logs -f service-name

# Stop all services
docker compose down

# Remove volumes
docker compose down -v
```

---

![Well Done](../assets/images/well-done.png)