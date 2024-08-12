#!/bin/bash
# set sh strict mode
set -o errexit
set -o nounset
IFS=$(printf '\n\t')

mkdir /home/scu/run
cd /home/scu/run

echo "starting service as"
echo "  User    : $(id "$(whoami)")"
echo "  Workdir : $(pwd)"
echo "..."
echo

# Sanity check: list the files available as inputs, if any
echo "Files in input folder..."
ls -al "${INPUT_FOLDER}"

# Parse input parameters
# Assuming these are passed as environment variables by osparc
NAME="${NAME:-sPARcRNA}"
MIN_CELLS="${MIN_CELLS:-3}"
MIN_FEATURES="${MIN_FEATURES:-200}"
MAX_FEATURES="${MAX_FEATURES:-2500}"
RESOLUTION="${RESOLUTION:-0.8}"
SPECIES="${SPECIES:-Homo sapiens}"
MIN_PCT="${MIN_PCT:-0.25}"
LOGFC_THRESHOLD="${LOGFC_THRESHOLD:-0.25}"
GSEA_MIN_SIZE="${GSEA_MIN_SIZE:-15}"
GSEA_MAX_SIZE="${GSEA_MAX_SIZE:-500}"
CATEGORY="${CATEGORY:-H}"

# Run the R script with command line arguments
Rscript /home/${SC_USER_NAME}/dex.R \
  --input "$INPUT_FOLDER" \
  --output "$OUTPUT_FOLDER" \
  --name "$NAME" \
  --min_cells "$MIN_CELLS" \
  --min_features "$MIN_FEATURES" \
  --max_features "$MAX_FEATURES" \
  --resolution "$RESOLUTION" \
  --species "$SPECIES" \
  --min_pct "$MIN_PCT" \
  --logfc_threshold "$LOGFC_THRESHOLD" \
  --gsea_min_size "$GSEA_MIN_SIZE" \
  --gsea_max_size "$GSEA_MAX_SIZE" \
  --category "$CATEGORY"

# Check if outputs.json was created
if [ ! -f "${OUTPUT_FOLDER}/outputs.json" ]; then
    echo "Error: outputs.json was not created. Check R script execution."
    exit 1
fi

cp -r astro/ ./
yarn build
cp build/* "${OUTPUT_FOLDER}/"

# Zip all output files
zip -r outputs.zip "${OUTPUT_FOLDER}"/*.csv "${OUTPUT_FOLDER}"/*.png "${OUTPUT_FOLDER}"/*.rds "${OUTPUT_FOLDER}"/outputs.json

# Move the zip file to be the only output
mv outputs.zip "${OUTPUT_FOLDER}/final_output.zip"

echo "Service completed successfully."