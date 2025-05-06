#!/bin/bash

CONTAINER_NAME=portainer
URL=http://localhost:9000

echo "🚀 Starting Portainer..."

# Check if it is already running
if docker ps --format '{{.Names}}' | grep -qw "$CONTAINER_NAME"; then
  notify-send "Portainer" "It is already running in $URL"
  xdg-open "$URL"
  exit 0
fi

# Delete if it already existed
if docker ps -a --format '{{.Names}}' | grep -qw "$CONTAINER_NAME"; then
  echo "🧼 Deleting previous container..."
  docker rm -f $CONTAINER_NAME
fi

# Volume
docker volume inspect portainer_data &>/dev/null || docker volume create portainer_data

# Run a new, clean container without HTTPS
docker run -d \
  -p 9000:9000 \
  --name $CONTAINER_NAME \
  --restart=always \
  --privileged \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

notify-send "Portainer" "Successfully started in $URL"
xdg-open "$URL"
