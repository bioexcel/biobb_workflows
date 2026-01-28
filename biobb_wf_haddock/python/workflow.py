#!/usr/bin/env python3

import time
import argparse
import os
import zipfile
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
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


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    def pdb_tools_pipeline(inp_file, out_file, steps):
        """Helper function to concatenate calls to pdb_tools"""
        tmp_file = inp_file
        for step, props in steps:
            # Apply each step in the pipeline
            step(input_file_path=tmp_file, output_file_path=out_file, properties=props)
            tmp_file = 'tmp.pdb'
            os.rename(out_file, tmp_file)
        os.rename(tmp_file, out_file)

    # get cwd for coming and back after some steps
    cwd = os.getcwd()

    global_log.info("step0_prepare_antibody_reduce: Select and extract protein regions/chains")
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

    zip_file_path = f'{step0_pth}/antibody_HL.zip'
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        zipf.write(pdb_final['H'], arcname='antibody_H.pdb')
        zipf.write(pdb_final['L'], arcname='antibody_L.pdb')

    global_log.info("step1_biobb_pdb_merge: Merge regions into a single file")
    paths = global_paths["step1_biobb_pdb_merge"]
    paths['input_file_path'] = zip_file_path
    biobb_pdb_merge(**paths, properties=global_prop["step1_biobb_pdb_merge"])

    global_log.info("step2_prepare_antibody_clean: Prepare PDB file to meet HADDOCK3 requirements")
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
    pdb_tools_pipeline(paths['output_file_path'], antibody_prep, steps)
    os.chdir(cwd)

    global_log.info("step3_prepare_antigen_clean: Preparing the antigen structure")
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

    global_log.info("step4_prepare_reference_structure: Select and extract protein regions/chains")
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

    zip_file_path = f'{step4_pth}/complex_HL.zip'
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        zipf.write(pdb_ref['H'], arcname='complex_H.pdb')
        zipf.write(pdb_ref['L'], arcname='complex_L.pdb')

    global_log.info("step5_biobb_pdb_merge: Merge Heavy and Light regions (from the complex) into a single file")
    paths = global_paths["step5_biobb_pdb_merge"]
    paths['input_file_path'] = zip_file_path
    biobb_pdb_merge(**paths, properties=global_prop["step5_biobb_pdb_merge"])

    global_log.info("step6_prepare_complex_antibody_clean: Prepare the Antibody PDB file (from the complex) to match HADDOCK3 requirements")
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
    pdb_tools_pipeline(paths['output_file_path'], complex_ref_antibody, steps)
    os.chdir(cwd)

    global_log.info("step7_prepare_complex_antigen_clean: Prepare the Antigen PDB file (from the complex) to match HADDOCK3 requirements")
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

    zip_file_path = f'{step7_pth}/complex_HL_B.zip'
    with zipfile.ZipFile(zip_file_path, 'w') as zipf:
        zipf.write(f'{step6_pth}/complex_clean_antibody_final.pdb', arcname='complex_antibody.pdb')
        zipf.write(f'{step7_pth}/complex_clean_antigen_final.pdb', arcname='complex_antigen.pdb')

    global_log.info("step8_merge_heavy_light_antigen: Merge Heavy + Light regions and Antigen (from the complex) into a single file")
    step8_pth = os.path.join(conf.get_working_dir_path(), "step8_merge_heavy_light_antigen")
    os.mkdir(step8_pth)
    os.chdir(step8_pth)
    complex_prep = f'{step8_pth}/complex_clean.pdb'
    steps = [
        (biobb_pdb_merge, {}),
        (biobb_pdb_tidy.biobb_pdb_tidy, {'strict': True})
    ]
    pdb_tools_pipeline(zip_file_path, complex_prep, steps)
    os.chdir(cwd)

    global_log.info("step9_haddock3_passive_from_active: Passive restraints")
    paths = global_paths["step9_haddock3_passive_from_active"]
    paths['input_pdb_path'] = antigen_prep
    haddock3_passive_from_active(**paths, properties=global_prop["step9_haddock3_passive_from_active"])

    global_log.info("step10_haddock3_actpass_to_ambig: Passive restraints")
    paths = global_paths["step10_haddock3_actpass_to_ambig"]
    paths['input_actpass1_path'] = os.path.join(cwd, 'antibody_actpass.txt')
    haddock3_actpass_to_ambig(**paths, properties=global_prop["step10_haddock3_actpass_to_ambig"])

    global_log.info("step11_haddock3_restrain_bodies: Passive restraints")
    paths = global_paths["step11_haddock3_restrain_bodies"]
    paths['input_structure_path'] = antibody_prep
    haddock3_restrain_bodies(**paths, properties=global_prop["step11_haddock3_restrain_bodies"])

    global_log.info("step12_topology: Create topology")
    paths = global_paths["step12_topology"]
    paths['mol1_input_pdb_path'] = antibody_prep
    paths['mol2_input_pdb_path'] = antigen_prep
    topology(**paths, properties=global_prop["step12_topology"])

    # global_log.info("step13_rigid_body: Rigid body sampling")
    # rigid_body(**global_paths["step13_rigid_body"], properties=global_prop["step13_rigid_body"])

    # global_log.info("step14_capri_eval1: 1st CAPRI evaluation")
    # paths = global_paths["step14_capri_eval1"]
    # paths['reference_pdb_path'] = complex_prep
    # capri_eval(**paths, properties=global_prop["step14_capri_eval1"])

    # global_log.info("step15_sele_top: Select Top structures")
    # sele_top(**global_paths["step15_sele_top"], properties=global_prop["step15_sele_top"])

    # global_log.info("step16_flex_ref: Flexible Refinement")
    # flex_ref(**global_paths["step16_flex_ref"], properties=global_prop["step16_flex_ref"])

    # global_log.info("step17_capri_eval2: 2nd CAPRI evaluation")
    # paths = global_paths["step17_capri_eval2"]
    # paths['reference_pdb_path'] = complex_prep
    # capri_eval(**paths, properties=global_prop["step17_capri_eval2"])

    # global_log.info("step18_em_ref: Energy minimization refinement")
    # em_ref(**global_paths["step18_em_ref"], properties=global_prop["step18_em_ref"])

    # global_log.info("step19_capri_eval3: 3rd CAPRI evaluation")
    # paths = global_paths["step19_capri_eval3"]
    # paths['reference_pdb_path'] = complex_prep
    # capri_eval(**paths, properties=global_prop["step19_capri_eval3"])

    # global_log.info("step20_clust_fcc: Clustering")
    # clust_fcc(**global_paths["step20_clust_fcc"], properties=global_prop["step20_clust_fcc"])

    # global_log.info("step21_sele_top_clusts: Clustering")
    # sele_top_clusts(**global_paths["step21_sele_top_clusts"], properties=global_prop["step21_sele_top_clusts"])

    # global_log.info("step22_capri_eval4: Final CAPRI evaluation")
    # paths = global_paths["step22_capri_eval4"]
    # paths['reference_pdb_path'] = complex_prep
    # capri_eval(**paths, properties=global_prop["step22_capri_eval4"])

    # global_log.info("step23_contact_map: Contacts analysis")
    # contact_map(**global_paths["step23_contact_map"], properties=global_prop["step23_contact_map"])

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
    parser = argparse.ArgumentParser(description="Based on the official Gromacs tutorial")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
