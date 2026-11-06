/*
 * Local module of the hand-ported biobb_workflows: files of one or more zips (python logic of the workflow.py of the
 * python flavour, which extracts the zip outputs of some steps to use their files in the next steps).
 */

process UNZIP {
    tag "${meta.id}"
    label 'process_single'

    conda 'bioconda::biobb_common=5.3.1'
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/biobb_common:5.3.1--pyhdfd78af_0'
        : 'quay.io/biocontainers/biobb_common:5.3.1--pyhdfd78af_0'}"

    input:
    tuple val(meta), path(zips, stageAs: 'zips/*')

    output:
    tuple val(meta), path('unzipped/*'), emit: files

    script:
    def paths = groovy.json.JsonOutput.toJson([zips].flatten().collect { file -> file.toString() })
    """
    #!/usr/bin/env python3
    import zipfile

    for path in ${paths}:
        with zipfile.ZipFile(path) as zip_file:
            zip_file.extractall('unzipped')
    """

    stub:
    """
    mkdir unzipped
    touch unzipped/stub
    """
}
