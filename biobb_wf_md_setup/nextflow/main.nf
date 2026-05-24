#!/usr/bin/env nextflow

nextflow.enable.dsl=2

def loadConfig() {
    def yaml = new groovy.yaml.YamlSlurper()
    def cfg = yaml.parse(new File(params.config))
    params.workflow_dir = cfg.global_properties?.working_dir_path ?: 'workdir'
    return cfg
}

params.config = params.config ?: 'system_setup.yml'
params.input_dir = params.input_dir ?: '.'
params.workflow_dir = 'workdir'

workflow {
    main:
        def config = loadConfig()
        Channel.fromPath("${params.input_dir}/structure.pdb").set { pdb_input }
        Channel.fromPath("${params.input_dir}/ions.pdb").set { ions_input }

        step0_cfg = config.step0_reduce_remove_hydrogens 
        step0_cfg.step_name = 'step0_reduce_remove_hydrogens'

        step0 = reduce_remove_hydrogens(step0_cfg, pdb_input)

        step1_cfg = config.step1_extract_molecule
        step1_cfg.step_name = 'step1_extract_molecule'

        step1 = extract_molecule(step1_cfg, step0.path)

        step00_cfg = config.step00_cat_pdb
        step00_cfg.step_name = 'step00_cat_pdb'

        step00 = cat_pdb(step00_cfg, step1.molecule, ions_input)

        step2_cfg = config.step2_fix_side_chain
        step2_cfg.step_name = 'step2_fix_side_chain'

        step2 = fix_side_chain(step2_cfg, step00.structure)

        step4_cfg = config.step4_pdb2gmx
        step4_cfg.step_name = 'step4_pdb2gmx'

        step4 = pdb2gmx(step4_cfg, step2.pdb)

        step5_cfg = config.step5_editconf
        step5_cfg.step_name = 'step5_editconf'

        step5 = editconf(step5_cfg, step4.gro)

        step6_cfg = config.step6_solvate
        step6_cfg.step_name = 'step6_solvate'

        step6 = solvate(step6_cfg, step5.gro, step4.top)

        step7_cfg = config.step7_grompp_genion
        step7_cfg.step_name = 'step7_grompp_genion'

        step7 = grompp_genion(step7_cfg, step6.gro, step6.top)

        step8_cfg = config.step8_genion
        step8_cfg.step_name = 'step8_genion'

        step8 = genion(step8_cfg, step7.tpr, step6.top)
    
        step9_cfg = config.step9_grompp_min
        step9_cfg.step_name = 'step9_grompp_min'

        step9 = grompp_min(step9_cfg, step8.gro, step8.top)

        step10_cfg = config.step10_mdrun_min
        step10_cfg.step_name = 'step10_mdrun_min'

        step10 = mdrun_min(step10_cfg, step9.tpr)

        step100_cfg = config.step100_make_ndx
        step100_cfg.step_name = 'step100_make_ndx'

        step100 = make_ndx(step100_cfg, step10.gro)

        step11_cfg = config.step11_grompp_nvt
        step11_cfg.step_name = 'step11_grompp_nvt'

        step11 = grompp_nvt(step11_cfg, step10.gro, step8.top)

        step12_cfg = config.step12_mdrun_nvt    
        step12_cfg.step_name = 'step12_mdrun_nvt'

        step12 = mdrun_nvt(step12_cfg, step11.tpr)

        step13_cfg = config.step13_grompp_npt
        step13_cfg.step_name = 'step13_grompp_npt'

        step13 = grompp_npt(step13_cfg, step12.gro, step8.top)

        step14_cfg = config.step14_mdrun_npt    
        step14_cfg.step_name = 'step14_mdrun_npt'

        step14 = mdrun_npt(step14_cfg, step13.tpr)

        step15_cfg = config.step16_mdrun_md
        step15_cfg.step_name = 'step16_mdrun_md'

        step15 = grompp_md(step15_cfg, step14.gro, step8.top)

        step16_cfg = config.step16_mdrun_md    
        step16_cfg.step_name = 'step16_mdrun_md'

        step16 = mdrun_md(step16_cfg, step15.tpr)

        step17_cfg = config.step17_gmx_image1
        step17_cfg.step_name = 'step17_gmx_image1'

        step17 = gmx_image1(step17_cfg, step16.xtc, step8.top)

        step18_cfg = config.step18_gmx_image2
        step18_cfg.step_name = 'step18_gmx_image2'

        step18 = gmx_image2(step18_cfg, step17.traj, step8.top)

        step19_cfg = config.step19_gmx_trjconv_str
        step19_cfg.step_name = 'step19_gmx_trjconv_str'

        step19 = gmx_trjconv_str(step19_cfg, step16.gro, step9.tpr)

        step20_cfg = config.step20_gmx_energy
        step20_cfg.step_name = 'step20_gmx_energy'

        step20 = gmx_energy(step20_cfg, step16.edr)

        step21_cfg = config.step21_gmx_rgyr
        step21_cfg.step_name = 'step21_gmx_rgyr'    

        step21 = gmx_rgyr(step21_cfg, step15.tpr, step18.traj)

        step22_cfg = config.step22_rmsd_first
        step22_cfg.step_name = 'step22_rmsd_first'

        step22 = gmx_rms_first(step22_cfg, step15.tpr, step18.traj)

        step23_cfg = config.step23_rmsd_exp
        step23_cfg.step_name = 'step23_rmsd_exp'

        step23_exp = gmx_rms_exp(step23_cfg, step9.tpr, step18.traj)

        step24_cfg = config.step24_grompp_md
        step24_cfg.step_name = 'step24_grompp_md'

        step24 = grompp_free(step24_cfg, step16.gro, step8.top)  
}

