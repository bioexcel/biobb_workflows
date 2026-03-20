#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
label: AutoEncoders for Anomaly Detection workflow 
doc: |-
  This workflow involves the use of a multilayer AutoEncoder (AE) for feature extraction and pattern recognition by analyzing Molecular Dynamic Simulations
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
  step2_mdfeaturizer1_input_topology_path:
    label: Input file
    doc: Path to the input topology file.
    type: File
  step2_mdfeaturizer1_output_dataset_pt_path:
    label: Output file
    doc: Path to the output dataset model file.
    type: string
  step2_mdfeaturizer1_output_stats_pt_path:
    label: Output file
    doc: Path to the output model statistics file.
    type: string
  step2_mdfeaturizer1_config:
    label: Config file
    doc: Configuration file for biobb_pytorch.mdfeaturizer tool.
    type: string
  step3_build_model_output_model_pth_path:
    label: Output file
    doc: Path to save the model in .pth format.
    type: string
  step3_build_model_config:
    label: Config file
    doc: Configuration file for biobb_pytorch.build_model tool.
    type: string
  step4_train_model_output_model_pth_path:
    label: Output file
    doc: Path to save the trained model (.pth). If omitted, the trained model is only available in memory.
    type: string
  step4_train_model_output_metrics_npz_path:
    label: Output file
    doc: Path save training metrics in compressed NumPy format (.npz).
    type: string
  step4_train_model_config:
    label: Config file
    doc: Configuration file for biobb_pytorch.train_model tool.
    type: string
  step5_gmx_image2_input_traj_path:
    label: Input file
    doc: Path to the GROMACS trajectory file.
    type: File
  step5_gmx_image2_input_top_path:
    label: Input file
    doc: Path to the GROMACS input topology file.
    type: File
  step5_gmx_image2_output_traj_path:
    label: Output file
    doc: Path to the output file.
    type: string
  step5_gmx_image2_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_image tool.
    type: string
  step6_mdfeaturizer2_input_topology_path:
    label: Input file
    doc: Path to the input topology file.
    type: File
  step6_mdfeaturizer2_output_dataset_pt_path:
    label: Output file
    doc: Path to the output dataset model file.
    type: string
  step6_mdfeaturizer2_output_stats_pt_path:
    label: Output file
    doc: Path to the output model statistics file.
    type: string
  step6_mdfeaturizer2_config:
    label: Config file
    doc: Configuration file for biobb_pytorch.mdfeaturizer tool.
    type: string
  step7_evaluate_model_output_results_npz_path:
    label: Output file
    doc: Path to the output evaluation results file (compressed NumPy archive).
    type: string
  step7_evaluate_model_config:
    label: Config file
    doc: Configuration file for biobb_pytorch.evaluate_model tool.
    type: string
  step8_make_ndx1_input_structure_path:
    label: Input file
    doc: Path to the input GRO/PDB/TPR file.
    type: File
  step8_make_ndx1_output_ndx_path:
    label: Output file
    doc: Path to the output index NDX file.
    type: string
  step8_make_ndx1_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.make_ndx tool.
    type: string
  step9_make_ndx2_input_structure_path:
    label: Input file
    doc: Path to the input GRO/PDB/TPR file.
    type: File
  step9_make_ndx2_output_ndx_path:
    label: Output file
    doc: Path to the output index NDX file.
    type: string
  step9_make_ndx2_config:
    label: Config file
    doc: Configuration file for biobb_gromacs.make_ndx tool.
    type: string
  step10_gmx_rmsf1_input_structure_path:
    label: Input file
    doc: Path to the input structure file.
    type: File
  step10_gmx_rmsf1_input_traj_path:
    label: Input file
    doc: Path to the GROMACS trajectory file.
    type: File
  step10_gmx_rmsf1_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step10_gmx_rmsf1_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_rmsf tool.
    type: string
  step11_gmx_rmsf2_input_structure_path:
    label: Input file
    doc: Path to the input structure file.
    type: File
  step11_gmx_rmsf2_input_traj_path:
    label: Input file
    doc: Path to the GROMACS trajectory file.
    type: File
  step11_gmx_rmsf2_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step11_gmx_rmsf2_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_rmsf tool.
    type: string
  step12_feat2traj_output_traj_path:
    label: Output file
    doc: Path to save the trajectory in xtc/pdb/dcd format.
    type: string
  step12_feat2traj_output_top_path:
    label: Output file
    doc: Path to save the output topology file (pdb). Used if trajectory format requires separate topology.
    type: string
  step13_gmx_rmsf3_output_xvg_path:
    label: Output file
    doc: Path to the XVG output file.
    type: string
  step13_gmx_rmsf3_config:
    label: Config file
    doc: Configuration file for biobb_analysis.gmx_rmsf tool.
    type: string
  step14_make_plumed_input_reference_pdb_path:
    label: Input file
    doc: Path to reference PDB used for FIT_TO_TEMPLATE actions when Cartesian features are present.
    type: File
  step14_make_plumed_output_model_ptc_path:
    label: Output file
    doc: Path to the output TorchScript model file (.ptc) for PLUMED's PYTORCH_MODEL action.
    type: string
  step14_make_plumed_output_plumed_dat_path:
    label: Output file
    doc: Path to the output PLUMED input file.
    type: string
  step14_make_plumed_output_features_dat_path:
    label: Output file
    doc: Path to the output features.dat file describing the CVs to PLUMED.
    type: string
  step14_make_plumed_config:
    label: Config file
    doc: Configuration file for biobb_pytorch.make_plumed tool.
    type: string
