FROM repomanager.lcsb.uni.lu:9999/python:3.9
LABEL authors="francois.ancien"

RUN pip install --no-cache requests
WORKDIR /
COPY aggregate-remote.py /aggregate-remote.py
COPY aggregate-remote.sh /usr/local/bin/aggregate_remote

RUN chmod +x /usr/local/bin/aggregate_remote

ENTRYPOINT ["/bin/bash"]