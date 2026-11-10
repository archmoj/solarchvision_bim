import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportRadiance() drives .draw(TypeWindow.RAD3D) across Terrain and
// allFaces, then writes a companion .bat invoking Radiance's own oconv/
// rvu tools - like exportObj()'s own OBJ3D pass (see
// ExportObjectsOBJTest.java's own comment on why that's safe), the
// RAD3D branch of allFaces.draw() just writes plain text to radOutput,
// walking this.nodes directly (no allGroups dependency, unlike
// exportHtml()'s HTML branch - see ExportHtmlTest.java's own comment on
// that difference), so it's directly callable from a bare instance.
// Terrain.shouldDraw() returns false by default (displaySurface is
// false - see ExportObjectsOBJTest.java's own comment), so it
// contributes nothing here either.
//
// The .bat file's "rvu" command line also reads WIN3D.dX/dY (through
// atan_ang()) to compute its own "-vh" (horizontal field of view)
// argument - WIN3D.dX and dY both default to 0 (pixel_W/pixel_H, never
// set without a real setup()), so that one argument is a literal "NaN"
// on a bare, never-setup()'d instance exactly as it would be read back
// by Radiance - confirmed directly below. Nothing here works around or
// papers over that; it is simply what exportRadiance() currently writes
// for an instance that was never shown a window.
class ExportRadianceTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
    app.update_project_folders(); // Folder_Export3D is null until this runs - see ExportObjectsOBJTest.java's own identical comment
  }

  private void createOneTriangle (int material) {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.current_Material = material;
    app.allFaces.create(new int[]{ p0, p1, p2 });
  }

  private String exportRad () throws IOException {
    app.exportRadiance();
    return Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + ".rad"));
  }

  private String exportBat () throws IOException {
    app.exportRadiance();
    return Files.readString(Path.of(app.Folder_Export3D, app.ProjectName + ".bat"));
  }

  @Test
  void exportRadiance_createsBothARadAndABatFile () throws IOException {
    app.exportRadiance();

    Path radFile = Path.of(app.Folder_Export3D, app.ProjectName + ".rad");
    Path batFile = Path.of(app.Folder_Export3D, app.ProjectName + ".bat");
    assertTrue(Files.exists(radFile), "expected " + radFile + " to exist");
    assertTrue(Files.exists(batFile), "expected " + batFile + " to exist");

    String content = Files.readString(radFile);
    assertTrue(content.startsWith("#SOLARCHVISION"), content);
  }

  @Test
  void exportRadiance_withNoFaces_stillWritesTheElevenGenskyLines () throws IOException {
    // One "!gensky" line per 15-degree step from 15 up to (but not
    // including) 180 - i.e. 15, 30, ..., 165: 11 lines, regardless of
    // scene content.
    String content = exportRad();

    long genskyLines = content.lines().filter(l -> l.startsWith("!gensky")).count();
    assertEquals(11, genskyLines, content);
    assertTrue(content.contains("!gensky -ang 15 45 +s -trb 4.0"), content);
    assertTrue(content.contains("!gensky -ang 165 45 +s -trb 4.0"), content);
    assertFalse(content.contains("!gensky -ang 180"), content);
  }

  @Test
  void exportRadiance_writesOneMaterialDefinition_perUsedMaterial_withItsRGB () throws IOException {
    // allMaterials.Color[5] is the fixed {255, 0, 0, 255} (ARGB) entry -
    // see materials.pde's own fixed[] table - so SurfaceMaterial5's
    // "void plastic" line is expected to read r=0.0000 g=0.0000
    // b=1.0000 (each channel divided by 255), confirmed directly
    // against the real compiled app before writing this assertion.
    createOneTriangle(5);

    String content = exportRad();

    assertTrue(content.contains("void plastic SurfaceMaterial5\n0\n0\n5 0.0000 0.0000 1.0000 0 0"), content);
    // Only material 5 was ever used, so no other "void plastic" line is
    // written - mirrors ExportObjectsOBJTest's own used_Materials[]
    // coverage for the .mtl side of exportObj().
    long materialLines = content.lines().filter(l -> l.startsWith("void plastic")).count();
    assertEquals(1, materialLines, content);
  }

  @Test
  void exportRadiance_writesOnePolygonFaceBlock_perSide_forANonZeroMaterialTriangle () throws IOException {
    // material != 0 and tessellation == 0 (the create() default) means
    // no subdivision, and 3 nodes means no second (quad-completing)
    // polygon block - User3D.exporterDoubleSided defaults to true, so
    // a double-sided export of one triangle is exactly 2 "polygon FACE"
    // blocks, one per side - the same reasoning as
    // ExportObjectsOBJTest.exportObj_writesOneFacePerSide_....
    createOneTriangle(5);

    String content = exportRad();

    long faceBlocks = content.lines().filter(l -> l.equals("SurfaceMaterial5 polygon FACE")).count();
    assertEquals(2, faceBlocks, content);
    assertTrue(content.contains("9\n 0.000000 0.000000 0.000000\n 1.000000 1.000000 0.000000\n 1.000000 0.000000 0.000000"), content);
    assertTrue(content.contains("9\n 0.000000 0.000000 0.000000\n 1.000000 0.000000 0.000000\n 1.000000 1.000000 0.000000"), content);
  }

  @Test
  void exportRadiance_appliesExtraSubdivision_whenTheFacesMaterialIsZero () throws IOException {
    // Same material-0 subdivision rule as
    // ExportObjectsOBJTest.exportObj_appliesExtraSubdivision_...:
    // material 0 gets Faces.displayTessellation (2 by default) added
    // to its export tessellation, so totalNumberOfSubs becomes
    // nodes[f].length * 4^(tessellation-1) = 3 * 4^1 = 12 per side (24
    // across both sides, with exporterDoubleSided's own default of
    // true) - the same per-sub/per-side count that test pins for the
    // OBJ3D case.
    //
    // Unlike OBJ3D (OBJ natively supports a 4-vertex face as a single
    // "f" line), RAD3D's own branch always writes a 3-vertex Radiance
    // "polygon", so subFace.length == 4 - confirmed directly against
    // the real compiled app to be exactly what funcs.getSubFace()
    // returns here for every one of this triangle's 12 subdivided
    // chunks, not just some of them - triggers the SECOND "polygon
    // FACE" block that completes the quad (exportRad.pde's own "if
    // (subFace.length == 4)" branch). That doubles 24 to 48.
    createOneTriangle(0);

    String content = exportRad();

    long faceBlocks = content.lines().filter(l -> l.equals("SurfaceMaterial0 polygon FACE")).count();
    assertEquals(48, faceBlocks, content);
  }

  @Test
  void exportRadiance_batFile_invokesOconvThenRvu_pointingAtTheRadAndOctFiles () throws IOException {
    String content = exportBat();
    String[] lines = content.split("\r?\n", -1);

    Path radFile = Path.of(app.Folder_Export3D, app.ProjectName + ".rad");
    Path octFile = Path.of(app.Folder_Export3D, app.ProjectName + ".oct");

    assertEquals("oconv " + radFile + " > " + octFile, lines[0]);
    assertTrue(lines[1].startsWith("rvu -vtv "), lines[1]);
    assertTrue(lines[1].contains("-vv 90"), lines[1]); // WIN3D.zoom's own default
    assertTrue(lines[1].contains("-vp 0 0 0"), lines[1]); // WIN3D.cameraX/Y/Z all default to 0
    assertTrue(lines[1].contains("-av 0.5 0.5 0.5 -pe 0.001 -ab 1 "), lines[1]);
    // The backslash-separated .oct path (Windows-style, via
    // '/'->char(92) - see exportRad.pde's own Command2 assembly) is the
    // command's own last argument.
    assertTrue(lines[1].endsWith(octFile.toString().replace('/', '\\')), lines[1]);
    assertEquals("cmd /k", lines[2]);
  }

  @Test
  void exportRadiance_batFile_vhArgument_isNaN_onABareNeverSetupInstance () throws IOException {
    // See this file's own header comment: WIN3D.dX and WIN3D.dY both
    // default to 0 (pixel_W/pixel_H), so WIN3D.dX / float(WIN3D.dY) is
    // 0 / 0.0, which is NaN in Java - exportRad.pde's own "-vh" argument
    // propagates that NaN straight through nf() rather than guarding
    // against it. Pinned here as current, confirmed behavior rather
    // than silently relied upon elsewhere.
    String content = exportBat();

    assertTrue(content.contains("-vh NaN "), content);
  }
}
