#!/bin/bash

BASE_DIR=$(pwd)

source "$BASE_DIR/utils/loading.sh"

hemispheres=("lh" "rh")
parcellations=("aparc" "aparc.a2009s" "aparc.pial")
measures=("volume" "thickness" "meancurv")

SUBJECTS_DIR="$FREESURFER_HOME/subjects"

subjects=($(find "$SUBJECTS_DIR" -type d -name 'sub-*' -exec basename {} \;))

if [ ${#subjects[@]} -eq 0 ]; then
    echo "No subjects found"
    exit 1
fi

loading &
loading_pid=$!

for hemi in "${hemispheres[@]}"; do
    stats_dir="$BASE_DIR/stats/aparc/$hemi"
    mkdir -p "$stats_dir"

    for parc in "${parcellations[@]}"; do
        parc_dir="$stats_dir/$parc"
        mkdir -p "$parc_dir"

        for measure in "${measures[@]}"; do
            output_file="$parc_dir/${measure}_stats.csv"
            aparcstats2table --subjects "${subjects[@]}" \
                --hemi "$hemi" -p "$parc" -m "$measure" \
                --parcid-only -d comma --tablefile "$output_file" \
                >/dev/null 2>&1
        done
    done
done

asegstats2table --subjects "${subjects[@]}" \
    --delimiter comma --tablefile "$BASE_DIR/stats/aseg_stats.csv" \
    >/dev/null 2>&1

kill "$loading_pid" || true
echo -ne "\rDone!        \n"
