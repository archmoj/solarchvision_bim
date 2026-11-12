import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.StringWriter;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;

// Sky3D.writeSkyPatternMaterial()/Sun3D.writeSunPatternMaterial()
// (identically-shaped - one per celestial-body tab) and Sections.
// writeSectionMaterial() are the remaining writers in the OBJ/HTML/MTL
// export pipeline (ExportFaceWritersTest.java already covers Earth3D/
// Tropo3D's own face writers). All three were untested. Same real-
// PrintWriter-capture strategy as that file: htmlOutput/objOutput/
// mtlOutput are all top-level PrintWriter fields, null until something
// opens a real export file, so each test here points the relevant one
// at a real java.io.PrintWriter wrapping a StringWriter to verify exact
// text output.
//
// The two palette writers additionally save a real PNG texture to disk
// (PImage.save(), off a palette image built via createImage() - already
// confirmed headlessly safe by resize_Image_array() elsewhere this
// session) - so those two point texturePath at a real temp file rather
// than a fake path, and confirm the file actually gets written, not
// just that the MTL text is right.
//
// writeSectionMaterial()'s own image-save step is deliberately skipped
// by setting both allSolarImpacts.displayImage and allSolidImpacts.
// displayImage to false first - the latter's own bare-construction
// default is actually true (confirmed by reading solidImpacts.pde's own
// field declaration, not assumed), and its SolidImpact[] array isn't
// populated by this test, so leaving that default in place would risk
// the exact kind of NullPointerException-from-an-unverified-default a
// previous round this session already hit once for a different function.
class MaterialWritersTest {

  private solarchvision_bim app;
  private StringWriter captured;
  private static final String EOL = System.lineSeparator();

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
    app.sketchPath(); // see LoadClimateTypicalYearTest.java's own comment on why
    captured = new StringWriter();
  }

  private String expectedMtlBlock (String matName, String filename) {
    return
        "newmtl " + matName + EOL +
        "\tilum 2" + EOL +
        "\tKa 1.000 1.000 1.000" + EOL +
        "\tKd 1.000 1.000 1.000" + EOL +
        "\tKs 0.000 0.000 0.000" + EOL +
        "\tNs 10.00" + EOL +
        "\tNi 1.500" + EOL +
        "\td 1.000" + EOL +
        "\tTr 1.000" + EOL +
        "\tTf 1.000 1.000 1.000" + EOL +
        "\tmap_Kd " + app.Subfolder_exportMaps + filename + EOL;
  }

  // ================= Sky3D.writeSkyPatternMaterial ============================

  @Test
  void sky3D_writeSkyPatternMaterial_writesTheMtlBlockAndSavesARealTexture () throws Exception {
    app.mtlOutput = new PrintWriter(captured);
    Path tempPng = Files.createTempFile("sky-palette", ".png");
    tempPng.toFile().deleteOnExit();

    app.Sky3D.writeSkyPatternMaterial(0, "sky.png", tempPng.toString());
    app.mtlOutput.flush();

    assertEquals(expectedMtlBlock("sky_png", "sky.png"), captured.toString());
    assertTrue(Files.size(tempPng) > 0, "a real PNG must have been written to the temp path");
  }

  // ================= Sun3D.writeSunPatternMaterial ============================

  @Test
  void sun3D_writeSunPatternMaterial_writesTheMtlBlockAndSavesARealTexture () throws Exception {
    app.mtlOutput = new PrintWriter(captured);
    Path tempPng = Files.createTempFile("sun-palette", ".png");
    tempPng.toFile().deleteOnExit();

    app.Sun3D.writeSunPatternMaterial(0, "sun.png", tempPng.toString());
    app.mtlOutput.flush();

    assertEquals(expectedMtlBlock("sun_png", "sun.png"), captured.toString());
    assertTrue(Files.size(tempPng) > 0, "a real PNG must have been written to the temp path");
  }

  // ================= Sections.writeSectionMaterial =============================

  @Test
  void sections_writeSectionMaterial_htmlTarget_writesTheAppearanceBlock () {
    app.allSolarImpacts.displayImage = false;
    app.allSolidImpacts.displayImage = false; // its own bare-construction default is true - see this file's own header comment
    app.htmlOutput = new PrintWriter(captured);

    app.allSections.writeSectionMaterial(0, app.TypeWindow.HTML, "section.png");
    app.htmlOutput.flush();

    String expected =
        "\t\t\t\t<Appearance DEF='section.png'>" + EOL +
        "\t\t\t\t\t<ImageTexture url='" + app.Subfolder_exportMaps + "section.png'><ImageTexture/>" + EOL +
        "\t\t\t\t</Appearance>" + EOL;

    assertEquals(expected, captured.toString());
  }

  @Test
  void sections_writeSectionMaterial_obj3DTarget_writesTheMtlBlock () {
    app.allSolarImpacts.displayImage = false;
    app.allSolidImpacts.displayImage = false;
    app.mtlOutput = new PrintWriter(captured);

    app.allSections.writeSectionMaterial(0, app.TypeWindow.OBJ3D, "section.png");
    app.mtlOutput.flush();

    assertEquals(expectedMtlBlock("section_png", "section.png"), captured.toString());
  }

  @Test
  void sections_writeSectionMaterial_withNeitherTargetWindow_writesNothing () {
    app.allSolarImpacts.displayImage = false;
    app.allSolidImpacts.displayImage = false;
    app.htmlOutput = new PrintWriter(captured);
    app.mtlOutput = new PrintWriter(captured);

    // WIN3D (the live viewport, not an export target at all) matches
    // neither "if" guard - confirms the HTML/OBJ3D checks are two
    // genuinely independent "if" statements, not an if/else-if pair
    // where one of them always writes something.
    app.allSections.writeSectionMaterial(0, app.TypeWindow.WIN3D, "section.png");
    app.htmlOutput.flush();
    app.mtlOutput.flush();

    assertEquals("", captured.toString());
  }
}
