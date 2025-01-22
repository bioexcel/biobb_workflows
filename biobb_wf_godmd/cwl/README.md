# <a name="execute-wf"></a>Execute workflow through CWL script

To execute the workflow through a CWL script, please follow the next steps:

## <a name="files"></a>Workflow files

Below you can find the list of all the needed **files** for executing this workflow:

* **workflow.cwl:** the CWL file with all the steps to execute this workflow.
* **workflow_input_descriptions.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.
* **inputs:** the inputs vary depending on the workflow, all the needed files are available in this same repository, just be sure to have them in the same folder where **workflow.yml** is.
* **BioBB adapters:** be sure to have the **biobb_adapters** folder at the same level where the **workflow.cwl** and **workflow_input_descriptions.yml** files are.

## <a name="run-wf"></a>Run workflow with cwltool

Instructions for executing the **CWL workflow** through **cwltool**.

### <a name="requirements-c"></a>Requirements

For executing a **BioBB workflow** in CWL through **cwltool**, you should have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [cwltool](https://github.com/common-workflow-language/cwltool#install) and [docker](https://docs.docker.com/engine/install/) installed in your computer.

### <a name="custom-paths"></a>Custom paths

To run this workflow properly in your computer, you should open in a text/code editor the **workflow.cwl** file and replace all the occurrences of **biobb_adapters/** with the absolute path to the folder where you have installed the **biobb_adapters**.

### <a name="run-wf-c"></a>Run workflow

After that, the only thing left is to run the workflow:

    cwltool workflow.cwl workflow_input_descriptions.yml

## <a name="run-wf"></a>Run workflow with docker

Instructions for executing the **CWL workflow** through **docker**.

### <a name="requirements-d"></a>Requirements

For executing a **BioBB workflow** in CWL through **docker**, you should have [docker](https://docs.docker.com/engine/install/) installed in your computer.

### <a name="amd"></a>AMD architecture

#### Install docker

    docker pull biobb/cwl_dind:amd64

#### Run container

Be sure to execute the following instructions in the **same folder** where the files described in the [**Workflow files**](#files) section are.

    docker run --privileged -d --name my_container -v /path/to/files:/workspace biobb/cwl_dind:amd64
    docker exec -w /workspace my_container cwltool --tmpdir-prefix /workspace/tmpd- workflow.cwl workflow_input_descriptions.yml

Where **/path/to/files** is the folder where the files described in the [**Workflow files**](#files) section are.

### <a name="arm"></a>ARM architecture

#### Install docker

    docker pull biobb/cwl_dind:arm64

#### Run container

Be sure to execute the following instructions in the **same folder** where the files described in the [**Workflow files**](#files) section are.

    docker run --privileged -d --name my_container -v /path/to/files:/workspace biobb/cwl_dind:arm64
    docker exec -w /workspace my_container cwltool --tmpdir-prefix /workspace/tmpd- workflow.cwl workflow_input_descriptions.yml

Where **/path/to/files** is the folder where the files described in the [**Workflow files**](#files) section are.

## <a name="time"></a>Time of execution

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**. The workflow progress will be shown in your terminal.

## <a name="get-output"></a>Get output results

Once the workflow is finished, you will have all the files generated in every step in the same folder..
