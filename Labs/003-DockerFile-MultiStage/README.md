

![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 003 - Writing Docker multi-stage build

- In this lab we will learn how to write a multi-stage Docker file.
- A multistage build allows you to use **multiple images** to build a final product. 
- In a multistage build, you have a **single** Dockerfile which builds up multiple images inside it, used to help build the final image.

---

## 01. Why Use Multistage Builds?

<div class="grid cards" markdown>

-   :material-resize:{ .lg .middle } **Reduce Image Size**

    ---

    - Use a minimal base image for the final stage
    - Only copy necessary artifacts to the final image
    - Exclude build tools and intermediate files from production image

-   :material-shield-check:{ .lg .middle } **Improve Security**

    ---

    - Exclude build tools and secrets from the runtime image
    - Limit the attack surface by using a smaller final image
    - Use a non-root user in the final stage
    - Reduce vulnerabilities by minimizing installed packages

-   :material-speedometer:{ .lg .middle } **Better Build Performance**

    ---

    - Leverage Docker's layer caching mechanism to speed up builds
    - Only rebuild stages that have changed
    - Each stage can be built and tested independently
    - Parallel stage execution when possible

-   :material-file-code:{ .lg .middle } **Cleaner and More Maintainable Dockerfiles**

    ---

    - Separate concerns by using multiple named stages
    - No need for a manual cleanup of build dependencies
    - Easier to read and maintain with clear stage purposes
    - Use meaningful stage names for better clarity
    - Add comments to explain each stage's role

-   :material-package-variant:{ .lg .middle } **Flexible Dependency Management**

    ---

    - Install build dependencies in one stage and runtime dependencies in another
    - Use different base images optimized for each stage (e.g., `golang:alpine` for build, `alpine` for runtime)
    - Use the best-suited image for each stage without bloating the final image

-   :material-pipe:{ .lg .middle } **Simplified CI/CD Pipelines**

    ---

    - Combine build, test, and deploy stages in a single Dockerfile
    - Use `--target` flag to build specific stages for different environments
    - Consistent build process across development and production

</div>

---


## 02. Create multi-stage docker file

- The first step is to create a Dockerfile.
- Later-on we will pass build time arguments to this file to build the desired image
- See the below `Dockerfile`:
    ```Dockerfile
    # Get the value of the desired image to build
    ARG     BASE_IMG=curl

    # Build the base image 
    FROM    alpine AS base_image

    # Add some content to the 2nd image
    FROM    base_image  AS build-curl
    RUN     echo -e "This file is from curl image" > image.txt

    # Add some content to the 3rd image
    FROM    base_image  AS build-bash
    RUN     echo -e "This file is from bash image" > image.txt

    # Build the desired image
    FROM    build-${BASE_IMG}

    # We can use the FROM command as we see in the previous line or use the
    # We can also use image index instead
    # COPY  --from=build-${BASE_IMG} image.txt . to copy a specific content
    RUN     cat image.txt
    CMD     ["cat", "image.txt"]
    ```

## 03. Build the desired images

- We will use the following script to build multiple images and to test the results
    ```bash
    #!/bin/bash -x

    # Build The curl based image (no-cache)
    docker build --build-arg BASE_IMG=curl --no-cache -t curl1 .

    # Build The bash based image (no-cache)
    docker build --build-arg BASE_IMG=bash --no-cache -t bash1 .

    ### Build with cache
    echo -e ""
    echo -e "---------------------------------"
    echo -e ""
    # Build The curl based image (with cache)
    docker build --build-arg BASE_IMG=curl -t curl2 .

    # Build The bash based image (with cache)
    docker build --build-arg BASE_IMG=bash -t bash2 .
    ```

---

## 04. Test the images

- We will now test the 4 images we have built previously
    ```bash
    # Debug mode
    set -x

    # Test the output images
    docker run curl1
    docker run curl2
    docker run bash1
    docker run bash2
    ```

- You should see output similar to this:
    ```bash
    + docker run curl1
    This file is from curl image
    + docker run curl2
    This file is from curl image
    + docker run bash1
    This file is from bash image
    + docker run bash2
    This file is from bash image
    ```

---

## 05. Quiz
  
  * What will be the results of this d`Dockerfile`?
  * Try to answer and then build the following `Dockerfile` to see the results:
        ```dockerfile
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
        CMD ["cat", "image.txt"]
        ```
  - Test your answer with the following command:

    ```bash
    docker build -f Dockerfile2 .
    ```

---

## 06. Build a specific target

  - We can build our specific image and stop at the desired stage.
  - In other words, we don't need to build all the images within the `Dockerfile`.

    ```bash
    docker build --target build-curl -f Dockerfile2 .
    ```

---

## 07. In-Class Exercise
    
- Create a `multi-stage` `Dockerfile` that will build 2 images.
- The first image will be based on `alpine` and will create a file named `alpine.txt` with the content: `This is alpine image`.
- The second image will be based on `node` and will create a file named `node.txt` with the content: `This is node image`.
- The final image should be based on `alpine` and should copy the files which you created from the previous stages and display their content when the container will run.
- Hint: Use the `COPY --from=` command to copy files from previous stages.

<details>
<summary>Solution</summary>

### Dockerfile Solution

<br>
Create a file named `Dockerfile-exercise`:

```dockerfile
# First stage: Alpine image
FROM  alpine AS alpine-stage
RUN   echo "This is alpine image" > alpine.txt

# Second stage: Node image
FROM  node AS node-stage
RUN   echo "This is node image" > node.txt

# Final stage: Alpine with files from previous stages
FROM  alpine
COPY  --from=alpine-stage alpine.txt  .
COPY  --from=node-stage node.txt      .

# Run the command to display contents
CMD   cat alpine.txt && cat node.txt
```

### Build and Test
<br>
Build the image:

```bash
docker build -f Dockerfile-exercise -t exercise-solution .
```

Run the container:

```bash
docker run exercise-solution
```

Expected output:

```text
This is alpine image
This is node image
```

### Explanation
<br>
1. First Stage (alpine-stage): Based on `alpine`, creates `alpine.txt` with the required content.
<br>
2. Second Stage (node-stage): Based on `node`, creates `node.txt` with the required content.
<br>
3. Final Stage: Based on `alpine` (lightweight), copies both files from previous stages using `COPY --from=<stage-name>` and displays their content when run.

</details>
