# Contributing to SOLARCHVISION-BIM

This covers getting the project running **from source** for development. If
you just want to use the application, see the [project README](README.md#get-started)
or grab a pre-built binary from [`dist/`](dist/LAUNCH.md) instead — nothing
here is required for that.

## Prerequisites

- **Git**
- **JDK 17+** — a full JDK/JRE, not a "headless" one. Headless packages
  (e.g. Debian/Ubuntu's `openjdk-*-jre-headless`) are missing
  `libawt_xawt.so`/`libjawt.so`, so the app can't open a window at all —
  "Cannot run sketch without a display" regardless of `DISPLAY`, Xvfb, or
  anything else (confirmed directly — see `build-dist.sh`'s own comment).
- **[Processing](https://github.com/processing/processing4)**, either
  generation:
  - **4.5.x+** (current, recommended) — a new `Processing cli` command.
  - **≤4.4.x** (legacy) — the older `processing-java` CLI. Still supported
    here side by side with 4.5.x+; CI (`.github/workflows/ci.yml`) runs the
    full test suite against both every time, as two separate jobs.

  The two generations differ enough in how they're installed and invoked
  that this repo ships a separate pair of run scripts for each — see
  "Run it" below. `test/README.md`'s "Running" section and
  `test/image/README.md`'s "Setup: Processing 4.5.x" cover the same ground
  in more depth.

## 1. Get the code

```sh
git clone https://github.com/archmoj/solarchvision_bim.git
cd solarchvision_bim
```

## 2. Install Processing

Pick one generation (or both, if you want to test against each — that's
what CI does). Install it somewhere `run-with-*.sh`/`.bat` can find, or
point `PROCESSING_HOME` at wherever you put it.

### Linux

Steps below are exactly what `.github/workflows/ci.yml` does, so they're
confirmed working, not just plausible:

**4.5.x+ (portable zip, matches `run-with-latest-processing.sh`):**

```sh
curl -fL -o /tmp/processing.zip \
  https://github.com/processing/processing4/releases/download/processing-1313-4.5.2/processing-4.5.2-linux-x64-portable.zip
mkdir -p ~/processing
unzip -q /tmp/processing.zip -d /tmp/processing-extracted
mv /tmp/processing-extracted/Processing ~/processing/4.5.2
```

**≤4.4.x (`.tgz`, matches `run-with-processing-4.3.sh`):**

```sh
curl -fL -o /tmp/processing.tgz \
  https://github.com/processing/processing4/releases/download/processing-1297-4.3.4/processing-4.3.4-linux-x64.tgz
mkdir -p ~/processing
tar -xf /tmp/processing.tgz -C /tmp
mv /tmp/processing-4.3.4 ~/processing/4.3.4
```

(Swap in a newer version/tag from the
[releases page](https://github.com/processing/processing4/releases) if you
want a later 4.5.x — just keep the two numbers in the URL and the
`mv` destination in sync.)

### Windows

The `.bat` scripts expect each generation at `%USERPROFILE%\processing\<version>`.
Download from the matching release tag
(e.g. [`processing-1313-4.5.2`](https://github.com/processing/processing4/releases/tag/processing-1313-4.5.2)
for 4.5.2) and extract:

- **4.5.x+:** `processing-<version>-windows-x64-portable.zip` →
  `%USERPROFILE%\processing\<version>` (so `Processing.exe` ends up directly
  under that folder — one level shallower than Linux's `bin/Processing`,
  which is exactly what `run-with-latest-processing.bat`'s own comment
  calls out).
- **≤4.4.x:** `processing-<version>-windows-x64.zip` →
  `%USERPROFILE%\processing\<version>`, giving `processing-java.exe` at
  the root.

Unlike the Linux steps above, this isn't something CI actually runs (every
job in this repo builds/tests on `ubuntu-latest`, cross-exporting Windows
binaries rather than running on Windows itself) — so treat it as the
standard, documented way Processing installs on Windows rather than
something verified end-to-end here.

### macOS

macOS releases ship only as a `.dmg` disk-image installer — there's no
portable zip for this platform the way there is for Linux/Windows. Open the
`.dmg` for your chip (`processing-<version>-macos-aarch64.dmg` for Apple
Silicon, `processing-<version>-macos-x64.dmg` for Intel,
[from the releases page](https://github.com/processing/processing4/releases))
and drag `Processing.app` into `/Applications` the normal macOS way.

That also means the `.app` doesn't land at a `bin/Processing`/`Processing.exe`
path, and the `run-with-*.sh` scripts in this repo don't currently look
inside an `.app` bundle — so on macOS, run the CLI directly instead of
through those scripts:

```sh
cd /Applications/Processing.app/Contents/MacOS
./Processing cli --sketch=/path/to/solarchvision_bim/src/solarchvision_bim --run
```

That's Processing's own documented CLI location on macOS, not something
this repo's CI exercises (it only runs on Linux) — if you hit something
that doesn't match, a PR to extend `run-with-latest-processing.sh` to also
check for `Processing.app/Contents/MacOS/Processing` would be a welcome fix.

## 3. Run it

From the repo root, once Processing is installed:

```sh
./run-with-latest-processing.sh     # Processing 4.5.x+
./run-with-processing-4.3.sh        # Processing <=4.4.x
```

or on Windows, `run-with-latest-processing.bat` / `run-with-processing-4.3.bat`.
Set `PROCESSING_HOME` first if you installed somewhere other than the
default path above. Once it's running, the project README's
["Try a first study"](README.md#2-try-a-first-study) section covers the
basics of using it.

## 4. Run the tests

```sh
./test/run_tests.sh
```

One-time setup (a JUnit console launcher jar) and everything else — what's
actually tested, how coverage reporting works, how to extend it — is in
[`test/README.md`](test/README.md). Image-comparison tests have their own
setup, in [`test/image/README.md`](test/image/README.md).

## 5. Build a distributable (optional)

```sh
./build-dist.sh        # every platform
./build-dist.sh linux-amd64 windows-amd64   # just these two, say
```

Needs Processing 4.5.x+ specifically (`--export` doesn't exist in the
legacy CLI) at `PROCESSING_HOME` (`~/processing/4.5.2` by default). See
`build-dist.sh`'s own header comment for what it does and why macOS always
builds without a bundled JVM; `dist/LAUNCH.md` is what end users running
the result actually see.

## Where to go next

- [`command/README.md`](command/README.md) — the command/scripting reference
- [`test/README.md`](test/README.md) / [`test/image/README.md`](test/image/README.md) — testing
- [`import/README.md`](import/README.md) — OSM/Overture 3D import scripts

## Reporting issues / opening PRs

- **Search existing issues first** on the
  [GitHub repository](https://github.com/archmoj/solarchvision_bim) before
  opening a new one.
- When reporting a bug, include your **operating system**, the **steps to
  reproduce**, the **relevant dataset or workflow**, and any **error
  message**.
- For code changes: make sure `./test/run_tests.sh` passes locally first —
  CI runs the same suite against both Processing generations on every push
  and pull request.

## License

By contributing, you agree your contributions are licensed under the
project's [GNU General Public License v2](LICENSE.md), the same as the
rest of the codebase.
