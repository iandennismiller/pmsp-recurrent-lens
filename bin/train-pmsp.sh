#!/bin/bash

function run_one_partition {
    DILUTION=$1
    PARITION=$2
    SEED=$3

    PMSP_RANDOM_SEED=$SEED PMSP_DILUTION=$DILUTION PMSP_PARTITION=$PARITION \
        ./bin/alens-batch.sh ./src/train-pmsp-cogsci.tcl
}

# dilution 1
run_one_partition 1 1 1 &
run_one_partition 1 1 2 &
run_one_partition 1 1 3 &
