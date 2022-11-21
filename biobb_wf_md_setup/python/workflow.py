#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_chemistry.ambertools.reduce_remove_hydrogens import reduce_remove_hydrogens
from biobb_structure_utils.utils.extract_molecule import extract_molecule
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_model.model.fix_side_chain import fix_side_chain
from biobb_gromacs.gromacs.pdb2gmx import pdb2gmx
from biobb_gromacs.gromacs.editconf import editconf
from biobb_gromacs.gromacs.solvate import solvate
from biobb_gromacs.gromacs.grompp import grompp
from biobb_gromacs.gromacs.genion import genion
from biobb_gromacs.gromacs.mdrun import mdrun
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_analysis.gromacs.gmx_energy import gmx_energy
from biobb_analysis.gromacs.gmx_rgyr import gmx_rgyr
from biobb_analysis.gromacs.gmx_trjconv_str import gmx_trjconv_str
from biobb_analysis.gromacs.gmx_image import gmx_image
from biobb_analysis.gromacs.gmx_rms import gmx_rms

def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step0_reduce_remove_hydrogens: Removing Hydrogens")
    reduce_remove_hydrogens(**global_paths["step0_reduce_remove_hydrogens"], properties=global_prop["step0_reduce_remove_hydrogens"])

    global_log.info("step1_extract_molecule: Extracting Protein")
    extract_molecule(**global_paths["step1_extract_molecule"], properties=global_prop["step1_extract_molecule"])

    global_log.info("step00_cat_pdb: Concatenating protein with included ions")
    cat_pdb(**global_paths["step00_cat_pdb"], properties=global_prop["step00_cat_pdb"])

    global_log.info("step2_fix_side_chain: Modeling the missing heavy atoms in the structure side chains")
    fix_side_chain(**global_paths["step2_fix_side_chain"], properties=global_prop["step2_fix_side_chain"])

    global_log.info("step4_pdb2gmx: Generate the topology")
    pdb2gmx(**global_paths["step4_pdb2gmx"], properties=global_prop["step4_pdb2gmx"])

    global_log.info("step5_editconf: Create the solvent box")
    editconf(**global_paths["step5_editconf"], properties=global_prop["step5_editconf"])

    global_log.info("step6_solvate: Fill the solvent box with water molecules")
    solvate(**global_paths["step6_solvate"], properties=global_prop["step6_solvate"])

    global_log.info("step7_grompp_genion: Preprocess ion generation")
    grompp(**global_paths["step7_grompp_genion"], properties=global_prop["step7_grompp_genion"])

    global_log.info("step8_genion: Ion generation")
    genion(**global_paths["step8_genion"], properties=global_prop["step8_genion"])

    global_log.info("step9_grompp_min: Preprocess energy minimization")
    grompp(**global_paths["step9_grompp_min"], properties=global_prop["step9_grompp_min"])

    global_log.info("step10_mdrun_min: Execute energy minimization")
    mdrun(**global_paths["step10_mdrun_min"], properties=global_prop["step10_mdrun_min"])

    global_log.info("step100_make_ndx: Creating an index file for the whole system")
    make_ndx(**global_paths["step100_make_ndx"], properties=global_prop["step100_make_ndx"])

    global_log.info("step11_grompp_nvt: Preprocess system temperature equilibration")
    grompp(**global_paths["step11_grompp_nvt"], properties=global_prop["step11_grompp_nvt"])

    global_log.info("step12_mdrun_nvt: Execute system temperature equilibration")
    mdrun(**global_paths["step12_mdrun_nvt"], properties=global_prop["step12_mdrun_nvt"])

    global_log.info("step13_grompp_npt: Preprocess system pressure equilibration")
    grompp(**global_paths["step13_grompp_npt"], properties=global_prop["step13_grompp_npt"])

    global_log.info("step14_mdrun_npt: Execute system pressure equilibration")
    mdrun(**global_paths["step14_mdrun_npt"], properties=global_prop["step14_mdrun_npt"])

    global_log.info("step15_grompp_md: Preprocess free dynamics")
    grompp(**global_paths["step15_grompp_md"], properties=global_prop["step15_grompp_md"])

    global_log.info("step16_mdrun_md: Execute free molecular dynamics simulation")
    mdrun(**global_paths["step16_mdrun_md"], properties=global_prop["step16_mdrun_md"])

    global_log.info("step17_gmx_image1: Image Trajectory, step1, moving ligand to center of the water box")
    gmx_image(**global_paths["step17_gmx_image1"], properties=global_prop["step17_gmx_image1"])

    global_log.info("step18_gmx_image2: Image Trajectory, step2, removing rotation")
    gmx_image(**global_paths["step18_gmx_image2"], properties=global_prop["step18_gmx_image2"])

    global_log.info("step19_gmx_trjconv_str: Convert final structure from GRO to PDB")
    gmx_trjconv_str(**global_paths["step19_gmx_trjconv_str"], properties=global_prop["step19_gmx_trjconv_str"])

    global_log.info("step20_gmx_energy: Generate energy plot from minimization/equilibration")
    gmx_energy(**global_paths["step20_gmx_energy"], properties=global_prop["step20_gmx_energy"])

    global_log.info("step21_gmx_rgyr: Generate Radius of Gyration plot for the resulting setup trajectory from the free md step")
    gmx_rgyr(**global_paths["step21_gmx_rgyr"], properties=global_prop["step21_gmx_rgyr"])

    global_log.info("step22_rmsd_first: Generate RMSd (against 1st snp.) plot for the resulting setup trajectory from the free md step")
    gmx_rms(**global_paths["step22_rmsd_first"], properties=global_prop["step22_rmsd_first"])

    global_log.info("step23_rmsd_exp: Generate RMSd (against exp.) plot for the resulting setup trajectory from the free md step")
    gmx_rms(**global_paths["step23_rmsd_exp"], properties=global_prop["step23_rmsd_exp"])

    if conf.properties['run_md']:
        global_log.info("step24_grompp_md: Preprocess long MD simulation after setup")
        grompp(**global_paths["step24_grompp_md"], properties=global_prop["step24_grompp_md"])

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
