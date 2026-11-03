// Minimal stand-in for org.junit.jupiter.api.Assertions - see
// test/fallback-junit/README.md for what this is and when to reach for
// it instead of the real jar. Covers exactly the methods/overloads this
// repo's own test/*.java files actually call (confirmed by compiling
// and running the whole suite against this stub - see that README for
// how) - not the full real Assertions API. If a test file is later
// written using an overload or method that isn't here yet, add it
// following the same pattern as its neighbors; the compiler will say
// exactly which one's missing.

package org.junit.jupiter.api;

import org.junit.jupiter.api.function.Executable;
import org.junit.jupiter.api.function.ThrowingSupplier;
import java.util.Arrays;

public class Assertions {

  public static class TestAssertionError extends AssertionError {
    public TestAssertionError(String msg) { super(msg); }
  }

  public static void fail(String msg) {
    throw new TestAssertionError(msg);
  }

  public static void fail(String msg, Throwable cause) {
    TestAssertionError e = new TestAssertionError(msg);
    e.initCause(cause);
    throw e;
  }

  public static void fail(Throwable cause) {
    fail(String.valueOf(cause), cause);
  }

  // ===== assertEquals: ints/longs/Objects =====
  public static void assertEquals(int expected, int actual) {
    assertEquals(expected, actual, "");
  }
  public static void assertEquals(int expected, int actual, String msg) {
    if (expected != actual) fail(msg + " ==> expected: <" + expected + "> but was: <" + actual + ">");
  }
  public static void assertEquals(long expected, long actual) {
    assertEquals(expected, actual, "");
  }
  public static void assertEquals(long expected, long actual, String msg) {
    if (expected != actual) fail(msg + " ==> expected: <" + expected + "> but was: <" + actual + ">");
  }
  public static void assertEquals(Object expected, Object actual) {
    assertEquals(expected, actual, "");
  }
  public static void assertEquals(Object expected, Object actual, String msg) {
    boolean eq = (expected == null) ? (actual == null) : expected.equals(actual);
    if (!eq) fail(msg + " ==> expected: <" + expected + "> but was: <" + actual + ">");
  }

  // ===== assertEquals: float/double with delta =====
  public static void assertEquals(float expected, float actual, float delta) {
    assertEquals(expected, actual, delta, "");
  }
  public static void assertEquals(float expected, float actual, float delta, String msg) {
    if (Math.abs(expected - actual) > delta) fail(msg + " ==> expected: <" + expected + "> but was: <" + actual + ">");
  }
  public static void assertEquals(double expected, double actual, double delta) {
    assertEquals(expected, actual, delta, "");
  }
  public static void assertEquals(double expected, double actual, double delta, String msg) {
    if (Math.abs(expected - actual) > delta) fail(msg + " ==> expected: <" + expected + "> but was: <" + actual + ">");
  }

  // ===== assertArrayEquals =====
  public static void assertArrayEquals(int[] expected, int[] actual) {
    assertArrayEquals(expected, actual, "");
  }
  public static void assertArrayEquals(int[] expected, int[] actual, String msg) {
    if (!Arrays.equals(expected, actual)) fail(msg + " ==> expected: <" + Arrays.toString(expected) + "> but was: <" + Arrays.toString(actual) + ">");
  }
  public static void assertArrayEquals(boolean[] expected, boolean[] actual) {
    assertArrayEquals(expected, actual, "");
  }
  public static void assertArrayEquals(boolean[] expected, boolean[] actual, String msg) {
    if (!Arrays.equals(expected, actual)) fail(msg + " ==> expected: <" + Arrays.toString(expected) + "> but was: <" + Arrays.toString(actual) + ">");
  }
  public static void assertArrayEquals(String[] expected, String[] actual) {
    assertArrayEquals(expected, actual, "");
  }
  public static void assertArrayEquals(String[] expected, String[] actual, String msg) {
    if (!Arrays.equals(expected, actual)) fail(msg + " ==> expected: <" + Arrays.toString(expected) + "> but was: <" + Arrays.toString(actual) + ">");
  }
  public static void assertArrayEquals(float[] expected, float[] actual, float delta) {
    assertArrayEquals(expected, actual, delta, "");
  }
  public static void assertArrayEquals(float[] expected, float[] actual, float delta, String msg) {
    if (expected.length != actual.length) { fail(msg + " ==> array lengths differ: " + expected.length + " vs " + actual.length); return; }
    for (int i = 0; i < expected.length; i++) {
      if (Math.abs(expected[i] - actual[i]) > delta) { fail(msg + " ==> expected: <" + Arrays.toString(expected) + "> but was: <" + Arrays.toString(actual) + ">"); return; }
    }
  }
  public static void assertArrayEquals(Object[] expected, Object[] actual) {
    assertArrayEquals(expected, actual, "");
  }
  public static void assertArrayEquals(Object[] expected, Object[] actual, String msg) {
    if (!Arrays.deepEquals(expected, actual)) fail(msg + " ==> expected: <" + Arrays.toString(expected) + "> but was: <" + Arrays.toString(actual) + ">");
  }

