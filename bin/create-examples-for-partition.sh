#!/bin/bash

PARTITION=$1

SETTINGS=~/.dilution-deadline-study.ini \
    python3 bin/create-example-file.py \
    create_examples \
    --partition $PARTITION \
    --dilution 1 \
    --frequency 0.001 \
        > examples/updated/cogsci-partition-$PARTITION-dilution-1.ex

SETTINGS=~/.dilution-deadline-study.ini \
    python3 bin/create-example-file.py \
    create_examples \
    --partition $PARTITION \
    --dilution 2 \
    --frequency 0.001 \
        > examples/updated/cogsci-partition-$PARTITION-dilution-2.ex

SETTINGS=~/.dilution-deadline-study.ini \
    python3 bin/create-example-file.py \
    create_examples \
    --partition $PARTITION \
    --dilution 3 \
    --frequency 0.001 \
        > examples/updated/cogsci-partition-$PARTITION-dilution-3.ex

cat examples/pmsp/pmsp-train-the-normalized.ex \
    examples/updated/cogsci-partition-$PARTITION-dilution-1.ex > \
    examples/updated/cogsci-pmsp-added-partition-$PARTITION-dilution-1.ex

cat examples/pmsp/pmsp-train-the-normalized.ex \
    examples/updated/cogsci-partition-$PARTITION-dilution-2.ex > \
    examples/updated/cogsci-pmsp-added-partition-$PARTITION-dilution-2.ex

cat examples/pmsp/pmsp-train-the-normalized.ex \
    examples/updated/cogsci-partition-$PARTITION-dilution-3.ex > \
    examples/updated/cogsci-pmsp-added-partition-$PARTITION-dilution-3.ex
