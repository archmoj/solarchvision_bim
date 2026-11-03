// Minimal stand-in for the real JUnit 5 API - see test/fallback-junit/README.md
// for what this is and when to reach for it instead of the real jar.

package org.junit.jupiter.api.function;

@FunctionalInterface
public interface ThrowingSupplier<T> {
  T get() throws Throwable;
}
