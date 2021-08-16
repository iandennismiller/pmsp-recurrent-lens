#!/bin/bash

function run_one_partition {
    DILUTION=$1
    PARITION=$2

    PMSP_RANDOM_SEED=1 PMSP_DILUTION=$DILUTION PMSP_PARTITION=$PARITION \
        ./bin/alens.sh ./src/train-pmsp-cogsci.tcl
}

# dilution 1
run_one_partition 1 0 &
run_one_partition 1 1 &
run_one_partition 1 2 &

# dilution 2
run_one_partition 2 0 &
run_one_partition 2 1 &
run_one_partition 2 2 &

# dilution 3
run_one_partition 3 0 &
run_one_partition 3 1 &
run_one_partition 3 2 &
