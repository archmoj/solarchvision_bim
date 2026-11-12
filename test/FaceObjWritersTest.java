import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.StringWriter;
import java.io.PrintWriter;

// Tropo3D.writeFaceOBJ()/Earth3D.writeFaceOBJ() - the per-vertex OBJ
// writers (distinct from writeOBJfaceSelection(), the per-face "f" line
// writer ExportFaceWritersTest.java already covers directly - these two
// call that same function internally, on their own _turn == 3, but that
// path isn't re-verified here since it already is there) - and Tropo3D.
// writeMTLHeader()/Earth3D.writeMTLHeader() were all previously
// untested. Same real-PrintWriter-capture strategy as the rest of this
// suite's export-pipeline tests (ExportFaceWritersTest.java/
// MaterialWritersTest.java/ObjVertexWritersTest.java).
//
// Both writeFaceOBJ() functions share an identical shape - clamp01()
// each vertex's own u/v, then dispatch on _turn: 1 writes "v" lines
// (OBJprintVertex()), 2 writes "vt" lines (OBJprintVtexture(), with v
// mirrored), 3 just increments the running vertex/vtexture counters and
// calls writeOBJfaceSelection(). OBJprintVertex()'s own exact output
// depends on User3D.exporterYaxisUp (its own bare-construction default,
// 1): "v " + (-x*scale) + " " + (z*scale) + " " + (y*scale), not simply
// x/y/z in order - read directly from its own source, not assumed.
class FaceObjWritersTest {

  private solarchvision_bim app;
  private StringWriter captured;
  private static final String EOL = System.lineSeparator();

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    captured = new StringWriter();
  }

  private solarchvision_bim.Tropo3D.FaceVertex[] tropoSubFace () {
    solarchvision_bim.Tropo3D.FaceVertex[] subFace = new solarchvision_bim.Tropo3D.FaceVertex[2];
    subFace[0] = app.Tropo3D.new FaceVertex();
    subFace[0].x = 1; subFace[0].y = 2; subFace[0].z = 3; subFace[0].u = 0.5f; subFace[0].v = 0.25f;
    subFace[1] = app.Tropo3D.new FaceVertex();
    subFace[1].x = 4; subFace[1].y = 5; subFace[1].z = 6; subFace[1].u = 1.5f; subFace[1].v = -0.5f; // out-of-[0,1] - exercises clamp01()
    return subFace;
  }

  @Test
  void tropo3D_writeFaceOBJ_turn1_writesVLines () {
    app.objOutput = new PrintWriter(captured);

    app.Tropo3D.writeFaceOBJ(tropoSubFace(), 0, 1, 5);
    app.objOutput.flush();

    // exporterYaxisUp == 1 (default): "v " + (-x) + " " + z + " " + y, exporterScale == 1.
    String expected =
        "v -1.000000 3.000000 2.000000" + EOL +
        "v -4.000000 6.000000 5.000000" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void tropo3D_writeFaceOBJ_turn2_writesVtLines_withClampedAndMirroredUV () {
    app.objOutput = new PrintWriter(captured);

    app.Tropo3D.writeFaceOBJ(tropoSubFace(), 0, 2, 5);
    app.objOutput.flush();

    // u clamped to [0,1], then v = 1 - clamp01(v): (0.5,0.25)->(0.5,0.75); (1.5,-0.5) clamps to (1,0)->(1,1).
    String expected =
        "vt 0.5000 0.7500 0.0000" + EOL +
        "vt 1.0000 1.0000 0.0000" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void tropo3D_writeFaceOBJ_turn3_incrementsCountersForEveryVertex_andCallsWriteOBJfaceSelection () {
    app.objOutput = new PrintWriter(captured);
    app.obj_lastVertexNumber = 10;
    app.obj_lastVtextureNumber = 20;
    app.obj_lastFaceNumber = 0;

    app.Tropo3D.writeFaceOBJ(tropoSubFace(), 0, 3, 5);
    app.objOutput.flush();

    assertEquals(12, app.obj_lastVertexNumber, "one increment per vertex in subFace (2 of them)");
    assertEquals(22, app.obj_lastVtextureNumber);
    assertTrue(captured.toString().startsWith("f "), "must have actually called writeOBJfaceSelection()");
  }

  // ================= Earth3D.writeFaceOBJ (no n_Map parameter) ===================

  @Test
  void earth3D_writeFaceOBJ_turn1_writesVLines () {
    app.objOutput = new PrintWriter(captured);
    solarchvision_bim.Earth3D.FaceVertex[] subFace = new solarchvision_bim.Earth3D.FaceVertex[1];
    subFace[0] = app.Earth3D.new FaceVertex();
    subFace[0].x = 1; subFace[0].y = 2; subFace[0].z = 3; subFace[0].u = 0.5f; subFace[0].v = 0.5f;

    app.Earth3D.writeFaceOBJ(subFace, 0, 1);
    app.objOutput.flush();

    assertEquals("v -1.000000 3.000000 2.000000" + EOL, captured.toString());
  }

  // ================= writeMTLHeader ============================================

  @Test
  void tropo3D_writeMTLHeader_writesTheStandardMtlBlock () {
    app.mtlOutput = new PrintWriter(captured);

    app.Tropo3D.writeMTLHeader(5);
    app.mtlOutput.flush();

    String expected =
        "newmtl TropoSphere5" + EOL +
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

  @Test
  void earth3D_writeMTLHeader_writesTheStandardMtlBlock () {
    app.mtlOutput = new PrintWriter(captured);

    app.Earth3D.writeMTLHeader();
    app.mtlOutput.flush();

    String expected =
        "newmtl EarthSphere" + EOL +
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
}
