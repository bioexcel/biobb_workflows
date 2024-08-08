# <a name="execute-wf"></a>Execute workflow through docker container

All the **BioBB workflows** can be executed via **docker container**. Inside this container there are all the necessary **dependencies** for executing the workflow. These workflows are available via [**docker hub**](https://hub.docker.com/), though in this repository you can find as well all the necessary files for **building** them **in house**

## <a name="requirements"></a>Requirements

For executing this **BioBB workflow**, there is a single requirement: to have [**Docker**](https://docs.docker.com/engine/install/) installed in your computer. Once this requirement is fullfilled, you will be able to install the workflow.

## <a name="download"></a>Download and execute container from docker hub

Below there are the steps to follow for downloading and running the container from [**docker hub**](https://hub.docker.com/r/biobb/biobb_wf_pmx_tutorial).

In the following link you can find all the BioBB workflows available in docker hub:

<https://hub.docker.com/u/biobb>

### <a name="pull"></a>Download container

For **downloading** the container to you computer, please type the following instruction in your **terminal**:

    docker pull biobb/biobb_wf_pmx_tutorial

### <a name="run-wf-d"></a>Run workflow

The **BioBB workflows containers** can be executed either **interactively** via **Jupyter Notebook** or **sequentially** in **python**.

#### <a name="run-jn-d"></a>Run in Jupyter Notebook

For **running** the container in Jupyter Notebook, please type the following instruction in your **terminal**:

    docker run --name <container_name> -d -e MODE=jupyter -p <port>:8888 -v /path/to/inputs:/data biobb/biobb_wf_pmx_tutorial

Where:
* **container_name** is the name of the container (optional).
* **port** is the port of your computer where the output of the container will be redirected (ie 3000).
* **/path/to/inputs** is the path to the folder where the **input(s)** and **workflow.yml** files are located (all of them must be in the same folder).

This instruction will run the container in **detached** (or background) mode, so once it's running, you should go to your **browser** and type:

<http://localhost:3000/notebooks/notebook.ipynb>

Note that **the port can change** depending on the value provided in the previous step.

#### <a name="run-py-d"></a>Run in Python

Below you can find the list of all the needed **files** for executing this workflow in **python**:

* **workflow.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.
* **inputs:** the inputs vary depending on the workflow, all the needed files are available in this same repository, just be sure to have them in the same folder where **workflow.yml** is.

For **running** the container in python, please type the following instruction in your **terminal**:

    docker run --name <container_name> -v /path/to/inputs:/data biobb/biobb_wf_pmx_tutorial

Where:
* **container_name** is the name of the container (optional).
* **/path/to/inputs** is the path to the folder where the **input(s)** and **workflow.yml** files are located (all of them must be in the same folder).

## <a name="build"></a>Build container in house

To execute the workflow through a docker container, please follow the next steps:

### <a name="installation"></a>Installation

First off, the [**Dockerfile**](Dockerfile) file found in this repository must be in the same folder where the building instruction is performed.

Please go to the folder where the [**Dockerfile**](Dockerfile) file is, open it in terminal and execute the following script:

    docker build --build-arg REPO=biobb_wf_pmx_tutorial -t <container_image> .

Where **container_image** will be the name of the docker container image.

Note: if using an **ARM** architecture such as the **Apple Silicon chips**, please be sure of adding the **--platform** flag:

    docker build --build-arg REPO=biobb_wf_pmx_tutorial --platform linux/amd64 -t <container_image> .

### <a name="run-wf-b"></a>Run workflow

The **BioBB workflows containers** can be executed either **interactively** via **Jupyter Notebook** or **sequentially** in **python**.

#### <a name="run-jn-b"></a>Run in Jupyter Notebook

For **running** the container in Jupyter Notebook, please type the following instruction in your **terminal**:

    docker run --name <container_name> -d -e MODE=jupyter -p <port>:8888 -v /path/to/inputs:/data <container_image>

Where:
* **container_name** is the name of the container (optional).
* **port** is the port of your computer where the output of the container will be redirected (ie 3000).
* **/path/to/inputs** is the path to the folder where the **input(s)** and **workflow.yml** files are located (all of them must be in the same folder).
* **container_image** is the name of the docker container image.

This instruction will run the container in **detached** (or background) mode, so once it's running, you should go to your **browser** and type:

    http://localhost:3000/notebooks/notebook.ipynb

Note that **the port can change** depending on the value provided in the previous step.

#### <a name="run-py-b"></a>Run in Python

Below you can find the list of all the needed **files** for executing this workflow in **python**:

* **workflow.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.
* **inputs:** the inputs vary depending on the workflow, all the needed files are available in this same repository, just be sure to have them in the same folder where **workflow.yml** is.

For **running** the container in python, please type the following instruction in your **terminal**:

    docker run --name <container_name> -v /path/to/inputs:/data <container_image>

Where:
* **container_name** is the name of the container (optional).
* **/path/to/inputs** is the path to the folder where the **input(s)** and **workflow.yml** files are located (all of them must be in the same folder).
* **container_image** is the name of the docker container image.

## <a name="time"></a>Time of execution

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**. The workflow progress will be shown in your terminal if you execute the workflow via python.

## <a name="output"></a>Get output results

### <a name="output-jn"></a>Jupyter Notebook

Once the workflow is finished, you just should enter the new **wf_notebook/biobb_wf_pmx_tutorial** folder and, inside it, you will find all the outputs generated by the workflow.

### <a name="output-py"></a>Python

Once the workflow is finished, you just should enter the new **wf_python/biobb_wf_pmx_tutorial** folder and, inside it, you will find a folder for each step of the workflow with all the files generated in every step.
