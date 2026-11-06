/*
 * Structural DNA helical parameters from MD trajectory tutorial using BioExcel Building Blocks (biobb)
 * Nextflow version of biobb_wf_dna_helparms/python/workflow.py, with the BioBB Nextflow modules in modules/.
 * Ported by hand: nextflow_wf_generator.py can't translate the python logic of workflow.py (loops over the helical
 * parameters and the base pairs, files extracted from the Canal and timeseries zips, zips of the step outputs).
 * Regenerating it only refreshes the modules.
 * Usage: nextflow run main.nf -profile docker [--input samplesheet.csv]
 */

include { BIOBB_DNA_BIOBB_CURVES as STEP1_BIOBB_CURVES } from './modules/bioexcel/biobb_dna/biobb_curves'
include { BIOBB_DNA_BIOBB_CANAL as STEP2_BIOBB_CANAL } from './modules/bioexcel/biobb_dna/biobb_canal'
include { BIOBB_DNA_DNA_AVERAGES as STEP4_DNA_AVERAGES_BASE_PAIR_STEP } from './modules/bioexcel/biobb_dna/dna_averages'
include { BIOBB_DNA_DNA_AVERAGES as STEP5_DNA_AVERAGES_BASE_PAIR } from './modules/bioexcel/biobb_dna/dna_averages'
include { BIOBB_DNA_DNA_AVERAGES as STEP6_DNA_AVERAGES_AXIS_BASE_PAIRS } from './modules/bioexcel/biobb_dna/dna_averages'
include { BIOBB_DNA_DNA_AVERAGES as STEP7_DNA_AVERAGES_GROOVES } from './modules/bioexcel/biobb_dna/dna_averages'
include { BIOBB_DNA_PUCKERING as STEP8_PUCKERING } from './modules/bioexcel/biobb_dna/puckering'
include { BIOBB_DNA_CANONICALAG as STEP9_CANONICALAG } from './modules/bioexcel/biobb_dna/canonicalag'
include { BIOBB_DNA_BIPOPULATIONS as STEP10_BIPOPULATIONS } from './modules/bioexcel/biobb_dna/bipopulations'
include { BIOBB_DNA_DNA_TIMESERIES as STEP12_DNA_TIMESERIES_BASE_PAIR_STEP } from './modules/bioexcel/biobb_dna/dna_timeseries'
include { BIOBB_DNA_DNA_TIMESERIES as STEP13_DNA_TIMESERIES_BASE_PAIR } from './modules/bioexcel/biobb_dna/dna_timeseries'
include { BIOBB_DNA_DNA_TIMESERIES as STEP14_DNA_TIMESERIES_AXIS_BASE_PAIRS } from './modules/bioexcel/biobb_dna/dna_timeseries'
include { BIOBB_DNA_DNA_TIMESERIES as STEP15_DNA_TIMESERIES_GROOVES } from './modules/bioexcel/biobb_dna/dna_timeseries'
include { BIOBB_DNA_DNA_TIMESERIES as STEP16_DNA_TIMESERIES_BACKBONE_TORSIONS } from './modules/bioexcel/biobb_dna/dna_timeseries'
include { BIOBB_DNA_BASEPAIR_STIFFNESS as STEP18_BASEPAIR_STIFFNESS } from './modules/bioexcel/biobb_dna/basepair_stiffness'
include { BIOBB_DNA_DNA_BIMODALITY as STEP19_DNA_BIMODALITY } from './modules/bioexcel/biobb_dna/dna_bimodality'
include { BIOBB_DNA_INTRASEQCORR as STEP20_INTRASEQCORR } from './modules/bioexcel/biobb_dna/intraseqcorr'
include { BIOBB_DNA_INTERSEQCORR as STEP21_INTERSEQCORR } from './modules/bioexcel/biobb_dna/interseqcorr'
include { BIOBB_DNA_INTRAHPCORR as STEP22_INTRAHPCORR } from './modules/bioexcel/biobb_dna/intrahpcorr'
include { BIOBB_DNA_INTERHPCORR as STEP23_INTERHPCORR } from './modules/bioexcel/biobb_dna/interhpcorr'
include { BIOBB_DNA_INTRABPCORR as STEP24_INTRABPCORR } from './modules/bioexcel/biobb_dna/intrabpcorr'
include { BIOBB_DNA_INTERBPCORR as STEP25_INTERBPCORR } from './modules/bioexcel/biobb_dna/interbpcorr'
// Python logic of workflow.py
include { UNZIP as UNZIP_CANAL } from './modules/local/unzip'
include { UNZIP as UNZIP_TIMESERIES } from './modules/local/unzip'
include { ZIP as ZIP_OUTPUTS } from './modules/local/zip'

