import uuid

import boto3
import json
import os
import numpy as np
import pandas as pd
import shutil

from abc import abstractmethod, ABC
from argparse import ArgumentParser
from ftplib import FTP
from urllib.parse import urlparse


NODE_MAPS = {
    "http://tesk-api-node-1:8080/ga4gh/tes/": "site-1",
    "http://tesk-api-node-2:8080/ga4gh/tes/": "site-2",
}

class Downloader(ABC):
    subclasses = {}
    _SCHEME = ""

    def __init_subclass__(cls, **kwargs):
        super().__init_subclass__(**kwargs)
        cls.subclasses[cls._SCHEME] = cls

    @classmethod
    def from_url(cls, data_location: str):
        scheme, *_ = urlparse(data_location)
        if not scheme:
            scheme = FileDownloader._SCHEME
        if scheme not in cls.subclasses:
            raise ValueError(f"Bad data location: {scheme} is not a supported scheme")
        return cls.subclasses[scheme](data_location)

    def __init__(self, data_location: str):
        self.source = data_location
        self.filename = data_location.split("/")[-1]

    @abstractmethod
    def download(self, destination_folder: str):
        pass

    def check_download(self, destination_folder: str):
        if not os.path.exists(destination_folder.rstrip("/") + "/" + self.filename):
            raise IOError(f"Failed to download {self.source}. {self.filename} not found at destination {destination_folder}")


class FTPDownloader(Downloader):
    _SCHEME = "ftp"

    def __init__(self, data_location: str):
        self.url = os.environ.get("FTP_HOST")
        self.usr = os.environ.get("FTP_USR")
        self.pwd = os.environ.get("FTP_PWD")

        if self.url is None or self.usr is None or self.pwd is None:
            raise ValueError("Cannot instantiate ftp handler without host or credentials")
        super().__init__(data_location)

    def _connect(self):
        ftp = FTP(host=self.url)
        ftp.login(self.usr, self.pwd)
        return ftp

    def download(self, destination_folder):
        ftp = self._connect()

        if self.source.startswith(f"ftp://{self.url}"):
            offset = len(f"ftp://{self.url}")
            source = self.source[offset:]
        else:
            source = self.source


        print(f"Downloading {source}")
        with open(destination_folder.rstrip("/") + "/" + source, "wb") as fh:
            ftp.retrbinary(f"RETR {source}", fh.write)

        self.check_download(destination_folder)


class S3Downloader(Downloader):
    _SCHEME = "s3"

    def __init__(self, data_location: str):
        self.session = boto3.session.Session(profile_name="data")
        parsed_url = urlparse(data_location)
        self.bucket = parsed_url.netloc
        self.object_key = parsed_url.path[1:]

        super().__init__(data_location)

    def download(self, destination_folder):
        client = self.session.client("s3")
        with open(destination_folder.rstrip("/") + f"/{self.filename}", "wb") as file:
            object_bytes = client.get_object(Bucket=self.bucket, Key=self.object_key)
            file.write(object_bytes)

        self.check_download(destination_folder)


class FileDownloader(Downloader):
    _SCHEME = "file"

    def download(self, destination_folder):
        # Copy the file to the destination folder
        shutil.copy2(self.source, f"{destination_folder.rstrip('/')}/{self.filename}")
        self.check_download(destination_folder)


class ConditionDataset:
    def __init__(self, data_location: str, node_name: str):
        print(f"Building dataset from {data_location}")
        dest_dir = "/tmp/data/"
        if not os.path.exists(dest_dir):
            os.mkdir(dest_dir)
        filename = data_location.split("/")[-1]

        downloader = Downloader.from_url(data_location)
        downloader.download(dest_dir)

        columns = ["condition_era_id", "condition_concept_id", "condition_era_start_date", "condition_era_end_date"]

        def td_to_float(td):
            days = td.days
            hours_dec = td.components.hours / 24.0
            minutes_dec = td.components.minutes / 60 / 24
            seconds_dec = td.components.seconds / 60 / 60 / 24
            return np.round(days + hours_dec + minutes_dec + seconds_dec, 2)

        csv_loader = pd.read_csv(
            dest_dir + filename,
            usecols=columns,
            parse_dates=["condition_era_start_date", "condition_era_end_date"],
            chunksize=1024,
            dtype={
                "condition_era_id": np.uint32,
                "condition_concept_id": np.uint32,
            },
        )
        src = pd.DataFrame(
            {x: [] for x in ["condition_era_id", "condition_concept_id", "condition_era_duration"]},
        )
        src.condition_era_id = pd.to_numeric(src.condition_era_id, downcast="unsigned")
        src.condition_concept_id = pd.to_numeric(src.condition_concept_id, downcast="unsigned")

        features = set()
        self.length = 0

        print("Loading dataset: ", end="")

        for chunk in csv_loader:
            self.length += len(chunk)
            chunk["condition_era_duration"] = [
                td_to_float(x - y)
                for x, y in zip(chunk.condition_era_end_date, chunk.condition_era_start_date)
            ]
            chunk.drop(columns=["condition_era_start_date", "condition_era_end_date"], inplace=True)
            features.update(chunk.condition_concept_id.unique())

            src = pd.concat([src, chunk])
            print(".", end="")
        print()

        self.data = src
        self.features = self.data.condition_concept_id.unique().tolist()

        grouped = self.data.groupby("condition_concept_id").condition_era_duration

        self.stats = {
            "name": NODE_MAPS.get(node_name, node_name),
            "count": grouped.count(),
            "sum": grouped.sum(),
            "mean": grouped.mean(),
            "max": grouped.max(),
            "min": grouped.min(),
            "stddev": grouped.std(),
        }
        print("Statistics pre-calculated")

    def __len__(self):
        return self.length

    def to_dict(self):
        return {
            x: y.to_dict() if not isinstance(y, str) else y
            for x, y in self.stats.items()
        }


def main():
    parser = ArgumentParser()
    parser.add_argument(
        "-i", "--infile", required=True
    )
    parser.add_argument(
        "--location", type=str, required=False, default=str(uuid.uuid4())
    )
    args = parser.parse_args()
    data = ConditionDataset(args.infile, args.location)

    print("Writing statistics")
    with open("image_statistics.json", "w") as fh:
        json.dump(data.to_dict(), fh)
    print("Done")
    return 0


if __name__ == "__main__":
    exit(main())
