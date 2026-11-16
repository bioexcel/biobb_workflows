### <a name="container-notes"></a>Notes for this workflow (container mode)

* **CONCOORD data files on your computer.** The `concoord_dist` / `concoord_disco` steps copy the CONCOORD data files from `$CONCOORDLIB` on your computer into the container. Download the same CONCOORD build used by the image and point `CONCOORDLIB` to it (Linux):

    ```shell
    mkdir -p concoord_data
    curl -fsSL https://conda.anaconda.org/bioconda/linux-64/concoord-2.1.2-h9ee0642_4.tar.bz2 | tar -xj -C concoord_data
    export CONCOORDLIB=$PWD/concoord_data/share/concoord/lib
    ```

* **`CONDA_PREFIX` inside the container.** **workflow.py** builds the CONCOORD path used *inside* the container from `$CONDA_PREFIX`. The images keep their conda environment in `/opt/conda`, so set:

    ```shell
    export CONDA_PREFIX=/opt/conda
    ```
