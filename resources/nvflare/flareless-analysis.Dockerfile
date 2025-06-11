FROM repomanager.lcsb.uni.lu:9999/python:3.9
LABEL authors="francois.ancien"

WORKDIR /app

RUN python3 -m pip install boto3 numpy pandas --no-cache-dir

COPY create_random_conditions.py .
COPY flareless_analysis.py .
COPY flareless_merge.py .