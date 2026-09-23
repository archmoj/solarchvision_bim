# Image regression tests

This exercises the `command/test_*.txt` scripts against the running sketch
and image-diffs the screenshot each one produces, to catch unintended visual
regressions (a broken shading mode, a camera command that stops working, a
geometry command that silently changes its output, etc).

- **`make_baseline.py`** — runs the sketch, one `processing-java` process
  per `command/test_*.txt`, and saves each screenshot to
  `test/image/actual/<name>.png` (or `test/image/baseline/<name>.png` with
  `--baseline`). Rendering is the flaky, slow half of this pipeline (JVM/GL
  startup, Xvfb), so it's both retried and parallelized at the level of
  individual tests rather than the whole batch:
  - **retries are per test**: if `test_houses` fails, only `test_houses` is
    retried — the tests that already succeeded aren't re-run.
  - **generation can be sharded across parallel containers** via
    `SHARD_INDEX`/`SHARD_TOTAL`, so e.g. 3 containers each render a third
    of the tests instead of one container rendering all of them in
    sequence. See "Running in parallel" below.
- **`compare_pixels.py`** — pixel-diffs `test/image/actual/<name>.png`
  against `test/image/baseline/<name>.png` and writes a red-highlighted
  diff to `test/image/diff/<name>.png`. Purely deterministic, no retries
  and no sharding needed: a pixel comparison is either right or it isn't,
  and it's fast enough to just run once over every test's image.

## How it works

1. `command/test_*.txt` each build a small, non-intersecting scene, set a
   camera/view, and end in exactly one `REC.png`.
2. `make_baseline.py` runs each script through the sketch in headless mode:
   ```
   processing-java --sketch=app/src/solarchvision_bim --run \
     --args USER=AUTO RUN=command/test_primitives.txt
   ```
   (the same `USER=AUTO RUN=...` mechanism as `./run.sh USER=AUTO
   RUN=command/test.txt` — see `app/src/solarchvision_bim/parseArgs.pde` and
   `solarchvision_bim.pde`: `USER=AUTO` makes the sketch run the script
   ~1000 frames after startup and then call `exit()` on its own).
3. Each script's single screenshot is found under `projects/model-01/export/screenshots/`
   at the repo root (by mtime, whatever appeared after that test's run
   started — see the note in `make_baseline.py` on why it's there and not
   under `app/src/solarchvision_bim/`, which is where `sketchPath()`/
   `BaseFolder` would suggest) and copied to `test/image/actual/<name>.png`
   (or `baseline/` with `--baseline`).
4. In CI, each shard's `test/image/actual/` is uploaded as its own
   short-lived artifact, then a separate job downloads and merges every
   shard's artifact back into one `test/image/actual/` before running
   `compare_pixels.py` once over the full set. Locally, there's only ever
   one `actual/` directory, so this merge step doesn't come up.

## Running locally

Needs a Processing 4 install (same one `run.sh`/`ci.yml` use) and Python
with Pillow + numpy:

```sh
pip install pillow numpy
export PROCESSING_HOME=~/processing/4.3.4   # wherever it's installed
xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" python3 test/image/make_baseline.py
python3 test/image/compare_pixels.py
```

(`xvfb-run` only wraps `make_baseline.py` — `compare_pixels.py` doesn't
touch the sketch at all, no display needed.)

`--server-args="-screen 0 1920x1080x24"` matters: the sketch runs
`fullScreen(P2D)`, so every screenshot comes out the same size as Xvfb's
virtual screen. Leave it off and you get `xvfb-run`'s default 1280x1024
instead - if you ever change this, baselines need regenerating at the new
size (a resolution change alone makes `compare_pixels.py` report every test
as a dimension mismatch).

Run a subset by naming tests (without `.txt`):

```sh
python3 test/image/make_baseline.py test_houses test_primitives
python3 test/image/compare_pixels.py test_houses test_primitives
```

## Running in parallel (sharding)

`make_baseline.py` reads `SHARD_INDEX`/`SHARD_TOTAL` and only runs the
tests where `index % SHARD_TOTAL == SHARD_INDEX`. Both must be set together;
leave them unset (the default) to run every test in one process.

`.github/workflows/image-tests.yml` uses this to spread generation across
`SHARD_TOTAL` (currently 3) parallel containers.

- **`generate-images`** — a matrix job, one run per `shard` in
  `[0, 1, ..., SHARD_TOTAL - 1]`. Each sets `SHARD_INDEX` to its own shard
  number and runs `make_baseline.py`, which only renders its slice of the
  tests. Each shard uploads its own `test/image/actual/` as
  `actual-images-<shard>` (short retention - it's only consumed by the next
  job in the same run, not meant to be downloaded directly).
- **`compare-pixels`** — needs `generate-images`, downloads every
  `actual-images-*` artifact merged into one `test/image/actual/`
  (`actions/download-artifact` with `pattern: actual-images-*` and
  `merge-multiple: true`), then runs `compare_pixels.py` once over the
  complete set. No Processing/GL involved here, so it runs on a plain
  `ubuntu-latest` runner rather than the `ubuntu-22.04` `generate-images`
  needs (see Troubleshooting below).

To try this locally instead of via CI, run each shard into its own
directory and merge them by hand:

```sh
for shard in 0 1 2; do
  rm -rf test/image/actual
  SHARD_INDEX=$shard SHARD_TOTAL=3 \
    xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" \
    python3 test/image/make_baseline.py
  mkdir -p /tmp/shard-$shard && cp test/image/actual/*.png /tmp/shard-$shard/
done
rm -rf test/image/actual && mkdir test/image/actual
cp /tmp/shard-*/*.png test/image/actual/
python3 test/image/compare_pixels.py
```

