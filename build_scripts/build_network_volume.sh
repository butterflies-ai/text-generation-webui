#!/bin/bash

source "./build_scripts/$1.env"

SOURCE_REPOSITORY="text-generation-ui-text-generation-webui"
SOURCE_TAG="latest"
TARGET_REPOSITORY="vu0tran/text-generation-app-network"

if [ -z "$MODEL_FILE" ]; then
  MODEL_FILE=${MODEL_NAME//\//_}
fi

echo $MODEL_FILE

# Copy environmental variables
cp -f template.env .env

# Append lines to .env
echo "HUGGING_FACE_MODEL=$MODEL_NAME" >> .env
echo "CLI_ARGS=--model $MODEL_FILE --listen --auto-devices --api --loader exllama_hf" >> .env

# Build
sudo docker compose up --build

# Get the latest image ID
IMAGE_ID=$(sudo docker images --format "{{.ID}}" --filter "reference=${SOURCE_REPOSITORY}:${SOURCE_TAG}" | head -n 1)

if [[ -z $IMAGE_ID ]]; then
  echo "No image found for ${SOURCE_REPOSITORY}:${SOURCE_TAG}"
  exit 1
fi

# Tag the image with the target repository and tag
sudo docker tag "$IMAGE_ID" "${TARGET_REPOSITORY}:${TARGET_TAG}"

# Push the tagged image to the target repository
sudo docker push "${TARGET_REPOSITORY}:${TARGET_TAG}"
