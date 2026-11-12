import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Edit3D.Groups() (edit3D.pde) was at 0% coverage - its own loop logic
// (for a selected group, walk its owned face range via allGroups.
// getStart_Face()/getStop_Face(), then its owned polyline range the same
// way, each bounds-checked against the real allFaces.nodes.length/
// allPolylines.nodes.length before calling adjustFaceProperties()/
// adjustPolylineProperties()) isn't exercised by Edit3D.Faces()/
// Polylines() being covered on their own (WheelHandlersTest.java/
// HandleObjectEditWheelTest.java) - those two test a direct face/
// polyline selection, never a group that owns one.
//
// Also fills in the remaining adjustFaceProperties()/
// adjustPolylineProperties() branches: those two existing files only
// ever select UITASK.Seed_Material, leaving Tessellation/Layer/
// Visibility/Weight on both at 0%.
class Edit3DGroupsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.currentObjectCategory = app.ObjectCategory.GROUP;
    app.Select3D.groupSelection = new int[]{0};
  }

  // Group 0 owns face index 0 and polyline index 0 - the minimal case
  // where both of Groups()'s own sub-loops have exactly one iteration to
  // actually do real work on.
  private void armOneFaceAndOnePolylineOwnedByGroupZero () {
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 1, 2, 1, 5, 0}}; // material, tessellation, layer, visibility, weight, close
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.allPolylines.options = new int[][]{{3, 1, 2, 1, 5, 0}};
    app.allGroups.num = 1;
    app.allGroups.Faces = new int[][]{{0, 0}};
    app.allGroups.Polylines = new int[][]{{0, 0}};
  }

  @Test
  void seedMaterial_adjustsBothTheGroupsOwnedFaceAndItsOwnedPolyline () {
    armOneFaceAndOnePolylineOwnedByGroupZero();
    app.User3D.currentTool = app.UITASK.Seed_Material;

    app.Edit3D.selection(-1);

    assertEquals(2, app.allFaces.getMaterial(0));     // 3 - 1
    assertEquals(2, app.allPolylines.getMaterial(0));  // 3 - 1
  }

  @Test
  void tessellation_adjustsBothTheGroupsOwnedFaceAndItsOwnedPolyline () {
    armOneFaceAndOnePolylineOwnedByGroupZero();
    app.User3D.currentTool = app.UITASK.Tessellation;

    app.Edit3D.selection(1);

    assertEquals(2, app.allFaces.getTessellation(0));     // 1 + 1
    assertEquals(2, app.allPolylines.getTessellation(0)); // 1 + 1
  }

  @Test
  void layer_visibility_andWeight_eachAdjustTheirOwnOwnedFaceAndPolylineFieldOnly () {
    armOneFaceAndOnePolylineOwnedByGroupZero();

    app.User3D.currentTool = app.UITASK.Layer;
    app.Edit3D.selection(3);
    assertEquals(5, app.allFaces.getLayer(0));     // 2 + 3
    assertEquals(5, app.allPolylines.getLayer(0)); // 2 + 3

    app.User3D.currentTool = app.UITASK.Visibility;
    app.Edit3D.selection(1);
    assertEquals(2, app.allFaces.getVisibility(0));     // 1 + 1, clamp(...,0,2)
    assertEquals(2, app.allPolylines.getVisibility(0));

    app.User3D.currentTool = app.UITASK.Weight;
    app.Edit3D.selection(-2);
    assertEquals(3, app.allFaces.getWeight(0));     // 5 - 2
    assertEquals(3, app.allPolylines.getWeight(0));
  }

  @Test
  void aGroupsFaceRangeOutsideTheRealFaceArray_isSkippedWithoutError () {
    // allFaces.nodes has only index 0, but this group claims to own face
    // index 5 - Groups()'s own "(0 <= f) && (f < allFaces.nodes.length)"
    // guard must skip it rather than index out of bounds.
    app.allFaces.nodes = new int[][]{{0, 1, 2}};
    app.allFaces.options = new int[][]{{3, 0, 0, 1, 0, 0}};
    app.allPolylines.nodes = new int[0][];
    app.allPolylines.options = new int[0][];
    app.allGroups.num = 1;
    app.allGroups.Faces = new int[][]{{5, 5}};
    app.allGroups.Polylines = new int[][]{{0, -1}}; // start > stop - the loop itself never runs

    app.User3D.currentTool = app.UITASK.Seed_Material;

    assertDoesNotThrow(() -> app.Edit3D.selection(-1));

    assertEquals(3, app.allFaces.getMaterial(0), "unchanged - face index 0 was never actually owned by this group");
  }
}
