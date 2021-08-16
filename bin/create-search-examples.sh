#!/bin/bash

for FREQUENCY in 0.00001 0.0001 0.001 0.01 0.1 1 10 100 1000 10000 100000; do

for PARTITION in 0 1 2; do
    for DILUTION in 1 2 3; do

        INFILE=examples/cogsci/cogsci-pmsp-added-partition-$PARTITION-dilution-$DILUTION.ex

        OUTFILE=examples/frequency-search/freq-$FREQUENCY-partition-$PARTITION-dilution-$DILUTION.ex

        cat $INFILE | sed "s/freq: 0.00100000/freq: $FREQUENCY/g" > $OUTFILE

    done
done

done
