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
from biobb_gromacs.gromacs.make_ndx import make_ndx
from biobb_gromacs.gromacs.genrestr import genrestr
from biobb_analysis.gromacs.gmx_trjconv_str import gmx_trjconv_str
from biobb_structure_utils.utils.cat_pdb import cat_pdb
from biobb_gromacs.gromacs_extra.append_ligand import append_ligand
from biobb_gromacs.gromacs.editconf import editconf
from biobb_gromacs.gromacs.solvate import solvate
from biobb_gromacs.gromacs.grompp import grompp
from biobb_gromacs.gromacs.genion import genion
from biobb_gromacs.gromacs.mdrun import mdrun
from biobb_analysis.gromacs.gmx_energy import gmx_energy
from biobb_analysis.gromacs.gmx_rms import gmx_rms
from biobb_analysis.gromacs.gmx_rgyr import gmx_rgyr
from biobb_analysis.gromacs.gmx_image import gmx_image


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step0_reduce_remove_hydrogens: Removing Hydrogens")
    reduce_remove_hydrogens(**global_paths["step0_reduce_remove_hydrogens"], properties=global_prop["step0_reduce_remove_hydrogens"])

    global_log.info("step2_extract_molecule: Extracting Protein")
    extract_molecule(**global_paths["step2_extract_molecule"], properties=global_prop["step2_extract_molecule"])

    global_log.info("step00_cat_pdb: Concatenating protein with included ions")
    cat_pdb(**global_paths["step00_cat_pdb"], properties=global_prop["step00_cat_pdb"])

    global_log.info("step4_fix_side_chain: Fix protein structure")
    fix_side_chain(**global_paths["step4_fix_side_chain"], properties=global_prop["step4_fix_side_chain"])

    global_log.info("step5_pdb2gmx: Create protein system topology")
    pdb2gmx(**global_paths["step5_pdb2gmx"], properties=global_prop["step5_pdb2gmx"])
    
    global_log.info("step9_make_ndx: Creating an index file for the small molecule heavy atoms")
    make_ndx(**global_paths["step9_make_ndx"], properties=global_prop["step9_make_ndx"])

    global_log.info("step10_genrestr: Generating the position restraints file")
    genrestr(**global_paths["step10_genrestr"], properties=global_prop["step10_genrestr"])

    global_log.info("step11_gmx_trjconv_str_protein: Convert gro (with hydrogens) to pdb (protein)")
    gmx_trjconv_str(**global_paths["step11_gmx_trjconv_str_protein"], properties=global_prop["step11_gmx_trjconv_str_protein"])

    global_log.info("step12_gmx_trjconv_str_ligand: Convert gro (with hydrogens) to pdb (ligand)")
    gmx_trjconv_str(**global_paths["step12_gmx_trjconv_str_ligand"], properties=global_prop["step12_gmx_trjconv_str_ligand"])

    global_log.info("step13_cat_pdb_hydrogens: Create new protein-ligand complex structure file")
    cat_pdb(**global_paths["step13_cat_pdb_hydrogens"], properties=global_prop["step13_cat_pdb_hydrogens"])

    global_log.info("step14_append_ligand: Create new protein-ligand complex topology file")
    append_ligand(**global_paths["step14_append_ligand"], properties=global_prop["step14_append_ligand"])

    global_log.info("step15_editconf: Create solvent box")
    editconf(**global_paths["step15_editconf"], properties=global_prop["step15_editconf"])

    global_log.info("step16_solvate: Fill the box with water molecules")
    solvate(**global_paths["step16_solvate"], properties=global_prop["step16_solvate"])

    global_log.info("step17_grompp_genion: Creating portable binary run file for ion generation")
    grompp(**global_paths["step17_grompp_genion"], properties=global_prop["step17_grompp_genion"])

    global_log.info("step18_genion: Adding ions to neutralize the system and reach a 0.05 molar concentration")
    genion(**global_paths["step18_genion"], properties=global_prop["step18_genion"])

    global_log.info("step19_grompp_min: Creating portable binary run file for energy minimization")
    grompp(**global_paths["step19_grompp_min"], properties=global_prop["step19_grompp_min"])

    global_log.info("step20_mdrun_min: Running Energy Minimization")
    mdrun(**global_paths["step20_mdrun_min"], properties=global_prop["step20_mdrun_min"])

    global_log.info("step21_gmx_energy_min: Checking Energy Minimization results")
    gmx_energy(**global_paths["step21_gmx_energy_min"], properties=global_prop["step21_gmx_energy_min"])

    global_log.info("step22_make_ndx: Creating an index file with a new group including the protein-ligand complex")
    make_ndx(**global_paths["step22_make_ndx"], properties=global_prop["step22_make_ndx"])

    global_log.info("step23_grompp_nvt: Creating portable binary run file for system equilibration (NVT)")
    grompp(**global_paths["step23_grompp_nvt"], properties=global_prop["step23_grompp_nvt"])

    global_log.info("step24_mdrun_nvt: Running NVT equilibration")
    mdrun(**global_paths["step24_mdrun_nvt"], properties=global_prop["step24_mdrun_nvt"])

    global_log.info("step25_gmx_energy_nvt: Checking NVT Equilibration results")
    gmx_energy(**global_paths["step25_gmx_energy_nvt"], properties=global_prop["step25_gmx_energy_nvt"])

    global_log.info("step26_grompp_npt: Creating portable binary run file for system equilibration (NPT)")
    grompp(**global_paths["step26_grompp_npt"], properties=global_prop["step26_grompp_npt"])

    global_log.info("step27_mdrun_npt: Running NPT equilibration")
    mdrun(**global_paths["step27_mdrun_npt"], properties=global_prop["step27_mdrun_npt"])

    global_log.info("step28_gmx_energy_npt: Checking NPT Equilibration results")
    gmx_energy(**global_paths["step28_gmx_energy_npt"], properties=global_prop["step28_gmx_energy_npt"])

    global_log.info("step29_grompp_md: Creating portable binary run file to run a free MD simulation")
    grompp(**global_paths["step29_grompp_md"], properties=global_prop["step29_grompp_md"])

    global_log.info("step30_mdrun_md: Running short free MD simulation")
    mdrun(**global_paths["step30_mdrun_md"], properties=global_prop["step30_mdrun_md"])

    global_log.info("step34_gmx_image: Image Trajectory, step1, moving ligand to center of the water box")
    gmx_image(**global_paths["step34_gmx_image"], properties=global_prop["step34_gmx_image"])

    global_log.info("step34b_gmx_image2: Image Trajectory, step2, removing rotation")
    gmx_image(**global_paths["step34b_gmx_image2"], properties=global_prop["step34b_gmx_image2"])

    global_log.info("step35_gmx_trjconv_str: Generating the output dry structure")
    gmx_trjconv_str(**global_paths["step35_gmx_trjconv_str"], properties=global_prop["step35_gmx_trjconv_str"])

    global_log.info("step31_rmsd_first: Generate RMSd (against 1st snp.) plot for the resulting setup trajectory from the free md step")
    gmx_rms(**global_paths["step31_rmsd_first"], properties=global_prop["step31_rmsd_first"])

    global_log.info("step32_rmsd_exp: Generate RMSd (against exp.) plot for the resulting setup trajectory from the free md step")
    gmx_rms(**global_paths["step32_rmsd_exp"], properties=global_prop["step32_rmsd_exp"])

    global_log.info("step33_gmx_rgyr: Generate Radius of Gyration plot for the resulting setup trajectory from the free md step")
    gmx_rgyr(**global_paths["step33_gmx_rgyr"], properties=global_prop["step33_gmx_rgyr"])

    if conf.properties['run_md']:
        global_log.info("step36_grompp_md: Preprocess long MD simulation after setup")
        grompp(**global_paths["step36_grompp_md"], properties=global_prop["step36_grompp_md"])
    
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
    parser = argparse.ArgumentParser(description="Protein Ligand Complex MD Setup tutorial using BioExcel Building Blocks")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)
