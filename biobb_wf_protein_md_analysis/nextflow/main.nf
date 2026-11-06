/*
 * Protein MD Analysis tutorial using BioExcel Building Blocks (biobb)
 * Nextflow version of biobb_wf_protein_md_analysis/python/workflow.py, with the BioBB Nextflow modules in modules/.
 * Ported by hand: nextflow_wf_generator.py can't translate the python logic of workflow.py (B-factor PDB and
 * clusters JSON files). Regenerating it only refreshes the modules.
 * Usage: nextflow run main.nf -profile docker [--input samplesheet.csv]
 */

include { BIOBB_ANALYSIS_CPPTRAJ_AVERAGE as STEP1_CPPTRAJ_AVERAGE } from './modules/bioexcel/biobb_analysis/cpptraj_average'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP2_CPPTRAJ_RMS_FIRST } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_ANALYSIS_CPPTRAJ_RMS as STEP3_CPPTRAJ_RMS_AVERAGE } from './modules/bioexcel/biobb_analysis/cpptraj_rms'
include { BIOBB_ANALYSIS_CPPTRAJ_BFACTOR as STEP4_CPPTRAJ_BFACTOR } from './modules/bioexcel/biobb_analysis/cpptraj_bfactor'
include { BIOBB_ANALYSIS_CPPTRAJ_RGYR as STEP5_CPPTRAJ_RGYR } from './modules/bioexcel/biobb_analysis/cpptraj_rgyr'
include { BIOBB_ANALYSIS_CPPTRAJ_CONVERT as STEP6_CPPTRAJ_CONVERT } from './modules/bioexcel/biobb_analysis/cpptraj_convert'
include { BIOBB_ANALYSIS_GMX_CLUSTER as STEP7_GMX_CLUSTER } from './modules/bioexcel/biobb_analysis/gmx_cluster'

params {
    // CSV with an id column and one column per input file: one workflow run per row
    input: String = "${projectDir}/samplesheet.csv"
}

workflow {
    main:
    // One [meta, files] item per samplesheet row: the steps of every row run in parallel
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [[id: row.id], [topology: samplePath(row.topology), trajectory: samplePath(row.trajectory)]] }

    // step1_cpptraj_average: Calculating trajectory structure average
    STEP1_CPPTRAJ_AVERAGE(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(ch_samples.map { meta, files -> [meta, files.trajectory] })
    )
    // step2_cpptraj_rms_first: Generate RMSd (against 1st snp.) plot for the trajectory
    STEP2_CPPTRAJ_RMS_FIRST(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(ch_samples.map { meta, files -> [meta, files.trajectory] })
            .map { meta, top, traj -> [meta, top, traj, []] }
    )
    // step3_cpptraj_rms_average: Generate RMSd (against all frames) plot for the trajectory
    STEP3_CPPTRAJ_RMS_AVERAGE(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(ch_samples.map { meta, files -> [meta, files.trajectory] })
            .map { meta, top, traj -> [meta, top, traj, []] }
    )
    // step4_cpptraj_bfactor: Calculating trajectory Bfactor fluctuations
    STEP4_CPPTRAJ_BFACTOR(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(ch_samples.map { meta, files -> [meta, files.trajectory] })
            .map { meta, top, traj -> [meta, top, traj, []] }
    )
    // step5_cpptraj_rgyr: Generate Radius of Gyration plot for the trajectory
    STEP5_CPPTRAJ_RGYR(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(ch_samples.map { meta, files -> [meta, files.trajectory] })
    )
    // step6_cpptraj_convert: Convert trajectory to GMX compatible format
    STEP6_CPPTRAJ_CONVERT(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(ch_samples.map { meta, files -> [meta, files.trajectory] })
    )
    // step7_gmx_cluster: Clustering structures from the trajectory
    STEP7_GMX_CLUSTER(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(STEP6_CPPTRAJ_CONVERT.out.output_cpptraj_path)
            .map { meta, structure, traj -> [meta, structure, traj, []] }
    )
    // step4_cpptraj_bfactor: Generating B-factor pdb file
    SAVE_BFACTOR(
        ch_samples.map { meta, files -> [meta, files.topology] }
            .join(STEP4_CPPTRAJ_BFACTOR.out.output_cpptraj_path)
    )
    // step7_gmx_cluster: Generating clusters JSON file
    SAVE_CLUSTERS(STEP7_GMX_CLUSTER.out.output_cluster_log_path)

    publish:
    results = channel.empty().mix(
        STEP1_CPPTRAJ_AVERAGE.out.output_cpptraj_path.map { meta, result -> [meta, 'step1_cpptraj_average', result] },
        STEP2_CPPTRAJ_RMS_FIRST.out.output_cpptraj_path.map { meta, result -> [meta, 'step2_cpptraj_rms_first', result] },
        STEP3_CPPTRAJ_RMS_AVERAGE.out.output_cpptraj_path.map { meta, result -> [meta, 'step3_cpptraj_rms_average', result] },
        STEP4_CPPTRAJ_BFACTOR.out.output_cpptraj_path.map { meta, result -> [meta, 'step4_cpptraj_bfactor', result] },
        STEP5_CPPTRAJ_RGYR.out.output_cpptraj_path.map { meta, result -> [meta, 'step5_cpptraj_rgyr', result] },
        STEP6_CPPTRAJ_CONVERT.out.output_cpptraj_path.map { meta, result -> [meta, 'step6_cpptraj_convert', result] },
        STEP7_GMX_CLUSTER.out.output_pdb_path.mix(STEP7_GMX_CLUSTER.out.output_cluster_log_path).map { meta, result -> [meta, 'step7_gmx_cluster', result] },
        SAVE_BFACTOR.out.pdb.map { meta, result -> [meta, 'step4_cpptraj_bfactor', result] },
        SAVE_CLUSTERS.out.json.map { meta, result -> [meta, 'step7_gmx_cluster', result] }
    )
}

