import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Completes handleWin3DClickAt()'s Create dispatch coverage -
// HandleWin3DClickAtCreateMoveTest.java only covered one representative
// combination (GROUP category, CreateObject.Cone). This covers every
// other CreateObject/currentObjectCategory pairing the function
// actually dispatches on:
//
//   GROUP:    SuperOBJ (whichever shape classifySuperOBJShape() picks
//             for the default creator-power settings), Pyramid, Plane,
//             Polygon, Hyper, Extrude, House1, House2, House3, Parametric
//   MODEL2D:  Person, Plant
//   MODEL1D:  Model1Ds
//   VERTEX:   Vertex
//   FACE:     Face
//   POLYLINE: Polyline, Arc
//   SOLID:    Solid
//   CAMERA:   Camera
//   SECTION:  Section
//
// Same smoke-test scope as that file: each individual creation command
// (House1/2/3, the Polygon family, Person/Tree1/Tree2, Solid, Camera,
// Section, ...) is already its own separately-tested surface elsewhere
// in this suite. What's new here is specifically that handleWin3DClickAt()
// reaches and correctly dispatches each of its own remaining branches -
// confirmed via a simple, reliable count-based signal per branch (the
// owning collection's own .num/.length growing by exactly 1), not by
// re-verifying the created geometry's own correctness.
//
// FACE/POLYLINE's own "add a vertex to the LAST face/polyline" commands
// (allFaces.add_VertexToLastFace()/allPolylines.add_VertexToLastPolyline())
// turned out to need an already-started (if still empty) face/polyline
// to append to - confirmed by reading their own "int n = this.nodes.
// length - 1;" line, which would index at -1 on a bare, truly empty
// array - so those two tests seed one empty "in progress" entry first,
// the same state the real UI would already be in by the time a second
// click like this one can happen (the first click is what starts it).
class HandleWin3DClickAtCreateDispatchTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment

    app.WIN3D.projectionTypeIndex = 1;
    app.WIN3D.scale = 1;
    app.WIN3D.cameraFieldOfView = (float) Math.toRadians(60);
    app.WIN3D.rotationX = 0;
    app.WIN3D.rotationZ = 0;
    app.WIN3D.cameraX = 0;
    app.WIN3D.cameraY = 0;
    app.WIN3D.cameraZ = 10;
    app.overallScale = 1;

    armOneTriangleFace();
    app.User3D.currentTool = app.UITASK.Create;
    app.mouseButton = app.LEFT;
    app.addToLastGroup = false;
  }

  // Same triangle as HandleWin3DClickAtCreateMoveTest.java's own
  // armOneTriangleFace() - hit at (0,0,0) by this exact camera setup.
  private void armOneTriangleFace () {
    app.allVertices = new float[][]{{-5, -5, 0}, {5, -5, 0}, {0, 5, 0}};
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{1, 0, 0, 1, 0, 0}};
  }

  // ================= GROUP ====================================================

  @Test
  void create_group_superOBJ_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.SuperOBJ;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_pyramid_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.Pyramid;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_plane_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.Plane;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_polygon_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.Polygon;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_hyper_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.Hyper;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_extrude_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.Extrude;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_house1_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.House1;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_house2_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.House2;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_house3_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.House3;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  @Test
  void create_group_parametric_doesNotThrow_andBeginsANewGroup () {
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.CreateObject = app.CREATE.Parametric;
    int groupsBefore = app.allGroups.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(groupsBefore + 1, app.allGroups.num);
  }

  // ================= MODEL2D ===================================================
  // No "BeginNewGroup" here - MODEL2D is its own top-level branch, a
  // sibling of GROUP, not nested inside it.

  @Test
  void create_model2D_person_doesNotThrow_andAddsAModel2D () {
    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.CreateObject = app.CREATE.Person;
    int before = app.allModel2Ds.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(before + 1, app.allModel2Ds.num);
  }

  @Test
  void create_model2D_plant_doesNotThrow_andAddsAModel2D () {
    app.currentObjectCategory = app.ObjectCategory.MODEL2D;
    app.CreateObject = app.CREATE.Plant;
    int before = app.allModel2Ds.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(before + 1, app.allModel2Ds.num);
  }

  // ================= MODEL1D ===================================================

  @Test
  void create_model1D_model1Ds_doesNotThrow_andAddsAModel1D () {
    app.currentObjectCategory = app.ObjectCategory.MODEL1D;
    app.CreateObject = app.CREATE.Model1Ds;
    int before = app.allModel1Ds.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(before + 1, app.allModel1Ds.num);
  }

  // ================= VERTEX ====================================================
  // allPoints.create() directly - no runScriptLine(), no "last object"
  // requirement.

  @Test
  void create_vertex_addsARealPoint () {
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.CreateObject = app.CREATE.Vertex;
    int before = app.allVertices.length;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(before + 1, app.allVertices.length);
  }

  // ================= FACE ======================================================

  @Test
  void create_face_addsAVertexToTheInProgressFace () {
    app.currentObjectCategory = app.ObjectCategory.FACE;
    app.CreateObject = app.CREATE.Face;
    // An empty, already-started face at the end - the real precondition
    // for add_VertexToLastFace() to have anything to append to.
    app.allFaces.nodes = new int[][]{{0, 1, 2}, {}};
    app.allFaces.options = new int[][]{{1, 0, 0, 1, 0, 0}, {1, 0, 0, 1, 0, 0}};
    int lastFaceVertexCountBefore = app.allFaces.nodes[app.allFaces.nodes.length - 1].length;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(lastFaceVertexCountBefore + 1, app.allFaces.nodes[app.allFaces.nodes.length - 1].length);
  }

  // ================= POLYLINE ==================================================

  @Test
  void create_polyline_polyline_addsAVertexToTheInProgressPolyline () {
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.CreateObject = app.CREATE.Polyline;
    app.allPolylines.nodes = new int[][]{{}};
    app.allPolylines.options = new int[][]{{1, 0, 0, 1, 0, 0, 0, 0}};
    int lastPolylineVertexCountBefore = app.allPolylines.nodes[app.allPolylines.nodes.length - 1].length;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(lastPolylineVertexCountBefore + 1, app.allPolylines.nodes[app.allPolylines.nodes.length - 1].length);
  }

  @Test
  void create_polyline_arc_doesNotThrow_andAddsARealPolyline () {
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.CreateObject = app.CREATE.Arc;
    int polylinesBefore = app.allPolylines.nodes.length;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertTrue(app.allPolylines.nodes.length > polylinesBefore, "a whole new polyline (the arc) must have been created, not just a vertex appended");
  }

  // ================= SOLID =====================================================

  @Test
  void create_solid_doesNotThrow_andAddsASolid () {
    app.currentObjectCategory = app.ObjectCategory.SOLID;
    app.CreateObject = app.CREATE.Solid;
    int before = app.allSolids.DEF.length;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(before + 1, app.allSolids.DEF.length);
  }

  // ================= CAMERA ====================================================

  @Test
  void create_camera_doesNotThrow_andAddsACamera () {
    app.currentObjectCategory = app.ObjectCategory.CAMERA;
    app.CreateObject = app.CREATE.Camera;
    int before = app.allCameras.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(before + 1, app.allCameras.num);
  }

  // ================= SECTION ===================================================
  // computeSectionParams()'s own "createNew" check depends on the hit
  // face (our triangle, f=0) having more than 2 nodes - true here (3).

  @Test
  void create_section_doesNotThrow_andAddsASection () {
    app.currentObjectCategory = app.ObjectCategory.SECTION;
    app.CreateObject = app.CREATE.Section;
    int before = app.allSections.num;

    assertDoesNotThrow(() -> app.handleWin3DClickAt(0, 0));

    assertEquals(before + 1, app.allSections.num);
  }
}
