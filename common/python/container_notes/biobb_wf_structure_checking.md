### <a name="container-notes"></a>Notes for this workflow (container mode)

* **MPI.** If a `sander` step fails because `sander.MPI` or `mpirun` is not found, the image has no MPI build: remove the `binary_path: sander.MPI`, `mpi_bin` and `mpi_np` lines from the configuration file and the step runs serially.
