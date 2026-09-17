import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.core.PImage;

// Exercises Delete3D.pde: the removeIndices overloads (pure array
// filtering, already package-private after a recent refactor), the two
// isolatedVertices functions (self-contained given allVertices/allFaces/
// allPolylines), the selection() dispatcher, and every one of the
// selected_* deletion functions (Faces, Polylines, Groups, Cameras,
// Sections, Model1Ds, Model2Ds, Solids).
//
// A fresh `app` per test since these all mutate shared scene state.
class DeleteGeometryTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // Builds a length-`len` float row with `first` in slot 0 and zeros
  // elsewhere - just enough to both satisfy an array's expected column
  // count and be individually distinguishable for order-preservation
  // assertions after a deletion.
  private float[] floatRow (int len, float first) {
    float[] row = new float[len];
    row[0] = first;
    return row;
  }

  // --- removeIndices ----------------------------------------------

  @Test
  void removeIndices_dropsTheGivenPositionsPreservingOrder () {
    int[] result = app.Delete3D.removeIndices(new int[]{10, 20, 30, 40}, new int[]{1, 3});
    assertArrayEquals(new int[]{10, 30}, result);
  }

  @Test
  void removeIndices_dedupesRepeatedIdsAndIgnoresOutOfRangeOnes () {
    // id 1 appears twice; id -1 and id 99 are out of range for a
    // length-3 array and should be silently ignored, not crash.
    int[] result = app.Delete3D.removeIndices(new int[]{10, 20, 30}, new int[]{1, 1, -1, 99});
    assertArrayEquals(new int[]{10, 30}, result);
  }

  @Test
  void removeIndices_returnsTheSameArrayUnchangedForAnEmptyIdList () {
    int[] original = {10, 20, 30};
    int[] result = app.Delete3D.removeIndices(original, new int[]{});
    assertSame(original, result); // the actual early-return identity, not just an equal copy
  }

  @Test
  void removeIndices_returnsTheSameArrayUnchangedWhenEveryIdIsOutOfRange () {
    int[] original = {10, 20, 30};
    int[] result = app.Delete3D.removeIndices(original, new int[]{-5, 99});
    assertSame(original, result);
  }

  @Test
  void removeIndices_worksOnTheInt2DOverloadToo () {
    int[][] result = app.Delete3D.removeIndices(new int[][]{{0}, {1}, {2}, {3}}, new int[]{0, 2});
    assertEquals(2, result.length);
    assertArrayEquals(new int[]{1}, result[0]);
    assertArrayEquals(new int[]{3}, result[1]);
  }

  @Test
  void removeIndices_worksOnTheFloat2DOverloadToo () {
    float[][] result = app.Delete3D.removeIndices(
      new float[][]{{0, 0, 0}, {1, 1, 1}, {2, 2, 2}}, new int[]{1});
    assertEquals(2, result.length);
    assertArrayEquals(new float[]{0, 0, 0}, result[0], 0.0001f);
    assertArrayEquals(new float[]{2, 2, 2}, result[1], 0.0001f);
  }

  // --- isolatedVertices_Scene ---------------------------------------

  @Test
  void isolatedVerticesScene_removesEveryVertexNotReferencedByAnyFaceOrPolyline () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 1, 1}, {2, 2, 2}, {3, 3, 3}};
    app.allFaces.nodes = new int[][]{{0, 2}}; // points 1 and 3 are unused
    app.allPolylines.nodes = new int[0][];

    app.Delete3D.isolatedVertices_Scene();

    assertEquals(2, app.allVertices.length);
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{2, 2, 2}, app.allVertices[1], 0.0001f);

    // Point 2 survived but shifted down to index 1 (point 1, before it,
    // was removed) - the face's own reference must follow that shift.
    assertArrayEquals(new int[]{0, 1}, app.allFaces.nodes[0]);
  }

  // --- isolatedVertices_Selection ------------------------------------

  @Test
  void isolatedVerticesSelection_onlyConsidersVerticesWithinTheGivenSelection () {
    // Points 1, 2, and 3 are all genuinely unused - but only 1 and 2 are
    // in Vertex_ids, so point 3 must survive untouched despite also
    // being unreferenced.
    app.allVertices = new float[][]{{0, 0, 0}, {1, 1, 1}, {2, 2, 2}, {3, 3, 3}};
    app.allFaces.nodes = new int[][]{{0}};
    app.allPolylines.nodes = new int[0][];
    app.Select3D.Vertex_ids = new int[]{1, 2};

    app.Delete3D.isolatedVertices_Selection();

    assertEquals(2, app.allVertices.length); // only 1 and 2 removed, not 3
    assertArrayEquals(new float[]{0, 0, 0}, app.allVertices[0], 0.0001f);
    assertArrayEquals(new float[]{3, 3, 3}, app.allVertices[1], 0.0001f); // point 3, shifted down
    assertArrayEquals(new int[]{0}, app.allFaces.nodes[0]);
    assertEquals(0, app.Select3D.Vertex_ids.length); // deselected afterward
  }

  @Test
  void isolatedVerticesSelection_isANoOpWhenNothingIsSelected () {
    app.allVertices = new float[][]{{0, 0, 0}, {1, 1, 1}};
    app.allFaces.nodes = new int[0][];
    app.allPolylines.nodes = new int[0][];
    app.Select3D.Vertex_ids = new int[]{};

    app.Delete3D.isolatedVertices_Selection();

    assertEquals(2, app.allVertices.length); // untouched
  }

  // --- selected_Faces (a full integration test) -----------------------

  @Test
  void selectedFaces_shrinksAndShiftsOwningGroupsThenCompactsTheFaceArrays () {
    app.allVertices = new float[4][3]; // just needs to be big enough for convert_Faces_to_Vertices' bookkeeping
    app.allFaces.nodes = new int[][]{{0}, {1}, {2}, {3}};
    app.allFaces.options = new int[][]{{0}, {1}, {2}, {3}};

    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 1}; // group 0 owns faces 0-1
    app.allGroups.Faces[1] = new int[]{2, 3}; // group 1 owns faces 2-3, entirely after the deleted face

    app.Select3D.Face_ids = new int[]{1}; // delete face 1 (inside group 0's range)

    app.Delete3D.selected_Faces();

    // group 0 shrinks by 1 (the deleted face was inside its range);
    // group 1 shifts down by 1 entirely (it came after the deleted face).
    assertArrayEquals(new int[]{0, 0}, app.allGroups.Faces[0]);
    assertArrayEquals(new int[]{1, 2}, app.allGroups.Faces[1]);

    assertEquals(3, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{2}, app.allFaces.nodes[1]);
    assertArrayEquals(new int[]{3}, app.allFaces.nodes[2]);
  }

  // --- selected_Polylines ---------------------------------------------
  //
  // Structurally identical to selected_Faces above, just against
  // allPolylines/allGroups.Polylines - confirms it's wired to the right
  // arrays and not accidentally sharing logic with the Faces path.

  @Test
  void selectedPolylines_shrinksAndShiftsOwningGroupsThenCompactsThePolylineArrays () {
    app.allVertices = new float[4][3];
    app.allPolylines.nodes = new int[][]{{0}, {1}, {2}, {3}};
    app.allPolylines.options = new int[][]{{0}, {1}, {2}, {3}};

    app.allGroups.makeEmpty(2);
    app.allGroups.Polylines[0] = new int[]{0, 1};
    app.allGroups.Polylines[1] = new int[]{2, 3};

    app.Select3D.Polyline_ids = new int[]{1};

    app.Delete3D.selected_Polylines();

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Polylines[0]);
    assertArrayEquals(new int[]{1, 2}, app.allGroups.Polylines[1]);

    assertEquals(3, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{0}, app.allPolylines.nodes[0]);
    assertArrayEquals(new int[]{2}, app.allPolylines.nodes[1]);
    assertArrayEquals(new int[]{3}, app.allPolylines.nodes[2]);
  }

  // --- selected_Groups (a full integration test) -----------------------

  @Test
  void selectedGroups_cascadesIntoTheGroupsOwnFacesThenRemovesTheGroupItself () {
    app.allVertices = new float[4][3];
    app.allFaces.nodes = new int[][]{{0}, {1}, {2}, {3}};
    app.allFaces.options = new int[][]{{0}, {1}, {2}, {3}};

    app.allGroups.makeEmpty(2);
    app.allGroups.Faces[0] = new int[]{0, 1}; // group 0 owns faces 0-1 - being deleted
    app.allGroups.Faces[1] = new int[]{2, 3}; // group 1 owns faces 2-3 - survives, shifted down

    // Explicitly mark every other object type as "empty" (start > stop)
    // for both groups, using the same convention beginNewGroup() itself
    // uses, so only the Faces cascade below is actually exercised.
    for (int[][] ranges : new int[][][]{
      app.allGroups.Polylines, app.allGroups.Model1Ds, app.allGroups.Model2Ds, app.allGroups.Solids
    }) {
      ranges[0] = new int[]{0, -1};
      ranges[1] = new int[]{0, -1};
    }

    app.Select3D.Group_ids = new int[]{0}; // delete group 0

    app.Delete3D.selected_Groups();

    // Group 0's own faces (0-1) are spliced out of allFaces entirely.
    assertEquals(2, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{2}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{3}, app.allFaces.nodes[1]);

    // Group 0's row itself is removed; group 1's row survives with its
    // Faces range shifted down by the 2 faces removed ahead of it.
    assertEquals(1, app.allGroups.num);
    assertArrayEquals(new int[]{0, 1}, app.allGroups.Faces[0]); // this is (former) group 1's row
  }

  // --- selected_Cameras (a full integration test) ----------------------

  @Test
  void selectedCameras_shiftsCurrentCameraDownWhenAnEarlierOneIsDeleted () {
    app.allCameras.options = new float[][]{new float[9], new float[9], new float[9]};
    app.allCameras.Type = new int[]{0, 0, 0};
    app.allCameras.num = 3;
    app.WIN3D.currentCamera = 2;

    app.Select3D.Camera_ids = new int[]{0}; // delete camera 0, before the current one

    app.Delete3D.selected_Cameras();

    assertEquals(1, app.WIN3D.currentCamera); // shifted down by 1, not reset
    assertEquals(2, app.allCameras.num);
  }

  @Test
  void selectedCameras_resetsToCameraZeroWhenTheCurrentOneIsDeleted () {
    app.allCameras.options = new float[][]{new float[9], new float[9], new float[9]};
    app.allCameras.Type = new int[]{0, 0, 0};
    app.allCameras.num = 3;
    app.WIN3D.currentCamera = 1;

    // Deletes camera 0 (before current) and camera 1 (the current one
    // itself) in the same call - the "current camera was deleted"
    // outcome takes priority over the plain shift-down outcome
    // regardless of how much shiftBefore had already accumulated.
    app.Select3D.Camera_ids = new int[]{0, 1};

    app.Delete3D.selected_Cameras();

    assertEquals(0, app.WIN3D.currentCamera);
    assertEquals(1, app.allCameras.num);
  }

  @Test
  void selectedCameras_addsABackDefaultCameraWhenTheLastOneIsDeleted () {
    app.allCameras.options = new float[][]{new float[9]};
    app.allCameras.Type = new int[]{0};
    app.allCameras.num = 1;
    app.WIN3D.currentCamera = 0;

    app.Select3D.Camera_ids = new int[]{0};

    app.Delete3D.selected_Cameras();

    // num dropped to 0, which triggers add_first() to put one back.
    assertEquals(1, app.allCameras.num);
    assertEquals(1, app.allCameras.options.length);
  }

  // --- selection() dispatcher -----------------------------------------

  @Test
  void selectionDispatcher_onlyRunsTheBranchMatchingTheCurrentCategoryThenDeselectsAll () {
    // CAMERA category should run selected_Cameras() and nothing else -
    // in particular, NOT isolatedVertices_Selection() (that only runs
    // for VERTEX/FACE/POLYLINE/GROUP categories), so a populated
    // Vertex_ids should survive untouched right up until the final,
    // unconditional Select3D.deselectAll() at the end.
    app.allCameras.options = new float[][]{new float[9], new float[9]};
    app.allCameras.Type = new int[]{0, 0};
    app.allCameras.num = 2;
    app.WIN3D.currentCamera = 0;

    app.allVertices = new float[][]{{0, 0, 0}};
    app.Select3D.Vertex_ids = new int[]{0}; // would be examined by isolatedVertices_Selection if it ran

    app.current_ObjectCategory = app.ObjectCategory.CAMERA;
    app.Select3D.Camera_ids = new int[]{0};

    app.Delete3D.selection();

    assertEquals(1, app.allCameras.num); // the CAMERA branch did run
    assertEquals(1, app.allVertices.length); // isolatedVertices_Selection did NOT run - vertex left alone
    assertEquals(0, app.Select3D.Vertex_ids.length); // but deselectAll() at the end clears the selection anyway
  }

  // --- selected_Sections (a full integration test) ---------------------
  //
  // The one selected_* function with NO owning-group cascade at all -
  // sections aren't grouped, so this is just sort-ids-then-removeIndices
  // across its 4 backing arrays.

  @Test
  void selectedSections_compactsAllFourBackingArraysInLockstep () {
    app.allSections.f_data = new float[][]{
      floatRow(6, 100), floatRow(6, 200), floatRow(6, 300)
    };
    app.allSections.i_data = new int[][]{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
    app.allSections.SolidImpact = new PImage[3];
    app.allSections.SolarImpact = new PImage[3][1][1];
    app.allSections.num = 3;

    app.Select3D.Section_ids = new int[]{1};

    app.Delete3D.selected_Sections();

    assertEquals(2, app.allSections.num);
    assertEquals(2, app.allSections.f_data.length);
    assertEquals(100f, app.allSections.f_data[0][0], 0.0001f);
    assertEquals(300f, app.allSections.f_data[1][0], 0.0001f);
    assertEquals(2, app.allSections.i_data.length);
    assertEquals(2, app.allSections.SolidImpact.length);
    assertEquals(2, app.allSections.SolarImpact.length);
  }

  // --- selected_Model1Ds (a full integration test) ----------------------
  //
  // Same owning-group cascade shape as selected_Faces, but against
  // allGroups.Model1Ds/allModel1Ds - confirmed independently rather than
  // assumed identical.

  @Test
  void selectedModel1Ds_shiftsOwningGroupsThenCompactsItsOwnArrays () {
    app.allModel1Ds.f_data = new float[][]{
      floatRow(11, 100), floatRow(11, 200), floatRow(11, 300), floatRow(11, 400)
    };
    app.allModel1Ds.i_data = new int[][]{{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
    app.allModel1Ds.num = 4;

    app.allGroups.makeEmpty(2);
    app.allGroups.Model1Ds[0] = new int[]{0, 1};
    app.allGroups.Model1Ds[1] = new int[]{2, 3};

    app.Select3D.Model1D_ids = new int[]{1};

    app.Delete3D.selected_Model1Ds();

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Model1Ds[0]);
    assertArrayEquals(new int[]{1, 2}, app.allGroups.Model1Ds[1]);

    assertEquals(3, app.allModel1Ds.num);
    assertEquals(3, app.allModel1Ds.f_data.length);
    assertEquals(100f, app.allModel1Ds.f_data[0][0], 0.0001f);
    assertEquals(300f, app.allModel1Ds.f_data[1][0], 0.0001f);
    assertEquals(400f, app.allModel1Ds.f_data[2][0], 0.0001f);
    assertEquals(3, app.allModel1Ds.i_data.length);
  }

  // --- selected_Model2Ds (a full integration test) ----------------------

  @Test
  void selectedModel2Ds_shiftsOwningGroupsThenCompactsItsOwnArrays () {
    app.allModel2Ds.XYZS = new float[][]{
      floatRow(4, 100), floatRow(4, 200), floatRow(4, 300), floatRow(4, 400)
    };
    app.allModel2Ds.MAP = new int[]{0, 0, 0, 0};
    app.allModel2Ds.num = 4;

    app.allGroups.makeEmpty(2);
    app.allGroups.Model2Ds[0] = new int[]{0, 1};
    app.allGroups.Model2Ds[1] = new int[]{2, 3};

    app.Select3D.Model2D_ids = new int[]{1};

    app.Delete3D.selected_Model2Ds();

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Model2Ds[0]);
    assertArrayEquals(new int[]{1, 2}, app.allGroups.Model2Ds[1]);

    assertEquals(3, app.allModel2Ds.num);
    assertEquals(3, app.allModel2Ds.XYZS.length);
    assertEquals(100f, app.allModel2Ds.XYZS[0][0], 0.0001f);
    assertEquals(300f, app.allModel2Ds.XYZS[1][0], 0.0001f);
    assertEquals(400f, app.allModel2Ds.XYZS[2][0], 0.0001f);
    assertArrayEquals(new int[]{0, 0, 0}, app.allModel2Ds.MAP);
  }

  // --- selected_Solids (a full integration test) ------------------------

  @Test
  void selectedSolids_shiftsOwningGroupsThenCompactsDEFWithNoSeparateNumField () {
    // solarchvision_Solids has no `num` field at all - DEF.length IS the
    // count everywhere else in the codebase, which is exactly why
    // selected_Solids() (unlike every other selected_* function here)
    // has no "num -= ids.length" line at the end. Worth confirming
    // explicitly rather than assuming it's an oversight.
    app.allSolids.DEF = new float[][]{
      floatRow(13, 100), floatRow(13, 200), floatRow(13, 300), floatRow(13, 400)
    };

    app.allGroups.makeEmpty(2);
    app.allGroups.Solids[0] = new int[]{0, 1};
    app.allGroups.Solids[1] = new int[]{2, 3};

    app.Select3D.Solid_ids = new int[]{1};

    app.Delete3D.selected_Solids();

    assertArrayEquals(new int[]{0, 0}, app.allGroups.Solids[0]);
    assertArrayEquals(new int[]{1, 2}, app.allGroups.Solids[1]);

    assertEquals(3, app.allSolids.DEF.length);
    assertEquals(100f, app.allSolids.DEF[0][0], 0.0001f);
    assertEquals(300f, app.allSolids.DEF[1][0], 0.0001f);
    assertEquals(400f, app.allSolids.DEF[2][0], 0.0001f);
  }
}
