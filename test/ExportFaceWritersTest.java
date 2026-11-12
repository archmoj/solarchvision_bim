import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.StringWriter;
import java.io.PrintWriter;

// Earth3D.writeFaceHTML()/writeOBJfaceSelection() and Tropo3D.writeFaceHTML()
// (earth3D.pde/tropo3D.pde) are part of the X3D/HTML and OBJ export
// pipeline - previously untested even in the merged (unit + image)
// coverage report (nothing in either suite apparently ever runs an
// actual export). Each one is pure string formatting against
// htmlOutput/objOutput - both top-level PrintWriter fields, null until
// something opens a real export file - so each test here points that
// field at a real java.io.PrintWriter wrapping a StringWriter instead,
// to capture and verify the exact text written, not just that nothing
// throws.
//
// println()'s own line terminator is the platform's (via the underlying
// PrintWriter, same as System.out's own - see ConsolePrintHelpersTest.java's
// own fix for the Windows/Linux difference this caused there), so every
// expected string below is built with System.lineSeparator(), not a
// hardcoded "\n".
//
// FaceVertex (both Earth3D's own and Tropo3D's own - distinct, identically-
// shaped inner classes, one per celestial-body tab) is a plain data
// holder (x, y, z, u, v, w, all public fields, no constructor logic) -
// built directly here with hand-picked values rather than through
// Earth3D's own buildVertex() (which separately pulls in real elevation-
// texture image data and STATION-based rotation math, Earth3DTest.java's
// own job, not this file's).
class ExportFaceWritersTest {

