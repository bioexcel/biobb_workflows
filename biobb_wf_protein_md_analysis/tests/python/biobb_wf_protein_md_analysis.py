import pytest
import glob
from pathlib import Path
import csv
from Bio.PDB.PDBParser import PDBParser
from Bio.PDB.PDBIO import PDBIO
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_analysis.ambertools.cpptraj_average import cpptraj_average
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_analysis.ambertools.cpptraj_bfactor import cpptraj_bfactor
from biobb_analysis.ambertools.cpptraj_rgyr import cpptraj_rgyr
from biobb_analysis.ambertools.cpptraj_convert import cpptraj_convert
from biobb_analysis.gromacs.gmx_cluster import gmx_cluster

global_work_dir = None


def getBfactorsList(input):
    file = open(input)
    csv_reader = csv.reader(file)
    next(csv_reader)

    bfactors = []
    for row in csv_reader:
        r = row[0].strip().split()
        bfactors.append({
            'residue': int(float(r[0])),
            'bfactor': float(r[1])
        })

    return bfactors


def saveBfactor(input, output, bfactors):
    # load input into BioPython structure
    structure = PDBParser(QUIET=True).get_structure('structure', input)

    # add B-factor to each structure atoms
    for atom in structure.get_atoms():
        res = atom.get_parent().get_id()[1]
        bf = [d for d in bfactors if d['residue'] == res][0]['bfactor']
        atom.set_bfactor(bf)

    # save the structure
    io = PDBIO()
    io.set_structure(structure)
    io.save(output)


def step1_cpptraj_average(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_average(**global_paths["step1_cpptraj_average"], properties=global_prop["step1_cpptraj_average"])

    assert fx.not_empty(global_paths["step1_cpptraj_average"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step1_cpptraj_average"]["output_cpptraj_path"], f'reference/step1_cpptraj_average/{Path(global_paths["step1_cpptraj_average"]["output_cpptraj_path"]).name}')

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step2_cpptraj_rms_first(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step2_cpptraj_rms_first"], properties=global_prop["step2_cpptraj_rms_first"])

    assert fx.not_empty(global_paths["step2_cpptraj_rms_first"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step2_cpptraj_rms_first"]["output_cpptraj_path"], f'reference/step2_cpptraj_rms_first/{Path(global_paths["step2_cpptraj_rms_first"]["output_cpptraj_path"]).name}')


def step3_cpptraj_rms_average(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_rms(**global_paths["step3_cpptraj_rms_average"], properties=global_prop["step3_cpptraj_rms_average"])

    assert fx.not_empty(global_paths["step3_cpptraj_rms_average"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step3_cpptraj_rms_average"]["output_cpptraj_path"], f'reference/step3_cpptraj_rms_average/{Path(global_paths["step3_cpptraj_rms_average"]["output_cpptraj_path"]).name}')


def step4_cpptraj_bfactor(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_bfactor(**global_paths["step4_cpptraj_bfactor"], properties=global_prop["step4_cpptraj_bfactor"])

    assert fx.not_empty(global_paths["step4_cpptraj_bfactor"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step4_cpptraj_bfactor"]["output_cpptraj_path"], f'reference/step4_cpptraj_bfactor/{Path(global_paths["step4_cpptraj_bfactor"]["output_cpptraj_path"]).name}')


def step5_cpptraj_rgyr(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_paths["step5_cpptraj_rgyr"]["input_pdb_target_path"] = global_paths["step5_cpptraj_rgyr"]["output_cpptraj_path"]
    cpptraj_rgyr(**global_paths["step5_cpptraj_rgyr"], properties=global_prop["step5_cpptraj_rgyr"])

    assert fx.not_empty(global_paths["step5_cpptraj_rgyr"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step5_cpptraj_rgyr"]["output_cpptraj_path"], f'reference/step5_cpptraj_rgyr/{Path(global_paths["step5_cpptraj_rgyr"]["output_cpptraj_path"]).name}')


def step6_cpptraj_convert(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    cpptraj_convert(**global_paths["step6_cpptraj_convert"], properties=global_prop["step6_cpptraj_convert"])

    assert fx.not_empty(global_paths["step6_cpptraj_convert"]["output_cpptraj_path"])
    assert fx.equal(global_paths["step6_cpptraj_convert"]["output_cpptraj_path"], f'reference/step6_cpptraj_convert/{Path(global_paths["step6_cpptraj_convert"]["output_cpptraj_path"]).name}')


def step7_gmx_cluster(config, remove=False, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    bfactors = getBfactorsList(global_paths["step4_cpptraj_bfactor"]["output_cpptraj_path"])
    saveBfactor(global_paths["step7_gmx_cluster"]["input_structure_path"], conf.get_working_dir_path() + "/step4_cpptraj_bfactor/output.bfactor.pdb", bfactors)

    gmx_cluster(**global_paths["step7_gmx_cluster"], properties=global_prop["step7_gmx_cluster"])

    assert fx.not_empty(global_paths["step7_gmx_cluster"]["output_pdb_path"])
    assert fx.equal(global_paths["step7_gmx_cluster"]["output_pdb_path"], f'reference/step7_gmx_cluster/{Path(global_paths["step7_gmx_cluster"]["output_pdb_path"]).name}')
    assert fx.not_empty(global_paths["step7_gmx_cluster"]["output_cluster_log_path"])
    # assert fx.equal(global_paths["step7_gmx_cluster"]["output_cluster_log_path"], f'reference/step7_gmx_cluster/{Path(global_paths["step7_gmx_cluster"]["output_cluster_log_path"]).name}')

    if remove:
        tmp_files = [conf.get_working_dir_path()]
        tmp_files.extend(glob.glob('sandbox_*'))
        fu.rm_file_list(tmp_files)


@pytest.mark.parametrize("system", [None])
def test_step1_cpptraj_average(config_path, system):
    step1_cpptraj_average(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_cpptraj_rms_first(config_path, system):
    step2_cpptraj_rms_first(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_cpptraj_rms_average(config_path, system):
    step3_cpptraj_rms_average(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_cpptraj_bfactor(config_path, system):
    step4_cpptraj_bfactor(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_cpptraj_rgyr(config_path, system):
    step5_cpptraj_rgyr(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_cpptraj_convert(config_path, system):
    step6_cpptraj_convert(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_gmx_cluster(config_path, remove_flag, system):
    step7_gmx_cluster(config_path, remove_flag, system)
