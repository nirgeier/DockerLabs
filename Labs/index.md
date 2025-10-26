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

<div class="grid cards" markdown>

-   ## 001 - Docker CLI

    ---

    Practice the core Docker CLI commands for running, inspecting, and managing containers.

    [:octicons-arrow-right-24: Get started](001-DockerCli/)

-   ## 002 - Dockerfile Basics

    ---

    Build your first Node.js container image from a Dockerfile and publish it to a registry.

    [:octicons-arrow-right-24: Get started](002-DockerFile/)

-   ## 003 - Dockerfile Multi-Stage

    ---

    Learn how multi-stage Dockerfiles produce lean images across build targets.

    [:octicons-arrow-right-24: Get started](003-DockerFile-MultiStage/)

-   ## 004 - Local Registry

    ---

    Stand up a private registry, retag images, and push or pull them locally.

    [:octicons-arrow-right-24: Get started](004-LocalRegistry/)

-   ## 005 - Docker Compose Stack

    ---

    Orchestrate a WordPress and MariaDB stack with Docker Compose.

    [:octicons-arrow-right-24: Get started](005-DockerCompose-Basics/)

-   ## 006 - Compose Environments

    ---

    Structure Compose files and env vars for dev and prod workflows.

    [:octicons-arrow-right-24: Get started](006-DockerCompose-env/)

-   ## 007 - Docker Compose Fragments

    ---

    Learn advanced Docker Compose features with fragments and modular configurations.

    [:octicons-arrow-right-24: Get started](007-DockerCompose-fragments/)

-   ## 008 - CRI `crictl`

    ---

    Learn about container runtime interface tooling using crictl.

    [:octicons-arrow-right-24: Get started](008-crictl/)

-   ## 009 - Dive Layers

    ---

    Explore image layer creation and visualize them with the dive tool.

    [:octicons-arrow-right-24: Get started](009-dive-layers/)

-   ## 010 - Docker Bake

    ---

    Use Docker Buildx Bake to coordinate complex, multi-target image builds.

    [:octicons-arrow-right-24: Get started](010-bake/)

-   ## 011 - Security & Trust

    ---

    Learn advanced Docker security features and best practices for container security.

    [:octicons-arrow-right-24: Get started](011-Security&Trust/)

-   ## 012 - gVisor Seccomp

    ---

    Apply a gVisor runtime profile to block privileged syscalls inside a container.

    [:octicons-arrow-right-24: Get started](012-gvisor/)

-   ## 013 - onictl

    ---

    Learn about container networking with onictl.

    [:octicons-arrow-right-24: Get started](013-onictl/)

-   ## 100 - Hands-On Intro

    ---

    Guided Node.js exercise covering the full build, run, and publish workflow.

    [:octicons-arrow-right-24: Get started](100-Hands-On/)

</div>

---

## Tasks

| Task | Description |
| --- | --- |
| [DockerCommit](Tasks/DockerCommit/) | In-class exercise for capturing container changes with `docker commit`. |
| [DockerDebug](Tasks/DockerDebug/) | Debugging challenge: troubleshoot a crashing Flask container and fix missing configurations. |
| [DockerfileAdvanced](Tasks/DockerfileAdvanced/) | Advanced Dockerfile exercise covering BuildKit secrets, caching, and health checks. |
| [DockerLogs](Tasks/DockerLogs/) | In-class exercise for running cowsay container, managing logs, and debugging. |
| [MultiStage](Tasks/MultiStage/) | In-class exercise for creating multi-stage Dockerfiles with alpine and node images. |

---

Happy learning and hacking with Docker!
