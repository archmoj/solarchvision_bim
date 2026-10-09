#!/bin/bash
# Attaches JaCoCo coverage to a test/image/make_baseline.sh USER=AUTO run
# (e.g. the command/test/*.svs image-regression scripts), and merges the
# result with the unit tests' jacoco.exec into one combined report.
#
# Delegates the actual "find Processing, run it, know what it takes to
# get rendering working at all" work entirely to
# test/image/make_baseline.sh, rather than duplicating that here a second
# time. This file used to carry its own copy of the launcher detection
# and the java.instrument runtime swap - which turned out to be exactly
# the kind of duplication that bites: make_baseline.sh needed
# LIBGL_ALWAYS_SOFTWARE and that same runtime swap too, for reasons that
# took several rounds to track down, and this file's own copy of both was
# the only reason either was known to work in the first place. One copy
# now, not two. JAVA_TOOL_OPTIONS is picked up by any JVM started while
# it's set, including the one make_baseline.sh's own launcher spawns
# internally to run the sketch, so nothing about that script needs to
# change to make -javaagent attach here.
#
# Requires test/lib/jacoco/jacocoagent.jar and jacococli.jar - the same
# pair test/install_jacoco.sh fetches for test/run_tests.sh's own coverage
# report, from the official JaCoCo distribution zip (see test/README.md).
#
# This exercises the sketch's real GL rendering pipeline, so it needs a
# display - see test/image/make_baseline.sh's own comment on this.
#
# Usage:
#   ./test/run_integration.sh                          # every command/test/*.svs
#   ./test/run_integration.sh command/test/primitives.svs [more scripts...]
#
# Environment:
#   PROCESSING_HOME   - defaults to ~/processing/4.5.2 - see
#                       test/image/make_baseline.sh's own comment on this.
#   JACOCO_AGENT_JAR  - defaults to test/lib/jacoco/jacocoagent.jar
#   UNIT_TEST_EXEC    - defaults to build/test/jacoco.exec (the file
#                       test/run_tests.sh's own coverage run writes) -
#                       merged in automatically if it exists, so the
#                       final report reflects both unit tests AND every
#                       image script given on the command line.
#   JACOCO_CLI_JAR    - defaults to test/lib/jacoco/jacococli.jar
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

JACOCO_AGENT_JAR="${JACOCO_AGENT_JAR:-test/lib/jacoco/jacocoagent.jar}"
UNIT_TEST_EXEC="${UNIT_TEST_EXEC:-build/test/jacoco.exec}"
OUT_DIR="build/merged-coverage"

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
  set -- command/test/*.svs
  shopt -u nullglob
  if [ "$#" -lt 1 ]; then
    echo "error: no scripts given and no command/test/*.svs files found" >&2
    exit 1
  fi
  echo "==> No scripts given - defaulting to every command/test/*.svs: $*"
fi

mkdir -p "$OUT_DIR"
EXEC_FILES=()
[ -f "$UNIT_TEST_EXEC" ] && EXEC_FILES+=("$UNIT_TEST_EXEC")

# JAVA_TOOL_OPTIONS is an environment variable, not a command-line
# argument - Git Bash's automatic POSIX-to-Windows path conversion only
# ever applies to argv, so a path built with $(pwd) here stays exactly as
# POSIX-style as it started, and the native java.exe this eventually
# reaches can't open "/d/a/.../jacocoagent.jar" (same root cause as the
# classpath and mklink issues this project hit elsewhere, just hitting an
# env var this time instead of argv). cygpath -m (not -w) specifically to
# get forward slashes - sidesteps any question of whether a backslash
# survives bash's own string handling untouched, and Java accepts forward
# slashes in paths on Windows natively either way.
to_native_path () {
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*) cygpath -m "$1" ;;
    *)                    printf '%s' "$1" ;;
  esac
}

for SCRIPT in "$@"; do
  NAME="$(basename "$SCRIPT" .svs)"
  EXEC_FILE="$OUT_DIR/${NAME}.exec"
  echo "==> Running $SCRIPT through test/image/make_baseline.sh with coverage attached"
  rm -f "$EXEC_FILE"

  # append=true, NOT append=false: JAVA_TOOL_OPTIONS is picked up by every
  # JVM started while it's set, and Processing cli's native (jpackage)
  # launcher spawns an outer driver JVM as well as the inner one that
  # actually runs the sketch - both end up instrumented. append=false
  # means "start this file fresh", so whichever of the two JVMs finishes
  # last truncates whatever the other already wrote, and losing the inner
  # JVM's real coverage data this way is silent (the file still exists,
  # just full of near-nothing) - append=true is what actually keeps both.
  #
  # || true: make_baseline.sh's own idea of failure is "no screenshot
  # after every retry", which doesn't necessarily mean no coverage was
  # written - checked independently right below regardless - and letting
  # `set -e` abort the whole run here would lose every other script's
  # coverage too, not just this one's.
  JAVA_TOOL_OPTIONS="-javaagent:$(to_native_path "$(pwd)/${JACOCO_AGENT_JAR}")=destfile=$(to_native_path "$(pwd)/${EXEC_FILE}"),includes=solarchvision_bim*,append=true" \
    bash test/image/make_baseline.sh "$NAME" || true

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
