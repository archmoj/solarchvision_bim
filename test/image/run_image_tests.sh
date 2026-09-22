#!/usr/bin/env bash
set -euo pipefail

# Runs every command/test_*.txt script through the solarchvision_bim sketch
# in headless `USER=AUTO` mode (see app/src/solarchvision_bim/parseArgs.pde),
# captures the single screenshot each one produces (each script now ends in
# exactly one REC.* command), and compares it against
# test/image/baseline/<name>.png with compare_images.py.
#
# Usage:
#   test/image/run_image_tests.sh                      # run + compare every command/test_*.txt
#   test/image/run_image_tests.sh test_houses.txt ...   # run + compare specific scripts only
#   UPDATE_BASELINES=1 test/image/run_image_tests.sh    # (re)generate baselines instead of comparing
#   STRICT=1 test/image/run_image_tests.sh              # fail (not just warn) when a baseline is missing
#   IMAGE_DIFF_THRESHOLD=1.0 test/image/run_image_tests.sh  # allow up to 1% of pixels to differ
#
# Requires:
#   - PROCESSING_HOME pointing at a Processing 4 install
#     (default: ~/processing/4.3.4, matching .github/workflows/ci.yml's cache path)
#   - python3 with Pillow + numpy installed (for compare_images.py)
#   - a display. On a headless machine/CI, wrap the whole invocation with
#     `xvfb-run --auto-servernum`, e.g.:
#       xvfb-run --auto-servernum test/image/run_image_tests.sh
#     See test/image/README.md for troubleshooting if the sketch's OpenGL
#     (P3D) context crashes under Xvfb.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

PROCESSING_HOME="${PROCESSING_HOME:-$HOME/processing/4.3.4}"
PROCESSING_JAVA="$PROCESSING_HOME/processing-java"

SKETCH_DIR="app/src/solarchvision_bim"
SCREENSHOTS_ROOT="$SKETCH_DIR/projects/model-01/export/screenshots"

IMAGE_TEST_DIR="test/image"
BASELINE_DIR="$IMAGE_TEST_DIR/baseline"
ACTUAL_DIR="$IMAGE_TEST_DIR/actual"
DIFF_DIR="$IMAGE_TEST_DIR/diff"

UPDATE_BASELINES="${UPDATE_BASELINES:-0}"
STRICT="${STRICT:-0}"
THRESHOLD="${IMAGE_DIFF_THRESHOLD:-0.5}" # max % of pixels allowed to differ

mkdir -p "$ACTUAL_DIR" "$DIFF_DIR" "$BASELINE_DIR"

if [ ! -x "$PROCESSING_JAVA" ]; then
  echo "processing-java not found at $PROCESSING_JAVA (set PROCESSING_HOME to your Processing 4 install)" >&2
  exit 1
fi

if [ "$#" -gt 0 ]; then
  SCRIPTS=("$@")
else
  SCRIPTS=()
  while IFS= read -r -d '' f; do
    SCRIPTS+=("$(basename "$f")")
  done < <(find command -maxdepth 1 -name 'test_*.txt' -print0 | sort -z)
fi

if [ "${#SCRIPTS[@]}" -eq 0 ]; then
  echo "No command/test_*.txt scripts found." >&2
  exit 1
fi

overall_status=0

for script in "${SCRIPTS[@]}"; do
  name="${script%.txt}"
  echo "== $name =="

  if [ ! -f "command/$script" ]; then
    echo "  FAIL: command/$script not found"
    overall_status=1
    continue
  fi

  # Timestamp taken right before the run, so we can pick out whichever
  # screenshot this run produced even if an earlier run this hour left
  # files behind in the same RunStamp folder (see globals.pde/RunStamp).
  marker="$(mktemp)"

  "$PROCESSING_JAVA" --sketch="$SKETCH_DIR" --run --args "USER=AUTO" "RUN=command/$script"

  new_png="$(find "$SCREENSHOTS_ROOT" -name '*.png' -newer "$marker" -print 2>/dev/null | sort | tail -n 1)"
  rm -f "$marker"

  if [ -z "$new_png" ]; then
    echo "  FAIL: no screenshot produced for command/$script (check that it ends in exactly one REC.png)"
    overall_status=1
    continue
  fi

  actual="$ACTUAL_DIR/$name.png"
  cp "$new_png" "$actual"
  echo "  captured: $actual (from $new_png)"

  if [ "$UPDATE_BASELINES" = "1" ]; then
    cp "$actual" "$BASELINE_DIR/$name.png"
    echo "  baseline updated: $BASELINE_DIR/$name.png (review it before committing!)"
    continue
  fi

  baseline="$BASELINE_DIR/$name.png"
  if [ ! -f "$baseline" ]; then
    msg="no baseline yet at $baseline (run with UPDATE_BASELINES=1 once the image looks right, review it, then commit it)"
    if [ "$STRICT" = "1" ]; then
      echo "  FAIL: $msg"
      overall_status=1
    else
      echo "  WARN: $msg"
    fi
    continue
  fi

  if ! python3 "$IMAGE_TEST_DIR/compare_images.py" "$baseline" "$actual" "$DIFF_DIR/$name.png" --threshold "$THRESHOLD"; then
    overall_status=1
  fi
done

exit $overall_status
