#!/usr/bin/env python3

import time
import argparse
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_structure_utils.utils.structure_check import structure_check
from biobb_structure_utils.utils.extract_model import extract_model
from biobb_structure_utils.utils.extract_chain import extract_chain
from biobb_model.model.fix_altlocs import fix_altlocs
from biobb_model.model.fix_ssbonds import fix_ssbonds
from biobb_structure_utils.utils.remove_molecules import remove_molecules
from biobb_chemistry.ambertools.reduce_remove_hydrogens import reduce_remove_hydrogens
from biobb_structure_utils.utils.remove_pdb_water import remove_pdb_water
from biobb_model.model.fix_amides import fix_amides
from biobb_model.model.fix_chirality import fix_chirality
from biobb_model.model.fix_side_chain import fix_side_chain
from biobb_model.model.fix_backbone import fix_backbone
from biobb_amber.leap.leap_gen_top import leap_gen_top
from biobb_amber.sander.sander_mdrun import sander_mdrun
from biobb_amber.ambpdb.amber_to_pdb import amber_to_pdb
from biobb_model.model.fix_pdb import fix_pdb


def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step0_structure_check_init: PDB structure checking")
    structure_check(**global_paths["step0_structure_check_init"], properties=global_prop["step0_structure_check_init"])

    global_log.info("step1_extract_model: Extract model")
    extract_model(**global_paths["step1_extract_model"], properties=global_prop["step1_extract_model"])

    global_log.info("step2_extract_chain: Extract chain")
    extract_chain(**global_paths["step2_extract_chain"], properties=global_prop["step2_extract_chain"])

    global_log.info("step3_fix_altlocs: Alternative Locations")
    fix_altlocs(**global_paths["step3_fix_altlocs"], properties=global_prop["step3_fix_altlocs"])

    global_log.info("step4_fix_ssbonds: Disulfide Bridges")
    fix_ssbonds(**global_paths["step4_fix_ssbonds"], properties=global_prop["step4_fix_ssbonds"])

    global_log.info("step5_remove_molecules_ions: Metal Ions")
    remove_molecules(**global_paths["step5_remove_molecules_ions"], properties=global_prop["step5_remove_molecules_ions"])

    global_log.info("step6_remove_molecules_ligands: Ligands")
    remove_molecules(**global_paths["step6_remove_molecules_ligands"], properties=global_prop["step6_remove_molecules_ligands"])

    global_log.info("step7_reduce_remove_hydrogens: Hydrogen atoms")
    reduce_remove_hydrogens(**global_paths["step7_reduce_remove_hydrogens"], properties=global_prop["step7_reduce_remove_hydrogens"])

    global_log.info("step8_remove_pdb_water: Water molecules")
    remove_pdb_water(**global_paths["step8_remove_pdb_water"], properties=global_prop["step8_remove_pdb_water"])

    global_log.info("step9_fix_amides: Amide groups")
    fix_amides(**global_paths["step9_fix_amides"], properties=global_prop["step9_fix_amides"])

    global_log.info("step10_fix_chirality: Chirality")
    fix_chirality(**global_paths["step10_fix_chirality"], properties=global_prop["step10_fix_chirality"])

    global_log.info("step11_fix_side_chain: Side Chains")
    fix_side_chain(**global_paths["step11_fix_side_chain"], properties=global_prop["step11_fix_side_chain"])

    global_log.info("step12_fix_backbone: Backbone")
    fix_backbone(**global_paths["step12_fix_backbone"], properties=global_prop["step12_fix_backbone"])

    global_log.info("step13_leap_gen_top: Atomic Clashes, leap_gen_top")
    leap_gen_top(**global_paths["step13_leap_gen_top"], properties=global_prop["step13_leap_gen_top"])

    global_log.info("step14_sander_mdrun: Atomic Clashes, sander_mdrun")
    sander_mdrun(**global_paths["step14_sander_mdrun"], properties=global_prop["step14_sander_mdrun"])

    global_log.info("step15_amber_to_pdb: Atomic Clashes, amber_to_pdb")
    amber_to_pdb(**global_paths["step15_amber_to_pdb"], properties=global_prop["step15_amber_to_pdb"])

    global_log.info("step16_fix_pdb: Fix PDB")
    fix_pdb(**global_paths["step16_fix_pdb"], properties=global_prop["step16_fix_pdb"])

    global_log.info("step17_structure_check: Final Check")
    structure_check(**global_paths["step17_structure_check"], properties=global_prop["step17_structure_check"])

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
