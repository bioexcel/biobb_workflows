# Base docker with miniconda
FROM continuumio/miniconda3

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
        mkdir -p /data/wf_notebook; \
        if [ -n \"$USER_JN\" ]; then \
            cp /data/\"$USER_JN\" /data/wf_notebook/notebook.ipynb; \
        else \
            cp /app/notebook.ipynb /data/wf_notebook/notebook.ipynb; \
        fi; \
\t\tcp -r /data/ABCix_config_files /data/wf_notebook/ABCix_config_files; 
        cd /data/wf_notebook; \
        source activate $REPOSITORY; \
        jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password=''; \
    fi \
"]