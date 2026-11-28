import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Properties/Modify Selected's own command-bar counterpart:
// registerReassignActions() (uiRollout.pde) registers one "Reassign
// <Field>" command per field drawPropertiesModifySelectedTab() exposes,
// via the new putSelectedIntValueAction()/putSelectedFloatValueAction()
// (actions.pde). Those two are the real thing under test here - a
// handful of representative fields (one shared-across-categories field,
// one single-category int field, one single-category float field with a
// per-entity side effect, one with an afterAllWrites hook, and Model2D's
// bespoke File Index) stand in for every other field registered the same
// way, rather than re-testing all 22 field-by-field - the generic
// machinery is what actually varies in behavior, not each field's own
// bounds.
//
// None of this touches this.Spinner()/rendering (unlike
// drawPropertiesModifySelectedTab() itself) - allActions.get(key).run(...)
// is the same real path runScriptLine() uses, same reasoning
// ActionsTest.java's own header comment gives for putValueAction.
class ReassignActionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>();
    app.UI_rollout.registerReassignActions();
  }

  private void run (String command, String... args) {
    String[] full = new String[args.length + 1];
    full[0] = command;
    System.arraycopy(args, 0, full, 1, args.length);
    app.allActions.get(command.toLowerCase().replace(' ', '_')).run(full);
  }

  // ================= registration ==========================================

  @Test
  void registersOneCommandPerField_underTheNormalizedKey () {
    assertTrue(app.allActions.containsKey("reassign_material"));
    assertTrue(app.allActions.containsKey("reassign_weight"));
    assertTrue(app.allActions.containsKey("reassign_degree_max"));
    assertTrue(app.allActions.containsKey("reassign_seed"));
    assertTrue(app.allActions.containsKey("reassign_file_index"));
    assertTrue(app.allActions.containsKey("reassign_zoom"));
    assertTrue(app.allActions.containsKey("reassign_power_x"));
    assertTrue(app.allActions.containsKey("reassign_resolution"));
  }

  // ================= single-category field (Camera Zoom) ==================

  @Test
  void reassignZoom_setsTheValue_onASingleSelectedCamera () {
    app.allCameras.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 1);
    app.Select3D.cameraSelection = new int[]{ 0 };

    run("Reassign Zoom", "45");

    assertEquals(45f, app.allCameras.get_zoom(0), 0.0001f);
  }

  @Test
  void reassignZoom_appliesTheSameValueToEveryCameraInTheSelection () {
    app.allCameras.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 1);
    app.allCameras.create(10, 20, 30, 40, 50, 60, 70, 80, 90, 1);
    app.Select3D.cameraSelection = new int[]{ 0, 1 };

    run("Reassign Zoom", "60");

    assertEquals(60f, app.allCameras.get_zoom(0), 0.0001f);
    assertEquals(60f, app.allCameras.get_zoom(1), 0.0001f);
  }

  @Test
  void reassignZoom_syncsWIN3D_onlyForTheActiveCamera () {
    app.allCameras.create(1, 2, 3, 4, 5, 6, 7, 8, 9, 1);
    app.allCameras.create(10, 20, 30, 40, 50, 60, 70, 80, 90, 1);
    app.Select3D.cameraSelection = new int[]{ 0, 1 };
    app.WIN3D.currentCameraIndex = 1;

    run("Reassign Zoom", "60");

    assertEquals(60f, app.WIN3D.zoom, 0.0001f, "WIN3D follows the active camera (index 1)");
  }

  // These four rely on the one default camera the app constructor
  // already creates (same "makeEmpty(n) unconditionally calls
  // add_first()" default CamerasTest.java's own header comment notes) -
  // reading its zoom before the command runs, rather than assuming a
  // fixed starting value, since any explicitly-created camera here would
  // land at index 1, not 0.

  @Test
  void reassignZoom_outOfRange_reportsErrorAndLeavesItUnchanged () {
    app.Select3D.cameraSelection = new int[]{ 0 };
    float before = app.allCameras.get_zoom(0);

    run("Reassign Zoom", "999");

    assertEquals(before, app.allCameras.get_zoom(0), 0.0001f);
  }

  @Test
  void reassignZoom_nonNumericValue_doesNotThrowOrChangeAnything () {
    app.Select3D.cameraSelection = new int[]{ 0 };
    float before = app.allCameras.get_zoom(0);

    assertDoesNotThrow(() -> run("Reassign Zoom", "not-a-number"));
    assertEquals(before, app.allCameras.get_zoom(0), 0.0001f);
  }

  @Test
  void reassignZoom_emptySelection_reportsErrorAndDoesNothing () {
    app.Select3D.cameraSelection = new int[0];
    float before = app.allCameras.get_zoom(0);

    assertDoesNotThrow(() -> run("Reassign Zoom", "45"));
    assertEquals(before, app.allCameras.get_zoom(0), 0.0001f);
  }

  @Test
  void reassignZoom_mixedCategorySelection_reportsErrorAndDoesNothing () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.Select3D.cameraSelection = new int[]{ 0 };
    app.Select3D.faceSelection = new int[]{ f };
    float before = app.allCameras.get_zoom(0);

    assertDoesNotThrow(() -> run("Reassign Zoom", "45"));
    assertEquals(before, app.allCameras.get_zoom(0), 0.0001f);
  }

  @Test
  void reassignZoom_doesNotApply_toACategoryWithNoZoomField () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setMaterial(f, 3);
    app.Select3D.faceSelection = new int[]{ f };

    assertDoesNotThrow(() -> run("Reassign Zoom", "45"));
    assertEquals(3, app.allFaces.getMaterial(f), "untouched - Zoom isn't a Face field");
  }

  // ================= shared-across-categories field (Material) ============

  @Test
  void reassignMaterial_appliesToAFaceSelection () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    int f = app.allFaces.create(new int[]{ p0, p1, p2 });
    app.Select3D.faceSelection = new int[]{ f };

    run("Reassign Material", "5");

    assertEquals(5, app.allFaces.getMaterial(f));
  }

  @Test
  void reassignMaterial_appliesToAPolylineSelection_theSameWay () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int line = app.allPolylines.create(new int[]{ p0, p1 });
    app.Select3D.polylineSelection = new int[]{ line };

    run("Reassign Material", "5");

    assertEquals(5, app.allPolylines.getMaterial(line));
  }

  // ================= single-category float field with afterAllWrites ======

  @Test
  void reassignPowerX_setsTheValue_andRefreshesSolidImpactsOnce () {
    app.allSolids.create(0, 0, 0, 2, 2, 2, 1, 1, 1, 0, 0, 0, 0);
    app.Select3D.solidSelection = new int[]{ 0 };

    run("Reassign Power X", "4");

    assertEquals(4f, app.allSolids.get_powX(0), 0.0001f);
  }

  // ================= Model2D File Index (bespoke: per-Kind dynamic bound) =

  @Test
  void reassignFileIndex_setsTheValue_whenWithinTheSharedKindsFileCount () {
    app.TREES_KIND.fileCount = 3;
    app.allModel2Ds.create("TREES", 1, 0, 0, 0, 1);
    app.Select3D.model2DSelection = new int[]{ 0 };

    run("Reassign File Index", "3");

    assertEquals(3, app.allModel2Ds.FileIndex[0]);
  }

  @Test
  void reassignFileIndex_outOfRange_reportsErrorAndLeavesItUnchanged () {
    app.TREES_KIND.fileCount = 3;
    app.allModel2Ds.create("TREES", 1, 0, 0, 0, 1);
    app.Select3D.model2DSelection = new int[]{ 0 };

    run("Reassign File Index", "99");

    assertEquals(1, app.allModel2Ds.FileIndex[0]);
  }

  // Model2DKind.Images (model2DKind.pde) is 1-indexed with [0]
  // deliberately left null, so 0 is not a valid FileIndex for an
  // already-placed entity - it used to be accepted (0..fileCount), which
  // let this write that null slot's index straight into FileIndex and
  // NPE the next time anything rendered that entity (model2Ds.pde's own
  // kind.Images[n] lookup).
  @Test
  void reassignFileIndex_zero_reportsErrorAndLeavesItUnchanged () {
    app.TREES_KIND.fileCount = 3;
    app.allModel2Ds.create("TREES", 1, 0, 0, 0, 1);
    app.Select3D.model2DSelection = new int[]{ 0 };

    run("Reassign File Index", "0");

    assertEquals(1, app.allModel2Ds.FileIndex[0]);
  }

  @Test
  void reassignFileIndex_mixedKindSelection_reportsErrorAndDoesNothing () {
    app.TREES_KIND.fileCount = 3;
    app.PEOPLE_KIND.fileCount = 3;
    app.allModel2Ds.create("TREES", 1, 0, 0, 0, 1);
    app.allModel2Ds.create("PEOPLE", 1, 0, 0, 0, 1);
    app.Select3D.model2DSelection = new int[]{ 0, 1 };

    assertDoesNotThrow(() -> run("Reassign File Index", "2"));
    assertEquals(1, app.allModel2Ds.FileIndex[0]);
    assertEquals(1, app.allModel2Ds.FileIndex[1]);
  }

  // ================= single-category int field, resX/resY mirrored + afterAllWrites ===

  @Test
  void reassignResolution_setsBothResXAndResY () {
    app.allSections.create(0, 0, 0, 5, 1, 1, 200, 200);
    app.Select3D.sectionSelection = new int[]{ 0 };

    run("Reassign Resolution", "400");

    assertEquals(400, app.allSections.get_resX(0));
    assertEquals(400, app.allSections.get_resY(0));
  }
}
