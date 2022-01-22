<a href="https://stackoverflow.com/users/1755598"><img src="https://stackexchange.com/users/flair/1951642.png" width="208" height="58" alt="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites"></a>

![Visitor Badge](https://visitor-badge.laobi.icu/badge?page_id=nirgeier)
[![Linkedin Badge](https://img.shields.io/badge/-nirgeier-blue?style=plastic&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/nirgeier/)](https://www.linkedin.com/in/nirgeier/)
[![Gmail Badge](https://img.shields.io/badge/-nirgeier@gmail.com-fcc624?style=plastic&logo=Gmail&logoColor=red&link=mailto:nirgeier@gmail.com)](mailto:nirgeier@gmail.com)
[![Outlook Badge](https://img.shields.io/badge/-nirg@codewizard.co.il-fcc624?style=plastic&logo=microsoftoutlook&logoColor=blue&link=mailto:nirg@codewizard.co.il)](mailto:nirg@codewizard.co.il)

---

![](../../resources/docker-logos.png)

---
![](../../resources/hands-on.png)

# Docker Hands-on Repository <!-- omit in toc -->

- A collection of Hands-on Docker labs.
- Each lab is a standalone lab and does not require to complete the previous labs.

#### Pre-Requirements <!-- omit in toc -->

* Docker installed
* Dockerfile knowledge 
* DockerHub account

---

## The Task <!-- omit in toc -->

* Work with containers using docker cli


## Lab - Docker CLI <!-- omit in toc -->

* In this lab we will learn the basics of docker cli
* The lab assume you have basic docker knowledge
 ---
### Table of Contents in this lab: <!-- omit in toc -->

- [`docker run`](#docker-run)
- [`docker run <command>`](#docker-run-command)
- [`docker run -it`](#docker-run--it)
- [`docker run -d`](#docker-run--d)
- [`docker run -name`](#docker-run--name)
- [`docker run -p`](#docker-run--p)
- [`docker run -a`](#docker-run--a)
- [`docker ps`](#docker-ps)
- [`docker rm`](#docker-rm)
- [`docker exec`](#docker-exec)
- [`docker cp`](#docker-cp)
- [`docker commit`](#docker-commit)

---
  
### `docker run`  

- The `run` command container many options (flags), we will not cover all of them
- [docs.docker.com - run](https://docs.docker.com/reference/cli/docker/container/run/)
- Run your first container: 

```sh
# Run the first container
docker run hello-world`

### Output:

Hello from Docker!
This message shows that your installation appears to be working correctly.
...
``` 

### `docker run <command>`  

- Docker allow you to run a command on your containers
- Task: List the files under alpine container 

```sh
# Spin alpine container and list the files under the / directory
docker run alpine ls -la
```

### `docker run -it`  

> [!NOTE]
> The flags `-it` stands for:   
> `-i` [`--interactive`]
> keeps the container's STDIN open, and lets you send input to the container through standard input.
>   
> `-t` [`--tty`]  
> TAttaches a pseudo-TTY to the container, connecting your terminal to the I/O streams of the container. 

```bash
# Execute a command on the container and interact with the container
# This command will change the password for root user
docker run -it alpine passwd root
```

### `docker run -d` 

- Spin up the container which will run in the background
- By default when you spin a docker container it will attach itself to the current terminal.
- In order to avoid it we will use the -d flag to specify that the container should be running in the background.

```sh
# Spin an nginx in the background.
# Add a sleep timeout so that the container will not exit immediately
docker run -d alpine sleep 10000

# Verify that the container is still running
docker ps -a
```

### `docker run -name` 

- By default the container will be assigned a semi-random name based upon the following code:
[docker-ce/names-generator.go](https://github.com/docker/docker-ce/blob/master/components/engine/pkg/namesgenerator/names-generator.go)
- We can assign our desired name to the container with the `--name` option

```sh
# Spin an nginx in the background.
# Add a sleep timeout so that the container will not exit immediately
docker run --name alpine001 alpine

# Verify that the container has been created with the given name
docker ps -a |  grep alpine001
```

### `docker run -p`  

> [!NOTE]
> We can specify the exact ports we wish to open `-p` or open them all `-P` 

- Run a container and connect to a port on the host which will be used to connect to the container
  
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

### `docker ps`  

- The "problem" with the previous command is that the container is not removed once it exits.
- Lets look at the list of containers that we have right now on the host machine

```sh
# List exiting containers on our host machine

# Display running containers
docker ps

# Display all containers
docker ps -a

# Display all containers ids
docker ps -aq
```

### `docker rm`  

- Lets clean and remove the containers which are not running anymore

```sh
# Remove all stopped containers
# We use docker rm with the previous command we learned docker ps
docker rm $(docker ps -aq)

# Verify that only running containers are still running
docker ps -a
```

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


### `docker cp`

- `docker cp` is used to copy files between the container and the host
- Lets spin a container and then lets grab the logs of this container to our host
> [!TIP] 
> Since container are "file system" we can grab files even when the container is stopped.

```sh
# Remove old container if any
docker stop nginx
docker rm   nginx

# Spin a container
docker run -it -d --name nginx -p 8888:80 nginx

# Wait for the container to Run
sleep 5

# grab the nginx default configuration 
docker cp nginx:/etc/nginx/nginx.conf nginx.conf 

# Verify that the file exists locally
cat nginx.conf 
```

- In the second part we will upload file to our container
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

### `docker commit`

- `docker commit` will create a new images out of an existing container.
- Same as we did with `docker cp` we will create a custom container of nginx and create a custom image.

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