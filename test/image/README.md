# Image regression tests

This exercises the `command/test_*.txt` scripts against the running sketch
and image-diffs the screenshot each one produces, to catch unintended visual
regressions (a broken shading mode, a camera command that stops working, a
geometry command that silently changes its output, etc).

## How it works

1. `command/test_*.txt` each build a small, non-intersecting scene, set a
   camera/view, and end in exactly one `REC.png` (see `command/TESTS.md`).
2. `run_image_tests.sh` runs each script through the sketch in headless mode:
   ```
   processing-java --sketch=app/src/solarchvision_bim --run \
     --args USER=AUTO RUN=command/test_primitives.txt
   ```
   (the same `USER=AUTO RUN=...` mechanism as `./run.sh USER=AUTO
   RUN=command/test.txt` — see `app/src/solarchvision_bim/parseArgs.pde` and
   `solarchvision_bim.pde`: `USER=AUTO` makes the sketch run the script
   ~1000 frames after startup and then call `exit()` on its own, so no
   further input is needed).
3. Each script's single screenshot is found under
   `app/src/solarchvision_bim/projects/model-01/export/screenshots/` (by
   timestamp — whatever appeared after the run started) and copied to
   `test/image/actual/<test-name>.png`.
4. `compare_images.py` diffs it against `test/image/baseline/<test-name>.png`
   pixel-by-pixel and writes a red-highlighted diff to
   `test/image/diff/<test-name>.png`.

## Running locally

Needs a Processing 4 install (same one `run.sh`/`ci.yml` use) and Python
with Pillow + numpy:

```sh
pip install pillow numpy
export PROCESSING_HOME=~/processing/4.3.4   # wherever it's installed
test/image/run_image_tests.sh
```

On a headless machine, wrap it in `xvfb-run` (see Troubleshooting below):

```sh
xvfb-run -a test/image/run_image_tests.sh
```

Run a subset by naming files:

```sh
test/image/run_image_tests.sh test_houses.txt test_primitives.txt
```

## Baselines

`test/image/baseline/` is empty (just `.gitkeep`) to start with — **nobody
has generated real baseline images yet**. To seed or refresh them:

```sh
UPDATE_BASELINES=1 xvfb-run -a test/image/run_image_tests.sh
```

then **look at every image in `test/image/baseline/` before committing** —
this step trusts whatever the sketch currently renders, so a bug would get
baked in as "correct" otherwise. The CI workflow (`update-baselines` job,
triggered manually) does the same thing but uploads the results as a build
artifact for review rather than committing them directly.

Without a baseline for a given test, `run_image_tests.sh` prints a `WARN`
and continues locally, but the CI workflow runs with `STRICT=1`, so a
missing baseline is a hard failure there — every test needs a reviewed
baseline before it's meaningful in CI.

## Thresholds

`compare_images.py` treats a pixel as "different" if any channel differs by
more than `--pixel-tolerance` (default `12`, to absorb minor antialiasing
noise), and fails if more than `--threshold` percent of pixels differ
(default `0.5`). Override per run with:

```sh
IMAGE_DIFF_THRESHOLD=1.0 test/image/run_image_tests.sh
```

Loosen this if the renderer turns out to have some inherent
run-to-run jitter (e.g. timing-dependent antialiasing); tighten it once the
tests have proven stable.

## Adding a new test

1. Add `command/test_<name>.txt`, following the existing scripts as a
   template: `Delete all` first, space objects out so nothing intersects,
   set a view + `SIZEALL`, end in exactly one `REC.png`.
2. `UPDATE_BASELINES=1 test/image/run_image_tests.sh test_<name>.txt`,
   review the resulting `test/image/baseline/test_<name>.png`, commit it.

## Troubleshooting: headless rendering

The sketch opens a real `P3D` (OpenGL) window even in `USER=AUTO` mode, so
it needs a display. On CI / a headless box:

```sh
xvfb-run --auto-servernum test/image/run_image_tests.sh
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
`ubuntu-22.04` for exactly this reason. Locally, use whatever's on hand —
a VM or container running Ubuntu 22.04 (or any distro with an
older/non-GLVND Mesa) will work; a fresh Ubuntu 24.04 machine likely won't
without patching Processing's bundled JOGL jars, which is out of scope here.

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

Because of this, `run_image_tests.sh` doesn't treat `processing-java`'s
exit code as the success signal — it explicitly catches it (so `set -e`
doesn't abort the loop after the very first test) and logs a note instead.
The actual check is whether a new screenshot file showed up under
`app/src/solarchvision_bim/projects/model-01/export/screenshots/`, which is
what genuinely indicates the script ran.

## Note on per-run timing

Each script takes a real chunk of wall-clock time on its own:
`frameRate(24)` and `Last_initializationStep = 1000` in
`solarchvision_bim.pde` mean the intro sequence alone takes at least
`1000 / 24 ~= 42s` before `RUN=...` even starts, on top of JVM startup, GL
context creation, and the render itself. Running all 7
`command/test_*.txt` scripts sequentially can add up to well over the
default timeout of a CI step — this is what caused an early version of
`.github/workflows/image-tests.yml` (`timeout_minutes: 15`) to have the
whole job killed mid-run with nothing more informative than "Child_process
exited with error code 1" and no further per-script output.

Two things address this:
- `run_image_tests.sh` prints a start time and elapsed seconds for each
  script, so a slow run is visible in the log instead of guessed at, and
  wraps each one in its own `PER_SCRIPT_TIMEOUT` (default 300s, override
  with the env var) so a single stuck script fails cleanly and the loop
  moves on, rather than silently consuming the whole job's time budget.
- The workflow's `timeout_minutes` is set generously (45) to give all 7
  scripts real headroom to run one after another.
