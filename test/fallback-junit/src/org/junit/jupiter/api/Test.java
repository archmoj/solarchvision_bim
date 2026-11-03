// Minimal stand-in for the real JUnit 5 API - see test/fallback-junit/README.md
// for what this is and when to reach for it instead of the real jar.

package org.junit.jupiter.api;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Test {
}
