import json

from argparse import ArgumentParser


URL_PREFIX = "https://iderha-test-central-node.org/storage/download/mdc-storage/policy_files"

def get_policy_id(url):
    return url.split('/')[-2]


def listify(inp):
    if isinstance(inp, list):
        return inp
    else:
        return [inp]


def main():
    parser = ArgumentParser()
    parser.add_argument("-i", "--input", help="Datacatalog metadata (DCAT) where the policy files were first defined")
    parser.add_argument("-l", "--location", help="Json file mapping each policy id with a list of file names")
    parser.add_argument("--host", help="Url of the node hosting the TES")

    args = parser.parse_args()

    with open(args.input) as f:
        dcat = json.load(f)

    with open(args.location) as f:
        files_mapping = json.load(f)

    if "dcat:service" in dcat:
        assert "dcat:identifier" not in dcat["dcat:service"], "Catalog service should not have a location identifier defined"
        dcat["dcat:service"]["dcat:identifier"] = args.host

    for dataset in listify(dcat["dcat:dataset"]):
        print(f"Processing locations of policy files for dataset {dataset['@id']}")
        dataset_policy_id = dataset.get("policyId")
        dataset_policy_obligation = dataset.get("odrl:hasPolicy", {}).get("odrl:obligation", {})
        if dataset_policy_obligation:
            dataset_policy_constraints = dataset_policy_obligation.get("odrl:constraint", [])

            dataset_policy_constraints = dataset_policy_constraints if isinstance(dataset_policy_constraints, list) else [dataset_policy_constraints]

            for i, constraint in enumerate(dataset_policy_constraints):
                if constraint["odrl:leftOperand"]["@id"] == "fileName" and constraint["odrl:operator"]["@id"] in ["odrl:eq", "eq"]:
                    files_list = files_mapping.get(dataset_policy_id, [])
                    if constraint["odrl:rightOperand"] in files_list:
                        dataset_policy_constraints[i] = {
                            "and": [
                                constraint,
                                {
                                    "odrl:leftOperand": {
                                        "@id": "virtualLocation"
                                    },
                                    "odrl:operator": {
                                        "@id": "odrl:eq"
                                    },
                                    "odrl:rightOperand": f"{URL_PREFIX}/{dataset_policy_id}/{constraint['odrl:rightOperand']}"
                                }
                            ]
                        }
            if dataset_policy_constraints:
                dataset["odrl:hasPolicy"]["odrl:obligation"]["odrl:constraint"] = dataset_policy_constraints
    with open("new-dcat.json", "w") as f:
        json.dump(dcat, f)


if __name__ == "__main__":
    main()
    exit(0)