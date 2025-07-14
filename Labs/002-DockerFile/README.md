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

### Pre-Requirements <!-- omit in toc -->

- Docker installed
- Dockerfile knowledge 
- DockerHub account

---

- [Step 01 - Write server code](#step-01---write-server-code)
- [Step 02 - Test the `server.js` code](#step-02---test-the-serverjs-code)
- [Step 03 - Write `Dockerfile`](#step-03---write-dockerfile)
- [Step 04 - Build the image (using Dockerfile)](#step-04---build-the-image-using-dockerfile)
- [Step 05 - Push the image to DockerHub](#step-05---push-the-image-to-dockerhub)
  - [05.01 - Login to DockerHub](#0501---login-to-dockerhub)
  - [05.02 - Push the image to DockerHub](#0502---push-the-image-to-dockerhub)
  - [05.03 - Verify the push](#0503---verify-the-push)
- [Step 06 - Test the image](#step-06---test-the-image)
  - [Step 06.01 - Spin the container](#step-0601---spin-the-container)
  - [Step 06.02 - Test the server](#step-0602---test-the-server)
- [Step 07 - Clean up](#step-07---clean-up)

## Lab - Basic container (Dockerfile) <!-- omit in toc -->

- In this lab we will build our first container
- The lab assume you know how to write dockerfile and to build them

## The Task <!-- omit in toc -->

- Create your first container.
  - The container will be used to serve a `NodeJs` simple web server
  - No NodeJs knowledge is required
  - You will need to create, build, tag & push your container to DockerHub

## Step 01 - Write server code

- Our container will include the following NodeJs simple web server
- Copy the code below and save it to a file named `server.js`

```js
//
// Filename: server.js
//
// Simple NodeJs Server
// The server is listening by default to port 8888
//
 
// import the HTTP module
var http = require('http');

// Define a port we want to listen to
// Later on we will pass the port as env parameter
// Default port is set to 8888
const PORT= process.env.PORT || 8888; 

// Create the server and listen for requests
// Create the server and listen for requests
http.createServer((request, response)=>{
    response.end('Server is running.!! You asked for: ' + request.url);
}).listen(PORT, ()=>{
    // Callback is triggered when server is getting a request
    console.log("Server listening on: http://localhost:%s", PORT);
});
```

## Step 02 - Test the `server.js` code

- Before we "pack" our code in Docker image lets test the code
- We will test the code inside `nodejs` docker 
  
  ```sh
  # Test the node code
  #   --rm            =   remove the container when done
  #   -d              =   run in detached mode
  #   -p              =   open the required ports
  #   -v              =   volume
  #   -w              =   workdir
  #   --name          =   the container name
  #   node            =   Execute a nodejs container to test our code
  #   node server.js  =   Execute the code
  docker   run --rm -d       \
    -v     $(pwd):/usr/src  \
    -w     /usr/src         \
    -p     8888:8888        \
    --name node_server      \
    node                    \
    node server.js   
  ```

## Step 03 - Write `Dockerfile`

- Now lets create a `Dockerfile` with the code we just created above
- The `Dockerfile` will be based upon `nodejs` image and will include our `server.js`

```Dockerfile
#
# Filename: Dockerfile
#
# Use node as our base image
FROM  node

# Optional: Set working directory
WORKDIR  /usr/src

# Copy the server code to our working directory [.]
COPY     server.js .

# Mark the port which will required for the server
EXPOSE   8888

# Start the server when the container is started
CMD ["node", "./server.js"]
```

- Lets verify that the Dockerfile is well defined and that there are no errors

  ```sh
  # Lint the Dockerfile and verify that the Dockerfile is well defined
  # We can ignore base image missing version errors
  docker run --rm -i --ignore DL3007 hadolint/hadolint < Dockerfile
  ```

## Step 04 - Build the image (using Dockerfile)

- Once we have the docker file we can build the image
- Once the image is ready we will push it to DockerHub so you will need an account.
- We will name the image: "Your Dockerhub username/repository:version"

  ```sh
  ###
  ### Build the image
  ### Tag the image with the following 
  ###     DockerHub username/repository:version
  ###
  docker build -t nirgeier/docker-labs-002 .
  ```

## Step 05 - Push the image to DockerHub

- Once the image is ready we will now push it to DockerHub
   
### 05.01 - Login to DockerHub

- Login to DockerHub
  - Execute `docker login` and enter your Docker Hub credentials when prompted

### 05.02 - Push the image to DockerHub

> [!NOTE]
> You must enter your Docker Hub credentials before you can push to DockerHub

- Execute `docker push username/image:tag` 

### 05.03 - Verify the push

- Login to your DockerHub account and verify that the image exists under your DockerHub account.

## Step 06 - Test the image

- Last step is to test our image
- To do so we will pull and run the image from DockerHub
- Once the container is started we will test the server

### Step 06.01 - Spin the container

- Spin the container from the image we just created

  ```sh
  ###
  ### Create the container from our image
  ###  ** Replace the image tag with your image tag
  ### 
  docker   run -d               \
          --name 002-container \
          -p 8888:8888         \
          nirgeier/docker-labs-002

  ### Check that the container is working as expected
  docker logs 002-container         
  ```

### Step 06.02 - Test the server

- Test the server that he is running on docker.

  ```sh
  # Test the server that he is running on docker
  curl -s localhost:8888

  ### Output:
  Server is running.!! You asked for: /
  ```

## Step 07 - Clean up

- Stop and remove the container

  ```sh
  # Stop the container
  # If we used --rm the container should remove itself
  docker stop 002-container

  # If not used --rm - remove the container
  docker rm 002-container
  ```

---

![](../../resources/well-done.png)



