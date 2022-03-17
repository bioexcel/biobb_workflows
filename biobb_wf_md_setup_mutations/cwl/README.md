# <a name="execute-wf"></a>Execute workflow through CWL script

To execute the workflow through a CWL script, please follow the next steps:

## <a name="files"></a>Workflow files

Below you can find the list of all the needed **files** for executing this workflow:

* **workflow.cwl:** the CWL file with all the common steps to execute this workflow.
* **workflow_input_descriptions.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.
* **workflow_list.cwl:** the CWL file with all the steps to execute each mutation for this workflow.
* **workflow_gather.cwl:** the CWL file with code needed to wrap up the outcome of this workflow.

## <a name="requirements"></a>Requirements

For executing a BioBB workflow in CWL, you should have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [cwltool](https://github.com/common-workflow-language/cwltool#install) and [docker](https://docs.docker.com/engine/install/) installed in your computer.

The [**biobb_adapters**](https://github.com/bioexcel/biobb_adapters) must be installed in your computer as well. Biobb_adapters is the Biobb module collection to use the building blocks with several workflow managers, **CWL** amongst them. Install biobb_adapters is very easy, just execute the following script somewhere in your computer:

    git clone git@github.com:bioexcel/biobb_adapters.git

## <a name="custom-paths"></a>Custom paths

To run this workflow properly in your computer, you should open in a text/code editor the **workflow.cwl** file and replace all the occurrences of **/path/to/** with the absolute path to the folder where you have installed the **biobb_adapters**.

## <a name="run-wf"></a>Run workflow

After that, the only thing left is to run the workflow:

    cwltool workflow.cwl workflow_input_descriptions.yml

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**. The workflow progress will be shown in your terminal.

## <a name="get-output"></a>Get output results

Once the workflow is finished, you will have all the files generated in every step in the same folder.
