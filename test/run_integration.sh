#!/bin/bash
# Attaches JaCoCo coverage to a run-with-processing-4.3.sh/run-with-latest-processing.sh USER=AUTO run (e.g. the
# command/test_*.txt image-regression scripts), and merges the result with
# the unit tests' jacoco.exec into one combined report.
#
# This does NOT modify run-with-processing-4.3.sh/run-with-latest-processing.sh - JAVA_TOOL_OPTIONS is picked
# up by any JVM started while it's set, including the one Processing cli
# spawns internally to run the sketch, so nothing about Processing's own
# launch command needs to change.
#
# Requires test/lib/jacoco/jacocoagent.jar and jacococli.jar - the same
# pair test/install_jacoco.sh fetches for test/run_tests.sh's own coverage
# report, from the official JaCoCo distribution zip (see test/README.md).
#
# This exercises the sketch's real GL rendering pipeline, so it needs a
# display. On Linux, wrap the whole invocation in xvfb-run if there isn't
# a real one:
#   xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" \
#     ./test/run_integration.sh
# Windows runners don't need (or have) an xvfb-run equivalent - GitHub's
# windows-latest image provides a real, if software-rendered, display
# session out of the box.
#
# Usage:
#   ./test/run_integration.sh                          # every command/test_*.txt
#   ./test/run_integration.sh command/test_primitives.txt [more scripts...]
#
# Environment:
#   PROCESSING_HOME       - defaults to ~/processing/4.5.2 (run-with-latest-processing.sh);
#                            point it at a 4.3.4 install instead only if
#                            you specifically want run-with-processing-4.3.sh - see the "Use
#                            Processing 4.5.x if at all possible" comment
#                            below for why that's not the default.
#   JACOCO_AGENT_JAR       - defaults to test/lib/jacoco/jacocoagent.jar
#   UNIT_TEST_EXEC         - defaults to build/test/jacoco.exec (the file
#                             test/run_tests.sh's own coverage run writes) -
#                             merged in automatically if it exists, so the
#                             final report reflects both unit tests AND
#                             every image script given on the command line.
#   JACOCO_CLI_JAR         - defaults to test/lib/jacoco/jacococli.jar
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"
JACOCO_AGENT_JAR="${JACOCO_AGENT_JAR:-test/lib/jacoco/jacocoagent.jar}"
UNIT_TEST_EXEC="${UNIT_TEST_EXEC:-build/test/jacoco.exec}"
OUT_DIR="build/merged-coverage"
export LIBGL_ALWAYS_SOFTWARE=1

if [ ! -f "$JACOCO_AGENT_JAR" ]; then
  echo "error: $JACOCO_AGENT_JAR not found - run test/install_jacoco.sh first" >&2
  exit 1
fi

JACOCO_CLI_JAR="${JACOCO_CLI_JAR:-test/lib/jacoco/jacococli.jar}"
if [ ! -f "$JACOCO_CLI_JAR" ]; then
  echo "error: $JACOCO_CLI_JAR not found - run test/install_jacoco.sh first" >&2
  exit 1
fi

if [ "$#" -lt 1 ]; then
  shopt -s nullglob
  set -- command/test_*.txt
  shopt -u nullglob
  if [ "$#" -lt 1 ]; then
    echo "error: no scripts given and no command/test_*.txt files found" >&2
    exit 1
  fi
  echo "==> No scripts given - defaulting to every command/test_*.txt: $*"
fi

# Pick the same launcher run-with-processing-4.3.sh/run-with-latest-processing.sh/.bat would use, based on
# what's actually under PROCESSING_HOME (see test/run_tests.sh's own
# detection). Windows' Processing.exe reuses the .bat version rather than
# teaching this .sh script Windows path handling too - run-with-latest-processing.bat
# already knows how to find/launch it correctly.
# Use Processing 4.5.x if at all possible - 4.3.4's bundled
# JOGL segfaults during GL context setup on newer Mesa (the same class of
# ABI mismatch noted in .github/workflows/image-tests.yml's comments),
# before any sketch code - including this script's instrumented classes -
# ever runs.
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

# Processing 4.5.x's native launcher (bin/Processing on Linux/macOS,
# Processing.exe on Windows) bundles a jlink runtime trimmed to only
# what Processing itself needs - which excludes java.instrument, so
# -javaagent can never attach to it no matter what flags are passed.
# The same install's full JDK (bundled so it can compile sketches) does
# have java.instrument; swapping the two (once, cheaply reversible) is
# the only way to get a working agent target here.
if [ -x "$PROCESSING_HOME/bin/Processing" ] && [ -d "$PROCESSING_HOME/lib/app/resources/jdk" ]; then
  if [ -d "$PROCESSING_HOME/lib/runtime" ] && [ ! -L "$PROCESSING_HOME/lib/runtime" ]; then
    echo "==> Swapping $PROCESSING_HOME/lib/runtime for the bundled full JDK (java.instrument support) - original kept at lib/runtime.orig"
    mv "$PROCESSING_HOME/lib/runtime" "$PROCESSING_HOME/lib/runtime.orig"
    ln -sfn "$PROCESSING_HOME/lib/app/resources/jdk" "$PROCESSING_HOME/lib/runtime"
  fi
