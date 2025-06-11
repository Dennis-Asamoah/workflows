import sys
import hashlib
import json
import requests

from datetime import datetime, timezone
from slugify import slugify
from urllib.parse import urlparse

MDC_SERVICE_NAME = "metadata-catalog-emx2"
MDC_URI = f"http://{MDC_SERVICE_NAME}:8080/iderha/api/Dataset/Dataset"
DRS_NAME = "drs-filer"
DRS_URI = f"http://{DRS_NAME}:8080/ga4gh/drs/v1"
DATASET_LIST_FIELD = "dcat:dataset"
SERVICE_FIELD = "dcat:service"
CATALOG_TIMESTAMP = 1726487040000  # 16 Sep 2024 - 11:44:00 UTC


def listify(obj):
    if obj is None:
        raise ValueError("Trying to listify None")
    elif isinstance(obj, list):
        return obj
    return [obj]


def dcat2drs(dcat, dcat_service):
    def get_size(dataset):
        obj_size = dataset["metadata"]["dataset"].get("dcat:distribution", {}).get("dcat:byteSize")
        return obj_size if isinstance(obj_size, int) else 0

    def get_time(timestamp):
        if timestamp is None or not isinstance(timestamp, int):
            raise ValueError("No timestamp provided, impossible to translate into a datetime")

        else:
            dt = datetime.fromtimestamp(timestamp/1000.0, tz=timezone.utc)
            return dt.isoformat()

    def get_checksum(dataset):
        return hashlib.md5(json.dumps(dataset["metadata"]).encode()).hexdigest()

    if DATASET_LIST_FIELD in dcat:
        # DCAT of a catalog, we will send a bundle
        datasets = listify(dcat[DATASET_LIST_FIELD])
        service_id = dcat_service["dcat:identifier"]
        node_uri = urlparse(service_id)
        node_uri = node_uri.netloc.split(":")[0] if node_uri.netloc else node_uri.path

        size = sum([get_size(dataset) for dataset in datasets])
        content_checksums = [
            get_checksum(dataset)
            for dataset in datasets
        ]
        return {
            "id": hashlib.md5(str(service_id).encode()).hexdigest(),
            "name": slugify(f"EDC Catalog - {node_uri}"),
            "size": size,
            "created_time": get_time(CATALOG_TIMESTAMP),  # FIXME: This should be retrieved from somewhere at some point
            "contents": [
                {
                    "name": slugify(dataset["metadata"]["dataset"]["dct:title"]),
                    "id": dataset["@id"],
                    "drs_uri": [f"drs://{DRS_NAME}/{dataset['@id']}"],
                }
                for dataset in datasets
            ],
            "checksums": [{
                "type": "md5",
                "checksum": hashlib.md5(''.join(sorted(content_checksums)).encode()).hexdigest(),
            }],
            "description": f"Bundle describing the content of edc catalog associated with "
                           f"{dcat_service['dcat:identifier']}",
            "type": "catalogue",
        }

    else:
        # DCAT of a dataset, we will send a blob
        size = get_size(dcat)
        # Timestamp should be an integer (e.g. 1739519700115)
        ts = dcat.get("createdAt")
        return {
            "name": slugify(dcat["metadata"]["dataset"]["dct:title"]),
            "created_time": get_time(ts),
            "size": size,
            "version": dcat["metadata"]["dataset"].get("dct:version", ""),
            "mime_type": "text/csv",
            "checksums": [{
                "type": "md5",
                "checksum": get_checksum(dcat),
            }],
            "execution_location": dcat_service["dcat:identifier"],
            "description": dcat["metadata"]["dataset"].get("dct:description", "No description provided"),
            "id": dcat["@id"],
            "aliases": [dcat["@id"]],
            "access_methods": [{
                "access_url": {"url": f"edc://edc-provider:19194/{dcat['@id']}"},
                "type": "file",
            }],
            "type": "dataset",
        }


def put_drs_object(drs_object, retries: int = 2):
    drs_id = drs_object.pop("id")
    for i in range(retries):
        url = f"{DRS_URI}/objects/{drs_id}?keep_contents=false"
        res = requests.put(url, json=drs_object)
        if not res.ok:
            print(f"Failed to send DRS entry - Try {i+1}: {res.text}")
        else:
            break
    else:
        raise RuntimeError(f"Impossible to send DRS entry {drs_id} to DRS")


def main(files_list):
    if not isinstance(files_list, list):
        raise ValueError("Unexpected arguments, expected a list of files")

    catalogs_list = []

    for file in files_list:
        with open(file, "r") as f:
            catalog_res = json.load(f)

        if isinstance(catalog_res, dict):
            catalog_res = [catalog_res]

        for catalog in catalog_res:
            if catalog.get(DATASET_LIST_FIELD):
                catalog[DATASET_LIST_FIELD] = listify(catalog[DATASET_LIST_FIELD])
            for blob in catalog[DATASET_LIST_FIELD]:
                drs_blob = dcat2drs(blob, catalog[SERVICE_FIELD])
                put_drs_object(drs_blob)

            drs_bundle = dcat2drs(catalog, catalog[SERVICE_FIELD])
            put_drs_object(drs_bundle)

            catalogs_list.append(catalog)

    res = requests.post(MDC_URI, json=catalogs_list, headers={"Content-Type": "application/json"})
    # Writing status code in an output file for subsequent steps to retrieve
    with open("response.txt", "w") as f:
        f.write(str(res.status_code))

    if not res.ok:
        error = f"An error occurred while pushing assets metadata: {res.content}"
        print(error)
        raise requests.exceptions.HTTPError(error)


if __name__ == "__main__":
    main(sys.argv[1:])
    print("Successfully sent request to MDC")
    exit(0)