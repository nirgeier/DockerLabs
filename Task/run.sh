#!/bin/bash

docker build --no-cache -t task .
docker build --no-cache -t task --target final3 .

docker run --rm task sh -c ls -la 