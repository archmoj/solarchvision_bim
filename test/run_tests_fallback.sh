#!/bin/bash
# Same job as run_tests.sh (build the sketch with Processing, compile and
# run the tests in this folder against it), but using
# test/fallback-junit/ in place of a real JUnit jar - see that
# directory's own README.md for why this exists and its limitations.
# Prefer run_tests.sh with a real JUnit jar whenever one is reachable;
# reach for this one specifically when Maven Central (or wherever a real
# junit-platform-console-standalone jar would come from) isn't.
#
# Linux x64 only for the auto-install step below (that's what this was
# built and verified against) - on another platform/architecture, either
# install Processing yourself first and point PROCESSING_HOME at it (see
# test/README.md's own setup instructions), or adapt the download URL
# below to the matching asset name from
# https://github.com/processing/processing4/releases.
#
# Usage:
#   ./test/run_tests_fallback.sh
set -euo pipefail
cd "$(dirname "$0")/.."   # repo root

PROCESSING_HOME="${PROCESSING_HOME:-}"
AUTO_INSTALL_DIR="$HOME/processing/4.4.7"
# A specific, known-good release - pinned rather than "latest" so this
# script's behavior doesn't silently change later. Bump both the tag and
# the version in the asset filename together if you want a newer one;
# check https://github.com/processing/processing4/releases for the
# current tag naming (it's "processing-<numeric-id>-<version>", not just
# "processing-<version>" - the numeric id isn't predictable from the
# version alone).
PROCESSING_RELEASE_TAG="processing-1307-4.4.7"
PROCESSING_RELEASE_ASSET="processing-4.4.7-linux-x64-portable.zip"

