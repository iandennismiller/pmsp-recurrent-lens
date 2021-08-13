#!/bin/bash

function run_one {
    PMSP_RANDOM_SEED=$1 \
        PMSP_DILUTION=$2 \
        PMSP_PARTITION=$3 \
        ./alens.sh \
        $4 &
}

function run_one_fig18 {
    run_one $1 $2 $3 ./activations-fig18-dt-100.tcl
}

function run_one_anchors {
    run_one $1 $2 $3 ./activations-anchors-dt-100.tcl
}

function run_one_probes {
    run_one $1 $2 $3 ./activations-probes-dt-100.tcl
}

function run_one_partition_fig18 {
    PARITION=$1
    run_one_fig18 1 1 $PARITION
    run_one_fig18 1 2 $PARITION
    run_one_fig18 1 3 $PARITION
}

function run_one_partition_anchors {
    PARITION=$1
    run_one_anchors 1 1 $PARITION
    run_one_anchors 1 2 $PARITION
    run_one_anchors 1 3 $PARITION
}

function run_one_partition_probes {
    PARITION=$1
    run_one_probes 1 1 $PARITION
    run_one_probes 1 2 $PARITION
    run_one_probes 1 3 $PARITION
}

run_one_partition_fig18 0
run_one_partition_fig18 1
run_one_partition_fig18 2

run_one_partition_anchors 0
run_one_partition_anchors 1
run_one_partition_anchors 2

run_one_partition_probes 0
run_one_partition_probes 1
run_one_partition_probes 2
