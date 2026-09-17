#!/bin/bash
set -euo pipefail

LATEST_VERSION=6.1.3
DEST_DIR="lib"
DEST_FILE="${DEST_DIR}/junit-platform-console-standalone-${LATEST_VERSION}.jar"
URL="https://repo1.maven.org/maven2/org/junit/platform/junit-platform-console-standalone/${LATEST_VERSION}/junit-platform-console-standalone-${LATEST_VERSION}.jar"

# mkdir -p "$DEST_DIR"
curl -fL -o "$DEST_FILE" "$URL"

# Fail loudly if what we got isn't actually a valid jar/zip (e.g. an
# error page saved under the .jar name), instead of leaving a corrupt
# file behind for run_tests.sh to trip over later.
if ! unzip -l "$DEST_FILE" >/dev/null 2>&1; then
  echo "error: downloaded file is not a valid jar - deleting it" >&2
  rm -f "$DEST_FILE"
  exit 1
fi

echo "Installed: $DEST_FILE"
