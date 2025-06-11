FROM repomanager.lcsb.uni.lu:9999/python:3.9

WORKDIR /app

RUN python3 -m pip install requests boto3 python-slugify==8.0.4 --no-cache-dir

COPY get-assets-metadata.py .
COPY post-assets-metadata.py .
COPY post-dar-metadata.py .
COPY get-assets-policies.py .
COPY update-dcat.py .
COPY send-dar-info.py .