`SHARD_TOTAL` in the workflow's `env:` block must match the matrix's
`shard` list length - if you change one, change the other.

## Baselines

`test/image/baseline/` is empty (just `.gitkeep`) to start with — **nobody
has generated real baseline images yet**.

There's no separate "update baselines" workflow or job. Instead a missing
baseline (a brand new test) and a notable diff (a real regression, *or* a
rendering change that's actually fine) both make `compare_pixels.py` fail,
which is exactly when there's something worth a human looking at. So the
`compare-pixels` job uploads `test/image/actual/` + `test/image/diff/` as
the `new-baselines` artifact only `if: failure()`. `actual/` doubles as the
set of candidate new baselines: download the artifact, look at the images
(and their diffs against whatever baseline did exist, if any), and commit
the ones that are actually correct into `test/image/baseline/` in a normal
commit — a bug would otherwise get silently baked in as "correct" if this
weren't reviewed by eye first.

To do the same thing locally instead of via the artifact:

```sh
xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" python3 test/image/make_baseline.py --baseline
```

then look at every image in `test/image/baseline/` before committing.

Without a baseline for a given test, `compare_pixels.py` reports it as a
real failure by default. Pass `--allow-missing-baseline` for a
warn-instead-of-fail local/dev run.

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
`make_baseline.py` needs a display:

```sh
xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" python3 test/image/make_baseline.py
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
`ubuntu-latest`.** `.github/workflows/image-tests.yml` pins `generate-images`
to `ubuntu-22.04` for exactly this reason (`compare-pixels` doesn't touch
Processing/GL at all, so it's on plain `ubuntu-latest`).

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
`projects/model-01/export/screenshots/` at the repo root (see the note in
`make_baseline.py` on why it's there and not under
`app/src/solarchvision_bim/`), which is what genuinely indicates the run
produced something.

## Note on per-run timing and per-test retry

`make_baseline.py` bounds each *attempt* with `PER_TEST_TIMEOUT` (default
300s, override with the env var) and retries only that one test up to
`MAX_RETRY` times (default 2) if it comes back empty — a flaky render of
one test doesn't cost re-running the others in its shard.
`timeout-minutes: 30` on the `generate-images` step is a last-resort safety
net for that whole shard (e.g. if `xvfb-run`/`Xvfb` itself wedges), not the
normal path.

`processing-java` is a plain shell script that runs `java` as a **foreground
child process**, not via `exec` — so killing just its own PID on a timeout
would leave the JVM running in the background. Across several timed-out
tests that can add up to real resource exhaustion (leaked X11 connections,
memory) that plausibly explains later tests failing even when they'd have
been fine in isolation. `make_baseline.py` avoids this by starting
`processing-java` in its own process group (`start_new_session=True`) and
killing the *whole group* on timeout (`os.killpg(...)`), not just the
top-level process.

## Note on CI render speed

Generation is measurably slower on CI than on a real machine (e.g.
`processing-java finished after 16s` locally vs. `247s` in CI for the same
test) — investigated, not yet fully resolved. Two things ruled out first:

- Not the long-intro-wait explanation from an earlier version of this file
  (removed): `Last_initializationStep` is `25`, not `1000`, so the intro
  sequence is only ~1s now. The gap is in the actual render/context setup,
  not idle waiting.
- Not `fullScreen()` itself. `solarchvision_bim.pde`'s main window is
  `fullScreen(P2D)`, same as it would be on any machine.

The leading suspect: `WIN3D` (the 3D viewport every `command/test_*.txt`
actually exercises) and `SKY2D_graphics` are separate offscreen **`P3D`**
`PGraphics` (`createGraphics(..., P3D)` in `setup()`). Both `P2D` and `P3D`
are OpenGL-backed (via JOGL) - `P2D` isn't a plain CPU/Java2D fallback -
but `P3D` does real 3D work per pixel (transforms, lighting, z-buffering)
that `P2D` doesn't. CI runners have no real GPU, so all of this - `P2D` and
`P3D` alike - falls back to Mesa's `llvmpipe`, a full software OpenGL
rasterizer running entirely on CPU; a real machine's actual GPU driver
handles the same work in hardware. `P3D`'s heavier per-pixel cost under
that software fallback is the current best explanation for why this
project's CI is slow while a comparable project
([archmoj/grib2_solarchvision](https://github.com/archmoj/grib2_solarchvision)),
which uses no `P3D` anywhere, stays fast on CI.

Two things added to actually pin this down on the next real CI run, rather
than resting on the reasoning above:

- **Timing instrumentation** in `solarchvision_bim.pde`: `println("TIMING:
  ...", millis())` around the `P3D` context creation in `setup()`, around
  `_fileSelected_RunScript(...)` (the command file's geometry creation),
  around `draw_WIN3D_layers()` (the actual render), and around
  `RecordFrame()` (the screenshot save). `make_baseline.py` doesn't capture
  `processing-java`'s stdout, so these lines show up directly in the
  `generate-images` step's log - read the gaps between consecutive
  `TIMING:` lines to see which phase the 231s (locally 16s, CI 247s) is
  actually in: one-time context setup, the geometry/command execution, or
  the render itself.
- **`LP_NUM_THREADS=4`** on the `generate-images` step: `llvmpipe`
  auto-detects how many threads to rasterize with, which can misdetect or
  oversubscribe under a CI container's CPU quota. Pinned to 4 to match
  GitHub-hosted public runners' 4 vCPUs, as a cheap thing to try alongside
  the instrumentation above. Remove it (or try other values) once the
  `TIMING` lines show whether it moved anything.
