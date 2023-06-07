#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: GROMACS Protein Ligand Complex MD Setup
doc: |-
  This workflow performs a simulation setup of a protein-ligand complex system, compatible with the GROMACS MD package.
inputs:
  step0_reduce_remove_hydrogens_input_path:
    label: Input file
    doc: Path to the input file.
    type: File
  step0_reduce_remove_hydrogens_output_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step2_extract_molecule_output_molecule_path:
    label: Output file
    doc: Output molecule file path.
    type: string
  step00_cat_pdb_input_structure2:
    label: Input file
    doc: Input structure 2 file path.
    type: File
  step00_cat_pdb_output_structure_path:
    label: Output file
    doc: Output protein file path.
    type: string
  step4_fix_side_chain_output_pdb_path:
    label: Output file
    doc: Output PDB file path.
    type: string
  step5_pdb2gmx_output_gro_path:
    label: Output file
    doc: Path to the output GRO file.
    type: string
  step5_pdb2gmx_output_top_zip_path:
    label: Output file
    doc: Path the output TOP topology in zip format.
    type: string
  step5_pdb2gmx_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.pdb2gmx tool.
    type: string
  step9_make_ndx_input_structure_path:
    label: Input file
    doc: Path to the input GRO/PDB/TPR file.
    type: File
  step9_make_ndx_output_ndx_path:
    label: Output file
    doc: Path to the output index NDX file.
    type: string
  step9_make_ndx_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.make_ndx tool.
    type: string
  step10_genrestr_input_structure_path:
    label: Input file
    doc: Path to the input structure PDB, GRO or TPR format.
    type: File
  step10_genrestr_output_itp_path:
    label: Output file
    doc: Path the output ITP topology file with restrains.
    type: string
  step10_genrestr_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.genrestr tool.
    type: string
  step11_gmx_trjconv_str_protein_output_str_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step11_gmx_trjconv_str_protein_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_trjconv_str tool.
    type: string
  step12_gmx_trjconv_str_ligand_input_structure_path:
    label: Input file
    doc: Path to the input structure file.
    type: File
  step12_gmx_trjconv_str_ligand_input_top_path:
    label: Input file
    doc: Path to the GROMACS input topology file.
    type: File
  step12_gmx_trjconv_str_ligand_output_str_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step12_gmx_trjconv_str_ligand_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_trjconv_str tool.
    type: string
  step13_cat_pdb_hydrogens_output_structure_path:
    label: Output file
    doc: Output protein file path.
    type: string
  step14_append_ligand_input_itp_path:
    label: Input file
    doc: Path to the ligand ITP file to be inserted in the topology.
    type: File
  step14_append_ligand_output_top_zip_path:
    label: Output file
    doc: Path/Name the output topology TOP and ITP files zipball.
    type: string
  step14_append_ligand_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.append_ligand tool.
    type: string
  step15_editconf_output_gro_path:
    label: Output file
    doc: Path to the output GRO file.
    type: string
  step15_editconf_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.editconf tool.
    type: string
  step16_solvate_output_gro_path:
    label: Output file
    doc: Path to the output GRO file.
    type: string
  step16_solvate_output_top_zip_path:
    label: Output file
    doc: Path the output topology in zip format.
    type: string
  step17_grompp_genion_output_tpr_path:
    label: Output file
    doc: Path to the output portable binary run file TPR.
    type: string
  step17_grompp_genion_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.grompp tool.
    type: string
  step18_genion_output_gro_path:
    label: Output file
    doc: Path to the input structure GRO file.
    type: string
  step18_genion_output_top_zip_path:
    label: Output file
    doc: Path the output topology TOP and ITP files zipball.
    type: string
  step18_genion_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.genion tool.
    type: string
  step19_grompp_min_output_tpr_path:
    label: Output file
    doc: Path to the output portable binary run file TPR.
    type: string
  step19_grompp_min_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.grompp tool.
    type: string
  step20_mdrun_min_output_trr_path:
    label: Output file
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: string
  step20_mdrun_min_output_gro_path:
    label: Output file
    doc: Path to the output GROMACS structure GRO file.
    type: string
  step20_mdrun_min_output_edr_path:
    label: Output file
    doc: Path to the output GROMACS portable energy file EDR.
    type: string
  step20_mdrun_min_output_log_path:
    label: Output file
    doc: Path to the output GROMACS trajectory log file LOG.
    type: string
  step21_gmx_energy_min_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step21_gmx_energy_min_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_energy tool.
    type: string
  step22_make_ndx_output_ndx_path:
    label: Output file
    doc: Path to the output index NDX file.
    type: string
  step22_make_ndx_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.make_ndx tool.
    type: string
  step23_grompp_nvt_output_tpr_path:
    label: Output file
    doc: Path to the output portable binary run file TPR.
    type: string
  step23_grompp_nvt_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.grompp tool.
    type: string
  step24_mdrun_nvt_output_trr_path:
    label: Output file
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: string
  step24_mdrun_nvt_output_gro_path:
    label: Output file
    doc: Path to the output GROMACS structure GRO file.
    type: string
  step24_mdrun_nvt_output_edr_path:
    label: Output file
    doc: Path to the output GROMACS portable energy file EDR.
    type: string
  step24_mdrun_nvt_output_log_path:
    label: Output file
    doc: Path to the output GROMACS trajectory log file LOG.
    type: string
  step24_mdrun_nvt_output_cpt_path:
    label: Output file
    doc: Path to the output GROMACS checkpoint file CPT.
    type: string
  step25_gmx_energy_nvt_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step25_gmx_energy_nvt_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_energy tool.
    type: string
  step26_grompp_npt_output_tpr_path:
    label: Output file
    doc: Path to the output portable binary run file TPR.
    type: string
  step26_grompp_npt_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.grompp tool.
    type: string
  step27_mdrun_npt_output_trr_path:
    label: Output file
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: string
  step27_mdrun_npt_output_gro_path:
    label: Output file
    doc: Path to the output GROMACS structure GRO file.
    type: string
  step27_mdrun_npt_output_edr_path:
    label: Output file
    doc: Path to the output GROMACS portable energy file EDR.
    type: string
  step27_mdrun_npt_output_log_path:
    label: Output file
    doc: Path to the output GROMACS trajectory log file LOG.
    type: string
  step27_mdrun_npt_output_cpt_path:
    label: Output file
    doc: Path to the output GROMACS checkpoint file CPT.
    type: string
  step28_gmx_energy_npt_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step28_gmx_energy_npt_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_energy tool.
    type: string
  step29_grompp_md_output_tpr_path:
    label: Output file
    doc: Path to the output portable binary run file TPR.
    type: string
  step29_grompp_md_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.grompp tool.
    type: string
  step30_mdrun_md_output_trr_path:
    label: Output file
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: string
  step30_mdrun_md_output_gro_path:
    label: Output file
    doc: Path to the output GROMACS structure GRO file.
    type: string
  step30_mdrun_md_output_edr_path:
    label: Output file
    doc: Path to the output GROMACS portable energy file EDR.
    type: string
  step30_mdrun_md_output_log_path:
    label: Output file
    doc: Path to the output GROMACS trajectory log file LOG.
    type: string
  step30_mdrun_md_output_cpt_path:
    label: Output file
    doc: Path to the output GROMACS checkpoint file CPT.
    type: string
  step34_gmx_image_output_traj_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step34_gmx_image_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_image tool.
    type: string
  step34b_gmx_image2_output_traj_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step34b_gmx_image2_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_image tool.
    type: string
  step35_gmx_trjconv_str_output_str_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step35_gmx_trjconv_str_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_trjconv_str tool.
    type: string
  step31_rmsd_first_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step31_rmsd_first_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_rms tool.
    type: string
  step32_rmsd_exp_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step32_rmsd_exp_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_rms tool.
    type: string
  step33_gmx_rgyr_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step33_gmx_rgyr_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_rgyr tool.
    type: string
  step36_grompp_md_output_tpr_path:
    label: Output file
    doc: Path to the output portable binary run file TPR.
    type: string
  step36_grompp_md_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.grompp tool.
    type: string
