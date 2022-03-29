# <a name="execute-wf"></a>Execute workflow through Galaxy

To execute the workflow through Galaxy, please follow the next steps:

## <a name="galaxy"></a>Access to INB's Galaxy server

Go to the [INB's Galaxy server](https://biobb.usegalaxy.es/), click to the **Login or Register** button and then the **Workflows** button. 

## <a name="workflows"></a>Upload workflow

In the **Workflows** section, click the **Import** button and upload the **.ga** file provided in this repository.

## <a name="data"></a>Upload data

For this workflow is mandatory to **upload additional data** as well. Please upload the **input.pdb file** and all the content of the **ABCix_config_files** folder to Galaxy. 

## <a name="execute"></a>Execute workflow

Once the Workflow has been created, go back to the **Workflows** section, select it and click the **Run Workflow** button.

Before running it, please provide the **additional data**:

* The **input.pdb** file is the _input PDB file_ for the first step (**LeapGenTop**).

* The **ABCix_config_files/stepX.in** files are the _input MDIN,IN,TXT file_ for each of the **SanderMdRun StepX** blocks.

* The **ABCix_config_files/md.in** file is the _input MDIN,IN,TXT file_ for the **SanderMdRun Free** block.