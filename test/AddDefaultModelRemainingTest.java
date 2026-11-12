import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Create3D.add_DefaultModel(n) (create3D.pde) only had n=1 and n=4
// covered (Create3DTest.java's own "addDefaultModel_n1.../n4..." tests) -
// 9 more (n=2,3,5,6,7,8,9,10,11) were untested, together accounting for
// most of this function's own 575 missed instructions. Each branch is
// just a sequence of runScriptLine() calls to commands that are each
// separately, substantially covered elsewhere (BeginNewGroup/Mesh2/
// Box2P/Sphere/House2/Section/Solid/Parametric/PolygonHyper) - so what's
// actually new here is specifically that add_DefaultModel() reaches and
// correctly dispatches each of its own 11 branches, not re-verifying
// those commands' own geometry-building correctness.
//
// Kept to the same style the existing n=1/n=4 tests already use:
// allGroups.num, counted directly from each branch's own "BeginNewGroup"
// call count in the source (not guessed) - n=1 and n=4 each count to 2
// by this same method, matching their own already-passing assertions
// exactly, which is as close to a built-in cross-check on the counting
// method itself as this file can get. Exact face counts aren't asserted
// for the shape-heavy branches (n=2/3/6/7/10 especially - dozens of
// Box2P/Sphere calls whose combined face count isn't independently
// re-derived here), only that real geometry is produced at all.
class AddDefaultModelRemainingTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.Terrain.loadMesh = false; // see Create3DTest.java's own n=1 test comment
    app.build_allActions(); // add_DefaultModel now dispatches through allActions
  }

  @Test
  void n2_buildsAMeshAndAHutInTwoGroups () {
    app.Create3D.add_DefaultModel(2);

    assertEquals(2, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void n3_buildsAMeshAndATallerBuildingInTwoGroups () {
    app.Create3D.add_DefaultModel(3);

    assertEquals(2, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void n5_buildsAMeshAndAHouse2InTwoGroups () {
    app.Create3D.add_DefaultModel(5);

    assertEquals(2, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void n6_buildsAMeshTwoSpheresAndAHouse2InFourGroups () {
    app.Create3D.add_DefaultModel(6);

    assertEquals(4, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void n7_buildsASectionAndThreeSphereSolidsInFourGroups () {
    app.Create3D.add_DefaultModel(7);

    assertEquals(4, app.allGroups.num);
    // The Section group's own faces, plus 3 Solid entries (distinct
    // from Faces - allSolids.DEF, not allFaces.nodes) from the 3
    // sphere-shaped Solid groups.
    assertTrue(app.allFaces.nodes.length > 0);
    assertEquals(3, app.allSolids.DEF.length);
  }

  @Test
  void n8_buildsAMeshAndAParametricSurfaceInTwoGroups () {
    app.Create3D.add_DefaultModel(8);

    assertEquals(2, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void n9_buildsAMeshAndAPolygonHyperInTwoGroups () {
    app.Create3D.add_DefaultModel(9);

    assertEquals(2, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void n10_buildsAMeshAndA34BoxComplexInTwoGroups () {
    app.Create3D.add_DefaultModel(10);

    assertEquals(2, app.allGroups.num);
    assertTrue(app.allFaces.nodes.length > 0);
  }

  @Test
  void n11_buildsASingleSectionGroup () {
    app.Create3D.add_DefaultModel(11);

    assertEquals(1, app.allGroups.num);
    // "Section" (extraCommands.pde's __SECTION__) calls allSections.create(),
    // not allFaces.create() - a Section is tracked in its own, separate
    // collection, unlike n=7's Sphere groups (which do land in allFaces,
    // which is why that test's own analogous assertion passed).
    assertEquals(1, app.allSections.num);
  }
}
