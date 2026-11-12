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

    assertEquals("t2u10p000v20p000w30p000r45p000ry0p000rz0p000", app.Section_Stamp());
  }

  @Test
  void sectionStamp_onABareDefaultScene_isAllZerosAtType0 () {
    assertEquals("t0u0p000v0p000w0p000r0p000ry0p000rz0p000", app.Section_Stamp());
  }

  @Test
  void sectionStamp_replacesMinusSignsWithNRatherThanLeavingThemRaw () {
    app.allSolarImpacts.X = -1.5f;
    app.allSolarImpacts.R = -90;

    assertEquals("t0un1p500v0p000w0p000rn90p000ry0p000rz0p000", app.Section_Stamp());
  }

  @Test
  void sectionStamp_includesRotYAndRotZ_forAType0ArbitrarySection () {
    // Regression coverage for the arbitrary (type 0) section feature:
    // without this, two type-0 sections at the same X/Y/Z/R but a
    // different rotY/rotZ would collide onto the same SceneName, the
    // exact bug this whole test file exists to guard against for the
    // sectionType digit itself.
    app.allSolarImpacts.sectionType = 0;
    app.allSolarImpacts.R = 10;
    app.allSolarImpacts.rotY = 20;
    app.allSolarImpacts.rotZ = -30;

    assertEquals("t0u0p000v0p000w0p000r10p000ry20p000rzn30p000", app.Section_Stamp());
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

    assertEquals("t3u0p000v0p000w0p000r0p000ry0p000rz0p000", app.Section_Stamp(),
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

    assertEquals("t1u5p000v6p000w7p000r8p000ry0p000rz0p000", app.Section_Stamp());
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

  // ================= createStamp ===========================================
  // createStamp()'s own output depends on TIME.year/month/day being seeded
  // from the machine's real clock (year()/month()/day(), at TIME's own
  // construction) only insofar as those feed the *calendar it builds*
  // (createCalendar(), time.pde), not the MM text it returns here - getMM()
  // only ever reads back TIME.beginDay/STUDY.startDay/STUDY.endDay/
  // STUDY.dayIncrement, all of which are pinned below, so these assertions
  // hold on any run date without needing to fake the clock.

  @Test
  void createStamp_bareDefaultScene_buildsImgPrefixPlusCityPlusDayRange () {
    // Defaults: SavedScreenShots 0 (+1 below), STATION "Toronto",
    // impactDisplayDay 0 (the "-" range branch), STUDY.startDay/endDay/
    // dayIncrement/TIME.beginDay all at their bare-construction values
    // (0 / 12 / 30.5 / 0) - day 0 of the range is Jan 1, day 11 (endDay-1)
    // lands in December.
    assertEquals("IMG0001_Toronto_01-12", app.createStamp(1, "Screen"));
  }

  @Test
  void createStamp_incrementsSavedScreenShotsAcrossCalls_andZeroPadsToFourDigits () {
    app.createStamp(1, "Screen"); // SavedScreenShots: 0 -> 1
    app.createStamp(1, "Screen"); // SavedScreenShots: 1 -> 2
    String third = app.createStamp(7, "Screen"); // SavedScreenShots: 2 -> 9

    assertEquals("IMG0009_Toronto_01-12", third);
  }

  @Test
  void createStamp_win3DStampUsesTheCameraIndexInsteadOfSavedScreenShots () {
    app.WIN3D.currentCameraIndex = 3;

    assertEquals("CAM03_Toronto_01-12", app.createStamp(0, "WIN3D"),
        "the \"WIN3D\" CLASS_STAMP branch must read WIN3D.currentCameraIndex, not SavedScreenShots");
  }

  @Test
  void createStamp_withASingleImpactDisplayDay_omitsTheDashedRangeAndUsesOneDate () {
    app.impactDisplayDay = 1; // (1-1)*dayIncrement + 286 + beginDay == 286 == Jan 1

    assertEquals("IMG0001_Toronto_01", app.createStamp(1, "Screen"));
  }

  @Test
  void createStamp_reflectsACustomStationCity () {
    app.STATION.setCity("Vancouver");

    assertEquals("IMG0001_Vancouver_01-12", app.createStamp(1, "Screen"));
  }

  // ================= MAKE_Filename =========================================

  @Test
  void makeFilename_joinsFolderScreenShotsAndTheGivenNameWithASlash () {
    app.Folder_ScreenShots = "out/screenshots/run1";

    assertEquals("out/screenshots/run1/shot_01", app.MAKE_Filename("shot_01"));
  }

  // ================= MAKE_MainName =========================================

  @Test
  void makeMainName_isEmptyForEveryDataSourceOtherThanEnsembleForecast () {
    // dataID_climateTypicalYear is the default current_DataSource.
    assertEquals("", app.MAKE_MainName());

    app.currentDataSource = app.dataID_climateEngineering;
    assertEquals("", app.MAKE_MainName());

    app.currentDataSource = app.dataID_climateArchive;
    assertEquals("", app.MAKE_MainName());
  }

  @Test
  void makeMainName_encodesDateAndStudyLengthForEnsembleForecast () {
    app.currentDataSource = app.dataID_ensembleForecast;
    app.TIME.year = 24;
    app.TIME.month = 3;
    app.TIME.day = 7;
    app.STUDY.endDay = 12;

    assertEquals("240307_12dayFORECAST_", app.MAKE_MainName());
  }

  // ================= getFilename_SolidImpact ===============================
  // allSolidImpacts' Z/R/rotY/rotZ are indexed by its own sectionType (see
  // arbitrarySection.pde / sections.pde), so these pin sectionType and its
  // matching index together rather than touching index 0 only.

  @Test
  void getFilenameSolidImpact_bareDefaultScene_encodesEveryFieldAtSectionType0 () {
    app.Folder_Graphics = "FG";
    app.TIME.year = 24;
    app.TIME.month = 3;
    app.TIME.day = 15;
    // allSolidImpacts defaults: sectionType 0, Z[0] 0, R[0]/rotY[0]/rotZ[0]
    // 0, Power 1.0, Grade 0.02; currentDataSource defaults to
    // dataID_climateTypicalYear.

    assertEquals(
        "FG/24-03-15/Climate Typical Year/Impacts/Solid0h0000r000ry000rz000p01_00m00_02",
        app.getFilename_SolidImpact());
  }

  @Test
  void getFilenameSolidImpact_readsZRRotYRotZ_fromTheSectionTypesOwnIndex () {
    app.Folder_Graphics = "FG";
    app.TIME.year = 24;
    app.TIME.month = 3;
    app.TIME.day = 15;
    app.currentDataSource = app.dataID_climateArchive;

    app.allSolidImpacts.sectionType = 2;
    app.allSolidImpacts.Z[2] = 5;
    app.allSolidImpacts.R[2] = 3;
    app.allSolidImpacts.rotY[2] = 1;
    app.allSolidImpacts.rotZ[2] = 2;
    app.allSolidImpacts.Power = 2.0f;
    app.allSolidImpacts.Grade = 0.1f;
    // Decoys at other indices - must be ignored since sectionType is 2.
    app.allSolidImpacts.Z[0] = 99;
    app.allSolidImpacts.R[1] = 99;
    app.allSolidImpacts.rotY[3] = 99;

    assertEquals(
        "FG/24-03-15/Climate Archive/Impacts/Solid2h0005r003ry001rz002p02_00m00_10",
        app.getFilename_SolidImpact());
  }

  // ================= getFilename_SolarImpact ================================
  // Unlike SolidImpacts, SolarImpacts keeps Z/R as single (non-array)
  // fields, so there's no per-sectionType index to thread through here.

  @Test
  void getFilenameSolarImpact_bareDefaultScene_encodesEveryField () {
    app.Folder_Graphics = "FG";
    app.TIME.year = 24;
    app.TIME.month = 3;
    app.TIME.day = 15;

    assertEquals(
        "FG/24-03-15/Climate Typical Year/Impacts/Solar0h0000r000",
        app.getFilename_SolarImpact());
  }

  @Test
  void getFilenameSolarImpact_reflectsSectionTypeZAndR () {
    app.Folder_Graphics = "FG";
    app.TIME.year = 24;
    app.TIME.month = 3;
    app.TIME.day = 15;
    app.currentDataSource = app.dataID_ensembleObservation;

    app.allSolarImpacts.sectionType = 1;
    app.allSolarImpacts.Z = 8;
    app.allSolarImpacts.R = 4;

    assertEquals(
        "FG/24-03-15/Ensemble Observation/Impacts/Solar1h0008r004",
        app.getFilename_SolarImpact());
  }
}
