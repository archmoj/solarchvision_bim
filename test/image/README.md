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

Generation was measurably slower on CI than on a real machine (e.g.
`processing-java finished after 16s` locally vs. `247s` in CI for the same
test) — root-caused and fixed. Kept here for anyone who hits something
like it again.

**Ruled out first:**
- The long-intro-wait explanation from an earlier version of this file
  (removed): `Last_initializationStep` is `25`, not `1000`, so the intro
  sequence is only ~1s.
- `fullScreen()` itself: the main window is `fullScreen(P2D)`, same as on
  any machine.
- `drawSceneContents()` (the actual scene - `Sky3D`, `Sun3D`, `Moon3D`,
  `Earth3D`, `Land3D`, `Tropo3D`, plus a test's own geometry): measured at
  633ms total on a run where the surrounding call took ~230s. Despite
  `Earth3D` loading a 5400x2700px texture for the globe, none of this was
  the bottleneck.

**Leading hypothesis (disproven)**: `renderFrame()`'s `this.graphics.endDraw()`
call - 163007ms out of a 170419ms total for the whole `draw_WIN3D_layers()`
call, 96% of it, isolated by timing every remaining piece of
`renderFrame()`/`drawView()` once `drawSceneContents()` was ruled out.
`endDraw()` on an offscreen `P3D`/`P2D` surface performs a multisample
(MSAA) resolve if antialiasing is enabled, which it is by default
(`smooth(4)`) unless turned off explicitly - a full-framebuffer,
per-sample averaging pass, cheap on real GPU hardware but plausibly very
slow under Mesa's `llvmpipe` software rasterizer.

**Attempted fix, confirmed ineffective**: `.noSmooth()` added on
`WIN3D.graphics`/`SKY2D_graphics` (`P3D`) and `WORLD.graphics`/
`STUDY.graphics` (`P2D`), gated on `control == USER_AUTO` so interactive
`USER_GUI` usage keeps its antialiasing. Confirmed *not* the fix by the
next CI run's own `TIMING:` output: `endDraw()` was still 229727ms of a
238361ms total - if anything slightly worse, well within normal CI
variance, but certainly not the order-of-magnitude drop a working fix
would show. Left in place (harmless, and a reasonable thing to have
regardless) but the MSAA-resolve theory above is not what's actually
happening here.

**Current approach**: guessing further from source reading alone hasn't
worked twice now (the `Earth3D` texture theory, then this one), so rather
than a third guess, `make_baseline.py` can trigger an actual JVM thread
dump *while* a test is stuck, showing the literal native/Java stack it's
blocked on instead of inferring it:

```sh
THREAD_DUMP_DELAY_SECONDS=60 xvfb-run --auto-servernum --server-args="-screen 0 1920x1080x24" python3 test/image/make_baseline.py test_primitives
```

Unlike `SIGTERM`/`SIGKILL`, a JVM's default `SIGQUIT` handling is to print
every thread's full stack trace (including native frames) to stdout and
then keep running - `make_baseline.py` doesn't capture `processing-java`'s
stdout, so the dump lands directly in the CI log, right where the
`TIMING:` lines already do.

**Bug found and fixed in the diagnostic itself, from a real CI run's log**:
the first version sent `SIGQUIT` to the whole process group
(`os.killpg`). That broadcasts to both `java` and the `processing-java`
bash wrapper it runs inside (as a foreground child, not `exec`'d - see the
process-group note above). `java` handles `SIGQUIT` specially (dump, keep
running); the wrapper does not trap it, so it dies immediately from its
default disposition - orphaning `java`, which keeps running unmonitored
while `make_baseline.py` sees its (now-dead) direct child, wrongly
concludes the test failed, and starts a retry *while the orphaned JVM from
the first attempt is still running in the background*. This was directly
visible in the log: `processing-java exited -3` (killed *by* signal 3,
`SIGQUIT`) and two tests' `TIMING:`/thread-dump output interleaved - two
orphaned JVMs concurrently writing to the same stdout, and very likely
competing for CPU with whatever ran next. **First fix**: find the actual
`java` child pid (via `/proc/<pid>/task/<pid>/children`) and send `SIGQUIT`
there specifically, never the wrapper.

**What that first (buggy) dump actually showed**: not graphics code -

```
at processing.mode.java.preproc.ProcessingParser.expression(...)
at processing.mode.java.preproc.PdePreprocessor.write(...)
at processing.mode.java.JavaBuild.build(...)
at processing.mode.java.Commander.main(...)
```

Processing's own ANTLR-based source parser (`.pde` → Java), still parsing
10 seconds in. Initially read as "compilation might be the real
bottleneck" - **revised after the corrected run below**: a second CI run,
using the first fix, shows `TIMING: setup() start` at `1936` (already past
compilation, JVM launched, sketch running - under 2 seconds in). That's
consistent with the *first* dump's slow compilation being an artifact of
the orphaning bug itself - competing for CPU against whatever leaked JVMs
were still running from earlier tests - rather than a genuine standalone
cost. `endDraw()` was `229748ms` in this same corrected run, consistent
with every properly-measured run so far - still the real, reproducible
bottleneck.

**Second bug, found from that same corrected run's dump**: the stack it
showed wasn't in our code either -

```
at processing.mode.java.runner.Runner.generateTrace(Runner.java:654)
at processing.mode.java.runner.Runner.launch(Runner.java:146)
at processing.mode.java.Commander.<init>(Commander.java:242)
```

- `Thread.join()`, waiting. `processing-java`'s "Commander" doesn't run the
sketch in the JVM that compiles it: it compiles in one JVM, then launches
a *second*, separate JVM process to actually run the sketch
(`Runner.launchJava`, monitored over the Java Debug Interface - other
threads in the same dump show `JDI Internal Event Handler`,
`MessageSiphon`, `ProcessImpl.waitFor()`), while the first JVM's main
thread just sits in `Thread.join()` waiting for it. The first fix's
`find_child_pids` found the right *first-level* child, but that's this
launcher/monitor JVM - a level too shallow. **Second fix**: walk the whole
descendant tree and send `SIGQUIT` to every process found, not just the
first level - a dump of the wrong process is nearly free to get and easy
to tell apart from the real one by its stack, so getting both beats
guessing which pid matters.

**Third bug**: the second fix's first implementation walked the tree by
repeatedly reading `/proc/<pid>/task/<pid>/children` one level at a time.
On the very next real CI run, it *still* found only the one Commander pid,
even though that run's own dump proved a child process existed (a thread
blocked in `ProcessImpl.waitFor()`) - that specific `/proc` file wasn't
reliably reporting children here, for reasons not fully pinned down
(possibly a race against a multi-threaded parent). **Fixed** by scanning
all of `/proc/*/stat` once and building the whole ppid → children mapping
directly (`ppid` is a plain, always-populated field there - see `man
proc`), instead of depending on that one file. This one was verified
against a *real* 3-level process tree in the sandbox (actual nested shell
scripts under this Linux `/proc`, not a stub simulation) and correctly
found every descendant across all three levels, where the previous
approach had failed to find even the first on real CI.

