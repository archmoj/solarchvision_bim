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
mkdir -p "$BUILD_DIR"
"$PROCESSING_HOME/processing-java" --sketch="$SKETCH_DIR" --build --output="$BUILD_DIR"
# --build leaves already-compiled .class files directly under $BUILD_DIR
# (and the merged, preprocessed .java source under $BUILD_DIR/source/) -
# we reuse those .class files as-is rather than recompiling.

CLASSPATH="$CORE_JAR:$JUNIT_JAR:$BUILD_DIR"

echo "==> Compiling tests"
TEST_CLASSES="$BUILD_DIR/test-classes"
mkdir -p "$TEST_CLASSES"
"$JAVAC_BIN" -cp "$CLASSPATH" -d "$TEST_CLASSES" test/*.java

echo "==> Running tests"
"$JAVA_BIN" -cp "$CLASSPATH:$TEST_CLASSES" \
  org.junit.platform.console.ConsoleLauncher \
  --scan-classpath="$TEST_CLASSES" \
  --details=tree
