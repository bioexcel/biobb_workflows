#!/usr/bin/env bash
#
# Written by hand for the hand-ported workflow in ../../nextflow, from the run_test.sh template of utils_biobb nextflow_wf_generator.py.
# biobb_wf_md_setup_mutations — nextflow flavour e2e test
#
# Runs the Nextflow workflow (../../nextflow) with its default samplesheet:
#   nextflow run ../../nextflow -profile docker -c out/test.config
# out/test.config is a copy of nextflow.config with the runtime cuts of
# adjust_runtime below and the test settings, so the committed workflow files
# are never modified. Every step pulls the quay.io/biocontainers/* image of its
# module through the host docker daemon (cached afterwards).
#
# Runtime cuts: s/nsteps: [0-9]+/nsteps: 10/g (the python CI ones)
#
# Asserts: nextflow exits 0 and every output of every step (127 files) is
# published, not empty, in out/results/<id>/<step>/.
#
# Options / environment:
#   --keep               keep out/ (always kept on failure, recorded in .e2e_workdir)
#   PROFILE=apptainer    container profile (default: docker)
#   FULL_STEPS=1         skip the runtime cuts
#   EXTRA_NF_ARGS="..."  extra `nextflow run` arguments
#
# Usage:
#   ./run_test.sh [--keep]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WF_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WF_NAME="biobb_wf_md_setup_mutations"

KEEP="${KEEP:-0}"
PROFILE="${PROFILE:-docker}"
FULL_STEPS="${FULL_STEPS:-0}"
EXTRA_NF_ARGS="${EXTRA_NF_ARGS:-}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-1}"

if [[ "${1:-}" == "--keep" ]]; then KEEP=1; fi

