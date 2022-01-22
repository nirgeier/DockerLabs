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

# Lab: Setup Basic Local Docker Registry <!-- omit in toc -->

- In this lab we will learn how to create a local Docker registry.
- In this lab we will learn how to push and pull images from the local registry.
- in this lab we will be using the default configuration, but of course you can change it as you wish.
- Configuration docs: [https://docs.docker.com/registry/configuration](https://docs.docker.com/registry/configuration/)

---
- [01. Create a basic local registry](#01-create-a-basic-local-registry)
- [02. Prepare the local images](#02-prepare-the-local-images)
- [02.01. Download busybox image](#0201-download-busybox-image)
- [02.01. Tag the image with the local registry prefix](#0201-tag-the-image-with-the-local-registry-prefix)
- [02.02. Push the image to the local registry](#0202-push-the-image-to-the-local-registry)
- [03. Test local images](#03-test-local-images)

---

### 01. Create a basic local registry

- The first step is to create a local registry.
- For this we will use the `docker run` command with the docker `registry`- https://hub.docker.com/_/registry image.

```sh
# Run the registry container
docker  run                     \
        -d                      \
        -p 5000:5000            \
        --restart always        \
        --name registry         \
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
curl -X GET http://localhost:5000/v2/_catalog

# List all tags for a repository
curl -X GET https://myregistry:5000/v2/ubuntu/tags/list
```