outputs:
  step0_reduce_remove_hydrogens_out1:
    label: output_path
    doc: Path to the output file.
    type: File
    outputSource: step0_reduce_remove_hydrogens/output_path
  step2_extract_molecule_out1:
    label: output_molecule_path
    doc: Output molecule file path.
    type: File
    outputSource: step2_extract_molecule/output_molecule_path
  step00_cat_pdb_out1:
    label: output_structure_path
    doc: Output protein file path.
    type: File
    outputSource: step00_cat_pdb/output_structure_path
  step4_fix_side_chain_out1:
    label: output_pdb_path
    doc: Output PDB file path.
    type: File
    outputSource: step4_fix_side_chain/output_pdb_path
  step5_pdb2gmx_out1:
    label: output_gro_path
    doc: Path to the output GRO file.
    type: File
    outputSource: step5_pdb2gmx/output_gro_path
  step5_pdb2gmx_out2:
    label: output_top_zip_path
    doc: Path the output TOP topology in zip format.
    type: File
    outputSource: step5_pdb2gmx/output_top_zip_path
  step9_make_ndx_out1:
    label: output_ndx_path
    doc: Path to the output index NDX file.
    type: File
    outputSource: step9_make_ndx/output_ndx_path
  step10_genrestr_out1:
    label: output_itp_path
    doc: Path the output ITP topology file with restrains.
    type: File
    outputSource: step10_genrestr/output_itp_path
  step11_gmx_trjconv_str_protein_out1:
    label: output_str_path
    doc: Path to the output file.
    type: File
    outputSource: step11_gmx_trjconv_str_protein/output_str_path
  step12_gmx_trjconv_str_ligand_out1:
    label: output_str_path
    doc: Path to the output file.
    type: File
    outputSource: step12_gmx_trjconv_str_ligand/output_str_path
  step13_cat_pdb_hydrogens_out1:
    label: output_structure_path
    doc: Output protein file path.
    type: File
    outputSource: step13_cat_pdb_hydrogens/output_structure_path
  step14_append_ligand_out1:
    label: output_top_zip_path
    doc: Path/Name the output topology TOP and ITP files zipball.
    type: File
    outputSource: step14_append_ligand/output_top_zip_path
  step15_editconf_out1:
    label: output_gro_path
    doc: Path to the output GRO file.
    type: File
    outputSource: step15_editconf/output_gro_path
  step16_solvate_out1:
    label: output_gro_path
    doc: Path to the output GRO file.
    type: File
    outputSource: step16_solvate/output_gro_path
  step16_solvate_out2:
    label: output_top_zip_path
    doc: Path the output topology in zip format.
    type: File
    outputSource: step16_solvate/output_top_zip_path
  step17_grompp_genion_out1:
    label: output_tpr_path
    doc: Path to the output portable binary run file TPR.
    type: File
    outputSource: step17_grompp_genion/output_tpr_path
  step18_genion_out1:
    label: output_gro_path
    doc: Path to the input structure GRO file.
    type: File
    outputSource: step18_genion/output_gro_path
  step18_genion_out2:
    label: output_top_zip_path
    doc: Path the output topology TOP and ITP files zipball.
    type: File
    outputSource: step18_genion/output_top_zip_path
  step19_grompp_min_out1:
    label: output_tpr_path
    doc: Path to the output portable binary run file TPR.
    type: File
    outputSource: step19_grompp_min/output_tpr_path
  step20_mdrun_min_out1:
    label: output_trr_path
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: File
    outputSource: step20_mdrun_min/output_trr_path
  step20_mdrun_min_out2:
    label: output_gro_path
    doc: Path to the output GROMACS structure GRO file.
    type: File
    outputSource: step20_mdrun_min/output_gro_path
  step20_mdrun_min_out3:
    label: output_edr_path
    doc: Path to the output GROMACS portable energy file EDR.
    type: File
    outputSource: step20_mdrun_min/output_edr_path
  step20_mdrun_min_out4:
    label: output_log_path
    doc: Path to the output GROMACS trajectory log file LOG.
    type: File
    outputSource: step20_mdrun_min/output_log_path
  step21_gmx_energy_min_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step21_gmx_energy_min/output_xvg_path
  step22_make_ndx_out1:
    label: output_ndx_path
    doc: Path to the output index NDX file.
    type: File
    outputSource: step22_make_ndx/output_ndx_path
  step23_grompp_nvt_out1:
    label: output_tpr_path
    doc: Path to the output portable binary run file TPR.
    type: File
    outputSource: step23_grompp_nvt/output_tpr_path
  step24_mdrun_nvt_out1:
    label: output_trr_path
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: File
    outputSource: step24_mdrun_nvt/output_trr_path
  step24_mdrun_nvt_out2:
    label: output_gro_path
    doc: Path to the output GROMACS structure GRO file.
    type: File
    outputSource: step24_mdrun_nvt/output_gro_path
  step24_mdrun_nvt_out3:
    label: output_edr_path
    doc: Path to the output GROMACS portable energy file EDR.
    type: File
    outputSource: step24_mdrun_nvt/output_edr_path
  step24_mdrun_nvt_out4:
    label: output_log_path
    doc: Path to the output GROMACS trajectory log file LOG.
    type: File
    outputSource: step24_mdrun_nvt/output_log_path
  step24_mdrun_nvt_out5:
    label: output_cpt_path
    doc: Path to the output GROMACS checkpoint file CPT.
    type: File
    outputSource: step24_mdrun_nvt/output_cpt_path
  step25_gmx_energy_nvt_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step25_gmx_energy_nvt/output_xvg_path
  step26_grompp_npt_out1:
    label: output_tpr_path
    doc: Path to the output portable binary run file TPR.
    type: File
    outputSource: step26_grompp_npt/output_tpr_path
  step27_mdrun_npt_out1:
    label: output_trr_path
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: File
    outputSource: step27_mdrun_npt/output_trr_path
  step27_mdrun_npt_out2:
    label: output_gro_path
    doc: Path to the output GROMACS structure GRO file.
    type: File
    outputSource: step27_mdrun_npt/output_gro_path
  step27_mdrun_npt_out3:
    label: output_edr_path
    doc: Path to the output GROMACS portable energy file EDR.
    type: File
    outputSource: step27_mdrun_npt/output_edr_path
  step27_mdrun_npt_out4:
    label: output_log_path
    doc: Path to the output GROMACS trajectory log file LOG.
    type: File
    outputSource: step27_mdrun_npt/output_log_path
  step27_mdrun_npt_out5:
    label: output_cpt_path
    doc: Path to the output GROMACS checkpoint file CPT.
    type: File
    outputSource: step27_mdrun_npt/output_cpt_path
  step28_gmx_energy_npt_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step28_gmx_energy_npt/output_xvg_path
  step29_grompp_md_out1:
    label: output_tpr_path
    doc: Path to the output portable binary run file TPR.
    type: File
    outputSource: step29_grompp_md/output_tpr_path
  step30_mdrun_md_out1:
    label: output_trr_path
    doc: Path to the GROMACS uncompressed raw trajectory file TRR.
    type: File
    outputSource: step30_mdrun_md/output_trr_path
  step30_mdrun_md_out2:
    label: output_gro_path
    doc: Path to the output GROMACS structure GRO file.
    type: File
    outputSource: step30_mdrun_md/output_gro_path
  step30_mdrun_md_out3:
    label: output_edr_path
    doc: Path to the output GROMACS portable energy file EDR.
    type: File
    outputSource: step30_mdrun_md/output_edr_path
  step30_mdrun_md_out4:
    label: output_log_path
    doc: Path to the output GROMACS trajectory log file LOG.
    type: File
    outputSource: step30_mdrun_md/output_log_path
  step30_mdrun_md_out5:
    label: output_cpt_path
    doc: Path to the output GROMACS checkpoint file CPT.
    type: File
    outputSource: step30_mdrun_md/output_cpt_path
  step34_gmx_image_out1:
    label: output_traj_path
    doc: Path to the output file.
    type: File
    outputSource: step34_gmx_image/output_traj_path
  step34b_gmx_image2_out1:
    label: output_traj_path
    doc: Path to the output file.
    type: File
    outputSource: step34b_gmx_image2/output_traj_path
  step35_gmx_trjconv_str_out1:
    label: output_str_path
    doc: Path to the output file.
    type: File
    outputSource: step35_gmx_trjconv_str/output_str_path
  step31_rmsd_first_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step31_rmsd_first/output_xvg_path
  step32_rmsd_exp_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step32_rmsd_exp/output_xvg_path
  step33_gmx_rgyr_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step33_gmx_rgyr/output_xvg_path
  step36_grompp_md_out1:
    label: output_tpr_path
    doc: Path to the output portable binary run file TPR.
    type: File
    outputSource: step36_grompp_md/output_tpr_path
