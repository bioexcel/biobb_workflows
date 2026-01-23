Launch workflow:

[![](https://img.shields.io/badge/Google%20Colab-Open-orange?logo=google-colab)](https://colab.research.google.com/github/bioexcel/biobb_wf_godmd/blob/main/biobb_wf_godmd/notebooks/biobb_wf_godmd.ipynb)

Download and install workflow:

[![Install - Docker](https://img.shields.io/badge/install_&_run-GHCR-006fb6?logo=Docker&logoColor=ffffff)](https://github.com/bioexcel/biobb_workflows/pkgs/container/biobb_wf_godmd)

WorkflowHub flavours:

[![CWL - WorkflowHub](https://img.shields.io/badge/CWL-WorkflowHub-1f8787?logo=Common+Workflow+Language&logoColor=ffffff)](https://workflowhub.eu/workflows/549)
[![Galaxy - WorkflowHub](https://img.shields.io/badge/Galaxy-WorkflowHub-1f8787?logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABmJLR0QA%2FwD%2FAP%2BgvaeTAAAACXBIWXMAAA3XAAAN1wFCKJt4AAAAB3RJTUUH5gMQDgQGnOEySwAAAKVJREFUKM%2BNkrsNAjEQRN%2FcJ4NGrg6aISFHQqIaSiAmoAEiWkCE5NwNyYHWBiyPZMnr%2Fcx4bNluqcMkye%2BgA9YVTQLOwOVz4nps46SGejgGHbApFDfAYt6f8sahcK%2B7pL3tHhhTfvv5Z422r1ltwqgCY5KTlDQeQq4Nhgm4zUz9r6lRygCsgCmYs8wd%2Ffbb3tU%2BalNSUEKXxUfgEaQW%2F2CUqtrf9AKgwZfhDysMRQAAAABJRU5ErkJggg%3D%3D&logoColor=ffffff)](https://workflowhub.eu/workflows/558)
[![Jupyter - WorkflowHub](https://img.shields.io/badge/Jupyter-WorkflowHub-1f8787?logo=Jupyter&logoColor=ffffff)](https://workflowhub.eu/workflows/548)
[![Python - WorkflowHub](https://img.shields.io/badge/Python-WorkflowHub-1f8787?logo=python&logoColor=ffffff)](https://workflowhub.eu/workflows/550)
[![Docker - WorkflowHub](https://img.shields.io/badge/Docker-WorkflowHub-1f8787?logo=docker&logoColor=ffffff)](https://workflowhub.eu/workflows/824)

# Protein conformational transitions calculations tutorial using BioExcel Building Blocks (biobb) and GOdMD

***

This tutorial aims to illustrate the process of computing a **conformational transition** between two known **structural conformations** of a protein, step by step, using the **BioExcel Building Blocks library (biobb)**. 

Examples shown are the calculation of the conformational transition for the **Adenylate Kinase** protein, from the **closed state** (PDB Code [1AKE](https://www.rcsb.org/structure/1AKE)) to the **open state** (PDB Code [4AKE](https://www.rcsb.org/structure/4AKE)). **Adenylate Kinases** are **phosphotransferase enzymes** that catalyze the interconversion of the various **adenosine phosphates** (ATP, ADP, and AMP), and are known to undergo large **conformational changes** during their **catalytic cycle**.

The code wrapped is the ***GOdMD*** method, developed in the **[Molecular Modeling and Bioinformatics](https://mmb.irbbarcelona.org/www/) group** (IRB Barcelona). **GOdMD** determines pathways for **conformational transitions** in macromolecules using **discrete molecular dynamics** and **biasing techniques** based on a combination of **essential dynamics** and **Maxwell-Demon sampling techniques**. A web implementation of the method can be found here: https://mmb.irbbarcelona.org/GOdMD/index.php

**Exploration of conformational transition pathways from coarse-grained simulations.**<br>
*Sfriso P, Hospital A, Emperador A, Orozco M.*<br>
*Bioinformatics, 129(16):1980-6.*<br>
*Available at: https://doi.org/10.1093/bioinformatics/btt324*

***

## Workflow Managers

* [Common Workflow Language (CWL)](cwl)
* [Galaxy](galaxy)
* [Jupyter Notebooks](https://github.com/bioexcel/biobb_wf_godmd) (this link switches to a different repository) 
* [Pure Python](python)
* [Docker](docker)

## Copyright & Licensing
This software has been developed in the [MMB group](http://mmb.irbbarcelona.org) at the [BSC](http://www.bsc.es/) & [IRB](https://www.irbbarcelona.org/) for the [European BioExcel](http://bioexcel.eu/), funded by the European Commission (EU Horizon Europe [101093290](https://cordis.europa.eu/project/id/101093290), EU H2020 [823830](http://cordis.europa.eu/projects/823830), EU H2020 [675728](http://cordis.europa.eu/projects/675728)).

* (c) 2015-2026 [Barcelona Supercomputing Center](https://www.bsc.es/)
* (c) 2015-2026 [Institute for Research in Biomedicine](https://www.irbbarcelona.org/)

Licensed under the
[Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0), see the file LICENSE for details.

![](https://bioexcel.eu/wp-content/uploads/2019/04/Bioexcell_logo_1080px_transp.png "Bioexcel")