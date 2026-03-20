#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: Protein-Membrane MD Analysis workflow
doc: |-
  This workflow aims to illustrate the process of analyzing a membrane molecular dynamics (MD) simulation
inputs:
  step1_gmx_image1_input_traj_path:
    label: Input file
    doc: Path to the GROMACS trajectory file.
    type: File
  step1_gmx_image1_input_top_path:
    label: Input file
    doc: Path to the GROMACS input topology file.
    type: File
  step1_gmx_image1_output_traj_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step1_gmx_image1_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_image tool.
    type: string
  step2_gmx_image2_input_top_path:
    label: Input file
    doc: Path to the GROMACS input topology file.
    type: File
  step2_gmx_image2_output_traj_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step2_gmx_image2_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_image tool.
    type: string
  step3_fatslim_membranes_input_traj_path:
    label: Input file
    doc: Path to the GROMACS trajectory file.
    type: File
  step3_fatslim_membranes_input_top_path:
    label: Input file
    doc: Path to the input topology file.
    type: File
  step3_fatslim_membranes_output_ndx_path:
    label: Output file
    doc: Path to the output index NDX file.
    type: string
  step3_fatslim_membranes_config:
    label: Config file
    doc: Configuration file for biobb_mem.fatslim_membranes tool.
    type: string
  step4_lpp_assign_leaflets_input_top_path:
    label: Input file
    doc: Path to the input structure or topology file.
    type: File
  step4_lpp_assign_leaflets_output_leaflets_path:
    label: Output file
    doc: Path to the output leaflet assignments.
    type: string
  step4_lpp_assign_leaflets_config:
    label: Config file
    doc: Configuration file for biobb_mem.lpp_assign_leaflets tool.
    type: string
  step5_lpp_zpositions1_input_top_path:
    label: Input file
    doc: Path to the input structure or topology file.
    type: File
  step5_lpp_zpositions1_output_positions_path:
    label: Output file
    doc: Path to the output z positions.
    type: string
  step5_lpp_zpositions1_config:
    label: Config file
    doc: Configuration file for biobb_mem.lpp_zpositions tool.
    type: string
  step6_lpp_zpositions2_input_top_path:
    label: Input file
    doc: Path to the input structure or topology file.
    type: File
  step6_lpp_zpositions2_output_positions_path:
    label: Output file
    doc: Path to the output z positions.
    type: string
  step6_lpp_zpositions2_config:
    label: Config file
    doc: Configuration file for biobb_mem.lpp_zpositions tool.
    type: string
  step7_gorder_aa_input_traj_path:
    label: Input file
    doc: Path to the input trajectory to be processed.
    type: File
  step7_gorder_aa_input_top_path:
    label: Input file
    doc: Path to the input structure or topology file.
    type: File
  step7_gorder_aa_output_order_path:
    label: Output file
    doc: Path to results of the order analysis.
    type: string
  step7_gorder_aa_config:
    label: Config file
    doc: Configuration file for biobb_mem.gorder_aa tool.
    type: string
  step8_fatslim_apl_input_top_path:
    label: Input file
    doc: Path to the input topology file.
    type: File
  step8_fatslim_apl_output_csv_path:
    label: Output file
    doc: Path to the output CSV file.
    type: string
  step8_fatslim_apl_config:
    label: Config file
    doc: Configuration file for biobb_mem.fatslim_apl tool.
    type: string
  step9_cpptraj_density_input_top_path:
    label: Input file
    doc: Path to the input structure or topology file.
    type: File
  step9_cpptraj_density_output_cpptraj_path:
    label: Output file
    doc: Path to the output processed density analysis.
    type: string
  step9_cpptraj_density_config:
    label: Config file
    doc: Configuration file for biobb_mem.cpptraj_density tool.
    type: string
  step10_mda_hole_input_top_path:
    label: Input file
    doc: Path to the input structure or topology file.
    type: File
  step10_mda_hole_output_hole_path:
    label: Output file
    doc: Path to the output HOLE analysis results.
    type: string
  step10_mda_hole_output_csv_path:
    label: Output file
    doc: Path to the output CSV file containing the radius and coordinates of the pore.
    type: string
  step10_mda_hole_config:
    label: Config file
    doc: Configuration file for biobb_mem.mda_hole tool.
    type: string
  step11_lpp_flip_flop_input_top_path:
    label: Input file
    doc: Path to the input structure or topology file.
    type: File
  step11_lpp_flip_flop_output_flip_flop_path:
    label: Output file
    doc: Path to the output flip-flop data.
    type: string
  step11_lpp_flip_flop_config:
    label: Config file
    doc: Configuration file for biobb_mem.lpp_flip_flop tool.
    type: string
