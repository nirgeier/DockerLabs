# In-Class Exercise - Parameterized Node.js Time Server

![DockerLabs Banner](../../assets/images/docker-logos.png)

---
    
Build a lightweight Node.js web server image that prints the current time and listens on a build-time configurable port.

## Task Checklist

- Use the minimal Node.js HTTP server (`server.js`) in the task folder.
- Use a Docker build argument to set the port value (`LISTEN_PORT`) and use it in the DockerFile
- Verify that the container print the message when it called

!!! warning "Requirements && Tips"
    - `docker build` accepts `--build-arg LISTEN_PORT=<port>` and succeeds without manual edits
    - Running the image with `docker run --rm -p <port>:<port>` serves the current time on the chosen port
    - Changing `LISTEN_PORT` during build changes both the exposed port in the image metadata and the runtime listener
    - The container process logs which port it is using when it starts
    - Use `ARG` in the Dockerfile to capture the build-time value and `ENV` to pass it to the Node.js process
    - Always bind to `0.0.0.0` so Docker can forward traffic into the container
    - A `curl` request or `docker run --rm image curl http://localhost:<port>` is a quick way to verify the response

!!! bug "Additional Task"
    - Once you have completed the task, change the port and test it again to ensure the server responds on the new port.


<details markdown="1">
<summary>Solution</summary>

### 1. Project Files

`server.js`

```javascript
const http = require("http");

const requestedPort = parseInt(process.env.LISTEN_PORT || "8080", 10);
const port = Number.isNaN(requestedPort) ? 8080 : requestedPort;

const server = http.createServer((req, res) => {
  const message = `Current time: ${new Date().toISOString()}\n`;
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end(message);
});

server.listen(port, "0.0.0.0", () => {
  console.log(`Listening on port ${port}`);
});
```

`Dockerfile`

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine

ARG LISTEN_PORT=8080

WORKDIR /usr/src/app

COPY server.js ./

ENV LISTEN_PORT=${LISTEN_PORT}

EXPOSE ${LISTEN_PORT}

CMD ["node", "server.js"]
```

### 2. Build the Image

```bash
docker build --build-arg LISTEN_PORT=9090 -t node-time-server .
```

### 3. Run and Test

```bash
docker run --rm -p 9090:9090 node-time-server
```

In another terminal, verify the output:

```bash
curl http://localhost:9090
```

Expected response:

```text
Current time: 2025-10-26T12:34:56.789Z
```

</details>
