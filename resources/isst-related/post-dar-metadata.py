import argparse
import json

import requests

from zoneinfo import ZoneInfo
from datetime import datetime


MDC_SERVICE_NAME = "metadata-catalog-emx2"
MDC_URI = f"http://{MDC_SERVICE_NAME}:8080/iderha/api/DAR/DataAccessRequest"


def rename_location(url):
    url = url.rstrip("/") + "/"
    return {
        "http://tesk-api-node-1:8080/ga4gh/tes/": "Federated Node 1",
        "http://tesk-api-node-2:8080/ga4gh/tes/": "Federated Node 2"
    }.get(url, "")

def check_key(o, key):
    if "." in key:
        key1, key2 = key.split(".", 1)
        if isinstance(o, list):
            try:
                key1 = int(key1)
                return check_key(o[key1], key2)
            except ValueError:
                return False
        return check_key(o[key1], key2) if key1 in o else False

    else:
        if key not in o:
            print(f"Key {key} not found in Object {o}")
        return key in o


def process_dar_list(dar_list, location):
    keys = ["id", "state", "stateRecords", "sub", "policyDefinition.policy.odrl:target"]
    clean_list = []
    for dar in dar_list:
        creation_date = sorted(dar["stateRecords"], key=lambda x: x['changedAt'])[0]["changedAt"]
        if not all([check_key(dar, key) for key in keys]):
            print("Some necessary keys are not part of the retrieved object:")
            print(f"Expected: {keys}")
            print(f"Found: {dar}")
            continue

        clean_list.append({
            "id": dar["id"],
            "state": dar["state"],
            "userId": dar["sub"],
            "assetId": dar["policyDefinition"]["policy"]["odrl:target"],
            "createdAt": datetime.fromtimestamp(int(creation_date)/1000, tz=ZoneInfo("Europe/Paris")).strftime("%d %b %Y - %H:%M:%S %Z"),
            "dataHost": rename_location(location),
        })

    return clean_list


def build_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--file", action="append"
    )
    parser.add_argument(
        "--location", action="append"
    )
    return parser


def main(args):
    files_list = args.file
    locations = args.location
    if not isinstance(files_list, list):
        raise ValueError("Unexpected arguments, expected a list of files")

    if len(files_list) != len(locations):
        raise ValueError("Unexpected error, different number of files and locations")

    with open(files_list[0], "r") as f:
        main_object = process_dar_list(json.load(f), locations[0])

    if len(files_list) > 1:
        for i, file in enumerate(files_list[1:]):
            with open(file, "r") as f:
                new_object = process_dar_list(json.load(f), locations[i+1])

            if not isinstance(new_object, list):
                raise ValueError(f"Content of file {file} should be an array")

            main_object += new_object

    res = requests.post(MDC_URI, json=main_object, headers={"Content-Type": "application/json"})
    if not res.ok:
        error = f"An error occurred while pushing assets metadata: {res.content}"
        print(error)
        raise requests.exceptions.HTTPError(error)


if __name__ == "__main__":
    parser = build_parser()
    args = parser.parse_args()
    main(args)
    print("Successfully sent request to MDC")
    exit(0)