# Every output of every step, under out/results (samplesheet id: md_setup_mutations)
EXPECTED_OUTPUTS=(
  "md_setup_mutations/step0_reduce_remove_hydrogens/md_setup_mutations_step0_reduce_remove_hydrogens_path.pdb"
  "md_setup_mutations/step1_extract_molecule/md_setup_mutations_step1_extract_molecule_molecule.pdb"
  "md_setup_mutations/step00_cat_pdb/md_setup_mutations_step00_cat_pdb_structure.pdb"
  "md_setup_mutations/step2_fix_side_chain/md_setup_mutations_step2_fix_side_chain_pdb.pdb"
  "md_setup_mutations/A:Gly4Lys/step3_mutate/md_setup_mutations_step3_mutate_pdb.pdb"
  "md_setup_mutations/A:Gly4Lys/step4_pdb2gmx/md_setup_mutations_step4_pdb2gmx_gro.gro"
  "md_setup_mutations/A:Gly4Lys/step4_pdb2gmx/md_setup_mutations_step4_pdb2gmx_top_zip.zip"
  "md_setup_mutations/A:Gly4Lys/step5_editconf/md_setup_mutations_step5_editconf_gro.pdb"
  "md_setup_mutations/A:Gly4Lys/step6_solvate/md_setup_mutations_step6_solvate_gro.gro"
  "md_setup_mutations/A:Gly4Lys/step6_solvate/md_setup_mutations_step6_solvate_top_zip.zip"
  "md_setup_mutations/A:Gly4Lys/step7_grompp_genion/md_setup_mutations_step7_grompp_genion_tpr.tpr"
  "md_setup_mutations/A:Gly4Lys/step8_genion/md_setup_mutations_step8_genion_gro.gro"
  "md_setup_mutations/A:Gly4Lys/step8_genion/md_setup_mutations_step8_genion_top_zip.zip"
  "md_setup_mutations/A:Gly4Lys/step9_grompp_min/md_setup_mutations_step9_grompp_min_tpr.tpr"
  "md_setup_mutations/A:Gly4Lys/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_gro.gro"
  "md_setup_mutations/A:Gly4Lys/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_edr.edr"
  "md_setup_mutations/A:Gly4Lys/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_log.log"
  "md_setup_mutations/A:Gly4Lys/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_trr.trr"
  "md_setup_mutations/A:Gly4Lys/step100_make_ndx/md_setup_mutations_step100_make_ndx_ndx.ndx"
  "md_setup_mutations/A:Gly4Lys/step11_grompp_nvt/md_setup_mutations_step11_grompp_nvt_tpr.tpr"
  "md_setup_mutations/A:Gly4Lys/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_gro.gro"
  "md_setup_mutations/A:Gly4Lys/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_edr.edr"
  "md_setup_mutations/A:Gly4Lys/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_log.log"
  "md_setup_mutations/A:Gly4Lys/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_trr.trr"
  "md_setup_mutations/A:Gly4Lys/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_cpt.cpt"
  "md_setup_mutations/A:Gly4Lys/step13_grompp_npt/md_setup_mutations_step13_grompp_npt_tpr.tpr"
  "md_setup_mutations/A:Gly4Lys/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_gro.gro"
  "md_setup_mutations/A:Gly4Lys/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_edr.edr"
  "md_setup_mutations/A:Gly4Lys/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_log.log"
  "md_setup_mutations/A:Gly4Lys/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_trr.trr"
  "md_setup_mutations/A:Gly4Lys/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_cpt.cpt"
  "md_setup_mutations/A:Gly4Lys/step15_grompp_md/md_setup_mutations_step15_grompp_md_tpr.tpr"
  "md_setup_mutations/A:Gly4Lys/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_gro.gro"
  "md_setup_mutations/A:Gly4Lys/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_edr.edr"
  "md_setup_mutations/A:Gly4Lys/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_log.log"
  "md_setup_mutations/A:Gly4Lys/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_trr.trr"
  "md_setup_mutations/A:Gly4Lys/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_cpt.cpt"
  "md_setup_mutations/A:Gly4Lys/step17_gmx_image1/md_setup_mutations_step17_gmx_image1_traj.trr"
  "md_setup_mutations/A:Gly4Lys/step18_gmx_image2/md_setup_mutations_step18_gmx_image2_traj.xtc"
  "md_setup_mutations/A:Gly4Lys/step19_gmx_trjconv_str/md_setup_mutations_step19_gmx_trjconv_str_str.pdb"
  "md_setup_mutations/A:Gly4Lys/step20_gmx_energy/md_setup_mutations_step20_gmx_energy_xvg.xvg"
  "md_setup_mutations/A:Gly4Lys/step21_gmx_rgyr/md_setup_mutations_step21_gmx_rgyr_xvg.xvg"
  "md_setup_mutations/A:Gly4Lys/step22_rmsd_first/md_setup_mutations_step22_rmsd_first_xvg.xvg"
  "md_setup_mutations/A:Gly4Lys/step23_rmsd_exp/md_setup_mutations_step23_rmsd_exp_xvg.xvg"
  "md_setup_mutations/A:Gly4Lys/step24_grompp_md/md_setup_mutations_step24_grompp_md_tpr.tpr"
  "md_setup_mutations/A:Leu8Met/step3_mutate/md_setup_mutations_step3_mutate_pdb.pdb"
  "md_setup_mutations/A:Leu8Met/step4_pdb2gmx/md_setup_mutations_step4_pdb2gmx_gro.gro"
  "md_setup_mutations/A:Leu8Met/step4_pdb2gmx/md_setup_mutations_step4_pdb2gmx_top_zip.zip"
  "md_setup_mutations/A:Leu8Met/step5_editconf/md_setup_mutations_step5_editconf_gro.pdb"
  "md_setup_mutations/A:Leu8Met/step6_solvate/md_setup_mutations_step6_solvate_gro.gro"
  "md_setup_mutations/A:Leu8Met/step6_solvate/md_setup_mutations_step6_solvate_top_zip.zip"
  "md_setup_mutations/A:Leu8Met/step7_grompp_genion/md_setup_mutations_step7_grompp_genion_tpr.tpr"
  "md_setup_mutations/A:Leu8Met/step8_genion/md_setup_mutations_step8_genion_gro.gro"
  "md_setup_mutations/A:Leu8Met/step8_genion/md_setup_mutations_step8_genion_top_zip.zip"
  "md_setup_mutations/A:Leu8Met/step9_grompp_min/md_setup_mutations_step9_grompp_min_tpr.tpr"
  "md_setup_mutations/A:Leu8Met/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_gro.gro"
  "md_setup_mutations/A:Leu8Met/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_edr.edr"
  "md_setup_mutations/A:Leu8Met/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_log.log"
  "md_setup_mutations/A:Leu8Met/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_trr.trr"
  "md_setup_mutations/A:Leu8Met/step100_make_ndx/md_setup_mutations_step100_make_ndx_ndx.ndx"
  "md_setup_mutations/A:Leu8Met/step11_grompp_nvt/md_setup_mutations_step11_grompp_nvt_tpr.tpr"
  "md_setup_mutations/A:Leu8Met/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_gro.gro"
  "md_setup_mutations/A:Leu8Met/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_edr.edr"
  "md_setup_mutations/A:Leu8Met/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_log.log"
  "md_setup_mutations/A:Leu8Met/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_trr.trr"
  "md_setup_mutations/A:Leu8Met/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_cpt.cpt"
  "md_setup_mutations/A:Leu8Met/step13_grompp_npt/md_setup_mutations_step13_grompp_npt_tpr.tpr"
  "md_setup_mutations/A:Leu8Met/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_gro.gro"
  "md_setup_mutations/A:Leu8Met/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_edr.edr"
  "md_setup_mutations/A:Leu8Met/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_log.log"
  "md_setup_mutations/A:Leu8Met/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_trr.trr"
  "md_setup_mutations/A:Leu8Met/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_cpt.cpt"
  "md_setup_mutations/A:Leu8Met/step15_grompp_md/md_setup_mutations_step15_grompp_md_tpr.tpr"
  "md_setup_mutations/A:Leu8Met/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_gro.gro"
  "md_setup_mutations/A:Leu8Met/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_edr.edr"
  "md_setup_mutations/A:Leu8Met/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_log.log"
  "md_setup_mutations/A:Leu8Met/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_trr.trr"
  "md_setup_mutations/A:Leu8Met/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_cpt.cpt"
  "md_setup_mutations/A:Leu8Met/step17_gmx_image1/md_setup_mutations_step17_gmx_image1_traj.trr"
  "md_setup_mutations/A:Leu8Met/step18_gmx_image2/md_setup_mutations_step18_gmx_image2_traj.xtc"
  "md_setup_mutations/A:Leu8Met/step19_gmx_trjconv_str/md_setup_mutations_step19_gmx_trjconv_str_str.pdb"
  "md_setup_mutations/A:Leu8Met/step20_gmx_energy/md_setup_mutations_step20_gmx_energy_xvg.xvg"
  "md_setup_mutations/A:Leu8Met/step21_gmx_rgyr/md_setup_mutations_step21_gmx_rgyr_xvg.xvg"
  "md_setup_mutations/A:Leu8Met/step22_rmsd_first/md_setup_mutations_step22_rmsd_first_xvg.xvg"
  "md_setup_mutations/A:Leu8Met/step23_rmsd_exp/md_setup_mutations_step23_rmsd_exp_xvg.xvg"
  "md_setup_mutations/A:Leu8Met/step24_grompp_md/md_setup_mutations_step24_grompp_md_tpr.tpr"
  "md_setup_mutations/A:Tyr20Gln/step3_mutate/md_setup_mutations_step3_mutate_pdb.pdb"
  "md_setup_mutations/A:Tyr20Gln/step4_pdb2gmx/md_setup_mutations_step4_pdb2gmx_gro.gro"
  "md_setup_mutations/A:Tyr20Gln/step4_pdb2gmx/md_setup_mutations_step4_pdb2gmx_top_zip.zip"
  "md_setup_mutations/A:Tyr20Gln/step5_editconf/md_setup_mutations_step5_editconf_gro.pdb"
  "md_setup_mutations/A:Tyr20Gln/step6_solvate/md_setup_mutations_step6_solvate_gro.gro"
  "md_setup_mutations/A:Tyr20Gln/step6_solvate/md_setup_mutations_step6_solvate_top_zip.zip"
  "md_setup_mutations/A:Tyr20Gln/step7_grompp_genion/md_setup_mutations_step7_grompp_genion_tpr.tpr"
  "md_setup_mutations/A:Tyr20Gln/step8_genion/md_setup_mutations_step8_genion_gro.gro"
  "md_setup_mutations/A:Tyr20Gln/step8_genion/md_setup_mutations_step8_genion_top_zip.zip"
  "md_setup_mutations/A:Tyr20Gln/step9_grompp_min/md_setup_mutations_step9_grompp_min_tpr.tpr"
  "md_setup_mutations/A:Tyr20Gln/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_gro.gro"
  "md_setup_mutations/A:Tyr20Gln/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_edr.edr"
  "md_setup_mutations/A:Tyr20Gln/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_log.log"
  "md_setup_mutations/A:Tyr20Gln/step10_mdrun_min/md_setup_mutations_step10_mdrun_min_trr.trr"
  "md_setup_mutations/A:Tyr20Gln/step100_make_ndx/md_setup_mutations_step100_make_ndx_ndx.ndx"
  "md_setup_mutations/A:Tyr20Gln/step11_grompp_nvt/md_setup_mutations_step11_grompp_nvt_tpr.tpr"
  "md_setup_mutations/A:Tyr20Gln/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_gro.gro"
  "md_setup_mutations/A:Tyr20Gln/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_edr.edr"
  "md_setup_mutations/A:Tyr20Gln/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_log.log"
  "md_setup_mutations/A:Tyr20Gln/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_trr.trr"
  "md_setup_mutations/A:Tyr20Gln/step12_mdrun_nvt/md_setup_mutations_step12_mdrun_nvt_cpt.cpt"
  "md_setup_mutations/A:Tyr20Gln/step13_grompp_npt/md_setup_mutations_step13_grompp_npt_tpr.tpr"
  "md_setup_mutations/A:Tyr20Gln/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_gro.gro"
  "md_setup_mutations/A:Tyr20Gln/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_edr.edr"
  "md_setup_mutations/A:Tyr20Gln/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_log.log"
  "md_setup_mutations/A:Tyr20Gln/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_trr.trr"
  "md_setup_mutations/A:Tyr20Gln/step14_mdrun_npt/md_setup_mutations_step14_mdrun_npt_cpt.cpt"
  "md_setup_mutations/A:Tyr20Gln/step15_grompp_md/md_setup_mutations_step15_grompp_md_tpr.tpr"
  "md_setup_mutations/A:Tyr20Gln/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_gro.gro"
  "md_setup_mutations/A:Tyr20Gln/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_edr.edr"
  "md_setup_mutations/A:Tyr20Gln/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_log.log"
  "md_setup_mutations/A:Tyr20Gln/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_trr.trr"
  "md_setup_mutations/A:Tyr20Gln/step16_mdrun_md/md_setup_mutations_step16_mdrun_md_cpt.cpt"
  "md_setup_mutations/A:Tyr20Gln/step17_gmx_image1/md_setup_mutations_step17_gmx_image1_traj.trr"
  "md_setup_mutations/A:Tyr20Gln/step18_gmx_image2/md_setup_mutations_step18_gmx_image2_traj.xtc"
  "md_setup_mutations/A:Tyr20Gln/step19_gmx_trjconv_str/md_setup_mutations_step19_gmx_trjconv_str_str.pdb"
  "md_setup_mutations/A:Tyr20Gln/step20_gmx_energy/md_setup_mutations_step20_gmx_energy_xvg.xvg"
  "md_setup_mutations/A:Tyr20Gln/step21_gmx_rgyr/md_setup_mutations_step21_gmx_rgyr_xvg.xvg"
  "md_setup_mutations/A:Tyr20Gln/step22_rmsd_first/md_setup_mutations_step22_rmsd_first_xvg.xvg"
  "md_setup_mutations/A:Tyr20Gln/step23_rmsd_exp/md_setup_mutations_step23_rmsd_exp_xvg.xvg"
  "md_setup_mutations/A:Tyr20Gln/step24_grompp_md/md_setup_mutations_step24_grompp_md_tpr.tpr"
)

