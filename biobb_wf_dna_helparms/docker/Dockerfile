# Base docker with miniconda
FROM continuumio/miniconda3

# Define working dir
WORKDIR /app

# Define a directory for the volume
VOLUME /data

# Clone repo
RUN wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/biobb_wf_dna_helparms/python/workflow.env.yml -O /app/workflow.env.yml && \
    wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/biobb_wf_dna_helparms/python/workflow.py -O /app/workflow.py

# Create new environment
RUN conda env create -f /app/workflow.env.yml

# TODO COPY .curvesplus FOLDER????

# Make RUN commands use the new environment:
SHELL ["conda", "run", "-n", "wf_dna_helparms", "/bin/bash", "-c"]

# Code to run when container is started
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "wf_dna_helparms", "python", "/app/workflow.py", "--config", "/data/workflow.yml"]