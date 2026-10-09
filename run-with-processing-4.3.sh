#!/bin/bash
# Windows: use run-with-processing-4.3.bat instead (processing-java.exe isn't a bash script).
if [ "$#" -lt 1 ]; then
    ~/processing/4.3.4/processing-java --sketch=src/solarchvision_bim --run
else
    ~/processing/4.3.4/processing-java --sketch=src/solarchvision_bim --run --args "$@"
fi
