![DockerLabs Banner](../../assets/images/docker-logos.png)

---

# In-Class Exercise - Docker Logs and Container Management
    
- Run a `cowsay` Docker container with a custom message
- Send a message to the cowsay container (e.g., "Hello from Docker!")
- Stop the container after execution
- Extract and save the container logs to the host machine for debugging purposes
- Hint: Use `docker run`, `docker logs`, and output redirection

<details markdown="1">
<summary>Solution</summary>

## Step-by-Step Solution

1. **Run the cowsay container with a custom message**

   ```bash
   docker run --name my-cowsay docker/whalesay cowsay "Hello from Docker!"
   ```

2. **Verify the container has stopped**

   The container stops automatically after execution. You can verify with:

   ```bash
   docker ps -a | grep my-cowsay
   ```

3. **Grab the logs and save to host machine**

   ```bash
   docker logs my-cowsay > cowsay-logs.txt
   ```

4. **View the saved logs**

   ```bash
   cat cowsay-logs.txt
   ```

   Expected output in `cowsay-logs.txt`:

   ```text
    ______________________
   < Hello from Docker! >
    ----------------------
       \
        \
         \     
                       ##        .            
                 ## ## ##       ==            
              ## ## ## ##      ===            
          /""""""""""""""""___/ ===        
     ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
          \______ o          __/            
           \    \        __/             
             \____\______/   
   ```

5. **Clean up (optional)**

   ```bash
   # Remove the container
   docker rm my-cowsay

   # Remove the log file
   rm cowsay-logs.txt
   ```

## Alternative: Using a Different Cowsay Image

If `docker/whalesay` is not available, you can build your own:

**Dockerfile:**

```dockerfile
FROM alpine:latest
RUN apk add --no-cache cowsay
ENTRYPOINT ["/usr/bin/cowsay"]
CMD ["Hello Docker!"]
```

**Build and run:**

```bash
docker build -t my-cowsay .
docker run --name cowsay-test my-cowsay "Hello from Docker!"
docker logs cowsay-test > cowsay-logs.txt
```

## Explanation

- **docker run --name**: Assigns a name to the container for easy reference
- **cowsay "message"**: Passes the message to the cowsay command
- **docker logs**: Retrieves all stdout/stderr output from the container
- **> cowsay-logs.txt**: Redirects the log output to a file on the host machine
- The container stops automatically after the command completes

## Bonus: Running in Detached Mode

For containers that run longer:

```bash
# Run in detached mode
docker run -d --name my-cowsay-bg docker/whalesay /bin/sh -c "cowsay 'Background task' && sleep 30"

# Get logs while running
docker logs my-cowsay-bg

# Follow logs in real-time
docker logs -f my-cowsay-bg

# Stop the container
docker stop my-cowsay-bg

# Save logs after stopping
docker logs my-cowsay-bg > cowsay-bg-logs.txt
```

</details>
