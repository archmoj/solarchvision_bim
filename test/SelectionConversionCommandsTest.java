import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// extraCommands.pde's 16 selection-type conversion commands - VERTEX>GROUP,
// FACE>GROUP, GROUP>FACE, POLYLINE>GROUP, GROUP>POLYLINE, POLYLINE>VERTEX,
// VERTEX>POLYLINE, GROUP>VERTEX, FACE>VERTEX, VERTEX>FACE, SOLID>GROUP,
// GROUP>SOLID, 2D>GROUP, GROUP>2D, 1D>GROUP, GROUP>1D - each a thin
// runScriptLine() dispatch straight to one of Select3D's own
// convert_X_to_Y() methods, followed by view_changed(). Every convert_*
// method is pure array logic over the various *Selection fields (plus
// allGroups/allFaces/allPolylines/... for context) - no drawing, and
// selection_changed() (called by every one of them) only sets two flags
// and zeroes 3 fields (reset_selectedRefValues()/revise_BoundingBox()),
// confirmed safe the same way MouseClickedTest.java's own selectNewlyCreated()
// already relies on. All 16 commands were at 0% coverage.
//
// Each Select3D *Selection field defaults to an empty int[0] on a bare
// app, so every conversion below starts from "nothing selected" and
// checks it lands on "nothing selected" of the target kind too (and that
// the command dispatches successfully, with a blank hint) - enough to
// exercise every line in each thin wrapper and its target convert_*
// method without needing to build up real geometry/groups first.
class SelectionConversionCommandsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
  }

  @Test
  void vertexToGroup_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("VERTEX>GROUP"));
    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void faceToGroup_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("FACE>GROUP"));
    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void groupToFace_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("GROUP>FACE"));
    assertEquals(0, app.Select3D.faceSelection.length);
  }

  @Test
  void polylineToGroup_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("POLYLINE>GROUP"));
    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void groupToPolyline_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("GROUP>POLYLINE"));
    assertEquals(0, app.Select3D.polylineSelection.length);
  }

  @Test
  void polylineToVertex_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("POLYLINE>VERTEX"));
    assertEquals(0, app.Select3D.vertexSelection.length);
  }

  @Test
  void vertexToPolyline_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("VERTEX>POLYLINE"));
    assertEquals(0, app.Select3D.polylineSelection.length);
  }

  @Test
  void groupToVertex_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("GROUP>VERTEX"));
    assertEquals(0, app.Select3D.vertexSelection.length);
  }

  @Test
  void faceToVertex_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("FACE>VERTEX"));
    assertEquals(0, app.Select3D.vertexSelection.length);
  }

  @Test
  void vertexToFace_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("VERTEX>FACE"));
    assertEquals(0, app.Select3D.faceSelection.length);
  }

  @Test
  void solidToGroup_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("SOLID>GROUP"));
    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void groupToSolid_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("GROUP>SOLID"));
    assertEquals(0, app.Select3D.solidSelection.length);
  }

  @Test
  void model2DToGroup_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("2D>GROUP"));
    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void groupToModel2D_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("GROUP>2D"));
    assertEquals(0, app.Select3D.model2DSelection.length);
  }

  @Test
  void model1DToGroup_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("1D>GROUP"));
    assertEquals(0, app.Select3D.groupSelection.length);
  }

  @Test
  void groupToModel1D_onAnEmptySelection_staysEmpty () {
    assertEquals("", app.runScriptLine("GROUP>1D"));
    assertEquals(0, app.Select3D.model1DSelection.length);
  }

  // ================= a non-trivial round trip, to prove it's not vacuous =====
  // The 16 tests above would also pass if a conversion command silently
  // did nothing at all - this one starts from an actual (fabricated)
  // selection and group membership, so VERTEX>GROUP has real work to do,
  // confirming the dispatch really does reach Select3D.convert_Vertices_
  // to_Groups() and not just fail to throw.

  @Test
  void vertexToGroup_withARealVertexInAGroupsFaces_findsThatGroup () {
    // A single triangular face, group 0 owning it (allGroups.Faces[0] = [0, 0]).
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allGroups.num = 1;
    app.allGroups.Faces = new int[][]{{0, 0}}; // group 0's range: face index 0 to 0 (inclusive), i.e. just that one face
    app.allPolylines.nodes = new int[0][];
    app.allGroups.Polylines = new int[][]{{0, 0}};

    app.Select3D.vertexSelection = new int[]{1}; // node 1 belongs to face 0

    assertEquals("", app.runScriptLine("VERTEX>GROUP"));

    assertArrayEquals(new int[]{0}, app.Select3D.groupSelection);
  }
}
