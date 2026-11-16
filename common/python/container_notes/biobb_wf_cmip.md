### <a name="container-notes"></a>Notes for this workflow (container mode)

* **CMIP data files on your computer.** The `cmip_run` / `cmip_titration` steps read the CMIP parameter files (`share/cmip/dat/vdwprm`) from `$CONDA_PREFIX` on your computer, not from the container. Download the same CMIP build used by the image and point `CONDA_PREFIX` to it before running the workflow (Linux):

    ```shell
    mkdir -p cmip_data
    curl -fsSL https://conda.anaconda.org/bioconda/linux-64/cmip-2.7.0-h8c3ec31_0.tar.bz2 | tar -xj -C cmip_data
    export CONDA_PREFIX=$PWD/cmip_data
    ```

* **Memory.** Some CMIP steps need around **25 GB of RAM**.
