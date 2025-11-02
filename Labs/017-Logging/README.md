# Lab 017 - Logging with Fluentd

This lab demonstrates how to use Fluentd with Docker to collect and manage logs from Docker containers, Docker events, and syslog.

## Prerequisites

- Docker installed and running
- Basic understanding of Docker and logging concepts

## Overview

Fluentd is an open-source data collector that provides a unified logging layer. In this lab, we'll:

1. Set up Fluentd as a logging driver for Docker containers
2. Collect Docker events using Fluentd
3. Configure syslog input for Fluentd

## Demo Scripts

- `demo.sh`: Main demo script showing Fluentd setup with Docker logging
- `fluentd.conf`: Fluentd configuration file
- `docker-compose.yml`: Docker Compose file to run Fluentd

## Running the Demo

1. Make sure Docker is running
2. Run the demo script: `./demo.sh`
3. Follow the on-screen instructions

## Key Concepts

- **Fluentd Logging Driver**: Docker can send container logs directly to Fluentd
- **Docker Events**: System events from Docker daemon (container start/stop, etc.)
- **Syslog Input**: Fluentd can receive syslog messages from various sources

## Cleanup

After the demo, run:

```bash
docker-compose down
```

## Additional Resources

- [Fluentd Documentation](https://docs.fluentd.org/)
- [Docker Logging Drivers](https://docs.docker.com/config/containers/logging/configure/)
