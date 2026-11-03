# Testing `src/solarchvision_bim/*.pde`

This exists to establish the pattern so more tests can be added the same way.

## Why this isn't a normal `javac`/JUnit setup

Every `.pde` tab (e.g. `earth3D.pde`) declares one top-level `class
X { ... }`. Processing's own preprocessor merges all tabs
in `src/solarchvision_bim/` into a single generated Java file, where:

- The main tab (`solarchvision_bim.pde`) becomes a class named
  `solarchvision_bim` extending `PApplet`.
- Every other tab's class becomes a **non-static inner class** of that
  generated class, so it can call Processing globals (`sin()`, `color()`,
  `PI`, ...) and shared fields (`STATION`, `DOUBLE_r_Earth`, ...).

That means the `.pde` files aren't valid, compilable Java on their own -
you need Processing's own compiler to produce real `.class`/`.java`
output first, and any inner class needs a live instance of the sketch to
construct (`app.new Earth3D()`), even though that instance
never needs to open a window.

## Running

One-time setup:

1. Install Processing - either generation, on any platform, works, auto-
   detected by `run_tests.sh`:
   - `<=4.4.x` (matching `run-with-processing-4.3.sh`, or
     `run-with-processing-4.3.bat` on Windows), e.g. under
     `~/processing/4.3.4`
   - `4.5.x+` (matching `run-with-latest-processing.sh`, or
     `run-with-latest-processing.bat` on Windows), e.g. under
     `~/processing/4.5.2`. Windows' portable build of this one lays out
     one directory level shallower than Linux/macOS (`Processing.exe`
     directly at the install root instead of `bin/Processing`, no `lib/`
     wrapper around `app/`) - also auto-detected, no extra setup needed.

   Point `PROCESSING_HOME` at wherever it's installed if it's not under
   `~/processing/4.3.4` (the default, for backwards compatibility).
2. Download a `junit-platform-console-standalone` jar (any recent 1.x
   release) from
   https://search.maven.org/artifact/org.junit.platform/junit-platform-console-standalone
   and drop it anywhere under `test/lib/`. Its filename normally includes
   the version (e.g. `junit-platform-console-standalone-6.1.3.jar`) -
   that's fine, `run_tests.sh` picks it up automatically. Set `JUNIT_JAR`
   instead if you'd rather point at a jar living somewhere else.

Then:

```sh
./test/run_tests.sh
```

CI (`.github/workflows/ci.yml`) runs this against both Processing
generations, as two separate jobs (a matrix over `processing_version`).

### No access to a real JUnit jar?

Step 2 above needs Maven Central (or an equivalent jar host) reachable,
which isn't always true - most notably in a sandboxed coding-agent
session with a network allowlist that doesn't include
`repo1.maven.org`. `test/fallback-junit/` is a stand-in for exactly that
situation: a minimal hand-written implementation of just the JUnit 5
pieces this repo's own tests use, plus a small runner, verified by
actually compiling and running the whole suite against it. See
`test/fallback-junit/README.md` for what it does and doesn't cover, then:

```sh
./test/run_tests_fallback.sh
```

which finds or installs Processing itself (no step 1 needed either) and
runs everything end to end. Prefer the real `run_tests.sh` whenever a
real JUnit jar is reachable - reach for this one specifically when it
isn't.

## Coverage

`run_tests.sh` generates a [JaCoCo](https://www.jacoco.org/jacoco/) coverage
report automatically whenever it finds `jacocoagent.jar`/`jacococli.jar`
under `test/lib/jacoco/` - it's entirely optional, skipped (not an error)
otherwise, so installing it isn't part of the one-time setup above.

To get a report locally:

```sh
./test/install_jacoco.sh   # run from inside test/, like install_junit.sh
cd ..
./test/run_tests.sh
```

This writes, under `build/test/coverage/`:

- `html/index.html` - browsable, per-package/class coverage, including a
  source-highlighted view per class
- `coverage.xml` - machine-readable, for CI tooling (e.g. a coverage-diff
  or badge action)
- `coverage.csv` - the same data, one row per class

and prints a quick instructions/branches/lines summary to the terminal.
The source-highlighted view is against Processing's own generated
`solarchvision_bim.java` (found automatically under `build/test/`, next
to the compiled classes) rather than the original `.pde` tabs - that's
genuinely what the compiled bytecode maps to, so the line numbers there
are accurate, just not the same line numbers you'd see editing the `.pde`
files directly in `src/solarchvision_bim/`.

CI (`.github/workflows/ci.yml`) always installs JaCoCo, so every run gets
a coverage report: a summary table in the workflow's Job Summary, and the
full HTML/XML/CSV report uploaded as a `coverage-report` build artifact.

## Extending this

Anything that touches `WIN3D.graphics`, `PImage`, or live UI/mouse state
isn't unit-testable as-is - the sustainable path is the one used for
`earth3D.pde` in this session: pull the pure decision/math logic out of
the drawing code into its own small method first (like `buildVertex()`/
`isStationGridCell()`), then test the extracted piece.
