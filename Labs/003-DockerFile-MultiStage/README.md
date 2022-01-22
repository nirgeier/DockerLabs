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

# Lab - Writing Docker multi-stage build

- In this lab we will learn how to write a multi-stage Docker file
- A multistage build allows you to use **multiple images** to build a final product. 
- In a multistage build, you have a **single** Dockerfile which build up multiple images inside it to help build the final image.

### 01. Create the multi-stage docker file

- The first step is to create a Dockerfile.
- Later on we will pass build time arguments to this file to build the desired image
- `Dockerfile`

```Dockerfile
# Get the value of the desired image to build
ARG     BASE_IMG=${BASE_IMG}

# Build the base image
FROM    alpine AS base_image

# Add some packages to the base image
FROM    base_image  AS build-curl
RUN     echo -e "This file is from curl image" > image.txt

# Add some packages to the base image
FROM    base_image  AS build-bash
RUN     echo -e "This file is from bash image" > image.txt

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
echo -e "---------------------------------"
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
