# DockerLabs Hands-on

![DockerLabs Banner](./assets/images/docker-logos.png)

---

* Welcome to the lab workspace that accompanies the DockerLabs project. 
* Each folder below is a self-contained lab that you can complete independently to sharpen specific containerization skills. 
* Follow the README file in each lab for detailed steps.

## How to Use Those Labs

{% include "../mkdocs/overrides/partials/usage.md" %}

---

## Lab Index

| Lab | Description |
| --- | --- |
| [001 - Docker CLI](001-DockerCli/) | Practice the core Docker CLI commands for running, inspecting, and managing containers. |
| [002 - Dockerfile Basics](002-DockerFile/) | Build your first Node.js container image from a Dockerfile and publish it to a registry. |
| [003 - Dockerfile Multi-Stage](003-DockerFile-MultiStage/) | Learn how multi-stage Dockerfiles produce lean images across build targets. |
| [004 - Local Registry](004-LocalRegistry/) | Stand up a private registry, retag images, and push or pull them locally. |
| [005 - Docker Compose Stack](005-DockerCompose/) | Orchestrate a WordPress and MariaDB stack with Docker Compose. |
| [006 - Compose Environments](006-DockerCompose-env/) | Structure Compose files and env vars for dev and prod workflows. |
| [007 - Image Layers & Dive](007-layers/) | Explore image layer creation and visualize them with the dive tool. |
| [008 - CRI `crictl`](008-crictl/) | Placeholder lab for container runtime interface tooling using crictl. |
| [009 - Multistage Patterns](009-multistage/) | Review advanced multistage techniques with language-specific examples. |
| [010 - Compose Reference](010-DockerCompose/) | Quick reference of everyday docker-compose commands and usage. |
| [011 - Docker Bake](011-bake/) | Use Docker Buildx Bake to coordinate complex, multi-target image builds. |
| [012 - gVisor Seccomp](012-gvisor/) | Apply a gVisor runtime profile to block privileged syscalls inside a container. |
| [100 - Hands-On Intro](100-Hands-On/) | Guided Node.js exercise covering the full build, run, and publish workflow. |


Happy learning and hacking with Docker!
