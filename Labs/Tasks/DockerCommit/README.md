![DockerLabs Banner](../../assets/images/docker-logos.png)

---

# In-Class Exercise - Docker Commit Workflow
    
- Start an `alpine` container and keep it running for modifications
- Create a new file inside the running container
- Use `docker commit` to capture a new image with the file included
- Run a container from the committed image and verify the file exists
- Hint: Combine `docker run`, `docker exec`, `docker commit`, and `docker run --rm`

<details markdown="1">
<summary>Solution</summary>

## Step-by-Step Solution

1. **Run a modifiable alpine container**

   ```bash
   docker run -d --name alpine-commit alpine:latest sleep infinity
   ```

2. **Write a file inside the running container**

   ```bash
   docker exec alpine-commit sh -c "echo 'Persisted with docker commit' > /opt/commit-note.txt"
   ```

3. **Validate the file inside the original container (optional check)**

   ```bash
   docker exec alpine-commit cat /opt/commit-note.txt
   ```

4. **Create a new image from the modified container**

   ```bash
   docker commit alpine-commit alpine-with-note:latest
   ```

5. **Run a container from the committed image and verify the file exists**

   ```bash
   docker run --rm alpine-with-note:latest cat /opt/commit-note.txt
   ```

   Expected output:

   ```text
   Persisted with docker commit
   ```

6. **Clean up resources**

   ```bash
   docker rm -f alpine-commit
   docker image rm alpine-with-note:latest
   ```

## Explanation

- **docker run -d ... sleep infinity**: Starts a container that stays alive for edits
- **docker exec ... echo '...' > file**: Writes a file into the running container
- **docker commit**: Captures the container's filesystem changes into a new image
- **docker run --rm new-image cat file**: Launches the new image, verifies the persistent file, and removes the container when done
- **Cleanup commands**: Remove the temporary container and image to free resources

</details>
