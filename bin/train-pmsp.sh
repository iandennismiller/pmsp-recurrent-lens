#!/bin/bash

function run_one_partition {
    DILUTION=$1
    PARITION=$2

    PMSP_RANDOM_SEED=1 PMSP_DILUTION=$DILUTION PMSP_PARTITION=$PARITION \
        ./bin/alens.sh ./src/train-pmsp-cogsci.tcl
}

# dilution 1
run_one_partition 1 1
