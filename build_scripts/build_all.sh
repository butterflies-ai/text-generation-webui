#!/bin/bash

SCRIPT_DIR=$(dirname "$0")
BUILD_SCRIPT="$SCRIPT_DIR/build.sh"

# Check if build.sh exists
if [ ! -f "$BUILD_SCRIPT" ]; then
  echo "build.sh script not found in the same directory."
  exit 1
fi

# Iterate over .env files
for env_file in "$SCRIPT_DIR"/*.env; do
  if [ -f "$env_file" ]; then
    echo "Building using $env_file"
    env_name=$(basename "$env_file" .env)
    "$BUILD_SCRIPT" "$env_name" "$env_file"
    echo ""
  fi
done
