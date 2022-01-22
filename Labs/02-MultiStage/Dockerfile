# Get the value of the desired image to build
ARG     BASE_IMG=${BASE_IMG}

# Build the base image
FROM    alpine AS base_image

# Add some packages to the base image
FROM    base_image  AS build-curl
RUN     echo -e "\033[1;33mThis file is from curl image\033[0m" > image.txt

# Add some packages to the base image
FROM    base_image  AS build-bash
RUN     echo -e "\033[1;32mThis file is from bash image\033[0m" > image.txt

#   Build the desired image
FROM    build-${BASE_IMG}
# We can use the FROM command as we see in the previous line or use the 
# `COPY  --from=build-${BASE_IMG} image.txt .` to copy a specific content 
RUN     cat image.txt 
CMD     cat image.txt 