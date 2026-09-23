# Image regression tests

This exercises the `command/test_*.txt` scripts against the running sketch
and image-diffs the screenshot each one produces, to catch unintended visual
regressions (a broken shading mode, a camera command that stops working, a
geometry command that silently changes its output, etc).

- **`make_baseline.py`** — runs the sketch, one `Processing cli` process per
  `command/test_*.txt`, and saves each screenshot to
  `test/image/actual/<name>.png` (or `test/image/baseline/<name>.png` with
  `--baseline`). Rendering is the flaky half of this pipeline (JVM/GL
  startup, Xvfb), so it's both retried and parallelized at the level of
  individual tests rather than the whole batch:
  - **retries are per test**: if `test_houses` fails, only `test_houses` is
    retried — the tests that already succeeded aren't re-run.
  - **generation is sharded across parallel containers** via
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
   Processing cli --sketch=app/src/solarchvision_bim --run \
     USER=AUTO RUN=command/test_primitives.txt
   ```
   (the same `USER=AUTO RUN=...` mechanism as `./run.sh USER=AUTO
   RUN=command/test.txt` — see `app/src/solarchvision_bim/parseArgs.pde` and
   `solarchvision_bim.pde`: `USER=AUTO` makes the sketch run the script a
   couple of frames after startup and then call `exit()` on its own).
3. Each script's single screenshot is found under
   `projects/model-01/export/screenshots/` (searched at both the repo root
   and under the Processing install — see "Setup: Processing 4.5.x" below
   for why) and copied to `test/image/actual/<name>.png` (or `baseline/`
   with `--baseline`).
4. In CI, each shard's `test/image/actual/` is uploaded as its own
   short-lived artifact, then a separate job downloads and merges every
   shard's artifact back into one `test/image/actual/` before running
   `compare_pixels.py` once over the full set. Locally, there's only ever
   one `actual/` directory, so this merge step doesn't come up.

## Setup: Processing 4.5.x

Needs [Processing 4.5.x](https://github.com/processing/processing4/releases)
(the "portable" `linux-x64` build) and Python with Pillow + numpy:

```sh
pip install pillow numpy
```

The 4.5.x CLI (`Processing cli --sketch=... --run ...`, replacing the old
`processing-java` script) resolves `sketchPath()`/`BaseFolder` to its own
install directory (`<install>/lib/app/resources/core`) instead of the
sketch's working directory — so before running anything, symlink this
repo's `input/`, `command/`, and `projects/` directories into that
location (`projects/` needs creating first, since it doesn't exist yet on
a fresh checkout):

```sh
PROCESSING_HOME=~/processing/4.5.2   # wherever it's installed
CORE="$PROCESSING_HOME/lib/app/resources/core"
mkdir -p projects
ln -sfn "$(pwd)/input" "$CORE/input"
ln -sfn "$(pwd)/command" "$CORE/command"
ln -sfn "$(pwd)/projects" "$CORE/projects"
```

`.github/workflows/image-tests.yml` does this as a normal CI step (re-run
every job, since `$GITHUB_WORKSPACE` is a fresh checkout path each time —
it's not part of the cached Processing install).

## Running locally

```sh
export PROCESSING_HOME=~/processing/4.5.2   # wherever it's installed
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
  `ubuntu-latest` runner regardless of what `generate-images` needs.

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

## Notes on process handling

`Processing exited 1` (or any nonzero code) in the log isn't necessarily a
failure — `make_baseline.py` doesn't treat the exit code as the success
signal on its own, just informational. The real check is whether a new
screenshot file showed up under
`projects/model-01/export/screenshots/`, which is what genuinely
indicates the run produced something. JOGL's shutdown also prints an
`X11Util: Open X11 Display Connections: ...` warning at exit; that's
normal `Xvfb`/JOGL cleanup noise, not an error.

`make_baseline.py` bounds each *attempt* with `PER_TEST_TIMEOUT` (default
300s) and retries only that one test up to `MAX_RETRY` times (default 2)
if it comes back empty — a flaky render of one test doesn't cost re-running
the others in its shard. Each attempt runs in its own process group
(`start_new_session=True`), and a timeout kills the *whole group*
(`os.killpg(...)`), not just the top-level process, so nothing gets left
running in the background. `timeout-minutes` on the `generate-images` step
is a last-resort safety net for the whole shard (e.g. if `xvfb-run`/`Xvfb`
itself wedges), not the normal path.
