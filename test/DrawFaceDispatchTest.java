import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.StringWriter;
import java.io.PrintWriter;

// Tropo3D.drawFace()/Earth3D.drawFace() are thin dispatchers: for
// target_window HTML or OBJ3D they call writeFaceHTML()/writeFaceOBJ()
// (both already independently verified directly in
// ExportFaceWritersTest.java/FaceObjWritersTest.java); for WORLD or
// WIN3D they call writeFaceWORLD()/writeFaceWIN3D() instead, both real
// graphics (WORLD.graphics/WIN3D.graphics) and out of scope here, the
// same category as every other *_graphics-dependent function this
// session has confirmed unreachable headlessly.
//
// Reuses the exact same subFace construction and expected output
// strings those two files already established for the HTML/OBJ3D cases
// - the point of this file is confirming drawFace()'s own routing picks
// the right writer for a given target_window, not re-verifying what
// each writer itself produces.
class DrawFaceDispatchTest {

  private solarchvision_bim app;
  private StringWriter captured;
  private static final String EOL = System.lineSeparator();

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    captured = new StringWriter();
  }

  // ================= Tropo3D.drawFace ==========================================

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
  void tropo3D_drawFace_htmlTarget_dispatchesToWriteFaceHTML () {
    app.htmlOutput = new PrintWriter(captured);

    app.Tropo3D.drawFace(app.TypeWindow.HTML, tropoSubFace(), 5, 0, 0);
    app.htmlOutput.flush();

    // Same expected block as ExportFaceWritersTest.java's own
    // tropo3D_writeFaceHTML_withARealMapIndex_... test (n_Map = 5).
    String expected =
        "\t\t\t\t<shape>" + EOL +
        "\t\t\t\t\t<Appearance USE='TropoSphere5'></Appearance>" + EOL +
        "\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 -1'>" + EOL +
        "\t\t\t\t\t\t<Coordinate point='1.000000 2.000000 3.000000,4.000000 5.000000 6.000000,-1.000000 -2.000000 -3.000000'></Coordinate>" + EOL +
        "\t\t\t\t\t\t<TextureCoordinate point='0.5000 0.7500,0.1000 0.1000,1.0000 1.0000'></TextureCoordinate>" + EOL +
        "\t\t\t\t\t</IndexedFaceSet>" + EOL +
        "\t\t\t\t</shape>" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void tropo3D_drawFace_obj3DTarget_turn1_dispatchesToWriteFaceOBJ () {
    app.objOutput = new PrintWriter(captured);

    app.Tropo3D.drawFace(app.TypeWindow.OBJ3D, tropoSubFace(), 5, 0, 1);
    app.objOutput.flush();

    // Same "v" lines FaceObjWritersTest.java's own tropo3D_writeFaceOBJ_turn1
    // test expects, for a 3rd vertex (-1,-2,-3) too: exporterYaxisUp == 1
    // -> "v " + (-x) + " " + z + " " + y.
    String expected =
        "v -1.000000 3.000000 2.000000" + EOL +
        "v -4.000000 6.000000 5.000000" + EOL +
        "v 1.000000 -3.000000 -2.000000" + EOL;

    assertEquals(expected, captured.toString());
  }

  // ================= Earth3D.drawFace ==========================================

  private solarchvision_bim.Earth3D.FaceVertex[] earthSubFace () {
    solarchvision_bim.Earth3D.FaceVertex[] subFace = new solarchvision_bim.Earth3D.FaceVertex[3];
    subFace[0] = app.Earth3D.new FaceVertex();
    subFace[0].x = 1; subFace[0].y = 2; subFace[0].z = 3; subFace[0].u = 0.5f; subFace[0].v = 0.25f;
    subFace[1] = app.Earth3D.new FaceVertex();
    subFace[1].x = 4; subFace[1].y = 5; subFace[1].z = 6; subFace[1].u = 0.1f; subFace[1].v = 0.9f;
    subFace[2] = app.Earth3D.new FaceVertex();
    subFace[2].x = -1; subFace[2].y = -2; subFace[2].z = -3; subFace[2].u = 1.5f; subFace[2].v = -0.5f;
    return subFace;
  }

  @Test
  void earth3D_drawFace_htmlTarget_dispatchesToWriteFaceHTML () {
    app.htmlOutput = new PrintWriter(captured);

    app.Earth3D.drawFace(app.TypeWindow.HTML, earthSubFace(), "myTexture", 0, 0);
    app.htmlOutput.flush();

    // Same expected block as ExportFaceWritersTest.java's own
    // earth3D_writeFaceHTML_... test.
    String expected =
        "\t\t\t\t<shape>" + EOL +
        "\t\t\t\t\t<Appearance USE='myTexture'></Appearance>" + EOL +
        "\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 -1'>" + EOL +
        "\t\t\t\t\t\t<Coordinate point='1.000000 2.000000 3.000000,4.000000 5.000000 6.000000,-1.000000 -2.000000 -3.000000'></Coordinate>" + EOL +
        "\t\t\t\t\t\t<TextureCoordinate point='0.5000 0.7500,0.1000 0.1000,1.0000 1.0000'></TextureCoordinate>" + EOL +
        "\t\t\t\t\t</IndexedFaceSet>" + EOL +
        "\t\t\t\t</shape>" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void earth3D_drawFace_obj3DTarget_turn1_dispatchesToWriteFaceOBJ () {
    app.objOutput = new PrintWriter(captured);

    app.Earth3D.drawFace(app.TypeWindow.OBJ3D, earthSubFace(), "myTexture", 0, 1);
    app.objOutput.flush();

    String expected =
        "v -1.000000 3.000000 2.000000" + EOL +
        "v -4.000000 6.000000 5.000000" + EOL +
        "v 1.000000 -3.000000 -2.000000" + EOL;

    assertEquals(expected, captured.toString());
  }
}