include { reduce_remove_hydrogens } from './modules/biobb_chemistry/reduce_remove_hydrogens/main.nf'
include { extract_molecule } from './modules/biobb_structure_utils/extract_molecule/main.nf'
include { cat_pdb } from './modules/biobb_structure_utils/cat_pdb/main.nf'
include { fix_side_chain } from './modules/biobb_model/fix_side_chain/main.nf'
include { pdb2gmx } from './modules/biobb_gromacs/pdb2gmx/main.nf'
include { editconf } from './modules/biobb_gromacs/editconf/main.nf'
include { solvate } from './modules/biobb_gromacs/solvate/main.nf'
include { grompp as grompp_genion} from './modules/biobb_gromacs/grompp/main.nf'
include { grompp as grompp_min } from './modules/biobb_gromacs/grompp/main.nf'
include { grompp as grompp_nvt } from './modules/biobb_gromacs/grompp/main.nf'
include { grompp as grompp_npt } from './modules/biobb_gromacs/grompp/main.nf'
include { grompp as grompp_md } from './modules/biobb_gromacs/grompp/main.nf'
include { grompp as grompp_free } from './modules/biobb_gromacs/grompp/main.nf'
include { genion } from './modules/biobb_gromacs/genion/main.nf'
include { mdrun as mdrun_min } from './modules/biobb_gromacs/mdrun/main.nf'
include { mdrun as mdrun_nvt } from './modules/biobb_gromacs/mdrun/main.nf'
include { mdrun as mdrun_npt } from './modules/biobb_gromacs/mdrun/main.nf'
include { mdrun as mdrun_md } from './modules/biobb_gromacs/mdrun/main.nf'
include { make_ndx } from './modules/biobb_gromacs/make_ndx/main.nf'
include { gmx_image } from './modules/biobb_analysis/gmx_image/main.nf'
include { gmx_rms as gmx_rms_first } from './modules/biobb_analysis/gmx_rms/main.nf'
include { gmx_rms as gmx_rms_exp } from './modules/biobb_analysis/gmx_rms/main.nf'
include { gmx_image as gmx_image1 } from './modules/biobb_analysis/gmx_image/main.nf'
include { gmx_image as gmx_image2 } from './modules/biobb_analysis/gmx_image/main.nf'
include { gmx_energy } from './modules/biobb_analysis/gmx_energy/main.nf'
include { gmx_rmsf } from './modules/biobb_analysis/gmx_rmsf/main.nf'   
include { gmx_trjconv_str } from './modules/biobb_analysis/gmx_trjconv_str/main.nf'
include { gmx_rgyr } from './modules/biobb_analysis/gmx_rgyr/main.nf'