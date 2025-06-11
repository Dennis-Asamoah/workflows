import argparse
import boto3
import io
import json
import logging
import os
import requests
import sys

_log = logging.getLogger()

POLICY_ISSUER = "http://policy-issuer:1919/api/v1/file"
BUCKET_NAME = "mdc-storage"
POLICY_ROOT_FOLDER = "policy_files"


def argparser():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", help="Catalog DCAT metadata")
    parser.add_argument("-s", "--strict", action="store_true", help="Raises an error if retrieved policy files do not correspond to description in DCAT. Only log a warning if not")
    return parser


def arrays_equal(l1: list, l2: list):
    if len(l1) != len(l2):
        return False
    return all([a == b for a, b in zip(l1, l2)])


def get_filename_from_constraint(constraint: dict):
    if (
        constraint.get("odrl:leftOperand", {}).get("@id") == "fileName"
        and constraint.get("odrl:operator", {}).get("@id") in ["odrl:eq", "eq"]
    ):
        return constraint.get("odrl:rightOperand")
    else:
        return None


def build_s3_client():
    session = boto3.session.Session()
    client = session.client("s3")
    res = client.get_bucket_location(Bucket=BUCKET_NAME)
    assert res.get("ResponseMetadata", {}).get("HTTPStatusCode") == 200
    return client


def main():
    parser = argparser()
    args = parser.parse_args()
    retrieved_policies = {}
    with open(args.input, "r") as f:
        assets_json = json.load(f)

    client = build_s3_client()

    datasets = assets_json["dcat:dataset"] if isinstance(assets_json["dcat:dataset"], list) else [assets_json["dcat:dataset"]]

    for dataset in datasets:
        dataset_policy_id = dataset.get("policyId")
        dataset_policy_obligations = dataset.get("odrl:hasPolicy", {}).get("odrl:obligation", [])
        dataset_policy_obligations = dataset_policy_obligations if isinstance(dataset_policy_obligations, list) else [dataset_policy_obligations]
        dataset_policy_constraints = []
        for obligation in dataset_policy_obligations:
            constraints = obligation.get("odrl:constraint")
            if constraints is not None:
                constraints = constraints if isinstance(constraints, list) else [constraints]
                dataset_policy_constraints += constraints

        expected_files = set([fn for fn in [get_filename_from_constraint(c) for c in dataset_policy_constraints] if fn is not None])
        if dataset_policy_id is not None and dataset_policy_id not in retrieved_policies.keys():
            print(f"Retrieving files for policy {dataset_policy_id}")
            if expected_files:
                os.makedirs(f"{POLICY_ROOT_FOLDER}/{dataset_policy_id}", exist_ok=True)

                files_res = requests.get(f"{POLICY_ISSUER}/policy/{dataset_policy_id}")
                if files_res.ok:
                    files = [
                        {
                            "id": f["id"],
                            "name": f["fileName"]
                        }
                        for f in files_res.json()
                    ]

                    try:
                        assert \
                            arrays_equal(sorted(expected_files), sorted([f["name"] for f in files])), \
                            f"Expected and retrieved files list are not identical for policy {dataset_policy_id}:\n" \
                            f"  Expected: {sorted(expected_files)}\n" \
                            f"  Found: {sorted([f['name'] for f in files])}" \

                    except AssertionError as e:
                        if not args.strict:
                            print(f"{str(e)}. Expected")
                            print(str(e))
                        else:
                            raise e
                    uploaded_files = {dataset_policy_id: []}
                    for file in files:
                        res = requests.get(f"{POLICY_ISSUER}/download/{file['id']}")
                        # Building a stream to send to s3 storage
                        file_stream = io.BytesIO(res.content)
                        s3_res = client.put_object(Bucket=BUCKET_NAME, Body=file_stream, Key=f"/policy_files/{dataset_policy_id}/{file['name']}")
                        if s3_res.get("ResponseMetadata", {}).get("HTTPStatusCode") == 200:
                            uploaded_files[dataset_policy_id].append(file['name'])
                            print(f"File {file['name']} successfully uploaded")
                        else:
                            print(f"File {file['name']} failed to upload successfully")

                    retrieved_policies.update(uploaded_files)
                else:
                    print(f"Failed to retrieve files list: {files_res.status_code}")
                    print(f"Used request: {POLICY_ISSUER}/policy/{dataset_policy_id}")

    with open("files_per_policy.json", "w") as f:
        json.dump(retrieved_policies, f)


if __name__ == "__main__":
    main()
    sys.exit(0)
