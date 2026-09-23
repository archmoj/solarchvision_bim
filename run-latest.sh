#!/bin/bash
# Like run.sh, but for Processing 4.5.x's rewritten CLI (`Processing cli`,
# which replaced the old processing-java script entirely - see
# test/image/README.md's "Setup: Processing 4.5.x").
#
# Run this from the repo root, same as run.sh.
set -e

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"

# The 4.5.x CLI resolves sketchPath()/BaseFolder to its own install
# directory instead of this repo's working directory, so input/, command/,
# and projects/ are symlinked into that location first - harmless to redo
# every run (ln -sfn is idempotent).
CORE="$PROCESSING_HOME/lib/app/resources/core"
mkdir -p projects
ln -sfn "$(pwd)/input" "$CORE/input"
ln -sfn "$(pwd)/command" "$CORE/command"
ln -sfn "$(pwd)/projects" "$CORE/projects"

if [ "$#" -lt 1 ]; then
    "$PROCESSING_HOME/bin/Processing" cli --sketch=app/src/solarchvision_bim --run
else
    "$PROCESSING_HOME/bin/Processing" cli --sketch=app/src/solarchvision_bim --run "$@"
fi