output {
    // results/<id>/<step>/<id>_<step>_<role>.<ext>
    results {
        path { meta, step, _result -> "${meta.id}/${step}" }
    }
}

// saveBfactor of workflow.py: the B-factor of every residue (cpptraj_bfactor output) on the atoms of the structure
process SAVE_BFACTOR {
    tag "${meta.id}"
    label 'process_single'

    conda 'bioconda::biobb_common=5.3.1'
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/biobb_common:5.3.1--pyhdfd78af_0'
        : 'quay.io/biocontainers/biobb_common:5.3.1--pyhdfd78af_0'}"

    input:
    tuple val(meta), path(structure), path(bfactors)

    output:
    tuple val(meta), path('*_bfactor.pdb'), emit: pdb

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    #!/usr/bin/env python3
    import csv
    from Bio.PDB.PDBIO import PDBIO
    from Bio.PDB.PDBParser import PDBParser

    # Residue number and B-factor columns, after a header line
    bfactors = {}
    with open('${bfactors}') as dat:
        rows = csv.reader(dat)
        next(rows)
        for row in rows:
            residue, bfactor = row[0].strip().split()[:2]
            bfactors.setdefault(int(float(residue)), float(bfactor))

    structure = PDBParser(QUIET=True).get_structure('structure', '${structure}')
    for atom in structure.get_atoms():
        atom.set_bfactor(bfactors[atom.get_parent().get_id()[1]])
    io = PDBIO()
    io.set_structure(structure)
    io.save('${prefix}_bfactor.pdb')
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_bfactor.pdb
    """
}

// saveClusters of workflow.py: cluster ids and populations of the gmx_cluster log
process SAVE_CLUSTERS {
    tag "${meta.id}"
    label 'process_single'

    conda 'bioconda::biobb_common=5.3.1'
    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/biobb_common:5.3.1--pyhdfd78af_0'
        : 'quay.io/biocontainers/biobb_common:5.3.1--pyhdfd78af_0'}"

    input:
    tuple val(meta), path(cluster_log)

    output:
    tuple val(meta), path('*_clusters.json'), emit: json

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    #!/usr/bin/env python3
    import csv
    import json

    # Table rows after the 'cl. | #st  rmsd | ...' header: cluster | population ...
    clusters = []
    start = False
    with open('${cluster_log}') as log:
        for row in csv.reader(log):
            if start and row:
                columns = row[0].split('|')
                if columns[0].strip():
                    clusters.append({'cluster': columns[0].strip(), 'population': columns[1].strip().split()[0]})
            if row and row[0].startswith('cl.'):
                start = True
    with open('${prefix}_clusters.json', 'w') as out:
        json.dump(clusters, out)
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_clusters.json
    """
}

// Path of a samplesheet column: absolute, or relative to the samplesheet folder
def samplePath(String value) {
    file(file(params.input).parent.resolve(value).toString(), checkIfExists: true)
}
