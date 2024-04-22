# Base docker with miniconda
FROM continuumio/miniconda3

# Define working dir
WORKDIR /app

# Define a directory for the volume
VOLUME /data

# Clone repo
RUN wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/biobb_wf_cmip/python/workflow.env.yml -O /app/workflow.env.yml && \
    wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/biobb_wf_cmip/python/workflow.py -O /app/workflow.py

# Enable libmamba as solver
RUN conda config --set solver libmamba

# Create new environment
RUN conda env create -f /app/workflow.env.yml

# Code to run when container is started
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "cmip_env", "python", "/app/workflow.py", "--config", "/data/workflow.yml"]