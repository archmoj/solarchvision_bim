#!/bin/bash
# Exports a self-contained, runnable solarchvision_bim application into
# dist/<variant>/ - bundling a full Java runtime via Processing's own
# --export (https://github.com/processing/processing4/wiki/Command-Line),
# so the result runs with no Processing, and no separate Java, install
# needed - plus the input/, command/, projects/, import/ folders
# solarchvision_bim resolves relative to its own install directory at
# runtime (BaseFolder = sketchPath() - see update_folders.pde), which
# --export alone doesn't know to include, since they live at the repo
# root rather than inside the sketch's own data/ folder (only data/,
# here just data/font/, gets bundled automatically). Confirmed by
# actually running an export before this script existed: it starts, but
# throws immediately trying to load input/images/sun/Sun.jpg without
# this.
#
# Same idea as run-with-latest-processing.sh's own input/command/projects
# symlinks for a live dev run from this repo - except these are real
# copies (cp, not ln), since a dist build is meant to be moved/zipped/
# handed to someone else entirely, not left pointing back at this
# checkout.
#
# Usage:
#   ./build-dist.sh                       # every variant below
#   ./build-dist.sh linux-amd64           # just one (or a few)
#
# Variants (Processing's own --variant names - see `Processing cli --help`):
#   linux-amd64, windows-amd64, macos-x86_64, macos-aarch64
# The two macOS variants are known not to cross-export correctly from a
# Linux or Windows host (confirmed: the export command still exits 0,
# but throws partway through and leaves an incomplete output directory -
# a Kotlin NoSuchElementException inside Processing's own
# JavaBuild.exportApplication) - an actual macOS host is needed for
# those two. CI (.github/workflows/dist.yml) only builds linux-amd64 and
# windows-amd64, both confirmed working, from a single Linux runner.
#
# Requires Processing 4.5.x+ (the --export flag doesn't exist in the
# legacy <=4.4.x processing-java CLI - see test/README.md's "Setup:
# Processing 4.5.x" for the two generations' differences).
#
# Environment:
#   PROCESSING_HOME   - defaults to ~/processing/4.5.2, same as
#                       run-with-latest-processing.sh and test/run_tests.sh.
#   DIST_DIR          - defaults to dist/
set -euo pipefail
cd "$(dirname "$0")"   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"
SKETCH_DIR="app/src/solarchvision_bim"
DIST_DIR="${DIST_DIR:-dist}"

# Windows' portable build lays out one directory level shallower than
# Linux/macOS's (Processing.exe directly at the install root, no bin/
# wrapper) - see run-with-latest-processing.bat's own comment on this
# same difference.
if [ -x "$PROCESSING_HOME/bin/Processing" ]; then
  PROCESSING_BIN="$PROCESSING_HOME/bin/Processing"
elif [ -x "$PROCESSING_HOME/Processing.exe" ]; then
  PROCESSING_BIN="$PROCESSING_HOME/Processing.exe"
else
  echo "error: no bin/Processing or Processing.exe found under $PROCESSING_HOME" >&2
  echo "       --export needs Processing 4.5.x+ - set PROCESSING_HOME to that install." >&2
  exit 1
fi

if [ "$#" -ge 1 ]; then
  VARIANTS=("$@")
else
  VARIANTS=(linux-amd64 windows-amd64 macos-x86_64 macos-aarch64)
fi

for VARIANT in "${VARIANTS[@]}"; do
  OUT="$DIST_DIR/$VARIANT"
  echo "==> Exporting $VARIANT to $OUT"
  rm -rf "$OUT"
  "$PROCESSING_BIN" cli --sketch="$SKETCH_DIR" --output="$OUT" --force --variant="$VARIANT" --export

  echo "==> Adding input/, command/, projects/, import/ to $OUT"
  cp -r input "$OUT/input"
  cp -r command "$OUT/command"
  mkdir -p "$OUT/projects" "$OUT/import"

  echo "==> Done: $OUT"
done
