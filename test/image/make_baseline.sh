#!/bin/bash
# Bash equivalent of test/image/make_baseline.py, for CI legs where the
# Python-based version doesn't work (Windows, specifically): generates
# test/image/actual/*.png for command/test_*.txt by running the sketch
# headlessly (USER=AUTO) through the exact same
# run-with-latest-processing.sh/.bat (or run-with-processing-4.3.sh/.bat)
# wrapper test/run_integration.sh uses - confirmed, by hand, to actually
# produce real screenshots on Windows, unlike every variation of invoking
# Processing.exe/Processing cli directly from Python that was tried
# first (see make_baseline.py's own build_command() for that history -
# the exact underlying cause was never pinned down; this script exists
# to stop guessing at it and just reuse the invocation already proven to
# work instead).
#
# No coverage/JaCoCo instrumentation here: this script exists purely to
# generate images, so none of test/run_integration.sh's
# JAVA_TOOL_OPTIONS/runtime-swap machinery (needed only for -javaagent to
# attach) is needed or included.
#
# A single test script can call REC.png more than once, each with its
# own name given right in the script (see command/test_views.txt), so
# one test can produce several screenshots - each is kept under its own
# original filename rather than the test's, matching make_baseline.py's
# own behavior exactly.
#
# This exercises the sketch's real GL rendering pipeline, so it needs a
# display - see test/run_integration.sh's own comment on this (Linux:
# wrap in xvfb-run; Windows: nothing extra needed, but does need a
# software OpenGL implementation - see .github/workflows/image-tests.yml's
# Windows job for what that takes).
#
# Usage:
#   ./test/image/make_baseline.sh                          # every command/test_*.txt
#   ./test/image/make_baseline.sh test_edit test_views ...  # specific ones only (name without .txt)
#
# Environment:
#   PROCESSING_HOME   - defaults to ~/processing/4.5.2, same as
#                       test/run_integration.sh.
#   PER_TEST_TIMEOUT  - seconds allowed per attempt (default: 300)
#   MAX_RETRY         - retries per test after the first attempt
#                       (default: 2, i.e. up to 3 attempts total)
set -uo pipefail   # NOT -e: one failed test shouldn't abort the whole run
cd "$(dirname "$0")/../.."   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"
PER_TEST_TIMEOUT="${PER_TEST_TIMEOUT:-300}"
MAX_RETRY="${MAX_RETRY:-2}"

ACTUAL_DIR="test/image/actual"
mkdir -p "$ACTUAL_DIR"

# Same launcher detection as test/run_integration.sh - see that file's
# own comment for why Processing 4.5.x is preferred when available, and
# run-with-latest-processing.bat for why Windows reuses the .bat wrapper
# rather than Processing.exe being invoked directly.
if [ -x "$PROCESSING_HOME/bin/Processing" ]; then
  RUN_CMD=(./run-with-latest-processing.sh)
elif [ -x "$PROCESSING_HOME/Processing.exe" ]; then
  RUN_CMD=(./run-with-latest-processing.bat)
elif [ -x "$PROCESSING_HOME/processing-java" ]; then
  RUN_CMD=(./run-with-processing-4.3.sh)
  echo "warning: using legacy run-with-processing-4.3.sh (Processing 4.3.4) - known to segfault on newer Mesa; switch to 4.5.x if this happens" >&2
else
  echo "error: none of processing-java, bin/Processing, or Processing.exe found under $PROCESSING_HOME" >&2
  exit 1
fi

if [ "$#" -lt 1 ]; then
  shopt -s nullglob
  for f in command/test_*.txt; do
    set -- "$@" "$(basename "$f" .txt)"
  done
  shopt -u nullglob
  if [ "$#" -lt 1 ]; then
    echo "error: no tests given and no command/test_*.txt files found" >&2
    exit 1
  fi
  echo "==> No tests given - defaulting to every command/test_*.txt: $*"
fi

# sketchPath() (used as BaseFolder in update_folders.pde) resolves to
# Processing's own install directory, not the repo directly - see
# test/image/README.md for why. The input/command/projects
# symlink-or-junction setup run-with-latest-processing.sh/.bat itself
# sets up on every invocation aliases that back to REPO_ROOT/projects,
# so checking REPO_ROOT's own copy (and, just in case, the sketch
# directory's) covers it - the same two roots make_baseline.py's own
# SCREENSHOTS_ROOTS checks.
SCREENSHOTS_ROOTS=(
  "projects/model-01/export/screenshots"
  "app/src/solarchvision_bim/projects/model-01/export/screenshots"
)

find_new_screenshots () {
  local marker="$1"
  for root in "${SCREENSHOTS_ROOTS[@]}"; do
    if [ -d "$root" ]; then
      find "$root" -name '*.png' -newer "$marker" 2>/dev/null
    fi
  done
}

TOTAL=0
SUCCEEDED=0
FAILED_NAMES=()

for NAME in "$@"; do
  TOTAL=$((TOTAL + 1))
  SCRIPT="command/${NAME}.txt"
  if [ ! -f "$SCRIPT" ]; then
    echo "error: $SCRIPT not found" >&2
    FAILED_NAMES+=("$NAME")
    continue
  fi

  echo "== $NAME =="
  OK=0
  for ATTEMPT in $(seq 0 "$MAX_RETRY"); do
    MARKER="$(mktemp)"
    START=$(date +%s)

    timeout "$PER_TEST_TIMEOUT" "${RUN_CMD[@]}" "USER=AUTO" "RUN=${SCRIPT}"
    STATUS=$?

    ELAPSED=$(( $(date +%s) - START ))
    if [ "$STATUS" -eq 124 ]; then
      echo "  timed out after ${ELAPSED}s (PER_TEST_TIMEOUT=${PER_TEST_TIMEOUT})"
    elif [ "$STATUS" -ne 0 ]; then
      echo "  note: exited $STATUS after ${ELAPSED}s"
    else
      echo "  finished after ${ELAPSED}s"
    fi

    SCREENSHOTS=()
    while IFS= read -r line; do
      [ -n "$line" ] && SCREENSHOTS+=("$line")
    done < <(find_new_screenshots "$MARKER")
    rm -f "$MARKER"

    if [ "${#SCREENSHOTS[@]}" -gt 0 ]; then
      for SHOT in "${SCREENSHOTS[@]}"; do
        DEST="$ACTUAL_DIR/$(basename "$SHOT")"
        cp "$SHOT" "$DEST"
        echo "  captured: $DEST (from $SHOT)"
      done
      OK=1
      break
    fi

    echo "  no screenshots produced for $SCRIPT"
    if [ "$ATTEMPT" -lt "$MAX_RETRY" ]; then
      echo "  retry $((ATTEMPT + 1))/$MAX_RETRY"
    fi
  done

  if [ "$OK" -eq 1 ]; then
    SUCCEEDED=$((SUCCEEDED + 1))
  else
    FAILED_NAMES+=("$NAME")
  fi
done

echo "$SUCCEEDED/$TOTAL succeeded"
if [ "${#FAILED_NAMES[@]}" -gt 0 ]; then
  echo "failed: ${FAILED_NAMES[*]}" >&2
  exit 1
fi
