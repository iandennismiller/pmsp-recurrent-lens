#!/bin/bash

function run_alens {
    PMSP_RANDOM_SEED=$1 \
        PMSP_DILUTION=$2 \
        PMSP_PARTITION=$3 \
        PMSP_FREQ=$4 \
        ./bin/alens-batch.sh $5 &
}

function search_one_dilution {
    run_alens $1 $2 $3 $4 ./src/search-frequency.tcl
}

function search_one_partition {
    PARITION=$1
    FREQUENCY=$2
    search_one_dilution 1 1 $PARITION $FREQUENCY
    search_one_dilution 1 2 $PARITION $FREQUENCY
    search_one_dilution 1 3 $PARITION $FREQUENCY
}

function search_one_frequency {
    FREQUENCY=$1
    search_one_partition 0 $FREQUENCY
    search_one_partition 1 $FREQUENCY
    search_one_partition 2 $FREQUENCY
}

find . -name "search-frequency.tsv" -delete

for FREQUENCY in 0.00001 0.0001 0.001 0.01 0.1 1 10 100 1000 10000 100000; do
    search_one_frequency $FREQUENCY
done
