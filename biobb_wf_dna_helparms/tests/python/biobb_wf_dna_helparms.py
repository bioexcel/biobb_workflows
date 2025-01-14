import pytest
import re
import glob
import os
import shutil
import zipfile
from pathlib import Path, PurePath
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
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

global_work_dir = None
global_global_canal_dir = None
grooves = ('majd', 'majw', 'mind', 'minw')
axis_base_pairs = ('inclin', 'tip', 'xdisp', 'ydisp')
base_pair = ('shear', 'stretch', 'stagger', 'buckle', 'propel', 'opening')
base_pair_step = ('rise', 'roll', 'twist', 'shift', 'slide', 'tilt')
backbone_torsions = ('alphaC', 'alphaW', 'betaC', 'betaW', 'gammaC', 'gammaW', 'deltaC', 'deltaW', 'epsilC', 'epsilW', 'zetaC', 'zetaW', 'chiC', 'chiW', 'phaseC', 'phaseW')


def compress_outputs(step, wd, glob, zname):
    files_list = Path(f"{wd}/{step}").glob(glob)
    zfilename = f"{wd}/{step}/{zname}"
    with zipfile.ZipFile(zfilename, 'w') as zout:
        for file in files_list:
            zout.write(file, PurePath(file).name, compress_type=zipfile.ZIP_DEFLATED)
    return zfilename