params {
    // CSV with an id column and one column per input file: one workflow run per row
    input: String = "${projectDir}/samplesheet.csv"
}

workflow {
    main:
    // Helical parameters of the python loops
    def grooves = ['majd', 'majw', 'mind', 'minw']
    def axis_base_pairs = ['inclin', 'tip', 'xdisp', 'ydisp']
    def base_pair = ['shear', 'stretch', 'stagger', 'buckle', 'propel', 'opening']
    def base_pair_step = ['rise', 'roll', 'twist', 'shift', 'slide', 'tilt']
    def backbone_torsions = ['alphaC', 'alphaW', 'betaC', 'betaW', 'gammaC', 'gammaW', 'deltaC', 'deltaW', 'epsilC', 'epsilW', 'zetaC', 'zetaW', 'chiC', 'chiW', 'phaseC', 'phaseW']

    // One [meta, files] item per samplesheet row: the steps of every row run in parallel
    ch_samples = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> [[id: row.id], [trajectory: samplePath(row.trajectory), topology: samplePath(row.topology)]] }

    // step1_biobb_curves: Running Curves+
    STEP1_BIOBB_CURVES(ch_samples.map { meta, files -> [meta, files.trajectory, files.topology] })
    // step2_biobb_canal: Running Canal
    STEP2_BIOBB_CANAL(
        STEP1_BIOBB_CURVES.out.output_cda_path
            .join(STEP1_BIOBB_CURVES.out.output_lis_path)
    )
    // Extracting Canal results: [meta, [<helpar>: canal_output_<helpar>.ser]]
    UNZIP_CANAL(STEP2_BIOBB_CANAL.out.output_zip_path)
    ch_ser = UNZIP_CANAL.out.files.map { meta, files -> [meta, canalSeries(files)] }

    // step4_dna_averages_base_pair_step: Extracting Helical Base Pair Step (Inter Base Pair) Parameters
    STEP4_DNA_AVERAGES_BASE_PAIR_STEP(helparSeries(ch_ser, base_pair_step))
    // step5_dna_averages_base_pair: Extracting Helical Base Pair (Intra Base Pair) Parameters
    STEP5_DNA_AVERAGES_BASE_PAIR(helparSeries(ch_ser, base_pair))
    // step6_dna_averages_axis_base_pairs: Extracting Axis Base Pair Parameters
    STEP6_DNA_AVERAGES_AXIS_BASE_PAIRS(helparSeries(ch_ser, axis_base_pairs))
    // step7_dna_averages_grooves: Extracting Grooves Parameters
    STEP7_DNA_AVERAGES_GROOVES(helparSeries(ch_ser, grooves))
    // step8_puckering: Sugar Puckering
    STEP8_PUCKERING(ch_ser.map { meta, ser -> [meta, ser.phaseC, ser.phaseW] })
    // step9_canonicalag: Canonical Alpha/Gamma
    STEP9_CANONICALAG(ch_ser.map { meta, ser -> [meta, ser.alphaC, ser.alphaW, ser.gammaC, ser.gammaW] })
    // step10_bipopulations: BI/BII Population
    STEP10_BIPOPULATIONS(ch_ser.map { meta, ser -> [meta, ser.epsilC, ser.epsilW, ser.zetaC, ser.zetaW] })

    // step12_dna_timeseries_base_pair_step: Computing timeseries for all base-pair step parameters
    STEP12_DNA_TIMESERIES_BASE_PAIR_STEP(helparSeries(ch_ser, base_pair_step))
    // step13_dna_timeseries_base_pair: Computing timeseries for all base-pair parameters
    STEP13_DNA_TIMESERIES_BASE_PAIR(helparSeries(ch_ser, base_pair))
    // step14_dna_timeseries_axis_base_pairs: Computing timeseries for all axis parameters
    STEP14_DNA_TIMESERIES_AXIS_BASE_PAIRS(helparSeries(ch_ser, axis_base_pairs))
    // step15_dna_timeseries_grooves: Computing timeseries for all grooves parameters
    STEP15_DNA_TIMESERIES_GROOVES(helparSeries(ch_ser, grooves))
    // step16_dna_timeseries_backbone_torsions: Computing timeseries for all backbone torsions parameters
    STEP16_DNA_TIMESERIES_BACKBONE_TORSIONS(helparSeries(ch_ser, backbone_torsions))

    // Extracting the base-pair step (step12) and base-pair (step13) timeseries: [meta, [<pair>: [<helpar>: series csv]]]
    UNZIP_TIMESERIES(
        STEP12_DNA_TIMESERIES_BASE_PAIR_STEP.out.output_zip_path
            .map { meta, zip -> [sampleMeta(meta) + [timeseries: 'base_pair_step'], zip] }
            .groupTuple(size: base_pair_step.size())
            .mix(
                STEP13_DNA_TIMESERIES_BASE_PAIR.out.output_zip_path
                    .map { meta, zip -> [sampleMeta(meta) + [timeseries: 'base_pair'], zip] }
                    .groupTuple(size: base_pair.size())
            )
    )
    ch_timeseries = UNZIP_TIMESERIES.out.files.branch { meta, _files ->
        base_pair_step: meta.timeseries == 'base_pair_step'
        base_pair: true
    }
    // Base-pair steps of the series_shift_<n>_<bases>.csv files, base pairs of the series_shear_<n>_<base>.csv files
    ch_bps_series = ch_timeseries.base_pair_step.flatMap { meta, files ->
        pairSeries(files, base_pair_step, 'shift', /(\d+_[GATC]{2})/).collect { pair, series -> [sampleMeta(meta) + [pair: pair], series] }
    }
    ch_bp_series = ch_timeseries.base_pair.flatMap { meta, files ->
        pairSeries(files, base_pair, 'shear', /(\d+_[GATC]{1})/).collect { pair, series -> [sampleMeta(meta) + [pair: pair], series] }
    }

    // step18_basepair_stiffness: Computing basepair stiffness
    STEP18_BASEPAIR_STIFFNESS(ch_bps_series.map { meta, series -> [meta, series.shift, series.slide, series.rise, series.tilt, series.roll, series.twist] })
    // step19_dna_bimodality: Computing basepair bimodality
    STEP19_DNA_BIMODALITY(
        ch_bps_series.flatMap { meta, series -> base_pair_step.collect { helpar -> [meta + [helpar: helpar], series[helpar], []] } }
    )
    // step20_intraseqcorr: Sequence Correlations: Intra-base pairs
    STEP20_INTRASEQCORR(helparSeries(ch_ser, base_pair))
    // step21_interseqcorr: Sequence Correlations: Inter-base pair steps
    STEP21_INTERSEQCORR(helparSeries(ch_ser, base_pair_step))
    // step22_intrahpcorr: Helical Parameter Correlations: Intra-base pair
    STEP22_INTRAHPCORR(ch_bp_series.map { meta, series -> [meta, series.shear, series.stretch, series.stagger, series.buckle, series.propel, series.opening] })
    // step23_interhpcorr: Helical Parameter Correlations: Inter-base pair steps
    STEP23_INTERHPCORR(ch_bps_series.map { meta, series -> [meta, series.shift, series.slide, series.rise, series.tilt, series.roll, series.twist] })
    // step24_intrabpcorr: Neighboring steps Correlations: Intra-base pair
    STEP24_INTRABPCORR(ch_ser.map { meta, ser -> [meta, ser.shear, ser.stretch, ser.stagger, ser.buckle, ser.propel, ser.opening] })
    // step25_interbpcorr: Neighboring steps Correlations: Inter-base pair steps
    STEP25_INTERBPCORR(ch_ser.map { meta, ser -> [meta, ser.shift, ser.slide, ser.rise, ser.tilt, ser.roll, ser.twist] })

    // Every output of every step: [meta, step, file]
    ch_results = channel.empty().mix(
        STEP1_BIOBB_CURVES.out.output_cda_path.mix(STEP1_BIOBB_CURVES.out.output_lis_path, STEP1_BIOBB_CURVES.out.output_zip_path).map { meta, result -> [meta, 'step1_biobb_curves', result] },
        STEP2_BIOBB_CANAL.out.output_zip_path.map { meta, result -> [meta, 'step2_biobb_canal', result] },
        STEP4_DNA_AVERAGES_BASE_PAIR_STEP.out.output_csv_path.mix(STEP4_DNA_AVERAGES_BASE_PAIR_STEP.out.output_jpg_path).map { meta, result -> [meta, 'step4_dna_averages_base_pair_step', result] },
        STEP5_DNA_AVERAGES_BASE_PAIR.out.output_csv_path.mix(STEP5_DNA_AVERAGES_BASE_PAIR.out.output_jpg_path).map { meta, result -> [meta, 'step5_dna_averages_base_pair', result] },
        STEP6_DNA_AVERAGES_AXIS_BASE_PAIRS.out.output_csv_path.mix(STEP6_DNA_AVERAGES_AXIS_BASE_PAIRS.out.output_jpg_path).map { meta, result -> [meta, 'step6_dna_averages_axis_base_pairs', result] },
        STEP7_DNA_AVERAGES_GROOVES.out.output_csv_path.mix(STEP7_DNA_AVERAGES_GROOVES.out.output_jpg_path).map { meta, result -> [meta, 'step7_dna_averages_grooves', result] },
        STEP8_PUCKERING.out.output_csv_path.mix(STEP8_PUCKERING.out.output_jpg_path).map { meta, result -> [meta, 'step8_puckering', result] },
        STEP9_CANONICALAG.out.output_csv_path.mix(STEP9_CANONICALAG.out.output_jpg_path).map { meta, result -> [meta, 'step9_canonicalag', result] },
        STEP10_BIPOPULATIONS.out.output_csv_path.mix(STEP10_BIPOPULATIONS.out.output_jpg_path).map { meta, result -> [meta, 'step10_bipopulations', result] },
        STEP12_DNA_TIMESERIES_BASE_PAIR_STEP.out.output_zip_path.map { meta, result -> [meta, 'step12_dna_timeseries_base_pair_step', result] },
        STEP13_DNA_TIMESERIES_BASE_PAIR.out.output_zip_path.map { meta, result -> [meta, 'step13_dna_timeseries_base_pair', result] },
        STEP14_DNA_TIMESERIES_AXIS_BASE_PAIRS.out.output_zip_path.map { meta, result -> [meta, 'step14_dna_timeseries_axis_base_pairs', result] },
        STEP15_DNA_TIMESERIES_GROOVES.out.output_zip_path.map { meta, result -> [meta, 'step15_dna_timeseries_grooves', result] },
        STEP16_DNA_TIMESERIES_BACKBONE_TORSIONS.out.output_zip_path.map { meta, result -> [meta, 'step16_dna_timeseries_backbone_torsions', result] },
        STEP18_BASEPAIR_STIFFNESS.out.output_csv_path.mix(STEP18_BASEPAIR_STIFFNESS.out.output_jpg_path).map { meta, result -> [meta, 'step18_basepair_stiffness', result] },
        STEP19_DNA_BIMODALITY.out.output_csv_path.mix(STEP19_DNA_BIMODALITY.out.output_jpg_path).map { meta, result -> [meta, 'step19_dna_bimodality', result] },
        STEP20_INTRASEQCORR.out.output_csv_path.mix(STEP20_INTRASEQCORR.out.output_jpg_path).map { meta, result -> [meta, 'step20_intraseqcorr', result] },
        STEP21_INTERSEQCORR.out.output_csv_path.mix(STEP21_INTERSEQCORR.out.output_jpg_path).map { meta, result -> [meta, 'step21_interseqcorr', result] },
        STEP22_INTRAHPCORR.out.output_csv_path.mix(STEP22_INTRAHPCORR.out.output_jpg_path).map { meta, result -> [meta, 'step22_intrahpcorr', result] },
        STEP23_INTERHPCORR.out.output_csv_path.mix(STEP23_INTERHPCORR.out.output_jpg_path).map { meta, result -> [meta, 'step23_interhpcorr', result] },
        STEP24_INTRABPCORR.out.output_csv_path.mix(STEP24_INTRABPCORR.out.output_jpg_path).map { meta, result -> [meta, 'step24_intrabpcorr', result] },
        STEP25_INTERBPCORR.out.output_csv_path.mix(STEP25_INTERBPCORR.out.output_jpg_path).map { meta, result -> [meta, 'step25_interbpcorr', result] }
    )
    // Compressing the outputs of every step but step1 and step2, in the folder of the step (<id>_<step>_outputs.zip)
    ZIP_OUTPUTS(
        ch_results
            .filter { _meta, step, _result -> !(step in ['step1_biobb_curves', 'step2_biobb_canal']) }
            .map { meta, step, result -> [sampleMeta(meta) + [step: step], result] }
            .groupTuple()
    )

    publish:
    results = ch_results.mix(ZIP_OUTPUTS.out.zip.map { meta, result -> [meta, meta.step, result] })
}

