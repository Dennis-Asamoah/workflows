FROM repomanager.lcsb.uni.lu:9999/python:3.9

RUN pip install pandas matplotlib

WORKDIR /app
COPY stats_visualizer.py .
COPY condition_labels.csv .