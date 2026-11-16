### <a name="container-notes"></a>Notes for this workflow (container mode)

* **The `sander_mdrun` input files in `/data` on your computer.** The `sander_mdrun` steps read their input mdin file from `/data` (the folder where the files are mounted *inside* the container) also on your computer. Create it and copy the mdin files there:

    ```shell
    sudo mkdir -p /data && sudo chown "$USER" /data
    cp ABCix_config_files/*.in /data/
    ```

* **MPI.** If a `sander` step fails because `sander.MPI` or `mpirun` is not found, the image has no MPI build: remove the `binary_path: sander.MPI`, `mpi_bin` and `mpi_np` lines from the configuration file and the step runs serially.
