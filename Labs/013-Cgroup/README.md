![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 013 - Resource Isolation with Linux Cgroups

- This lab covers resource isolation using Linux Cgroups in Docker containers.
- You will learn how to limit CPU, memory, and other resources for containers to prevent resource contention and ensure fair sharing.
- By the end of this lab, you will understand how to use Docker commands to enforce resource constraints.

---

## CPU Limits

- Use `--cpus` to limit CPU usage as a fraction of available cores.

```sh
# Limit container to 0.5 CPU cores
docker run -d --cpus=0.5 --name cpu-limited nginx

# Check resource usage
docker stats cpu-limited

# Clean up
docker stop cpu-limited
docker rm cpu-limited
```

## Memory Limits

- Use `--memory` to set a hard memory limit.

```sh
# Limit container to 128MB RAM
docker run -d --memory=128m --name mem-limited nginx

# Check resource usage
docker stats mem-limited

# Test memory limit by running a memory-intensive process
docker run --memory=50m stress --vm 1 --vm-bytes 100m

# Clean up
docker stop mem-limited
docker rm mem-limited
```

## CPU Sets

- Use `--cpuset-cpus` to pin container to specific CPU cores.

```sh
# Pin container to CPU cores 0 and 1
docker run -d --cpuset-cpus=0,1 --name cpu-pinned nginx

# Check which CPUs the container is using
docker exec cpu-pinned cat /proc/self/status | grep Cpus_allowed

# Clean up
docker stop cpu-pinned
docker rm cpu-pinned
```

## Combined Resource Limits

- Combine multiple resource constraints for comprehensive control.

```sh
# Limit both CPU and memory
docker run -d --cpus=1.0 --memory=256m --name combined-limits nginx

# Check all resource limits
docker inspect combined-limits | grep -A 10 "HostConfig"

# Clean up
docker stop combined-limits
docker rm combined-limits
```

## Monitoring Resource Usage

- Use `docker stats` to monitor container resource usage in real-time.

```sh
# Start multiple containers with different limits
docker run -d --cpus=0.5 --memory=128m --name container1 nginx
docker run -d --cpus=1.0 --memory=256m --name container2 nginx

# Monitor resource usage
docker stats

# Clean up
docker stop container1 container2
docker rm container1 container2
```
