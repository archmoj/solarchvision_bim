# Image regression tests

This exercises the `command/test_*.txt` scripts against the running sketch
and image-diffs the screenshot each one produces, to catch unintended visual
regressions (a broken shading mode, a camera command that stops working, a
geometry command that silently changes its output, etc).

Split into two independent steps:
- **`make_baseline.py`** — runs the sketch, one `processing-java` process
  per `command/test_*.txt`, and saves each screenshot to
  `test/image/actual/<name>.png` (or `test/image/baseline/<name>.png` with
  `--baseline`). Rendering is the flaky half of this pipeline (JVM/GL
  startup, Xvfb), so **retries are per test, not per batch**: if
  `test_houses` fails, only `test_houses` is retried — the 6 tests that
  already succeeded aren't re-run.
- **`compare_pixels.py`** — pixel-diffs `test/image/actual/<name>.png`
  against `test/image/baseline/<name>.png` and writes a red-highlighted
  diff to `test/image/diff/<name>.png`. Purely deterministic, no retries:
  a pixel comparison is either right or it isn't.

## How it works

1. `command/test_*.txt` each build a small, non-intersecting scene, set a
   camera/view, and end in exactly one `REC.png` (see `command/TESTS.md`).
2. `make_baseline.py` runs each script through the sketch in headless mode:
   ```
   processing-java --sketch=app/src/solarchvision_bim --run \
     --args USER=AUTO RUN=command/test_primitives.txt
   ```
   (the same `USER=AUTO RUN=...` mechanism as `./run.sh USER=AUTO
   RUN=command/test.txt` — see `app/src/solarchvision_bim/parseArgs.pde` and
   `solarchvision_bim.pde`: `USER=AUTO` makes the sketch run the script
   ~1000 frames after startup and then call `exit()` on its own).
3. Each script's single screenshot is found under
   `app/src/solarchvision_bim/projects/model-01/export/screenshots/` (by
   mtime, whatever appeared after that test's run started) and copied to
   `test/image/actual/<name>.png` (or `baseline/` with `--baseline`).
4. `compare_pixels.py` diffs `actual/` against `baseline/`.

## Running locally

Needs a Processing 4 install (same one `run.sh`/`ci.yml` use) and Python
with Pillow + numpy:

```sh
pip install pillow numpy
export PROCESSING_HOME=~/processing/4.3.4   # wherever it's installed
xvfb-run --auto-servernum python3 test/image/make_baseline.py
python3 test/image/compare_pixels.py
```

(`xvfb-run` only wraps `make_baseline.py` — `compare_pixels.py` doesn't
touch the sketch at all, no display needed.)

Run a subset by naming tests (without `.txt`):

```sh
python3 test/image/make_baseline.py test_houses test_primitives
python3 test/image/compare_pixels.py test_houses test_primitives
```

## Baselines

`test/image/baseline/` is empty (just `.gitkeep`) to start with — **nobody
has generated real baseline images yet**. To seed or refresh them:

```sh
xvfb-run --auto-servernum python3 test/image/make_baseline.py --baseline
```

then **look at every image in `test/image/baseline/` before committing** —
this step trusts whatever the sketch currently renders, so a bug would get
baked in as "correct" otherwise. The CI workflow's `update-baselines` job
(triggered manually) does the same thing but uploads the results as a build
artifact for review rather than committing them directly.

Without a baseline for a given test, `compare_pixels.py` reports it as a
real failure by default. Pass `--allow-missing-baseline` for a warn-instead-of-fail local/dev run.

## Thresholds

`compare_pixels.py` treats a pixel as "different" if any channel differs by
more than `--pixel-tolerance` (default `12`, to absorb minor antialiasing
noise), and fails if more than `--threshold` percent of pixels differ
(default `0.5`, or set `IMAGE_DIFF_THRESHOLD`). Loosen this if the renderer
turns out to have some inherent run-to-run jitter; tighten it once the
tests have proven stable.

## Adding a new test

1. Add `command/test_<name>.txt`, following the existing scripts as a
   template: `Delete all` first, space objects out so nothing intersects,
   set a view + `SIZEALL`, end in exactly one `REC.png`.
2. `python3 test/image/make_baseline.py test_<name> --baseline`, review the
   resulting `test/image/baseline/test_<name>.png`, commit it.

## Troubleshooting: headless rendering

The sketch opens a real `P3D` (OpenGL) window even in `USER=AUTO` mode, so
it needs a display:

```sh
xvfb-run --auto-servernum python3 test/image/make_baseline.py
```

**On `ubuntu-24.04`/`ubuntu-latest` runners this crashes the JVM** with a
native `SIGSEGV` inside `libGLX_mesa.so` (from JOGL's `SharedResourceRunner`
setting up its shared GL context) — reliably, at the same crash address,
regardless of `LIBGL_ALWAYS_SOFTWARE`, `vblank_mode`, `LIBGL_ALWAYS_INDIRECT`,
or `__GLX_VENDOR_LIBRARY_NAME`. That insensitivity to every runtime flag
points to a binary (ABI) incompatibility between the JOGL native library
bundled in Processing 4.3.4 and Ubuntu 24.04's newer GLVND-based Mesa, not a
missing config flag — `actions/runner-images#11517` documents the same class
of Mesa-on-24.04 regression for another project.

**The fix that actually works here: run on `ubuntu-22.04`, not
`ubuntu-latest`.** `.github/workflows/image-tests.yml` pins both jobs to
`ubuntu-22.04` for exactly this reason.

`LIBGL_ALWAYS_SOFTWARE=1` is still set in the workflow as a normal, harmless
"use the software rasterizer, there's no real GPU here" hint for Xvfb — it
just isn't what fixes the crash above.

## Note on processing-java's exit code

`processing-java` returns exit code `1` whenever the sketch calls `exit()`
itself — which is exactly what `USER=AUTO` does once it's finished running
the script (see `solarchvision_bim.pde`) — regardless of whether the run
actually succeeded. JOGL's shutdown also prints an `X11Util: Open X11
Display Connections: ...` warning at exit; that's normal noise from
`Xvfb`/JOGL cleanup, not an error.

Because of this, `make_baseline.py` doesn't treat `processing-java`'s exit
code as the success signal — it logs a note and moves on. The actual check
is whether a new screenshot file showed up under
`app/src/solarchvision_bim/projects/model-01/export/screenshots/`, which is
what genuinely indicates the run produced something.

## Note on per-run timing and per-test retry

`make_baseline.py` bounds each *attempt* with `PER_TEST_TIMEOUT` (default
300s, override with the env var) and retries only that one test up to
`MAX_RETRY` times (default 0) if it comes back empty — a flaky render of
one test doesn't cost re-running the others. `timeout-minutes: 30` on the
workflow step is a last-resort safety net for the whole batch (e.g. if
`xvfb-run`/`Xvfb` itself wedges), not the normal path.

`processing-java` is a plain shell script that runs `java` as a **foreground
child process**, not via `exec` — so killing just its own PID on a timeout
would leave the JVM running in the background. Across several timed-out
tests that can add up to real resource exhaustion (leaked X11 connections,
memory) that plausibly explains later tests failing even when they'd have
been fine in isolation. `make_baseline.py` avoids this by starting
`processing-java` in its own process group (`start_new_session=True`) and
killing the *whole group* on timeout (`os.killpg(...)`), not just the
top-level process.
