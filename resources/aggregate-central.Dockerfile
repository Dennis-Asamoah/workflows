FROM repomanager.lcsb.uni.lu:9999/python:3.9
LABEL authors="francois.ancien"

WORKDIR /
COPY aggregate-central.py /aggregate-central.py
COPY aggregate-central.sh /usr/local/bin/aggregate_central

RUN chmod +x /usr/local/bin/aggregate_central

ENTRYPOINT ["/usr/bin/bash"]

