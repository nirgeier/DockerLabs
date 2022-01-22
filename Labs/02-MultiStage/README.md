<a href="https://stackoverflow.com/users/1755598">
    <img src="https://stackexchange.com/users/flair/1951642.png" width="208" height="58">
</a>

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

# Lab 02: Writing Docker multi-stage build

- In this lab we will learn how to write a multi-stage Docker file

### 01. Create the multi-stage docker file

- The first step is to create a Dockerfile.
- Later on we will pass build time arguments to this file to build the desired image
- `Dockerfile`

  ```sh
  # Get the value of the desired image to build
  ARG     BASE_IMG=${BASE_IMG}

  # Build the base image
  FROM    alpine AS base_image

  # Add some packages to the base image
  FROM    base_image  AS build-curl
  RUN     echo -e "\033[1;33mThis file is from curl image\033[0m" > image.txt

  # Add some packages to the base image
  FROM    base_image  AS build-bash
  RUN     echo -e "\033[1;32mThis file is from bash image\033[0m" > image.txt

  #   Build the desired image
  FROM    build-${BASE_IMG}
  # We can use the FROM command as we see in the previous line or use the
  # `COPY  --from=build-${BASE_IMG} image.txt .` to copy a specific content
  RUN     cat image.txt
  CMD     cat image.txt
  ```

### 02. Build the desired images

- We will use the following script to build multiple images and to test the results

  ```sh
  #!/bin/bash  -x

  # Build The curl based image (no-cache)
  docker build --build-arg BASE_IMG=curl --no-cache -t curl1 .

  # Build The bash based image (no-cache)
  docker build --build-arg BASE_IMG=bash --no-cache -t bash1 .

  ### Build with cache
  echo -e ""
  echo -e "\033[1;33m---------------------------------\033[0m"
  echo -e ""
  # Build The curl based image (no-cache)
  docker build --build-arg BASE_IMG=curl -t curl2 .

  # Build The bash based image (no-cache)
  docker build --build-arg BASE_IMG=bash -t bash2 .
  ```

### 03. Test the images

- We will now test the 4 images we build perviously

  ```sh
  # Debug mode
  set -x

  # Test the output images
  docker run curl1
  docker run curl2
  docker run bash1
  docker run bash2
  ```

- You should see out put similar to this one:
  ```sh
  + docker run curl1
  This file is from curl image
  + docker run curl2
  This file is from curl image
  + docker run bash1
  This file is from bash image
  + docker run bash2
  This file is from bash image
  ```

### 04. What will be the results of this docker file?

    ```sh
    # Build the base image
    FROM    alpine AS base_image

    # Add some packages to the base image
    FROM    base_image  AS build-curl
    RUN     echo -e "\033[1;33mThis file is from curl image\033[0m" > image.txt

    # Add some packages to the base image
    FROM    base_image  AS build-bash
    RUN     echo -e "\033[1;32mThis file is from bash image\033[0m" > image.txt

    #   Build the desired image
    FROM    build-curl
    COPY    --from=2 image.txt .
    RUN cat image.txt
    CMD cat image.txt
    ```

- Test your answer with the following command
  ``sh
  docker build -f Dockerfile2 .

### 05. Build a specific target

- We can build our specific image and stop at the desired stage
- In other words we don't need to build all the images within the docker file
  ```sh
  docker build --target build-curl -f Dockerfile2 .
  ```
