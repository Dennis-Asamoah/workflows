#!/usr/bin/env python

import argparse
import json
from ftplib import FTP
import sys


def main(args=None):
    if args is None:
        args = sys.argv[1:]
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", help="PATH to input file")

    parsed = parser.parse_args(args)

    data = None
    with open(parsed.input, "r") as f:
        lines = f.readlines()
        ftp_path = lines[0]

    # Getting data from ftp source
    ftp_host = "10.240.6.96"
    ftp = FTP(ftp_host)
    ftp.login(user="ftp_iderha_user", passwd="ftp_iderha_pass")
    tmp_path = "tmp_data.json"
    with open(tmp_path, "wb") as fh:
        ftp.retrbinary(f"RETR {ftp_path}", fh.write)

    # Extracting data from json
    with open(tmp_path, "rb") as f:
        try:
            data = json.load(f)
        except json.JSONDecodeError as e:
            raise json.JSONDecodeError(f"Impossible to parse data in {tmp_path}. Not a valid json.") from e

    # Calculating avg username lengths
    sum_usrname = 0
    for row in data:
        try:
            sum_usrname += len(row["username"])
        except (AttributeError, KeyError):
            continue

    count_rows = len(data)

    # Saving
    with open("aggregated-ages.json", "w") as f:
        json.dump({"sum": sum_usrname, "count": count_rows}, f)


if __name__ == "__main__":
    sys.exit(main())
