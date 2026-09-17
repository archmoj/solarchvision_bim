# Testing `app/src/solarchvision_bim/*.pde`

This is a starting scaffold, not full coverage - it exists to establish
the pattern so more tests can be added the same way.

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

## What's here

- `EarthGridHelpersTest.java` - JUnit 5 tests for a handful of pure,
  deterministic helpers in `Earth3D.pde` (`isStationGridCell`,
  `isRoundGridLine`, `unwrapLon`). These take plain `float`s in, return a
  plain value out, touch no texture/image data, no file I/O, and no
  graphics context - the cheapest, safest things to unit test in this
  codebase.
- `run_tests.sh` - builds the sketch with Processing's own compiler, then
  compiles and runs the tests against the result.

Three of `Earth3D.pde`'s helpers (`isStationGridCell`, `isRoundGridLine`,
`unwrapLon`) were changed from `private` to package-private specifically
so this test class - deliberately left in the same default/unnamed
package as the generated sketch class - can call them directly, with no
reflection needed.

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

Good next candidates, roughly in order of value/effort - all pure
math/parsing with no rendering or file dependency:

- `Functions.pde` (`solarchvision_Functions`/`funcs`): `cos_ang`,
  `roundTo`, `lon_lat_dist`, `convert_lonlat2XY`.
- `TIME.pde` date/time arithmetic.
- `SolarAtSurface.pde` / `SolarImpacts.pde` / `WindRose.pde` angle and
  radiation math.
- `isIntersected_Faces.pde` geometry intersection tests.

For anything that needs actual station/EPW data (`STATION.pde`,
`DataUtils.pde`) or a loaded texture image (`Earth3D.pde`'s
`computeElevationBump`/`computeElevationBumpBilinear`), treat it as an
integration test instead: feed it a small, checked-in fixture file and
assert on the parsed/computed values, rather than trying to keep it a
fast, no-I/O unit test.

Anything that touches `WIN3D.graphics`, `PImage`, or live UI/mouse state
isn't unit-testable as-is - the sustainable path is the one used for
`Earth3D.pde` in this session: pull the pure decision/math logic out of
the drawing code into its own small method first (like `buildVertex()`/
`isStationGridCell()`), then test the extracted piece.
