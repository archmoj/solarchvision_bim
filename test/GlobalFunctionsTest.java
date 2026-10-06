import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.io.IOException;

// global_functions.pde's functions are top-level (not scoped to any
// class), so they're called directly on the app instance - e.g.
// app.deleteAll(), not app.SomeClass.deleteAll() - the same way
// _fileSelected_RunScript() and the other fileSelected.pde functions are
// (see FileSelectedTest.java).
//
// Most of this file turned out callable from a bare, never-setup()'d
// instance: confirmed by hand against the real compiled app that
// WIN3D.revise()/UI_toolBar.revise()/UI_toolBar.highlight() are all plain
// flag/array updates with no WIN3D.graphics involved (the same conclusion
// ModifyGeometryTest.java already reached and relies on elsewhere in this
// suite). The one exception is regenerate_desired_bakings(), which is only
// tested in its no-op shape below - see that test's own comment.
class GlobalFunctionsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= is_defined / is_undefined ====================================

  @Test
  void isDefined_isFalseOnlyForFLOAT_undefined () {
    assertTrue(app.is_defined(5f));
    assertTrue(app.is_defined(-1000000f));
    assertFalse(app.is_defined(app.FLOAT_undefined));
  }

  @Test
  void isUndefined_isTheOppositeOfIsDefined () {
    assertFalse(app.is_undefined(5f));
    assertTrue(app.is_undefined(app.FLOAT_undefined));
  }

  // ================= isInside ========================================================

  @Test
  void isInside_acceptsAPointStrictlyInsideTheRectangle () {
    assertTrue(app.isInside(0.5f, 0.5f, 0, 0, 1, 1));
  }

  @Test
  void isInside_rejectsPointsOnOrOutsideTheBoundary () {
    // Strict inequalities (x1 < x < x2, not <=) - a point exactly on an
    // edge or corner doesn't count as inside.
    assertFalse(app.isInside(0f, 0f, 0, 0, 1, 1), "corner");
    assertFalse(app.isInside(0.5f, 0f, 0, 0, 1, 1), "on an edge");
    assertFalse(app.isInside(1.5f, 0.5f, 0, 0, 1, 1), "outside");
  }

  // ================= applyPalDirection ===============================================

  @Test
  void applyPalDirection_appliesEachDirectionsOwnTransform () {
    assertEquals(0.7f, app.applyPalDirection(0.3f, -1), 0.0001f); // 1-u
    assertEquals(0.35f, app.applyPalDirection(0.3f, -2), 0.0001f); // 0.5-0.5u
    assertEquals(0.15f, app.applyPalDirection(0.3f, 2), 0.0001f); // 0.5u
    assertEquals(0.3f, app.applyPalDirection(0.3f, 1), 0.0001f); // anything else: unchanged
    assertEquals(0.3f, app.applyPalDirection(0.3f, 0), 0.0001f);
  }

  // ================= deleteAll ========================================================

  @Test
  void deleteAll_clearsEveryModelCollection () {
    app.allModel1Ds.makeEmpty(1);
    app.allModel2Ds.makeEmpty(1);
    app.allPolylines.makeEmpty(1);
    app.allFaces.makeEmpty(1);
    app.allPoints.makeEmpty(1);
    app.allSolids.makeEmpty(1);
    app.allSections.makeEmpty(1);
    app.allCameras.makeEmpty(1);
    app.allGroups.makeEmpty(1);

    app.deleteAll();

    assertEquals(0, app.allModel1Ds.num);
    assertEquals(0, app.allModel2Ds.num);
    assertEquals(0, app.allPolylines.nodes.length);
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPoints.getLength());
    assertEquals(0, app.allSolids.DEF.length);
    assertEquals(0, app.allSections.num);
    // Not 0: Cameras.makeEmpty() (see Cameras.pde) always calls
    // add_first() afterward, so there's always at least one camera - a
    // default "home" view - confirmed by hand against the real compiled
    // app, since this.num starting at 0 and jumping back to 1 isn't
    // obvious just from reading deleteAll() itself.
    assertEquals(1, app.allCameras.num);
    assertEquals(0, app.allGroups.num);
  }

  // ================= model_added / model_changed / view_changed / ===================
  // ================= selection_changed / switch_category =============================
  // All plain flag updates - WIN3D.revise()/UI_toolBar.revise() just set a
  // boolean (see Sun3DTest.java's own class comment on the identical
  // conclusion for WIN3D.graphics more broadly), nothing graphics-related.

  @Test
  void viewChanged_setsWIN3DsUpdateFlag () {
    app.WIN3D.update = false;

    app.view_changed();

    assertTrue(app.WIN3D.update);
  }

  @Test
  void modelChanged_setsShouldRebuildFaceGridAndTriggersAViewChange () {
    app.should_rebuildFaceGrid = false;
    app.WIN3D.update = false;

    app.model_changed();

    assertTrue(app.should_rebuildFaceGrid);
    assertTrue(app.WIN3D.update);
  }

  @Test
  void modelAdded_andSelectionChanged_runWithoutThrowing () {
    // Select3D.selectLast()/reset_selectedRefValues()/revise_BoundingBox()
    // are plain array/bookkeeping logic too - confirmed by hand, not
    // independently re-verified field-by-field here since that's
    // Select3D's own responsibility, not global_functions.pde's.
    assertDoesNotThrow(() -> app.model_added());
    assertDoesNotThrow(() -> app.selection_changed());
  }

  @Test
  void switchCategory_setsTheCategoryAndRevisesTheToolbar () {
    app.currentObjectCategory = app.ObjectCategory.FACE;

    app.switch_category(app.ObjectCategory.GROUP);

    assertEquals(app.ObjectCategory.GROUP, app.currentObjectCategory);
  }

  // ================= modify_Viewport_Title ============================================

  @Test
  void modifyViewportTitle_labelsTheViewportWithTheCurrentCameraIndex () {
    app.WIN3D.currentCameraIndex = 3;

    app.modify_Viewport_Title();

    assertEquals("Cam03", app.UI_toolBar.Items[0][11]);
  }

  // ================= find_which_bakings_to_regenerate =================================

  @Test
  void findWhichBakingsToRegenerate_flagsGlobalSolar_whenThatsTheActiveShadingMode () {
    app.GlobalSolar_rebuild_array = false;
    app.WIN3D.shadingMode = app.SHADE.Global_Solar;

    app.find_which_bakings_to_regenerate();

    assertTrue(app.GlobalSolar_rebuild_array);
  }

  @Test
  void findWhichBakingsToRegenerate_flagsVertexSolar_whenThatsTheActiveShadingMode () {
    app.VertexSolar_rebuild_array = false;
    app.WIN3D.shadingMode = app.SHADE.Vertex_Solar;

    app.find_which_bakings_to_regenerate();

    assertTrue(app.VertexSolar_rebuild_array);
  }

  @Test
  void findWhichBakingsToRegenerate_leavesBothFlagsAlone_forAnUnrelatedShadingMode () {
    app.GlobalSolar_rebuild_array = false;
    app.VertexSolar_rebuild_array = false;
    app.WIN3D.shadingMode = app.SHADE.Surface_Base;

    app.find_which_bakings_to_regenerate();

    assertFalse(app.GlobalSolar_rebuild_array);
    assertFalse(app.VertexSolar_rebuild_array);
  }

  // ================= regenerate_desired_bakings ========================================

  @Test
  void regenerateDesiredBakings_isANoOp_whenNeitherFlagIsSet () {
    // Not exercising the actual rebuild paths here - calculate_
    // VertexSolar_array()/calculate_GlobalSolar_array() iterate real
    // scene data and belong to their own files, not global_functions.pde;
    // this just confirms the dispatcher itself doesn't do anything
    // unexpected when there's nothing to regenerate.
    app.VertexSolar_rebuild_array = false;
    app.GlobalSolar_rebuild_array = false;

    assertDoesNotThrow(() -> app.regenerate_desired_bakings());
  }

  // ================= VertexSolar_resize_array ===========================================

  @Test
  void vertexSolarResizeArray_sizesAmountsToTheStudyDayRange_andClearsTheRebuildFlag () {
    app.STUDY.startDay = 10;
    app.STUDY.endDay = 15;
    app.VertexSolar_rebuild_array = true;

    app.VertexSolar_resize_array();

    assertEquals(0, app.VertexSolar_XYZ.length);
    assertEquals(2, app.VertexSolar_amounts.length);
    assertEquals(1 + 15 - 10, app.VertexSolar_amounts[0].length);
    assertFalse(app.VertexSolar_rebuild_array);
  }

  // ================= OBJprintVertex / OBJprintVtexture / HTMLprintVtexture =============

  @Test
  void objPrintVertex_writesXYZInOrder_whenYAxisUpIsOff () throws IOException {
    Path path = Files.createTempFile("global-functions-obj-test", ".obj");
    app.objOutput = app.createWriter(path.toString());
    app.User3D.exporterYaxisUp = 0;
    app.User3D.exporterScale = 1;

    app.OBJprintVertex(1, 2, 3);
    app.objOutput.flush();
    app.objOutput.close();

    String content = Files.readString(path);
    assertTrue(content.contains("v 1.000000 2.000000 3.000000"), content);
  }

  @Test
  void objPrintVertex_swapsYAndZ_whenYAxisUpIsOn () throws IOException {
    Path path = Files.createTempFile("global-functions-obj-yup-test", ".obj");
    app.objOutput = app.createWriter(path.toString());
    app.User3D.exporterYaxisUp = 1;
    app.User3D.exporterScale = 1;

    app.OBJprintVertex(1, 2, 3);
    app.objOutput.flush();
    app.objOutput.close();

    // -x, z, y
    String content = Files.readString(path);
    assertTrue(content.contains("v -1.000000 3.000000 2.000000"), content);
  }

  @Test
  void objPrintVtexture_writesUVW () throws IOException {
    Path path = Files.createTempFile("global-functions-objvt-test", ".obj");
    app.objOutput = app.createWriter(path.toString());

    app.OBJprintVtexture(0.5f, 0.25f, 0f);
    app.objOutput.flush();
    app.objOutput.close();

    String content = Files.readString(path);
    assertTrue(content.contains("vt 0.5000 0.2500 0.0000"), content);
  }

  @Test
  void htmlPrintVtexture_writesUV () throws IOException {
    Path path = Files.createTempFile("global-functions-htmlvt-test", ".html");
    app.htmlOutput = app.createWriter(path.toString());

    app.HTMLprintVtexture(0.5f, 0.25f);
    app.htmlOutput.flush();
    app.htmlOutput.close();

    String content = Files.readString(path);
    assertTrue(content.contains("0.5000 0.2500"), content);
  }
}
