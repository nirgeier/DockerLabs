FROM alpine

LABEL maintainer="nirgeier@gmail.com"

# Install shadow for user management
RUN apk update && apk add shadow

# The following command will likely be blocked by gVisor
RUN mount -t tmpfs none /mnt

# Start a shell
CMD ["/bin/sh"]



