# Base docker with miniconda
FROM continuumio/miniconda3

# Define working dir
WORKDIR /app

# Define a directory for the volume
VOLUME /data

# Define REPO variable
ARG REPO

# Check if REPO variable is set
RUN if [ -z "$REPO" ]; then echo "REPO variable is not set. Cancelling build." && exit 1; fi

# Define REPOSITORY environment variable
ENV REPOSITORY=$REPO

# Clone repo
RUN wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/$REPOSITORY/python/workflow.env.yml -O /app/workflow.env.yml && \
    wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/$REPOSITORY/python/workflow.py -O /app/workflow.py

# Enable libmamba as solver
RUN conda config --set solver libmamba

# Create new environment
RUN conda env create -f /app/workflow.env.yml

# Set the entrypoint script as the entrypoint for the Docker image
ENTRYPOINT ["/bin/bash", "-c"]

# Run the python script
CMD ["conda run --no-capture-output -n $REPOSITORY python /app/workflow.py --config /data/workflow.yml"]
