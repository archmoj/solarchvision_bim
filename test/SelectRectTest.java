import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Select3D.selectRect() (select3D.pde) was fully untested - 1444 missed
// instructions - even in the merged (unit + image) coverage report.
// It's one long if-block per currentObjectCategory (TERRAIN, MODEL1D,
// GROUP, FACE, POLYLINE, VERTEX, MODEL2D, SOLID, SECTION, CAMERA), each
// walking that category's own objects, projecting their vertices via
// rectTest_vertex() (itself also previously untested, though the
// perspective math it calls - WIN3D.calculate_Perspective_Internally() -
// already is, fully, elsewhere), and toggling a selection.
//
// GROUP/FACE/POLYLINE/VERTEX are naturally safe on a bare app: each
// backing array (allGroups.num, allFaces.nodes/allPolylines.nodes.length,
// allPoints.getLength()) defaults to 0/empty via that class's own
// makeEmpty(0) constructor call, so those 4 loops simply don't iterate.
// SOLID/MODEL2D/SECTION/MODEL1D/CAMERA are different: each one's own
// Faces field is declared with no initializer (int[][] Faces;), so it's
// null until something else populates it - confirmed by reading each
// class's own field declaration, not assumed - so those 5 are given an
// explicit empty array first, below, rather than risking the same
// NullPointerException calculate_VertexSolar_array() hit earlier this
// session for an unrelated reason.
//
// TERRAIN is deliberately out of scope: it reads Terrain.Mesh directly,
// and the whole Terrain subsystem has its own, separate coverage gap
// (nearly every Terrain method is 0% even in the merged report) that's
// its own follow-up, not something to paper over here with more guessed
// field setup.
class SelectRectTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();

    // Same calculate_Click3D()-family setup HandleWin3DClickAtTest.java/
    // WIN3DTest.java already use - rectTest_vertex() goes through the
    // same WIN3D.calculate_Perspective_Internally() chain.
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

  // ================= naturally-safe categories, empty scene ==================

  @Test
  void groupCategory_onAnEmptyScene_doesNotThrow_selectionStaysEmpty () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.mouseButton = app.LEFT;

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));

    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void faceCategory_onAnEmptyScene_doesNotThrow_selectionStaysEmpty () {
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.mouseButton = app.LEFT;

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));

    assertEquals(0, app.Select3D.faceSelection.length);
  }

  @Test
  void polylineCategory_onAnEmptyScene_doesNotThrow_selectionStaysEmpty () {
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.mouseButton = app.LEFT;

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));

    assertEquals(0, app.Select3D.polylineSelection.length);
  }

  @Test
  void vertexCategory_onAnEmptyScene_doesNotThrow_selectionStaysEmpty () {
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.mouseButton = app.LEFT;

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));

    assertEquals(0, app.Select3D.vertexSelection.length);
  }

  // ================= categories needing an explicit empty Faces array ========

  @Test
  void solidCategory_withNoFaces_doesNotThrow () {
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.mouseButton = app.LEFT;
    app.allSolids.Faces = new int[0][];

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));
  }

  @Test
  void model2DCategory_withNoFaces_doesNotThrow () {
    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.mouseButton = app.LEFT;
    app.allModel2Ds.Faces = new int[0][];

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));
  }

  @Test
  void sectionCategory_withNoFaces_doesNotThrow () {
    app.currentObjectCategory = app.ObjectCategory.SECTION;
    app.mouseButton = app.LEFT;
    app.allSections.Faces = new int[0][];

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));
  }

  @Test
  void model1DCategory_withNoFaces_doesNotThrow () {
    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.mouseButton = app.LEFT;
    app.allModel1Ds.Faces = new int[0][];

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));
  }

  @Test
  void cameraCategory_withNoFaces_doesNotThrow () {
    app.currentObjectCategory = app.ObjectCategory.CAMERA;
    app.mouseButton = app.LEFT;
    app.allCameras.Faces = new int[0][];

    assertDoesNotThrow(() -> app.Select3D.selectRect(-10, -10, 10, 10));
  }

  // ================= FACE, with one real vertex: rectTest_vertex's own decision ====
  // A single point at world-space (0,0,0), with the camera set up above
  // (cameraZ=10, looking straight down -Z, no rotation) - calculate_Click3D-
  // family math projects this to image-space (0, 0), directly in front of
  // the camera (WIN3DTest.java's own calculateClick3D_atImageCenterWithNoRotation...
  // test derives the same point-at-image-center result for an analogous
  // setup).

  private void armOneVertexFace () {
    // allVertices (the vertex data allPoints.getX()/getY()/getZ() read)
    // is actually a top-level field (globalVariables.pde), not a member
    // of the Points class itself - Points' own methods reach it as an
    // implicit outer-class field, same as any other nested class here.
    app.allVertices = new float[][]{{0, 0, 0}};
    app.allFaces.nodes = new int[][]{{0}};
    app.currentObjectCategory = app.ObjectCategory.FACE;
  }

  @Test
  void leftClick_rectContainingTheProjectedPoint_selectsTheFace () {
    armOneVertexFace();
    app.mouseButton = app.LEFT;

    // (0,0) is strictly inside (-10,-10)-(10,10).
    app.Select3D.selectRect(-10, -10, 10, 10);

    assertArrayEquals(new int[]{0}, app.Select3D.faceSelection);
  }

  @Test
  void leftClick_rectNotContainingTheProjectedPoint_doesNotSelectTheFace () {
    armOneVertexFace();
    app.mouseButton = app.LEFT;

    // (0,0) is outside (5,5)-(10,10).
    app.Select3D.selectRect(5, 5, 10, 10);

    assertEquals(0, app.Select3D.faceSelection.length);
  }
}
