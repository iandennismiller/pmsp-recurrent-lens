#!/bin/bash

function run_one {
    DILUTION=$1
    PARITION=$2
    SEED=$3

    PMSP_RANDOM_SEED=$SEED PMSP_DILUTION=$DILUTION PMSP_PARTITION=$PARITION \
        ./bin/alens-batch.sh ./src/train-pmsp-cogsci.tcl &
}

function run_one_dilution {
    DILUTION=$1
    SEED=$2

    run_one $DILUTION 0 $SEED
    run_one $DILUTION 1 $SEED
    run_one $DILUTION 2 $SEED
}

function run_one_seed {
    SEED=$1

    run_one_dilution 1 $SEED
    run_one_dilution 2 $SEED
    run_one_dilution 3 $SEED
}

run_one_seed 1
run_one_seed 2
run_one_seed 3
