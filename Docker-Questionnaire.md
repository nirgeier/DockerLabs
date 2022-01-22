# Docker Questionnaire

:question: 1. Which docker command will run and container in the background

```
a. docker run -b alpine
b. docker run -d alpine
c. docker run -it alpine /bin/bash
d. docker run -it -d=false alpine
```

:question: 2.  Which docker command will remove docker container?
```
a. docker rm
b. docker rmi
c. docker stop
d. docker remove
```

:question: 3.  Which docker command will "download" image from the Registry?
```
a. docker install
b. docker pull
c. docker download
d. docker exec
```

:question: 4.  Which docker command will display information about the docker image?
```
a. docker stats
b. docker summary
c. docker inspect
d. docker info
```

:question: 5.  Which file system Docker use to build up images?

```
a. NTFS
b. BTRFS
c. ZFS
d. AUFS
```

:question: 6.  Which command is used for building Docker image?
```
a. run
b. cp
c. build
d. commit
```

:question: 7.  What are the steps for the Docker container life cycle?

```
a. Build, Run, Stop
b. Build, Run, Exit
c. Created, Started, Exited
d. Run, Pull, Started, Exited
```

:question: 8.  What does the volume (-v) parameter do in a docker run command?
```
a. Create folder on the host
b. Create volume in the container
c. Volume is not a valid flag
d. Bind filesystem between the host and the container
```

:question: 9.  Which Dockerfile command define which port the app is listening on?
```
a. OPEN
b. EXPOSE
c. LISTEN
d. ENTRYPOINT
```

:question: 10. Which DockerFile command(s) adds files to the image (can be more than 1)?
```
a. RUN
b. COPY
c. ADD
d. FROM
```

:question: 11. Which DockerFile commands will not add new layers to image?

```
a. RUN
b. COPY
c. ENV
d. FROM
```

:question: 12. Which DockerFile command change the current directory?

```
a. RUN
b. CD
c. SET
d. WORKDIR
```

:question: 13. Which DockerFile command will be used for executing script when the container is starting?
```
a. EXPOSE
b. RUN
c. CMD
d. ENTRYPOINT
```

:question: 14. What is Docker Compose? What can it be used for?
```
a. Define docker image content
b. Docker Compose is a tool that lets you define multiple containers and their configurations via a YAML or JSON file.
c. Change an existing container and inject new content
d. Optimization tools for production containers
```

:question: 15. What are the various states that a Docker container can be in at any given point in time?
```
a. Running
b. Paused
c. Restarting
d. Exited
```

:question: 16. How to execute a command on running container?
```
a. docker exec  -it <container id> <command>
b. docker start -it <container id> <command>
c. docker image -it <container id> <command>
d. docker load  -it <container id> <command>
```

:question: 17. How do you get the the status of a Docker container?
```
a. docker ps
b. docker info
c. docker inspect
d. docker status
```

:question: 18. What is the difference between the COPY and ADD commands in a DockerFile?
```
a. There is no difference, ADD is old (backward compatibility) command
b. They are the same, no difference
c. ADD will copy and extract files (zip, tar etc), Copy will only copy the files
d. Copy is for copying file, ADD is for adding exiting image
```

:question: 19. In a DockerFile which instructions id used to for setting the base image for the container?
```
a. ADD
b. FROM
c. ENTRYPOINT
d. BASE
```

:question: 20. `EXPOSE` in docker-compose will do the following?
```
a. Open and listen on a given port when the container is running.
b. Allow users to open this port if they wish to. 
c. Document which port the service (application) will accept network traffic.
d. Create a secure network between the application to the host
```
---

# Answers

1.  Which docker command will run and container in the background
<br/>**`b. docker run -d alpine`**
2.  Which docker command will remove docker container?
<br/>**`a. docker rm`**
3.  Which docker command will "download" image from the Registry?
<br/>**`b. docker pull`**
4.  Which docker command will display information about the docker image?
<br/>**`c. docker inspect`**
5.  Which file system Docker use to build up images?
<br/>**`d. AUFS`**
6.  Which command is used for building Docker image?
<br/>**`c. docker build`**
7.  What are the steps for the Docker container life cycle?
<br/>**`c. Created, Started, Exited`**
8.  What does the volume (-v) parameter do in a docker run command?
<br/>**`d. Bind filesystem between the host and the container`**
9.  Which DockerFile command define which port to open?
<br/>**`b. EXPOSE`**
10. Which DockerFile command(s) adds files to the image (can be more than 1)?
<br/>**`b & c COPY/ADD`**
11. Which DockerFile commands will not add new layers to image?
<br/>**`c. ENV`**
12. Which DockerFile command change the current directory
<br/>**`d. WORKDIR`**
13. Which DockerFile command will be used for executing script when the container is starting?
<br/>**`d. ENTRYPOINT`**
14. What is Docker Compose? What can it be used for?
<br/>**`b. Docker Compose is a tool that lets you define multiple containers and their configurations via a YAML or JSON file.`**
15. What are the various states that a Docker container can be in at any given point in time?
<br/>**`All the answers`**
16. How to execute a command on running container?
<br/>**`a. docker exec -it <container id> <command>`**
17. How do you get the the status of a Docker container?
<br/>**`a. docker ps`**
18. What is the difference between the COPY and ADD commands in a DockerFile?
<br/>**`c. ADD will copy and extract files (zip, tar etc), Copy will only copy the files`**
19. In a DockerFile which instructions id used to for setting the base image for the container?
<br/>**`b. FROM`**
20. `EXPOSE` in docker-compose will do the following?
<br/>**`c. Document which port the service (application) will accept network traffic.`**