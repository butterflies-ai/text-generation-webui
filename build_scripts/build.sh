#!/bin/bash

source "./build_scripts/$1.env"

SOURCE_REPOSITORY="text-generation-ui-text-generation-webui"
SOURCE_TAG="latest"
TARGET_REPOSITORY="vu0tran/text-generation-app"

if [ -z "$MODEL_FILE" ]; then
  MODEL_FILE=${MODEL_NAME//\//_}
fi

echo $MODEL_FILE

if [ ! -d "models/$MODEL_FILE" ]; then
  rm -rf "./models"
  mkdir "./models"

  if [ -d "models_cache/$MODEL_FILE" ]; then
    echo "FOUND MODEL IN CACHE, COPYING"
    cp -r "models_cache/$MODEL_FILE" "models/"
  else
    echo "MODEL NOT FOUND IN CACHE, DOWNLOADING"
    python3 download-model.py "$MODEL_NAME"
    echo "COPYING DOWNLOADED MODEL TO CACHE"
    cp -r "models/$MODEL_FILE" "models_cache/"
  fi
else
  echo "FOUND PRE-DOWNLOADED MODEL"
fi

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
