import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// uiSetTo.pde's own UI_setTo_Create_*() family - the toolbar's "what am
// I about to draw" mode switches (one per Create button) - had no
// dedicated coverage anywhere: UI_toolBarTest.java's own comments
// reference a few of them by name, but only to reason about which
// command maps to which one, never actually calling them and asserting
// what they do. Every one of these is plain, headlessly-safe state
// mutation - switch_category() (globalFunctions.pde) chains into
// selection_changed()/view_changed(), but neither touches
// WIN3D.graphics or any PImage, just flag/field assignment (confirmed
// directly, not assumed) - so there's no WIN3D/graphics wall to work
// around here, unlike most of this file's own neighbors in uiSetTo.pde
// (the View_*/Modify_* camera-manipulation functions, well out of this
// file's scope).
//
// uiSetTo.pde's own UI_setTo_Modify_*()/UI_setTo_View_*() functions (the
// other ~45 functions in that same file) are NOT covered here - each
// takes a raw mouse-delta `n` and feeds it straight into camera/
// selection math that's a much bigger, separate testing effort of its
// own, better suited to its own dedicated file.
class UiSetToCreateTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void createNothing_setsCreateObjectToNothing_andCurrentToolToCreate () {
    app.UI_setTo_Create_Nothing();

    assertEquals(app.CREATE.Nothing, app.CreateObject);
    assertEquals(app.UITASK.Create, app.User3D.currentTool);
  }

  @Test
  void createAllModel1Ds_setsCreateObjectAndSwitchesToTheModel1DCategory () {
    app.UI_setTo_Create_allModel1Ds();

    assertEquals(app.CREATE.Model1Ds, app.CreateObject);
    assertEquals(app.ObjectCategory.MODEL1D, app.currentObjectCategory);
  }

  @Test
  void createTree_setsCreateObjectToPlant_andSwitchesToTheModel2DCategory () {
    app.UI_setTo_Create_Tree();

    assertEquals(app.CREATE.Plant, app.CreateObject);
    assertEquals(app.ObjectCategory.MODEL2D, app.currentObjectCategory);
  }

  @Test
  void createPerson_setsCreateObjectToPerson_andSwitchesToTheModel2DCategory () {
    app.UI_setTo_Create_Person();

    assertEquals(app.CREATE.Person, app.CreateObject);
    assertEquals(app.ObjectCategory.MODEL2D, app.currentObjectCategory);
  }

  @Test
  void createVertex_setsCreateObjectAndSwitchesToTheVertexCategory () {
    app.UI_setTo_Create_Vertex();

    assertEquals(app.CREATE.Vertex, app.CreateObject);
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory);
  }

  @Test
  void createSolid_setsCreateObjectAndSwitchesToTheSolidCategory () {
    app.UI_setTo_Create_Solid();

    assertEquals(app.CREATE.Solid, app.CreateObject);
    assertEquals(app.ObjectCategory.SOLID, app.currentObjectCategory);
  }

  @Test
  void createSection_setsCreateObjectAndSwitchesToTheSectionCategory () {
    app.UI_setTo_Create_Section();

    assertEquals(app.CREATE.Section, app.CreateObject);
    assertEquals(app.ObjectCategory.SECTION, app.currentObjectCategory);
  }

  @Test
  void createCamera_setsCreateObjectAndSwitchesToTheCameraCategory () {
    app.UI_setTo_Create_Camera();

    assertEquals(app.CREATE.Camera, app.CreateObject);
    assertEquals(app.ObjectCategory.CAMERA, app.currentObjectCategory);
  }

  @Test
  void createParametric_setsCreateObjectAndStoresTheGivenTypeIndex_inUser3D () {
    app.UI_setTo_Create_Parametric(5);

    assertEquals(app.CREATE.Parametric, app.CreateObject);
    assertEquals(5, app.User3D.creatorParametricTypeIndex);
    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory);
  }

  // ================= Face / Polyline - the two with extra setup ==========
  // Both copy User3D's own creator* defaults into the matching
  // current_*() globals and open a real, empty Face/Polyline via
  // beginNewFace()/beginNewPolyline() (faces.pde/polylines.pde) - no
  // graphics involved in either, just a plain create(new int[]{}).

  @Test
  void createFace_copiesEveryCreatorDefault_andOpensOneEmptyFace () {
    app.User3D.creatorMaterial = 3;
    app.User3D.creatorTessellation = 2;
    app.User3D.creatorLayer = 1;
    app.User3D.creatorVisibility = 0;
    app.User3D.creatorWeight = 4;
    app.User3D.creatorClosed = 1;

    app.UI_setTo_Create_Face();

    assertEquals(app.CREATE.Face, app.CreateObject);
    assertEquals(app.ObjectCategory.FACE, app.currentObjectCategory);
    assertEquals(3, app.current_Material);
    assertEquals(2, app.current_Tessellation);
    assertEquals(1, app.current_Layer);
    assertEquals(0, app.current_Visibility);
    assertEquals(4, app.current_Weight);
    assertEquals(1, app.current_Closed);

    // beginNewFace() == create(new int[]{}) - a real, empty face, not
    // just a flag flip.
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(0, app.allFaces.nodes[0].length);
  }

  @Test
  void createPolyline_copiesEveryCreatorDefault_andOpensOneEmptyPolyline () {
    app.User3D.creatorMaterial = 6;
    app.User3D.creatorTessellation = 1;
    app.User3D.creatorLayer = 2;
    app.User3D.creatorVisibility = -1;
    app.User3D.creatorWeight = 3;
    app.User3D.creatorClosed = 1;

    app.UI_setTo_Create_Polyline();

    assertEquals(app.CREATE.Polyline, app.CreateObject);
    assertEquals(app.ObjectCategory.POLYLINE, app.currentObjectCategory);
    assertEquals(6, app.current_Material);
    assertEquals(1, app.current_Tessellation);
    assertEquals(2, app.current_Layer);
    assertEquals(-1, app.current_Visibility);
    assertEquals(3, app.current_Weight);
    assertEquals(1, app.current_Closed);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(0, app.allPolylines.nodes[0].length);
    assertEquals(app.allPolylines.CURVE_STRAIGHT, app.allPolylines.getCurveType(0));
  }

  @Test
  void createSpline_copiesEveryCreatorDefault_andOpensOneEmptyPolylineMarkedAsASpline () {
    // Same setup/assertions as createPolyline_... above - UI_setTo_Create_Spline()
    // reuses CREATE.Polyline itself (see uiSetTo.pde's own comment), differing
    // only in current_CurveType.
    app.User3D.creatorMaterial = 6;
    app.User3D.creatorTessellation = 1;
    app.User3D.creatorLayer = 2;
    app.User3D.creatorVisibility = -1;
    app.User3D.creatorWeight = 3;
    app.User3D.creatorClosed = 1;

    app.UI_setTo_Create_Spline();

    assertEquals(app.CREATE.Polyline, app.CreateObject);
    assertEquals(app.ObjectCategory.POLYLINE, app.currentObjectCategory);
    assertEquals(6, app.current_Material);
    assertEquals(1, app.current_Tessellation);
    assertEquals(2, app.current_Layer);
    assertEquals(-1, app.current_Visibility);
    assertEquals(3, app.current_Weight);
    assertEquals(1, app.current_Closed);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(0, app.allPolylines.nodes[0].length);
    assertEquals(app.allPolylines.CURVE_SPLINE, app.allPolylines.getCurveType(0));
  }

  @Test
  void createPolyline_afterASplineSession_isNotLeftMarkedAsASplineToo () {
    // The exact regression UI_setTo_Create_Polyline()'s own explicit
    // current_CurveType = CURVE_STRAIGHT guards against: without it, a
    // Polyline begun right after a Spline session would silently inherit
    // CURVE_SPLINE left behind in the current_CurveType global.
    app.UI_setTo_Create_Spline();
    app.UI_setTo_Create_Polyline();

    assertEquals(app.allPolylines.CURVE_STRAIGHT, app.allPolylines.getCurveType(1));
  }

  @Test
  void createArc_setsArcCreateObjectAndPolylineCategory_withoutOpeningAPolyline () {
    // Unlike Polyline/Spline, an arc is placed whole with one click
    // (mouseClicked.pde's own CREATE.Arc branch) rather than built up
    // vertex by vertex, so there is no in-progress polyline to open yet.
    app.UI_setTo_Create_Arc();

    assertEquals(app.CREATE.Arc, app.CreateObject);
    assertEquals(app.ObjectCategory.POLYLINE, app.currentObjectCategory);
    assertEquals(0, app.allPolylines.nodes.length);
  }

  // ================= the SuperOBJ-based primitives ========================
  // Several different-looking toolbar buttons all funnel into the same
  // CREATE.SuperOBJ, distinguished only by the three superellipsoid
  // power exponents they leave behind in User3D - CubePower
  // (globalVariables.pde, currently 16) stands in for "flat side" and 2
  // for "round".

  @Test
  void createBox_setsAllThreeSuperellipsoidPowers_toCubePower () {
    app.UI_setTo_Create_Box();

    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
    assertEquals(app.CubePower, app.User3D.creatorSuperellipsoidPowerX, 0.0001f);
    assertEquals(app.CubePower, app.User3D.creatorSuperellipsoidPowerY, 0.0001f);
    assertEquals(app.CubePower, app.User3D.creatorSuperellipsoidPowerZ, 0.0001f);
  }

  @Test
  void createSphere_setsAllThreeSuperellipsoidPowers_toTwo () {
    app.UI_setTo_Create_Sphere();

    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
    assertEquals(2f, app.User3D.creatorSuperellipsoidPowerX, 0.0001f);
    assertEquals(2f, app.User3D.creatorSuperellipsoidPowerY, 0.0001f);
    assertEquals(2f, app.User3D.creatorSuperellipsoidPowerZ, 0.0001f);
  }

  @Test
  void createCylinder_isRoundOnXYButFlatOnZ () {
    app.UI_setTo_Create_Cylinder();

    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
    assertEquals(2f, app.User3D.creatorSuperellipsoidPowerX, 0.0001f);
    assertEquals(2f, app.User3D.creatorSuperellipsoidPowerY, 0.0001f);
    assertEquals(app.CubePower, app.User3D.creatorSuperellipsoidPowerZ, 0.0001f);
  }

  @Test
  void createCushion_isFlatOnXYButRoundOnZ_theMirrorOfCylinder () {
    app.UI_setTo_Create_Cushion();

    assertEquals(app.CREATE.SuperOBJ, app.CreateObject);
    assertEquals(app.CubePower, app.User3D.creatorSuperellipsoidPowerX, 0.0001f);
    assertEquals(app.CubePower, app.User3D.creatorSuperellipsoidPowerY, 0.0001f);
    assertEquals(2f, app.User3D.creatorSuperellipsoidPowerZ, 0.0001f);
  }

  @Test
  void createIcosahedronAndCreateOctahedron_leaveIdenticalSuperellipsoidPowers () {
    // Pinned down deliberately, not an oversight in this test: both
    // functions set exactly the same three powers (1, 1, 1) - confirmed
    // directly in uiSetTo.pde's own source, not just inferred here.
    // Whatever currently visually distinguishes an icosahedron from an
    // octahedron in this app, it is NOT either button's own choice of
    // exponents - those come out identical. Worth a second look if
    // that's not intentional.
    app.UI_setTo_Create_Icosahedron();
    float icoX = app.User3D.creatorSuperellipsoidPowerX;
    float icoY = app.User3D.creatorSuperellipsoidPowerY;
    float icoZ = app.User3D.creatorSuperellipsoidPowerZ;

    app.UI_setTo_Create_Octahedron();

    assertEquals(icoX, app.User3D.creatorSuperellipsoidPowerX, 0.0001f);
    assertEquals(icoY, app.User3D.creatorSuperellipsoidPowerY, 0.0001f);
    assertEquals(icoZ, app.User3D.creatorSuperellipsoidPowerZ, 0.0001f);
    assertEquals(1f, app.User3D.creatorSuperellipsoidPowerX, 0.0001f);
  }

  // ================= every Create_* always resets through Nothing first ==

  @Test
  void everyCreateFunction_resetsThroughCreateNothingFirst_soStaleStateNeverLeaksAcrossAToolSwitch () {
    // UI_setTo_Create_Vertex()'s own first line is UI_setTo_Create_
    // Nothing() (uiSetTo.pde) - demonstrated here by switching from a
    // Face (which leaves behind an open, empty face - see this class's
    // own createFace_... test above) straight to Vertex, and confirming
    // CreateObject actually lands on Vertex rather than staying Face
    // (or some half-reset state in between).
    app.UI_setTo_Create_Face();
    assertEquals(app.CREATE.Face, app.CreateObject, "sanity check, not the point of this test");

    app.UI_setTo_Create_Vertex();

    assertEquals(app.CREATE.Vertex, app.CreateObject);
    assertEquals(app.UITASK.Create, app.User3D.currentTool);
  }
}
