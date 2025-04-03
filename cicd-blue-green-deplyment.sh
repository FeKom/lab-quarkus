#!/bin/zsh -xe

APP=$1
GREEN_CONTAINER_DEPLOY_TAG=$2

# Ensure both APP and GREEN_CONTAINER_DEPLOY_TAG are provided
if [ $# -lt 2 ]; then
  echo "Usage: $0 <app_name> <green_container_deploy_tag>"
  exit 1
fi

# Get the list of blue containers
BLUE_CONTAINERS=$(docker ps -qf "name=${APP}")
BLUE_CONTAINERS_SCALE=$(echo "$BLUE_CONTAINERS" | wc -w)

# Determine the scale for green containers
GREEN_CONTAINERS_SCALE=$((BLUE_CONTAINERS_SCALE * 2))
if [ "$BLUE_CONTAINERS_SCALE" -eq 0 ]; then
  GREEN_CONTAINERS_SCALE=1
fi

# Deploy green containers
TAG=$GREEN_CONTAINER_DEPLOY_TAG docker-compose up -d "$APP" --scale "$APP=$GREEN_CONTAINERS_SCALE" --no-recreate --no-build

# Wait for green containers to become healthy
while [ "$(docker ps -q -f "name=${APP}" -f "health=healthy" | wc -l)" -ne "$GREEN_CONTAINERS_SCALE" ]; do
  echo "Waiting for containers to become healthy..."
  docker ps --filter "name=${APP}" --format "table {{.Names}}\t{{.Status}}"
  sleep 1
done

# Terminate blue containers if they exist
if [ "$BLUE_CONTAINERS_SCALE" -gt 0 ]; then
  docker kill --signal=SIGTERM $BLUE_CONTAINERS
fi

echo "Deployment completed successfully."