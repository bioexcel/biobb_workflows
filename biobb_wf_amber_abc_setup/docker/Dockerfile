# Base docker with miniconda
FROM continuumio/miniconda3

# Define the version of the Docker image
LABEL version="2025.1"

# Connect this docker image to the biobb_workflows repository
LABEL org.opencontainers.image.source https://github.com/bioexcel/biobb_workflows

# Define working dir
WORKDIR /app

# Define a directory for the volume
VOLUME /data

# Define REPO & SUBREPO variables
ARG REPO
ARG SUBREPO

# Check if REPO variable is set
RUN if [ -z "$REPO" ]; then echo "REPO variable is not set. Cancelling build." && exit 1; fi

# Define REPOSITORY & SUBREPOSITORY environment variables
ENV REPOSITORY=$REPO
ENV SUBREPOSITORY=$SUBREPO

# Download the conda environment file (from the jupyter repo $REPO)
RUN wget https://raw.githubusercontent.com/bioexcel/$REPOSITORY/main/conda_env/environment.yml -O /app/workflow.env.yml

# Download the jupyter notebook file (the url varies depending on if the subrepository is set or not) and the pure python workflow file (from biobb_workflows)
RUN if [ -z "$SUBREPOSITORY" ]; then \
    wget https://raw.githubusercontent.com/bioexcel/$REPOSITORY/main/$REPOSITORY/notebooks/$REPOSITORY.ipynb -O /app/notebook.ipynb; \
    wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/$REPOSITORY/python/workflow.py -O /app/workflow.py; \
else \
    wget https://raw.githubusercontent.com/bioexcel/$REPOSITORY/main/$REPOSITORY/notebooks/$SUBREPOSITORY/${REPOSITORY}_$SUBREPOSITORY.ipynb -O /app/notebook.ipynb; \
    wget https://raw.githubusercontent.com/bioexcel/biobb_workflows/main/${REPOSITORY}_$SUBREPOSITORY/python/workflow.py -O /app/workflow.py; \
fi

# Enable libmamba as solver
RUN conda config --set solver libmamba

# Create new environment
RUN conda env create -f /app/workflow.env.yml

# Define an environment variable with default value
ENV MODE=python

# Define environment variables for the user custom python script and jupyter notebook
ENV USER_PY=
ENV USER_JN=

# Define the base URL for the Jupyter notebook server as an environment variable
ENV BASE_URL=/

# Expose the port for the Jupyter notebook server
EXPOSE 8888

# Set the entrypoint script as the entrypoint for the Docker image
ENTRYPOINT ["/bin/bash", "-c"]

# Run either the python script or the jupyter notebook depending on the MODE environment variable
CMD ["\
    if [ \"$MODE\" = \"python\" ]; then \
        if [ -n \"$USER_PY\" ]; then \
            cp /data/\"$USER_PY\" /app/workflow.py; \
        fi; \
        mkdir -p /data/wf_python; \
        cd /data/wf_python; \
        conda run --no-capture-output -n $REPOSITORY python /app/workflow.py --config /data/workflow.yml; \
    else \
        base_dir=/data/wf_notebook; \
        dir=\"$base_dir\"; \
        counter=1; \
        while [ -d \"$dir\" ]; do \
            dir=\"${base_dir}_$counter\"; \
            counter=$((counter + 1)); \
        done; \
        mkdir -p \"$dir\"; \
        if [ -n \"$USER_JN\" ]; then \
            cp /data/\"$USER_JN\" \"$dir/notebook.ipynb\"; \
        else \
            cp /app/notebook.ipynb \"$dir/notebook.ipynb\"; \
        fi; \
        cp -r /data/ABCix_config_files \"$dir/ABCix_config_files\"; \
        cd \"$dir\"; \
        source activate $REPOSITORY; \
        jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.base_url=$BASE_URL --NotebookApp.token='' --NotebookApp.password=''; \
    fi \
"]