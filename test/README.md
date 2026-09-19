# Testing `app/src/solarchvision_bim/*.pde`

This exists to establish the pattern so more tests can be added the same way.

## Why this isn't a normal `javac`/JUnit setup

Every `.pde` tab (e.g. `Earth3D.pde`) declares one top-level `class
solarchvision_X { ... }`. Processing's own preprocessor merges all tabs
in `app/src/solarchvision_bim/` into a single generated Java file, where:

- The main tab (`solarchvision_bim.pde`) becomes a class named
  `solarchvision_bim` extending `PApplet`.
- Every other tab's class becomes a **non-static inner class** of that
  generated class, so it can call Processing globals (`sin()`, `color()`,
  `PI`, ...) and shared fields (`STATION`, `DOUBLE_r_Earth`, ...).

That means the `.pde` files aren't valid, compilable Java on their own -
you need Processing's own compiler to produce real `.class`/`.java`
output first, and any inner class needs a live instance of the sketch to
construct (`app.new solarchvision_Earth3D()`), even though that instance
never needs to open a window.

## Running

One-time setup:

1. Install Processing (matching what `run.sh` expects), e.g. under
   `~/processing/4.3.4`, or set `PROCESSING_HOME` to point at yours.
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

## Extending this

Anything that touches `WIN3D.graphics`, `PImage`, or live UI/mouse state
isn't unit-testable as-is - the sustainable path is the one used for
`Earth3D.pde` in this session: pull the pure decision/math logic out of
the drawing code into its own small method first (like `buildVertex()`/
`isStationGridCell()`), then test the extracted piece.
