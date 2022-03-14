# <a name="execute-wf"></a>Execute workflow through python script

To execute the workflow through a python script, please follow the next steps:

## <a name="files"></a>Workflow files

Below you can find the list of all the needed **files** for executing this workflow:

* **workflow.py:** the python file with all the steps to execute this workflow.
* **workflow.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.
* **workflow.env.yml:** the environment file needed for create a conda environment where this workflow will be run.

## <a name="requirements"></a>Requirements

For executing a BioBB workflow in python, there is a single requirement: to have [Anaconda](https://docs.anaconda.com/anaconda/install/index.html) installed in your computer. Once this requirement is fullfilled, you will be able to install the workflow.

The BioBB's are fully compatible with **Linux** and **macOS**. For running them on **Windows 10**, you should do it through the Windows Subsystem for Linux. In the BioBB official website, [there is a tutorial](https://mmb.irbbarcelona.org/biobb/availability/tutorials/windows) explaining how to do it.

## <a name="installation"></a>Installation

After downloading the workflow files and decompressing them in a folder, please go to this directory, open it in terminal and execute the following script:

    conda env create --file workflow.env.yml

This process can take a while, and once it is finished you will have an environment with **all the dependencies** needed for running this workflow. For activate this environment, please follow the instructions given by the conda installator. Just before finishing the installation, the terminal will prompt the following message:

```shell
#
# To activate this environment, use
#
#     $ conda activate name_of_environment
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

So execute the following script (changing name_of_environment by the name shown in your terminal):

    conda activate name_of_environment

## <a name="custom-paths"></a>Custom paths

To run this workflow properly in your computer, you should open in a text/code editor the **workflow.yml** file and replace all the occurrences of **/path/to/inputs/** with the absolute path to the folder where you have decompressed the zip file downloaded in the first step.

## <a name="run-wf"></a>Run workflow

After that, the only thing left is to run the workflow:

    python workflow.py --config workflow.yml

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**. The workflow progress will be shown in your terminal.

## <a name="get-output"></a>Get output results

Once the workflow is finished, you just should enter the new **wf_name_of_workflow** folder and, inside it, you will find a folder for each step of the workflow with all the files generated in every step.