NF_DIR="$WF_DIR/nextflow"
OUT_DIR="$SCRIPT_DIR/out"

if [[ ! -f "$NF_DIR/main.nf" ]]; then
  echo "ERROR: $NF_DIR/main.nf not found (wrong repo layout?)" >&2
  exit 1
fi

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: '$1' not found on PATH." >&2
    [[ "$1" == "nextflow" ]] && echo "Install e.g.: curl -s https://get.nextflow.io | bash (needs Java 17+)" >&2
    exit 1
  }
}
require nextflow
if [[ "$PROFILE" == "docker" ]]; then
  require docker
  docker info >/dev/null 2>&1 || { echo "ERROR: docker daemon not reachable" >&2; exit 1; }
fi

# BSD sed (macOS) needs an empty backup suffix, GNU sed (Linux) does not
if sed --version >/dev/null 2>&1; then SED_INPLACE=(sed -i -E); else SED_INPLACE=(sed -i '' -E); fi

# ---------------- per-workflow runtime cuts (TEST_SETTINGS of nextflow_wf_generator.py) ----------------
adjust_runtime() {
  # $1 = copy of nextflow.config
  "${SED_INPLACE[@]}" 's/nsteps: [0-9]+/nsteps: 10/g' "$1"
}
# --------------------------------------------------------------------------------------------------------

