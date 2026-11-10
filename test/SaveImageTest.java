import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// saveImage.pde's stamp helpers are top-level (not scoped to any class),
// so they're called directly on the app instance - e.g. app.Section_
// Stamp(), not app.SomeClass.Section_Stamp() - the same way global_
// functions.pde's own functions are (see GlobalFunctionsTest.java).
//
// This exists as baseline coverage ahead of generalizing sections from
// the current 3 discrete types (sectionType 1/2/3, one rotation angle
// each) to arbitrary tilt+azimuth - so that refactor has something to
// prove it hasn't changed today's behavior, beyond the one spot it means
// to (rotateSectionCorner()/getCorners(), covered separately in
// SectionsTest.java).
class SaveImageTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= NearLatitude_Stamp ===================================

  @Test
  void nearLatitudeStamp_matchesTheDefaultStationsRoundedLatitude () {
    // globalVariables.pde's default STATION is Toronto, latitude 43.67 -
    // rounds to 44, northern hemisphere.
    assertEquals("44N", app.NearLatitude_Stamp());
  }

  @Test
  void nearLatitudeStamp_usesSForASouthernLatitude () {
    app.STATION.setLatitude(-33.87f); // Sydney

    assertEquals("34S", app.NearLatitude_Stamp());
  }

  @Test
  void nearLatitudeStamp_zeroPadsToTwoDigitsAndTreatsExactZeroAsNorth () {
    app.STATION.setLatitude(0f);

    assertEquals("00N", app.NearLatitude_Stamp());
  }

  @Test
  void nearLatitudeStamp_roundsToTheNearestWholeDegree () {
    app.STATION.setLatitude(43.49f);
    assertEquals("43N", app.NearLatitude_Stamp());

    app.STATION.setLatitude(43.5f);
    assertEquals("43N", app.NearLatitude_Stamp(), "exact ties round down (toward floor), matching funcs.roundTo()'s own tie-break");
  }

  // ================= Section_Stamp =========================================
  // Section_Stamp() is called from castShadows_CurrentSection() /
  // render_ShadowsOnSections() / calculate_ImpactOnSections() (solarImpacts.pde),
  // all of which operate purely on allSolarImpacts - so every field
  // Section_Stamp() reads must come from allSolarImpacts, never from the
  // unrelated allSolidImpacts object (see the regression test below).

  @Test
  void sectionStamp_encodesTypeAndEveryPositionField_inOrder () {
    app.allSolarImpacts.sectionType = 2;
    app.allSolarImpacts.X = 10;
    app.allSolarImpacts.Y = 20;
    app.allSolarImpacts.Z = 30;
    app.allSolarImpacts.R = 45;

    assertEquals("t2u10p000v20p000w30p000r45p000", app.Section_Stamp());
  }

  @Test
  void sectionStamp_onABareDefaultScene_isAllZerosAtType0 () {
    assertEquals("t0u0p000v0p000w0p000r0p000", app.Section_Stamp());
  }

  @Test
  void sectionStamp_replacesMinusSignsWithNRatherThanLeavingThemRaw () {
    app.allSolarImpacts.X = -1.5f;
    app.allSolarImpacts.R = -90;

    assertEquals("t0un1p500v0p000w0p000rn90p000", app.Section_Stamp());
  }

  @Test
  void sectionStamp_readsSectionTypeFromSolarImpactsNotSolidImpacts () {
    // Regression test for the bug this covers: Section_Stamp() used to read
    // "t" from allSolidImpacts.sectionType - a completely different object,
    // never touched by the section-baking loop - instead of
    // allSolarImpacts.sectionType, the one castShadows_CurrentSection()/
    // render_ShadowsOnSections() actually set per-section just before
    // calling this. That let allSolidImpacts.sectionType's leftover value
    // silently leak into every baked section's SceneName.
    app.allSolarImpacts.sectionType = 3;
    app.allSolidImpacts.sectionType = 1; // deliberately different and untouched

    assertEquals("t3u0p000v0p000w0p000r0p000", app.Section_Stamp(),
        "the 't' digit must track allSolarImpacts.sectionType, not allSolidImpacts.sectionType");
  }

  @Test
  void sectionStamp_isUnaffectedByAnyAllSolidImpactsField () {
    // Companion to the test above: proves none of Section_Stamp()'s other
    // 4 fields (u/v/w/r) are accidentally sourced from allSolidImpacts
    // either, by setting allSolidImpacts to clearly distinguishable values
    // and confirming the stamp is still built purely from allSolarImpacts.
    app.allSolarImpacts.sectionType = 1;
    app.allSolarImpacts.X = 5;
    app.allSolarImpacts.Y = 6;
    app.allSolarImpacts.Z = 7;
    app.allSolarImpacts.R = 8;

    app.allSolidImpacts.sectionType = 2;
    app.allSolidImpacts.X[2] = 999;
    app.allSolidImpacts.Y[2] = 999;
    app.allSolidImpacts.Z[2] = 999;
    app.allSolidImpacts.R[2] = 999;

    assertEquals("t1u5p000v6p000w7p000r8p000", app.Section_Stamp());
  }

  @Test
  void sectionStamp_regression_threeDefaultPositionedSectionsOfDifferentTypesNoLongerCollide () {
    // Reproduces the originally-reported bug at the field level (without
    // going through castShadows_CurrentSection()'s createGraphics() calls,
    // which aren't runnable headlessly - see test/README.md's "Extending
    // this" section): 3 freshly-created sections, left at their default
    // X/Y/Z/R (as "SOLARCHVISION all sections" would process them), differing
    // only by type 1/2/3 - the exact shape render_ShadowsOnSections()'s own
    // loop drives allSolarImpacts through, one section at a time.
    java.util.Set<String> stamps = new java.util.HashSet<>();

    for (int type = 1; type <= 3; type++) {
      app.allSolarImpacts.sectionType = type;
      app.allSolarImpacts.X = 0;
      app.allSolarImpacts.Y = 0;
      app.allSolarImpacts.Z = 0;
      app.allSolarImpacts.R = 0;

      stamps.add(app.Section_Stamp());
    }

    assertEquals(3, stamps.size(), "each section type must get its own SceneName even when every other field matches");
  }

  // ================= Viewport_Stamp =========================================
  // Currently a stub (its body is entirely commented out) - pinned here so
  // a future change to it is deliberate, not accidental.

  @Test
  void viewportStamp_isCurrentlyAlwaysEmpty () {
    assertEquals("", app.Viewport_Stamp());
  }
}
