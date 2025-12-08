#!/bin/bash

# sets up the variables to represent my Docker image and a container to set it up
IMAGE_NAME="admahamdan2005/brawlstars-site"
CONTAINER_NAME="web_content"

# the echo statements state what each line of code does, as they're there to visually show and prove to the user the commands are working good:
echo "Step 1: pulls latest Docker image"
docker pull $IMAGE_NAME:latest

echo "Step 2: stops previous running container image"
docker stop $IMAGE_NAME 2>/dev/null || true

echo "Step 3: removes previous running container image"
docker rm $IMAGE_NAME 2>/dev/null || true

echo "Step 4: runs a new container image"
docker run -d --name $CONTAINER_NAME --restart unless-stopped -p 80:80 $IMAGE_NAME:latest

echo "All Steps completed!"
