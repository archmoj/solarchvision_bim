#!/bin/bash
# Bash alternative to test/image/make_baseline.py: generates
# test/image/actual/*.png for command/test/*.svs by running the sketch
# headlessly (USER=AUTO) through the exact same
# run-with-latest-processing.sh/.bat (or run-with-processing-4.3.sh/.bat)
# wrapper test/run_integration.sh uses (which also delegates its own
# Processing invocation to this script, rather than duplicating this
# logic a third time - see that file's own comment).
#
# This existed originally to work around what looked like a Windows-
# specific hang when make_baseline.py invoked Processing.exe directly -
# every combination of subprocess options and argv forms tried there
# reliably hung during the sketch's very first rendered frame, while this
# script's invocation of the exact same Processing.exe through
# run-with-latest-processing.bat did not. The actual difference turned
# out to be LIBGL_ALWAYS_SOFTWARE=1 (see the comment on it below) - once
# make_baseline.py was given that same env var, direct invocation from
# Python worked too, so this script is no longer the only thing that
# works on Windows. Kept anyway (not reverted back to a thin wrapper
# around make_baseline.py) because it's now what test/run_integration.sh
# itself relies on for every platform, not just Windows.
#
# No coverage/JaCoCo instrumentation here: this script exists purely to
# generate images, so JAVA_TOOL_OPTIONS itself (needed only for
# -javaagent to attach) is not included. LIBGL_ALWAYS_SOFTWARE and the
# runtime swap are kept despite being originally documented (in
# test/run_integration.sh, which this was first adapted from) as existing
# only to support that - LIBGL_ALWAYS_SOFTWARE turned out to matter for
# rendering too (see above), and the runtime swap is cheap enough to
# leave in rather than prove it's unnecessary here specifically.
# Mesa's WGL (Windows) backend shares LIBGL_ALWAYS_SOFTWARE's underlying
# codebase and environment-variable handling with its Linux/GLX one
# despite the name suggesting otherwise, which is plausibly why setting
# it mattered here: forcing llvmpipe rather than letting Mesa probe for
# hardware acceleration first - a hang (not a crash) during that probe
# would match the symptom seen without it exactly.
#
# A single test script can call REC.png more than once, each with its
# own name given right in the script (see command/test/views.svs), so
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
#   ./test/image/make_baseline.sh                          # every command/test/*.svs
#   ./test/image/make_baseline.sh edit views ...            # specific ones only (name without .svs)
#
# Environment:
#   PROCESSING_HOME   - defaults to ~/processing/4.5.2, same as
#                       test/run_integration.sh.
#   PER_TEST_TIMEOUT  - seconds allowed per attempt (default: 300)
#   MAX_RETRY         - retries per test after the first attempt
#                       (default: 1, i.e. up to 2 attempts total)
set -uo pipefail   # NOT -e: one failed test shouldn't abort the whole run
cd "$(dirname "$0")/../.."   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"
PER_TEST_TIMEOUT="${PER_TEST_TIMEOUT:-300}"
MAX_RETRY="${MAX_RETRY:-1}"
export LIBGL_ALWAYS_SOFTWARE=1

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

# Ported from test/run_integration.sh verbatim, despite that file's own
# comment saying this swap exists only for -javaagent/java.instrument -
# see this file's header comment on why it's kept here anyway even
# though nothing here attaches a javaagent.
if [ -x "$PROCESSING_HOME/bin/Processing" ] && [ -d "$PROCESSING_HOME/lib/app/resources/jdk" ]; then
  if [ -d "$PROCESSING_HOME/lib/runtime" ] && [ ! -L "$PROCESSING_HOME/lib/runtime" ]; then
    echo "==> Swapping $PROCESSING_HOME/lib/runtime for the bundled full JDK - original kept at lib/runtime.orig"
    mv "$PROCESSING_HOME/lib/runtime" "$PROCESSING_HOME/lib/runtime.orig"
    ln -sfn "$PROCESSING_HOME/lib/app/resources/jdk" "$PROCESSING_HOME/lib/runtime"
  fi
elif [ -x "$PROCESSING_HOME/Processing.exe" ] && [ -d "$PROCESSING_HOME/app/resources/jdk" ]; then
  # Junction (mklink /J), not a symlink: true symlinks need Administrator
  # privileges or Developer Mode on Windows, junctions need neither - see
  # run-with-latest-processing.bat's own use of this same technique.
  # Guarded by runtime.orig's absence rather than `[ -L ... ]`: a
  # junction isn't reliably recognized as a symlink by bash's -L test on
  # Windows.
  if [ -d "$PROCESSING_HOME/runtime" ] && [ ! -d "$PROCESSING_HOME/runtime.orig" ]; then
    echo "==> Swapping $PROCESSING_HOME/runtime for the bundled full JDK - original kept at runtime.orig"
    mv "$PROCESSING_HOME/runtime" "$PROCESSING_HOME/runtime.orig"
    # MSYS_NO_PATHCONV=1 disables Git Bash's automatic POSIX-to-Windows
    # argument rewriting for this one command - without it, /J gets
    # misread as a Unix-style path reference and silently mangled before
    # mklink ever sees it. Plain /c and /J (not //c / //J) are correct
    # here specifically because conversion is switched off entirely for
    # this command, not merely escaped per-argument.
    MSYS_NO_PATHCONV=1 cmd /c mklink /J "$(cygpath -w "$PROCESSING_HOME/runtime")" "$(cygpath -w "$PROCESSING_HOME/app/resources/jdk")" >/dev/null
  fi
fi

if [ "$#" -lt 1 ]; then
  shopt -s nullglob
  for f in command/test/*.svs; do
    set -- "$@" "$(basename "$f" .svs)"
  done
  shopt -u nullglob
  if [ "$#" -lt 1 ]; then
    echo "error: no tests given and no command/test/*.svs files found" >&2
    exit 1
  fi
  echo "==> No tests given - defaulting to every command/test/*.svs: $*"
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
  SCRIPT="command/test/${NAME}.svs"
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
