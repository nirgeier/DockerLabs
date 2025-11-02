# 012 - gVisor Lab

* This lab demonstrates the use of gVisor, a sandbox runtime for containers that provides an additional layer of security by intercepting and filtering system calls.

## Overview

* `gVisor` is an application `kernel`, written in Go, that implements a substantial portion of the Linux system call interface. 
* It provides a strong isolation boundary between the application and the host kernel, making it harder for attackers to compromise the host system even if they gain control of a container.

## Prerequisites

  - Docker installed
  - gVisor runtime installed (`runsc`)
  - Basic understanding of Docker and system calls

## Installation

* To install gVisor:

  ```bash
  # Install gVisor
  curl -fsSL https://gvisor.dev/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/gvisor-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/gvisor-archive-keyring.gpg] https://storage.googleapis.com/gvisor/releases release main" | sudo tee /etc/apt/sources.list.d/gvisor.list > /dev/null
  sudo apt-get update && sudo apt-get install -y runsc
  ```

## Examples

### Example 1: Blocking User Creation

* This example demonstrates how to use gVisor with a `seccomp` profile to block user creation syscalls.

    **Files:**

    - `demo.sh`: Script to run the demo
    - `block-user-creation.json`: Seccomp profile that blocks user-related syscalls

    **Run the demo:**

      ```bash
      ./demo.sh
      ```

* This will attempt to create a user inside a container running with gVisor and the seccomp profile. 
* The operation should fail, demonstrating the security isolation.

### Example 2: Blocking Mount Operations

* This example shows how to restrict mount operations using gVisor and seccomp.

  **Files:**

  - `demo-mount.sh`: Script to run the mount demo
  - `block-mount.json`: Seccomp profile that blocks mount-related syscalls
  - `Dockerfile`: Alpine image that attempts to mount tmpfs

  **Run the demo:**

  ```bash
  ./demo-mount.sh
  ```

  * This will build an Alpine image and attempt to mount a `tmpfs` inside the container. 
  * The mount operation should be blocked.

## Key Concepts

  - **Seccomp Profiles:** JSON files that define which syscalls are allowed or blocked
  - **gVisor Runtime:** `runsc` provides the sandboxed execution environment
  - **System Call Filtering:** Prevents potentially dangerous operations

## Additional Resources

- [gVisor Documentation](https://gvisor.dev/docs/)
- [Seccomp Profiles](https://docs.docker.com/engine/security/seccomp/)
- [Docker Runtime Options](https://docs.docker.com/engine/reference/run/#runtime-options)
