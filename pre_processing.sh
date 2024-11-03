#!/bin/bash

BASE_DIR=$(pwd)
DATASET_DIR="$BASE_DIR/ds004199"

jobs=24
subjects=($(find "$DATASET_DIR" -type d -name 'sub-*' -exec basename {} \;))

commands=()

for subject in "${subjects[@]}"; do
    scan=$(find "$DATASET_DIR/$subject/anat" -name '*_T1w.nii.gz' | head -n 1)
    
    if [[ -n $scan ]]; then
        commands+=("recon-all -s \"$subject\" -i \"$scan\" -all -qcache")
    else
        echo "No T1w scan found for $subject"
    fi
done

echo "Running ${#commands[@]} jobs in parallel"
parallel --jobs "$jobs" ::: "${commands[@]}"