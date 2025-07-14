<a href="https://stackoverflow.com/users/1755598"><img src="https://stackexchange.com/users/flair/1951642.png" width="208" height="58" alt="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites"></a>

![Visitor Badge](https://visitor-badge.laobi.icu/badge?page_id=nirgeier)
[![Linkedin Badge](https://img.shields.io/badge/-nirgeier-blue?style=plastic&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/nirgeier/)](https://www.linkedin.com/in/nirgeier/)
[![Gmail Badge](https://img.shields.io/badge/-nirgeier@gmail.com-fcc624?style=plastic&logo=Gmail&logoColor=red&link=mailto:nirgeier@gmail.com)](mailto:nirgeier@gmail.com)
[![Outlook Badge](https://img.shields.io/badge/-nirg@codewizard.co.il-fcc624?style=plastic&logo=microsoftoutlook&logoColor=blue&link=mailto:nirg@codewizard.co.il)](mailto:nirg@codewizard.co.il)

---

![](../../resources/docker-logos.png)

---
![](../../resources/hands-on.png)

# Multi-Environment Docker Compose Setup <!-- omit in toc -->

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
