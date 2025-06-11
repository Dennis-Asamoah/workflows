FROM repomanager.lcsb.uni.lu:9999/python:3.9
LABEL authors="nirmeen.sallam"

RUN pip install --no-cache pandas boto3
WORKDIR /
COPY clean_header.py /clean_header.py
COPY clean_header.sh /usr/local/bin/clean_header

RUN chmod +x /usr/local/bin/clean_header

ENTRYPOINT ["/bin/bash"]
