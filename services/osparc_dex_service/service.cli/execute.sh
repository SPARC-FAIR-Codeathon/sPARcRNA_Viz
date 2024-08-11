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
Rscript /home/${SC_USER_NAME}/DEx.R \
  --input "$INPUT_FOLDER" \
  --output "$OUTPUT_FOLDER" \
  --prefix "$OUTPUT_PREFIX" \
  --min_cells "$MIN_CELLS" \
  --min_features "$MIN_FEATURES"

# Check if outputs.json was created
if [ ! -f "${OUTPUT_FOLDER}/outputs.json" ]; then
    echo "Error: outputs.json was not created. Check R script execution."
    exit 1
fi

# Zip all output files
cd "$OUTPUT_FOLDER"
zip -r outputs.zip ./*.h5ad outputs.json

# Move the zip file to be the only output
mv outputs.zip final_output.zip
rm ./*.h5ad outputs.json

echo "Service completed successfully."