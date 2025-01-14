#!/usr/bin/env python3

import os
import re
import time
import argparse
import shutil
import zipfile
from pathlib import Path, PurePath
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_dna.curvesplus.biobb_curves import biobb_curves
from biobb_dna.curvesplus.biobb_canal import biobb_canal
from biobb_dna.dna.dna_averages import dna_averages
from biobb_dna.backbone.puckering import puckering
from biobb_dna.backbone.canonicalag import canonicalag
from biobb_dna.backbone.bipopulations import bipopulations
from biobb_dna.dna.dna_timeseries import dna_timeseries
from biobb_dna.stiffness.basepair_stiffness import basepair_stiffness
from biobb_dna.dna.dna_bimodality import dna_bimodality
from biobb_dna.intrabp_correlations.intraseqcorr import intraseqcorr
from biobb_dna.interbp_correlations.interseqcorr import interseqcorr
from biobb_dna.intrabp_correlations.intrahpcorr import intrahpcorr
from biobb_dna.interbp_correlations.interhpcorr import interhpcorr
from biobb_dna.intrabp_correlations.intrabpcorr import intrabpcorr
from biobb_dna.interbp_correlations.interbpcorr import interbpcorr


def compress_outputs(log, step, wd, glob, zname):
    log.info(f"  Compressing {step} outputs")
    files_list = Path(f"{wd}/{step}").glob(glob)
    zfilename = f"{wd}/{step}/{zname}"
    with zipfile.ZipFile(zfilename, 'w') as zout:
        for file in files_list:
            zout.write(file, PurePath(file).name, compress_type=zipfile.ZIP_DEFLATED)


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    # Auxiliar lists
    grooves = ('majd', 'majw', 'mind', 'minw')
    axis_base_pairs = ('inclin', 'tip', 'xdisp', 'ydisp')
    base_pair = ('shear', 'stretch', 'stagger', 'buckle', 'propel', 'opening')
    base_pair_step = ('rise', 'roll', 'twist', 'shift', 'slide', 'tilt')
    backbone_torsions = ('alphaC', 'alphaW', 'betaC', 'betaW', 'gammaC', 'gammaW', 'deltaC', 'deltaW', 'epsilC', 'epsilW', 'zetaC', 'zetaW', 'chiC', 'chiW', 'phaseC', 'phaseW')

    global_log.info("step1_biobb_curves: Running Curves+")
    biobb_curves(**global_paths["step1_biobb_curves"], properties=global_prop["step1_biobb_curves"])

    global_log.info("step2_biobb_canal: Running Canal")
    biobb_canal(**global_paths["step2_biobb_canal"], properties=global_prop["step2_biobb_canal"])

    global_log.info("\tExtracting Canal results in a temporary folder")
    canal_dir = f"{conf.get_working_dir_path()}/canal_out"

    if Path(canal_dir).exists():
        shutil.rmtree(canal_dir)
    os.mkdir(canal_dir)

    with zipfile.ZipFile(global_paths["step2_biobb_canal"]["output_zip_path"], 'r') as zip_ref:
        zip_ref.extractall(canal_dir)

    global_log.info("step4_dna_averages_base_pair_step: Extracting Helical Base Pair Step (Inter Base Pair) Parameters")
    for helpar in base_pair_step:
        paths = global_paths["step4_dna_averages_base_pair_step"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step4_dna_averages_base_pair_step/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step4_dna_averages_base_pair_step/{helpar}.averages.jpg"
        props = global_prop["step4_dna_averages_base_pair_step"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

    compress_outputs(global_log, 'step4_dna_averages_base_pair_step', conf.get_working_dir_path(), '*.averages.*', 'base_pair_step.avs.zip')

    global_log.info("step5_dna_averages_base_pair: Extracting Helical Base Pair (Intra Base Pair) Parameters")
    for helpar in base_pair:
        paths = global_paths["step5_dna_averages_base_pair"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step5_dna_averages_base_pair/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step5_dna_averages_base_pair/{helpar}.averages.jpg"
        props = global_prop["step5_dna_averages_base_pair"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

    compress_outputs(global_log, 'step5_dna_averages_base_pair', conf.get_working_dir_path(), '*.averages.*', 'base_pair.avs.zip')

    global_log.info("step6_dna_averages_axis_base_pairs: Extracting Axis Base Pair Parameters")
    for helpar in axis_base_pairs:
        paths = global_paths["step6_dna_averages_axis_base_pairs"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step6_dna_averages_axis_base_pairs/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step6_dna_averages_axis_base_pairs/{helpar}.averages.jpg"
        props = global_prop["step6_dna_averages_axis_base_pairs"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

    compress_outputs(global_log, 'step6_dna_averages_axis_base_pairs', conf.get_working_dir_path(), '*.averages.*', 'axis_base_pairs.avs.zip')

    global_log.info("step7_dna_averages_grooves: Extracting Grooves Parameters")
    for helpar in grooves:
        paths = global_paths["step7_dna_averages_grooves"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step7_dna_averages_grooves/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step7_dna_averages_grooves/{helpar}.averages.jpg"
        props = global_prop["step7_dna_averages_grooves"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

    compress_outputs(global_log, 'step7_dna_averages_grooves', conf.get_working_dir_path(), '*.averages.*', 'grooves.avs.zip')

    global_log.info("step8_puckering: Sugar Puckering")
    paths = global_paths["step8_puckering"]
    paths["input_phaseC_path"] = f"{canal_dir}/canal_output_phaseC.ser"
    paths["input_phaseW_path"] = f"{canal_dir}/canal_output_phaseW.ser"
    puckering(**paths, properties=global_prop["step8_puckering"])

    compress_outputs(global_log, 'step8_puckering', conf.get_working_dir_path(), '*.averages.*', 'puckering.avs.zip')

    global_log.info("step9_canonicalag: Canonical Alpha/Gamma")
    paths = global_paths["step9_canonicalag"]
    paths["input_alphaC_path"] = f"{canal_dir}/canal_output_alphaC.ser"
    paths["input_alphaW_path"] = f"{canal_dir}/canal_output_alphaW.ser"
    paths["input_gammaC_path"] = f"{canal_dir}/canal_output_gammaC.ser"
    paths["input_gammaW_path"] = f"{canal_dir}/canal_output_gammaW.ser"
    canonicalag(**paths, properties=global_prop["step9_canonicalag"])

    compress_outputs(global_log, 'step9_canonicalag', conf.get_working_dir_path(), '*.averages.*', 'alphagamma.avs.zip')

    global_log.info("step10_bipopulations: BI/BII Population")
    paths = global_paths["step10_bipopulations"]
    paths["input_epsilC_path"] = f"{canal_dir}/canal_output_epsilC.ser"
    paths["input_epsilW_path"] = f"{canal_dir}/canal_output_epsilW.ser"
    paths["input_zetaC_path"] = f"{canal_dir}/canal_output_zetaC.ser"
    paths["input_zetaW_path"] = f"{canal_dir}/canal_output_zetaW.ser"
    bipopulations(**paths, properties=global_prop["step10_bipopulations"])

    compress_outputs(global_log, 'step10_bipopulations', conf.get_working_dir_path(), '*.averages.*', 'bIbII.avs.zip')

    global_log.info("step12_dna_timeseries_base_pair_step: Computing timeseries for all base-pair step parameters")
    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    for helpar in base_pair_step:
        paths = global_paths["step12_dna_timeseries_base_pair_step"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/{helpar}.timeseries.zip"
        props = global_prop["step12_dna_timeseries_base_pair_step"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)
        global_log.info(f"\t{helpar} parameters extracted")

    compress_outputs(global_log, 'step12_dna_timeseries_base_pair_step', conf.get_working_dir_path(), '*.timeseries.*', 'base_pair_step.tms.zip')

    global_log.info("step13_dna_timeseries_base_pair: Computing timeseries for all base-pair parameters")
    timeseries_dir = f"{conf.get_working_dir_path()}/step13_dna_timeseries_base_pair/timeseries"
    for helpar in base_pair:
        paths = global_paths["step13_dna_timeseries_base_pair"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step13_dna_timeseries_base_pair/{helpar}.timeseries.zip"
        props = global_prop["step13_dna_timeseries_base_pair"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)
        global_log.info(f"\t{helpar} parameters extracted")

    compress_outputs(global_log, 'step13_dna_timeseries_base_pair', conf.get_working_dir_path(), '*.timeseries.*', 'base_pair.tms.zip')

    global_log.info("step14_dna_timeseries_axis_base_pairs: Computing timeseries for all axis parameters")
    timeseries_dir = f"{conf.get_working_dir_path()}/step14_dna_timeseries_axis_base_pairs/timeseries"
    for helpar in axis_base_pairs:
        paths = global_paths["step14_dna_timeseries_axis_base_pairs"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step14_dna_timeseries_axis_base_pairs/{helpar}.timeseries.zip"
        props = global_prop["step14_dna_timeseries_axis_base_pairs"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)
        global_log.info(f"\t{helpar} parameters extracted")

    compress_outputs(global_log, 'step14_dna_timeseries_axis_base_pairs', conf.get_working_dir_path(), '*.timeseries.*', 'axis_base_pairs.tms.zip')

    global_log.info("step15_dna_timeseries_grooves: Computing timeseries for all grooves parameters")
    timeseries_dir = f"{conf.get_working_dir_path()}/step15_dna_timeseries_grooves/timeseries"
    for helpar in grooves:
        paths = global_paths["step15_dna_timeseries_grooves"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step15_dna_timeseries_grooves/{helpar}.timeseries.zip"
        props = global_prop["step15_dna_timeseries_grooves"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)
        global_log.info(f"\t{helpar} parameters extracted")

    compress_outputs(global_log, 'step15_dna_timeseries_grooves', conf.get_working_dir_path(), '*.timeseries.*', 'grooves.tms.zip')

    global_log.info("step16_dna_timeseries_backbone_torsions: Computing timeseries for all backbone torsions parameters")
    timeseries_dir = f"{conf.get_working_dir_path()}/step16_dna_timeseries_backbone_torsions/timeseries"
    for helpar in backbone_torsions:
        paths = global_paths["step16_dna_timeseries_backbone_torsions"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step16_dna_timeseries_backbone_torsions/{helpar}.timeseries.zip"
        props = global_prop["step16_dna_timeseries_backbone_torsions"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)
        global_log.info(f"\t{helpar} parameters computed")

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)
        global_log.info(f"\t{helpar} parameters extracted")

    compress_outputs(global_log, 'step16_dna_timeseries_backbone_torsions', conf.get_working_dir_path(), '*.timeseries.*', 'backbone_torsions.tms.zip')

    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    series_shift = Path(timeseries_dir).glob('series_shift_*.csv')
    global_log.info("step18_basepair_stiffness: Computing basepair stiffness")
    for f in series_shift:
        pair = re.findall('(\d+\_[GATC]{2})', str(f))[0]
        paths = global_paths["step18_basepair_stiffness"]
        paths["input_filename_shift"] = f
        paths["input_filename_slide"] = PurePath(timeseries_dir).joinpath(f'series_slide_{pair}.csv')
        paths["input_filename_rise"] = PurePath(timeseries_dir).joinpath(f'series_rise_{pair}.csv')
        paths["input_filename_tilt"] = PurePath(timeseries_dir).joinpath(f'series_tilt_{pair}.csv')
        paths["input_filename_roll"] = PurePath(timeseries_dir).joinpath(f'series_roll_{pair}.csv')
        paths["input_filename_twist"] = PurePath(timeseries_dir).joinpath(f'series_twist_{pair}.csv')
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step18_basepair_stiffness/stiffness_bps.{pair}.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step18_basepair_stiffness/stiffness_bps.{pair}.jpg"
        basepair_stiffness(**paths, properties=global_prop["step18_basepair_stiffness"])
        global_log.info(f"\t{pair} parameters computed")

    compress_outputs(global_log, 'step18_basepair_stiffness', conf.get_working_dir_path(), 'stiffness_bps.*', 'basepair_stiffness.zip')

    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    series_shift = Path(timeseries_dir).glob('series_shift_*.csv')
    global_log.info("step19_dna_bimodality: Computing basepair bimodality")
    for f in series_shift:
        pair = re.findall('(\d+\_[GATC]{2})', str(f))[0]
        paths = global_paths["step19_dna_bimodality"]
        global_log.info(f"\tComputing {pair} parameters")
        for helpar in base_pair_step:
            paths["input_csv_file"] = PurePath(timeseries_dir).joinpath(f'series_{helpar}_{pair}.csv')
            paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step19_dna_bimodality/{helpar}.bimodality.{pair}.csv"
            paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step19_dna_bimodality/{helpar}.bimodality.{pair}.jpg"
            dna_bimodality(**paths, properties=global_prop["step19_dna_bimodality"])
            global_log.info(f"\t\t{helpar} {pair} parameters computed")

    compress_outputs(global_log, 'step19_dna_bimodality', conf.get_working_dir_path(), '*.bimodality.*', 'bim.zip')

    global_log.info("step20_intraseqcorr: Sequence Correlations: Intra-base pairs")
    for helpar in base_pair:
        paths = global_paths["step20_intraseqcorr"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step20_intraseqcorr/{helpar}.intrabp_correlation.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step20_intraseqcorr/{helpar}.intrabp_correlation.jpg"
        intraseqcorr(**paths, properties=global_prop["step20_intraseqcorr"])
        global_log.info(f"\t{helpar} correlations computed")

    compress_outputs(global_log, 'step20_intraseqcorr', conf.get_working_dir_path(), '*.intrabp_correlation.*', 'intraseqcorr.zip')

    global_log.info("step21_interseqcorr: Sequence Correlations: Inter-base pair steps")
    for helpar in base_pair_step:
        paths = global_paths["step21_interseqcorr"]
        paths["input_ser_path"] = f"{canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step21_interseqcorr/{helpar}.interbp_correlation.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step21_interseqcorr/{helpar}.interbp_correlation.jpg"
        interseqcorr(**paths, properties=global_prop["step21_interseqcorr"])
        global_log.info(f"\t{helpar} correlations computed")

    compress_outputs(global_log, 'step21_interseqcorr', conf.get_working_dir_path(), '*.interbp_correlation.*', 'interseqcorr.zip')

    timeseries_dir = f"{conf.get_working_dir_path()}/step13_dna_timeseries_base_pair/timeseries"
    series_shear = Path(timeseries_dir).glob('series_shear_*.csv')
    global_log.info("step22_intrahpcorr: Helical Parameter Correlations: Intra-base pair")
    for f in series_shear:
        pair = re.findall('(\d+\_[GATC]{1})', str(f))[0]
        paths = global_paths["step22_intrahpcorr"]
        paths["input_filename_shear"] = f
        paths["input_filename_stretch"] = PurePath(timeseries_dir).joinpath(f'series_stretch_{pair}.csv')
        paths["input_filename_stagger"] = PurePath(timeseries_dir).joinpath(f'series_stagger_{pair}.csv')
        paths["input_filename_buckle"] = PurePath(timeseries_dir).joinpath(f'series_buckle_{pair}.csv')
        paths["input_filename_propel"] = PurePath(timeseries_dir).joinpath(f'series_propel_{pair}.csv')
        paths["input_filename_opening"] = PurePath(timeseries_dir).joinpath(f'series_opening_{pair}.csv')
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step22_intrahpcorr/helpar_bp_correlation.{pair}.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step22_intrahpcorr/helpar_bp_correlation.{pair}.jpg"
        intrahpcorr(**paths, properties=global_prop["step22_intrahpcorr"])
        global_log.info(f"\t{pair} parameters computed")

    compress_outputs(global_log, 'step22_intrahpcorr', conf.get_working_dir_path(), 'helpar_bp_correlation.*', 'intrahpcorr.zip')

    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    series_shift = Path(timeseries_dir).glob('series_shift_*.csv')
    global_log.info("step23_interhpcorr: Helical Parameter Correlations: Inter-base pair steps")
    for f in series_shift:
        pair = re.findall('(\d+\_[GATC]{2})', str(f))[0]
        paths = global_paths["step23_interhpcorr"]
        paths["input_filename_shift"] = f
        paths["input_filename_slide"] = PurePath(timeseries_dir).joinpath(f'series_slide_{pair}.csv')
        paths["input_filename_rise"] = PurePath(timeseries_dir).joinpath(f'series_rise_{pair}.csv')
        paths["input_filename_tilt"] = PurePath(timeseries_dir).joinpath(f'series_tilt_{pair}.csv')
        paths["input_filename_roll"] = PurePath(timeseries_dir).joinpath(f'series_roll_{pair}.csv')
        paths["input_filename_twist"] = PurePath(timeseries_dir).joinpath(f'series_twist_{pair}.csv')
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step23_interhpcorr/helpar_bps_correlation.{pair}.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step23_interhpcorr/helpar_bps_correlation.{pair}.jpg"
        interhpcorr(**paths, properties=global_prop["step23_interhpcorr"])
        global_log.info(f"\t{pair} parameters computed")

    compress_outputs(global_log, 'step23_interhpcorr', conf.get_working_dir_path(), 'helpar_bps_correlation.*', 'interhpcorr.zip')

    global_log.info("step24_intrabpcorr: Neighboring steps Correlations: Intra-base pair")
    paths = global_paths["step24_intrabpcorr"]
    paths["input_filename_shear"] = f"{canal_dir}/canal_output_shear.ser"
    paths["input_filename_stretch"] = f"{canal_dir}/canal_output_stretch.ser"
    paths["input_filename_stagger"] = f"{canal_dir}/canal_output_stagger.ser"
    paths["input_filename_buckle"] = f"{canal_dir}/canal_output_buckle.ser"
    paths["input_filename_propel"] = f"{canal_dir}/canal_output_propel.ser"
    paths["input_filename_opening"] = f"{canal_dir}/canal_output_opening.ser"
    intrabpcorr(**paths, properties=global_prop["step24_intrabpcorr"])

    compress_outputs(global_log, 'step24_intrabpcorr', conf.get_working_dir_path(), 'bp_correlation.*', 'intrabpcorr.zip')

    global_log.info("step25_interbpcorr: Neighboring steps Correlations: Inter-base pair steps")
    paths = global_paths["step25_interbpcorr"]
    paths["input_filename_shift"] = f"{canal_dir}/canal_output_shift.ser"
    paths["input_filename_slide"] = f"{canal_dir}/canal_output_slide.ser"
    paths["input_filename_rise"] = f"{canal_dir}/canal_output_rise.ser"
    paths["input_filename_tilt"] = f"{canal_dir}/canal_output_tilt.ser"
    paths["input_filename_roll"] = f"{canal_dir}/canal_output_roll.ser"
    paths["input_filename_twist"] = f"{canal_dir}/canal_output_twist.ser"
    interbpcorr(**paths, properties=global_prop["step25_interbpcorr"])

    compress_outputs(global_log, 'step25_interbpcorr', conf.get_working_dir_path(), 'bps_correlation.*', 'interbpcorr.zip')

    elapsed_time = time.time() - start_time
    global_log.info('')
    global_log.info('')
    global_log.info('Execution successful: ')
    global_log.info('  Workflow_path: %s' % conf.get_working_dir_path())
    global_log.info('  Config File: %s' % config)
    if system:
        global_log.info('  System: %s' % system)
    global_log.info('')
    global_log.info('Elapsed time: %.1f minutes' % (elapsed_time/60))
    global_log.info('')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="ABC MD Setup pipeline using BioExcel Building Blocks")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
