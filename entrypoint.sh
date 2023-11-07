#!/bin/bash

echo "RUNNING ENTRYPOINT"

# Check if HUGGING_FACE_MODEL environment variable exists and is not empty
if [ -n "$HUGGING_FACE_MODEL" ]
then
    echo "HUGGING_FACE_MODEL=$HUGGING_FACE_MODEL" >> .env
fi

# Check if CLI_ARGS environment variable exists and is not empty
if [ -n "$CLI_ARGS" ]
then
    echo "CLI_ARGS=$CLI_ARGS" >> .env
fi

# Activate virtual environment and download the model
. /app/venv/bin/activate && python3 download-model.py ${HUGGING_FACE_MODEL}

# Start your servers, ensure your server is able to read from the .env file
python3 server.py ${CLI_ARGS} &
python3 -u handler.py &
wait