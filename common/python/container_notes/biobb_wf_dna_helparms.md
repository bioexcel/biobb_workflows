### <a name="container-notes"></a>Notes for this workflow (container mode)

* **A `/data` folder on your computer.** The Curves+ / Canal steps change the working directory to `/data` (the folder where the files are mounted *inside* the container) also on your computer, so it must exist there:

    ```shell
    sudo mkdir -p /data
    ```

    It can stay empty: the containers use their own `/data`.