def step1_biobb_curves(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    biobb_curves(**global_paths["step1_biobb_curves"], properties=global_prop["step1_biobb_curves"])

    assert fx.not_empty(global_paths["step1_biobb_curves"]["output_cda_path"])
    assert fx.equal(global_paths["step1_biobb_curves"]["output_cda_path"], f'reference/step1_biobb_curves/{Path(global_paths["step1_biobb_curves"]["output_cda_path"]).name}')
    assert fx.not_empty(global_paths["step1_biobb_curves"]["output_lis_path"])
    # assert fx.equal(global_paths["step1_biobb_curves"]["output_lis_path"], f'reference/step1_biobb_curves/{Path(global_paths["step1_biobb_curves"]["output_lis_path"]).name}')

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step2_biobb_canal(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    biobb_canal(**global_paths["step2_biobb_canal"], properties=global_prop["step2_biobb_canal"])

    assert fx.not_empty(global_paths["step2_biobb_canal"]["output_zip_path"])
    assert fx.equal(global_paths["step2_biobb_canal"]["output_zip_path"], f'reference/step2_biobb_canal/{Path(global_paths["step2_biobb_canal"]["output_zip_path"]).name}')

    global global_canal_dir
    global_canal_dir = f"{conf.get_working_dir_path()}/canal_out"

    if Path(global_canal_dir).exists():
        shutil.rmtree(global_canal_dir)
    os.mkdir(global_canal_dir)

    with zipfile.ZipFile(global_paths["step2_biobb_canal"]["output_zip_path"], 'r') as zip_ref:
        zip_ref.extractall(global_canal_dir)


def step4_dna_averages_base_pair_step(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    for helpar in base_pair_step:
        paths = global_paths["step4_dna_averages_base_pair_step"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step4_dna_averages_base_pair_step/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step4_dna_averages_base_pair_step/{helpar}.averages.jpg"
        props = global_prop["step4_dna_averages_base_pair_step"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)

    zfilename = compress_outputs('step4_dna_averages_base_pair_step', conf.get_working_dir_path(), '*.averages.*', 'base_pair_step.avs.zip')

    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step4_dna_averages_base_pair_step/base_pair_step.avs.zip')


def step5_dna_averages_base_pair(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    for helpar in base_pair:
        paths = global_paths["step5_dna_averages_base_pair"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step5_dna_averages_base_pair/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step5_dna_averages_base_pair/{helpar}.averages.jpg"
        props = global_prop["step5_dna_averages_base_pair"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)

    zfilename = compress_outputs('step5_dna_averages_base_pair', conf.get_working_dir_path(), '*.averages.*', 'base_pair.avs.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step5_dna_averages_base_pair/base_pair.avs.zip')


def step6_dna_averages_axis_base_pairs(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    for helpar in axis_base_pairs:
        paths = global_paths["step6_dna_averages_axis_base_pairs"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step6_dna_averages_axis_base_pairs/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step6_dna_averages_axis_base_pairs/{helpar}.averages.jpg"
        props = global_prop["step6_dna_averages_axis_base_pairs"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)

    zfilename = compress_outputs('step6_dna_averages_axis_base_pairs', conf.get_working_dir_path(), '*.averages.*', 'axis_base_pairs.avs.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step6_dna_averages_axis_base_pairs/axis_base_pairs.avs.zip')


def step7_dna_averages_grooves(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    for helpar in grooves:
        paths = global_paths["step7_dna_averages_grooves"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step7_dna_averages_grooves/{helpar}.averages.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step7_dna_averages_grooves/{helpar}.averages.jpg"
        props = global_prop["step7_dna_averages_grooves"]
        props["helpar_name"] = helpar
        dna_averages(**paths, properties=props)

    zfilename = compress_outputs('step7_dna_averages_grooves', conf.get_working_dir_path(), '*.averages.*', 'grooves.avs.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step7_dna_averages_grooves/grooves.avs.zip')


def step8_puckering(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    paths = global_paths["step8_puckering"]
    paths["input_phaseC_path"] = f"{global_canal_dir}/canal_output_phaseC.ser"
    paths["input_phaseW_path"] = f"{global_canal_dir}/canal_output_phaseW.ser"
    puckering(**paths, properties=global_prop["step8_puckering"])

    zfilename = compress_outputs('step8_puckering', conf.get_working_dir_path(), '*.averages.*', 'puckering.avs.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step8_puckering/puckering.avs.zip')


def step9_canonicalag(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    paths = global_paths["step9_canonicalag"]
    paths["input_alphaC_path"] = f"{global_canal_dir}/canal_output_alphaC.ser"
    paths["input_alphaW_path"] = f"{global_canal_dir}/canal_output_alphaW.ser"
    paths["input_gammaC_path"] = f"{global_canal_dir}/canal_output_gammaC.ser"
    paths["input_gammaW_path"] = f"{global_canal_dir}/canal_output_gammaW.ser"
    canonicalag(**paths, properties=global_prop["step9_canonicalag"])

    zfilename = compress_outputs('step9_canonicalag', conf.get_working_dir_path(), '*.averages.*', 'alphagamma.avs.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step9_canonicalag/alphagamma.avs.zip')


def step10_bipopulations(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    paths = global_paths["step10_bipopulations"]
    paths["input_epsilC_path"] = f"{global_canal_dir}/canal_output_epsilC.ser"
    paths["input_epsilW_path"] = f"{global_canal_dir}/canal_output_epsilW.ser"
    paths["input_zetaC_path"] = f"{global_canal_dir}/canal_output_zetaC.ser"
    paths["input_zetaW_path"] = f"{global_canal_dir}/canal_output_zetaW.ser"
    bipopulations(**paths, properties=global_prop["step10_bipopulations"])

    zfilename = compress_outputs('step10_bipopulations', conf.get_working_dir_path(), '*.averages.*', 'bIbII.avs.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step10_bipopulations/bIbII.avs.zip')


def step12_dna_timeseries_base_pair_step(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    for helpar in base_pair_step:
        paths = global_paths["step12_dna_timeseries_base_pair_step"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/{helpar}.timeseries.zip"
        props = global_prop["step12_dna_timeseries_base_pair_step"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)

    zfilename = compress_outputs('step12_dna_timeseries_base_pair_step', conf.get_working_dir_path(), '*.timeseries.*', 'base_pair_step.tms.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step12_dna_timeseries_base_pair_step/base_pair_step.tms.zip')


def step13_dna_timeseries_base_pair(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step13_dna_timeseries_base_pair/timeseries"
    for helpar in base_pair:
        paths = global_paths["step13_dna_timeseries_base_pair"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step13_dna_timeseries_base_pair/{helpar}.timeseries.zip"
        props = global_prop["step13_dna_timeseries_base_pair"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)

    zfilename = compress_outputs('step13_dna_timeseries_base_pair', conf.get_working_dir_path(), '*.timeseries.*', 'base_pair.tms.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step13_dna_timeseries_base_pair/base_pair.tms.zip')


def step14_dna_timeseries_axis_base_pairs(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step14_dna_timeseries_axis_base_pairs/timeseries"
    for helpar in axis_base_pairs:
        paths = global_paths["step14_dna_timeseries_axis_base_pairs"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step14_dna_timeseries_axis_base_pairs/{helpar}.timeseries.zip"
        props = global_prop["step14_dna_timeseries_axis_base_pairs"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)

    zfilename = compress_outputs('step14_dna_timeseries_axis_base_pairs', conf.get_working_dir_path(), '*.timeseries.*', 'axis_base_pairs.tms.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step14_dna_timeseries_axis_base_pairs/axis_base_pairs.tms.zip')


def step15_dna_timeseries_grooves(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step15_dna_timeseries_grooves/timeseries"
    for helpar in grooves:
        paths = global_paths["step15_dna_timeseries_grooves"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step15_dna_timeseries_grooves/{helpar}.timeseries.zip"
        props = global_prop["step15_dna_timeseries_grooves"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)

    zfilename = compress_outputs('step15_dna_timeseries_grooves', conf.get_working_dir_path(), '*.timeseries.*', 'grooves.tms.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step15_dna_timeseries_grooves/grooves.tms.zip')


def step16_dna_timeseries_backbone_torsions(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step16_dna_timeseries_backbone_torsions/timeseries"
    for helpar in backbone_torsions:
        paths = global_paths["step16_dna_timeseries_backbone_torsions"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_zip_path"] = f"{conf.get_working_dir_path()}/step16_dna_timeseries_backbone_torsions/{helpar}.timeseries.zip"
        props = global_prop["step16_dna_timeseries_backbone_torsions"]
        props["helpar_name"] = helpar
        dna_timeseries(**paths, properties=props)

        if not Path(timeseries_dir).exists():
            os.mkdir(timeseries_dir)
        with zipfile.ZipFile(paths["output_zip_path"], 'r') as zip_ref:
            zip_ref.extractall(timeseries_dir)

    zfilename = compress_outputs('step16_dna_timeseries_backbone_torsions', conf.get_working_dir_path(), '*.timeseries.*', 'backbone_torsions.tms.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step16_dna_timeseries_backbone_torsions/backbone_torsions.tms.zip')


def step18_basepair_stiffness(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    series_shift = Path(timeseries_dir).glob('series_shift_*.csv')
    for f in series_shift:
        pair = re.findall('(\\d+\\_[GATC]{2})', str(f))[0]
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

    zfilename = compress_outputs('step18_basepair_stiffness', conf.get_working_dir_path(), 'stiffness_bps.*', 'basepair_stiffness.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step18_basepair_stiffness/basepair_stiffness.zip')


def step19_dna_bimodality(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    series_shift = Path(timeseries_dir).glob('series_shift_*.csv')
    for f in series_shift:
        pair = re.findall('(\\d+\\_[GATC]{2})', str(f))[0]
        paths = global_paths["step19_dna_bimodality"]
        global_log.info(f"\tComputing {pair} parameters")
        for helpar in base_pair_step:
            paths["input_csv_file"] = PurePath(timeseries_dir).joinpath(f'series_{helpar}_{pair}.csv')
            paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step19_dna_bimodality/{helpar}.bimodality.{pair}.csv"
            paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step19_dna_bimodality/{helpar}.bimodality.{pair}.jpg"
            dna_bimodality(**paths, properties=global_prop["step19_dna_bimodality"])

    zfilename = compress_outputs('step19_dna_bimodality', conf.get_working_dir_path(), '*.bimodality.*', 'bim.zip')
    assert fx.not_empty(zfilename)
    # assert fx.equal(zfilename, 'reference/step19_dna_bimodality/bim.zip', percent_tolerance=10)


def step20_intraseqcorr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    for helpar in base_pair:
        paths = global_paths["step20_intraseqcorr"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step20_intraseqcorr/{helpar}.intrabp_correlation.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step20_intraseqcorr/{helpar}.intrabp_correlation.jpg"
        intraseqcorr(**paths, properties=global_prop["step20_intraseqcorr"])
        global_log.info(f"\t{helpar} correlations computed")

    zfilename = compress_outputs('step20_intraseqcorr', conf.get_working_dir_path(), '*.intrabp_correlation.*', 'intraseqcorr.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step20_intraseqcorr/intraseqcorr.zip')


def step21_interseqcorr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    for helpar in base_pair_step:
        paths = global_paths["step21_interseqcorr"]
        paths["input_ser_path"] = f"{global_canal_dir}/canal_output_{helpar}.ser"
        paths["output_csv_path"] = f"{conf.get_working_dir_path()}/step21_interseqcorr/{helpar}.interbp_correlation.csv"
        paths["output_jpg_path"] = f"{conf.get_working_dir_path()}/step21_interseqcorr/{helpar}.interbp_correlation.jpg"
        interseqcorr(**paths, properties=global_prop["step21_interseqcorr"])
        global_log.info(f"\t{helpar} correlations computed")

    zfilename = compress_outputs('step21_interseqcorr', conf.get_working_dir_path(), '*.interbp_correlation.*', 'interseqcorr.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step21_interseqcorr/interseqcorr.zip')


def step22_intrahpcorr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step13_dna_timeseries_base_pair/timeseries"
    series_shear = Path(timeseries_dir).glob('series_shear_*.csv')
    for f in series_shear:
        pair = re.findall('(\\d+\\_[GATC]{1})', str(f))[0]
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

    zfilename = compress_outputs('step22_intrahpcorr', conf.get_working_dir_path(), 'helpar_bp_correlation.*', 'intrahpcorr.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step22_intrahpcorr/intrahpcorr.zip')


def step23_interhpcorr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    timeseries_dir = f"{conf.get_working_dir_path()}/step12_dna_timeseries_base_pair_step/timeseries"
    series_shift = Path(timeseries_dir).glob('series_shift_*.csv')
    for f in series_shift:
        pair = re.findall('(\\d+\\_[GATC]{2})', str(f))[0]
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

    zfilename = compress_outputs('step23_interhpcorr', conf.get_working_dir_path(), 'helpar_bps_correlation.*', 'interhpcorr.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step23_interhpcorr/interhpcorr.zip')


def step24_intrabpcorr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    paths = global_paths["step24_intrabpcorr"]
    paths["input_filename_shear"] = f"{global_canal_dir}/canal_output_shear.ser"
    paths["input_filename_stretch"] = f"{global_canal_dir}/canal_output_stretch.ser"
    paths["input_filename_stagger"] = f"{global_canal_dir}/canal_output_stagger.ser"
    paths["input_filename_buckle"] = f"{global_canal_dir}/canal_output_buckle.ser"
    paths["input_filename_propel"] = f"{global_canal_dir}/canal_output_propel.ser"
    paths["input_filename_opening"] = f"{global_canal_dir}/canal_output_opening.ser"
    intrabpcorr(**paths, properties=global_prop["step24_intrabpcorr"])

    zfilename = compress_outputs('step24_intrabpcorr', conf.get_working_dir_path(), 'bp_correlation.*', 'intrabpcorr.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step24_intrabpcorr/intrabpcorr.zip')


def step25_interbpcorr(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    paths = global_paths["step25_interbpcorr"]
    paths["input_filename_shift"] = f"{global_canal_dir}/canal_output_shift.ser"
    paths["input_filename_slide"] = f"{global_canal_dir}/canal_output_slide.ser"
    paths["input_filename_rise"] = f"{global_canal_dir}/canal_output_rise.ser"
    paths["input_filename_tilt"] = f"{global_canal_dir}/canal_output_tilt.ser"
    paths["input_filename_roll"] = f"{global_canal_dir}/canal_output_roll.ser"
    paths["input_filename_twist"] = f"{global_canal_dir}/canal_output_twist.ser"
    interbpcorr(**paths, properties=global_prop["step25_interbpcorr"])

    zfilename = compress_outputs('step25_interbpcorr', conf.get_working_dir_path(), 'bps_correlation.*', 'interbpcorr.zip')
    assert fx.not_empty(zfilename)
    assert fx.equal(zfilename, 'reference/step25_interbpcorr/interbpcorr.zip')

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step1_biobb_curves(config_path, system):
    step1_biobb_curves(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_biobb_canal(config_path, system):
    step2_biobb_canal(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_dna_averages_base_pair_step(config_path, system):
    step4_dna_averages_base_pair_step(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_dna_averages_base_pair(config_path, system):
    step5_dna_averages_base_pair(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_dna_averages_axis_base_pairs(config_path, system):
    step6_dna_averages_axis_base_pairs(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_dna_averages_grooves(config_path, system):
    step7_dna_averages_grooves(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_puckering(config_path, system):
    step8_puckering(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_canonicalag(config_path, system):
    step9_canonicalag(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_bipopulations(config_path, system):
    step10_bipopulations(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_dna_timeseries_base_pair_step(config_path, system):
    step12_dna_timeseries_base_pair_step(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step13_dna_timeseries_base_pair(config_path, system):
    step13_dna_timeseries_base_pair(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step14_dna_timeseries_axis_base_pairs(config_path, system):
    step14_dna_timeseries_axis_base_pairs(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step15_dna_timeseries_grooves(config_path, system):
    step15_dna_timeseries_grooves(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step16_dna_timeseries_backbone_torsions(config_path, system):
    step16_dna_timeseries_backbone_torsions(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step18_basepair_stiffness(config_path, system):
    step18_basepair_stiffness(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step19_dna_bimodality(config_path, system):
    step19_dna_bimodality(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step20_intraseqcorr(config_path, system):
    step20_intraseqcorr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step21_interseqcorr(config_path, system):
    step21_interseqcorr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step22_intrahpcorr(config_path, system):
    step22_intrahpcorr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step23_interhpcorr(config_path, system):
    step23_interhpcorr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step24_intrabpcorr(config_path, system):
    step24_intrabpcorr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step25_interbpcorr(config_path, remove_flag, system):
    step25_interbpcorr(config_path, remove_flag, system)