outputs:
  step1_gmx_image1_out1:
    label: output_traj_path
    doc: Path to the output file.
    type: File
    outputSource: step1_gmx_image1/output_traj_path
  step2_gmx_image2_out1:
    label: output_traj_path
    doc: Path to the output file.
    type: File
    outputSource: step2_gmx_image2/output_traj_path
  step3_fatslim_membranes_out1:
    label: output_ndx_path
    doc: Path to the output index NDX file.
    type: File
    outputSource: step3_fatslim_membranes/output_ndx_path
  step4_lpp_assign_leaflets_out1:
    label: output_leaflets_path
    doc: Path to the output leaflet assignments.
    type: File
    outputSource: step4_lpp_assign_leaflets/output_leaflets_path
  step5_lpp_zpositions1_out1:
    label: output_positions_path
    doc: Path to the output z positions.
    type: File
    outputSource: step5_lpp_zpositions1/output_positions_path
  step6_lpp_zpositions2_out1:
    label: output_positions_path
    doc: Path to the output z positions.
    type: File
    outputSource: step6_lpp_zpositions2/output_positions_path
  step7_gorder_aa_out1:
    label: output_order_path
    doc: Path to results of the order analysis.
    type: File
    outputSource: step7_gorder_aa/output_order_path
  step8_fatslim_apl_out1:
    label: output_csv_path
    doc: Path to the output CSV file.
    type: File
    outputSource: step8_fatslim_apl/output_csv_path
  step9_cpptraj_density_out1:
    label: output_cpptraj_path
    doc: Path to the output processed density analysis.
    type: File
    outputSource: step9_cpptraj_density/output_cpptraj_path
  step10_mda_hole_out1:
    label: output_hole_path
    doc: Path to the output HOLE analysis results.
    type: File
    outputSource: step10_mda_hole/output_hole_path
  step10_mda_hole_out2:
    label: output_csv_path
    doc: Path to the output CSV file containing the radius and coordinates of the pore.
    type: File
    outputSource: step10_mda_hole/output_csv_path
  step11_lpp_flip_flop_out1:
    label: output_flip_flop_path
    doc: Path to the output flip-flop data.
    type: File
    outputSource: step11_lpp_flip_flop/output_flip_flop_path