outputs:
  step1_gmx_image1_out1:
    label: output_traj_path
    doc: Path to the output file.
    type: File
    outputSource: step1_gmx_image1/output_traj_path
  step2_mdfeaturizer1_out1:
    label: output_dataset_pt_path
    doc: Path to the output dataset model file.
    type: File
    outputSource: step2_mdfeaturizer1/output_dataset_pt_path
  step2_mdfeaturizer1_out2:
    label: output_stats_pt_path
    doc: Path to the output model statistics file.
    type: File
    outputSource: step2_mdfeaturizer1/output_stats_pt_path
  step3_build_model_out1:
    label: output_model_pth_path
    doc: Path to save the model in .pth format.
    type: File
    outputSource: step3_build_model/output_model_pth_path
  step4_train_model_out1:
    label: output_model_pth_path
    doc: Path to save the trained model (.pth). If omitted, the trained model is only available in memory.
    type: File
    outputSource: step4_train_model/output_model_pth_path
  step4_train_model_out2:
    label: output_metrics_npz_path
    doc: Path save training metrics in compressed NumPy format (.npz).
    type: File
    outputSource: step4_train_model/output_metrics_npz_path
  step5_gmx_image2_out1:
    label: output_traj_path
    doc: Path to the output file.
    type: File
    outputSource: step5_gmx_image2/output_traj_path
  step6_mdfeaturizer2_out1:
    label: output_dataset_pt_path
    doc: Path to the output dataset model file.
    type: File
    outputSource: step6_mdfeaturizer2/output_dataset_pt_path
  step6_mdfeaturizer2_out2:
    label: output_stats_pt_path
    doc: Path to the output model statistics file.
    type: File
    outputSource: step6_mdfeaturizer2/output_stats_pt_path
  step7_evaluate_model_out1:
    label: output_results_npz_path
    doc: Path to the output evaluation results file (compressed NumPy archive).
    type: File
    outputSource: step7_evaluate_model/output_results_npz_path
  step8_make_ndx1_out1:
    label: output_ndx_path
    doc: Path to the output index NDX file.
    type: File
    outputSource: step8_make_ndx1/output_ndx_path
  step9_make_ndx2_out1:
    label: output_ndx_path
    doc: Path to the output index NDX file.
    type: File
    outputSource: step9_make_ndx2/output_ndx_path
  step10_gmx_rmsf1_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step10_gmx_rmsf1/output_xvg_path
  step11_gmx_rmsf2_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step11_gmx_rmsf2/output_xvg_path
  step12_feat2traj_out1:
    label: output_traj_path
    doc: Path to save the trajectory in xtc/pdb/dcd format.
    type: File
    outputSource: step12_feat2traj/output_traj_path
  step12_feat2traj_out2:
    label: output_top_path
    doc: Path to save the output topology file (pdb). Used if trajectory format requires separate topology.
    type: File
    outputSource: step12_feat2traj/output_top_path
  step13_gmx_rmsf3_out1:
    label: output_xvg_path
    doc: Path to the XVG output file.
    type: File
    outputSource: step13_gmx_rmsf3/output_xvg_path
  step14_make_plumed_out1:
    label: output_model_ptc_path
    doc: Path to the output TorchScript model file (.ptc) for PLUMED's PYTORCH_MODEL action.
    type: File
    outputSource: step14_make_plumed/output_model_ptc_path
  step14_make_plumed_out2:
    label: output_plumed_dat_path
    doc: Path to the output PLUMED input file.
    type: File
    outputSource: step14_make_plumed/output_plumed_dat_path
  step14_make_plumed_out3:
    label: output_features_dat_path
    doc: Path to the output features.dat file describing the CVs to PLUMED.
    type: File
    outputSource: step14_make_plumed/output_features_dat_path
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
  step2_mdfeaturizer1:
    label: mdfeaturizer
    doc: Obtain Molecular Dynamics features for PyTorch MDAE model training (dataset and statistics).
    run: biobb_adapters/mdfeaturizer.cwl
    in:
      config: step2_mdfeaturizer1_config
      input_trajectory_path: step1_gmx_image1/output_traj_path
      input_topology_path: step2_mdfeaturizer1_input_topology_path
      output_dataset_pt_path: step2_mdfeaturizer1_output_dataset_pt_path
      output_stats_pt_path: step2_mdfeaturizer1_output_stats_pt_path
    out:
    - output_dataset_pt_path
    - output_stats_pt_path
  step3_build_model:
    label: build_model
    doc: Build a PyTorch autoencoder model (MDAE) from input statistics and hyperparameters.
    run: biobb_adapters/build_model.cwl
    in:
      config: step3_build_model_config
      input_stats_pt_path: step2_mdfeaturizer1/output_stats_pt_path
      output_model_pth_path: step3_build_model_output_model_pth_path
    out:
    - output_model_pth_path
  step4_train_model:
    label: train_model
    doc: Train a PyTorch autoencoder model (MDAE) from an input dataset and initial model, optionally saving the trained model and training metrics.
    run: biobb_adapters/train_model.cwl
    in:
      config: step4_train_model_config
      input_dataset_pt_path: step2_mdfeaturizer1/output_dataset_pt_path
      input_model_pth_path: step3_build_model/output_model_pth_path
      output_model_pth_path: step4_train_model_output_model_pth_path
      output_metrics_npz_path: step4_train_model_output_metrics_npz_path
    out:
    - output_model_pth_path
    - output_metrics_npz_path
  step5_gmx_image2:
    label: gmx_image
    doc: Wrapper of the GROMACS trjconv module for correcting periodicity (image) from a given GROMACS compatible trajectory file.
    run: biobb_adapters/gmx_image.cwl
    in:
      config: step5_gmx_image2_config
      input_traj_path: step5_gmx_image2_input_traj_path
      input_top_path: step5_gmx_image2_input_top_path
      output_traj_path: step5_gmx_image2_output_traj_path
    out:
    - output_traj_path
  step6_mdfeaturizer2:
    label: mdfeaturizer
    doc: Obtain Molecular Dynamics features for PyTorch MDAE model training (dataset and statistics).
    run: biobb_adapters/mdfeaturizer.cwl
    in:
      config: step6_mdfeaturizer2_config
      input_trajectory_path: step5_gmx_image2/output_traj_path
      input_topology_path: step6_mdfeaturizer2_input_topology_path
      output_dataset_pt_path: step6_mdfeaturizer2_output_dataset_pt_path
      output_stats_pt_path: step6_mdfeaturizer2_output_stats_pt_path
    out:
    - output_dataset_pt_path
    - output_stats_pt_path
  step7_evaluate_model:
    label: evaluate_model
    doc: Evaluate a trained PyTorch autoencoder model (MDAE) on a dataset, computing loss and collecting model evaluation variables.
    run: biobb_adapters/evaluate_model.cwl
    in:
      config: step7_evaluate_model_config
      input_model_pth_path: step4_train_model/output_model_pth_path
      input_dataset_pt_path: step2_mdfeaturizer1/output_dataset_pt_path
      output_results_npz_path: step7_evaluate_model_output_results_npz_path
    out:
    - output_results_npz_path
  step8_make_ndx1:
    label: make_ndx
    doc: Creates a GROMACS index file (NDX) from an input selection and an input GROMACS structure file.
    run: biobb_adapters/make_ndx.cwl
    in:
      config: step8_make_ndx1_config
      input_structure_path: step8_make_ndx1_input_structure_path
      output_ndx_path: step8_make_ndx1_output_ndx_path
    out:
    - output_ndx_path
  step9_make_ndx2:
    label: make_ndx
    doc: Creates a GROMACS index file (NDX) from an input selection and an input GROMACS structure file.
    run: biobb_adapters/make_ndx.cwl
    in:
      config: step9_make_ndx2_config
      input_structure_path: step9_make_ndx2_input_structure_path
      output_ndx_path: step9_make_ndx2_output_ndx_path
    out:
    - output_ndx_path
  step10_gmx_rmsf1:
    label: gmx_rmsf
    doc: Wrapper of the GROMACS module for calculating the Root Mean Square fluctuations (RMSf) of a given GROMACS compatible trajectory.
    run: biobb_adapters/gmx_rmsf.cwl
    in:
      config: step10_gmx_rmsf1_config
      input_structure_path: step10_gmx_rmsf1_input_structure_path
      input_traj_path: step10_gmx_rmsf1_input_traj_path
      input_index_path: step8_make_ndx1/output_ndx_path
      output_xvg_path: step10_gmx_rmsf1_output_xvg_path
    out:
    - output_xvg_path
  step11_gmx_rmsf2:
    label: gmx_rmsf
    doc: Wrapper of the GROMACS module for calculating the Root Mean Square fluctuations (RMSf) of a given GROMACS compatible trajectory.
    run: biobb_adapters/gmx_rmsf.cwl
    in:
      config: step11_gmx_rmsf2_config
      input_structure_path: step11_gmx_rmsf2_input_structure_path
      input_traj_path: step11_gmx_rmsf2_input_traj_path
      input_index_path: step9_make_ndx2/output_ndx_path
      output_xvg_path: step11_gmx_rmsf2_output_xvg_path
    out:
    - output_xvg_path
  step12_feat2traj:
    label: feat2traj
    doc: Convert reconstructed molecular dynamics features (e.g. decoded coordinates) into an MD trajectory file using topology information from the stats file and/or a topology file.
    run: biobb_adapters/feat2traj.cwl
    in:
      input_results_npz_path: step7_evaluate_model/output_results_npz_path
      input_stats_pt_path: step6_mdfeaturizer2/output_stats_pt_path
      output_traj_path: step12_feat2traj_output_traj_path
      output_top_path: step12_feat2traj_output_top_path
    out:
    - output_traj_path
    - output_top_path
  step13_gmx_rmsf3:
    label: gmx_rmsf
    doc: Wrapper of the GROMACS module for calculating the Root Mean Square fluctuations (RMSf) of a given GROMACS compatible trajectory.
    run: biobb_adapters/gmx_rmsf.cwl
    in:
      config: step13_gmx_rmsf3_config
      input_structure_path: step12_feat2traj/output_top_path
      input_traj_path: step12_feat2traj/output_traj_path
      input_index_path: step9_make_ndx2/output_ndx_path
      output_xvg_path: step13_gmx_rmsf3_output_xvg_path
    out:
    - output_xvg_path
  step14_make_plumed:
    label: make_plumed
    doc: Generate a PLUMED input file, a features.dat file and a TorchScript (.ptc) model from a trained MDAE model and feature statistics, suitable for biased molecular dynamics simulations.
    run: biobb_adapters/make_plumed.cwl
    in:
      config: step14_make_plumed_config
      input_model_pth_path: step4_train_model/output_model_pth_path
      input_ndx_path: step8_make_ndx1/output_ndx_path
      input_reference_pdb_path: step14_make_plumed_input_reference_pdb_path
      input_stats_pt_path: step2_mdfeaturizer1/output_stats_pt_path
      output_model_ptc_path: step14_make_plumed_output_model_ptc_path
      output_plumed_dat_path: step14_make_plumed_output_plumed_dat_path
      output_features_dat_path: step14_make_plumed_output_features_dat_path
    out:
    - output_model_ptc_path
    - output_plumed_dat_path
    - output_features_dat_path
