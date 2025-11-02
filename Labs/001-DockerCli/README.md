

![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 001 - Docker CLI

- This lab covers the basics of the `Docker CLI`.
- You will learn how to run, manage and interact with Docker containers using various Docker commands.
- By the end of this lab, you will have a solid understanding of how to use the `Docker CLI` for container management.

---

## Docker CLI Commands

- [`docker attach`](#docker-attach)
- [`docker build`](#docker-build)
- [`docker commit`](#docker-commit)
- [`docker cp`](#docker-cp)
- [`docker create`](#docker-create)
- [`docker exec`](#docker-exec)
- [`docker images`](#docker-images)
- [`docker inspect`](#docker-inspect)
- [`docker kill`](#docker-kill)
- [`docker logs`](#docker-logs)
- [`docker pause`](#docker-pause)
- [`docker ps`](#docker-ps)
- [`docker pull`](#docker-pull)
- [`docker push`](#docker-push)
- [`docker rename`](#docker-rename)
- [`docker restart`](#docker-restart)
- [`docker rm`](#docker-rm)
- [`docker rmi`](#docker-rmi)
- [`docker run`](#docker-run)
- [`docker run -a`](#docker-run--a)
- [`docker run -d`](#docker-run--d)
- [`docker run -it`](#docker-run--it)
- [`docker run -name`](#docker-run--name)
- [`docker run -p`](#docker-run--p)
- [`docker run <command>`](#docker-run-command)
- [`docker start`](#docker-start)
- [`docker stats`](#docker-stats)
- [`docker stop`](#docker-stop)
- [`docker top`](#docker-top)
- [`docker unpause`](#docker-unpause)
- [`docker wait`](#docker-wait)

---

### `docker attach`

- `docker attach` is used to attach your terminal to a running container.
- This is useful when you want to interact with a container that is already running.
- For example, if you have a container running a shell or an application that accepts input, you can use `docker attach` to connect to it.

```sh
# Spin an alpine image and start it in the background
docker run -it -d --name alpine001 alpine sleep 10000

# Attach to the container and start a shell inside it
docker attach alpine001
```

!!! debug "Detaching from a Container"

    * To detach from the container without stopping it, you can use the <kbd>CTRL + P</kbd> followed by <kbd>CTRL + Q</kbd> key combination.    
    * This will leave the container running in the background while you return to your terminal.  
        * **Note that this detach sequence only works if the container was started with the `-it` flag (interactive with a TTY)**

---

### `docker build`

- `docker build` creates a Docker image from a Dockerfile.
- This is one of the most important commands for creating custom images.

    ```sh
    # Create a simple Dockerfile
    mkdir -p /tmp/docker-build-example
    cd /tmp/docker-build-example

    cat <<'EOF' > Dockerfile
    FROM alpine:latest
    RUN apk add --no-cache curl
    CMD ["echo", "Hello from custom image"]
    EOF

    # Build the image with a tag
    docker build -t my-custom-alpine:v1.0 .

    # Build with a different tag
    docker build -t my-custom-alpine:latest .

    # Build without using cache
    docker build --no-cache -t my-custom-alpine:v1.0 .

    # Test the built image
    docker run --rm my-custom-alpine:v1.0

    # Clean up
    cd -
    rm -rf /tmp/docker-build-example
    ```

---

### `docker commit`

- `docker commit` will create a new images out of an existing container.

    ```sh
    # Clean up and remove the container
    docker stop nginx
    docker rm   nginx

    # Spin the container
    docker  run  -it -d -p 8888:80 --name nginx nginx

    # Wait for the container to start
    sleep 5

    # Prepare the desired welcome page
    docker  exec -it nginx sh -c "                  \
            echo 'This is a custom message ... ' >  \
            /usr/share/nginx/html/index.html"

    # Verify the changes
    curl -s localhost:8888

    # Create the custom image
    docker commit nginx nirgeier/custom-nginx-image

    # Clean up and remove the container
    docker stop nginx
    docker rm   nginx

    # Push to the registry
    docker push nirgeier/custom-nginx-image

    # Clean up and remove the container
    docker stop custom-nginx
    docker rm   custom-nginx

    # Push to the registry
    docker  run -it -d --name custom-nginx  \
            -p 8888:80                      \
            nirgeier/custom-nginx-image

    # Wait for the container to start
    sleep 5

    # Verify the changes
    curl -s localhost:8888

    # Clean up and remove the container
    docker stop custom-nginx
    docker rm   custom-nginx
    ```

---

### `docker cp`

- The `docker cp` command is used to copy files between the container and the host
- Let's spin a container and then let's grab the logs of this container to our host

!!! debug "Copying files from and to a Container"

    Since containers are essentially "file systems", we can grab files even when the container is stopped.

* Example 1 - Copy file from Container to Host

    ```sh
    # Spin a container
    docker run -it -d --name nginx -p 8888:80 nginx

    # grab the nginx default configuration 
    docker cp nginx:/etc/nginx/nginx.conf nginx.conf 

    # Verify that the file exists locally
    cat nginx.conf 
    ```

* Example 2 - Copy file from Host to Container

    - In the second example we will upload a file to our container
    - We will change the default nginx welcome page with our own page

      ```sh
      # Prepare the desired welcome page
      echo 'Welcome to the world of Docker' > index.html

      # Copy the file to the container 
      docker cp index.html nginx:/usr/share/nginx/html

      # Test the changes to the container
      curl -s localhost:8888

      # Clean up and remove the container
      docker stop nginx
      docker rm   nginx
      ```

---

### `docker create`

- the `docker create` command creates a new container but does not start it.
- This is useful when you want to prepare a container, but prefer to start it later.
    ```sh
    # Create a container without starting it
    docker create --name my-nginx nginx

    # Verify the container is created but not running
    docker ps -a | grep my-nginx

    # Create a container with port mapping
    docker create --name web-server -p 8080:80 nginx

    # Create with environment variables
    docker create --name db-container -e POSTGRES_PASSWORD=secret postgres

    # Create with volume mount
    docker create --name data-container -v /data alpine

    # Start the created container
    docker start my-nginx

    # Clean up
    docker stop my-nginx
    docker rm my-nginx web-server db-container data-container
    ```

---

### `docker exec`

- Execute a command in a **running** container
    ```sh
    # Remove old containers with the same name
    docker stop alpine001
    docker rm   alpine001

    # Spin an alpine image
    docker run -it -d --name alpine001 alpine sleep 10000

    # Test that curl is not installed on the container
    docker exec -it alpine001 curl

    # Install a new package on the container
    docker exec -it alpine001 apk add curl

    # Test that curl is installed
    docker exec -it alpine001 curl codewizard.co.il

    # Interact with the alpine image and open bash shell
    docker exec -it alpine001 sh
    ```

---

### `docker images`

- The `docker images` command lists all Docker images on your system.
- This command helps you see what images you have available locally.

    ```sh
    # List all images
    docker images

    # List images with specific format
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

    # List all image IDs
    docker images -q

    # List dangling images (images with no tag)
    docker images -f "dangling=true"

    # Filter images by name
    docker images alpine

    # Show all images including intermediate layers
    docker images -a
    ```

---

### `docker inspect`

- The `docker inspect` command provides detailed information about Docker objects (containers, images, volumes, networks).
- It returns a JSON array with all the metadata.
    ```sh
    # Create a container for inspection
    docker run -d --name nginx-inspect -p 8080:80 nginx

    # Inspect a container
    docker inspect nginx-inspect

    # Get specific information using format flag
    docker inspect --format='{{.State.Running}}' nginx-inspect

    # Get IP address of container
    docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-inspect

    # Inspect an image
    docker inspect nginx:latest

    # Get image creation date
    docker inspect --format='{{.Created}}' nginx:latest

    # Clean up
    docker stop nginx-inspect
    docker rm nginx-inspect
    ```

---

### `docker kill`

- The `docker kill` command immediately terminates a running container.
- Unlike `docker stop`, it sends SIGKILL by default (no graceful shutdown).
    ```sh
    # Create a running container
    docker run -d --name kill-test alpine sleep 10000

    # Kill the container immediately
    docker kill kill-test

    # Verify the container is stopped
    docker ps -a | grep kill-test

    # Kill with specific signal
    docker run -d --name kill-test2 nginx
    docker kill --signal=SIGTERM kill-test2

    # Kill multiple containers
    docker run -d --name c1 alpine sleep 1000
    docker run -d --name c2 alpine sleep 1000
    docker kill c1 c2

    # Clean up
    docker rm kill-test kill-test2 c1 c2
    ```

---

### `docker logs`

- The `docker logs` command fetches the logs of a container.
- It is useful for debugging and monitoring container output.
- By default, it shows all logs since the container started.
- You can use various options to filter and format the logs.
    ```sh
    # Create a container that generates logs
    docker run -d --name log-example alpine sh -c "while true; do echo 'Hello from container'; sleep 2; done"

    # View container logs
    docker logs log-example

    # Follow log output (like tail -f)
    docker logs -f log-example

    # Show only last 10 lines
    docker logs --tail 10 log-example

    # Show logs with timestamps
    docker logs -t log-example

    # Show logs since specific time
    docker logs --since 5m log-example

    # Combine options
    docker logs -f --tail 5 -t log-example

    # Clean up (press Ctrl+C to stop following logs)
    docker stop log-example
    docker rm log-example
    ```

---

### `docker pause`

- The `docker pause` command suspends all processes in a container.
- The container continues to exist but is frozen.

    ```sh
    # Create a running container
    docker run -d --name pause-test alpine sh -c "while true; do echo 'Running'; sleep 1; done"

    # Pause the container
    docker pause pause-test

    # Verify the container is paused
    docker ps -a | grep pause-test

    # Try to see logs (no new logs while paused)
    docker logs --tail 5 pause-test

    # Note: Container remains paused until unpaused
    # See docker unpause to resume
    ```

---

### `docker ps`

- The `docker ps` command lists containers.
- The "problem" with the previous command is that the container is not removed once it exits.
- Let's look at the list of containers that we have right now on the host machine
    ```sh
    # List exiting containers on our host machine

    # Display running containers
    docker ps

    # Display all containers
    docker ps -a

    # Display all containers ids
    docker ps -aq
    ```

---

### `docker pull`

- The `docker pull` command downloads an image from a Docker registry (e.g., [Docker Hub](https://hub.docker.com/)).
- This command is useful when you want to download an image without running it immediately.
    ```sh
    # Pull the latest version of an image
    docker pull alpine:latest

    # Pull a specific version
    docker pull nginx:1.21

    # Pull from a specific registry
    docker pull gcr.io/google-containers/busybox

    # Pull all tags of a repository
    docker pull --all-tags alpine

    # Verify the pulled image
    docker images | grep alpine
    ```

---

### `docker push`

- The `docker push` command uploads an image to a Docker registry.
- Note that you need to be logged in to that registry and have proper permissions.
    ```sh
    # Tag an image for pushing (replace 'yourusername' with your Docker Hub username)
    docker tag alpine:latest yourusername/my-alpine:v1.0

    # Login to Docker Hub (you'll be prompted for credentials)
    # docker login

    # Push the image to Docker Hub
    # docker push yourusername/my-alpine:v1.0

    # Push all tags
    # docker push --all-tags yourusername/my-alpine

    # Note: The push commands are commented out to prevent accidental pushes
    # Uncomment and replace 'yourusername' with your actual username when ready to use
    ```

---

### `docker rename`

- The `docker rename` command changes the name of an existing container.
- It is useful for organizing or clarifying container purposes.

    ```sh
    # Create a container with a generic name
    docker run -d --name old-name alpine sleep 10000

    # Rename the container
    docker rename old-name new-name

    # Verify the new name
    docker ps | grep new-name

    # Clean up
    docker stop new-name
    docker rm new-name
    ```

---

### `docker restart`

- The `docker restart` command stops and then starts a container.
- It combines `docker stop` and `docker start` into one command.

    ```sh
    # Create a running container
    docker run -d --name restart-test nginx

    # Restart the container (default 10 second grace period)
    docker restart restart-test

    # Restart with custom timeout
    docker restart -t 30 restart-test

    # Restart multiple containers
    docker run -d --name r1 alpine sleep 1000
    docker run -d --name r2 alpine sleep 1000
    docker restart r1 r2

    # Clean up
    docker stop restart-test r1 r2
    docker rm restart-test r1 r2
    ```

---

### `docker rm`

- Let's clean and remove the containers which are not running anymore
- The `docker rm` command removes one or more stopped containers from your system.
- This helps free up system resources by deleting containers that are no longer needed.

!!! debug "Removing Containers"
      
       
      - You `cannot` remove a running container without stopping it first.
      - Use `docker ps -a` to list all containers (including stopped ones) before removing them.
      - **Warning:** This action is irreversible!

* Example:
    ```sh
    # Remove all stopped containers
    # We use docker rm with the previous command we learned docker ps
    docker rm $(docker ps -aq)

    # Verify that only running containers are still running
    docker ps -a

    # Remove a specific container (must be stopped first)
    docker stop nginx
    docker rm nginx

    # Force remove a running container
    docker rm -f nginx

    # Remove multiple containers
    docker rm container1 container2 container3
    ```

---

### `docker rmi`

- The `docker rmi` command removes one or more Docker images from your system.
- This helps free up disk space by removing unused images.
- You cannot remove an image that is currently being used by a running container.
- If you need to remove such an image, you must stop and remove the container using said image first.
- **Tip:** Use `docker ps -a` to list all containers (including stopped ones) before removing them.
    ```sh
    # Remove a specific image
    docker rmi alpine:latest

    # Remove multiple images
    docker rmi image1:tag1 image2:tag2

    # Remove image by ID
    docker rmi abc123def456

    # Force remove an image (even if containers are using it)
    docker rmi -f nginx:latest

    # Remove all dangling images (untagged images)
    docker rmi $(docker images -f "dangling=true" -q)

    # Remove all images
    # WARNING: This removes ALL images on your system
    # docker rmi $(docker images -q)
    ```

---

### `docker run`  

- The `run` command contains many options (flags), but we will not cover all of them.
- See the `run` command documentation here: [docs.docker.com - run](https://docs.docker.com/reference/cli/docker/container/run/)
- Run your first container: 
    ```sh
    # Run the first container
    docker run hello-world

    ### Output:

    Hello from Docker!
    This message shows that your installation appears to be working correctly.
    ...
    ```

---

### `docker run -a`

- The `--attach` [`-a`] flag tells docker run to **bind** to the container's `STDIN`, `STDOUT` or `STDERR`. 
    ```sh
    # Pass input from stdin to container
    docker run -a stdout alpine echo "Docker rocks !!"

    # Redirect stdout logs to a file
    docker run -a stdout -a stderr alpine echo 'Docker rocks again !!' > log.txt 2>&1

    # Print the log content
    cat log.txt
    ```

---

### `docker run -d` 

- The `-d` flag tells Docker to run the container in detached mode.
- By default when you spin a docker container, it will attach itself to the current terminal.
- In order to avoid this, we will use the `-d` flag in order to specify that the container should be running in the background.
    ```sh
    # Spin an nginx in the background.
    # Add a sleep timeout so that the container will not exit immediately
    docker run -d alpine sleep 10000

    # Verify that the container is still running
    docker ps -a
    ```

---

### `docker run -it`  

!!! debug "Interactive Terminal"
    The flag `-it` stands for:   
    `-i` [`--interactive`]: Keeps the container's STDIN open, and lets you send input to the container through standard input.

    `-t` [`--tty`]: Attaches a pseudo-TTY to the container, connecting your terminal to the I/O streams of the container.

* Example - Run an interactive shell inside an alpine container
    ```bash
    # Execute a command on the container and interact with the container
    # This command will change the password for root user
    docker run -it alpine passwd root
    ```

---

### `docker run --name` 

- By default, the container will be assigned a semi-random name based upon the following code:
[docker-ce/names-generator.go](https://github.com/docker/docker-ce/blob/master/components/engine/pkg/namesgenerator/names-generator.go)
- We can assign our desired name to the container with the `--name` option
    ```sh
    # Spin an nginx in the background.
    # Add a sleep timeout so that the container will not exit immediately
    docker run --name alpine001 alpine

    # Verify that the container has been created with the given name
    docker ps -a |  grep alpine001
    ```

---

### `docker run -p`  

!!! debug "Port Mapping"
    * We can specify the exact ports we wish to open with `-p`, or open them all with `-P`.

* Run a container and connect to a port on the host which will be used to connect to the container
    ```sh
    # Execute an nginx container and test the container

    # Remove any containers with the same name
    docker stop nginx
    docker rm   nginx

    # We will combine few flags here
    docker  run   -it  --rm     \
                  -d            \
                  -p 8888:80    \
                  --name nginx  \
                  nginx

    # Wait for the container to be created
    sleep 3

    # test the container
    curl -s localhost:8888

    # Remove the container
    docker kill nginx
    ```

---

### `docker start`

- The `docker start` command starts one or more stopped containers.
- Unlike `docker run`, this command applies only to an **existing container**.
- It does not create a new container.
    ```sh
    # Create a container but don't start it immediately
    docker create --name my-alpine alpine echo "Hello World"

    # Start the container
    docker start my-alpine

    # Start and attach to container output
    docker start -a my-alpine

    # Start multiple containers
    docker start container1 container2 container3

    # Start a stopped container interactively
    docker run -it --name interactive-alpine alpine sh
    # (exit the shell to stop the container)
    docker start -ai interactive-alpine

    # Clean up
    docker rm my-alpine interactive-alpine
    ```

---

### `docker stats`

- The `docker stats` command displays a live stream of resource usage statistics for containers.
- It can show CPU, memory, network I/O, and disk I/O usage.
- It is useful for monitoring container performance in real-time.
- It can be used to identify resource bottlenecks and optimize container performance.
- It supports filtering and formatting options for customized output.
    ```sh
    # Create some containers
    docker run -d --name stats-test1 nginx
    docker run -d --name stats-test2 alpine sleep 10000

    # Display stats for all running containers (live stream)
    # Press Ctrl+C to exit
    docker stats

    # Display stats for specific containers
    docker stats stats-test1 stats-test2

    # Display stats without streaming (single snapshot)
    docker stats --no-stream

    # Custom format
    docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

    # Clean up
    docker stop stats-test1 stats-test2
    docker rm stats-test1 stats-test2
    ```

---

### `docker stop`

- The `docker stop` command stops one or more running containers gracefully.
- It sends a `SIGTERM` signal first, then a `SIGKILL` signal after a grace period.

    ```sh
    # Create a running container
    docker run -d --name test-nginx nginx

    # Stop the container (default 10 second grace period)
    docker stop test-nginx

    # Stop with custom timeout
    docker stop -t 30 test-nginx

    # Stop multiple containers
    docker stop container1 container2 container3

    # Stop all running containers
    docker stop $(docker ps -q)

    # Verify container is stopped
    docker ps -a | grep test-nginx

    # Clean up
    docker rm test-nginx
    ```

---

### `docker top`

- The `docker top` command displays the running processes inside a container.
- It is similar to the Linux `top` command, but for containers.
  ```sh
  # Create a running container
  docker run -d --name top-test nginx

  # Display running processes in the container
  docker top top-test

  # Display with custom ps options
  docker top top-test aux

  # Display specific columns
  docker top top-test -eo pid,comm

  # Create a busier container to see more processes
  docker run -d --name busy-container alpine sh -c "sleep 100 & sleep 200 & sleep 300 & wait"
  docker top busy-container

  # Clean up
  docker stop top-test busy-container
  docker rm top-test busy-container
  ```

---

### `docker unpause`

- The `docker unpause` command resumes all processes that were paused in a container.
- It is used in conjunction with `docker pause`.
  ```sh
  # Create and pause a container
  docker run -d --name unpause-test alpine sh -c "while true; do echo 'Running'; sleep 1; done"
  docker pause unpause-test

  # Verify container is paused
  docker ps -a | grep unpause-test

  # Unpause the container
  docker unpause unpause-test

  # Verify container is running again
  docker ps | grep unpause-test

  # Check logs to see it resumed
  docker logs --tail 5 unpause-test

  # Clean up
  docker stop unpause-test
  docker rm unpause-test
  ```

---

### `docker wait`

- The `docker wait` command blocks until one or more containers stop.
- It returns the exit code of the container.

    ```sh
    # Create a container that will exit after 5 seconds
    docker run -d --name wait-test alpine sh -c "sleep 5; exit 42"

    # Wait for the container to exit and get the exit code
    echo "Waiting for container to exit..."
    docker wait wait-test
    # This will return 42 after 5 seconds

    # Wait for multiple containers
    docker run -d --name w1 alpine sh -c "sleep 3; exit 0"
    docker run -d --name w2 alpine sh -c "sleep 2; exit 1"
    docker wait w1 w2

    # Clean up
    docker rm wait-test w1 w2
    ```