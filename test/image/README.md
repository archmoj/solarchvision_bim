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

`xvfb-run` ships preinstalled on GitHub's `ubuntu-latest` runners, so
`.github/workflows/image-tests.yml` doesn't `apt-get install` anything for
the display — it just calls `xvfb-run --auto-servernum ...` directly,
wrapped in a retry (`nick-fields/retry@v4`, 2 attempts) since a fresh X
server can occasionally race with the JOGL context on its first attempt.
This mirrors the pattern already working for another JOGL/Processing-based
sketch in
[archmoj/grib2_solarchvision](https://github.com/archmoj/grib2_solarchvision/blob/master/.github/workflows/scheduled-job.yml).

If it still fails with a native `SIGSEGV` inside `libGLX_mesa.so`/JOGL (a
known JOGL + software-Mesa issue, more likely on constrained/single-core
machines than on standard GitHub runners), try forcing software rendering
explicitly and disabling the vsync query path that tends to trigger it:

```sh
LIBGL_ALWAYS_SOFTWARE=1 vblank_mode=0 xvfb-run --auto-servernum test/image/run_image_tests.sh
```

An earlier version of the workflow set those two variables and installed
extra Mesa packages up front; they were removed once the plain
`xvfb-run --auto-servernum` + retry pattern above was confirmed to be all
another project in this org actually needed. Bring them back (as job-level
`env:` in `.github/workflows/image-tests.yml`) if a real CI run hits the
JOGL crash.