cleanup() {
  local rc=$?
  if [[ "$rc" -ne 0 && -d "$OUT_DIR" ]]; then
    echo "$OUT_DIR" > "$SCRIPT_DIR/.e2e_workdir"
    echo "Kept for debugging: $OUT_DIR"
  elif [[ "$KEEP" -ne 1 ]]; then
    rm -rf "$OUT_DIR" "$SCRIPT_DIR/.e2e_workdir"
  else
    rm -f "$SCRIPT_DIR/.e2e_workdir"
    echo "Kept: out=$OUT_DIR"
  fi
  exit "$rc"
}
trap cleanup EXIT

echo ">>> [1/4] prepare"
rm -rf "$OUT_DIR" "$SCRIPT_DIR/.e2e_workdir"
mkdir -p "$OUT_DIR"
cp "$NF_DIR/nextflow.config" "$OUT_DIR/test.config"
if [[ "$FULL_STEPS" -ne 1 ]]; then adjust_runtime "$OUT_DIR/test.config"; fi
NCPU="$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu)"
cat >> "$OUT_DIR/test.config" <<EOF

// e2e test settings: no task asks for more CPUs than the host has, task status in trace.tsv
process.resourceLimits = [cpus: $NCPU]
trace {
    enabled = true
    file = 'trace.tsv'
    overwrite = true
    fields = 'process,tag,status,exit,realtime'
}
EOF
case "$(uname -m)" in
  arm64|aarch64)
    if [[ "$PROFILE" == "docker" ]]; then
      echo "WARNING: ARM host, the biocontainers are amd64 only: running them with --platform linux/amd64 (slow)"
      cat >> "$OUT_DIR/test.config" <<'EOF'
