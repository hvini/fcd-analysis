#!/bin/bash

BASE_DIR=$(pwd)
DATASET_DIR="$BASE_DIR/ds004199"
SUBJECTS_DIR="$FREESURFER_HOME/subjects"
pending_subjects=()
commands=()
jobs=24

subjects=($(find "$DATASET_DIR" -type d -name 'sub-*' -exec basename {} \;))

for subject in "${subjects[@]}"; do
    log_file="$SUBJECTS_DIR/$subject/scripts/recon-all.log"
    last_line=$(tail -1 "$log_file" 2>/dev/null)
    if [[ "$last_line" != *"finished without error"* ]]; then
        rm -rf "$SUBJECTS_DIR/$subject"
        pending_subjects+=("$subject")
    fi
done

for subject in "${pending_subjects[@]}"; do
    scan=$(find "$DATASET_DIR/$subject/anat" -name '*_T1w.nii.gz' | head -n 1)

    if [[ -n $scan ]]; then
        commands+=("recon-all -s \"$subject\" -i \"$scan\" -all -qcache")
    else
        echo "No T1w scan found for $subject"
    fi
done

echo "Running ${#commands[@]} jobs in parallel"
parallel --jobs "$jobs" ::: "${commands[@]}"
