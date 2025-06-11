import json

from argparse import ArgumentParser
from pathlib import Path


def main():
    parser = ArgumentParser()
    parser.add_argument("-i", "--infile", action="append", required=True)
    parser.add_argument("-l", "--logs", action="append", required=True)
    args = parser.parse_args()

    with open("merged_logs.txt", "w") as fh:
        for logfile in args.logs:
            log_path = Path(logfile)
            fh.write(f"### {log_path.name} ###\n\n")
            fh.write(open(logfile).read())
            fh.write("\n\n")

    stats = {}
    for data_file in args.infile:
        with open(data_file) as fh:
            data = json.load(fh)

        for condition in data["count"].keys():
            if condition not in stats:
                stats[condition] = {
                    "count": {},
                    "sum": {},
                    "mean": {},
                    "max": {},
                    "min": {},
                    "stddev": {},
                }

            stats[condition]["count"][data["name"]] = {"data": data["count"][condition]}
            stats[condition]["sum"][data["name"]] = {"data": data["sum"][condition]}
            stats[condition]["mean"][data["name"]] = {"data": data["mean"][condition]}
            stats[condition]["max"][data["name"]] = {"data": data["max"][condition]}
            stats[condition]["min"][data["name"]] = {"data": data["min"][condition]}
            stats[condition]["stddev"][data["name"]] = {"data": data["stddev"][condition]}

    for condition in stats.keys():
        stats[condition]["count"]["Global"] = {"data": sum([
            stats[condition]["count"][x]["data"]
            for x in stats[condition]["count"].keys()
        ])}
        stats[condition]["mean"]["Global"] = {"data": (
                sum(
                    [
                        stats[condition]["mean"][x]["data"] * stats[condition]["count"][x]["data"]
                        for x in stats[condition]["sum"].keys()
                    ]
                )
                / stats[condition]["count"]["Global"]["data"]
        )}

        stats[condition]["sum"]["Global"] = {"data": sum([
            stats[condition]["sum"][x]["data"]
            for x in stats[condition]["sum"].keys()
        ])}
        stats[condition]["max"]["Global"] = {"data": max([
            stats[condition]["max"][x]["data"]
            for x in stats[condition]["max"].keys()
        ])}
        stats[condition]["min"]["Global"] = {"data": min([
            stats[condition]["min"][x]["data"]
            for x in stats[condition]["min"].keys()
        ])}
        stats[condition]["stddev"]["Global"] = {"data": "Unknown"}

    with open("image_statistics.json", "w") as fh:
        json.dump(stats, fh)
    return 0


if __name__ == "__main__":
    exit(main())