output {
    // results/<id>/<step>/<id>_<step>[_<helpar>][_<pair>]_<role>.<ext>
    results {
        path { meta, step, _result -> "${meta.id}/${step}" }
    }
}

// Path of a samplesheet column: absolute, or relative to the samplesheet folder
def samplePath(String value) {
    file(file(params.input).parent.resolve(value).toString(), checkIfExists: true)
}

// Sample of an item of the helical parameter or base pair loops
def sampleMeta(Map meta) {
    meta.findAll { key, _value -> !(key in ['helpar', 'pair']) }
}

// Canal series of every helical parameter: canal_output_<helpar>.ser -> [<helpar>: file]
def canalSeries(List files) {
    files.findAll { file -> file.name ==~ /canal_output_\w+\.ser/ }.collectEntries { file -> [file.baseName.replaceFirst('canal_output_', ''), file] }
}

// One [meta + [helpar: <helpar>], canal_output_<helpar>.ser] item per helical parameter of a python loop
def helparSeries(ch_ser, List helpars) {
    ch_ser.flatMap { meta, ser -> helpars.collect { helpar -> [meta + [helpar: helpar], ser[helpar]] } }
}

// Timeseries of every base pair (step) found as series_<first>_<pair>.csv, as the python glob: [[<pair>, [<helpar>: series_<helpar>_<pair>.csv]]]
def pairSeries(List files, List helpars, String first, String pairRegex) {
    def byName = files.collectEntries { file -> [file.name, file] }
    files.findAll { file -> file.name.startsWith("series_${first}_") && file.name.endsWith('.csv') }
        .collect { file -> (file.name =~ pairRegex)[0][1] }
        .collect { pair -> [pair, helpars.collectEntries { helpar -> [helpar, byName["series_${helpar}_${pair}.csv".toString()]] }] }
}
