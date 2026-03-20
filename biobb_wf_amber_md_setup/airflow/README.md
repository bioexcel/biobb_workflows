# <a name="execute-wf"></a>Execute workflow through Apache Airflow

<div align="center"><img src="../../common/images/airflow.png" height="120" /></div>

Below can be found the instructions for running the **BioBB workflow** in Apache Airflow through **cwltool**. To install and execute the workflow, please follow the next steps:

## <a name="files"></a>Files

### <a name="wf-files"></a>Workflow files

Below you can find the list of all the needed **files** for executing this workflow:

* **biobb_wf_amber_md_setup.py:** the **python DAG** file with all the steps to execute this workflow.
* **inputs/:** the inputs folder contains the **input description** files (inputs, outputs and properties) for **each step** of the workflow. The **input files** for the workflow are in this folder as well.
* **biobb_adapters/:** folder with the **CWL adapters** for each step of the workflow.

Both folders and the python file must be located into a **biobb_wf_amber_md_setup folder** where the other **Apache Airflow Dags** are located (usually the **dags/** folder).

### <a name="utils"></a>Utils

* [**airflow_cwl_utils.py**](../../common/airflow/dags/airflow_cwl_utils.py): This file **generates the bash command** that will be executed for each step of the dag. It must be located into the main **dags/** folder, at the same level of the **biobb_wf_amber_md_setup folder** created in the step before.

### <a name="plugins"></a>Plugins

* [**cwl_run.sh**](../../common/airflow/plugins/cwl_run.sh): This file **wraps the cwltool** instruction with all the executions needed for running CWL in Apache Airflow. It must be located into the **plugins/** folder.

* [**docker_wrapper.sh**](../../common/airflow/plugins/docker_wrapper.sh): This file is needed when executing a docker instance of Apache Airflow and it **maps the paths** of the folders. It must be located into the **plugins/** folder.

## <a name="requirements-c"></a>Requirements

For executing a **BioBB workflow** in Apache Airflow through **cwltool**, [cwltool](https://github.com/common-workflow-language/cwltool#install) and [docker](https://docs.docker.com/engine/install/) must be installed in the Apache Airflow instance.

## <a name="run-wf"></a>Run workflow

### <a name="run-wf-c"></a>Run workflow via command line

Below you can find the instructions for executing the workflow **via command line** in an Apache Airflow implementation in **docker**. For other implementations the command lines may vary.

1) Get the docker-airflow-worker container ID:

        docker ps -aqf "name=worker"

2) Launch the workflow:

        docker exec [CONTAINER ID] airflow dags trigger biobb_wf_amber_md_setup

    Get the **dag_run_id** given after launching the workflow if you need monitoring the workflow status. The format is **manual__** followed by the timestamp (ie manual__2026-02-27T08:38:49.075884+00:00)

3) Monitor workflow status:

        docker exec [CONTAINER ID] airflow tasks states-for-dag-run biobb_wf_amber_md_setup [dag_run_id]

### <a name="run-wf-i"></a>Run workflow via GUI

Go to **Dags list** in the main menu. Search for the **biobb_wf_amber_md_setup dag**, click it and, once inside the dag, click on **Execute button** at the top right.

## <a name="time"></a>Time of execution

Take into account that depending on the number of steps, the tools executed and the settings provided, along with the power of your computer, the execution of the workflow can take from a **few minutes** to **several hours**.

## <a name="get-output"></a>Get output results

Once the workflow is finished, you just should enter the new **dags/biobb_wf_amber_md_setup/outputs/** folder and, inside it, you will find a folder for each step of the workflow with all the files generated in every step.