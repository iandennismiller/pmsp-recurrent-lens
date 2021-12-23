#!/bin/bash

if [ "$(uname -n)" == "kings" ]; then
    export LENSDIR=/opt/Lens-linux
elif [ "$(uname -n)" == "armstronglab" ]; then
    export LENSDIR=/app/Lens-linux
else
    export LENSDIR=/home/lens/lens-linux
fi

export PATH=${PATH}:${LENSDIR}/Bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LENSDIR}/Bin

exec ${LENSDIR}/Bin/alens $1
