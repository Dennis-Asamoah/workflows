#!/usr/bin/env python3
import sys
import os
import pandas
import boto3
from tempfile import NamedTemporaryFile

def download_csv(file_path):
    with open(file_path) as f:
        s3_location = f.read().rstrip()
    bucket_name, *subpath = s3_location.split("/")
    subpath = "/".join(subpath)

    session = boto3.session.Session(profile_name="read-data-upload")
    client = session.client("s3")
    s3_object = client.get_object(Bucket=bucket_name, Key=subpath)
    data_stream = s3_object["Body"]
    with NamedTemporaryFile(mode="wb", delete=False, suffix=".csv") as fh:
        fh.write(data_stream.read())
        return fh.name


def clean_csv_header(input_file, output_file):
    # Read the entire file to count the total number of lines
    with open(input_file, 'r') as file:
        lines = file.readlines()

    # Extract the header (second line) and clean it by removing type annotations
    header_line = lines[1].rstrip()
    clean_header = [col.split(':')[0] for col in header_line.split(",")]

    # Calculate the total number of rows, excluding the last line
    total_lines = len(lines)
    valid_rows = total_lines - 1

    # Read the CSV, skip the first two rows (condition_era and header), and stop before the last row
    df = pandas.read_csv(input_file, skiprows=2, header=None, nrows=valid_rows - 2)  # Substract 2 for the skipped lines

    # Assign the cleaned headers to the DataFrame
    df.columns = clean_header

    # Save the cleaned DataFrame to the output file
    df.to_csv(output_file, index=False)


if __name__ == "__main__":
    file_location = sys.argv[1]
    output_file = sys.argv[2]
    input_file = download_csv(file_location)
    try:
        clean_csv_header(input_file, output_file)
    finally:
        os.remove(input_file)
