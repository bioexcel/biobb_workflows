/*
 * Local module of the hand-ported biobb_workflows: zip of files, in the given order (python logic of the workflow.py
 * of the python flavour, which zips the outputs of some steps). The zip is named <prefix>.zip (task.ext.prefix or meta.id).
 * Files with the same name are renamed file_<index>_<name>, as biobb_common's file_utils.zip_list does.
 */

process ZIP {
    tag "${meta.id}"
    label 'process_single'

    conda 'bioconda::biobb_common=5.3.1'
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/biobb_common:5.3.1--pyhdfd78af_0'
        : 'quay.io/biocontainers/biobb_common:5.3.1--pyhdfd78af_0'}"

    input:
    tuple val(meta), path(files, stageAs: 'files/?/*')

    output:
    tuple val(meta), path('*.zip'), emit: zip

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def paths = groovy.json.JsonOutput.toJson([files].flatten().collect { file -> file.toString() })
    """
    #!/usr/bin/env python3
    import zipfile
    from pathlib import PurePath

    names = []
    with zipfile.ZipFile('${prefix}.zip', 'w') as zip_file:
        for index, path in enumerate(${paths}):
            name = PurePath(path).name
            if name in names:
                name = f'file_{index}_{name}'
            names.append(name)
            zip_file.write(path, name, compress_type=zipfile.ZIP_DEFLATED)
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.zip
    """
}