  private solarchvision_bim app;
  private StringWriter captured;
  private static final String EOL = System.lineSeparator();

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    captured = new StringWriter();
  }

  private solarchvision_bim.Earth3D.FaceVertex[] earthSubFace () {
    solarchvision_bim.Earth3D.FaceVertex[] subFace = new solarchvision_bim.Earth3D.FaceVertex[3];
    subFace[0] = app.Earth3D.new FaceVertex();
    subFace[0].x = 1; subFace[0].y = 2; subFace[0].z = 3; subFace[0].u = 0.5f; subFace[0].v = 0.25f;
    subFace[1] = app.Earth3D.new FaceVertex();
    subFace[1].x = 4; subFace[1].y = 5; subFace[1].z = 6; subFace[1].u = 0.1f; subFace[1].v = 0.9f;
    subFace[2] = app.Earth3D.new FaceVertex();
    subFace[2].x = -1; subFace[2].y = -2; subFace[2].z = -3; subFace[2].u = 1.5f; subFace[2].v = -0.5f; // out-of-[0,1] - exercises clamp01()
    return subFace;
  }

  // Coordinate block shared by both writeFaceHTML() tests below - same
  // subFace values in both, User3D.exporterPrecisionVertex's own
  // bare-construction default (6).
  private static final String EXPECTED_COORDINATE =
      "1.000000 2.000000 3.000000,4.000000 5.000000 6.000000,-1.000000 -2.000000 -3.000000";
  // TextureCoordinate: u clamped to [0,1], v stored as 1-clamp01(v)
  // (mirroring) - v=0.25->0.75, v=0.9->0.1, v=-0.5 clamps to 0 -> 1-0=1;
  // u=1.5 clamps to 1. User3D.exporterPrecisionVertexTexture's own
  // bare-construction default (4).
  private static final String EXPECTED_TEXTURE_COORDINATE =
      "0.5000 0.7500,0.1000 0.1000,1.0000 1.0000";

  @Test
  void earth3D_writeFaceHTML_writesTheExpectedX3DShapeBlock () {
    app.htmlOutput = new PrintWriter(captured);

    app.Earth3D.writeFaceHTML(earthSubFace(), "myTexture");
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t<shape>" + EOL +
        "\t\t\t\t\t<Appearance USE='myTexture'></Appearance>" + EOL +
        "\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 -1'>" + EOL +
        "\t\t\t\t\t\t<Coordinate point='" + EXPECTED_COORDINATE + "'></Coordinate>" + EOL +
        "\t\t\t\t\t\t<TextureCoordinate point='" + EXPECTED_TEXTURE_COORDINATE + "'></TextureCoordinate>" + EOL +
        "\t\t\t\t\t</IndexedFaceSet>" + EOL +
        "\t\t\t\t</shape>" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void earth3D_writeOBJfaceSelection_withDefaultSettings_writesBothWindingsAndNoGroupLine () {
    app.objOutput = new PrintWriter(captured);
    app.obj_lastVertexNumber = 10;
    app.obj_lastVtextureNumber = 20;
    app.obj_lastFaceNumber = 0;
    // User3D.exporterMaintainPolygons (1) and exporterDoubleSided (true)
    // both left at their own bare-construction defaults.

    app.Earth3D.writeOBJfaceSelection(5);
    app.objOutput.flush();

    String expected =
        "f 7/17 8/18 9/19 10/20" + EOL +
        "f 7/17 10/20 9/19 8/18" + EOL; // exporterDoubleSided's own reversed-winding second face

    assertEquals(expected, captured.toString());
    assertFalse(captured.toString().contains("g EarthSphere"), "exporterMaintainPolygons==1 must not emit a group line");
    assertEquals(2, app.obj_lastFaceNumber, "both faces (the real one and its double-sided mirror) must be counted");
  }

  @Test
  void earth3D_writeOBJfaceSelection_withMaintainPolygonsOff_alsoEmitsAGroupLine () {
    app.objOutput = new PrintWriter(captured);
    app.obj_lastVertexNumber = 10;
    app.obj_lastVtextureNumber = 20;
    app.obj_lastGroupNumber = 0;
    app.User3D.exporterMaintainPolygons = 0;
    app.User3D.exporterDoubleSided = false; // isolate this test to just the group-line difference

    app.Earth3D.writeOBJfaceSelection(5);
    app.objOutput.flush();

    String expected =
        "g EarthSphere_5" + EOL +
        "f 7/17 8/18 9/19 10/20" + EOL;

    assertEquals(expected, captured.toString());
    assertEquals(1, app.obj_lastGroupNumber);
  }

  // ================= Tropo3D.writeFaceHTML ====================================

  private solarchvision_bim.Tropo3D.FaceVertex[] tropoSubFace () {
    solarchvision_bim.Tropo3D.FaceVertex[] subFace = new solarchvision_bim.Tropo3D.FaceVertex[3];
    subFace[0] = app.Tropo3D.new FaceVertex();
    subFace[0].x = 1; subFace[0].y = 2; subFace[0].z = 3; subFace[0].u = 0.5f; subFace[0].v = 0.25f;
    subFace[1] = app.Tropo3D.new FaceVertex();
    subFace[1].x = 4; subFace[1].y = 5; subFace[1].z = 6; subFace[1].u = 0.1f; subFace[1].v = 0.9f;
    subFace[2] = app.Tropo3D.new FaceVertex();
    subFace[2].x = -1; subFace[2].y = -2; subFace[2].z = -3; subFace[2].u = 1.5f; subFace[2].v = -0.5f;
    return subFace;
  }

  @Test
  void tropo3D_writeFaceHTML_withARealMapIndex_includesAppearanceAndTextureCoordinate () {
    app.htmlOutput = new PrintWriter(captured);

    app.Tropo3D.writeFaceHTML(tropoSubFace(), 5);
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t<shape>" + EOL +
        "\t\t\t\t\t<Appearance USE='TropoSphere5'></Appearance>" + EOL +
        "\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 -1'>" + EOL +
        "\t\t\t\t\t\t<Coordinate point='" + EXPECTED_COORDINATE + "'></Coordinate>" + EOL +
        "\t\t\t\t\t\t<TextureCoordinate point='" + EXPECTED_TEXTURE_COORDINATE + "'></TextureCoordinate>" + EOL +
        "\t\t\t\t\t</IndexedFaceSet>" + EOL +
        "\t\t\t\t</shape>" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void tropo3D_writeFaceHTML_withMapIndexMinusOne_omitsAppearanceAndTextureCoordinate () {
    app.htmlOutput = new PrintWriter(captured);

    app.Tropo3D.writeFaceHTML(tropoSubFace(), -1);
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t<shape>" + EOL +
        "\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 -1'>" + EOL +
        "\t\t\t\t\t\t<Coordinate point='" + EXPECTED_COORDINATE + "'></Coordinate>" + EOL +
        "\t\t\t\t\t</IndexedFaceSet>" + EOL +
        "\t\t\t\t</shape>" + EOL;

    assertEquals(expected, captured.toString());
    assertFalse(captured.toString().contains("Appearance"), "n_Map == -1 must skip the Appearance/TextureCoordinate blocks entirely");
  }
}
