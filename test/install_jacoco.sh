#!/bin/bash
# Downloads the JaCoCo distribution zip and unpacks just the two jars
# run_tests.sh actually needs (jacocoagent.jar, jacococli.jar) into
# test/lib/jacoco/ - everything else in the distribution (docs, the
# Ant/OSGi jars, doc examples) is dead weight for a bash+javac setup
# like this one.
set -euo pipefail

LATEST_VERSION=0.8.15
DEST_DIR="lib/jacoco"
ZIP_FILE="/tmp/jacoco-${LATEST_VERSION}.zip"
URL="https://repo1.maven.org/maven2/org/jacoco/jacoco/${LATEST_VERSION}/jacoco-${LATEST_VERSION}.zip"

curl -fL -o "$ZIP_FILE" "$URL"

# Fail loudly if what we got isn't actually a valid zip (e.g. an error
# page saved under the .zip name), instead of leaving a corrupt/partial
# install behind for run_tests.sh to trip over later.
if ! unzip -l "$ZIP_FILE" >/dev/null 2>&1; then
  echo "error: downloaded file is not a valid zip - deleting it" >&2
  rm -f "$ZIP_FILE"
  exit 1
fi

rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR"
unzip -j -o "$ZIP_FILE" "lib/jacocoagent.jar" "lib/jacococli.jar" -d "$DEST_DIR"
rm -f "$ZIP_FILE"

echo "Installed: $DEST_DIR/jacocoagent.jar"
echo "Installed: $DEST_DIR/jacococli.jar"
