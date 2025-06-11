import requests
import json
import sys
import os

METADATA_ENDPOINT = "http://edc-provider:19194/protocol/catalog/request"

def main(payload_path):
    try:
        with open(payload_path, "r") as f:
            request_body = json.load(f)
    except json.JSONDecodeError as e:
        raise ValueError(f"Impossible to read json: {str(e)}")

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": os.environ.get("USER_PASSPORT_TOKEN")
    }

    try:
        res = requests.post(METADATA_ENDPOINT, json=request_body, headers=headers)
        metadata = res.json()
    except requests.exceptions.HTTPError as e:
        raise ValueError(f"An error occurred when requesting metadata: {str(e)}")

    with open("output.json", "w") as o:
        json.dump(metadata, o)

if __name__ == "__main__":
    main(sys.argv[1])
    exit(0)