All three fixes are cumulative in the current `make_baseline.py`, and they
worked: the next real CI run found **two** descendant pids and dumped
both. The second one was finally the actual sketch-running JVM, not the
Commander/launcher - progress. But it landed at the wrong *moment*: its
stack showed the animator thread still inside `setup()`, loading a font
from disk -

```
at sun.font.TrueTypeFont.init(...)
at processing.core.PApplet.createFont(...)
at solarchvision_bim.loadDefaultFontStyle(solarchvision_bim.java:38418)
at solarchvision_bim.setup(solarchvision_bim.java:170)
```

**Fourth thing found and fixed**: `THREAD_DUMP_DELAY_SECONDS` is measured
from when the *outer* wrapper process starts - but the Commander JVM
spends several seconds compiling before it launches the *inner* JVM that
actually runs the sketch (that same run's Commander-side dump showed its
launcher thread only `elapsed=2.41s` old, meaning the launch happened
~7.6s into Commander's own life). So a 10s delay only reached ~1-2 seconds
into the inner JVM's own life - nowhere near `endDraw()`, which per this
project's own `TIMING:` output doesn't start until several seconds into
the inner JVM's life and can run for 140-230+ seconds. **Fixed** by
raising the delay to 60s in `.github/workflows/image-tests.yml`, which
should land comfortably inside that window across every run length seen
so far (142s-249s total).

**The dump this finally produced - the actual root cause**:

```
at jogamp.opengl.gl4.GL4bcImpl.dispatch_glBlitFramebuffer1(Native Method)
at jogamp.opengl.gl4.GL4bcImpl.glBlitFramebuffer(...)
at processing.opengl.PJOGL.blitFramebuffer(...)
at processing.opengl.FrameBuffer.copy(...)
at processing.opengl.FrameBuffer.copyColor(...)
at processing.opengl.PGraphicsOpenGL.endOffscreenDraw(...)
at processing.opengl.PGraphicsOpenGL.endDraw(...)
at solarchvision_bim$WIN3D.renderFrame(solarchvision_bim.java:33277)
```

Thread state `RUNNABLE`, not blocked - genuinely executing `glBlitFramebuffer`
(a native OpenGL call), not waiting on anything. Processing's own source
(`FrameBuffer.java`) confirms every offscreen `P3D`/`P2D` surface's
`endDraw()` does this: it always renders into an internal FBO, then blits
its color buffer into a separate, texture-backed FBO via
`pgl.blitFramebuffer(0, 0, w, h, 0, 0, w, h, COLOR_BUFFER_BIT, NEAREST)` -
same size, `NEAREST` filtering, no scaling. This is architectural, not
MSAA-specific, which is exactly why `noSmooth()` never had any effect: it
was never in that code path to begin with.

A same-size, no-filtering blit taking 226 seconds isn't explained by
"software rendering is slower than hardware" alone - that's roughly
20,000x slower than a reasonable software blit, not the 10-100x llvmpipe
is normally slower by. That smells like a genuine Mesa/llvmpipe
performance bug or pathological code path for this specific FBO
configuration (format mismatch, packed depth-stencil interacting badly
with the blit, or similar) rather than expected software-rasterizer
overhead - but nothing found via search matches this exact symptom and
magnitude closely enough to call it confirmed.

**Resolved**: upgrading to Processing 4.5.2 (bundled JOGL 2.6.0, up from
whatever 4.3.4 shipped) fixes this completely - `endDraw()` dropped from
226,000+ms to 0-94ms across all 7 tests, with no code change to
`FrameBuffer.copy()`/`blitFramebuffer()` itself. Whatever was pathological
about the old JOGL/Mesa combination for this specific blit, the newer
bundle doesn't hit it. See "Note on upgrading Processing" below for the
full migration - a new CLI, a new install format, and a couple of real
behavior differences that needed fixing along the way.

The three options below were the plan before that upgrade was tried; kept
for the record and in case a future Processing/Mesa/JOGL combination
regresses the same way:

- **Isolate whether it's per-pixel cost or a fixed stall**: temporarily
  shrink `WIN3D`'s framebuffer resolution way down and see whether
  `endDraw()` time drops proportionally. If it does, it's a genuine
  (if bizarrely slow) per-pixel cost, and a real fix means finding *why*
  that blit is so slow per pixel. If it doesn't change much, it's a fixed
  stall (e.g. a sync/fence wait) unrelated to pixel count, and needs a
  completely different kind of investigation.
- **Cheap environment experiments**, never tried: `MESA_NO_ERROR=1`
  (skips GL error-checking overhead), or forcing a different Gallium
  software path (`GALLIUM_DRIVER=llvmpipe` explicitly, or trying
  `softpipe` instead of `llvmpipe` as a sanity check that it isn't an
  `llvmpipe`-specific regression).
- **Sidestep instead of fix**: raise `SHARD_TOTAL` close to the actual
  test count (one shard per test) so the pipeline's wall-clock time is
  bounded by the slowest single test rather than their sum.

The `TIMING:` instrumentation and `THREAD_DUMP_DELAY_SECONDS` stay in the
code - both are diagnostic-only, off by default, and harmless to leave in
case something like this comes up again; neither is needed for normal use
now.

## Note on upgrading Processing

Prompted by the `endDraw()` investigation above: does a newer Processing
(newer bundled JOGL) avoid both that slowness and the earlier Mesa ABI
crash on `ubuntu-24.04`? Tried Processing 4.5.2 (bundled JOGL 2.6.0, vs.
whatever 4.3.4 shipped) - **yes to both**, confirmed by actually running
it, repeatedly, not just checking version numbers:

- **The `ubuntu-24.04` Mesa ABI crash is gone.** 4.3.4 crashed every single
  time on this exact combination (`libGLX_mesa.so` SIGSEGV in JOGL's
  `SharedResourceRunner`, see "Troubleshooting: headless rendering" above).
  4.5.2 ran cleanly, repeatedly, no crash - meaning `generate-images` no
  longer needs pinning to `ubuntu-22.04` and is back on `ubuntu-latest`.
- **The `endDraw()` slowness is gone.** Same `glBlitFramebuffer` call
  (confirmed from Processing's source, unchanged), same test scenes, same
  sandbox: `endDraw()` went from 226,000+ms to 0-94ms. All 7
  `command/test_*.txt` scripts run sequentially, from cold, in ~224s total
  (previously a *single* test could take up to 249s on its own).

Getting to that clean result took fixing two real behavior differences in
the new tooling, not just swapping a version number:

**1. No more `processing-java`, and a new argument-passing convention.**
Processing 4.5.x replaced the old `processing-java` shell script entirely
with a Kotlin/Compose-based rewrite; headless use is now `Processing cli
--sketch=<path> --run <args...>` (a `cli` subcommand on the same binary
used for the GUI). The old CLI packaged trailing sketch arguments behind a
literal `--args` sentinel (`processing-java ... --run --args USER=AUTO
RUN=...`) before passing them to `PApplet.main()`; the new CLI's own docs
say it forwards trailing arguments to the sketch directly, with no such
marker. `solarchvision_bim.pde`'s `parseArgs()` required that literal
`"--args"` as `passedArgs[0]` before parsing anything, so with the new CLI
it silently parsed nothing at all - `USER=AUTO` never took effect, so the
sketch just looped in normal GUI mode forever instead of running
`RUN.SCRIPT` and exiting. Fixed to accept both forms: `--args`-prefixed
(old) or bare (new).

**2. `sketchPath()`/`BaseFolder` resolves to a different place.** With the
old `processing-java`, `sketchPath()` resolved to the process's current
working directory (confirmed earlier in this file, from an actual CI
run's own log path). With the new `Processing cli`, it resolves instead
to Processing's *own install directory*
(`$PROCESSING_HOME/lib/app/resources/core`) - a real behavior difference,
not a path assumption bug on our end this time. Since `BaseFolder` is
used throughout the sketch to find `input/images/...`, run
`command/....txt`, and write `projects/model-01/export/screenshots/...`,
none of that could be found without a fix. Rather than rewrite every
`BaseFolder`-relative path in the sketch, `input/`, `command/`, and
`projects/` are symlinked from the checkout into that resolved location
as a CI setup step (`ln -sfn "$GITHUB_WORKSPACE/<dir>" "$CORE/<dir>"`,
`projects/` pre-created first since it doesn't exist yet on a fresh
checkout - `mkdir -p` before `ln`, not after, learned from a real failed
run in local testing where skipping that step made `RecordFrame()` fail
to create its output directory through the not-yet-real symlink target).
This makes `make_baseline.py`'s own `SCREENSHOTS_ROOTS` search work
unchanged: since it's a symlink, not a copy, a screenshot written through
`$CORE/projects/...` is the same file as one under
`$GITHUB_WORKSPACE/projects/...`, found by the existing repo-root-relative
search without any code change there.

**3. The new package format.** 4.5.x ships as a "portable" `.zip`
(`processing-<version>-linux-x64-portable.zip`, extracting to a
`Processing/` folder with a native `jpackage`-built launcher at
`Processing/bin/Processing`) rather than the old
`processing-<version>-linux-x64.tgz` with a `processing-java` script
inside. `.github/workflows/image-tests.yml`'s install step and
`make_baseline.py`'s `find_processing_java()` both updated to match.

One thing this migration does *not* change: `processing-java`'s old exit
code always being `1` under `USER=AUTO` (see "Note on
processing-java's exit code" above) - the new CLI actually returned `0` on
every successful run in local testing, a genuine improvement, though
`make_baseline.py` still doesn't treat a nonzero code as fatal on its own,
just informational, in case that's not universally true.
