

![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 002 - Create a basic container using Dockerfile

- In this lab we will create our first container using `Dockerfile`
- The container will be used to serve a simple `NodeJs` web server
- No `NodeJs` knowledge is required
- You will need to create, build, tag & push your container to DockerHub
- The lab is divided into the several tasks:
    
    - [01. Prepare the server code](#01-prepare-the-server-code)
    - [02. Test the `server.js` code](#02-test-the-serverjs-code)
    - [03. Write the `Dockerfile`](#03-write-the-dockerfile)
    - [04. Build the image](#04---build-the-image)
    - [05. Login to DockerHub](#05-login-to-dockerhub)
    - [06. Push the image to DockerHub](#06---push-the-image-to-dockerhub)
    - [07. Verify the push](#07-verify-the-push)
    - [08. Test the image](#08---test-the-image)
    - [09. Test the server](#09-test-the-server)
    - [10. Clean up](#10-clean-up)

---

## 01. Prepare the server code

- Our container will include the following `NodeJs` simple web server
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

---

## 02. Test the `server.js` code

- Before we "pack" our code in Docker image, let's test the code
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

## 03. Write the `Dockerfile`

- Now let's create a `Dockerfile` with the code we have just created above
- The `Dockerfile` will be based on `nodejs` image and will include our `server.js`
    ```Dockerfile
    #
    # Filename: Dockerfile
    #
    # Use node as our base image
    FROM      node

    # Optional: Set working directory
    WORKDIR   /usr/src

    # Copy the server code to our working directory [.]
    COPY      server.js .

    # Mark the port which will required for the server
    EXPOSE    8888

    # Start the server when the container is started
    CMD       ["node", "./server.js"]
    ```

---

## 04. Build the image

- Once we have the docker file ready, we can build the image
- Once the image is ready, we will push it to DockerHub so you will need an account.
- We will name the image: `<DockerHub username/repository:version>`.
    ```sh
    ###
    ### Build the image
    ### Tag the image with the following 
    ###     DockerHub username/repository:version
    ###
    docker build -t nirgeier/docker-labs-002 .
    ```

---

## 05. Login to DockerHub

- Login to `DockerHub`
  - Execute `docker login` and enter your `DockerHub` credentials when prompted
  - If you don't have a `DockerHub` account, create one at: [https://hub.docker.com/signup](https://hub.docker.com/signup)
  - You will need to push the image to `DockerHub` in the next step

---

## 06. - Push the image to DockerHub

!!! danger "Docker Login Required"
    You must be logged in to `DockerHub` before you can push to `DockerHub`

- Example: `docker push username/image:tag` 

---

## 07. Verify the push

- Login to your `DockerHub` account and verify that the image exists under your `DockerHub` account.

---

## 08. Test the image

- Last step is to test our image
- To do so we will pull and run the image from `DockerHub`
- Once the container has started, we will test the server
    ```sh
    ###
    ### Pull the image from DockerHub
    ###  Replace the image tag with your image tag
    ### 
    docker   run -d               \
            --name 002-container \
            -p 8888:8888         \
            nirgeier/docker-labs-002

    ### Check that the container is working as expected
    docker logs 002-container         
    ```

---

## 09. Test the server

- Test the server that is running on docker.

    ```sh
    # Test the server that is running on docker
    curl -s localhost:8888

    ### ExpectedOutput:
    Server is running.!! You asked for: /
    ```

---

## 10. Clean up

- Stop and remove the container
    ```sh
    # Stop the container
    # If we used --rm the container should remove itself
    docker stop 002-container

    # If not used --rm - remove the container
    docker rm 002-container
    ```
---

![Well Done](../assets/images/well-done.png)