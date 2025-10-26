# In-Class Exercise - Docker Container Debugging Challenge

![DockerLabs Banner](../../assets/images/docker-logos.png)

---

## The Challenge

A web application container is crashing immediately after startup, and you need to debug it using Docker tools and techniques. Your mission: identify the root cause and fix the issue without modifying the original Dockerfile until you've diagnosed the problem.

## Scenario

You've inherited a Python Flask application that worked yesterday but now fails to start. The container exits with code 1, and you need to investigate:

- Why is the container crashing?
- What files or configurations are missing?
- How can you inspect a container that won't stay running?
- Can you fix it interactively before updating the Dockerfile?

## Task Checklist

- Build the provided broken Docker image
- Attempt to run it and observe the failure
- Use Docker debugging techniques to inspect the crashed container
- Override the entrypoint to keep the container alive for investigation
- Explore the filesystem and identify the missing configuration file
- Fix the issue interactively and verify the application works
- Update the Dockerfile with the permanent fix
- Document your debugging process

## Acceptance Criteria

- Identify the root cause without looking at the solution first
- Successfully get the application running using debugging techniques
- Demonstrate at least two different debugging methods (e.g., `docker logs`, entrypoint override, `docker exec`)
- Apply a permanent fix to the Dockerfile

## Tips

- `docker logs <container>` shows output even from crashed containers
- `docker run --entrypoint /bin/sh` can override the startup command
- `docker exec` requires a running container, but `docker run -it` with an overridden entrypoint keeps it alive
- The `--rm` flag is helpful during debugging to avoid container clutter
- Use `docker inspect` to see container configuration and state

<details markdown="1">
<summary>Solution</summary>

## Broken Application Files

### `app.py`

```python
from flask import Flask
import json

app = Flask(__name__)

# Load configuration
with open('/app/config.json', 'r') as f:
    config = json.load(f)

@app.route('/')
def hello():
    return f"Hello from {config['app_name']}! Running on port {config['port']}\n"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=config['port'])
```

### `requirements.txt`

```text
Flask==3.0.0
```

### `Dockerfile` (Broken Version)

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Missing: config.json is NOT copied!

EXPOSE 5000

CMD ["python", "app.py"]
```

## Step-by-Step Debugging Solution

### 1. Build the Broken Image

```bash
docker build -t broken-flask-app .
```

### 2. Attempt to Run (This Will Fail)

```bash
docker run --rm --name flask-debug -p 5000:5000 broken-flask-app
```

**Observation:** Container exits immediately with error.

### 3. Check the Logs

```bash
# If using --rm, run without it first to preserve the container
docker run --name flask-debug -p 5000:5000 broken-flask-app

# In another terminal
docker logs flask-debug
```

**Expected Output:**

```text
Traceback (most recent call last):
  File "/app/app.py", line 6, in <module>
    with open('/app/config.json', 'r') as f:
FileNotFoundError: [Errno 2] No such file or directory: '/app/config.json'
```

**Diagnosis:** Missing `config.json` file!

### 4. Debug by Overriding the Entrypoint

```bash
docker run --rm -it --entrypoint /bin/sh broken-flask-app
```

Inside the container:

```bash
ls -la /app/
# Shows: app.py, requirements.txt - but NO config.json!

# Verify Python can't find it
python -c "open('/app/config.json')"
# Error: No such file or directory
```

### 5. Create the Missing Configuration File

Create `config.json` locally:

```json
{
  "app_name": "Flask Debug Demo",
  "port": 5000
}
```

### 6. Fix Interactively with Volume Mount

```bash
# Mount the config file into the container for testing
docker run --rm -p 5000:5000 \
  -v $(pwd)/config.json:/app/config.json \
  broken-flask-app
```

Test the application:

```bash
curl http://localhost:5000
```

**Expected Output:**

```text
Hello from Flask Debug Demo! Running on port 5000
```

### 7. Apply Permanent Fix to Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY config.json .

EXPOSE 5000

CMD ["python", "app.py"]
```

### 8. Rebuild and Verify

```bash
docker build -t fixed-flask-app .
docker run --rm -p 5000:5000 fixed-flask-app
```

Test again:

```bash
curl http://localhost:5000
```

### 9. Cleanup

```bash
docker rm -f flask-debug  # If you created it without --rm
docker image rm broken-flask-app fixed-flask-app
```

## Key Debugging Techniques Demonstrated

1. **Container Logs:** `docker logs <container>` - View stdout/stderr from crashed containers
2. **Entrypoint Override:** `docker run --entrypoint /bin/sh` - Start a shell instead of the app
3. **Interactive Exploration:** `docker run -it` - Explore the container filesystem
4. **Volume Mounting:** `-v` flag - Test fixes without rebuilding
5. **Container Inspection:** `docker inspect <container>` - View full container config
6. **Process Monitoring:** `docker top <container>` - See running processes (if container stays up)

## Common Docker Debugging Commands Reference

```bash
# View logs from a stopped container
docker logs <container>

# Start container with shell access
docker run --rm -it --entrypoint /bin/sh <image>

# Execute command in running container
docker exec -it <container> /bin/sh

# Inspect container configuration
docker inspect <container>

# View container filesystem changes
docker diff <container>

# Copy files from container to host
docker cp <container>:/path/to/file ./local-path

# View container resource usage
docker stats <container>

# See running processes
docker top <container>
```

</details>
