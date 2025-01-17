# BioExcel Building Blocks Workflows

Welcome to the global repository for all the **BioExcel Building Blocks Workflows**. In this repository, there are all the versions for each workflow manager:

* Common Workflow Language (CWL)
* Galaxy
* Jupyter Notebooks
* Pure Python
* Docker

## Installation

Please note that all the Jupyter Notebook versions are loaded as submodules as all of them have their own repository, so the process of cloning this project is slightly different than the common one:

```console
git clone --recursive https://github.com/bioexcel/biobb_workflows.git
cd biobb_workflows
git submodule update --init --recursive
```

After cloning, to update to the latest Jupyter Notebook release, just execute:

```console
git submodule update --remote
```

## Copyright & Licensing
This software has been developed in the [MMB group](http://mmb.irbbarcelona.org) at the [BSC](http://www.bsc.es/) & [IRB](https://www.irbbarcelona.org/) for the [European BioExcel](http://bioexcel.eu/), funded by the European Commission (EU H2020 [823830](http://cordis.europa.eu/projects/823830), EU H2020 [675728](http://cordis.europa.eu/projects/675728)).

* (c) 2015-2025 [Barcelona Supercomputing Center](https://www.bsc.es/)
* (c) 2015-2025 [Institute for Research in Biomedicine](https://www.irbbarcelona.org/)

Licensed under the
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0), see the file LICENSE for details.

![](https://bioexcel.eu/wp-content/uploads/2019/04/Bioexcell_logo_1080px_transp.png "Bioexcel")
