import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// handleWin3DClickAt() (mouseClicked.pde) is the core 3D-viewport click
// dispatcher - by far the largest remaining gap even in the merged
// (unit + image) coverage report: 1825 missed instructions, only 16
// covered. Even the real-scene image tests apparently never simulate an
// actual click into the 3D viewport.
//
// This file covers two of its branches:
//
// - The LookAtDirection tool, at the very top (its own standalone
//   if/else branch before the shared ray-casting below even runs).
//
// - The "PickSelect" path (every tool OTHER than Create/Move) across
//   every currentObjectCategory it dispatches on: GROUP/FACE (the
//   default, via allFaces.intersect()), POLYLINE, CAMERA, SECTION,
//   SOLID, MODEL1D, MODEL2D (each via its own matching Xxx.intersect()),
//   plus a right-click, which goes through Terrain.intersect() instead
//   regardless of currentObjectCategory. Every one of those intersect()
//   methods, and Select3D.selectPick() (which every PickSelect branch
//   ultimately calls with the result), is already substantially covered
//   directly elsewhere - confirmed by reading the merged report class by
//   class before writing this - so what's new here is specifically
//   handleWin3DClickAt()'s OWN dispatch logic: which intersect() method
//   it picks for a given tool/category/button combination, not whether
//   each intersect() itself works.
//
// Both paths route through computeClickRay()/WIN3D.calculate_Click3D(),
// which needs a handful of WIN3D fields set up first or it hits a
// division by zero - the exact setup WIN3DTest.java's own
// calculateClick3D_atImageCenterWithNoRotationTerrainsStraightAheadOfTheCamera
// test already establishes, reused here.
//
// CAMERA/SECTION/SOLID/MODEL1D/MODEL2D's own intersect() methods each
// read that class's own Faces field directly - declared with no
// initializer, so null rather than empty, on a bare app (a real failure
// from an earlier run of this file surfaced this, the same thing
// SelectRectTest.java's own header comment documents for selectRect()'s
// analogous per-category loops) - so each of those tests sets Faces to
// an empty array first. Terrain.intersect() has the same shape: its own
// cell count is driven by rowCount (20 by default, not 0), so its loop
// runs by default and reads a likewise-null Mesh; rowCount is set to 1
// there for the same reason.
//
// The Create/Move branches (object creation across every CREATE shape
// type, geometry snapping via snap_Faces(), computeCreateParams()) are a
// much larger, separate effort and are deliberately out of scope here.
class HandleWin3DClickAtTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment

    // Same calculate_Click3D() setup WIN3DTest.java's own test uses.
    app.WIN3D.projectionTypeIndex = 1; // perspective
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;
  }

  // ================= LookAtDirection =========================================

  @Test
  void lookAtDirectionTool_doesNotThrow () {
    app.User3D.currentTool = app.UITASK.LookAtDirection;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  // ================= PickSelect: left click, every object category ==========
  // User3D.currentTool is left at its bare-construction default
  // (zoom_Orbit_Pan) throughout this section - neither UITASK.Create nor
  // UITASK.Move, so every one of these reaches the shared PickSelect
  // branch (Select3D.selectPick(RxP)) rather than the Create/Move ones.

  @Test
  void pickSelect_leftClick_defaultGroupCategory_onAnEmptyScene_doesNotThrow () {
    app.mouseButton = app.LEFT;
    // currentObjectCategory left at its own bare-construction default
    // (GROUP) - the "else" branch, allFaces.intersect() via snap_Faces().

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(0, app.Select3D.faceSelection.length, "a miss on an empty scene must leave the selection empty");
    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void pickSelect_leftClick_polylineCategory_onAnEmptyScene_doesNotThrow () {
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(0, app.Select3D.polylineSelection.length);
  }

  // CAMERA/SECTION/SOLID/MODEL1D/MODEL2D each read their own class's
  // Faces field directly (Cameras.intersect()/Sections.intersect()/
  // etc.) - and, confirmed by a real run (not assumed), each one is
  // declared with no initializer, so it's null rather than empty until
  // something else populates it. SelectRectTest.java hit the exact same
  // thing for selectRect()'s own analogous per-category loops; same fix
  // here: an explicit empty array first.

  @Test
  void pickSelect_leftClick_cameraCategory_withNoFaces_doesNotThrow () {
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.CAMERA;
    app.allCameras.Faces = new int[0][];

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  @Test
  void pickSelect_leftClick_sectionCategory_withNoFaces_doesNotThrow () {
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.SECTION;
    app.allSections.Faces = new int[0][];

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  @Test
  void pickSelect_leftClick_solidCategory_withNoFaces_doesNotThrow () {
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.allSolids.Faces = new int[0][];

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  @Test
  void pickSelect_leftClick_model1DCategory_withNoFaces_doesNotThrow () {
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.allModel1Ds.Faces = new int[0][];

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  @Test
  void pickSelect_leftClick_model2DCategory_withNoFaces_doesNotThrow () {
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.allModel2Ds.Faces = new int[0][];

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }

  @Test
  void pickSelect_leftClick_faceCategory_onAnEmptyScene_doesNotThrow () {
    app.mouseButton = app.LEFT;
    app.currentObjectCategory = app.ObjectCategory.FACE;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(0, app.Select3D.faceSelection.length);
  }

  // ================= PickSelect: right click -> Terrain, any category ========
  // Right-click always goes through Terrain.intersect() instead,
  // regardless of currentObjectCategory - already fully covered
  // directly elsewhere, so this is purely about handleWin3DClickAt()'s
  // own "mouseButton == RIGHT" branch being reached.
  //
  // Terrain.intersect()'s own cell count is (rowCount-1)*(columnCount-1)
  // - rowCount defaults to 20, not 0 (land3D.pde), so its loop iterates
  // by default and immediately reads a null this.Mesh (also declared
  // with no initializer) - a real failure, not a guess. Setting rowCount
  // to 1 makes that cell count exactly 0, so the loop - and Mesh - are
  // never touched, the same "make the loop bound 0" fix used for every
  // *.Faces array above.

  @Test
  void pickSelect_rightClick_goesThroughTerrainIntersect_regardlessOfCategory () {
    app.mouseButton = app.RIGHT;
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.Terrain.rowCount = 1;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));
  }
}
