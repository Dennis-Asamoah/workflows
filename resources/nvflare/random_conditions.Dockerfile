FROM repomanager.lcsb.uni.lu:9999/python:3.9
LABEL authors="francois.ancien"

WORKDIR /workspace

ADD create_random_conditions.py /workspace
ADD labels.csv /workspace

RUN chgrp -R root /workspace && \
    chmod -R g=u /workspace

