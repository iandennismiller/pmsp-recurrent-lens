#!/bin/bash

PARTITION=$1

SETTINGS=~/.dilution-deadline-study.ini \
    python3 bin/create-example-file.py \
    create_examples \
    --partition $PARTITION \
    --dilution 1 \
    --frequency 0.001 \
        > usr/examples/cogsci-partition-$PARTITION-dilution-1.ex

SETTINGS=~/.dilution-deadline-study.ini \
    python3 bin/create-example-file.py \
    create_examples \
    --partition $PARTITION \
    --dilution 2 \
    --frequency 0.001 \
        > usr/examples/cogsci-partition-$PARTITION-dilution-2.ex

SETTINGS=~/.dilution-deadline-study.ini \
    python3 bin/create-example-file.py \
    create_examples \
    --partition $PARTITION \
    --dilution 3 \
    --frequency 0.001 \
        > usr/examples/cogsci-partition-$PARTITION-dilution-3.ex

cat usr/examples/pmsp-train-the-normalized.ex \
    usr/examples/cogsci-partition-$PARTITION-dilution-1.ex > \
    usr/examples/cogsci-pmsp-added-partition-$PARTITION-dilution-1.ex

cat usr/examples/pmsp-train-the-normalized.ex \
    usr/examples/cogsci-partition-$PARTITION-dilution-2.ex > \
    usr/examples/cogsci-pmsp-added-partition-$PARTITION-dilution-2.ex

cat usr/examples/pmsp-train-the-normalized.ex \
    usr/examples/cogsci-partition-$PARTITION-dilution-3.ex > \
    usr/examples/cogsci-pmsp-added-partition-$PARTITION-dilution-3.ex
