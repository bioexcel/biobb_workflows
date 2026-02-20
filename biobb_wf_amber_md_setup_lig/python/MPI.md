# MPI

Instructions for running the workflow in MPI.

## Install ambertools compatible version 

Install an openmpi version of ambertools once the workflow environment has been built:

    conda install ambertools=24.8=cuda_None_openmpi_py311h0df6727_1

See here for the exact build needed according to your python version and platform:

https://anaconda.org/channels/conda-forge/packages/ambertools/files

## Modify workflow properties

Uncomment the following lines in [workflow.yml](workflow.yml) for all the sander_mdrun steps in the workflow (set the desired number of processes according to the resources available):

```yaml
binary_path: sander.MPI
mpi_np: 8
mpi_bin: mpirun
```