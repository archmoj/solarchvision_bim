import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// uiSetTo.pde's own UI_setTo_Modify_*()/UI_setTo_View_*() family -
// UiSetToCreateTest.java's own header comment set these aside as "a much
// bigger, separate testing effort" on the (mistaken) assumption they
// take raw mouse-delta arguments and drive real camera math directly.
// Reading them more closely: almost every one is the same kind of pure
// tool-mode switch UI_setTo_Create_*() already covers for the Create
// family - User3D.currentTool plus a small handful of int fields
// (toolParameterModifier, targetAxisIndex, Select3D.*VectorIndex), each
// n a mode/sub-option index, not a delta. The actual per-frame camera
// dragging math lives in mouseDragged.pde, reached only once one of
// these tools is already active - out of scope here, same as it was for
// the Create family's own allFaces/allPolylines creation logic.
//
// A few DO reach real camera/view code (LookAtSelection, LookAtOrigin,
// 3DViewPoint) - each confirmed directly against the real compiled app
// to be headlessly safe (no WIN3D.graphics dependency) before writing
// assertions, the same way WIN3DTest.java's own handleCommandKey() tests
// already confirm for look_3DViewport_towards_Selection() specifically.
// UI_setTo_Viewport(n) is the one function in this file NOT covered
// here: it calls update_frame_layout(), which hits the same
// createGraphics() NullPointerException documented throughout this
// suite (LoadProjectTest.java's own header comment, among others).
class UiSetToModifyAndViewTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= Modify_* : Select3D.*VectorIndex family ==============

  @Test
  void modifyMove_setsToolAndPositionVectorIndex () {
    app.UI_setTo_Modify_Move(2);

    assertEquals(app.UITASK.Move, app.User3D.currentTool);
    assertEquals(2, app.Select3D.positionVectorIndex);
  }

  @Test
  void modifyScale_setsToolAndScaleVectorIndex () {
    app.UI_setTo_Modify_Scale(1);

    assertEquals(app.UITASK.Scale, app.User3D.currentTool);
    assertEquals(1, app.Select3D.scaleVectorIndex);
  }

  @Test
  void modifyRotate_setsToolAndRotationVectorIndex () {
    app.UI_setTo_Modify_Rotate(3);

    assertEquals(app.UITASK.Rotate, app.User3D.currentTool);
    assertEquals(3, app.Select3D.rotationVectorIndex);
  }

  // ================= Modify_* : toolParameterModifier family ==============
  // Seed/Tessellation/Layer/Visibility/Weight/DegreeMax/BranchTilt/
  // BranchTwist/BranchRatio/TreeBase/TrunkSize/LeafSize/Model1DsProps/
  // Pivot all share this exact same shape - one representative pair
  // below, not all fourteen individually.

  @Test
  void modifySeed_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_Seed(2); // 2: assign to

    assertEquals(app.UITASK.Seed_Material, app.User3D.currentTool);
    assertEquals(2, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyWeight_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_Weight(1); // 1: pick from

    assertEquals(app.UITASK.Weight, app.User3D.currentTool);
    assertEquals(1, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyPivot_setsToolAndParameterModifier () {
    app.UI_setTo_Modify_Pivot(0); // 0: change selection

    assertEquals(app.UITASK.Pivot, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyNormal_usesItsOwnDistinctModifierMeaning_flipOutIn () {
    app.UI_setTo_Modify_Normal(1); // 1: flip
    assertEquals(1, app.User3D.toolParameterModifier);

    app.UI_setTo_Modify_Normal(3); // 3: set in from pivot
    assertEquals(app.UITASK.Normal, app.User3D.currentTool);
    assertEquals(3, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyDrop_usesItsOwnDistinctModifierMeaning_landOrModelSurface () {
    app.UI_setTo_Modify_Drop(2); // 2: ModelSurface+

    assertEquals(app.UITASK.Drop, app.User3D.currentTool);
    assertEquals(2, app.User3D.toolParameterModifier);
  }

  @Test
  void modifyGetLength_usesItsOwnDistinctModifierMeaning_axisOrAngle () {
    app.UI_setTo_Modify_GetLength(5); // 5: angle on XY plane

    assertEquals(app.UITASK.GetLength, app.User3D.currentTool);
    assertEquals(5, app.User3D.toolParameterModifier);
  }

  // ================= Modify_Power: the one with real branching ============

  @Test
  void modifyPower_eachIndex_picksADifferentCurrentTool () {
    app.UI_setTo_Modify_Power(0);
    assertEquals(app.UITASK.PowerX, app.User3D.currentTool);

    app.UI_setTo_Modify_Power(1);
    assertEquals(app.UITASK.PowerY, app.User3D.currentTool);

    app.UI_setTo_Modify_Power(2);
    assertEquals(app.UITASK.PowerZ, app.User3D.currentTool);

    app.UI_setTo_Modify_Power(3);
    assertEquals(app.UITASK.PowerAll, app.User3D.currentTool);

    assertEquals(0, app.User3D.toolParameterModifier, "always reset to 0 (\"change\"), regardless of which axis");
  }

  // ================= View_*: simple field + view_changed() ================

  @Test
  void viewProjectionType_setsWIN3DsOwnField () {
    app.UI_setTo_View_ProjectionType(1);

    assertEquals(1, app.WIN3D.projectionTypeIndex);
  }

  @Test
  void viewPivotXYZ_setSelect3DsOwnAlignmentFields () {
    app.UI_setTo_View_PivotX(1);
    app.UI_setTo_View_PivotY(2);
    app.UI_setTo_View_PivotZ(0);

    assertEquals(1, app.Select3D.pivotAlignmentX);
    assertEquals(2, app.Select3D.pivotAlignmentY);
    assertEquals(0, app.Select3D.pivotAlignmentZ);
  }

  // ================= View_PickSelect / View_WindowSelect ==================
  // Both share the exact same addNewSelectionToPreviousSelection
  // encoding (0/1/2 -> 0/1/-1) - PickSelect covered fully, WindowSelect
  // just for its own, different currentTool.

  @Test
  void viewPickSelect_encodesNIntoAddNewSelectionToPreviousSelection () {
    app.UI_setTo_View_PickSelect(0);
    assertEquals(0, app.addNewSelectionToPreviousSelection);

    app.UI_setTo_View_PickSelect(1);
    assertEquals(1, app.addNewSelectionToPreviousSelection);

    app.UI_setTo_View_PickSelect(2);
    assertEquals(app.UITASK.PickSelect, app.User3D.currentTool);
    assertEquals(-1, app.addNewSelectionToPreviousSelection);
  }

  @Test
  void viewWindowSelect_setsItsOwnCurrentTool_withTheSameEncoding () {
    app.UI_setTo_View_WindowSelect(1);

    assertEquals(app.UITASK.RectSelect, app.User3D.currentTool);
    assertEquals(1, app.addNewSelectionToPreviousSelection);
  }

  // ================= Truck / CameraRoll / TargetRoll / Orbit ===============
  // All four share the same n==0/1/2 shape (plain tool, then
  // toolParameterModifier + targetAxisIndex for 1 and 2) - Truck and
  // Orbit covered fully (since Orbit reuses Truck's own UITASK.Truck_
  // Orbit with a different toolParameterModifier), CameraRoll/TargetRoll
  // each just for their own n==0 case.

  @Test
  void viewTruck_n0_isThePlainZoomOrbitPanTool () {
    app.UI_setTo_View_Truck(0);

    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
  }

  @Test
  void viewTruck_n1And2_pickDifferentTargetAxes_withTheSameToolAndModifier () {
    app.UI_setTo_View_Truck(1);
    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(0, app.User3D.targetAxisIndex);

    app.UI_setTo_View_Truck(2);
    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool);
    assertEquals(0, app.User3D.toolParameterModifier);
    assertEquals(1, app.User3D.targetAxisIndex);
  }

  @Test
  void viewOrbit_sharesTruckOrbitsOwnCurrentTool_butWithADifferentModifier () {
    app.UI_setTo_View_Orbit(1);

    assertEquals(app.UITASK.Truck_Orbit, app.User3D.currentTool, "same UITASK as Truck(1)");
    assertEquals(1, app.User3D.toolParameterModifier, "but modifier 1, not Truck's own 0 - this is what actually distinguishes orbiting from trucking");
    assertEquals(0, app.User3D.targetAxisIndex);
  }

  @Test
  void viewCameraRoll_n0_isThePlainPanTool () {
    app.UI_setTo_View_CameraRoll(0);

    assertEquals(app.UITASK.CameraRoll_Pan, app.User3D.currentTool);
  }

  @Test
  void viewTargetRoll_n0_isThePlainPanTool () {
    app.UI_setTo_View_TargetRoll(0);

    assertEquals(app.UITASK.TargetRoll_Pan, app.User3D.currentTool);
  }

  // ================= DistMouseXY / CameraDistance / TerrainOrbit ==========

  @Test
  void viewDistMouseXY_n0_setsItsOwnTool () {
    app.UI_setTo_View_DistMouseXY(0);

    assertEquals(app.UITASK.DistMouseXY_TargetRollXY_TargetRollZ, app.User3D.currentTool);
  }

  @Test
  void viewCameraDistance_n0_setsItsOwnTool () {
    app.UI_setTo_View_CameraDistance(0);

    assertEquals(app.UITASK.CameraDistance_TargetRollXY_TargetRollZ, app.User3D.currentTool);
  }

  @Test
  void viewTerrainOrbit_alwaysSetsItsOwnTool_regardlessOfN () {
    // No n-based branching at all here, unlike its Truck/Orbit neighbors
    // above - confirmed directly, not assumed.
    app.UI_setTo_View_TerrainOrbit(7);

    assertEquals(app.UITASK.TerrainOrbit_Pan_TargetRollZ, app.User3D.currentTool);
  }

  // ================= Pan / ZOOM ===========================================

  @Test
  void viewPan_eachIndex_picksADifferentCurrentTool () {
    app.UI_setTo_View_Pan(0);
    assertEquals(app.UITASK.Pan_TargetRoll, app.User3D.currentTool);

    app.UI_setTo_View_Pan(1);
    assertEquals(app.UITASK.PanX_TargetRoll, app.User3D.currentTool);

    app.UI_setTo_View_Pan(2);
    assertEquals(app.UITASK.PanY_TargetRoll, app.User3D.currentTool);
  }

  @Test
  void viewZoom_n0_setsTheToolButLeavesTheActualZoomAlone () {
    app.WIN3D.zoom = 90;

    app.UI_setTo_View_ZOOM(0);

    assertEquals(app.UITASK.Pan_Height, app.User3D.currentTool);
    assertEquals(90f, app.WIN3D.zoom, 0.0001f, "n==0 only sets the tool - the zoom value itself is untouched");
  }

  @Test
  void viewZoom_n1_alsoResetsZoomToASixtyDegreeDefault () {
    app.WIN3D.zoom = 90;

    app.UI_setTo_View_ZOOM(1);

    assertEquals(60f, app.WIN3D.zoom, 0.0001f);
  }

  // ================= 3DModelSize / SkydomeSize / AllModelSize =============

  @Test
  void viewModelSkydomeAllSizes_eachSetTheirOwnDistinctTool () {
    app.UI_setTo_View_3DModelSize();
    assertEquals(app.UITASK.ModelSize_Pan_TargetRoll, app.User3D.currentTool);

    app.UI_setTo_View_SkydomeSize();
    assertEquals(app.UITASK.SkydomeSize, app.User3D.currentTool);

    app.UI_setTo_View_AllModelSize();
    assertEquals(app.UITASK.AllModelSize, app.User3D.currentTool);
  }

  // ================= LookAtDirection / LookAtOrigin / LookAtSelection =====

  @Test
  void viewLookAtDirection_justSetsItsOwnTool () {
    app.UI_setTo_View_LookAtDirection(0);

    assertEquals(app.UITASK.LookAtDirection, app.User3D.currentTool);
  }

  @Test
  void viewLookAtOrigin_zeroesWIN3DsOwnPosition_andAlsoSelectsTheTruckTool () {
    app.WIN3D.positionX = 99;
    app.WIN3D.positionY = 99;
    app.WIN3D.positionZ = 99;

    app.UI_setTo_View_LookAtOrigin(0);

    assertEquals(0f, app.WIN3D.positionX, 0.0001f);
    assertEquals(0f, app.WIN3D.positionY, 0.0001f);
    assertEquals(0f, app.WIN3D.positionZ, 0.0001f);
    // Its own "automatically set another choice of interest" block -
    // chains into UI_setTo_View_Truck(0), confirmed directly rather than
    // only inferred from reading the source.
    assertEquals(app.UITASK.zoom_Orbit_Pan, app.User3D.currentTool);
  }

  @Test
  void viewLookAtSelection_rotatesTheCameraTowardsThePivot_andAlsoSelectsCameraDistance () {
    // Select3D.getPivot() falls back to the origin when nothing is
    // selected (confirmed, same as WIN3DTest.java's own handleCommandKey_
    // starAndSlash_... test relies on for a different command) - a real
    // selection isn't required for this to run safely, just for the
    // resulting rotation to be meaningfully non-zero.
    app.allVertices = new float[][]{{5, 5, 5}};
    app.Select3D.vertexSelection = new int[]{0};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.overallScale = 1;
    float rotationZBefore = app.WIN3D.rotationZ;

    app.UI_setTo_View_LookAtSelection(0);

    assertNotEquals(rotationZBefore, app.WIN3D.rotationZ, 0.0001f);
    // Its own "automatically set another choice of interest" block -
    // chains into UI_setTo_View_CameraDistance(0).
    assertEquals(app.UITASK.CameraDistance_TargetRollXY_TargetRollZ, app.User3D.currentTool);
  }

  // ================= 3DViewPoint: preset camera angles ====================
  // Each of the 10 presets computes its own rotateZ/rotateXY delta as
  // "target angle minus WIN3D's own CURRENT angle" - which always lands
  // on that exact absolute target, regardless of where the camera
  // started. Confirmed directly against the real compiled app for every
  // n from 0 to 9 before writing these assertions; representative cases
  // below, not all ten.

  private void setUpOneCamera () {
    // apply_currentCameraIndex() (called unconditionally by
    // UI_setTo_View_3DViewPoint) reads allCameras' own index 0, which
    // doesn't exist on a bare instance (num == 0) - CamerasTest.java's
    // own create_appendsAndIncrementsNum() test uses this exact same
    // call shape to seed one.
    app.allCameras.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 1);
    app.overallScale = 1;
  }

  @Test
  void viewPoint_n0_alwaysLandsOnZeroZero_regardlessOfTheStartingAngle () {
    setUpOneCamera();
    app.WIN3D.rotationX = 123.4f; // arbitrary starting point
    app.WIN3D.rotationZ = -45.6f;

    app.UI_setTo_View_3DViewPoint(0);

    assertEquals(0f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void viewPoint_n1_alwaysLandsOnNinetyZero () {
    setUpOneCamera();
    app.WIN3D.rotationX = -17f;
    app.WIN3D.rotationZ = 200f;

    app.UI_setTo_View_3DViewPoint(1);

    assertEquals(90f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void viewPoint_n5_alwaysLandsOnOneEightyZero_theOnlyPresetThatIsntNinety () {
    setUpOneCamera();
    app.WIN3D.rotationX = 10f;
    app.WIN3D.rotationZ = 10f;

    app.UI_setTo_View_3DViewPoint(5);

    assertEquals(180f, app.WIN3D.rotationX, 0.0001f);
    assertEquals(0f, app.WIN3D.rotationZ, 0.0001f);
  }

  @Test
  void viewPoint_everyDiagonalPreset_sharesTheSameNinetyDegreeRotationX_butADifferentRotationZ () {
    setUpOneCamera();

    int[] diagonalPresets = { 2, 3, 4, 6, 7, 8, 9 };
    float[] expectedRotationZ = { -90f, 180f, 90f, -45f, 45f, 135f, -135f };

    for (int idx = 0; idx < diagonalPresets.length; idx++) {
      app.WIN3D.rotationX = 1000f; // a deliberately absurd starting point
      app.WIN3D.rotationZ = -1000f;

      app.UI_setTo_View_3DViewPoint(diagonalPresets[idx]);

      assertEquals(90f, app.WIN3D.rotationX, 0.0001f, "preset " + diagonalPresets[idx]);
      assertEquals(expectedRotationZ[idx], app.WIN3D.rotationZ, 0.0001f, "preset " + diagonalPresets[idx]);
    }
  }
}
