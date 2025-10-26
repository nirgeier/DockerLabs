![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 009 - Inspect Docker Image Layers with Dive

- This lab introduces the `dive` tool for analyzing Docker image layers.
- `dive` is a tool for exploring each layer in a Docker image, helping you understand what's changed in each layer and identify ways to optimize your images.
- In this lab, we'll create a multi-layer Docker image and use `dive` to inspect its layers.
- By the end of this lab, you'll understand how Docker images are built layer by layer and how to use `dive` for image analysis.

---

## What is Dive?

- `dive` is a tool for exploring the contents of Docker images.
- It allows you to see what files were added, modified, or removed in each layer.
- This is useful for optimizing image size, understanding image composition, and debugging build issues.
- `dive` can be run as a Docker container itself or installed locally.

---

## 01. Setup Dive

- First, let's pull the `dive` image from Docker Hub.
- If `dive` is not installed locally, we can use it via Docker.

```sh
# Pull the dive image
docker pull wagoodman/dive
```

- Check if `dive` is installed locally. If not, we'll alias it to run via Docker.

```sh
# Check if dive is installed
if ! command -v dive &> /dev/null
then
  echo "dive could not be found, using Docker alias..."
  # Alias dive to run via Docker
  alias dive="docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock docker.io/wagoodman/dive"
fi
```

---

## 02. Create a Multi-Layer Dockerfile

- Let's create a Dockerfile with several layers to demonstrate how `dive` works.
- Each `RUN` command creates a new layer.

```sh
# Create the Dockerfile
cat << EOF > Dockerfile
### Layer 00
FROM alpine

## Layer 01
WORKDIR /__app

## Layer 02
RUN echo "Hello World" > file1.txt

## Layer 03
RUN echo "10.10.10.10" > /etc/hosts

## Layer 04
RUN cat /etc/hosts > hosts.txt

EOF
```

---

## 03. Build the Image

- Build the Docker image from the Dockerfile.

```sh
# Build the image
docker build -t nirgeier/docker-labs-07-dive -f Dockerfile .
```

---

## 04. Print the Dockerfile Layers

- Let's review what each layer does:

```sh
echo "=== Dockerfile Layers ==="
echo "Layer 00: FROM alpine"
echo "Layer 01: WORKDIR /__app"
echo "Layer 02: RUN echo \"Hello World\" > file1.txt"
echo "Layer 03: RUN echo \"10.10.10.10\" > /etc/hosts"
echo "Layer 04: RUN cat /etc/hosts > hosts.txt"
echo "========================="
```

---

## 05. Inspect Layers with Dive

- Now, let's use `dive` to inspect the image layers.
- `dive` will analyze the image and show you what's in each layer.
- We'll also generate a JSON output file for further analysis.

```sh
# Run dive on the image and generate JSON output
dive nirgeier/docker-labs-07-dive --json output.json
```

- When `dive` runs, you'll see an interactive interface showing:
  - The layers on the left
  - File changes in each layer on the right
  - Use arrow keys to navigate, and press `Ctrl+C` to exit

---

## 06. Analyze the JSON Output

- After running `dive`, we can analyze the `output.json` file.
- Let's use `jq` to extract information about files changed in layers 2 and above.

```sh
# Search for files changed in layers starting from index 2
jq '.layer[] | select(.index >= 2) | "\(.command) -> \(.fileList[]?.path)"' output.json
```

- This will show you which files were added or modified in each layer.

---

## 07. Clean Up

- Remove the created image and files.

```sh
# Remove the image
docker rmi nirgeier/docker-labs-07-dive

# Remove the Dockerfile and output.json
rm -f Dockerfile output.json
```

---

![Well Done](../assets/images/well-done.png)
