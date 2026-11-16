### <a name="container-notes"></a>Notes for this workflow (container mode)

* **Python 3.12.** **workflow.py** builds the path of the pmx force fields as `$CONDA_PREFIX/lib/python3.12/site-packages/pmx/data/mutff/`. Create the virtual environment with Python 3.12 (`python3.12 -m venv .venv`) and point `CONDA_PREFIX` to it after activating it:

    ```shell
    export CONDA_PREFIX=$VIRTUAL_ENV
    ```

    The pmx package (and its force fields) is installed in the virtual environment by **requirements.txt**.
