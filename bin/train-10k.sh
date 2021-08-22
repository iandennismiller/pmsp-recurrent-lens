#!/bin/bash

function run_one_partition {
    DILUTION=$1
    PARITION=$2
    RANDOM_SEED=$3

    PMSP_RANDOM_SEED=$RANDOM_SEED PMSP_DILUTION=$DILUTION PMSP_PARTITION=$PARITION \
        ./bin/alens-batch.sh ./src/train-pmsp-10k-epochs.tcl
}

function run_one_seed {
    RANDOM_SEED=$1

    # dilution 1
    run_one_partition 1 0 $RANDOM_SEED &
    run_one_partition 1 1 $RANDOM_SEED &
    run_one_partition 1 2 $RANDOM_SEED &

    # dilution 2
    run_one_partition 2 0 $RANDOM_SEED &
    run_one_partition 2 1 $RANDOM_SEED &
    run_one_partition 2 2 $RANDOM_SEED &

    # dilution 3
    run_one_partition 3 0 $RANDOM_SEED &
    run_one_partition 3 1 $RANDOM_SEED &
    run_one_partition 3 2 $RANDOM_SEED &
}

run_one_seed 1
run_one_seed 2
run_one_seed 3
run_one_seed 4
run_one_seed 5
run_one_seed 6
run_one_seed 7
run_one_seed 8
run_one_seed 9
run_one_seed 10
