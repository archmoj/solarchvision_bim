#!/bin/bash
# Builds app/src/solarchvision_bim with Processing's own compiler (so all
# .pde tabs get preprocessed/merged the same way `run.sh` runs them), then
# compiles and runs the JUnit tests in this folder against the result.
#
# One-time setup:
#   1. Install Processing (matching run.sh's expectation), e.g. under
#      ~/processing/4.3.4, or point PROCESSING_HOME at your install.
#   2. Download junit-platform-console-standalone (any recent 1.x release)
#      from https://search.maven.org/artifact/org.junit.platform/junit-platform-console-standalone
#      and drop the jar anywhere under test/lib/ - its filename normally
#      includes the version (e.g. junit-platform-console-standalone-6.1.3.jar),
#      which is fine, it's picked up automatically below. Set JUNIT_JAR
#      instead if you'd rather point at a jar living somewhere else.
#   3. Optional - for a coverage report, run test/install_jacoco.sh (from
#      inside test/) to drop jacocoagent.jar/jacococli.jar under
#      test/lib/jacoco/. Coverage is skipped, not an error, if these
#      aren't found - only JUnit is required to just run the tests.
#
# Usage:
#   ./test/run_tests.sh
#
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.3.4}"
SKETCH_DIR="app/src/solarchvision_bim"
BUILD_DIR="build/test"
CORE_JAR="$PROCESSING_HOME/core/library/core.jar"

if [ ! -f "$CORE_JAR" ]; then
  echo "error: core.jar not found at $CORE_JAR" >&2
  echo "       set PROCESSING_HOME to your Processing install." >&2
  exit 1
fi

if [ -z "${JUNIT_JAR:-}" ]; then
  # Maven Central always bakes the version into the filename (e.g.
  # junit-platform-console-standalone-6.1.3.jar), so match on the
  # unversioned prefix instead of requiring an exact name.
  JUNIT_JAR="$(find test/lib -maxdepth 1 -name 'junit-platform-console-standalone*.jar' 2>/dev/null | sort -V | tail -n 1)"
fi

if [ -z "${JUNIT_JAR:-}" ] || [ ! -f "$JUNIT_JAR" ]; then
  echo "error: JUnit console launcher not found under test/lib/" >&2
  echo "       download junit-platform-console-standalone-<version>.jar from" >&2
  echo "       https://search.maven.org/artifact/org.junit.platform/junit-platform-console-standalone" >&2
  echo "       and place it there, or set JUNIT_JAR to point at it directly." >&2
  exit 1
fi

echo "==> Using JUnit console launcher: $JUNIT_JAR"

# Coverage is opt-in-by-presence: only enabled when both jars are
# actually there (test/install_jacoco.sh puts them under
# test/lib/jacoco/), so this script still runs with only JUnit
# installed - CI always has jacoco installed (see .github/workflows/ci.yml),
# a local dev who just wants to run the tests doesn't need to.
JACOCO_AGENT_JAR="${JACOCO_AGENT_JAR:-test/lib/jacoco/jacocoagent.jar}"
JACOCO_CLI_JAR="${JACOCO_CLI_JAR:-test/lib/jacoco/jacococli.jar}"
COVERAGE_ENABLED=0
if [ -f "$JACOCO_AGENT_JAR" ] && [ -f "$JACOCO_CLI_JAR" ]; then
  COVERAGE_ENABLED=1
  echo "==> JaCoCo found - coverage report will be generated"
else
  echo "==> JaCoCo not found under test/lib/jacoco/ - skipping coverage (run test/install_jacoco.sh to enable it)"
fi

