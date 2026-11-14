import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.StringWriter;
import java.io.PrintWriter;

// Terrain's downstream rendering/export functions (land3D.pde) were
// untested - the whole Terrain class was essentially 0% before
// TerrainUpdateMeshTest.java's own real elevation/texture fixture made
// Terrain.Mesh non-null for the first time. This covers the functions
// one level past that: several turned out to be the same mix this
// whole session has found repeatedly - target_window-dispatched
// functions with a safe, non-graphics branch (HTML/OBJ3D/RENDER/
// TerrainMesh) sitting next to a real WIN3D.graphics/SHADOW_graphics
// one (left untested, same category as every other *_graphics-
// dependent function this session has confirmed unreachable headlessly).
//
// Terrain.castShadows()/castLandSubFaceShadow() specifically: the
// first is safely skipped by its own "displaySurface" guard (false by
// default); castLandSubFaceShadow() itself calls SHADOW_graphics.
// beginShape() completely unconditionally (confirmed by reading it
// directly, the same way FacesCastShadowsTest.java's own header
// comment documents for Faces.castShadows()'s own SHADOW_graphics
// dependency) - not attempted here.
class TerrainRenderingTest {

  private solarchvision_bim app;
  private StringWriter captured;
  private static final String EOL = System.lineSeparator();

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    captured = new StringWriter();
  }

  // ================= writeTerrainObjFace =======================================

  @Test
  void writeTerrainObjFace_writesBothWindings () {
    app.objOutput = new PrintWriter(captured);
    app.obj_lastVertexNumber = 10;
    app.obj_lastVtextureNumber = 20;
    app.num_vertices_added = 4;
    app.obj_lastFaceNumber = 0;
    // User3D.exporterDoubleSided's own bare-construction default (true).

    app.Terrain.writeTerrainObjFace();
    app.objOutput.flush();

    String expected =
        "f 11/21 12/22 13/23 14/24" + EOL +
        "f 11/21 14/24 13/23 12/22" + EOL;

    assertEquals(expected, captured.toString());
    assertEquals(2, app.obj_lastFaceNumber);
  }

  // ================= writeTerrainMaterials ======================================

  @Test
  void writeTerrainMaterials_html_withoutTextures_writesTheAppearanceShell () {
    app.htmlOutput = new PrintWriter(captured);
    app.Terrain.Textures_num = 1;
    app.Terrain.displayTexture = false; // skips the real texture-file-copy branch entirely

    app.Terrain.writeTerrainMaterials(app.TypeWindow.HTML);
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t<Appearance DEF='TerrainMap0'>" + EOL +
        "\t\t\t\t</Appearance>" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void writeTerrainMaterials_obj3D_withoutTextures_writesTheMtlBlock () {
    app.mtlOutput = new PrintWriter(captured);
    app.Terrain.Textures_num = 1;
    app.Terrain.displayTexture = false;

    app.Terrain.writeTerrainMaterials(app.TypeWindow.OBJ3D);
    app.mtlOutput.flush();

    String expected =
        "newmtl TerrainMap0" + EOL +
        "\tilum 2" + EOL +
        "\tKa 1.000 1.000 1.000" + EOL +
        "\tKd 1.000 1.000 1.000" + EOL +
        "\tKs 0.000 0.000 0.000" + EOL +
        "\tNs 10.00" + EOL +
        "\tNi 1.500" + EOL +
        "\td 1.000" + EOL +
        "\tTr 1.000" + EOL +
        "\tTf 1.000 1.000 1.000" + EOL;

    assertEquals(expected, captured.toString());
  }

  // ================= beginLandShape / endLandShape ==============================

  @Test
  void beginLandShape_html_noTexture_writesTheShapeOpening () {
    app.htmlOutput = new PrintWriter(captured);
    float[][] subFace = {{1, 2, 3}, {4, 5, 6}};

    app.Terrain.beginLandShape(app.TypeWindow.HTML, subFace, -1, 0);
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t<shape>" + EOL +
        "\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 -1'>" + EOL +
        "\t\t\t\t\t\t<Coordinate point='1.000000 2.000000 3.000000,4.000000 5.000000 6.000000'></Coordinate>" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void beginLandShape_obj3D_turn3_withATexture_writesUsemtl () {
    app.objOutput = new PrintWriter(captured);
    app.Terrain.displayTexture = true;
    // User3D.exporterMaterialLibrary's own bare-construction default (true).
    float[][] subFace = {{1, 2, 3}};

    app.Terrain.beginLandShape(app.TypeWindow.OBJ3D, subFace, 0, 3);
    app.objOutput.flush();

    assertEquals("usemtl TerrainMap0" + EOL, captured.toString());
  }

  @Test
  void endLandShape_html_closesTheShape () {
    app.htmlOutput = new PrintWriter(captured);

    app.Terrain.endLandShape(app.TypeWindow.HTML, 1, -1, 0);
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t\t</IndexedFaceSet>" + EOL +
        "\t\t\t\t</shape>" + EOL;

    assertEquals(expected, captured.toString());
  }

  // ================= renderLandVertex ===========================================

  @Test
  void renderLandVertex_renderTarget_recordsAFlattenedPointAndFace () {
    app.allActions = new java.util.HashMap<>(); // see ViewNavigationCommandsTest.java's own setUp comment
    // entirePointsX/Y/Z/entireFaces are null by default, not an
    // already-empty ArrayList - see FaceIntersectionTest.java's own
    // setUp for the same initialization.
    app.entirePointsX = new java.util.ArrayList<Float>();
    app.entirePointsY = new java.util.ArrayList<Float>();
    app.entirePointsZ = new java.util.ArrayList<Float>();
    app.entireFaces = new java.util.ArrayList<int[]>();
    int before = app.entirePointsX.size();
    float[][] subFace = {{1, 2, 3}};
    int[] newFace = new int[1];

    app.Terrain.renderLandVertex(app.TypeWindow.RENDER, subFace, newFace, 0, 0, 0, -1, 0, 1, 1f);

    assertEquals(before + 1, app.entirePointsX.size());
    assertEquals(1f, app.entirePointsX.get(before), 0.0001f);
    assertEquals(2f, app.entirePointsY.get(before), 0.0001f);
    assertEquals(3f, app.entirePointsZ.get(before), 0.0001f);
    assertEquals(before, newFace[0]);
  }

  @Test
  void renderLandVertex_terrainMeshTarget_addsARealPoint () {
    int before = app.allVertices.length;
    float[][] subFace = {{1, 2, 3}};
    int[] newFace = new int[1];

    app.Terrain.renderLandVertex(app.TypeWindow.TerrainMesh, subFace, newFace, 0, 1 /* i != 0 */, 0, -1, 0, 1, 1f);

    assertEquals(before + 1, app.allVertices.length);
  }

  // ================= renderLandVertexShaded (default shadingMode) ===============

  @Test
  void renderLandVertexShaded_nonWIN3DTarget_doesNotThrow () {
    // WIN3D.shadingMode's own bare-construction default (SHADE.Surface_
    // Materials) takes the pure vertexRender_Surface_White(223) path -
    // no GlobalSolar dependency, no graphics touched at all since the
    // target isn't WIN3D.
    float[][] subFace = {{1, 2, 3}};

    assertDoesNotThrow(() -> app.Terrain.renderLandVertexShaded(app.TypeWindow.RENDER, subFace, 0, 0, 1, 1f));
  }

  // ================= renderLandVertexTextured ====================================

  @Test
  void renderLandVertexTextured_obj3D_turn1_writesAVLine () {
    app.objOutput = new PrintWriter(captured);
    float[][] subFace = {{1, 2, 3}};

    app.Terrain.renderLandVertexTextured(app.TypeWindow.OBJ3D, subFace, 0, 0, 1, -1);
    app.objOutput.flush();

    // n_Map == -1 -> u = v = 0 throughout; exporterYaxisUp's own
    // default (1): "v " + (-x) + " " + z + " " + y.
    assertEquals("v -1.000000 3.000000 2.000000" + EOL, captured.toString());
  }

  // ================= guard-only: writeLandDepthWalls / drawTerrainVertices / castShadows ====

  @Test
  void writeLandDepthWalls_nonWIN3DTarget_isANoOp () {
    float[][] subFace = {{1, 2, 3}, {4, 5, 6}};

    assertDoesNotThrow(() -> app.Terrain.writeLandDepthWalls(app.TypeWindow.HTML, subFace, -1));
  }

  @Test
  void drawTerrainVertices_withDisplayPointsOff_isANoOp () {
    // Terrain.displayPoints' own bare-construction default (false).
    assertDoesNotThrow(() -> app.Terrain.drawTerrainVertices());
  }

  @Test
  void terrainCastShadows_withDisplaySurfaceOff_isANoOp () {
    // Terrain.displaySurface's own bare-construction default (false) -
    // skips before ever reaching castLandSubFaceShadow()'s own
    // unconditional SHADOW_graphics.beginShape().
    assertDoesNotThrow(() -> app.Terrain.castShadows());
  }
}
