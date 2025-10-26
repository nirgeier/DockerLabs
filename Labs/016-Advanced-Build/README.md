![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 016 - Advanced Build

- This lab covers advanced Docker build techniques using BuildKit and BuildX.
- You will learn how to leverage BuildKit for faster and more efficient builds, and use BuildX to build multi-platform images locally.
- By the end of this lab, you will understand how to build Docker images for multiple architectures and platforms using the Docker CLI.

---

## Prerequisites

- Docker Desktop or Docker Engine with BuildX support
- Basic understanding of Dockerfiles and Docker CLI

## BuildKit

BuildKit is an improved backend for building Docker images. It provides:

- Faster builds through parallel processing
- Better caching mechanisms
- Support for advanced Dockerfile features
- Improved security with rootless builds

### Enabling BuildKit

BuildKit is enabled by default in Docker Desktop. For Docker Engine, you can enable it by setting the environment variable:

```sh
export DOCKER_BUILDKIT=1
```

Or add it to your shell profile:

```sh
echo 'export DOCKER_BUILDKIT=1' >> ~/.zshrc
source ~/.zshrc
```

### BuildKit Features

- **Parallel builds**: Build stages can run in parallel
- **Better caching**: More granular cache invalidation
- **Secrets management**: Secure handling of sensitive data during builds
- **Multi-stage builds**: Improved support for multi-stage Dockerfiles

Example Dockerfile using BuildKit features:

```dockerfile
# syntax=docker/dockerfile:1

FROM alpine:latest AS base
RUN apk add --no-cache git

FROM base AS build
WORKDIR /app
COPY . .
RUN echo "Building application..."

FROM alpine:latest
COPY --from=build /app /app
CMD ["echo", "Application built with BuildKit"]
```

## BuildX

BuildX is a Docker CLI plugin that extends the build capabilities with BuildKit. It provides:

- Multi-platform builds
- Advanced build options
- Custom build drivers
- Bake support for complex builds

### Installing BuildX

BuildX comes pre-installed with Docker Desktop. For Docker Engine:

```sh
# Download and install BuildX
mkdir -p ~/.docker/cli-plugins
curl -L https://github.com/docker/buildx/releases/latest/download/buildx-linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
```

### Building Multi-Platform Images Locally

BuildX allows you to build images for multiple platforms simultaneously. To build for all platforms locally, you need to enable QEMU emulation:

```sh
# Enable QEMU emulation for cross-platform builds
docker run --privileged --rm tonistiigi/binfmt --install all
```

Or using the Docker image for this purpose:

```sh
# Use the docker/binfmt image to enable multi-platform support
docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64c
```

---

## Using tonistiigi/binfmt for QEMU Emulation

The [tonistiigi/binfmt](https://github.com/tonistiigi/binfmt) project provides a Docker image that installs QEMU and binfmt_misc support, enabling cross-platform architecture emulation. This is essential for building Docker images for different CPU architectures on your local machine.

**What it does:**

- Installs QEMU user-mode emulation for various architectures
- Configures binfmt_misc to automatically use QEMU when running foreign binaries
- Enables building and testing multi-platform Docker images locally

**Installation and Setup:**

```sh
# Install QEMU and binfmt support for all architectures
docker run --privileged --rm tonistiigi/binfmt --install all

# Install specific architectures only
docker run --privileged --rm tonistiigi/binfmt --install amd64,arm64,arm

# Check installed formats
docker run --privileged --rm tonistiigi/binfmt

# Uninstall (if needed)
docker run --privileged --rm tonistiigi/binfmt --uninstall all
```

**Supported Architectures:**

- `amd64` (x86-64)
- `arm64` (ARM 64-bit)
- `arm` (ARM 32-bit)
- `ppc64le` (PowerPC 64-bit little-endian)
- `s390x` (IBM System z)
- `riscv64` (RISC-V 64-bit)
- And more...

**Persistent Setup:**
To make the setup persistent across Docker daemon restarts, you can create a systemd service or add it to your Docker startup script.

**Verification:**
After installation, verify that binfmt is working:

```sh
# Check binfmt_misc entries
cat /proc/sys/fs/binfmt_misc/qemu-aarch64

# Test with a simple command
docker run --rm arm64v8/alpine uname -m  # Should show aarch64
```

**Common Issues:**

- **Permission denied**: Run with `--privileged` flag
- **Already installed**: The tool is idempotent, running it multiple times is safe
- **Docker Desktop**: May require restarting Docker Desktop after installation

This tool is the foundation for local multi-platform Docker builds, allowing you to emulate different architectures without needing physical hardware.

#### Building on macOS

On macOS, Docker Desktop provides built-in support for multi-platform builds, but for full cross-platform emulation (especially when building ARM images on Intel Macs or vice versa), you need to set up QEMU using the Docker binfmt image.

**Prerequisites:**

- Docker Desktop for Mac (latest version)
- At least 4GB of RAM allocated to Docker

**Setup QEMU on macOS:**

```sh
# Enable binfmt support for multi-architecture emulation
docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64c

# Verify the setup
docker buildx inspect --bootstrap
```

**Supported Platforms on macOS:**

- `linux/amd64` (Intel/AMD)
- `linux/arm64` (Apple Silicon)
- `linux/arm/v7` (32-bit ARM)
- `linux/arm/v6` (Raspberry Pi)

**Example: Building for all platforms on macOS:**

```sh
# Create a builder with docker-container driver for better isolation
docker buildx create --use --name mac-multi-builder --driver docker-container

# Build for all supported platforms
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 \
  -t myapp:all-platforms \
  --push \
  .

# For local testing (load only native platform)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:native \
  --load \
  .
```

**Troubleshooting macOS builds:**

- If builds fail with QEMU errors, restart Docker Desktop
- Ensure Docker Desktop has enough RAM (8GB+ recommended for multi-platform builds)
- Use `--progress=plain` for detailed build logs
- Check available platforms: `docker buildx inspect --bootstrap | grep Platforms`

### Basic Multi-Platform Build

```sh
# Create a new builder instance
docker buildx create --use --name multi-platform-builder

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t myapp:multi .

# Build and push to registry
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t myregistry.com/myapp:multi --push .
```

### Advanced BuildX Commands

- **List builders**:

  ```sh
  docker buildx ls
  ```

- **Inspect builder**:

  ```sh
  docker buildx inspect multi-platform-builder
  ```

- **Build with custom output**:

  ```sh
  docker buildx build --platform linux/amd64,linux/arm64 -t myapp:multi --output type=local,dest=./dist .
  ```

- **Build with bake** (using docker-bake.hcl file):

  ```sh
  docker buildx bake
  ```

### Example: Multi-Platform Node.js Application

Create a sample application:

```sh
mkdir multi-platform-example
cd multi-platform-example

# Create package.json
cat <<EOF > package.json
{
  "name": "multi-platform-app",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Create index.js
cat <<EOF > index.js
const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from multi-platform Docker app!',
    platform: process.arch,
    timestamp: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(\`App listening on port \${port}\`);
});
EOF

# Create Dockerfile
cat <<EOF > Dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
EXPOSE 3000
CMD ["npm", "start"]
EOF
```

Build for multiple platforms:

```sh
# Enable multi-platform support
docker run --privileged --rm docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64c

# Create and use builder
docker buildx create --use --name multi-builder

# Build for multiple platforms
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t multi-platform-node:latest --load .

# Test the built image
docker run -p 3000:3000 multi-platform-node:latest
curl localhost:3000
```

### BuildX Bake for Complex Builds

Create a `docker-bake.hcl` file for complex multi-target builds:

```hcl
group "default" {
  targets = ["app", "debug"]
}

target "app" {
  context = "."
  dockerfile = "Dockerfile"
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["myapp:latest"]
}

target "debug" {
  inherits = ["app"]
  dockerfile = "Dockerfile.debug"
  tags = ["myapp:debug"]
}
```

Build using bake:

```sh
docker buildx bake
```

### Troubleshooting

- **QEMU issues**: Ensure QEMU is properly installed for cross-platform emulation
- **Builder not found**: Use `docker buildx create --use` to create a new builder
- **Platform not supported**: Check available platforms with `docker buildx inspect --bootstrap`
- **Build failures**: Use `--progress=plain` for detailed build output

### Cleanup

```sh
# Remove builder
docker buildx rm multi-platform-builder

# Clean up images
docker image rm myapp:multi multi-platform-node:latest
```

---

This lab demonstrates the power of BuildKit and BuildX for advanced Docker builds, enabling efficient and multi-platform container development.
