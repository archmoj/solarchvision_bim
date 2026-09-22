#!/usr/bin/env bash
set -uo pipefail
# Deliberately no `-e`: this script processes each command/test_*.txt
# independently and must keep going past a single test's failure, which is
# fundamentally incompatible with `-e` aborting on the first nonzero exit
# anywhere in the loop - including plain command substitutions with no `||`
# guard, which abort silently with no error message. That already bit two
# different lines here (processing-java's exit code, and a find|sort|tail
# pipeline racing with the JVM's own shutdown/cleanup in the same
# directory). Every real success/failure check below uses its own explicit
# if/exit, so nothing here relies on `-e`.

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
#   PER_SCRIPT_TIMEOUT=600 test/image/run_image_tests.sh    # seconds allowed per script (default 300)
#
# Requires:
#   - PROCESSING_HOME pointing at a Processing 4 install
#     (default: ~/processing/4.3.4, matching .github/workflows/ci.yml's cache path)
#   - python3 with Pillow + numpy installed (for compare_images.py)
#   - a display. On a headless machine/CI, wrap the whole invocation with
#     `xvfb-run --auto-servernum`, e.g.:
#       xvfb-run --auto-servernum test/image/run_image_tests.sh
#     On ubuntu-24.04/ubuntu-latest this crashes the JVM (a JOGL/Mesa ABI
#     issue, not a config problem - see test/image/README.md); use
#     ubuntu-22.04 instead. .github/workflows/image-tests.yml already does.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)" || { echo "could not resolve repo root" >&2; exit 1; }
cd "$REPO_ROOT" || { echo "could not cd to $REPO_ROOT" >&2; exit 1; }

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
PER_SCRIPT_TIMEOUT="${PER_SCRIPT_TIMEOUT:-300}" # seconds allowed per script

mkdir -p "$ACTUAL_DIR" "$DIFF_DIR" "$BASELINE_DIR" || { echo "could not create test/image output dirs" >&2; exit 1; }

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

  # processing-java's exit code isn't a reliable success/failure signal
  # here: Processing's runner returns 1 whenever the sketch calls exit()
  # itself (exactly what USER=AUTO does, on every run, success or not) -
  # see test/image/README.md#note-on-processing-javas-exit-code. Capture it
  # for the log without letting `set -e` abort the loop over it; the real
  # check is "did a screenshot actually appear", right below.
  #
  # Each run also takes a while on its own: frameRate(24) and
  # Last_initializationStep = 1000 in solarchvision_bim.pde mean the intro
  # sequence alone takes >=1000/24 ~= 42s before RUN=... even starts, before
  # JVM/GL startup and the render itself. PER_SCRIPT_TIMEOUT bounds a single
  # stuck run instead of letting it silently eat the whole job's time
  # budget; print start/elapsed so slow runs are visible in the log instead
  # of guessed at.
  start_ts="$(date +%s)"
  echo "  started $(date -u +%H:%M:%S) UTC"
  processing_exit=0
  timeout "$PER_SCRIPT_TIMEOUT" "$PROCESSING_JAVA" --sketch="$SKETCH_DIR" --run --args "USER=AUTO" "RUN=command/$script" || processing_exit=$?
  elapsed=$(( $(date +%s) - start_ts ))
  if [ "$processing_exit" -eq 124 ]; then
    echo "  FAIL: command/$script timed out after ${elapsed}s (PER_SCRIPT_TIMEOUT=${PER_SCRIPT_TIMEOUT})"
    overall_status=1
    continue
  elif [ "$processing_exit" -ne 0 ]; then
    echo "  note: processing-java exited $processing_exit after ${elapsed}s (expected under USER=AUTO; checking for the screenshot instead)"
  else
    echo "  finished after ${elapsed}s"
  fi

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
