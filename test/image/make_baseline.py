#!/usr/bin/env python3
"""Generate screenshots for command/test_*.txt by running the
solarchvision_bim sketch headlessly (USER=AUTO), one subprocess per test.

Usage:
  python3 test/image/make_baseline.py                 # generate test/image/actual/*.png for every command/test_*.txt
  python3 test/image/make_baseline.py test_houses ...  # generate specific ones only (name without .txt)
  python3 test/image/make_baseline.py --baseline       # write straight to test/image/baseline/ instead of actual/
                                                        # (review the images before committing them!)

Env vars:
  PROCESSING_HOME     Processing 4 install (default: ~/processing/4.5.2,
                      matching .github/workflows/ci.yml's cache path). Runs
                      `$PROCESSING_HOME/bin/Processing cli --sketch=... --run
                      USER=AUTO RUN=...` - the 4.5.x CLI, a full rewrite of
                      the old `processing-java` shell script (removed in
                      this version). See test/image/README.md's "Note on
                      upgrading Processing" for what changed and why.
  PER_TEST_TIMEOUT    seconds allowed per attempt (default: 300)
  MAX_RETRY           retries per test after the first attempt (default: 2,
                      i.e. up to 3 attempts total for one test)

Requires a display - wrap with `xvfb-run --auto-servernum` on headless
machines/CI. Also requires test/image/README.md's "Note on upgrading
Processing" symlink workaround to already be set up (input/, command/, and
projects/ linked into Processing's own install directory) - without it the
sketch can't find its own asset files.
"""
import argparse
import glob
import os
import shutil
import signal
import subprocess
import sys
import threading
import time

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SKETCH_DIR = os.path.join(REPO_ROOT, "app", "src", "solarchvision_bim")
# sketchPath() (used as BaseFolder in update_folders.pde) resolves to
# REPO_ROOT with the old processing-java CLI (confirmed from an actual CI
# run's "Saving: .../solarchvision_bim/projects/model-01/export/..." log
# line), but to Processing's own install directory
# ($PROCESSING_HOME/lib/app/resources/core) with the new 4.5.x `Processing
# cli` tool - a real behavior difference between the two, not just a path
# assumption bug on our end this time. See test/image/README.md's "Note on
# upgrading Processing": input/, command/, and projects/ are symlinked into
# that install-relative location so the sketch's own asset loading (and our
# screenshot search below) both keep working. Search both roots regardless,
# so a future change in either direction doesn't silently break this again.
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


def find_processing_java():
    home = os.environ.get("PROCESSING_HOME", os.path.expanduser("~/processing/4.5.2"))
    exe = os.path.join(home, "bin", "Processing")
    if not os.path.isfile(exe) or not os.access(exe, os.X_OK):
        print(f"Processing CLI launcher not found at {exe} (set PROCESSING_HOME to your Processing 4.5.x install)", file=sys.stderr)
        sys.exit(1)
    return exe


def newest_screenshot_since(marker_time):
    """The screenshot this run produced, if any: the newest *.png under any
    of SCREENSHOTS_ROOTS with an mtime after marker_time. Recursive because
    screenshots land under a RunStamp=YYYYMMDD_HH subfolder (globals.pde)."""
    newest_path = None
    newest_mtime = marker_time
    for root in SCREENSHOTS_ROOTS:
        for path in glob.glob(os.path.join(root, "**", "*.png"), recursive=True):
            try:
                mtime = os.path.getmtime(path)
            except OSError:
                continue
            if mtime > newest_mtime:
                newest_mtime = mtime
                newest_path = path
    return newest_path


def find_descendant_pids(root_pid):
    """Every descendant of root_pid (children, grandchildren, ...), by
    scanning /proc/*/stat for every process's ppid and building the whole
    tree at once (Linux only, which is all CI runs here).

    Built while diagnosing a severe slowdown in Processing 4.3.4's
    "Commander" tool, which didn't run the sketch in the JVM that compiled
    it - it compiled in one JVM, then launched a *second*, separate JVM
    process to actually run the sketch, monitored over JDI, with the first
    JVM's main thread just sitting in a Thread.join() waiting for it. That
    slowdown is resolved by upgrading to Processing 4.5.x (see
    test/image/README.md's "Note on upgrading Processing"), so this and
    THREAD_DUMP_DELAY_SECONDS below aren't needed for normal use anymore -
    kept as a general diagnostic if something like it ever comes up again.

    Originally tried reading /proc/<pid>/task/<pid>/children directly
    (simpler, one lookup per level) instead of this full-tree scan, but a
    real CI dump showed that file returning no children for a process a
    thread dump proved had launched one (a thread blocked in
    ProcessImpl.waitFor()) - unreliable here for reasons not fully
    understood, possibly a timing race against a multi-threaded parent.
    Scanning /proc/*/stat directly (ppid is a plain, always-populated field
    - see `man proc`) doesn't depend on that file at all.
    """
    children_of = {}
    for entry in os.listdir("/proc"):
        if not entry.isdigit():
            continue
        try:
            with open(f"/proc/{entry}/stat") as f:
                stat = f.read()
            # Format: "pid (comm) state ppid ...". comm can itself contain
            # spaces/parens, so split off everything after the LAST ')'.
            fields_after_comm = stat.rsplit(")", 1)[1].split()
            ppid = int(fields_after_comm[1])  # [0] is state, [1] is ppid
            children_of.setdefault(ppid, []).append(int(entry))
        except (FileNotFoundError, ProcessLookupError, IndexError, ValueError):
            continue

    all_descendants = []
    frontier = [root_pid]
    while frontier:
        next_frontier = []
        for p in frontier:
            next_frontier.extend(children_of.get(p, []))
        all_descendants.extend(next_frontier)
        frontier = next_frontier
    return all_descendants


