# <a name="execute-wf"></a>Execute workflow through python script

To execute the workflow through a python script, please follow the next steps:

## <a name="files"></a>Workflow files

Below you can find the list of all the needed **files** for executing this workflow:

* **workflow.py:** the python file with all the steps to execute this workflow.
* **workflow.yml:** the configuration file with the I/O dependencies and settings for each step of the workflow.
* **workflow.env.yml:** the environment file needed for create a conda environment where this workflow will be run.
* **inputs:** the inputs vary depending on the workflow, all the needed files are available in this same repository, just be sure to have them in the same folder where **workflow.yml** is.

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
#     $ conda activate biobb_wf_protein_md_analysis
#
# To deactivate an active environment, use
#
#     $ conda deactivate
```

So execute the following script:

    conda activate biobb_wf_protein_md_analysis

## <a name="run-wf"></a>Run workflow

After that, the only thing left is to run the workflow:

    python workflow.py --config workflow.yml

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**. The workflow progress will be shown in your terminal.

## <a name="get-output"></a>Get output results

Once the workflow is finished, you just should enter the new **wf_python/biobb_wf_protein_md_analysis** folder and, inside it, you will find a folder for each step of the workflow with all the files generated in every step.

## <a name="tests"></a>Tests

To run the tests for this workflow, the **pytest framework** must be installed into the environment described in the [**Installation**](#installation) section:

    conda install conda-forge::pytest

Once the pytest framework is installed, please go to the [**python tests folder**](tests/python) and execute:

    pytest biobb_wf_protein_md_analysis.py --config ../../python/workflow.yml --remove

To disable the output capturing and show all the logs for each step, please add the **-s** flag:

    pytest -s biobb_wf_protein_md_analysis.py --config ../../python/workflow.yml --remove

If you want to preserve all the temporary files generated during the tests, just remove the **--remove** flag:

    pytest biobb_wf_protein_md_analysis.py --config ../../python/workflow.yml