elif [ -x "$PROCESSING_HOME/Processing.exe" ] && [ -d "$PROCESSING_HOME/app/resources/jdk" ]; then
  # Same swap, Windows layout (runtime/ and app/resources/jdk directly
  # under PROCESSING_HOME, no lib/ wrapper - see run-with-latest-processing.bat's
  # own comment on this difference) and a junction (mklink /J) instead
  # of a symlink: creating a true symlink on Windows needs Administrator
  # privileges or Developer Mode, which isn't guaranteed on every
  # runner, while junctions need neither - the same reasoning
  # run-with-latest-processing.bat already uses for its own input/command/projects
  # links. Guarded by runtime.orig's absence rather than `[ -L ... ]`:
  # a junction isn't reliably recognized as a symlink by bash's -L test
  # on Windows, but this still only swaps once either way (re-running
  # it against an already-swapped, cached install would otherwise try
  # to move the junction itself on top of a stale runtime.orig and
  # fail, or silently redo a no-op swap - checking for runtime.orig
  # instead sidesteps both).
  if [ -d "$PROCESSING_HOME/runtime" ] && [ ! -d "$PROCESSING_HOME/runtime.orig" ]; then
    echo "==> Swapping $PROCESSING_HOME/runtime for the bundled full JDK (java.instrument support) - original kept at runtime.orig"
    mv "$PROCESSING_HOME/runtime" "$PROCESSING_HOME/runtime.orig"
    # MSYS_NO_PATHCONV=1 disables Git Bash's automatic POSIX-to-Windows
    # argument rewriting for this one command - without it, /J here (and
    # /c above, if this didn't already sidestep it) gets misread as a
    # Unix-style path reference and silently mangled before mklink ever
    # sees it, the exact same class of bug as e.g. a Windows taskkill
    # /PID flag getting rewritten into a path under Git Bash. Plain /c
    # and /J (not //c/ //J) are correct here specifically because
    # conversion is now switched off entirely for this command, not
    # merely escaped per-argument.
    MSYS_NO_PATHCONV=1 cmd /c mklink /J "$(cygpath -w "$PROCESSING_HOME/runtime")" "$(cygpath -w "$PROCESSING_HOME/app/resources/jdk")" >/dev/null
  fi
fi

mkdir -p "$OUT_DIR"
EXEC_FILES=()
[ -f "$UNIT_TEST_EXEC" ] && EXEC_FILES+=("$UNIT_TEST_EXEC")

for SCRIPT in "$@"; do
  NAME="$(basename "$SCRIPT" .txt)"
  EXEC_FILE="$OUT_DIR/${NAME}.exec"
  echo "==> Running $SCRIPT through ${RUN_CMD[*]} with coverage attached"
  rm -f "$EXEC_FILE"
  # append=true, NOT append=false: JAVA_TOOL_OPTIONS is picked up by every
  # JVM started while it's set, and Processing cli's native (jpackage)
  # launcher spawns an outer driver JVM as well as the inner one that
  # actually runs the sketch - both end up instrumented. append=false
  # means "start this file fresh", so whichever of the two JVMs finishes
  # last truncates whatever the other already wrote, and losing the inner
  # JVM's real coverage data this way is silent (the file still exists,
  # just full of near-nothing) - append=true is what actually keeps both.
  JAVA_TOOL_OPTIONS="-javaagent:$(pwd)/${JACOCO_AGENT_JAR}=destfile=$(pwd)/${EXEC_FILE},includes=solarchvision_bim*,append=true" \
    "${RUN_CMD[@]}" "USER=AUTO" "RUN=${SCRIPT}"
  if [ -s "$EXEC_FILE" ]; then
    echo "    -> wrote $EXEC_FILE ($(stat -c%s "$EXEC_FILE" 2>/dev/null || stat -f%z "$EXEC_FILE") bytes)"
    EXEC_FILES+=("$EXEC_FILE")
  else
    echo "    -> warning: $EXEC_FILE is empty or missing - did the sketch actually run to completion?" >&2
  fi
done

if [ "${#EXEC_FILES[@]}" -eq 0 ]; then
  echo "error: no .exec files were produced - nothing to report" >&2
  exit 1
fi

MAIN_CLASS_PATH="$(find build/test -name 'solarchvision_bim.class' -print -quit)"
if [ -z "$MAIN_CLASS_PATH" ]; then
  echo "error: build/test/solarchvision_bim.class not found - run test/run_tests.sh at least once first" >&2
  exit 1
fi
MAIN_CLASS_DIR="$(dirname "$MAIN_CLASS_PATH")"
SOURCE_FILE_PATH="$(find build/test -name 'solarchvision_bim.java' -print -quit)"
SOURCE_DIR="$(dirname "$SOURCE_FILE_PATH")"

java -jar "$JACOCO_CLI_JAR" merge "${EXEC_FILES[@]}" --destfile "$OUT_DIR/merged.exec"
java -jar "$JACOCO_CLI_JAR" report "$OUT_DIR/merged.exec" \
  --classfiles "$MAIN_CLASS_DIR" \
  --sourcefiles "$SOURCE_DIR" \
  --name solarchvision_bim \
  --html "$OUT_DIR/html" \
  --xml "$OUT_DIR/coverage.xml" \
  --csv "$OUT_DIR/coverage.csv"

echo "==> Coverage report: $OUT_DIR/html/index.html (also: coverage.xml, coverage.csv)"
