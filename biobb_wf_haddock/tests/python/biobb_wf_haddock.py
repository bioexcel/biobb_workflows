import pytest
import os
import zipfile
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_common.tools import test_fixtures as fx
from biobb_pdb_tools.pdb_tools import biobb_pdb_tidy
from biobb_pdb_tools.pdb_tools import biobb_pdb_selchain
from biobb_pdb_tools.pdb_tools import biobb_pdb_delhetatm
from biobb_pdb_tools.pdb_tools import biobb_pdb_fixinsert
from biobb_pdb_tools.pdb_tools import biobb_pdb_selaltloc
from biobb_pdb_tools.pdb_tools import biobb_pdb_keepcoord
from biobb_pdb_tools.pdb_tools import biobb_pdb_selres
from biobb_pdb_tools.pdb_tools.biobb_pdb_merge import biobb_pdb_merge
from biobb_pdb_tools.pdb_tools import biobb_pdb_reres
from biobb_pdb_tools.pdb_tools import biobb_pdb_chain
from biobb_pdb_tools.pdb_tools import biobb_pdb_chainxseg
from biobb_haddock.haddock_restraints.haddock3_passive_from_active import haddock3_passive_from_active
from biobb_haddock.haddock_restraints.haddock3_actpass_to_ambig import haddock3_actpass_to_ambig
from biobb_haddock.haddock_restraints.haddock3_restrain_bodies import haddock3_restrain_bodies
from biobb_haddock.haddock.topology import topology
# from biobb_haddock.haddock.rigid_body import rigid_body
# from biobb_haddock.haddock.capri_eval import capri_eval
# from biobb_haddock.haddock.sele_top import sele_top
# from biobb_haddock.haddock.flex_ref import flex_ref
# from biobb_haddock.haddock.em_ref import em_ref
# from biobb_haddock.haddock.clust_fcc import clust_fcc
# from biobb_haddock.haddock.sele_top_clusts import sele_top_clusts
# from biobb_haddock.haddock.contact_map import contact_map

global_work_dir = None
cwd = os.getcwd()


def pdb_tools_pipeline(inp_file, out_file, steps):
    """Helper function to concatenate calls to pdb_tools"""
    tmp_file = inp_file
    for step, props in steps:
        # Apply each step in the pipeline
        step(input_file_path=tmp_file, output_file_path=out_file, properties=props)
        tmp_file = 'tmp.pdb'
        os.rename(out_file, tmp_file)
    os.rename(tmp_file, out_file)


def step0_prepare_antibody_reduce(config, system=None):
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)

    step0_pth = os.path.join(conf.get_working_dir_path(), "step0_prepare_antibody_reduce")
    os.mkdir(step0_pth)
    os.chdir(step0_pth)
    pdb_final = {}
    for ch, sel in [('H', 120), ('L', 107)]:
        pdb_final[ch] = f'{step0_pth}/antibody_{ch}_reduced.pdb'
        steps = [
            (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True}),
            (biobb_pdb_selchain.biobb_pdb_selchain, {'chains': ch}),
            (biobb_pdb_delhetatm.biobb_pdb_delhetatm, {}),
            (biobb_pdb_fixinsert.biobb_pdb_fixinsert, {}),
            (biobb_pdb_selaltloc.biobb_pdb_selaltloc, {}),
            (biobb_pdb_keepcoord.biobb_pdb_keepcoord, {}),
            (biobb_pdb_selres.biobb_pdb_selres, {'selection': '1:'+str(sel)}),
            (biobb_pdb_tidy.biobb_pdb_tidy, {})
        ]
        pdb_tools_pipeline(os.path.join(cwd, 'antibody.pdb'), pdb_final[ch], steps)
    os.chdir(cwd)

    assert fx.not_empty(pdb_final['H'])
    assert fx.not_empty(pdb_final['L'])

    zip_file_path = f'{step0_pth}/antibody_HL.zip'
    print(zip_file_path)
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        zipf.write(pdb_final['H'], arcname='antibody_H.pdb')
        zipf.write(pdb_final['L'], arcname='antibody_L.pdb')

    assert fx.not_empty(zip_file_path)

    global global_work_dir
    global_work_dir = conf.get_working_dir_path()


