#!/usr/bin/env python3
"""Generate screenshots for command/test_*.txt by running the
solarchvision_bim sketch headlessly (USER=AUTO), one subprocess per test.
A single test script can call REC.png more than once, each with its own
name given right in the script (see command/test_views.txt), so one test
can produce several screenshots - each is kept under its own original
filename rather than the test's.

Usage:
  python3 test/image/make_baseline.py                 # generate test/image/actual/*.png for every command/test_*.txt
  python3 test/image/make_baseline.py test_houses ...  # generate specific ones only (name without .txt)
  python3 test/image/make_baseline.py --baseline       # write straight to test/image/baseline/ instead of actual/
                                                        # (review the images before committing them!)

Env vars:
  PROCESSING_HOME     Processing 4 install (default: ~/processing/4.5.2,
                      matching .github/workflows/image-tests.yml's cache
                      path). Runs `$PROCESSING_HOME/bin/Processing cli
                      --sketch=... --run USER=AUTO RUN=...`.
  PER_TEST_TIMEOUT    seconds allowed per attempt (default: 300)
  MAX_RETRY           retries per test after the first attempt (default: 2,
                      i.e. up to 3 attempts total for one test)
  SHARD_INDEX,        run only every SHARD_TOTAL-th test (0-based, i.e. the
  SHARD_TOTAL         tests where index % SHARD_TOTAL == SHARD_INDEX), for
                      running generation across several parallel CI jobs/
                      containers - same striping plotly.js's
                      .github/scripts/split_files.mjs uses. Both must be
                      set together; unset (the default) runs everything in
                      one process. Applied after any explicit test names on
                      the command line, so `make_baseline.py test_a test_b`
                      with SHARD_TOTAL=2 still splits just those two.

Requires a display - wrap with `xvfb-run --auto-servernum` on headless
machines/CI. Also requires input/, command/, and projects/ to be symlinked
into Processing's own install directory first - see test/image/README.md.
"""
import argparse
import glob
import os
import shutil
import signal
import subprocess
import sys
import time

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SKETCH_DIR = os.path.join(REPO_ROOT, "app", "src", "solarchvision_bim")
# sketchPath() (used as BaseFolder in update_folders.pde) resolves to
# Processing's own install directory ($PROCESSING_HOME/lib/app/resources/
# core), not REPO_ROOT - see test/image/README.md for why and the symlink
# workaround this relies on. Search both that location and REPO_ROOT so a
# future change in either direction doesn't silently break this again.
SCREENSHOTS_ROOTS = [
    os.path.join(REPO_ROOT, "projects", "model-01", "export", "screenshots"),
    os.path.join(SKETCH_DIR, "projects", "model-01", "export", "screenshots"),
]
COMMAND_DIR = os.path.join(REPO_ROOT, "command")
IMAGE_TEST_DIR = os.path.join(REPO_ROOT, "test", "image")
ACTUAL_DIR = os.path.join(IMAGE_TEST_DIR, "actual")
BASELINE_DIR = os.path.join(IMAGE_TEST_DIR, "baseline")

PER_TEST_TIMEOUT = int(os.environ.get("PER_TEST_TIMEOUT", "300"))
MAX_RETRY = int(os.environ.get("MAX_RETRY", "2"))


def discover_tests():
    paths = sorted(glob.glob(os.path.join(COMMAND_DIR, "test_*.txt")))
    return [os.path.splitext(os.path.basename(p))[0] for p in paths]


def shard_slice(names):
    """Same striping as plotly.js's .github/scripts/split_files.mjs:
    element i goes to shard (i % SHARD_TOTAL). Both env vars must be set
    together; if neither is, every name passes through unchanged."""
    index_raw = os.environ.get("SHARD_INDEX")
    total_raw = os.environ.get("SHARD_TOTAL")
    if index_raw is None and total_raw is None:
        return names
    try:
        index = int(index_raw)
        total = int(total_raw)
    except (TypeError, ValueError):
        print("error: SHARD_INDEX and SHARD_TOTAL must both be set to valid integers", file=sys.stderr)
        sys.exit(1)
    if total <= 0 or not (0 <= index < total):
        print(f"error: invalid SHARD_INDEX={index_raw} / SHARD_TOTAL={total_raw} (need 0 <= SHARD_INDEX < SHARD_TOTAL)", file=sys.stderr)
        sys.exit(1)
    return [name for i, name in enumerate(names) if i % total == index]


def find_processing_java():
    home = os.environ.get("PROCESSING_HOME", os.path.expanduser("~/processing/4.5.2"))
    exe = os.path.join(home, "bin", "Processing")
    if not os.path.isfile(exe) or not os.access(exe, os.X_OK):
        print(f"Processing CLI launcher not found at {exe} (set PROCESSING_HOME to your Processing 4.5.x install)", file=sys.stderr)
        sys.exit(1)
    return exe