profiles {
    docker {
        docker.runOptions = '-u $(id -u):$(id -g) --platform linux/amd64'
    }
}
EOF
    fi
    ;;
esac

if [[ "$PROFILE" == "docker" ]]; then
  echo ">>> [2/4] pull the module images"
  for img in $(grep -ho "quay.io/biocontainers/[^']*" "$NF_DIR"/modules/*/*/*/main.nf | sort -u); do
    PULL_OK=0
    for attempt in 1 2 3; do
      if docker pull -q "$img" >/dev/null; then PULL_OK=1; break; fi
      [[ "$attempt" -eq 3 ]] && break
      echo "  pull $img attempt $attempt/3 failed, retrying in 15 s"
      sleep 15
    done
    [[ "$PULL_OK" -eq 1 ]] || { echo "ERROR: docker pull failed for $img after 3 attempts" >&2; exit 1; }
  done
else
  echo ">>> [2/4] images are pulled by nextflow ($PROFILE profile)"
fi

echo ">>> [3/4] nextflow run (up to $MAX_ATTEMPTS attempts)"
RC=1
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  RESUME=""
  if [[ "$attempt" -gt 1 ]]; then RESUME="-resume"; fi
  set +e
  # shellcheck disable=SC2086
  ( cd "$OUT_DIR" && nextflow run "$NF_DIR" -profile "$PROFILE" -c test.config -ansi-log false $RESUME $EXTRA_NF_ARGS ) \
    >> "$OUT_DIR/nextflow_run.log" 2>&1
  RC=$?
  set -e
  [[ "$RC" -eq 0 ]] && break
  if [[ "$attempt" -lt "$MAX_ATTEMPTS" ]]; then
    echo "  attempt $attempt/$MAX_ATTEMPTS failed (rc=$RC), resuming in 30 s"
    sleep 30
  fi
done

if [[ "$RC" -ne 0 ]]; then
  echo "FAIL: nextflow exited with code $RC — failed tasks and last 50 log lines:"
  [[ -f "$OUT_DIR/trace.tsv" ]] && awk -F'\t' 'NR > 1 && $3 != "COMPLETED" { print "  " $1 " (" $2 "): " $3 ", exit " $4 }' "$OUT_DIR/trace.tsv"
  tail -50 "$OUT_DIR/nextflow_run.log"
  exit "$RC"
fi

echo ">>> [4/4] assert outputs (under $OUT_DIR/results)"
FAIL=0
for out in "${EXPECTED_OUTPUTS[@]}"; do
  path="$OUT_DIR/results/$out"
  if [[ "$out" == */ ]]; then
    [[ -d "$path" && -n "$(ls -A "$path" 2>/dev/null)" ]] && continue
  else
    [[ -s "$path" ]] && continue
  fi
  echo "  FAIL: not found (or empty): $out"
  FAIL=1
done

if [[ "$FAIL" -eq 0 ]]; then
  echo "  PASS: all 127 outputs"
  echo "PASS: $WF_NAME nextflow flavour e2e test"
else
  echo "  (files actually present under $OUT_DIR/results:)"
  find "$OUT_DIR/results" -type f 2>/dev/null | sed "s|^$OUT_DIR/results/|    |" | head -40
  echo "FAIL: $WF_NAME nextflow flavour e2e test (see missing outputs above)"
  exit 1
fi