steps:
  step0_reduce_remove_hydrogens:
    label: reduce_remove_hydrogens
    doc: Removes hydrogen atoms to small molecules.
    run: biobb_adapters/reduce_remove_hydrogens.cwl
    in:
      input_path: step0_reduce_remove_hydrogens_input_path
      output_path: step0_reduce_remove_hydrogens_output_path
    out:
    - output_path
  step2_extract_molecule:
    label: extract_molecule
    doc: This class is a wrapper of the Structure Checking tool to extract a molecule from a 3D structure.
    run: biobb_adapters/extract_molecule.cwl
    in:
      input_structure_path: step0_reduce_remove_hydrogens/output_path
      output_molecule_path: step2_extract_molecule_output_molecule_path
    out:
    - output_molecule_path
  step00_cat_pdb:
    label: cat_pdb
    doc: Class to concat two PDB structures in a single PDB file.
    run: biobb_adapters/cat_pdb.cwl
    in:
      input_structure1: step2_extract_molecule/output_molecule_path
      input_structure2: step00_cat_pdb_input_structure2
      output_structure_path: step00_cat_pdb_output_structure_path
    out:
    - output_structure_path
  step4_fix_side_chain:
    label: fix_side_chain
    doc: Reconstructs the missing side chains and heavy atoms of the given PDB file.
    run: biobb_adapters/fix_side_chain.cwl
    in:
      input_pdb_path: step00_cat_pdb/output_structure_path
      output_pdb_path: step4_fix_side_chain_output_pdb_path
    out:
    - output_pdb_path
  step5_pdb2gmx:
    label: pdb2gmx
    doc: Creates a compressed (ZIP) GROMACS topology (TOP and ITP files) from a given PDB file.
    run: biobb_adapters/pdb2gmx.cwl
    in:
      config: step5_pdb2gmx_config
      input_pdb_path: step4_fix_side_chain/output_pdb_path
      output_gro_path: step5_pdb2gmx_output_gro_path
      output_top_zip_path: step5_pdb2gmx_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path
  step9_make_ndx:
    label: make_ndx
    doc: Creates a GROMACS index file (NDX) from an input selection and an input GROMACS structure file.
    run: biobb_adapters/make_ndx.cwl
    in:
      config: step9_make_ndx_config
      input_structure_path: step9_make_ndx_input_structure_path
      output_ndx_path: step9_make_ndx_output_ndx_path
    out:
    - output_ndx_path
  step10_genrestr:
    label: genrestr
    doc: Creates a new GROMACS compressed topology applying the indicated force restrains to the given input compressed topology.
    run: biobb_adapters/genrestr.cwl
    in:
      config: step10_genrestr_config
      input_structure_path: step10_genrestr_input_structure_path
      input_ndx_path: step9_make_ndx/output_ndx_path
      output_itp_path: step10_genrestr_output_itp_path
    out:
    - output_itp_path
  step11_gmx_trjconv_str_protein:
    label: gmx_trjconv_str
    doc: Wrapper of the GROMACS trjconv module for converting between GROMACS compatible structure file formats and/or extracting a selection of atoms.
    run: biobb_adapters/gmx_trjconv_str.cwl
    in:
      config: step11_gmx_trjconv_str_protein_config
      input_structure_path: step5_pdb2gmx/output_gro_path
      input_top_path: step5_pdb2gmx/output_gro_path
      output_str_path: step11_gmx_trjconv_str_protein_output_str_path
    out:
    - output_str_path
  step12_gmx_trjconv_str_ligand:
    label: gmx_trjconv_str
    doc: Wrapper of the GROMACS trjconv module for converting between GROMACS compatible structure file formats and/or extracting a selection of atoms.
    run: biobb_adapters/gmx_trjconv_str.cwl
    in:
      config: step12_gmx_trjconv_str_ligand_config
      input_structure_path: step12_gmx_trjconv_str_ligand_input_structure_path
      input_top_path: step12_gmx_trjconv_str_ligand_input_top_path
      output_str_path: step12_gmx_trjconv_str_ligand_output_str_path
    out:
    - output_str_path
  step13_cat_pdb_hydrogens:
    label: cat_pdb
    doc: Class to concat two PDB structures in a single PDB file.
    run: biobb_adapters/cat_pdb.cwl
    in:
      input_structure1: step11_gmx_trjconv_str_protein/output_str_path
      input_structure2: step12_gmx_trjconv_str_ligand/output_str_path
      output_structure_path: step13_cat_pdb_hydrogens_output_structure_path
    out:
    - output_structure_path
  step14_append_ligand:
    label: append_ligand
    doc: Takes a ligand ITP file and inserts it in a topology.
    run: biobb_adapters/append_ligand.cwl
    in:
      config: step14_append_ligand_config
      input_top_zip_path: step5_pdb2gmx/output_top_zip_path
      input_posres_itp_path: step10_genrestr/output_itp_path
      input_itp_path: step14_append_ligand_input_itp_path
      output_top_zip_path: step14_append_ligand_output_top_zip_path
    out:
    - output_top_zip_path
  step15_editconf:
    label: editconf
    doc: Creates a GROMACS structure file (GRO) adding the information of the solvent box to the input structure file.
    run: biobb_adapters/editconf.cwl
    in:
      config: step15_editconf_config
      input_gro_path: step13_cat_pdb_hydrogens/output_structure_path
      output_gro_path: step15_editconf_output_gro_path
    out:
    - output_gro_path
  step16_solvate:
    label: solvate
    doc: Creates a new compressed GROMACS topology file adding solvent molecules to a given input compressed GROMACS topology file.
    run: biobb_adapters/solvate.cwl
    in:
      input_solute_gro_path: step15_editconf/output_gro_path
      output_gro_path: step16_solvate_output_gro_path
      input_top_zip_path: step14_append_ligand/output_top_zip_path
      output_top_zip_path: step16_solvate_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path
  step17_grompp_genion:
    label: grompp
    doc: Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run: biobb_adapters/grompp.cwl
    in:
      config: step17_grompp_genion_config
      input_gro_path: step16_solvate/output_gro_path
      input_top_zip_path: step16_solvate/output_top_zip_path
      output_tpr_path: step17_grompp_genion_output_tpr_path
    out:
    - output_tpr_path
  step18_genion:
    label: genion
    doc: 'Creates a new compressed GROMACS topology adding ions until reaching the desired concentration to the input compressed GROMACS topology. '
    run: biobb_adapters/genion.cwl
    in:
      config: step18_genion_config
      input_tpr_path: step17_grompp_genion/output_tpr_path
      output_gro_path: step18_genion_output_gro_path
      input_top_zip_path: step16_solvate/output_top_zip_path
      output_top_zip_path: step18_genion_output_top_zip_path
    out:
    - output_gro_path
    - output_top_zip_path
  step19_grompp_min:
    label: grompp
    doc: Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run: biobb_adapters/grompp.cwl
    in:
      config: step19_grompp_min_config
      input_gro_path: step18_genion/output_gro_path
      input_top_zip_path: step18_genion/output_top_zip_path
      output_tpr_path: step19_grompp_min_output_tpr_path
    out:
    - output_tpr_path
  step20_mdrun_min:
    label: mdrun
    doc: Performs molecular dynamics simulations from an input GROMACS TPR file.
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step19_grompp_min/output_tpr_path
      output_trr_path: step20_mdrun_min_output_trr_path
      output_gro_path: step20_mdrun_min_output_gro_path
      output_edr_path: step20_mdrun_min_output_edr_path
      output_log_path: step20_mdrun_min_output_log_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path
  step21_gmx_energy_min:
    label: gmx_energy
    doc: Wrapper of the GROMACS energy module for extracting energy components from a given GROMACS energy file.
    run: biobb_adapters/gmx_energy.cwl
    in:
      config: step21_gmx_energy_min_config
      input_energy_path: step20_mdrun_min/output_edr_path
      output_xvg_path: step21_gmx_energy_min_output_xvg_path
    out:
    - output_xvg_path
  step22_make_ndx:
    label: make_ndx
    doc: Creates a GROMACS index file (NDX) from an input selection and an input GROMACS structure file.
    run: biobb_adapters/make_ndx.cwl
    in:
      config: step22_make_ndx_config
      input_structure_path: step20_mdrun_min/output_gro_path
      output_ndx_path: step22_make_ndx_output_ndx_path
    out:
    - output_ndx_path
  step23_grompp_nvt:
    label: grompp
    doc: Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run: biobb_adapters/grompp.cwl
    in:
      config: step23_grompp_nvt_config
      input_gro_path: step20_mdrun_min/output_gro_path
      input_top_zip_path: step18_genion/output_top_zip_path
      input_ndx_path: step22_make_ndx/output_ndx_path
      output_tpr_path: step23_grompp_nvt_output_tpr_path
    out:
    - output_tpr_path
  step24_mdrun_nvt:
    label: mdrun
    doc: Performs molecular dynamics simulations from an input GROMACS TPR file.
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step23_grompp_nvt/output_tpr_path
      output_trr_path: step24_mdrun_nvt_output_trr_path
      output_gro_path: step24_mdrun_nvt_output_gro_path
      output_edr_path: step24_mdrun_nvt_output_edr_path
      output_log_path: step24_mdrun_nvt_output_log_path
      output_cpt_path: step24_mdrun_nvt_output_cpt_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path
    - output_cpt_path
  step25_gmx_energy_nvt:
    label: gmx_energy
    doc: Wrapper of the GROMACS energy module for extracting energy components from a given GROMACS energy file.
    run: biobb_adapters/gmx_energy.cwl
    in:
      config: step25_gmx_energy_nvt_config
      input_energy_path: step24_mdrun_nvt/output_edr_path
      output_xvg_path: step25_gmx_energy_nvt_output_xvg_path
    out:
    - output_xvg_path
  step26_grompp_npt:
    label: grompp
    doc: Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run: biobb_adapters/grompp.cwl
    in:
      config: step26_grompp_npt_config
      input_gro_path: step24_mdrun_nvt/output_gro_path
      input_top_zip_path: step18_genion/output_top_zip_path
      input_ndx_path: step22_make_ndx/output_ndx_path
      output_tpr_path: step26_grompp_npt_output_tpr_path
      input_cpt_path: step24_mdrun_nvt/output_cpt_path
    out:
    - output_tpr_path
  step27_mdrun_npt:
    label: mdrun
    doc: Performs molecular dynamics simulations from an input GROMACS TPR file.
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step26_grompp_npt/output_tpr_path
      output_trr_path: step27_mdrun_npt_output_trr_path
      output_gro_path: step27_mdrun_npt_output_gro_path
      output_edr_path: step27_mdrun_npt_output_edr_path
      output_log_path: step27_mdrun_npt_output_log_path
      output_cpt_path: step27_mdrun_npt_output_cpt_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path
    - output_cpt_path
  step28_gmx_energy_npt:
    label: gmx_energy
    doc: Wrapper of the GROMACS energy module for extracting energy components from a given GROMACS energy file.
    run: biobb_adapters/gmx_energy.cwl
    in:
      config: step28_gmx_energy_npt_config
      input_energy_path: step27_mdrun_npt/output_edr_path
      output_xvg_path: step28_gmx_energy_npt_output_xvg_path
    out:
    - output_xvg_path
  step29_grompp_md:
    label: grompp
    doc: Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run: biobb_adapters/grompp.cwl
    in:
      config: step29_grompp_md_config
      input_gro_path: step27_mdrun_npt/output_gro_path
      input_ndx_path: step22_make_ndx/output_ndx_path
      input_top_zip_path: step18_genion/output_top_zip_path
      output_tpr_path: step29_grompp_md_output_tpr_path
      input_cpt_path: step27_mdrun_npt/output_cpt_path
    out:
    - output_tpr_path
  step30_mdrun_md:
    label: mdrun
    doc: Performs molecular dynamics simulations from an input GROMACS TPR file.
    run: biobb_adapters/mdrun.cwl
    in:
      input_tpr_path: step29_grompp_md/output_tpr_path
      output_trr_path: step30_mdrun_md_output_trr_path
      output_gro_path: step30_mdrun_md_output_gro_path
      output_edr_path: step30_mdrun_md_output_edr_path
      output_log_path: step30_mdrun_md_output_log_path
      output_cpt_path: step30_mdrun_md_output_cpt_path
    out:
    - output_trr_path
    - output_gro_path
    - output_edr_path
    - output_log_path
    - output_cpt_path
  step34_gmx_image:
    label: gmx_image
    doc: Wrapper of the GROMACS trjconv module for correcting periodicity (image) from a given GROMACS compatible trajectory file.
    run: biobb_adapters/gmx_image.cwl
    in:
      config: step34_gmx_image_config
      input_traj_path: step30_mdrun_md/output_trr_path
      input_top_path: step19_grompp_min/output_tpr_path
      input_index_path: step22_make_ndx/output_ndx_path
      output_traj_path: step34_gmx_image_output_traj_path
    out:
    - output_traj_path
  step34b_gmx_image2:
    label: gmx_image
    doc: Wrapper of the GROMACS trjconv module for correcting periodicity (image) from a given GROMACS compatible trajectory file.
    run: biobb_adapters/gmx_image.cwl
    in:
      config: step34b_gmx_image2_config
      input_traj_path: step34_gmx_image/output_traj_path
      input_top_path: step19_grompp_min/output_tpr_path
      input_index_path: step22_make_ndx/output_ndx_path
      output_traj_path: step34b_gmx_image2_output_traj_path
    out:
    - output_traj_path
  step35_gmx_trjconv_str:
    label: gmx_trjconv_str
    doc: Wrapper of the GROMACS trjconv module for converting between GROMACS compatible structure file formats and/or extracting a selection of atoms.
    run: biobb_adapters/gmx_trjconv_str.cwl
    in:
      config: step35_gmx_trjconv_str_config
      input_structure_path: step30_mdrun_md/output_gro_path
      input_top_path: step19_grompp_min/output_tpr_path
      input_index_path: step22_make_ndx/output_ndx_path
      output_str_path: step35_gmx_trjconv_str_output_str_path
    out:
    - output_str_path
  step31_rmsd_first:
    label: gmx_rms
    doc: Wrapper of the GROMACS module for calculating the Root Mean Square deviation (RMSd) of a given GROMACS compatible trajectory.
    run: biobb_adapters/gmx_rms.cwl
    in:
      config: step31_rmsd_first_config
      input_structure_path: step29_grompp_md/output_tpr_path
      input_traj_path: step34b_gmx_image2/output_traj_path
      input_index_path: step22_make_ndx/output_ndx_path
      output_xvg_path: step31_rmsd_first_output_xvg_path
    out:
    - output_xvg_path
  step32_rmsd_exp:
    label: gmx_rms
    doc: Wrapper of the GROMACS module for calculating the Root Mean Square deviation (RMSd) of a given GROMACS compatible trajectory.
    run: biobb_adapters/gmx_rms.cwl
    in:
      config: step32_rmsd_exp_config
      input_structure_path: step19_grompp_min/output_tpr_path
      input_traj_path: step34b_gmx_image2/output_traj_path
      input_index_path: step22_make_ndx/output_ndx_path
      output_xvg_path: step32_rmsd_exp_output_xvg_path
    out:
    - output_xvg_path
  step33_gmx_rgyr:
    label: gmx_rgyr
    doc: Wrapper of the GROMACS gyrate module for computing the radius of gyration (Rgyr) of a molecule about the x-, y- and z-axes, as a function of time, from a given GROMACS compatible trajectory.
    run: biobb_adapters/gmx_rgyr.cwl
    in:
      config: step33_gmx_rgyr_config
      input_structure_path: step29_grompp_md/output_tpr_path
      input_traj_path: step34b_gmx_image2/output_traj_path
      input_index_path: step22_make_ndx/output_ndx_path
      output_xvg_path: step33_gmx_rgyr_output_xvg_path
    out:
    - output_xvg_path
  step36_grompp_md:
    label: grompp
    doc: Creates a GROMACS portable binary run input file (TPR) applying the desired properties from the input compressed GROMACS topology.
    run: biobb_adapters/grompp.cwl
    in:
      config: step36_grompp_md_config
      input_gro_path: step30_mdrun_md/output_gro_path
      input_top_zip_path: step18_genion/output_top_zip_path
      output_tpr_path: step36_grompp_md_output_tpr_path
      input_cpt_path: step30_mdrun_md/output_cpt_path
    out:
    - output_tpr_path
