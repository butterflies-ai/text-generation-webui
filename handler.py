import runpod
import os
import time
import subprocess
import requests
import json

# Load your model(s) into vram here
cli_args = os.getenv('CLI_ARGS', '')  # Get environment variable
print(f"running this command: {cli_args}")

server_command = f"python3 server.py {cli_args}"

# Execute server command in the background
server_process = subprocess.Popen(server_command, shell=True)

def handler(event):
    print(event)

    webhook = event.get('webhook')
    if webhook:
        event["status"] = "IN_PROGRESS"
        # If the job is done, POST back to the webhook url the job completion
        requests.post(webhook, json=event)


    url = "http://0.0.0.0:5000/api/v1/generate"
    chat_input_url = "http://0.0.0.0:5000/api/v1/chat"

    headers = {
        "Content-Type": "application/json",
    }

    data = {}

    # Update data with the provided parameters, if available
    provided_params = event['input']

    try:
        if provided_params['mode'] == "chat":
            url = chat_input_url
    except:
        # default url
        url

    for param in provided_params:
        if provided_params[param] is not None:
            data[param] = provided_params[param]

    max_retry_time = 15
    start_time = time.time()

    while True:
        try:
            response = requests.post(url, headers=headers, data=json.dumps(data))
            response_data = response.json()

            # Check if a webhook url is provided and if the job is done
            webhook = event.get('webhook')
            if webhook:
                # If the job is done, POST back to the webhook url the job completion
                requests.post(webhook, json=response_data)

            return response_data
        except requests.exceptions.RequestException:
            elapsed_time = time.time() - start_time
            if elapsed_time >= max_retry_time:
                print("Maximum retry time reached. Exiting...")
                return "timeout"
                break
            else:
                print("Retrying in 1 second...")
                time.sleep(1)

runpod.serverless.start({
    "handler": handler
})
