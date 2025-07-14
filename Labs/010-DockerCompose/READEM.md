# Docker Compose Lab

This lab demonstrates how to use Docker Compose to manage multi-container Docker applications.

## Prerequisites

- Docker installed
- Docker Compose installed

## Common Docker Compose Commands

| Command                                   | Description                                                                          |
| ----------------------------------------- | ------------------------------------------------------------------------------------ |
| `docker-compose up`                       | Start all services defined in `docker-compose.yaml` in the foreground.               |
| `docker-compose up -d`                    | Start all services in detached mode (in the background).                             |
| `docker-compose down`                     | Stop and remove all running containers defined in the Compose file.                  |
| `docker-compose logs`                     | Show logs for all services.                                                          |
| `docker-compose logs <service>`           | Show logs for a specific service.                                                    |
| `docker-compose ps`                       | List containers managed by this Compose project.                                     |
| `docker-compose exec <service> <command>` | Run a command in a running service container (e.g., `docker-compose exec web bash`). |
| `docker-compose build`                    | Build or rebuild services.                                                           |

## Example

To start the application:

```
docker-compose up -d
```

To stop and clean up:

```
docker-compose down
```
