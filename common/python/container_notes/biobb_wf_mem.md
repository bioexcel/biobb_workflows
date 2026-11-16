### <a name="container-notes"></a>Notes for this workflow (container mode)

* **Two tools must be installed on your computer.** The `gorder_aa` and `mda_hole` steps are pure python steps that run on your computer, not in a container, and need:
    * **gorder** (python module): not available on PyPI, only as the conda-forge package `pygorder`.
    * **HOLE** (`hole`, `sph_process`, `sos_triangle` binaries): only available as the conda-forge package `hole2`.

  Since both come only from conda-forge, the **conda mode** is the simplest way to run this workflow. The script [`run_container_test.sh`](../tests/python/run_container_test.sh) shows a conda-free way to install both on Linux.
