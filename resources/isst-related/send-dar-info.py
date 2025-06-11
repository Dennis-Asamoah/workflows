import os
import requests
from argparse import ArgumentParser

POLICY_ISSUER_URI = "http://policy-issuer:1919/dar/v1/request"

def main():
    parser = make_parser()
    args = parser.parse_args()

    dar_request = {
        "id": args.dar,
        "description": args.info,
        "tables": [
            "condition_era"
        ],
        "values": [
            "condition_era_id",
            "condition_concept_id",
            "condition_era_start_date",
            "condition_era_end_date"
        ],
        "policyDefinition": {
            "@context": {
                "@vocab": "https://w3id.org/edc/v0.0.1/ns/",
                "odrl": "http://www.w3.org/ns/odrl/2/"
            },
            "@id": args.policy,
            "policy": {
                "@type": "Set",
                "odrl:target": args.asset,
                "odrl:assignee": "Iderha Steward",
                "odrl:assigner": args.user,
                "odrl:permission": [],
                "odrl:prohibition": [],
                "odrl:obligation": [
                    {
                        "odrl:action": "use",
                        "odrl:constraint": [
                            {
                                "odrl:leftOperand": "fileName",
                                "odrl:operator": "eq",
                                "odrl:rightOperand": filename,
                            }
                            for filename in args.file
                        ]
                    }
                ]
            }
        }
    }

    res = requests.post(
        POLICY_ISSUER_URI,
        json=dar_request,
        headers={
            "Content-type": "application/json",
            "Authorization": f"Bearer {os.environ.get('USER_PASSPORT_TOKEN')}",
        }
    )

    with open("response.txt", "w") as f:
        f.write(str(res.status_code))

    if not res.ok:
        raise ValueError(res.text)
    else:
        return 0


def make_parser():
    parser = ArgumentParser()
    parser.add_argument(
        "--user", "-u", help="Id of the user requesting data",
        required=True,
    )
    parser.add_argument(
        "--dar", "-d", help="Id of Data Access Request",
        required=True,
    )
    parser.add_argument(
        "--asset", "-a", help="Id of the asset requested",
        required=True,
    )
    parser.add_argument(
        "--info", "-i", help="Additional information to add to the DAR",
        default="",
    )
    parser.add_argument(
        "--file", "-f", help="File names to add to constraints",
        action="append",
    )
    parser.add_argument(
        "--policy", "-p", help="Id of the policy to follow to get access to data",
        required=True,
    )
    return parser


if __name__ == "__main__":
    exit(main())