# javac isn't always on PATH (e.g. a JRE-only install has `java` but not
# `javac`) - fall back to the JDK Processing itself bundles internally
# (it needs one to compile sketches), before giving up.
find_bundled_jdk_bin () {
  local name="$1"
  for candidate in \
    "${JAVA_HOME:-}/bin/$name" \
    "$PROCESSING_HOME/java/bin/$name" \
    "$PROCESSING_HOME/Contents/Java/bin/$name" \
    "$PROCESSING_HOME/jdk/bin/$name"
  do
    if [ -n "$candidate" ] && [ -x "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

JAVAC_BIN="javac"
JAVA_BIN="java"
if ! command -v javac >/dev/null 2>&1; then
  if found="$(find_bundled_jdk_bin javac)"; then
    JAVAC_BIN="$found"
    JAVA_BIN="$(dirname "$found")/java" # keep compile/run on the same JDK
    echo "==> javac not on PATH - using bundled JDK: $JAVAC_BIN"
  else
    echo "error: javac not found on PATH, and no bundled JDK found under \$PROCESSING_HOME." >&2
    echo "       Install a JDK, e.g.:" >&2
    echo "         Ubuntu/Debian: sudo apt install default-jdk" >&2
    echo "         macOS:         brew install openjdk" >&2
    echo "       so javac is on PATH, or set JAVA_HOME to a JDK you already have." >&2
    exit 1
  fi
fi

echo "==> Preprocessing/compiling the sketch (all .pde tabs) with Processing"
rm -rf "$BUILD_DIR"
mkdir -p "$(dirname "$BUILD_DIR")" # only the parent - processing-java creates $BUILD_DIR itself
# --force: without it, processing-java refuses to build at all if the
# output folder already exists (it's meant to create it fresh) - and
# since --build/--run/etc. must be the last argument, --force has to
# come before it.
"$PROCESSING_HOME/processing-java" --sketch="$SKETCH_DIR" --output="$BUILD_DIR" --force --build

# Find wherever --build actually put solarchvision_bim.class, rather than
# assuming a fixed layout (it doesn't reliably land directly in
# $BUILD_DIR - the exact subfolder has varied across Processing
# versions/platforms).
MAIN_CLASS_PATH="$(find "$BUILD_DIR" -name 'solarchvision_bim.class' -print -quit)"

if [ -z "$MAIN_CLASS_PATH" ]; then
  echo "error: could not find solarchvision_bim.class anywhere under $BUILD_DIR" >&2
  echo "       here's everything --build actually produced, for troubleshooting:" >&2
  find "$BUILD_DIR" >&2
  exit 1
fi

MAIN_CLASS_DIR="$(dirname "$MAIN_CLASS_PATH")"

echo "==> Found compiled sketch classes under: $MAIN_CLASS_DIR"

CLASSPATH="$CORE_JAR:$JUNIT_JAR:$MAIN_CLASS_DIR"

echo "==> Compiling tests"
TEST_CLASSES="$BUILD_DIR/test-classes"
mkdir -p "$TEST_CLASSES"
"$JAVAC_BIN" -cp "$CLASSPATH" -d "$TEST_CLASSES" test/*.java

echo "==> Running tests"

# -javaagent has to be a JVM option (before the class/launcher name),
# so it's built as a single optional string and only actually passed
# when coverage is enabled - ${JAVA_AGENT_ARG:+"$JAVA_AGENT_ARG"} below
# expands to nothing at all (not an empty-string argument) when unset,
# and avoids relying on bash-array expansion under `set -u`, which
# isn't reliable on every bash this might run under (e.g. macOS's
# stock bash 3.2).
JAVA_AGENT_ARG=""
JACOCO_EXEC="$BUILD_DIR/jacoco.exec"
if [ "$COVERAGE_ENABLED" -eq 1 ]; then
  rm -f "$JACOCO_EXEC"
  # includes=solarchvision_bim* - every sketch class (the main class
  # itself, plus every .pde tab's non-static inner class, e.g.
  # solarchvision_bim$solarchvision_WIN3D) starts with that prefix;
  # this keeps JUnit/Processing/JDK classes out of the instrumented set
  # and the resulting report.
  JAVA_AGENT_ARG="-javaagent:${JACOCO_AGENT_JAR}=destfile=${JACOCO_EXEC},includes=solarchvision_bim*"
fi

set +e
"$JAVA_BIN" ${JAVA_AGENT_ARG:+"$JAVA_AGENT_ARG"} -cp "$CLASSPATH:$TEST_CLASSES" \
  org.junit.platform.console.ConsoleLauncher execute \
  --scan-classpath="$TEST_CLASSES" \
  --details=tree
TEST_EXIT_CODE=$?
set -e

if [ "$COVERAGE_ENABLED" -eq 1 ]; then
  if [ -f "$JACOCO_EXEC" ]; then
    echo "==> Generating coverage report"
    COVERAGE_DIR="$BUILD_DIR/coverage"
    mkdir -p "$COVERAGE_DIR"
    # --sourcefiles is deliberately omitted: the real source is the
    # .pde tabs, not the single .java file Processing generates from
    # them, so line numbers in a source-annotated HTML view wouldn't
    # line up with anything in app/src/solarchvision_bim/ - the
    # class/method/line/branch percentages below (and in the XML/CSV,
    # for CI tooling) are unaffected by that and still accurate.
    "$JAVA_BIN" -jar "$JACOCO_CLI_JAR" report "$JACOCO_EXEC" \
      --classfiles "$MAIN_CLASS_DIR" \
      --name solarchvision_bim \
      --html "$COVERAGE_DIR/html" \
      --xml "$COVERAGE_DIR/coverage.xml" \
      --csv "$COVERAGE_DIR/coverage.csv"

    echo "==> Coverage report: $COVERAGE_DIR/html/index.html (also: coverage.xml, coverage.csv)"

    # Quick totals across every class JaCoCo tracked, in case nobody
    # opens the HTML report - INSTRUCTION and LINE are the two people
    # most often mean by "coverage %"; BRANCH catches missed if/else
    # arms the other two can look fine while still missing.
    awk -F, '
      NR == 1 { next }
      {
        instr_missed += $4; instr_covered += $5;
        branch_missed += $6; branch_covered += $7;
        line_missed += $8; line_covered += $9;
      }
      END {
        printf "==> Coverage summary:\n";
        printf "      Instructions: %5.1f%% (%d/%d)\n", 100*instr_covered/(instr_covered+instr_missed), instr_covered, instr_covered+instr_missed;
        printf "      Branches:     %5.1f%% (%d/%d)\n", 100*branch_covered/(branch_covered+branch_missed), branch_covered, branch_covered+branch_missed;
        printf "      Lines:        %5.1f%% (%d/%d)\n", 100*line_covered/(line_covered+line_missed), line_covered, line_covered+line_missed;
      }
    ' "$COVERAGE_DIR/coverage.csv"
  else
    echo "==> warning: coverage was enabled but $JACOCO_EXEC was never written (tests may have failed before any ran)" >&2
  fi
fi

exit "$TEST_EXIT_CODE"
