# <a name="execute-wf"></a>Execute workflow through docker container

To execute the workflow through a docker container, please follow the next steps:

## <a name="files"></a>Workflow files

Below you can find the list of all the needed **files** for executing this workflow:

* **Dockerfile:** the file used for building a docker container with this workflow inside.
* **workflow.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.

## <a name="requirements"></a>Requirements

For executing this BioBB workflow, there is a single requirement: to have [Docker](https://docs.docker.com/engine/install/) installed in your computer. Once this requirement is fullfilled, you will be able to install the workflow.

## <a name="installation"></a>Installation

After downloading the workflow files and decompressing them in a folder, please go to this directory, open it in terminal and execute the following script:

    docker build -t <container_image> .

Where **container_image** will be the name of the docker container image.

Note: if using an **ARM** architecture such as the **Apple Silicon chips**, please be sure of adding the **--platform** flag:

    docker build --platform linux/amd64 -t <container_image> .

## <a name="run-wf"></a>Run workflow

After that, the only thing left is to run the workflow:

    docker run -w /data -v /path/to/inputs:/data <container_image>

Where **/path/to/inputs** is the path to the folder where the input(s) and workflow.yml files are located (all of them must be in the same folder); and **container_image** is the name of the docker container image

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**. The workflow progress will be shown in your terminal.

## <a name="get-output"></a>Get output results

Once the workflow is finished, you just should enter the new **wf_name_of_workflow** folder and, inside it, you will find a folder for each step of the workflow with all the files generated in every step.
