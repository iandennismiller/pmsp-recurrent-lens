#!/bin/bash

if [ $(uname -n) == "kings" ]; then
    export LENSDIR=/opt/Lens-linux
else
    export LENSDIR=/app/Lens-linux
fi

export PATH=${PATH}:${LENSDIR}/Bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LENSDIR}/Bin

exec ${LENSDIR}/Bin/alens $1
