
<a href="https://stackoverflow.com/users/1755598"><img src="https://stackexchange.com/users/flair/1951642.png" width="208" height="58" alt="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites"></a> 

![Visitor Badge](https://visitor-badge.laobi.icu/badge?page_id=nirgeier) 


![](../../resources/docker-logos.png)

---
# Docker Hands-on Repository

- A collection of Hands-on Docker labs.
- Each lab is a standalone lab and does not require to complete the previous labs.

![](../../resources/lab.jpg)

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/nirgeier/DockerLabs)
### **<kbd>CTRL</kbd> + click to open in new window**   

---
### Pre-Requirements
- Docker installation

---
# Lab 0101: Setup Basic Local Docker Registry

- In this lab we will learn how to create a local Docker registry.
- In this lab we will learn how to push and pull images from the local registry.
- in this lab we will be using the default configuration, but of course you can change it as you wish.
- Configuration docs: [https://docs.docker.com/registry/configuration](https://docs.docker.com/registry/configuration/)

### 01. Create a basic local registry
- The first step is to create a local registry.
- For this we will use the `docker run` command with the docker `registry`- https://hub.docker.com/_/registry image.

```sh
# Run the registry container
docker  run \
        -d \
        -p 5000:5000 \
        --restart always \
        --name registry \
        registry:latest
```
### 02. Prepare the local images
- We will download the images from DockerHub and push them to the local registry.

### 02.01. Download busybox image
```sh
# download busybox image from docker-hub
docker pull busybox
```

### 02.01. Tag the image with the local registry prefix
```sh
# Tag the busybox image with the local registry prefix
docker tag busybox localhost:5000/busybox
```

### 02.02. Push the image to the local registry
```sh
# Once we have the appropriate tag, we can push the image to the local registry
docker push localhost:5000/busybox
```

### 03. Test local images
```sh
# List all local repositories
curl -X GET https://myregistry:5000/v2/_catalog

# List all tags for a repository
curl -X GET https://myregistry:5000/v2/ubuntu/tags/list
```


