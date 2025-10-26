#!/bin/bash

# Solution script for Lab 005 - Docker Compose: WordPress & MariaDB
# This script demonstrates how to use Docker Compose to orchestrate a WordPress site with a MariaDB backend.

set -e

COMMON_FILE="../../_utils/common.sh"
if [ -f "$COMMON_FILE" ]; then
  source "$COMMON_FILE"
else
  # Fallback colors if common.sh is missing
  Color_Off='\033[0m'
  Green='\033[0;32m'
  Yellow='\033[0;33m'
  Red='\033[0;31m'
fi

echo -e "${Yellow}Stopping and removing any existing containers...${Color_Off}"
docker-compose down || true
echo -e "${Yellow}Removing any existing volumes...${Color_Off}"
docker volume rm Labs_005-DockerCompose_db_data 2>/dev/null || true
echo -e "${Green}Starting WordPress & MariaDB stack with Docker Compose...${Color_Off}"
docker-compose up -d
echo -e "${Yellow}Checking running containers...${Color_Off}"
docker-compose ps
echo -e "${Green}WordPress should now be available at: http://localhost${Color_Off}"
echo -e "${Yellow}You can complete the WordPress setup in your browser.${Color_Off}"
echo -e "${Yellow}To view logs:${Color_Off}"
echo -e "  docker-compose logs wordpress"
echo -e "  docker-compose logs db"
echo -e "${Yellow}To stop and remove the stack:${Color_Off}"
echo -e "  docker-compose down"
echo -e "${Green}Lab 005 - Docker Compose solution completed!${Color_Off}"
LAB_DIR="$(dirname "$0")"
cd "$LAB_DIR"

# Detect docker-compose command
if command -v docker &>/dev/null && docker-compose version &>/dev/null; then
  DC="docker compose"
elif command -v docker-compose &>/dev/null; then
  DC="docker-compose"
else
  echo -e "${Red}Neither 'docker compose' nor 'docker-compose' is available. Please install Docker Compose.${Color_Off}"
  exit 1
fi

echo -e "${Yellow}Stopping and removing any existing containers...${Color_Off}"
$DC down || true

echo -e "${Yellow}Removing any existing volumes...${Color_Off}"
docker volume rm Labs_005-DockerCompose_db_data 2>/dev/null || true

echo -e "${Green}Starting WordPress & MariaDB stack with Docker Compose...${Color_Off}"
$DC up -d

# Wait for the database to initialize
sleep 10
echo -e "${Yellow}Checking running containers...${Color_Off}"
$DC ps

echo -e "${Green}WordPress should now be available at: http://localhost${Color_Off}"
echo -e "${Yellow}You can complete the WordPress setup in your browser.${Color_Off}"

echo -e "${Yellow}To view logs:${Color_Off}"
echo -e "  $DC logs wordpress"
echo -e "  $DC logs db"

echo -e "${Yellow}To stop and remove the stack:${Color_Off}"
echo -e "  $DC down"

echo -e "${Green}Lab 005 - Docker Compose solution completed!${Color_Off}"
