#!/bin/bash
# Attaches JaCoCo coverage to a run.sh/run-latest.sh USER=AUTO run (e.g. the
# command/test_*.txt image-regression scripts), and merges the result with
# the unit tests' jacoco.exec into one combined report.
#
# This does NOT modify run.sh/run-latest.sh - JAVA_TOOL_OPTIONS is picked
# up by any JVM started while it's set, including the one processing-java/
# Processing cli spawns internally to run the sketch, so nothing about
# Processing's own launch command needs to change.
#
# Requires test/lib/jacoco/jacocoagent.jar (the same one test/install_jacoco.sh
# would normally fetch - or the hand-built one described in the chat this
# script came out of, if repo1.maven.org isn't reachable in your environment).
# Also requires the "Report" tool (Report.java/.class) from that same
# conversation if you don't have a real jacococli.jar - it exercises the
# same org.jacoco.core/org.jacoco.report APIs jacococli itself does.
#
# This exercises the sketch's real GL rendering pipeline, so it needs a
# display - wrap the whole invocation in xvfb-run if there isn't a real one:
#   xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" \
#     ./test/run_image_coverage.sh command/test_primitives.txt
#
# Usage:
#   ./test/run_image_coverage.sh command/test_primitives.txt [more scripts...]
#
# Environment:
#   PROCESSING_HOME       - defaults to ~/processing/4.3.4 (run.sh) or
#                            ~/processing/4.5.2 (run-latest.sh, if the
#                            legacy processing-java isn't found there)
#   JACOCO_AGENT_JAR       - defaults to test/lib/jacoco/jacocoagent.jar
#   UNIT_TEST_EXEC         - defaults to build/test/jacoco.exec (the file
#                             test/run_tests.sh's own coverage run writes) -
#                             merged in automatically if it exists, so the
#                             final report reflects both unit tests AND
#                             every image script given on the command line.
#   REPORT_CLASSPATH       - classpath for the Report tool (org.jacoco.core +
#                             org.jacoco.report [+ asm, if using unshaded
#                             jars]); only needed if not using a real
#                             jacococli.jar.
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.5.2}"
JACOCO_AGENT_JAR="${JACOCO_AGENT_JAR:-test/lib/jacoco/jacocoagent.jar}"
UNIT_TEST_EXEC="${UNIT_TEST_EXEC:-build/test/jacoco.exec}"
OUT_DIR="build/image-coverage"
export LIBGL_ALWAYS_SOFTWARE=1

if [ ! -f "$JACOCO_AGENT_JAR" ]; then
  echo "error: $JACOCO_AGENT_JAR not found - run test/install_jacoco.sh first" >&2
  exit 1
fi

if [ "$#" -lt 1 ]; then
  echo "usage: $0 command/test_foo.txt [command/test_bar.txt ...]" >&2
  exit 1
fi

# Pick the same launcher run.sh/run-latest.sh would use, based on what's
# actually under PROCESSING_HOME (see test/run_tests.sh's own detection).
# Use Processing 4.5.x (run-latest.sh) if at all possible - 4.3.4's bundled
# JOGL segfaults during GL context setup on newer Mesa (the same class of
# ABI mismatch noted in .github/workflows/image-tests.yml's comments),
# before any sketch code - including this script's instrumented classes -
# ever runs.
if [ -x "$PROCESSING_HOME/bin/Processing" ]; then
  RUN_CMD=(./run-latest.sh)
elif [ -x "$PROCESSING_HOME/processing-java" ]; then
  RUN_CMD=(./run.sh)
  echo "warning: using legacy run.sh (Processing 4.3.4) - known to segfault on newer Mesa; switch to 4.5.x if this happens" >&2
else
  echo "error: neither processing-java nor bin/Processing found under $PROCESSING_HOME" >&2
  exit 1
fi

# Processing 4.5.x's "bin/Processing" is a native jpackage launcher whose
# bundled lib/runtime is a jlink image trimmed to only what Processing
# itself needs - which excludes java.instrument, so -javaagent can never
# attach to it no matter what flags are passed. lib/app/resources/jdk is
# the same install's full JDK (bundled so it can compile sketches) and
# does have java.instrument; swapping the two (once, cheaply reversible)
# is the only way to get a working agent target here.
if [ -x "$PROCESSING_HOME/bin/Processing" ] && [ -d "$PROCESSING_HOME/lib/app/resources/jdk" ]; then
  if [ -d "$PROCESSING_HOME/lib/runtime" ] && [ ! -L "$PROCESSING_HOME/lib/runtime" ]; then
    echo "==> Swapping $PROCESSING_HOME/lib/runtime for the bundled full JDK (java.instrument support) - original kept at lib/runtime.orig"
    mv "$PROCESSING_HOME/lib/runtime" "$PROCESSING_HOME/lib/runtime.orig"
    ln -sfn "$PROCESSING_HOME/lib/app/resources/jdk" "$PROCESSING_HOME/lib/runtime"
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

JACOCO_CLI_JAR="${JACOCO_CLI_JAR:-test/lib/jacoco/jacococli.jar}"
if [ -f "$JACOCO_CLI_JAR" ]; then
  echo "==> Using real jacococli.jar"
  java -jar "$JACOCO_CLI_JAR" merge "${EXEC_FILES[@]}" --destfile "$OUT_DIR/merged.exec"
  java -jar "$JACOCO_CLI_JAR" report "$OUT_DIR/merged.exec" \
    --classfiles "$MAIN_CLASS_DIR" \
    --sourcefiles "$SOURCE_DIR" \
    --name solarchvision_bim \
    --html "$OUT_DIR/html" \
    --xml "$OUT_DIR/coverage.xml" \
    --csv "$OUT_DIR/coverage.csv"
else
  # Fall back to the Report tool from the conversation this script came
  # from - it loads every .exec file straight into one
  # ExecutionDataStore, which does the same job as jacococli's separate
  # "merge" step, so no merged.exec file is needed either way.
  echo "==> jacococli.jar not found - using the Report tool (set REPORT_CLASSPATH if this fails)"
  : "${REPORT_CLASSPATH:?set REPORT_CLASSPATH to org.jacoco.core.jar:org.jacoco.report.jar[:asm-all.jar], and put Report.class on it too}"
  java -cp "$REPORT_CLASSPATH" Report "$MAIN_CLASS_DIR" "$OUT_DIR" solarchvision_bim "$SOURCE_DIR" "${EXEC_FILES[@]}"
fi

echo "==> Coverage report: $OUT_DIR/html/index.html (also: coverage.xml, coverage.csv)"