  // ===== booleans =====
  public static void assertTrue(boolean cond) { assertTrue(cond, ""); }
  public static void assertTrue(boolean cond, String msg) { if (!cond) fail(msg + " ==> expected true"); }
  public static void assertFalse(boolean cond) { assertFalse(cond, ""); }
  public static void assertFalse(boolean cond, String msg) { if (cond) fail(msg + " ==> expected false"); }

  // ===== null checks =====
  public static void assertNull(Object o) { assertNull(o, ""); }
  public static void assertNull(Object o, String msg) { if (o != null) fail(msg + " ==> expected null but was: <" + o + ">"); }
  public static void assertNotNull(Object o) { assertNotNull(o, ""); }
  public static void assertNotNull(Object o, String msg) { if (o == null) fail(msg + " ==> expected not null"); }

  // ===== identity / inequality =====
  public static void assertSame(Object expected, Object actual) { assertSame(expected, actual, ""); }
  public static void assertSame(Object expected, Object actual, String msg) { if (expected != actual) fail(msg + " ==> expected same instance"); }
  public static void assertNotSame(Object expected, Object actual) { assertNotSame(expected, actual, ""); }
  public static void assertNotSame(Object expected, Object actual, String msg) { if (expected == actual) fail(msg + " ==> expected different instances"); }
  public static void assertNotEquals(Object expected, Object actual) { assertNotEquals(expected, actual, ""); }
  public static void assertNotEquals(Object expected, Object actual, String msg) {
    boolean eq = (expected == null) ? (actual == null) : expected.equals(actual);
    if (eq) fail(msg + " ==> expected values to differ, both were: <" + actual + ">");
  }
  public static void assertNotEquals(int expected, int actual) { if (expected == actual) fail("expected values to differ, both were: <" + actual + ">"); }
  public static void assertNotEquals(int expected, int actual, String msg) { if (expected == actual) fail(msg + " ==> expected values to differ, both were: <" + actual + ">"); }
  public static void assertNotEquals(float expected, float actual, float delta) {
    if (Math.abs(expected - actual) <= delta) fail("expected values to differ (within delta " + delta + "), both were close to: <" + actual + ">");
  }
  public static void assertNotEquals(float expected, float actual, float delta, String msg) {
    if (Math.abs(expected - actual) <= delta) fail(msg + " ==> expected values to differ (within delta " + delta + "), both were close to: <" + actual + ">");
  }
  public static void assertNotEquals(double expected, double actual, double delta) {
    if (Math.abs(expected - actual) <= delta) fail("expected values to differ (within delta " + delta + "), both were close to: <" + actual + ">");
  }
  public static void assertNotEquals(double expected, double actual, double delta, String msg) {
    if (Math.abs(expected - actual) <= delta) fail(msg + " ==> expected values to differ (within delta " + delta + "), both were close to: <" + actual + ">");
  }

  // ===== type checks =====
  @SuppressWarnings("unchecked")
  public static <T> T assertInstanceOf(Class<T> expectedType, Object actual) {
    return assertInstanceOf(expectedType, actual, "");
  }
  @SuppressWarnings("unchecked")
  public static <T> T assertInstanceOf(Class<T> expectedType, Object actual, String msg) {
    if (actual == null || !expectedType.isInstance(actual)) {
      fail(msg + " ==> expected instance of " + expectedType.getName() + " but was: <" + actual + ">");
    }
    return (T) actual;
  }

  // ===== exceptions =====
  public static void assertDoesNotThrow(Executable e) {
    try {
      e.execute();
    } catch (Throwable t) {
      throw new TestAssertionError("Unexpected exception thrown: " + t);
    }
  }

  public static <T> T assertDoesNotThrow(ThrowingSupplier<T> s) {
    try {
      return s.get();
    } catch (Throwable t) {
      throw new TestAssertionError("Unexpected exception thrown: " + t);
    }
  }

  @SuppressWarnings("unchecked")
  public static <T extends Throwable> T assertThrows(Class<T> expectedType, Executable e) {
    try {
      e.execute();
    } catch (Throwable t) {
      if (expectedType.isInstance(t)) return (T) t;
      throw new TestAssertionError("Unexpected exception type: expected " + expectedType.getName() + " but got " + t.getClass().getName());
    }
    throw new TestAssertionError("Expected " + expectedType.getName() + " to be thrown, but nothing was thrown.");
  }
}
