#!/bin/bash

set -e

echo "=== Lab 017: Logging with Fluentd ==="
echo

echo "Starting Fluentd..."
docker-compose up -d
echo "Fluentd started."
echo

echo "Waiting for Fluentd to be ready..."
sleep 5
echo

echo "=== Demo 1: Container Logging with Fluentd ==="
echo "Running a container with Fluentd logging driver..."
docker run --rm --log-driver=fluentd --log-opt fluentd-address=localhost:24224 --name test-container alpine echo "Hello from container with Fluentd logging"
echo "Container logs should be visible in Fluentd output."
echo

echo "Checking Fluentd logs..."
docker-compose logs fluentd | tail -20
echo

echo "=== Demo 2: Syslog with Fluentd ==="
echo "Sending a syslog message to Fluentd..."
# Assuming logger is available, or use a container
docker run --rm --net host alpine sh -c 'echo '\''<34>Oct 11 22:14:15 mymachine su: su root failed for lonvick on /dev/pts/8'\'' | nc -u -w 1 localhost 5140'
echo "Syslog message sent."
echo

echo "Checking Fluentd logs again..."
docker-compose logs fluentd | tail -20
echo

echo "=== Demo 3: Docker Events (Manual) ==="
echo "To log Docker events with Fluentd, you can use:"
echo "docker events --since '1m' | docker run --rm -i fluent/fluentd fluent-cat docker.events"
echo "But for this demo, we'll simulate by running a container and checking events."
echo

echo "Running another container to generate events..."
docker run --rm --log-driver=fluentd --log-opt fluentd-address=localhost:24224 alpine echo "Another message"
echo

echo "Checking logs..."
docker-compose logs fluentd | tail -30
echo

echo "=== Cleanup ==="
echo "To stop Fluentd: docker-compose down"
echo "Demo completed."