def screenshots_since(marker_time):
    """Every screenshot this run produced, oldest first: all *.png under any
    of SCREENSHOTS_ROOTS with an mtime after marker_time. Recursive because
    screenshots land under a RunStamp=YYYYMMDD_HH subfolder (globals.pde).
    A single command/test_*.txt can call REC.png several times, each with
    its own name given right in the script (see command/test_views.txt),
    so one test run can produce many screenshots - not just one - and
    every one of them is returned here."""
    found = []
    for root in SCREENSHOTS_ROOTS:
        for path in glob.glob(os.path.join(root, "**", "*.png"), recursive=True):
            try:
                mtime = os.path.getmtime(path)
            except OSError:
                continue
            if mtime > marker_time:
                found.append((mtime, path))
    found.sort(key=lambda item: item[0])
    return [path for _, path in found]


def run_once(exe, name):
    """One attempt at one test. Returns the list of screenshot paths
    produced (possibly more than one - see screenshots_since()), or an
    empty list if none were."""
    marker_time = time.time()
    start = time.time()

    # start_new_session=True puts this process (and anything it launches)
    # in its own process group, so a timeout can kill the whole thing
    # rather than leaving something running in the background.
    proc = subprocess.Popen(
        [exe, "cli", f"--sketch={SKETCH_DIR}", "--run", "USER=AUTO", f"RUN=command/{name}.txt"],
        cwd=REPO_ROOT,
        start_new_session=True,
    )

    try:
        returncode = proc.wait(timeout=PER_TEST_TIMEOUT)
        elapsed = time.time() - start
        # A nonzero exit isn't necessarily a failure here (e.g. how the
        # sketch calls exit() itself under USER=AUTO can vary by Processing
        # version) - it's logged, but the real check is "did a screenshot
        # appear", below.
        if returncode != 0:
            print(f"  note: Processing exited {returncode} after {elapsed:.0f}s")
        else:
            print(f"  Processing finished after {elapsed:.0f}s")
    except subprocess.TimeoutExpired:
        elapsed = time.time() - start
        print(f"  timed out after {elapsed:.0f}s (PER_TEST_TIMEOUT={PER_TEST_TIMEOUT}), killing process group")
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()
        return []

    return screenshots_since(marker_time)


def make_one(exe, name, out_dir):
    for attempt in range(0, MAX_RETRY + 1):
        screenshots = run_once(exe, name)
        if screenshots:
            # Keep each screenshot's own filename - the one given right in
            # command/test_*.txt's REC.png lines (see command/test_views.txt) -
            # rather than renaming it after the test file, since one test
            # can produce several distinctly-named screenshots.
            for screenshot in screenshots:
                dest = os.path.join(out_dir, os.path.basename(screenshot))
                shutil.copyfile(screenshot, dest)
                print(f"  captured: {dest} (from {screenshot})")
            return True
        print(f"  no screenshots produced for command/{name}.txt")
        if attempt < MAX_RETRY:
            print(f"  retry {attempt + 1}/{MAX_RETRY}")
    return False


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*", help="test names to run (default: all command/test_*.txt)")
    parser.add_argument("--baseline", action="store_true", help="write to test/image/baseline/ instead of test/image/actual/")
    args = parser.parse_args()

    all_tests = discover_tests()
    if not all_tests:
        print("error: no command/test_*.txt scripts found", file=sys.stderr)
        sys.exit(1)

    names = args.names if args.names else all_tests
    unknown = [n for n in names if n not in all_tests]
    if unknown:
        print(f"error: no such test(s): {', '.join(unknown)} (known: {', '.join(all_tests)})", file=sys.stderr)
        sys.exit(1)

    names = shard_slice(names)
    if os.environ.get("SHARD_TOTAL") is not None:
        print(f"shard {os.environ.get('SHARD_INDEX')}/{os.environ.get('SHARD_TOTAL')}: {len(names)} test(s): {', '.join(names) or '(none)'}")
        if not names:
            # A legitimately empty shard (SHARD_TOTAL > test count) isn't a
            # failure - nothing to do here, exit cleanly.
            return

    out_dir = BASELINE_DIR if args.baseline else ACTUAL_DIR
    os.makedirs(out_dir, exist_ok=True)

    exe = find_processing_java()

    failed = []
    for name in names:
        print(f"== {name} ==", flush=True)
        if not make_one(exe, name, out_dir):
            failed.append(name)

    print()
    print(f"{len(names) - len(failed)}/{len(names)} succeeded")
    if failed:
        print("Failed:", ", ".join(failed))
        sys.exit(1)


if __name__ == "__main__":
    main()
