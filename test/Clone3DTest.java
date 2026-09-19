import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.HashMap;

class Clone3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= selection() dispatcher ==========================

  @Test
  void selection_faceCategoryDispatchesToFaces () {
    app.allVertices = new float[][]{{1, 2, 3}};
    app.allFaces.nodes = new int[][]{{0}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.current_ObjectCategory = app.ObjectCategory.FACE;
    app.Select3D.Face_ids = new int[]{0};

    app.Clone3D.selection(true);

    assertEquals(2, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{1}, app.Select3D.Face_ids); // only the new clone stays selected
  }

  @Test
  void selection_landPointCategoryIsANoOp () {
    // "nothing to clone" per the source comment - LandPoints have no
    // clone branch in the dispatcher at all.
    app.current_ObjectCategory = app.ObjectCategory.LANDPOINT;
    app.Select3D.LandPoint_ids = new int[]{3};
    app.Clone3D.selection(true);
    assertArrayEquals(new int[]{3}, app.Select3D.LandPoint_ids); // untouched
  }

  // ================= appendRange ======================================

  @Test
  void appendRange_appendsTheHalfOpenRange () {
    assertArrayEquals(new int[]{9, 5, 6}, app.Clone3D.appendRange(new int[]{9}, 5, 7));
  }

  @Test
  void appendRange_returnsTheOriginalArrayUnchangedWhenTheRangeIsEmpty () {
    int[] original = {9};
    assertSame(original, app.Clone3D.appendRange(original, 5, 5));  // start == endExclusive
    assertSame(original, app.Clone3D.appendRange(original, 7, 5));  // start > endExclusive
  }

  // ================= cloneNodes =======================================

  @Test
  void cloneNodes_reusesAVertexAlreadyInTheMapInsteadOfCreatingAnother () {
    app.allVertices = new float[][]{{1, 1, 1}, {2, 2, 2}};
    HashMap<Integer, Integer> vertexMap = new HashMap<Integer, Integer>();

    int[] firstPass = app.Clone3D.cloneNodes(new int[]{0, 1}, vertexMap);
    assertEquals(4, app.allVertices.length); // 2 original + 2 new clones
    assertArrayEquals(new int[]{2, 3}, firstPass);

    // Reusing the SAME map for a second face that shares vertex 0: it
    // should reuse the already-cloned vertex 2, not create a third copy.
    int[] secondPass = app.Clone3D.cloneNodes(new int[]{0, 0}, vertexMap);
    assertEquals(4, app.allVertices.length); // no new vertices created
    assertArrayEquals(new int[]{2, 2}, secondPass);
  }

  // ================= cloneFace / clonePolyline ========================

  @Test
  void cloneFace_isANoOpForAnOutOfRangeIndex () {
    app.allFaces.nodes = new int[][]{{0}};
    app.Clone3D.cloneFace(5, new HashMap<Integer, Integer>());
    assertEquals(1, app.allFaces.nodes.length); // unchanged
  }

  @Test
  void cloneFace_copiesNodesAndOptions () {
    app.allVertices = new float[][]{{1, 1, 1}};
    app.allFaces.nodes = new int[][]{{0}};
    app.allFaces.options = new int[][]{{7, 1, 2, 1, 0, 0}}; // material=7, tessellation=1, layer=2, visible

    app.Clone3D.cloneFace(0, new HashMap<Integer, Integer>());

    assertEquals(2, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{7, 1, 2, 1, 0, 0}, app.allFaces.options[1]);
  }

  @Test
  void clonePolyline_isANoOpForAnOutOfRangeIndex () {
    app.allPolylines.nodes = new int[][]{{0}};
    app.Clone3D.clonePolyline(5, new HashMap<Integer, Integer>());
    assertEquals(1, app.allPolylines.nodes.length);
  }

  @Test
  void clonePolyline_copiesNodesAndOptionsIncludingWeightAndClosed () {
    app.allVertices = new float[][]{{1, 1, 1}};
    app.allPolylines.nodes = new int[][]{{0}};
    app.allPolylines.options = new int[][]{{3, 0, 1, 1, 5, 1}}; // weight=5, closed=1

    app.Clone3D.clonePolyline(0, new HashMap<Integer, Integer>());

    assertEquals(2, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{3, 0, 1, 1, 5, 1}, app.allPolylines.options[1]);
  }

  // ================= cloneModel1D =====================================

  @Test
  void cloneModel1D_produceSameVariationCopiesEveryFieldExactly () {
    app.allModel1Ds.f_data = new float[][]{
      {10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6} // x,y,z,scale,rot,tilt,twist,ratio,base,trunkSize,leafSize
    };
    app.allModel1Ds.i_data = new int[][]{{7, 99, 8}}; // type, seed, degreeMax
    app.allModel1Ds.num = 1;

    app.Clone3D.cloneModel1D(0, true, false);

    assertEquals(2, app.allModel1Ds.num);
    assertEquals(10f, app.allModel1Ds.getX(1), 0.0001f);
    assertEquals(45f, app.allModel1Ds.getRotation(1), 0.0001f); // unchanged - exact copy
    assertEquals(99, app.allModel1Ds.getSeed(1));
  }

  @Test
  void cloneModel1D_notProduceSameVariationWithoutRandomizeFlagStillKeepsTheOriginalRotationAndSeed () {
    // randomizeRotationAndSeed is a SEPARATE flag from
    // produce_same_variation - per the source comment, only the Groups()
    // clone path passes randomizeRotationAndSeed=true; the plain
    // Model1Ds() batch function always passes false, so even a "not the
    // same variation" clone keeps the original rotation/seed here.
    app.allModel1Ds.f_data = new float[][]{{10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6}};
    app.allModel1Ds.i_data = new int[][]{{7, 99, 8}};
    app.allModel1Ds.num = 1;

    app.Clone3D.cloneModel1D(0, false, false);

    assertEquals(45f, app.allModel1Ds.getRotation(1), 0.0001f);
    assertEquals(99, app.allModel1Ds.getSeed(1));
  }

  @Test
  void cloneModel1D_randomizeRotationAndSeedProducesAWellFormedButDifferentOrientation () {
    app.allModel1Ds.f_data = new float[][]{{10, 20, 30, 2, 45, 1, 2, 3, 4, 5, 6}};
    app.allModel1Ds.i_data = new int[][]{{7, 99, 8}};
    app.allModel1Ds.num = 1;

    app.Clone3D.cloneModel1D(0, false, true);

    float newRot = app.allModel1Ds.getRotation(1);
    int newSeed = app.allModel1Ds.getSeed(1);
    assertTrue(newRot >= 0f && newRot < 360f);
    assertTrue(newSeed >= 0 && newSeed < 32767);
    // Position and every other non-randomized field still carry over exactly.
    assertEquals(10f, app.allModel1Ds.getX(1), 0.0001f);
    assertEquals(2f, app.allModel1Ds.getScale(1), 0.0001f);
  }

  // ================= cloneModel2D =====================================

  @Test
  void cloneModel2D_produceSameVariationClonesPositionAndPreservesFamily () {
    app.allModel2Ds.XYZS = new float[][]{{10, 20, 30, 2}};
    app.allModel2Ds.MAP = new int[]{5}; // abs(5) > num_files_PEOPLE(0) -> a tree
    app.allModel2Ds.num = 1;

    app.Clone3D.cloneModel2D(0, true);

    assertEquals(2, app.allModel2Ds.num);
    assertEquals(10f, app.allModel2Ds.getX(1), 0.0001f);
    assertEquals(30f, app.allModel2Ds.getZ(1), 0.0001f);
    // create()'s own internal +/-1 sign roll means only the MAGNITUDE
    // (and therefore the tree/person family) is guaranteed preserved,
    // not necessarily the exact signed MAP value.
    assertTrue(app.allModel2Ds.isTree(app.allModel2Ds.MAP[1]));
  }

  @Test
  void cloneModel2D_notProduceSameVariationPicksAFreshVariantOfTheSameFamily () {
    // Widen the People/Trees ranges so "a fresh random variant" and "the
    // exact original" are distinguishable ranges rather than both
    // degenerately collapsing to 1 (which is what happens with the
    // default num_files_PEOPLE=num_files_TREES=0).
    app.allModel2Ds.num_files_PEOPLE = 5;  // variant ids 1-5
    app.allModel2Ds.num_files_TREES = 5;   // variant ids 6-10
    app.allModel2Ds.XYZS = new float[][]{{10, 20, 30, 2}};
    app.allModel2Ds.MAP = new int[]{7}; // a tree (abs(7) > 5)
    app.allModel2Ds.num = 1;

    app.Clone3D.cloneModel2D(0, false);

    int newAbsMap = Math.abs(app.allModel2Ds.MAP[1]);
    assertTrue(newAbsMap >= 6 && newAbsMap <= 10); // still a tree-range variant
    assertTrue(app.allModel2Ds.isTree(app.allModel2Ds.MAP[1]));
  }

  // ================= cloneSolid =======================================

  @Test
  void cloneSolid_copiesEveryFieldExactly () {
    app.allSolids.DEF = new float[][]{
      {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13}
    };

    app.Clone3D.cloneSolid(0);

    assertEquals(2, app.allSolids.DEF.length);
    assertArrayEquals(app.allSolids.DEF[0], app.allSolids.DEF[1], 0.0001f);
  }

  // ================= Faces / Polylines (batch) ========================

  @Test
  void facesBatch_clonesEverySelectedFaceAndSelectsOnlyTheClones () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 1, 1}};
    app.allFaces.nodes = new int[][]{{0}, {1}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}};
    app.Select3D.Face_ids = new int[]{0, 1};

    app.Clone3D.Faces(true);

    assertEquals(4, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{2, 3}, app.Select3D.Face_ids);
  }

  @Test
  void polylinesBatch_clonesEverySelectedPolylineAndSelectsOnlyTheClones () {
    app.allVertices = new float[][]{{0, 0, 0}};
    app.allPolylines.nodes = new int[][]{{0}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.Select3D.Polyline_ids = new int[]{0};

    app.Clone3D.Polylines(true);

    assertEquals(2, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{1}, app.Select3D.Polyline_ids);
  }

  // ================= Model1Ds / Model2Ds / Solids (batch) ==============

  @Test
  void model1DsBatch_clonesEverySelectedModel1DAndSelectsOnlyTheClones () {
    app.allModel1Ds.f_data = new float[][]{new float[11], new float[11]};
    app.allModel1Ds.i_data = new int[][]{new int[3], new int[3]};
    app.allModel1Ds.num = 2;
    app.Select3D.Model1D_ids = new int[]{0, 1};

    app.Clone3D.Model1Ds(true);

    assertEquals(4, app.allModel1Ds.num);
    assertArrayEquals(new int[]{2, 3}, app.Select3D.Model1D_ids);
  }

  @Test
  void model2DsBatch_clonesEverySelectedModel2DAndSelectsOnlyTheClones () {
    app.allModel2Ds.XYZS = new float[][]{new float[4]};
    app.allModel2Ds.MAP = new int[]{1};
    app.allModel2Ds.num = 1;
    app.Select3D.Model2D_ids = new int[]{0};

    app.Clone3D.Model2Ds(true);

    assertEquals(2, app.allModel2Ds.num);
    assertArrayEquals(new int[]{1}, app.Select3D.Model2D_ids);
  }

  @Test
  void solidsBatch_clonesEverySelectedSolidAndSelectsOnlyTheClones () {
    app.allSolids.DEF = new float[][]{new float[13]};
    app.Select3D.Solid_ids = new int[]{0};

    app.Clone3D.Solids(true);

    assertEquals(2, app.allSolids.DEF.length);
    assertArrayEquals(new int[]{1}, app.Select3D.Solid_ids);
  }

  // ================= Sections (batch) =================================
  //
  // Unlike Move3D/Scale3D/Rotate3D's Sections() functions, this one does
  // NOT call allSolidImpacts.calculate_Impact_selectedSections() at all -
  // it only creates new section rows - so it's fully safe to test here,
  // no skip needed.

  @Test
  void sectionsBatch_clonesEverySelectedSectionAndSelectsOnlyTheClones () {
    app.allSections.f_data = new float[][]{{1, 2, 3, 4, 5, 6}};
    app.allSections.i_data = new int[][]{{0, 4, 4}}; // type=0, small 4x4 resolution
    app.allSections.SolidImpact = new processing.core.PImage[1];
    app.allSections.SolarImpact = new processing.core.PImage[1][1][1];
    app.allSections.num = 1;

    app.Select3D.Section_ids = new int[]{0};

    app.Clone3D.Sections(true);

    assertEquals(2, app.allSections.num);
    assertArrayEquals(new int[]{1}, app.Select3D.Section_ids);
    assertEquals(1f, app.allSections.f_data[1][0], 0.0001f); // position carried over
  }

  // ================= Cameras (batch) ===================================

  @Test
  void camerasBatch_clonesEverySelectedCameraAndSelectsOnlyTheClones () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;
    app.allCameras.options[0][0] = 5; // posX

    app.Select3D.Camera_ids = new int[]{0};

    app.Clone3D.Cameras(true);

    assertEquals(2, app.allCameras.num);
    assertArrayEquals(new int[]{1}, app.Select3D.Camera_ids);
    assertEquals(5f, app.allCameras.options[1][0], 0.0001f);
  }

  // ================= Groups (a full integration test) ===================

  @Test
  void groupsBatch_clonesAGroupWithFacesAndCascadesIntoOwnedSubObjects () {
    app.allVertices = new float[][]{{1, 1, 1}};
    app.allFaces.nodes = new int[][]{{0}};
    app.allFaces.options = new int[][]{{0, 0, 0, 0, 0, 0}};
    app.allPolylines.nodes = new int[0][];

    app.allModel1Ds.f_data = new float[][]{new float[11]};
    app.allModel1Ds.i_data = new int[][]{new int[3]};
    app.allModel1Ds.num = 1;

    app.allModel2Ds.XYZS = new float[][]{new float[4]};
    app.allModel2Ds.MAP = new int[]{1};
    app.allModel2Ds.num = 1;

    app.allSolids.DEF = new float[][]{new float[13]};

    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, 0};
    app.allGroups.Polylines[0] = new int[]{0, -1};
    app.allGroups.Model1Ds[0] = new int[]{0, 0};
    app.allGroups.Model2Ds[0] = new int[]{0, 0};
    app.allGroups.Solids[0] = new int[]{0, 0};
    app.allGroups.Pivots[0] = new float[]{1, 2, 3, 1, 1, 1, 0, 0, 0};

    app.Select3D.Group_ids = new int[]{0};

    app.Clone3D.Groups(true);

    // A new group was created, with the source group's pivot copied over.
    assertEquals(2, app.allGroups.num);
    assertArrayEquals(new float[]{1, 2, 3, 1, 1, 1, 0, 0, 0}, app.allGroups.Pivots[1], 0.0001f);

    // Its owned face, Model1D, Model2D, and Solid were all cloned...
    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(2, app.allModel1Ds.num);
    assertEquals(2, app.allModel2Ds.num);
    assertEquals(2, app.allSolids.DEF.length);

    // ...and the new group's own Faces/Model1Ds/Model2Ds/Solids ranges
    // correctly grew to include them, via each create()'s own
    // "extend the last group's range" side effect.
    assertArrayEquals(new int[]{1, 1}, app.allGroups.Faces[1]);
    assertArrayEquals(new int[]{1, 1}, app.allGroups.Model1Ds[1]);
    assertArrayEquals(new int[]{1, 1}, app.allGroups.Model2Ds[1]);
    assertArrayEquals(new int[]{1, 1}, app.allGroups.Solids[1]);

    // Only the new group ends up selected.
    assertArrayEquals(new int[]{1}, app.Select3D.Group_ids);
  }

  @Test
  void groupsBatch_skipsAGroupThatHasNeitherFacesNorPolylines () {
    app.allGroups.makeEmpty(1);
    app.allGroups.Faces[0] = new int[]{0, -1};     // empty
    app.allGroups.Polylines[0] = new int[]{0, -1}; // empty

    app.Select3D.Group_ids = new int[]{0};

    app.Clone3D.Groups(true);

    assertEquals(1, app.allGroups.num); // no new group created
    assertEquals(0, app.Select3D.Group_ids.length); // nothing new to select
  }
}
