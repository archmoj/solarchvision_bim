// A reflection-based substitute for org.junit.platform.console.ConsoleLauncher
// - see test/fallback-junit/README.md for what this is and when to reach
// for it instead of the real JUnit console launcher jar. Takes one
// argument: the directory of already-compiled test classes (e.g.
// build/all-test-classes) to scan. For each top-level, non-nested class
// found there, runs any static @BeforeAll methods once, then for every
// @Test method: constructs a fresh instance, runs any @BeforeEach
// methods on it, invokes the test method, and records pass/fail/error.
// No filtering, tagging, parallelism, or @AfterEach/@AfterAll/@Nested/
// @ParameterizedTest support - this repo's test/*.java files don't use
// any of those, so there was nothing to reproduce; add support the same
// way if a later test file needs it.
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class TestRunner {
  static int totalPassed = 0;
  static int totalFailed = 0;
  static int totalErrored = 0;
  static List<String> failures = new ArrayList<>();

  public static void main(String[] args) throws Exception {
    String testClassesDir = args[0];
    List<String> classNames = new ArrayList<>();
    File dir = new File(testClassesDir);
    for (File f : dir.listFiles()) {
      String name = f.getName();
      if (name.endsWith(".class") && !name.contains("$")) {
        classNames.add(name.substring(0, name.length() - 6));
      }
    }
    java.util.Collections.sort(classNames);

    for (String className : classNames) {
      runClass(className);
    }

    System.out.println();
    System.out.println("========================================");
    System.out.println("TOTAL: " + totalPassed + " passed, " + totalFailed + " failed, " + totalErrored + " errored");
    if (!failures.isEmpty()) {
      System.out.println("Failures:");
      for (String f : failures) System.out.println("  " + f);
    }

    // Matters for scripted/CI use (run_tests_fallback.sh relies on this
    // to fail the build) - without it, the process always exits 0 even
    // when tests failed.
    if ((totalFailed > 0) || (totalErrored > 0)) {
      System.exit(1);
    }
  }

  static void runClass(String className) {
    Class<?> clazz;
    try {
      clazz = Class.forName(className);
    } catch (Throwable t) {
      return; // not a loadable class (e.g. compile issue) - skip
    }

    // Run @BeforeAll (static methods)
    for (Method m : clazz.getDeclaredMethods()) {
      if (isAnnotated(m, "BeforeAll") && Modifier.isStatic(m.getModifiers())) {
        try {
          m.setAccessible(true);
          m.invoke(null);
        } catch (Throwable t) {
          System.out.println("ERROR in @BeforeAll for " + className + ": " + rootCause(t));
          totalErrored++;
          return;
        }
      }
    }

    List<Method> testMethods = new ArrayList<>();
    for (Method m : clazz.getDeclaredMethods()) {
      if (isAnnotated(m, "Test")) testMethods.add(m);
    }
    if (testMethods.isEmpty()) return;

    for (Method testMethod : testMethods) {
      String fullName = className + "." + testMethod.getName();
      try {
        Object instance = clazz.getDeclaredConstructor().newInstance();

        for (Method m : clazz.getDeclaredMethods()) {
          if (isAnnotated(m, "BeforeEach")) {
            m.setAccessible(true);
            m.invoke(instance);
          }
        }

        testMethod.setAccessible(true);
        testMethod.invoke(instance);

        totalPassed++;
      } catch (Throwable t) {
        Throwable root = rootCauseThrowable(t);
        if (root.getClass().getName().contains("TestAssertionError") || root instanceof AssertionError) {
          totalFailed++;
          failures.add(fullName + " -- " + root.getMessage());
          System.out.println("FAIL: " + fullName + " -- " + root.getMessage());
        } else {
          totalErrored++;
          failures.add(fullName + " -- ERROR: " + root);
          System.out.println("ERROR: " + fullName + " -- " + root);
        }
      }
    }
  }

  static boolean isAnnotated(Method m, String simpleAnnotationName) {
    for (java.lang.annotation.Annotation a : m.getDeclaredAnnotations()) {
      if (a.annotationType().getSimpleName().equals(simpleAnnotationName)) return true;
    }
    return false;
  }

  static Throwable rootCauseThrowable(Throwable t) {
    Throwable cause = t;
    while (cause.getCause() != null && cause.getCause() != cause) {
      cause = cause.getCause();
    }
    return cause;
  }

  static String rootCause(Throwable t) {
    return rootCauseThrowable(t).toString();
  }
}