find_processing_home () {
  for candidate in "$PROCESSING_HOME" "$HOME/processing/4.3.4" "$AUTO_INSTALL_DIR"; do
    if [ -n "$candidate" ] && { [ -x "$candidate/processing-java" ] || [ -x "$candidate/bin/Processing" ] || [ -x "$candidate/Processing.exe" ]; }; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

if ! PROCESSING_HOME="$(find_processing_home)"; then
  echo "==> No Processing install found - downloading $PROCESSING_RELEASE_ASSET to $AUTO_INSTALL_DIR" >&2
  echo "    (release assets are served from release-assets.githubusercontent.com," >&2
  echo "    which is often reachable even where Maven Central isn't - see" >&2
  echo "    test/fallback-junit/README.md)" >&2
  TMP_ZIP="$(mktemp -t processing-download-XXXXXX.zip)"
  curl -sL -o "$TMP_ZIP" "https://github.com/processing/processing4/releases/download/${PROCESSING_RELEASE_TAG}/${PROCESSING_RELEASE_ASSET}"
  TMP_EXTRACT="$(mktemp -d -t processing-extract-XXXXXX)"
  unzip -q "$TMP_ZIP" -d "$TMP_EXTRACT"
  mkdir -p "$AUTO_INSTALL_DIR"
  # The zip's one top-level folder is named "Processing", not a
  # version string - contents get copied straight into AUTO_INSTALL_DIR
  # rather than keeping that wrapper folder, so find_processing_home's
  # own bin/Processing check lines up.
  cp -r "$TMP_EXTRACT"/*/* "$AUTO_INSTALL_DIR"/
  chmod +x "$AUTO_INSTALL_DIR/bin/Processing"
  rm -rf "$TMP_ZIP" "$TMP_EXTRACT"
  PROCESSING_HOME="$AUTO_INSTALL_DIR"
  echo "==> Installed to $PROCESSING_HOME" >&2
fi

echo "==> Using Processing at: $PROCESSING_HOME"

SKETCH_DIR="src/solarchvision_bim"
BUILD_DIR="build/test"

if [ -x "$PROCESSING_HOME/processing-java" ] || [ -x "$PROCESSING_HOME/processing-java.exe" ]; then
  PROCESSING_STYLE="legacy"
  CORE_JAR="$PROCESSING_HOME/core/library/core.jar"
elif [ -x "$PROCESSING_HOME/bin/Processing" ]; then
  PROCESSING_STYLE="new"
  CORE_JAR="$(find "$PROCESSING_HOME/lib/app/resources/core/library" -maxdepth 1 -name 'core-*.jar' -print -quit 2>/dev/null || true)"
elif [ -x "$PROCESSING_HOME/Processing.exe" ]; then
  PROCESSING_STYLE="new-windows"
  CORE_JAR="$(find "$PROCESSING_HOME/app/resources/core/library" -maxdepth 1 -name 'core-*.jar' -print -quit 2>/dev/null || true)"
else
  echo "error: no processing-java, bin/Processing, or Processing.exe found under $PROCESSING_HOME" >&2
  exit 1
fi

if [ -z "${CORE_JAR:-}" ] || [ ! -f "$CORE_JAR" ]; then
  echo "error: core.jar not found under $PROCESSING_HOME" >&2
  exit 1
fi

# javac isn't always on PATH - fall back to the JDK Processing bundles
# internally (it needs one to compile sketches), same as run_tests.sh.
find_bundled_jdk_bin () {
  local name="$1"
  for candidate in \
    "${JAVA_HOME:-}/bin/$name" \
    "$PROCESSING_HOME/java/bin/$name" \
    "$PROCESSING_HOME/Contents/Java/bin/$name" \
    "$PROCESSING_HOME/jdk/bin/$name" \
    "$PROCESSING_HOME/lib/app/resources/jdk/bin/$name" \
    "$PROCESSING_HOME/app/resources/jdk/bin/$name.exe"
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
    case "$found" in
      *.exe) JAVA_BIN="$(dirname "$found")/java.exe" ;;
      *)     JAVA_BIN="$(dirname "$found")/java" ;;
    esac
    echo "==> javac not on PATH - using bundled JDK: $JAVAC_BIN"
  else
    echo "error: javac not found on PATH, and no bundled JDK found under \$PROCESSING_HOME." >&2
    exit 1
  fi
fi

echo "==> Preprocessing/compiling the sketch (all .pde tabs) with Processing ($PROCESSING_STYLE style)"
rm -rf "$BUILD_DIR"
mkdir -p "$(dirname "$BUILD_DIR")"
if [ "$PROCESSING_STYLE" = "legacy" ]; then
  "$PROCESSING_HOME/processing-java" --sketch="$SKETCH_DIR" --output="$BUILD_DIR" --force --build
elif [ "$PROCESSING_STYLE" = "new-windows" ]; then
  "$PROCESSING_HOME/Processing.exe" cli --sketch="$SKETCH_DIR" --output="$BUILD_DIR" --force --build
else
  "$PROCESSING_HOME/bin/Processing" cli --sketch="$SKETCH_DIR" --output="$BUILD_DIR" --force --build
fi

MAIN_CLASS_PATH="$(find "$BUILD_DIR" -name 'solarchvision_bim.class' -print -quit)"
if [ -z "$MAIN_CLASS_PATH" ]; then
  echo "error: could not find solarchvision_bim.class anywhere under $BUILD_DIR" >&2
  find "$BUILD_DIR" >&2
  exit 1
fi
MAIN_CLASS_DIR="$(dirname "$MAIN_CLASS_PATH")"
echo "==> Found compiled sketch classes under: $MAIN_CLASS_DIR"

FALLBACK_JUNIT_SRC="test/fallback-junit/src"
FALLBACK_JUNIT_CLASSES="build/fallback-junit-classes"
echo "==> Compiling the fallback JUnit stub"
rm -rf "$FALLBACK_JUNIT_CLASSES"
mkdir -p "$FALLBACK_JUNIT_CLASSES"
"$JAVAC_BIN" -encoding UTF-8 -d "$FALLBACK_JUNIT_CLASSES" $(find "$FALLBACK_JUNIT_SRC" -name '*.java')

CLASSPATH="$CORE_JAR:$MAIN_CLASS_DIR:$FALLBACK_JUNIT_CLASSES"

echo "==> Compiling tests"
TEST_CLASSES="build/test-classes-fallback"
rm -rf "$TEST_CLASSES"
mkdir -p "$TEST_CLASSES"
"$JAVAC_BIN" -encoding UTF-8 -cp "$CLASSPATH" -d "$TEST_CLASSES" test/*.java

echo "==> Running tests"
set +e
"$JAVA_BIN" -cp "$CLASSPATH:$TEST_CLASSES" TestRunner "$TEST_CLASSES"
TEST_EXIT_CODE=$?
set -e

exit "$TEST_EXIT_CODE"