steps:
  step1_gmx_image1:
    label: gmx_image
    doc: Wrapper of the GROMACS trjconv module for correcting periodicity (image) from a given GROMACS compatible trajectory file.
    run: biobb_adapters/gmx_image.cwl
    in:
      config: step1_gmx_image1_config
      input_traj_path: step1_gmx_image1_input_traj_path
      input_top_path: step1_gmx_image1_input_top_path
      output_traj_path: step1_gmx_image1_output_traj_path
    out:
    - output_traj_path
  step2_gmx_image2:
    label: gmx_image
    doc: Wrapper of the GROMACS trjconv module for correcting periodicity (image) from a given GROMACS compatible trajectory file.
    run: biobb_adapters/gmx_image.cwl
    in:
      config: step2_gmx_image2_config
      input_traj_path: step1_gmx_image1/output_traj_path
      input_top_path: step2_gmx_image2_input_top_path
      output_traj_path: step2_gmx_image2_output_traj_path
    out:
    - output_traj_path
  step3_fatslim_membranes:
    label: fatslim_membranes
    doc: Identify membrane types and leaflets.
    run: biobb_adapters/fatslim_membranes.cwl
    in:
      config: step3_fatslim_membranes_config
      input_traj_path: step3_fatslim_membranes_input_traj_path
      input_top_path: step3_fatslim_membranes_input_top_path
      output_ndx_path: step3_fatslim_membranes_output_ndx_path
    out:
    - output_ndx_path
  step4_lpp_assign_leaflets:
    label: lpp_assign_leaflets
    doc: Assign lipids to leaflets in a bilayer.
    run: biobb_adapters/lpp_assign_leaflets.cwl
    in:
      config: step4_lpp_assign_leaflets_config
      input_traj_path: step2_gmx_image2/output_traj_path
      input_top_path: step4_lpp_assign_leaflets_input_top_path
      output_leaflets_path: step4_lpp_assign_leaflets_output_leaflets_path
    out:
    - output_leaflets_path
  step5_lpp_zpositions1:
    label: lpp_zpositions
    doc: Calculate the z distance in of lipids to the bilayer center.
    run: biobb_adapters/lpp_zpositions.cwl
    in:
      config: step5_lpp_zpositions1_config
      input_traj_path: step2_gmx_image2/output_traj_path
      input_top_path: step5_lpp_zpositions1_input_top_path
      output_positions_path: step5_lpp_zpositions1_output_positions_path
    out:
    - output_positions_path
  step6_lpp_zpositions2:
    label: lpp_zpositions
    doc: Calculate the z distance in of lipids to the bilayer center.
    run: biobb_adapters/lpp_zpositions.cwl
    in:
      config: step6_lpp_zpositions2_config
      input_traj_path: step2_gmx_image2/output_traj_path
      input_top_path: step6_lpp_zpositions2_input_top_path
      output_positions_path: step6_lpp_zpositions2_output_positions_path
    out:
    - output_positions_path
  step7_gorder_aa:
    label: gorder_aa
    doc: Compute atomistic lipid order parameters using gorder order tool.
    run: biobb_adapters/gorder_aa.cwl
    in:
      config: step7_gorder_aa_config
      input_traj_path: step7_gorder_aa_input_traj_path
      input_top_path: step7_gorder_aa_input_top_path
      output_order_path: step7_gorder_aa_output_order_path
    out:
    - output_order_path
  step8_fatslim_apl:
    label: fatslim_apl
    doc: Calculate the area per lipid.
    run: biobb_adapters/fatslim_apl.cwl
    in:
      config: step8_fatslim_apl_config
      input_traj_path: step1_gmx_image1/output_traj_path
      input_top_path: step8_fatslim_apl_input_top_path
      output_csv_path: step8_fatslim_apl_output_csv_path
    out:
    - output_csv_path
  step9_cpptraj_density:
    label: cpptraj_density
    doc: Calculates the density along an axis of a given cpptraj compatible trajectory.
    run: biobb_adapters/cpptraj_density.cwl
    in:
      config: step9_cpptraj_density_config
      input_traj_path: step2_gmx_image2/output_traj_path
      input_top_path: step9_cpptraj_density_input_top_path
      output_cpptraj_path: step9_cpptraj_density_output_cpptraj_path
    out:
    - output_cpptraj_path
  step10_mda_hole:
    label: mda_hole
    doc: Wrapper of the MDAnalysis Hole module for analyzing hole geometry in protein channels and other macromolecular structures.
    run: biobb_adapters/mda_hole.cwl
    in:
      config: step10_mda_hole_config
      input_traj_path: step2_gmx_image2/output_traj_path
      input_top_path: step10_mda_hole_input_top_path
      output_hole_path: step10_mda_hole_output_hole_path
      output_csv_path: step10_mda_hole_output_csv_path
    out:
    - output_hole_path
    - output_csv_path
  step11_lpp_flip_flop:
    label: lpp_flip_flop
    doc: Find flip-flop events in a lipid bilayer.
    run: biobb_adapters/lpp_flip_flop.cwl
    in:
      config: step11_lpp_flip_flop_config
      input_traj_path: step2_gmx_image2/output_traj_path
      input_top_path: step11_lpp_flip_flop_input_top_path
      input_leaflets_path: step4_lpp_assign_leaflets/output_leaflets_path
      output_flip_flop_path: step11_lpp_flip_flop_output_flip_flop_path
    out:
    - output_flip_flop_path