def run_once(exe, name):
    """One attempt at one test. Returns the screenshot path produced, or None."""
    marker_time = time.time()
    start = time.time()

    # start_new_session=True puts this process (and any JVM(s) it launches)
    # in its own process group, so a timeout/SIGQUIT can target the right
    # thing rather than orphaning something. The old processing-java shell
    # script definitely ran java as a non-exec'd foreground child, which is
    # exactly how that orphaning happened for real (see find_descendant_pids
    # above); the new 4.5.x `Processing` binary is a jpackage-built native
    # launcher, a different enough process model that this may not apply the
    # same way - not specifically confirmed either way, so the same
    # defensive handling is kept regardless.
    proc = subprocess.Popen(
        [exe, "cli", f"--sketch={SKETCH_DIR}", "--run", "USER=AUTO", f"RUN=command/{name}.txt"],
        cwd=REPO_ROOT,
        start_new_session=True,
    )

    # Diagnostic only, off by default: if set, send SIGQUIT to every
    # descendant process (found via find_descendant_pids - NOT the whole
    # process group, see below) this many seconds after starting, which
    # makes each JVM among them print a full thread dump (every thread's
    # stack, including native frames) to stdout and then keep running -
    # unlike SIGTERM/SIGKILL, SIGQUIT does not stop it. Used to see exactly
    # what a slow call is actually blocked on, instead of guessing from
    # source reading alone. Sent to every descendant, not just the deepest
    # one, since which JVM is actually running the sketch isn't assumed -
    # a dump of the wrong process (e.g. the Commander JVM sitting in
    # Runner.generateTrace()'s Thread.join(), waiting on the real one) is
    # nearly free to get and easy to tell apart from the real one by its
    # stack, so getting both is safer than guessing which pid matters.
    # Pick a delay past setup/intro (a few seconds) and comfortably before
    # PER_TEST_TIMEOUT.
    #
    # Deliberately NOT os.killpg(...): that broadcasts to the whole process
    # group, which includes the processing-java bash wrapper as well as the
    # java process(es) it runs in the foreground. Those java processes
    # handle SIGQUIT specially (dump + keep running) but the wrapper does
    # not trap it, so the wrapper dies immediately from its default
    # disposition - orphaning java, which keeps running unmonitored while
    # this script sees its (now-dead) direct child and wrongly concludes
    # the test failed. Seen for real: a CI run with the group-wide version
    # showed "processing-java exited -3" (killed BY SIGQUIT, signal 3) and
    # two tests' TIMING/thread-dump output interleaved - two orphaned JVMs
    # running concurrently, each still writing to the same stdout.
    dump_timer = None
    dump_delay = os.environ.get("THREAD_DUMP_DELAY_SECONDS")
    if dump_delay:
        delay = float(dump_delay)

        def _send_thread_dump():
            targets = find_descendant_pids(proc.pid)
            if not targets:
                print(f"  THREAD_DUMP_DELAY_SECONDS={delay:.0f}: could not find any descendant pid, skipping (not sending SIGQUIT to the wrapper itself - see comment above)")
                return
            print(f"  THREAD_DUMP_DELAY_SECONDS={delay:.0f}: sending SIGQUIT to pid(s) {targets} for a thread dump")
            for pid in targets:
                try:
                    os.kill(pid, signal.SIGQUIT)
                except ProcessLookupError:
                    pass

        dump_timer = threading.Timer(delay, _send_thread_dump)
        dump_timer.start()

    try:
        returncode = proc.wait(timeout=PER_TEST_TIMEOUT)
        elapsed = time.time() - start
        # The old processing-java always returned 1 whenever the sketch
        # called exit() itself (exactly what USER=AUTO does), success or
        # not. The new 4.5.x `Processing cli` returns 0 on a normal run in
        # local testing - genuinely more reliable - but this still doesn't
        # treat a nonzero code as fatal on its own, just informational; the
        # real check stays "did a screenshot appear", below.
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
        return None
    finally:
        if dump_timer:
            dump_timer.cancel()

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
