### <a name="conda-notes"></a>Notes for this workflow (conda mode)

* **Recent Linux distributions (e.g. Ubuntu 26.04).** Their system library (glibc) refuses to load libraries that ask for an *executable stack*, and the PyTorch build installed by conda carries that flag, so the workflow stops with:

    ```
    ImportError: libtorch_cpu.so: cannot enable executable stack as shared object requires: Invalid argument
    ```

    The flag is a leftover of how the library was compiled (PyTorch does not need it). Clear it once in the environment with [patchelf](https://github.com/NixOS/patchelf) (0.18 or newer):

    ```shell
    conda install -c conda-forge "patchelf>=0.18"
    for lib in "$CONDA_PREFIX"/lib/python3*/site-packages/torch/lib/*.so* "$CONDA_PREFIX"/lib/libtorch*.so*; do
        [ -f "$lib" ] && patchelf --clear-execstack "$lib"
    done
    ```

    macOS and older Linux versions (e.g. Ubuntu 24.04) are not affected.
