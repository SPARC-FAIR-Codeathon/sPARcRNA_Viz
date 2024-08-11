#!/bin/bash
# set sh strict mode
set -o errexit
set -o nounset
IFS=$(printf '\n\t')

mkdir /home/scu/run
cd /home/scu/run

echo "starting service as"
echo   User    : "$(id "$(whoami)")"
echo   Workdir : "$(pwd)"
echo "..."
echo

# Sanity check: list the files available as inputs, if any
echo "Files in input folder..."
ls -al "${INPUT_FOLDER}"

# Parse input parameters
# Assuming these are passed as environment variables by osparc
INPUT_FILE="${INPUT_FILE:-}"
SPECIES="${SPECIES:-Homo sapiens}"
MSIGDB_CATEGORY="${MSIGDB_CATEGORY:-H}"
MIN_PCT="${MIN_PCT:-0.25}"
LOGFC_THRESHOLD="${LOGFC_THRESHOLD:-0.25}"
GSEA_MIN_SIZE="${GSEA_MIN_SIZE:-15}"
GSEA_MAX_SIZE="${GSEA_MAX_SIZE:-500}"

# Run the R script with command line arguments
Rscript /home/${SC_USER_NAME}/gsea_analysis.R \
  --input "$INPUT_FOLDER/$INPUT_FILE" \
  --output "$OUTPUT_FOLDER" \
  --species "$SPECIES" \
  --category "$MSIGDB_CATEGORY" \
  --min_pct "$MIN_PCT" \
  --logfc_threshold "$LOGFC_THRESHOLD" \
  --gsea_min_size "$GSEA_MIN_SIZE" \
  --gsea_max_size "$GSEA_MAX_SIZE"

# Zip all output files
cd "$OUTPUT_FOLDER"
zip -r gsea_results.zip *.csv *.png

echo "GSEA analysis completed successfully. Results zipped into gsea_results.zip"