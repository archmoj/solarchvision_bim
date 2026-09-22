#!/usr/bin/env python3
"""Generate screenshots for command/test_*.txt by running the
solarchvision_bim sketch headlessly (USER=AUTO), one subprocess per test.

Usage:
  python3 test/image/make_baseline.py                 # generate test/image/actual/*.png for every command/test_*.txt
  python3 test/image/make_baseline.py test_houses ...  # generate specific ones only (name without .txt)
  python3 test/image/make_baseline.py --baseline       # write straight to test/image/baseline/ instead of actual/
                                                        # (review the images before committing them!)

Env vars:
  PROCESSING_HOME     Processing 4 install (default: ~/processing/4.3.4,
                      matching .github/workflows/ci.yml's cache path)
  PER_TEST_TIMEOUT    seconds allowed per attempt (default: 300). Each of
                      the 7 command/test_*.txt scripts needs at least
                      ~1000/24 = ~42s on its own just for the sketch's
                      intro sequence (frameRate(24), Last_initializationStep
                      = 1000 in solarchvision_bim.pde) before RUN=... even
                      starts, on top of JVM/GL startup and the render.
  MAX_RETRY           retries per test after the first attempt (default: 2,
                      i.e. up to 3 attempts total for one test)

Requires a display - wrap with `xvfb-run --auto-servernum` on headless
machines/CI. See test/image/README.md, including why timeouts here kill the
whole process group: processing-java is a plain shell script that runs
`java` as a foreground child (no `exec`), so killing just its own PID on a
timeout leaves the JVM running in the background - across several timed-out
tests that adds up to real resource exhaustion (X11 connections, memory)
that can plausibly explain later tests failing even when they'd have been
fine on their own.
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
SCREENSHOTS_ROOT = os.path.join(SKETCH_DIR, "projects", "model-01", "export", "screenshots")
COMMAND_DIR = os.path.join(REPO_ROOT, "command")
IMAGE_TEST_DIR = os.path.join(REPO_ROOT, "test", "image")
ACTUAL_DIR = os.path.join(IMAGE_TEST_DIR, "actual")
BASELINE_DIR = os.path.join(IMAGE_TEST_DIR, "baseline")

PER_TEST_TIMEOUT = int(os.environ.get("PER_TEST_TIMEOUT", "300"))
MAX_RETRY = int(os.environ.get("MAX_RETRY", "0"))


def discover_tests():
    paths = sorted(glob.glob(os.path.join(COMMAND_DIR, "test_*.txt")))
    return [os.path.splitext(os.path.basename(p))[0] for p in paths]


def find_processing_java():
    home = os.environ.get("PROCESSING_HOME", os.path.expanduser("~/processing/4.3.4"))
    exe = os.path.join(home, "processing-java")
    if not os.path.isfile(exe) or not os.access(exe, os.X_OK):
        print(f"processing-java not found at {exe} (set PROCESSING_HOME to your Processing 4 install)", file=sys.stderr)
        sys.exit(1)
    return exe


def newest_screenshot_since(marker_time):
    """The screenshot this run produced, if any: the newest *.png under
    SCREENSHOTS_ROOT with an mtime after marker_time. Recursive because
    screenshots land under a RunStamp=YYYY MMDD_HH subfolder (globals.pde)."""
    newest_path = None
    newest_mtime = marker_time
    for path in glob.glob(os.path.join(SCREENSHOTS_ROOT, "**", "*.png"), recursive=True):
        try:
            mtime = os.path.getmtime(path)
        except OSError:
            continue
        if mtime > newest_mtime:
            newest_mtime = mtime
            newest_path = path
    return newest_path


def run_once(exe, name):
    """One attempt at one test. Returns the screenshot path produced, or None."""
    marker_time = time.time()
    start = time.time()

    # start_new_session=True puts processing-java (and, crucially, the
    # `java` it runs as a foreground child - see module docstring) in its
    # own process group, so a timeout can kill the whole thing rather than
    # just the shell wrapper and leaving java running.
    proc = subprocess.Popen(
        [exe, f"--sketch={SKETCH_DIR}", "--run", "--args", "USER=AUTO", f"RUN=command/{name}.txt"],
        cwd=REPO_ROOT,
        start_new_session=True,
    )
    try:
        returncode = proc.wait(timeout=PER_TEST_TIMEOUT)
        elapsed = time.time() - start
        # processing-java returns 1 whenever the sketch calls exit() itself
        # (exactly what USER=AUTO does), success or not - not a reliable
        # signal here. The real check is below: did a screenshot appear.
        if returncode != 0:
            print(f"  note: processing-java exited {returncode} after {elapsed:.0f}s (expected under USER=AUTO)")
        else:
            print(f"  processing-java finished after {elapsed:.0f}s")
    except subprocess.TimeoutExpired:
        elapsed = time.time() - start
        print(f"  timed out after {elapsed:.0f}s (PER_TEST_TIMEOUT={PER_TEST_TIMEOUT}), killing process group")
        try:
            os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()
        return None

    return newest_screenshot_since(marker_time)


def make_one(exe, name, out_dir):
    for attempt in range(0, MAX_RETRY + 1):
        screenshot = run_once(exe, name)
        if screenshot:
            dest = os.path.join(out_dir, name + ".png")
            shutil.copyfile(screenshot, dest)
            print(f"  captured: {dest} (from {screenshot})")
            return True
        print(f"  no screenshot produced for command/{name}.txt")
        if attempt < MAX_RETRY:
            print(f"  retry {attempt + 1}/{MAX_RETRY}")
    return False


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("names", nargs="*", help="test names to run (default: all command/test_*.txt)")
    parser.add_argument("--baseline", action="store_true", help="write to test/image/baseline/ instead of test/image/actual/")
    args = parser.parse_args()

    all_tests = discover_tests()
    names = args.names if args.names else all_tests
    unknown = [n for n in names if n not in all_tests]
    if unknown:
        print(f"error: no such test(s): {', '.join(unknown)} (known: {', '.join(all_tests)})", file=sys.stderr)
        sys.exit(1)
    if not names:
        print("error: no command/test_*.txt scripts found", file=sys.stderr)
        sys.exit(1)

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
