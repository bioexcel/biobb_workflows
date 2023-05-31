# <a name="execute-wf"></a>Execute workflow through CWL script

To execute the workflow through a CWL script, please follow the next steps:

## <a name="files"></a>Workflow files

Below you can find the list of all the needed **files** for executing this workflow:

* **workflow.cwl:** the CWL file with all the steps to execute this workflow.
* **workflow_input_descriptions.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.

> **IMPORTANT!** The Concoord software doesn't work with dockers on Mac ARM, so in case you are using this type of computer, please comment the steps 4 to 7 as indicated in both **workflow.cwl** and **workflow_input_descriptions.yml** files.

## <a name="requirements"></a>Requirements

For executing a BioBB workflow in CWL, you should have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [cwltool](https://github.com/common-workflow-language/cwltool#install) and [docker](https://docs.docker.com/engine/install/) installed in your computer.

## <a name="biobb_adapters"></a>Biobb adapters

Please be sure to have the **biobb_adapters** folder at the same level where the **workflow.cwl** and **workflow_input_descriptions.yml** files are.

## <a name="run-wf"></a>Run workflow

After that, the only thing left is to run the workflow:

    cwltool workflow.cwl workflow_input_descriptions.yml

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**. The workflow progress will be shown in your terminal.

## <a name="get-output"></a>Get output results

Once the workflow is finished, you will have all the files generated in every step in the same folder.
