# Fallback JUnit (for when the real jar isn't reachable)

`test/run_tests.sh` (see `test/README.md`) needs a real
`junit-platform-console-standalone-<version>.jar`, normally downloaded from
Maven Central. That works fine on a normal dev machine or CI, but it doesn't
in every environment - most notably, a sandboxed coding-agent session (e.g.
Claude running in a container with an egress allowlist) often can't reach
`repo1.maven.org` at all, and there's no GitHub release carrying that exact
jar as a downloadable asset either (JUnit's own GitHub releases are
source-only - the published jar only lives on Maven Central).

This directory exists so that situation doesn't need re-solving from
scratch every time: a hand-written stand-in for just the pieces of the real
JUnit 5 API this repo's own `test/*.java` files actually use (`@Test`,
`@BeforeEach`, `@BeforeAll`, `Assertions`, and the two functional
interfaces `assertDoesNotThrow`/`assertThrows` need), plus a small
reflection-based runner that plays the same role as
`org.junit.platform.console.ConsoleLauncher`. It was built by actually
compiling the whole real suite against it and fixing whatever the compiler
flagged as missing, then running every test and confirming the results
looked right - not written speculatively.

**This is a fallback, not a replacement.** Prefer `test/run_tests.sh` with
a real JUnit jar whenever one is reachable - this stub has none of the
real platform's filtering, tagging, parallelism, or detailed reporting,
and doesn't support `@AfterEach`/`@AfterAll`/`@Nested`/`@ParameterizedTest`
(nothing here uses them yet). Reach for this specifically when Maven
Central (or an equivalent jar host) isn't reachable from wherever you're
running.

## Layout

```
test/fallback-junit/
  README.md              (this file)
  src/
    org/junit/jupiter/api/Test.java
    org/junit/jupiter/api/BeforeEach.java
    org/junit/jupiter/api/BeforeAll.java
    org/junit/jupiter/api/Assertions.java
    org/junit/jupiter/api/function/Executable.java
    org/junit/jupiter/api/function/ThrowingSupplier.java
    TestRunner.java       (the ConsoleLauncher stand-in)
```

## Using it

`test/run_tests_fallback.sh` (next to `run_tests.sh`) runs the whole thing
end to end - find or install Processing, build the sketch, compile this
stub, compile `test/*.java` against it, compile `TestRunner`, run it. See
that script's own header for exactly what it does and its environment
variables. In short:

```sh
./test/run_tests_fallback.sh
```

If you're doing this by hand instead (e.g. adapting the approach rather
than running the script as-is), the shape is:

1. Build the sketch with Processing's own CLI, the same way
   `run_tests.sh` does (see `test/README.md`) - this needs Processing
   installed somewhere, which itself needs network access; Processing's
   GitHub releases (`github.com/processing/processing4/releases`) are
   often reachable even when Maven Central isn't, since release assets
   are served from `release-assets.githubusercontent.com` - that's a
   normal download, no special handling needed, and it's what
   `run_tests_fallback.sh` does automatically if `PROCESSING_HOME` isn't
   already set to a working install.
2. Compile everything under `src/` here into a `classes/` directory.
3. Compile `test/*.java` with that `classes/` directory (plus
   Processing's own `core.jar` and the sketch's own compiled classes)
   on the classpath.
4. Run `TestRunner`, passing it the directory your compiled test classes
   landed in.

## Extending it

If a future test file needs an `Assertions` method or overload that
isn't here, the compiler error naming the missing symbol says exactly
what to add - follow the pattern of its neighbors in `Assertions.java`.
The same goes for `TestRunner.java` if a test file ever needs
`@AfterEach`/`@AfterAll`/`@Nested`/etc. - none of that exists yet because
nothing currently needs it.
