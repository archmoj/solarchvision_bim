import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Edit3D - previously untested - is the scroll-wheel/keyboard "nudge the
// current selection's property by a step" logic (mouseWheel.pde's own
// caller, among others): a current UITASK (User3D.currentTool) selects
// WHICH property adjusts, and the int `p` each method below takes is a
// direction/step count, not a mouse delta - same "mode selected
// elsewhere, this just applies the nudge" shape as uiSetTo.pde's own
// Modify_* family (UiSetToModifyAndViewTest.java's own header comment).
// Every category's own calculate_ImpactOnSections()/calculate_Impact_
// CurrentSection() calls (Sections()/Solids(), when something actually
// changed) confirmed directly, not assumed, to be headlessly safe here -
// the PImage.save()/createGraphics() calls deeper inside are gated
// behind record_IMG/record_PDF flags that default off.
class Edit3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= clamp / clampF =======================================

  @Test
  void clamp_leavesAnInRangeValueUntouched_butClampsBothEnds () {
    assertEquals(5, app.Edit3D.clamp(5, 0, 10));
    assertEquals(10, app.Edit3D.clamp(15, 0, 10));
    assertEquals(0, app.Edit3D.clamp(-5, 0, 10));
  }

  @Test
  void clampF_sameShapeAsClamp_forFloats () {
    assertEquals(0.5f, app.Edit3D.clampF(0.5f, 0f, 1f), 0.0001f);
    assertEquals(1f, app.Edit3D.clampF(2f, 0f, 1f), 0.0001f);
    assertEquals(0f, app.Edit3D.clampF(-2f, 0f, 1f), 0.0001f);
  }

  // ================= Faces() / adjustFaceProperties =======================

  @Test
  void faces_seedMaterial_adjustsByP_clampedToZeroToEight () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setMaterial(f, 7);
    app.Select3D.faceSelection = new int[]{ f };
    app.User3D.currentTool = app.UITASK.Seed_Material;

    app.Edit3D.Faces(1);
    assertEquals(8, app.allFaces.getMaterial(f));

    app.Edit3D.Faces(1); // one more step past the ceiling (8) - clamped, not wrapped
    assertEquals(8, app.allFaces.getMaterial(f));
  }

  @Test
  void faces_tessellation_adjustsWithinItsOwnZeroToFourRange () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setTessellation(f, 0);
    app.Select3D.faceSelection = new int[]{ f };
    app.User3D.currentTool = app.UITASK.Tessellation;

    app.Edit3D.Faces(-1); // below the floor (0) - clamped, not wrapped
    assertEquals(0, app.allFaces.getTessellation(f));
  }

  @Test
  void faces_weight_allowsNegativeValues_withinItsOwnMinusTwentyToTwentyRange () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setWeight(f, -20);
    app.Select3D.faceSelection = new int[]{ f };
    app.User3D.currentTool = app.UITASK.Weight;

    app.Edit3D.Faces(-5);
    assertEquals(-20, app.allFaces.getWeight(f), "clamped at the floor, not wrapped to a positive value");
  }

  @Test
  void faces_doesNothing_whenCurrentToolIsntOneOfTheFiveAdjustableProperties () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setMaterial(f, 5);
    app.Select3D.faceSelection = new int[]{ f };
    app.User3D.currentTool = app.UITASK.Move; // not one of the five

    app.Edit3D.Faces(3);

    assertEquals(5, app.allFaces.getMaterial(f));
  }

  // ================= Polylines() ==========================================

  @Test
  void polylines_sharesTheSameFivePropertyAdjustments_asFaces () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int line = app.allPolylines.create(new int[]{ p0, p1 });
    app.allPolylines.setLayer(line, 10);
    app.Select3D.polylineSelection = new int[]{ line };
    app.User3D.currentTool = app.UITASK.Layer;

    app.Edit3D.Polylines(10);

    assertEquals(16, app.allPolylines.getLayer(line), "clamped at its own ceiling of 16");
  }

  // ================= Groups() - applies to every face/polyline it owns ===

  @Test
  void groups_adjustsEveryFaceAndPolylineTheGroupOwns_notJustOne () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{ 0, -1 };
    app.allGroups.Polylines[0] = new int[]{ 0, -1 };

    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f0 = app.allFaces.create(new int[]{ p0, p1, p2 });
    int f1 = app.allFaces.create(new int[]{ p0, p2, p1 });
    int line0 = app.allPolylines.create(new int[]{ p0, p1 });

    app.allFaces.setMaterial(f0, 3);
    app.allFaces.setMaterial(f1, 3);
    app.allPolylines.setMaterial(line0, 3);

    app.Select3D.groupSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Seed_Material;

    app.Edit3D.Groups(2);

    assertEquals(5, app.allFaces.getMaterial(f0));
    assertEquals(5, app.allFaces.getMaterial(f1));
    assertEquals(5, app.allPolylines.getMaterial(line0));
  }

  // ================= Model1Ds() ===========================================

  @Test
  void model1Ds_degreeMax_wrapsRatherThanClamps_atBothEnds () {
    app.allModel1Ds.create(0, 0, 12, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0); // degreeMax == 12 (3rd param: type, seed, degreeMax, ...)
    app.Select3D.model1DSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.DegreeMax;

    app.Edit3D.Model1Ds(1); // one past 12 wraps to 0, not clamped at 12
    assertEquals(0, app.allModel1Ds.getDegreeMax(0));

    app.Edit3D.Model1Ds(-1); // one before 0 wraps to 12
    assertEquals(12, app.allModel1Ds.getDegreeMax(0));
  }

  @Test
  void model1Ds_branchRatio_adjustsBySmallSteps_clampedToItsOwnTenthToOneRange () {
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1.0f, 0, 0, 0); // branchRatio == 1.0 (create()'s own 11th param: type, seed, degreeMax, x, y, z, s, rot, tilt, twist, ratio, ...)
    app.Select3D.model1DSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.BranchRatio;

    app.Edit3D.Model1Ds(5); // 5 * 0.02 = 0.1 past the ceiling (1.0) - clamped, not overshot
    assertEquals(1.0f, app.allModel1Ds.getBranchRatio(0), 0.0001f);
  }

  @Test
  void model1Ds_trunkSize_hasAFloorAtZero_butNoCeiling () {
    app.allModel1Ds.create(0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0.01f, 0); // trunkSize == 0.01 (create()'s own 13th param)
    app.Select3D.model1DSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.TrunkSize;

    app.Edit3D.Model1Ds(-5); // well past zero
    assertEquals(0f, app.allModel1Ds.getTrunkSize(0), 0.0001f, "floored at 0, not a negative value");

    app.Edit3D.Model1Ds(1000); // confirms there's genuinely no ceiling, unlike BranchRatio above
    assertEquals(0f + 1000 * 0.02f, app.allModel1Ds.getTrunkSize(0), 0.0001f);
  }

  // ================= Model2Ds() ===========================================

  @Test
  void model2Ds_fileIndex_wrapsWithinItsOwnKindsFileCount_andTogglesMirrorOnWrap () {
    app.TREES_KIND.fileCount = 3;
    app.allModel2Ds.create("TREES", 2, 0, 0, 0, 1); // local file index 2, mirror false (m > 0)
    app.Select3D.model2DSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Seed_Material;

    app.Edit3D.Model2Ds(1); // 2 -> 3, still within fileCount (3) - no wrap
    assertEquals(3, app.allModel2Ds.FileIndex[0]);
    assertFalse(app.allModel2Ds.Mirror[0]);

    app.Edit3D.Model2Ds(1); // 3 -> 4, past fileCount (3) - wraps to 1, mirror flips
    assertEquals(1, app.allModel2Ds.FileIndex[0]);
    assertTrue(app.allModel2Ds.Mirror[0]);
  }

  // ================= Cameras() =============================================

  @Test
  void cameras_type_isClampedToZeroOrOne_andSyncsWIN3DWhenItsTheActiveCamera () {
    app.allCameras.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 0); // type == 0
    app.Select3D.cameraSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.WIN3D.currentCameraIndex = 0;

    app.Edit3D.Cameras(5); // well past the ceiling (1)

    assertEquals(1, app.allCameras.get_type(0));
    assertEquals(1, app.WIN3D.projectionTypeIndex, "WIN3D's own projection type follows along, since this IS the active camera");
  }

  @Test
  void cameras_doesNotTouchWIN3D_whenItIsNotTheActiveCamera () {
    app.allCameras.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 0);
    app.Select3D.cameraSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.WIN3D.currentCameraIndex = 5; // some other camera is active
    app.WIN3D.projectionTypeIndex = 99;

    app.Edit3D.Cameras(1);

    assertEquals(99, app.WIN3D.projectionTypeIndex, "untouched - the edited camera isn't the one currently active");
  }

  // ================= Sections() ===========================================

  @Test
  void sections_type_isClampedToZeroToThree () {
    app.allSections.create(0, 0, 0, 5, 1, 1, 0, 4, 4); // type == 0
    app.Select3D.sectionSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Seed_Material;

    app.Edit3D.Sections(10);

    assertEquals(3, app.allSections.get_type(0));
  }

  @Test
  void sections_tessellation_doublesOrHalvesResolution_clampedToOneHundredToSixteenHundred_onBothAxes () {
    app.allSections.create(0, 0, 0, 5, 1, 1, 1, 4, 4); // RES1 == RES2 == 4
    app.Select3D.sectionSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Tessellation;

    app.Edit3D.Sections(1); // 4 -> 8, well below the 100 floor - clamped UP to 100

    assertEquals(100, app.allSections.get_res1(0));
    assertEquals(100, app.allSections.get_res2(0), "both axes move together");
  }

  @Test
  void sections_tessellation_doublesNormally_onceAlreadyWithinRange () {
    app.allSections.create(0, 0, 0, 5, 1, 1, 1, 200, 200);
    app.Select3D.sectionSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Tessellation;

    app.Edit3D.Sections(1);
    assertEquals(400, app.allSections.get_res1(0));

    app.Edit3D.Sections(-1);
    assertEquals(200, app.allSections.get_res1(0));
  }

  // ================= Solids() ==============================================

  @Test
  void solids_powerX_doublesOrHalves_andWrapsAtCubePowerAndStarPower_ratherThanClamping () {
    app.allSolids.create(0, 0, 0, 12, 1, 1, 1, 1, 1, 0, 0, 0, 0); // powX == 12
    app.Select3D.solidSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.PowerX;

    app.Edit3D.Solids(1); // 12 -> 24, past CubePower (16) - wraps DOWN to StarPower (0.25), not clamped at 16
    assertEquals(0.25f, app.allSolids.get_powX(0), 0.0001f);

    app.allSolids.updatePowers(0, 0.3f, 1f, 1f);
    app.Edit3D.Solids(-1); // 0.3 -> 0.15, below StarPower (0.25) - wraps UP to CubePower (16)
    assertEquals(16f, app.allSolids.get_powX(0), 0.0001f);
  }

  @Test
  void solids_powerAll_setsAllThreeAxesTogether_ratherThanJustOne () {
    app.allSolids.create(0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0);
    app.Select3D.solidSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.PowerAll;

    app.Edit3D.Solids(1);

    assertEquals(4f, app.allSolids.get_powX(0), 0.0001f);
    assertEquals(4f, app.allSolids.get_powY(0), 0.0001f);
    assertEquals(4f, app.allSolids.get_powZ(0), 0.0001f);
  }

  @Test
  void solids_doesNothing_whenCurrentToolIsntAPowerTask () {
    app.allSolids.create(0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0);
    app.Select3D.solidSelection = new int[]{ 0 };
    app.User3D.currentTool = app.UITASK.Move;

    app.Edit3D.Solids(1);

    assertEquals(2f, app.allSolids.get_powX(0), 0.0001f);
  }

  // ================= selection() dispatcher ===============================

  @Test
  void selection_dispatchesToFaces_whenCategoryIsFace () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setMaterial(f, 2);
    app.Select3D.faceSelection = new int[]{ f };
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.Edit3D.selection(1);

    assertEquals(3, app.allFaces.getMaterial(f));
  }

  @Test
  void selection_dispatchesToPolylines_whenCategoryIsPolyline () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int line = app.allPolylines.create(new int[]{ p0, p1 });
    app.allPolylines.setMaterial(line, 2);
    app.Select3D.polylineSelection = new int[]{ line };
    app.User3D.currentTool = app.UITASK.Seed_Material;
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;

    app.Edit3D.selection(1);

    assertEquals(3, app.allPolylines.getMaterial(line));
  }

  @Test
  void selection_doesNothing_forACategoryWithNoEdit3DBranch () {
    // TERRAIN, VERTEX and SOFTVERTEX aren't in selection()'s own
    // if/else chain at all - confirmed directly, not assumed - so this
    // is a silent no-op, not an error.
    app.currentObjectCategory = app.ObjectCategory.VERTEX;

    assertDoesNotThrow(() -> app.Edit3D.selection(1));
  }
}
