#!/bin/bash

function run_alens {
    PMSP_RANDOM_SEED=$1 \
        PMSP_DILUTION=$2 \
        PMSP_PARTITION=$3 \
        ./bin/alens.sh \
        $4 &
}

function search_one_dilution {
    run_alens $1 $2 $3 ./src/search-frequency.tcl
}

function search_one_partition {
    PARITION=$1
    search_one_dilution 1 1 $PARITION
    search_one_dilution 1 2 $PARITION
    search_one_dilution 1 3 $PARITION
}

search_one_partition 0
search_one_partition 1
search_one_partition 2
