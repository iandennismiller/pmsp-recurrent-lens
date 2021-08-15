#!/bin/bash

function run_one {
    PMSP_RANDOM_SEED=$1 \
        PMSP_DILUTION=$2 \
        PMSP_PARTITION=$3 \
        ./bin/alens.sh \
        $4 &
}

function run_one_probes {
    run_one $1 $2 $3 ./src/run-accuracy-probes.tcl
}

function run_one_partition_probes {
    PARITION=$1
    run_one_probes 1 1 $PARITION
    run_one_probes 1 2 $PARITION
    run_one_probes 1 3 $PARITION
}

function run_one_pmsp_anchors {
    run_one $1 $2 $3 ./src/run-accuracy-pmsp-anchors.tcl
}

function run_one_partition_pmsp_anchors {
    PARITION=$1
    run_one_probes 1 1 $PARITION
    run_one_probes 1 2 $PARITION
    run_one_probes 1 3 $PARITION
}

# run_one_partition_probes 0
# run_one_partition_probes 1
# run_one_partition_probes 2

run_one_partition_pmsp_anchors 0
run_one_partition_pmsp_anchors 1
run_one_partition_pmsp_anchors 2
