import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.StringWriter;
import java.io.PrintWriter;

// Sky3D.writeSkyPatternObjFace()/Sun3D.writeSunPatternObjFace()/
// Sections.writeSectionObjFace()/Sections.writeSectionHTML() - the
// sibling OBJ/HTML vertex writers to the material (.mtl) writers
// MaterialWritersTest.java already covers for these same 3 classes.
// All 4 were previously untested. Same real-PrintWriter-capture
// strategy as ExportFaceWritersTest.java/MaterialWritersTest.java:
// objOutput/htmlOutput point at a real java.io.PrintWriter wrapping a
// StringWriter, to verify exact text output.
class ObjVertexWritersTest {

  private solarchvision_bim app;
  private StringWriter captured;
  private static final String EOL = System.lineSeparator();

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    captured = new StringWriter();
  }

  // ================= Sky3D.writeSkyPatternObjFace ==============================
  // Reverses the winding order on its own first ("solid") line (n1,n4,
  // n3,n2) - distinct from its own double-sided second line (n1,n2,n3,
  // n4) and from Sun3D/Sections' own single/first lines below, which
  // both use the plain n1,n2,n3,n4 order throughout.

  @Test
  void sky3D_writeSkyPatternObjFace_writesBothWindings () {
    app.objOutput = new PrintWriter(captured);
    app.obj_lastVertexNumber = 10;
    app.obj_lastVtextureNumber = 20;
    app.num_vertices_added = 4;
    // User3D.exporterDoubleSided's own bare-construction default (true).

    app.Sky3D.writeSkyPatternObjFace();
    app.objOutput.flush();

    String expected =
        "f 11/21 14/24 13/23 12/22" + EOL +
        "f 11/21 12/22 13/23 14/24" + EOL;

    assertEquals(expected, captured.toString());
  }

  // ================= Sun3D.writeSunPatternObjFace ===============================
  // Always exactly one line (no exporterDoubleSided check at all).

  @Test
  void sun3D_writeSunPatternObjFace_writesOneLine_andIncrementsFaceNumber () {
    app.objOutput = new PrintWriter(captured);
    app.obj_lastVertexNumber = 10;
    app.obj_lastVtextureNumber = 20;
    app.num_vertices_added = 4;
    app.obj_lastFaceNumber = 0;

    app.Sun3D.writeSunPatternObjFace();
    app.objOutput.flush();

    assertEquals("f 11/21 12/22 13/23 14/24" + EOL, captured.toString());
    assertEquals(1, app.obj_lastFaceNumber);
  }

  // ================= Sections.writeSectionObjFace ===============================
  // No num_vertices_added term at all (unlike its Sky3D/Sun3D siblings
  // above) - just obj_lastVertexNumber/obj_lastVtextureNumber directly.

  @Test
  void sections_writeSectionObjFace_writesBothWindings () {
    app.objOutput = new PrintWriter(captured);
    app.obj_lastVertexNumber = 10;
    app.obj_lastVtextureNumber = 20;

    app.allSections.writeSectionObjFace();
    app.objOutput.flush();

    String expected =
        "f 7/17 8/18 9/19 10/20" + EOL +
        "f 7/17 10/20 9/19 8/18" + EOL; // the double-sided line reverses the winding here, unlike Sky3D's own first line doing so

    assertEquals(expected, captured.toString());
  }

  // ================= Sections.writeSectionHTML ===================================
  // subFace's own index 0 is a center point this function never reads
  // (its own coordIndex is hardcoded "0 1 2 3 -1") - only indices 1-4
  // (the 4 real corners) are used, each {x, y, z, u, v}. No clamp01()
  // here (unlike Earth3D/Tropo3D's own writeFaceHTML()), so every u/v
  // below is a plain, already-in-range value.

  @Test
  void sections_writeSectionHTML_writesTheExpectedX3DShapeBlock () {
    app.htmlOutput = new PrintWriter(captured);
    float[][] subFace = {
        {0, 0, 0, 0, 0},       // index 0 - unused
        {1, 2, 3, 0.5f, 0.25f},
        {4, 5, 6, 0.1f, 0.9f},
        {-1, -2, -3, 0.8f, 0.3f},
        {7, 8, 9, 0.2f, 0.6f}
    };

    app.allSections.writeSectionHTML(subFace, "section.png");
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t<shape>" + EOL +
        "\t\t\t\t\t<Appearance USE='section.png'></Appearance>" + EOL +
        "\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>" + EOL +
        "\t\t\t\t\t\t<Coordinate point='1.000000 2.000000 3.000000,4.000000 5.000000 6.000000,-1.000000 -2.000000 -3.000000,7.000000 8.000000 9.000000'></Coordinate>" + EOL +
        "\t\t\t\t\t\t<TextureCoordinate point='0.5000 0.7500,0.1000 0.1000,0.8000 0.7000,0.2000 0.4000'></TextureCoordinate>" + EOL +
        "\t\t\t\t\t</IndexedFaceSet>" + EOL +
        "\t\t\t\t</shape>" + EOL;

    assertEquals(expected, captured.toString());
  }
}
