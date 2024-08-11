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
OUTPUT_PREFIX="${OUTPUT_PREFIX:-}"
MIN_CELLS="${MIN_CELLS:-3}"
MIN_FEATURES="${MIN_FEATURES:-200}"


# Run the R script with command line arguments
Rscript /home/${SC_USER_NAME}/gsea_analysis.R \
  --input "$INPUT_FOLDER/$INPUT_FILE" \
  --output "$OUTPUT_FOLDER" \
  --species "$SPECIES" \
  --category "$MSIGDB_CATEGORY"

# Zip all output files
cd "$OUTPUT_FOLDER"
zip -r gsea_results.zip *.csv *.png

echo "GSEA analysis completed successfully. Results zipped into gsea_results.zip"