def step1_biobb_pdb_merge(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    zip_file_path = os.path.join(conf.get_working_dir_path(), "step0_prepare_antibody_reduce", "antibody_HL.zip")
    paths = global_paths["step1_biobb_pdb_merge"]
    paths['input_file_path'] = zip_file_path
    biobb_pdb_merge(**paths, properties=global_prop["step1_biobb_pdb_merge"])

    assert fx.not_empty(global_paths["step1_biobb_pdb_merge"]["output_file_path"])


def step2_prepare_antibody_clean(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_paths = conf.get_paths_dic()

    step2_pth = os.path.join(conf.get_working_dir_path(), "step2_prepare_antibody_clean")
    os.mkdir(step2_pth)
    os.chdir(step2_pth)
    antibody_prep = f'{step2_pth}/antibody_clean.pdb'
    steps = [
        (biobb_pdb_reres.biobb_pdb_reres, {'number': 1}),
        (biobb_pdb_chain.biobb_pdb_chain, {'chain': 'A'}),
        (biobb_pdb_chainxseg.biobb_pdb_chainxseg, {}),
        (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True}),
    ]
    pdb_tools_pipeline(global_paths["step1_biobb_pdb_merge"]["output_file_path"], antibody_prep, steps)
    os.chdir(cwd)

    assert fx.not_empty(antibody_prep)


def step3_prepare_antigen_clean(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)

    step3_pth = os.path.join(conf.get_working_dir_path(), "step3_prepare_antigen_clean")
    os.mkdir(step3_pth)
    os.chdir(step3_pth)
    antigen_prep = f'{step3_pth}/antigen_clean.pdb'
    steps = [
        (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True}),
        (biobb_pdb_delhetatm.biobb_pdb_delhetatm, {}),
        (biobb_pdb_selaltloc.biobb_pdb_selaltloc, {}),
        (biobb_pdb_keepcoord.biobb_pdb_keepcoord, {}),
        (biobb_pdb_chain.biobb_pdb_chain, {'chain': 'B'}),
        (biobb_pdb_chainxseg.biobb_pdb_chainxseg, {}),
        (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True})
    ]
    pdb_tools_pipeline(os.path.join(cwd, 'antigen.pdb'), antigen_prep, steps)
    os.chdir(cwd)

    assert fx.not_empty(antigen_prep)


def step4_prepare_reference_structure(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)

    step4_pth = os.path.join(conf.get_working_dir_path(), "step4_prepare_reference_structure")
    os.mkdir(step4_pth)
    os.chdir(step4_pth)
    pdb_ref = {}
    for ch, sel in [('H', 120), ('L', 107)]:
        pdb_ref[ch] = f'{step4_pth}/complex_{ch}_reduced.pdb'
        steps = [
            (biobb_pdb_selchain.biobb_pdb_selchain, {'chains': ch}),
            (biobb_pdb_delhetatm.biobb_pdb_delhetatm, {}),
            (biobb_pdb_fixinsert.biobb_pdb_fixinsert, {}),
            (biobb_pdb_selaltloc.biobb_pdb_selaltloc, {}),
            (biobb_pdb_keepcoord.biobb_pdb_keepcoord, {}),
            (biobb_pdb_selres.biobb_pdb_selres, {'selection': '1:'+str(sel)}),
            (biobb_pdb_tidy.biobb_pdb_tidy, {})
        ]
        pdb_tools_pipeline(os.path.join(cwd, 'complex.pdb'), pdb_ref[ch], steps)
    os.chdir(cwd)

    assert fx.not_empty(pdb_ref['H'])
    assert fx.not_empty(pdb_ref['L'])

    zip_file_path = f'{step4_pth}/complex_HL.zip'
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        zipf.write(pdb_ref['H'], arcname='complex_H.pdb')
        zipf.write(pdb_ref['L'], arcname='complex_L.pdb')

    assert fx.not_empty(zip_file_path)


def step5_biobb_pdb_merge(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    zip_file_path = os.path.join(conf.get_working_dir_path(), "step4_prepare_reference_structure", "complex_HL.zip")
    paths = global_paths["step5_biobb_pdb_merge"]
    paths['input_file_path'] = zip_file_path
    biobb_pdb_merge(**paths, properties=global_prop["step5_biobb_pdb_merge"])

    assert fx.not_empty(global_paths["step5_biobb_pdb_merge"]["output_file_path"])


def step6_prepare_complex_antibody_clean(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_paths = conf.get_paths_dic()

    step6_pth = os.path.join(conf.get_working_dir_path(), "step6_prepare_complex_antibody_clean")
    os.mkdir(step6_pth)
    os.chdir(step6_pth)
    complex_ref_antibody = f'{step6_pth}/complex_clean_antibody_final.pdb'
    steps = [
        (biobb_pdb_reres.biobb_pdb_reres, {'number': 1}),
        (biobb_pdb_chain.biobb_pdb_chain, {'chain': 'A'}),
        (biobb_pdb_chainxseg.biobb_pdb_chainxseg, {}),
        (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True})
    ]
    pdb_tools_pipeline(global_paths["step5_biobb_pdb_merge"]['output_file_path'], complex_ref_antibody, steps)
    os.chdir(cwd)

    assert fx.not_empty(complex_ref_antibody)


def step7_prepare_complex_antigen_clean(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)

    step7_pth = os.path.join(conf.get_working_dir_path(), "step7_prepare_complex_antigen_clean")
    os.mkdir(step7_pth)
    os.chdir(step7_pth)
    complex_ref_antigen = f'{step7_pth}/complex_clean_antigen_final.pdb'
    steps = [
        (biobb_pdb_reres.biobb_pdb_reres, {'number': 1}),
        (biobb_pdb_chain.biobb_pdb_chain, {'chain': 'A'}),
        (biobb_pdb_chainxseg.biobb_pdb_chainxseg, {}),
        (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True})
    ]
    pdb_tools_pipeline(os.path.join(cwd, 'complex.pdb'), complex_ref_antigen, steps)
    os.chdir(cwd)

    assert fx.not_empty(complex_ref_antigen)


