#!/usr/bin/env python3.9

import argparse
import json
import sys


def main(args=None):
    if args is None:
        args = sys.argv[1:]

    parser = argparse.ArgumentParser()
    parser.add_argument("infiles", metavar="Input", type=str, nargs="+", help="PATH to an input file")

    args = parser.parse_args(args)

    total_sum = 0.0
    total_count = 0.0
    for file_path in args.infiles:
        with open(file_path, "r") as f:
            data = json.load(f)
            total_sum += data["sum"]
            total_count += data["count"]

    with open("avg-ages.json", "w") as f:
        json.dump({"avg": total_sum / total_count}, f)


if __name__ == "__main__":
    sys.exit(main())
