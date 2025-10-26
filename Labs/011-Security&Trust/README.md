![DockerLabs Banner](../assets/images/docker-logos.png)

---

# Lab 011 - Docker Security & Trust

- This lab covers advanced Docker security features and best practices for container security and privilege management.
- You'll learn about reducing the attack surface, implementing the Principle of Least Privilege, and using Docker's security mechanisms to protect your containers.
- Topics include non-root user execution, Linux capabilities, security options, and mandatory access control.
- By the end of this lab, you'll understand how to build and run secure Docker containers.

---

<!-- omit in toc -->
## Table of Contents

- [🛡️ Non-Root User Execution with the `USER` Instruction](#%F0%9F%9B%A1-non-root-user-execution-with-the-user-instruction)
  - [How to Use `USER`](#how-to-use-user)
- [🔒 Advanced Security Issues and Features](#%F0%9F%94%92-advanced-security-issues-and-features)
  - [1. Privileged Containers (`--privileged`)](#1-privileged-containers---privileged)
  - [2. Linux Capabilities (`--cap-drop`, `--cap-add`)](#2-linux-capabilities---cap-drop---cap-add)
  - [3. Preventing Privilege Escalation](#3-preventing-privilege-escalation)
  - [4. Mandatory Access Control (MAC)](#4-mandatory-access-control-mac)
  - [5. User Namespace Remapping (UserNS)](#5-user-namespace-remapping-userns)
- [🔑 Summary of Security Best Practices](#%F0%9F%94%91-summary-of-security-best-practices)

---

* Docker's advanced features offer critical mechanisms for **container security and privilege management**, primarily revolving around reducing the attack surface. 
* The key is to adhere to the **Principle of Least Privilege (PoLP)**.

## 🛡️ Non-Root User Execution with the `USER` Instruction

* By default, the process inside a Docker container runs as the `root user (UID 0)`, which is a major security risk. 
* If an attacker successfully exploits a vulnerability in the application, they gain **root access inside the container**. 
* Depending on the container's configuration and any underlying kernel vulnerabilities, this could potentially lead to a **container breakout** and **root access to the host machine**.
* The `USER` instruction in a `Dockerfile` is essential for mitigating this risk:

---

## How to Use `USER`

1. Create a Non-Root User
2. Use a `RUN` instruction to create a dedicated user and group *before* switching the user.
    ```dockerfile
    # Create an unprivileged user (e.g., 'appuser' with UID 1001)
    RUN adduser -D appuser

    # Set the ownership of the application directory to the new user
    RUN mkdir /app && chown -R appuser:appuser /app

    # Switch to the non-root user for all subsequent instructions and runtime
    USER appuser 

    WORKDIR /app
    # ... rest of your application commands (e.g., CMD)
    ```

!!! tip "adduser -D"

    Using `adduser -D` (on Alpine) creates a system user without a password or home directory, which is more secure.

---

## Best Practices for Permissions:

<div class="grid cards" markdown>

  -   ### File Permissions

      * Ensure the non-root user has the necessary **read, write, and execute permissions** for all files, directories, or temporary spaces the application needs. 
      * This often requires running `chown` in the Dockerfile.

  -   ### Multi-Stage Builds

      * Use **multi-stage builds** to perform privileged operations (like installing system packages with `apt` or `yum`) in a "builder" stage run as root, and then copy only the necessary artifacts into a minimal, non-root "runtime" stage. 
      * This prevents residual root tools or sensitive build-time files from existing in the final image.


  -   ### Bind Ports > 1024

      * Only the root user can bind to privileged ports (0-1023). 
      * If your application runs as non-root, it must bind to ports **1024 or higher** (e.g., port 8080).

  - ### User

      * Always specify a non-root user with the `USER` instruction in your Dockerfile to prevent running as root.
      * Avoid using `sudo` inside containers; instead, configure permissions properly at build time.
      * Consider using well-known non-root users like
  
  - ### Privileged Containers

      * Avoid running containers with the `--privileged` flag, as it grants excessive permissions and can lead to host compromise.
      * Instead, use specific capability additions (`--cap-add`) if certain elevated privileges are necessary.
      * Always review and minimize the capabilities your container needs.
      * Consider using tools like `seccomp` to restrict system calls your container can make.
  
</div>

---

## 🔒 Advanced Security Issues and Features

* Beyond running as a non-root user, Docker provides several advanced features to lock down container security:

### 1. Privileged Containers (`--privileged`)

* A privileged container is the **most dangerous security configuration** and should be avoided at all costs unless absolutely necessary (e.g., for running Docker-in-Docker or a tool that needs to interact directly with the host kernel).

  - **Security Issue:** 
    - Running a container with the `--privileged` flag grants it **all Linux Capabilities** (see below) and allows it to access all devices on the host. In a privileged container, the root user inside the container is essentially **equivalent to the root user on the host machine**. A container breakout is almost guaranteed.
    - **Mitigation:** **NEVER** use `--privileged` in production.   
      Instead, identify the specific capabilities your application needs and grant only those using the `--cap-add` flag.

### 2. Linux Capabilities (`--cap-drop`, `--cap-add`)

* Linux Capabilities are a finer-grained way to manage root permissions. 
* Traditional Unix divides processes into two categories: **root** (UID 0) and **unprivileged**. 
* Capabilities break down the powers of the root user into discrete units.

  - By default, Docker grants a set of "safe" capabilities and **drops dangerous ones**.
  - **Best Practice:** Use the `--cap-drop=ALL` flag to remove **all** capabilities, then use `--cap-add` to grant only the handful that the application truly requires (PoLP).
    ```bash
    # Runs the container with no capabilities except NET_BIND_SERVICE
    # A container that needs to bind to a low-numbered port (e.g., port 80) 
    # only needs the `NET_BIND_SERVICE` capability.
    docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE my-image
    ```

### 3. Preventing Privilege Escalation

* Even if a container starts as non-root, a malicious process could attempt to escalate its privileges.

  * **`no-new-privileges`:** Use the `--security-opt=no-new-privileges` flag to prevent a process from gaining new privileges via mechanisms like `setuid` or `setgid` binaries. This is a crucial security layer.

### 4. Mandatory Access Control (MAC)

* Docker integrates with two major Linux security modules for deeper kernel-level protection:

| Feature | Description | Purpose |
| :--- | :--- | :--- |
| **Seccomp (Secure Computing)** | Filters which **system calls (syscalls)** a container process can make to the Linux kernel. | Blocks dangerous syscalls that could be used for container breakout, even if the process is running as root. Docker uses a restrictive **default profile**. |
| **AppArmor (Application Armor)** | Creates **Mandatory Access Control (MAC) profiles** that limit what files, network resources, and other capabilities a container can access. | Provides an extra layer of defense-in-depth by confining the container process's access to host resources. Docker loads a moderately protective `docker-default` profile. |

### 5. User Namespace Remapping (UserNS)

* This is one of the **strongest isolation features** for mitigating the risk of a container breakout.

  * **How it Works:** It maps the **root user (UID 0) inside the container** to an **unprivileged user (a high UID, e.g., 100000)** on the host machine.
  * **Security Benefit:** If an attacker *does* manage to escape the container, they only have the privileges of the unprivileged mapped user on the host, **not** actual root access. This significantly reduces the potential for host compromise. This feature can be enabled at the Docker daemon level.

---

## 🔑 Summary of Security Best Practices

| Security Principle | Docker Feature/Instruction | Impact |
| :--- | :--- | :--- |
| **Least Privilege** | `USER non-root` in `Dockerfile` | Prevents an exploit from gaining root access inside the container. |
| **Runtime Hardening** | `--cap-drop=ALL`, `--cap-add=<needed-caps>` | Removes unnecessary superuser powers, reducing the attack surface. |
| **Kernel Isolation** | **Seccomp/AppArmor** | Limits the dangerous operations (syscalls, file access) a process can perform. |
| **No Escalation** | `--security-opt=no-new-privileges` | Prevents a non-root process from gaining root powers during execution. |
| **Host Protection** | **User Namespace Remapping** | Ensures that an escaped container process runs as an unprivileged user on the host. |

---

## Running the Demos

This lab includes individual demo scripts for each security topic:

| Demo Script                 | Description                                               |
|-----------------------------|-----------------------------------------------------------|
| `demo1-nonroot.sh`          | Demonstrates non-root user execution                      |
| `demo2-capabilities.sh`     | Shows Linux capabilities management                       |
| `demo3-security-options.sh` | Demonstrates security options like no-new-privileges      |
| `demo4-mac.sh`              | Checks Mandatory Access Control (Seccomp/AppArmor) status |
| `demo5-userns.sh`           | Explores User Namespace Remapping configuration           |

To run a demo:

```bash
chmod +x demo1-nonroot.sh
./demo1-nonroot.sh
```

Each demo is self-contained with automatic cleanup.