def step8_merge_heavy_light_antigen(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)

    step6_pth = os.path.join(conf.get_working_dir_path(), "step6_prepare_complex_antibody_clean")
    step7_pth = os.path.join(conf.get_working_dir_path(), "step7_prepare_complex_antigen_clean")
    step8_pth = os.path.join(conf.get_working_dir_path(), "step8_merge_heavy_light_antigen")
    os.mkdir(step8_pth)
    zip_file_path = f'{step8_pth}/complex_HL_B.zip'
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        zipf.write(f'{step6_pth}/complex_clean_antibody_final.pdb', arcname='complex_antibody.pdb')
        zipf.write(f'{step7_pth}/complex_clean_antigen_final.pdb', arcname='complex_antigen.pdb')

    assert fx.not_empty(zip_file_path)

    os.chdir(step8_pth)
    complex_prep = f'{step8_pth}/complex_clean.pdb'
    steps = [
        (biobb_pdb_merge, {}),
        (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True})
    ]
    pdb_tools_pipeline(zip_file_path, complex_prep, steps)
    os.chdir(cwd)

    assert fx.not_empty(complex_prep)


def step9_haddock3_passive_from_active(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    antigen_prep = os.path.join(conf.get_working_dir_path(), "step3_prepare_antigen_clean", "antigen_clean.pdb")
    paths = global_paths["step9_haddock3_passive_from_active"]
    paths['input_pdb_path'] = antigen_prep
    haddock3_passive_from_active(**paths, properties=global_prop["step9_haddock3_passive_from_active"])

    assert fx.not_empty(global_paths["step9_haddock3_passive_from_active"]["output_actpass_path"])


def step10_haddock3_actpass_to_ambig(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    paths = global_paths["step10_haddock3_actpass_to_ambig"]
    paths['input_actpass1_path'] = os.path.join(cwd, 'antibody_actpass.txt')
    haddock3_actpass_to_ambig(**paths, properties=global_prop["step10_haddock3_actpass_to_ambig"])

    assert fx.not_empty(global_paths["step10_haddock3_actpass_to_ambig"]["output_tbl_path"])


def step11_haddock3_restrain_bodies(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    antibody_prep = os.path.join(conf.get_working_dir_path(), "step2_prepare_antibody_clean", "antibody_clean.pdb")
    paths = global_paths["step11_haddock3_restrain_bodies"]
    paths['input_structure_path'] = antibody_prep
    haddock3_restrain_bodies(**paths, properties=global_prop["step11_haddock3_restrain_bodies"])

    assert fx.not_empty(global_paths["step11_haddock3_restrain_bodies"]["output_tbl_path"])


def step12_topology(config, system=None):
    conf = settings.ConfReader(config, system)
    conf.working_dir_path = global_work_dir
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    antibody_prep = os.path.join(conf.get_working_dir_path(), "step2_prepare_antibody_clean", "antibody_clean.pdb")
    antigen_prep = os.path.join(conf.get_working_dir_path(), "step3_prepare_antigen_clean", "antigen_clean.pdb")
    paths = global_paths["step12_topology"]
    paths['mol1_input_pdb_path'] = antibody_prep
    paths['mol2_input_pdb_path'] = antigen_prep
    topology(**paths, properties=global_prop["step12_topology"])

    assert fx.not_empty(global_paths["step12_topology"]["output_haddock_wf_data"])


@pytest.mark.parametrize("system", [None])
def test_step0_prepare_antibody_reduce(config_path, system):
    step0_prepare_antibody_reduce(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step1_biobb_pdb_merge(config_path, system):
    step1_biobb_pdb_merge(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step2_prepare_antibody_clean(config_path, system):
    step2_prepare_antibody_clean(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step3_prepare_antigen_clean(config_path, system):
    step3_prepare_antigen_clean(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step4_prepare_reference_structure(config_path, system):
    step4_prepare_reference_structure(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step5_biobb_pdb_merge(config_path, system):
    step5_biobb_pdb_merge(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step6_prepare_complex_antibody_clean(config_path, system):
    step6_prepare_complex_antibody_clean(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step7_prepare_complex_antigen_clean(config_path, system):
    step7_prepare_complex_antigen_clean(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step8_merge_heavy_light_antigen(config_path, system):
    step8_merge_heavy_light_antigen(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step9_haddock3_passive_from_active(config_path, system):
    step9_haddock3_passive_from_active(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step10_haddock3_actpass_to_ambig(config_path, system):
    step10_haddock3_actpass_to_ambig(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step11_haddock3_restrain_bodies(config_path, system):
    step11_haddock3_restrain_bodies(config_path, system)


@pytest.mark.parametrize("system", [None])
def test_step12_topology(config_path, system):
    step12_topology(config_path, system)
