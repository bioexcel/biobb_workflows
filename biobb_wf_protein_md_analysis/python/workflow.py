#!/usr/bin/env python3

import time
import argparse
import csv
import json
import shutil
from Bio.PDB.PDBParser import PDBParser
from Bio.PDB.PDBIO import PDBIO
from biobb_common.configuration import settings
from biobb_common.tools import file_utils as fu
from biobb_analysis.ambertools.cpptraj_average import cpptraj_average
from biobb_analysis.ambertools.cpptraj_rms import cpptraj_rms
from biobb_analysis.ambertools.cpptraj_bfactor import cpptraj_bfactor
from biobb_analysis.ambertools.cpptraj_rgyr import cpptraj_rgyr
from biobb_analysis.ambertools.cpptraj_convert import cpptraj_convert
from biobb_analysis.gromacs.gmx_cluster import gmx_cluster

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

def saveClusters(input, output):
    file = open(input)
    csv_reader = csv.reader(file)

    clusters = []
    start = False
    for row in csv_reader:

        if start: 
            col = row[0].split('|')
            if len(col[0].strip()): 
                clusters.append({
                    'cluster': col[0].strip(),
                    'population': col[1].strip().split()[0]
                })

        if len(row) and row[0].startswith('cl.'):
            start = True

    with open(output, 'w') as outfile:
        json.dump(clusters, outfile)

def main(config, system=None):
    start_time = time.time()
    conf = settings.ConfReader(config, system)
    global_log, _ = fu.get_logs(path=conf.get_working_dir_path(), light_format=True)
    global_prop = conf.get_prop_dic(global_log=global_log)
    global_paths = conf.get_paths_dic()

    global_log.info("step1_cpptraj_average: Calculating trajectory structure average")
    cpptraj_average(**global_paths["step1_cpptraj_average"], properties=global_prop["step1_cpptraj_average"])

    global_log.info("step2_cpptraj_rms_first: Generate RMSd (against 1st snp.) plot for the trajectory")
    cpptraj_rms(**global_paths["step2_cpptraj_rms_first"], properties=global_prop["step2_cpptraj_rms_first"])

    global_log.info("step3_cpptraj_rms_average: Generate RMSd (against all frames) plot for the trajectory")
    cpptraj_rms(**global_paths["step3_cpptraj_rms_average"], properties=global_prop["step3_cpptraj_rms_average"])

    global_log.info("step4_cpptraj_bfactor: Calculating trajectory Bfactor fluctuations")
    cpptraj_bfactor(**global_paths["step4_cpptraj_bfactor"], properties=global_prop["step4_cpptraj_bfactor"])

    global_log.info("  Generating B-factor pdb file")
    global_log.info("    Parsing " + global_paths["step4_cpptraj_bfactor"]["output_cpptraj_path"] + " file")
    bfactors = getBfactorsList(global_paths["step4_cpptraj_bfactor"]["output_cpptraj_path"])
    global_log.info("    Generating " + conf.get_working_dir_path() + "/step4_cpptraj_bfactor/output.bfactor.pdb" + " file")
    saveBfactor(global_paths["step7_gmx_cluster"]["input_structure_path"], conf.get_working_dir_path() + "/step4_cpptraj_bfactor/output.bfactor.pdb", bfactors)

    global_log.info("step5_cpptraj_rgyr: Generate Radius of Gyration plot for the trajectory")
    cpptraj_rgyr(**global_paths["step5_cpptraj_rgyr"], properties=global_prop["step5_cpptraj_rgyr"])

    global_log.info("step6_cpptraj_convert: Convert trajectory to GMX compatible format")
    cpptraj_convert(**global_paths["step6_cpptraj_convert"], properties=global_prop["step6_cpptraj_convert"])

    global_log.info("step7_gmx_cluster: Clustering structures from the trajectory")
    gmx_cluster(**global_paths["step7_gmx_cluster"], properties=global_prop["step7_gmx_cluster"])

    global_log.info("step7_gmx_cluster: Generating clusters JSON file")
    saveClusters("step7_gmx_cluster_cluster.log", conf.get_working_dir_path() + "/step7_gmx_cluster/clusters.json")

    # copy gmx_cluster log into step7_gmx_cluster folder
    shutil.copyfile("step7_gmx_cluster_cluster.log", conf.get_working_dir_path() + "/step7_gmx_cluster/output.cluster.log")

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
    parser = argparse.ArgumentParser(description="Protein MD Analysis pipeline using BioExcel Building Blocks")
    parser.add_argument('--config', required=True)
    parser.add_argument('--system', required=False)
    args = parser.parse_args()
    main(args.config, args.system)

