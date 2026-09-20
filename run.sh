#!/bin/bash
if [ "$#" -lt 1 ]; then
    ~/processing/4.3.4/processing-java --sketch=app/src/solarchvision_bim --run
else
    ~/processing/4.3.4/processing-java --sketch=app/src/solarchvision_bim --run --args "$@"
fi
