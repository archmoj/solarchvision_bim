import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_IFC() is a plain STEP(.ifc)-format text parser plus calls
// to Create3D.add_Mesh() (itself allPoints.create()/allFaces.create()/
// model_changed()/model_added()) and allGroups.beginNewGroup() - no
// WIN3D.graphics, no PImage - so, like ImportObjectsOBJTest.java's own
// import_objects_OBJ() tests, this is directly testable from a bare,
// never-setup()'d instance with no extra seeding.
//
// Each test below writes the smallest STEP snippet that exercises one
// path, rather than a realistic whole-building export - see
// import_objects_IFC.pde's own file-header comment for exactly which
// IFC entities/attributes each path corresponds to, and for the
// documented limitations (holes, curves, booleans, IfcMappedItem) a
// couple of tests below confirm are skipped-and-counted, not silently
// guessed around.
class ImportObjectsIFCTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path ifcFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".ifc");
    Files.writeString(f, body);
    return f;
  }

  // ================= IfcFacetedBrep (straight-edged B-rep) ===================

  @Test
  void importObjectsIFC_facetedBrep_importsOneQuadFace_keptAsAnNgonNotTriangulated () throws IOException {
    Path f = ifcFile("ifc-facetedbrep-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "the one IfcFace should have become exactly one face");
    assertEquals(4, app.allFaces.nodes[0].length, "a 4-point IfcPolyLoop should stay a quad, not split into triangles");
    assertEquals(4, app.allPoints.getLength());

    float[][] expected = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};
    for (int i = 0; i < 4; i++) {
      assertEquals(expected[i][0], app.allPoints.getX(i), 0.0001f, "point " + i);
      assertEquals(expected[i][1], app.allPoints.getY(i), 0.0001f, "point " + i);
      assertEquals(expected[i][2], app.allPoints.getZ(i), 0.0001f, "point " + i);
    }
  }

  @Test
  void importObjectsIFC_faceOuterBound_withFalseOrientation_reversesTheLoop () throws IOException {
    Path f = ifcFile("ifc-orientation-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.F.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // .F. orientation reverses the loop, so the first vertex created
    // should be the *last* point of the original IfcPolyLoop (0,1,0).
    assertEquals(0f, app.allPoints.getX(0), 0.0001f);
    assertEquals(1f, app.allPoints.getY(0), 0.0001f);
    assertEquals(0f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsIFC_faceBound_innerLoopIsCutOutOfTheOuterLoop () throws IOException {
    Path f = ifcFile("ifc-hole-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((4.,0.,0.));
        #3=IFCCARTESIANPOINT((4.,4.,0.));
        #4=IFCCARTESIANPOINT((0.,4.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCCARTESIANPOINT((1.,1.,0.));
        #8=IFCCARTESIANPOINT((2.,1.,0.));
        #9=IFCCARTESIANPOINT((2.,2.,0.));
        #10=IFCCARTESIANPOINT((1.,2.,0.));
        #11=IFCPOLYLOOP((#7,#8,#9,#10));
        #12=IFCFACEBOUND(#11,.T.);
        #13=IFCFACE((#6,#12));
        #14=IFCCLOSEDSHELL((#13));
        #15=IFCFACETEDBREP(#14);
        #16=IFCSHAPEREPRESENTATION($,'Body','Brep',(#15));
        #17=IFCPRODUCTDEFINITIONSHAPE($,$,(#16));
        #18=IFCWALL('guid-1',$,$,$,$,$,#17);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // PolygonHoles bridges the 1x1 hole into the 4x4 outer square with a
    // single slit, so this is still one face, just with 4 (outer) + 4
    // (hole) + 2 (the duplicated bridge endpoints) = 10 vertices now,
    // instead of simply dropping the hole's own 4.
    assertEquals(1, app.allFaces.nodes.length, "the hole is bridged into the same single face, not split into a second one");
    assertEquals(10, app.allFaces.nodes[0].length);
    assertEquals(1, app.ifcImportHolesCutCount, "the inner IfcFaceBound should be counted as an actually-cut hole");

    // Both loops are given .T. (use as-is), and (1,1)->(2,1)->(2,2)->(1,2)
    // winds the same way (counterclockwise) as the outer square, so
    // PolygonHoles should have reversed the hole before bridging it in -
    // see PolygonHoles' own comment on winding. The nearest valid
    // outer-to-hole pair is corner (0,0) to hole-vertex (1,1).
    float[][] expected = {
      {0, 0, 0}, {1, 1, 0}, {1, 2, 0}, {2, 2, 0}, {2, 1, 0}, {1, 1, 0}, {0, 0, 0}, {4, 0, 0}, {4, 4, 0}, {0, 4, 0}
    };
    for (int i = 0; i < expected.length; i++) {
      assertEquals(expected[i][0], app.allPoints.getX(i), 0.0001f, "point " + i + " x");
      assertEquals(expected[i][1], app.allPoints.getY(i), 0.0001f, "point " + i + " y");
      assertEquals(expected[i][2], app.allPoints.getZ(i), 0.0001f, "point " + i + " z");
    }
  }

  // ================= IfcLocalPlacement / IfcAxis2Placement3D =================

  @Test
  void importObjectsIFC_objectPlacement_translatesEveryPointOfTheProduct () throws IOException {
    Path f = ifcFile("ifc-placement-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #20=IFCCARTESIANPOINT((10.,20.,30.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCLOCALPLACEMENT($,#21);
        #12=IFCWALL('guid-1',$,$,$,$,#22,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    float[] expectedX = {10, 11, 11, 10};
    float[] expectedY = {20, 20, 21, 21};
    for (int i = 0; i < 4; i++) {
      assertEquals(expectedX[i], app.allPoints.getX(i), 0.0001f, "point " + i);
      assertEquals(expectedY[i], app.allPoints.getY(i), 0.0001f, "point " + i);
      assertEquals(30f, app.allPoints.getZ(i), 0.0001f, "point " + i);
    }
  }

  // ================= IfcPolygonalFaceSet (tessellated geometry) ==============

  @Test
  void importObjectsIFC_polygonalFaceSet_sharedPointPool_importsAQuadFace () throws IOException {
    Path f = ifcFile("ifc-polygonalfaceset-test", """
        #1=IFCCARTESIANPOINTLIST3D(((0.,0.,0.),(1.,0.,0.),(1.,1.,0.),(0.,1.,0.)));
        #2=IFCINDEXEDPOLYGONALFACE((1,2,3,4));
        #3=IFCPOLYGONALFACESET(#1,.F.,(#2),$);
        #4=IFCSHAPEREPRESENTATION($,'Body','Tessellation',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCWALL('guid-1',$,$,$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length, "the 1-based CoordIndex list should stay a quad");
  }

  @Test
  void importObjectsIFC_polygonalFaceSet_indexedPolygonalFaceWithVoids_cutsTheVoidsOut () throws IOException {
    // Mirrors the real shape of a Revit "Tessellation" wall body with
    // window openings - e.g. Ifc4_Revit_ARC.ifc's own Wall #36910, whose
    // single big face is an IFCINDEXEDPOLYGONALFACEWITHVOIDS with five
    // voids - just with one 4x4 face and one 1x1 void, at the same
    // indices (16 outer points then the void's own 4) a real export's
    // own point pool would use.
    Path f = ifcFile("ifc-polygonalfaceset-withvoids-test", """
        #1=IFCCARTESIANPOINTLIST3D(((0.,0.,0.),(4.,0.,0.),(4.,4.,0.),(0.,4.,0.),(1.,1.,0.),(2.,1.,0.),(2.,2.,0.),(1.,2.,0.)));
        #2=IFCINDEXEDPOLYGONALFACEWITHVOIDS((1,2,3,4),((5,6,7,8)));
        #3=IFCPOLYGONALFACESET(#1,.T.,(#2),$);
        #4=IFCSHAPEREPRESENTATION($,'Body','Tessellation',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCWALL('guid-1',$,$,$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "the void is bridged into the same single face, not split into a second one");
    // outer(4) + void(4) + 2 duplicated bridge endpoints = 10 - see
    // PolygonHolesTest for exactly this same shape worked out point by
    // point.
    assertEquals(10, app.allFaces.nodes[0].length);
    assertEquals(1, app.ifcImportHolesCutCount, "the one void should be counted as an actually-cut hole");
  }

  // ================= IfcExtrudedAreaSolid (parametric wall/column/slab) ======

  @Test
  void importObjectsIFC_extrudedRectangleProfile_buildsTwoCapsPlusOneSideFacePerEdge () throws IOException {
    Path f = ifcFile("ifc-extrusion-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2.,4.);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,3.);
        #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCWALL('guid-1',$,$,$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // A 4-edge rectangle profile extruded straight up: 2 end caps + 4
    // side panels, every one of them a single 4-point face - the same
    // shape Create3D.add_Mesh4()/"Mesh4" would build by hand, not a pair
    // of triangles per panel.
    assertEquals(6, app.allFaces.nodes.length);
    for (int[] face : app.allFaces.nodes) {
      assertEquals(4, face.length, "every cap/side of a rectangular extrusion should be a quad");
    }

    boolean sawBottom = false, sawTop = false;
    boolean sawMinX = false, sawMaxX = false, sawMinY = false, sawMaxY = false;
    for (int i = 0; i < app.allPoints.getLength(); i++) {
      if (app.allPoints.getZ(i) < 0.0001f) sawBottom = true;
      if (Math.abs(app.allPoints.getZ(i) - 3f) < 0.0001f) sawTop = true;
      if (Math.abs(app.allPoints.getX(i) + 1f) < 0.0001f) sawMinX = true;
      if (Math.abs(app.allPoints.getX(i) - 1f) < 0.0001f) sawMaxX = true;
      if (Math.abs(app.allPoints.getY(i) + 2f) < 0.0001f) sawMinY = true;
      if (Math.abs(app.allPoints.getY(i) - 2f) < 0.0001f) sawMaxY = true;
    }
    assertTrue(sawBottom && sawTop, "profile should be extruded from z=0 to z=Depth=3");
    assertTrue(sawMinX && sawMaxX, "rectangle should be centered: x in [-XDim/2, XDim/2] = [-1, 1]");
    assertTrue(sawMinY && sawMaxY, "rectangle should be centered: y in [-YDim/2, YDim/2] = [-2, 2]");
  }

  // ================= unsupported geometry: skipped and counted, not guessed ==

  @Test
  void importObjectsIFC_unsupportedRepresentationItem_isSkippedAndCounted_notSilentlyIgnored () throws IOException {
    // IfcRevolvedAreaSolid (a documented limitation - swept/revolved
    // solids other than a straight extrusion aren't evaluated) stands
    // in here for "a representation item type this importer genuinely
    // doesn't handle". IfcBooleanClippingResult/IfcMappedItem used to
    // be that case too, until each gained its own (partial, for
    // booleans) support - a malformed IfcMappedItem or
    // IfcBooleanClippingResult is covered by its own, more specific
    // test instead.
    Path f = ifcFile("ifc-skip-test", """
        #1=IFCARBITRARYCLOSEDPROFILEDEF(.AREA.,$,#2);
        #2=IFCPOLYLINE((#3,#4,#5));
        #3=IFCCARTESIANPOINT((0.,0.));
        #4=IFCCARTESIANPOINT((1.,0.));
        #5=IFCCARTESIANPOINT((1.,1.));
        #6=IFCAXIS1PLACEMENT(#7,$);
        #7=IFCCARTESIANPOINT((0.,0.,0.));
        #8=IFCREVOLVEDAREASOLID(#1,$,#6,3.14159);
        #9=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#8));
        #10=IFCPRODUCTDEFINITIONSHAPE($,$,(#9));
        #11=IFCWALL('guid-1',$,$,$,$,$,#10);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "IfcRevolvedAreaSolid isn't supported, so no geometry should appear");
    assertEquals(1, app.ifcImportSkippedCount);
    assertEquals(Integer.valueOf(1), app.ifcImportSkippedReasons.get("IFCREVOLVEDAREASOLID"));
  }

  // ================= boolean results: uncut-solid fallback ====================

  @Test
  void importObjectsIFC_booleanClippingResult_importsTheUncutFirstOperand () throws IOException {
    Path f = ifcFile("ifc-boolean-clip-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2.,4.);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,3.);
        #4=IFCBOOLEANCLIPPINGRESULT(.DIFFERENCE.,#3,$);
        #5=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#4));
        #6=IFCPRODUCTDEFINITIONSHAPE($,$,(#5));
        #7=IFCWALL('guid-1',$,$,$,$,$,#6);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "the wall's own solid (2 caps + 4 sides) should still import");
    assertEquals(1, app.ifcImportUncutOpeningCount);
    assertEquals(0, app.ifcImportSkippedCount, "an evaluated (if uncut) boolean result isn't an unsupported-item skip");
  }

  @Test
  void importObjectsIFC_plainBooleanResult_behavesTheSameAsTheClippingSubtype () throws IOException {
    Path f = ifcFile("ifc-boolean-result-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2.,4.);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,3.);
        #4=IFCBOOLEANRESULT(.DIFFERENCE.,#3,$);
        #5=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#4));
        #6=IFCPRODUCTDEFINITIONSHAPE($,$,(#5));
        #7=IFCWALL('guid-1',$,$,$,$,$,#6);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length);
    assertEquals(1, app.ifcImportUncutOpeningCount);
  }

  @Test
  void importObjectsIFC_chainedBooleanResults_resolveThroughToTheRealSolid_multipleOpeningsCounted () throws IOException {
    // Two openings cut one after another - a common pattern for a wall
    // with more than one window - chains FirstOperand through two
    // boolean results before reaching the real extrusion.
    Path f = ifcFile("ifc-boolean-chain-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2.,4.);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,3.);
        #4=IFCBOOLEANCLIPPINGRESULT(.DIFFERENCE.,#3,$);
        #5=IFCBOOLEANCLIPPINGRESULT(.DIFFERENCE.,#4,$);
        #6=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#5));
        #7=IFCPRODUCTDEFINITIONSHAPE($,$,(#6));
        #8=IFCWALL('guid-1',$,$,$,$,$,#7);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "should still resolve through both boolean levels to the real solid");
    assertEquals(2, app.ifcImportUncutOpeningCount, "two chained boolean results - two openings not cut");
  }

  @Test
  void importObjectsIFC_malformedBooleanResult_isSkippedAndCounted_notCrashed () throws IOException {
    Path f = ifcFile("ifc-boolean-malformed-test", """
        #1=IFCBOOLEANCLIPPINGRESULT(.DIFFERENCE.);
        #2=IFCSHAPEREPRESENTATION($,'Body','Clipping',(#1));
        #3=IFCPRODUCTDEFINITIONSHAPE($,$,(#2));
        #4=IFCWALL('guid-1',$,$,$,$,$,#3);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.ifcImportSkippedCount);
    assertEquals(0, app.ifcImportUncutOpeningCount, "a malformed boolean result shouldn't count as an evaluated-but-uncut opening");
  }

  // ================= IfcArbitraryClosedProfileDef(IfcIndexedPolyCurve) ========

  @Test
  void importObjectsIFC_indexedPolyCurveProfile_withNoSegments_importsAsAnImplicitPolyline () throws IOException {
    // No Segments attribute (the overwhelmingly common case checked
    // against a real Revit export - every one of its own 610
    // IfcIndexedPolyCurve instances omits it) means an implicit
    // polyline through every point in the shared list, in order. This
    // is the exact root cause of three real objects (a generic floor
    // slab, a roof slab, a curtain-wall panel) that were missing from
    // import despite having perfectly ordinary IfcExtrudedAreaSolid
    // geometry otherwise.
    Path f = ifcFile("ifc-indexedpolycurve-nosegments-test", """
        #1=IFCCARTESIANPOINTLIST2D(((0.,0.),(2.,0.),(2.,1.),(0.,1.)));
        #2=IFCINDEXEDPOLYCURVE(#1,$,.F.);
        #3=IFCARBITRARYCLOSEDPROFILEDEF(.AREA.,$,#2);
        #4=IFCDIRECTION((0.,0.,1.));
        #5=IFCEXTRUDEDAREASOLID(#3,$,#4,3.);
        #6=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#5));
        #7=IFCPRODUCTDEFINITIONSHAPE($,$,(#6));
        #8=IFCWALL('guid-1',$,$,$,$,$,#7);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "4-point rectangle profile: 2 caps + 4 sides");
    assertEquals(0, app.ifcImportSkippedCount);
  }

  @Test
  void importObjectsIFC_indexedPolyCurveProfile_withAnExplicitlyClosedLoop_dedupsTheRepeatedLastPoint () throws IOException {
    // The real roof slab this fix was found from has its point list
    // explicitly repeat the first point at the end - same dedup
    // IfcPolyline already gets.
    Path f = ifcFile("ifc-indexedpolycurve-closedloop-test", """
        #1=IFCCARTESIANPOINTLIST2D(((0.,0.),(2.,0.),(2.,1.),(0.,1.),(0.,0.)));
        #2=IFCINDEXEDPOLYCURVE(#1,$,.F.);
        #3=IFCARBITRARYCLOSEDPROFILEDEF(.AREA.,$,#2);
        #4=IFCDIRECTION((0.,0.,1.));
        #5=IFCEXTRUDEDAREASOLID(#3,$,#4,3.);
        #6=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#5));
        #7=IFCPRODUCTDEFINITIONSHAPE($,$,(#6));
        #8=IFCWALL('guid-1',$,$,$,$,$,#7);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "the repeated closing point should be dropped, still a 4-point rectangle");
  }

  @Test
  void importObjectsIFC_indexedPolyCurveProfile_withExplicitLineIndexSegments_importsCorrectly () throws IOException {
    // Two IfcLineIndex segments sharing a boundary point (index 3) -
    // the shared point must not be duplicated.
    Path f = ifcFile("ifc-indexedpolycurve-segments-test", """
        #1=IFCCARTESIANPOINTLIST2D(((0.,0.),(2.,0.),(2.,1.),(0.,1.)));
        #2=IFCINDEXEDPOLYCURVE(#1,(IFCLINEINDEX((1,2,3)),IFCLINEINDEX((3,4,1))),.F.);
        #3=IFCARBITRARYCLOSEDPROFILEDEF(.AREA.,$,#2);
        #4=IFCDIRECTION((0.,0.,1.));
        #5=IFCEXTRUDEDAREASOLID(#3,$,#4,3.);
        #6=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#5));
        #7=IFCPRODUCTDEFINITIONSHAPE($,$,(#6));
        #8=IFCWALL('guid-1',$,$,$,$,$,#7);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "4 distinct points across 2 line-index segments, boundary point not duplicated: 2 caps + 4 sides");
  }

  @Test
  void importObjectsIFC_indexedPolyCurveProfile_withAnArcIndexSegment_isSkippedNotApproximated () throws IOException {
    Path f = ifcFile("ifc-indexedpolycurve-arc-test", """
        #1=IFCCARTESIANPOINTLIST2D(((0.,0.),(1.,1.),(2.,0.),(1.,-1.)));
        #2=IFCINDEXEDPOLYCURVE(#1,(IFCARCINDEX((1,2,3)),IFCLINEINDEX((3,4,1))),.F.);
        #3=IFCARBITRARYCLOSEDPROFILEDEF(.AREA.,$,#2);
        #4=IFCDIRECTION((0.,0.,1.));
        #5=IFCEXTRUDEDAREASOLID(#3,$,#4,3.);
        #6=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#5));
        #7=IFCPRODUCTDEFINITIONSHAPE($,$,(#6));
        #8=IFCWALL('guid-1',$,$,$,$,$,#7);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "an actual arc segment should be skipped, not approximated as straight");
    assertEquals(1, app.ifcImportSkippedCount);
  }

  @Test
  void importObjectsIFC_indexedPolyCurveProfile_withMissingPointList_isSkippedNotCrashed () throws IOException {
    Path f = ifcFile("ifc-indexedpolycurve-missing-test", """
        #2=IFCINDEXEDPOLYCURVE(#999,$,.F.);
        #3=IFCARBITRARYCLOSEDPROFILEDEF(.AREA.,$,#2);
        #4=IFCDIRECTION((0.,0.,1.));
        #5=IFCEXTRUDEDAREASOLID(#3,$,#4,3.);
        #6=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#5));
        #7=IFCPRODUCTDEFINITIONSHAPE($,$,(#6));
        #8=IFCWALL('guid-1',$,$,$,$,$,#7);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.ifcImportSkippedCount);
  }

  @Test
  void importObjectsIFC_realRoofSlabChain_fromTheUserReportedFile_nowImportsCorrectly () throws IOException {
    // The exact real entity chain for "Basic Roof:Warm Roof -
    // Timber:724430" - reproduced verbatim (ids/coordinates) from the
    // originally-reported file - that this fix was found from: an
    // IfcSlab whose profile is an IfcArbitraryClosedProfileDef over an
    // IfcIndexedPolyCurve, previously missing entirely.
    Path f = ifcFile("ifc-real-roofslab-test", """
        #20=IFCDIRECTION((0.,0.,1.));
        #6=IFCCARTESIANPOINT((0.,0.,0.));
        #131334=IFCLOCALPLACEMENT($,#131360);
        #131360=IFCAXIS2PLACEMENT3D(#6,$,$);
        #484834=IFCAXIS2PLACEMENT3D(#6,$,$);
        #131342=IFCCARTESIANPOINTLIST2D(((-3000.,5899.00000000013),(-3000.,-5899.00000000013),(3000.,-5899.00000000013),(3000.,5899.00000000013),(-3000.,5899.00000000013)));
        #131349=IFCINDEXEDPOLYCURVE(#131342,$,.F.);
        #131350=IFCARBITRARYCLOSEDPROFILEDEF(.AREA.,$,#131349);
        #131351=IFCCARTESIANPOINT((3000.,5899.,0.));
        #131353=IFCAXIS2PLACEMENT3D(#131351,$,$);
        #131354=IFCEXTRUDEDAREASOLID(#131350,#131353,#20,338.000000000001);
        #131355=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#131354));
        #131357=IFCPRODUCTDEFINITIONSHAPE($,$,(#131355));
        #131361=IFCLOCALPLACEMENT(#131334,#484834);
        #131363=IFCSLAB('0LKJKCHUL1kBtnlFXddz6a',#42,'Basic Roof:Warm Roof - Timber:724430',$,'Basic Roof:Warm Roof - Timber',#131361,#131357,'724430',.NOTDEFINED.);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "a rectangular profile (the 5th point repeats the 1st): 2 caps + 4 sides");
    assertEquals(0, app.ifcImportSkippedCount);
  }

  // ================= groups / material cycling (mirrors OBJ's "g" lines) =====

  @Test
  void importObjectsIFC_oneGroupPerImportableProduct () throws IOException {
    Path f = ifcFile("ifc-groups-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCWALL('guid-2',$,$,$,$,$,#11);
        #14=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allGroups.num, "the three IfcWalls (sharing one Representation) should each start their own group");
    assertEquals(3, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsIFC_withMinusOneMaterial_cyclesThroughEightMaterialsOneProductAtATime () throws IOException {
    app.current_Material = 7; // stale value from something else entirely; should have no bearing below

    Path f = ifcFile("ifc-material-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCWALL('guid-2',$,$,$,$,$,#11);
        #14=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.options[0][0]);
    assertEquals(2, app.allFaces.options[1][0]);
    assertEquals(3, app.allFaces.options[2][0]);
  }

  // ================= vertex transform (cx, cy, cz, sx, sy, sz) ===============

  @Test
  void importObjectsIFC_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path f = ifcFile("ifc-transform-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 100, 200, 300, /*sx,sy,sz*/ 2, 2, 2);

    // first vertex is the IfcPolyLoop's own first point, (0,0,0):
    // (cx + sx*0, cy + sy*0, cz + sz*0) = (100, 200, 300)
    assertEquals(100f, app.allPoints.getX(0), 0.0001f);
    assertEquals(200f, app.allPoints.getY(0), 0.0001f);
    assertEquals(300f, app.allPoints.getZ(0), 0.0001f);
  }

  // ================= IfcWindow always draws as glass (Materials.pde 9) =======

  @Test
  void importObjectsIFC_ifcWindow_alwaysGetsMaterial9_insteadOfTheFixedWallMaterial () throws IOException {
    Path f = ifcFile("ifc-window-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWINDOW('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(9, app.allFaces.options[0][0], "IfcWindow should always use material 9, not the fixed wall material (5) or any other shade");
  }

  @Test
  void importObjectsIFC_windowsDontDisruptTheWallMaterialCycle () throws IOException {
    Path f = ifcFile("ifc-window-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCWINDOW('guid-2',$,$,$,$,$,#11);
        #14=IFCWALL('guid-3',$,$,$,$,$,#11);
        #15=IFCWINDOW('guid-4',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // Products are processed in ascending id order: wall(#12), window(#13),
    // wall(#14), window(#15).
    assertEquals(1, app.allFaces.options[0][0], "first wall: material cycle starts at 1");
    assertEquals(9, app.allFaces.options[1][0], "first window: always material 9");
    assertEquals(2, app.allFaces.options[2][0], "second wall: material cycle continues at 2, not disrupted by the window");
    assertEquals(9, app.allFaces.options[3][0], "second window: always material 9");
  }

  // ================= associated IfcMaterial -> Materials.pde named colors ====

  @Test
  void importObjectsIFC_wallWithConcreteMaterial_getsIFC_MATERIAL_CONCRETE () throws IOException {
    Path f = ifcFile("ifc-material-concrete-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCMATERIAL('Concrete, Cast-in-Place');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0], "should match 'Concrete' to IFC_MATERIAL_CONCRETE (11), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_wallWithLayeredMaterial_resolvesThroughMaterialLayerSetUsage () throws IOException {
    // The common real-world path for a wall's material: IfcWall's own
    // IfcRelAssociatesMaterial points at an IfcMaterialLayerSetUsage,
    // which points at an IfcMaterialLayerSet, whose first IfcMaterialLayer
    // finally names an IfcMaterial - "Structural Steel" here, to also
    // confirm the keyword match (not just the chain-walking).
    Path f = ifcFile("ifc-material-layered-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBEAM('guid-1',$,$,$,$,$,#11);
        #30=IFCMATERIAL('Structural Steel');
        #31=IFCMATERIALLAYER(#30,0.2,$);
        #32=IFCMATERIALLAYERSET((#31),$);
        #33=IFCMATERIALLAYERSETUSAGE(#32,.AXIS2.,.POSITIVE.,0.);
        #34=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#33);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(12, app.allFaces.options[0][0], "should resolve through LayerSetUsage->LayerSet->Layer to IFC_MATERIAL_STEEL (12)");
  }

  @Test
  void importObjectsIFC_unmatchedOrAbsentMaterial_fallsBackToTheNormalMaterialChoice () throws IOException {
    Path f = ifcFile("ifc-material-unmatched-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCMATERIAL('Some Custom Finish');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(5, app.allFaces.options[0][0], "no keyword matched, so the fixed material (5) passed in should still be used");
  }

  // ================= units: converted to metres on import ====================

  @Test
  void importObjectsIFC_millimetreProject_convertsCoordinatesToMetres () throws IOException {
    Path f = ifcFile("ifc-units-millimetre-test", """
        #1=IFCSIUNIT(*,.LENGTHUNIT.,.MILLI.,.METRE.);
        #2=IFCUNITASSIGNMENT((#1));
        #3=IFCPROJECT('guid-proj',$,$,$,$,$,$,$,#2);
        #10=IFCCARTESIANPOINT((0.,0.,0.));
        #11=IFCCARTESIANPOINT((1000.,0.,0.));
        #12=IFCCARTESIANPOINT((1000.,1000.,0.));
        #13=IFCCARTESIANPOINT((0.,1000.,0.));
        #14=IFCPOLYLOOP((#10,#11,#12,#13));
        #15=IFCFACEOUTERBOUND(#14,.T.);
        #16=IFCFACE((#15));
        #17=IFCCLOSEDSHELL((#16));
        #18=IFCFACETEDBREP(#17);
        #19=IFCSHAPEREPRESENTATION($,'Body','Brep',(#18));
        #20=IFCPRODUCTDEFINITIONSHAPE($,$,(#19));
        #21=IFCWALL('guid-1',$,$,$,$,$,#20);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // 1000mm face should import as a 1m face.
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(1f, app.allPoints.getX(1), 0.0001f, "1000mm should convert to 1m");
    assertEquals(1f, app.allPoints.getY(2), 0.0001f, "1000mm should convert to 1m");
    assertEquals(0.001f, app.ifcLengthUnitScale, 0.0000001f);
  }

  @Test
  void importObjectsIFC_feetProject_convertsCoordinatesToMetres () throws IOException {
    Path f = ifcFile("ifc-units-feet-test", """
        #1=IFCSIUNIT(*,.LENGTHUNIT.,$,.METRE.);
        #2=IFCMEASUREWITHUNIT(IFCLENGTHMEASURE(0.3048),#1);
        #3=IFCCONVERSIONBASEDUNIT(*,.LENGTHUNIT.,'feet',#2);
        #4=IFCUNITASSIGNMENT((#3));
        #5=IFCPROJECT('guid-proj',$,$,$,$,$,$,$,#4);
        #10=IFCCARTESIANPOINT((0.,0.,0.));
        #11=IFCCARTESIANPOINT((10.,0.,0.));
        #12=IFCCARTESIANPOINT((10.,10.,0.));
        #13=IFCCARTESIANPOINT((0.,10.,0.));
        #14=IFCPOLYLOOP((#10,#11,#12,#13));
        #15=IFCFACEOUTERBOUND(#14,.T.);
        #16=IFCFACE((#15));
        #17=IFCCLOSEDSHELL((#16));
        #18=IFCFACETEDBREP(#17);
        #19=IFCSHAPEREPRESENTATION($,'Body','Brep',(#18));
        #20=IFCPRODUCTDEFINITIONSHAPE($,$,(#19));
        #21=IFCWALL('guid-1',$,$,$,$,$,#20);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // 10 feet should import as 10*0.3048 = 3.048m.
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(3.048f, app.allPoints.getX(1), 0.001f, "10 feet should convert to 3.048m");
    assertEquals(0.3048f, app.ifcLengthUnitScale, 0.00001f);
  }

  @Test
  void importObjectsIFC_noDeclaredUnit_isReadAsIs () throws IOException {
    Path f = ifcFile("ifc-units-none-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1f, app.ifcLengthUnitScale, 0.0000001f, "no declared length unit - should be assumed already metric");
    assertEquals(1f, app.allPoints.getX(1), 0.0001f);
  }

  @Test
  void importObjectsIFC_millimetreProject_alsoScalesExtrusionProfileAndDepth () throws IOException {
    Path f = ifcFile("ifc-units-extrusion-test", """
        #1=IFCSIUNIT(*,.LENGTHUNIT.,.MILLI.,.METRE.);
        #2=IFCUNITASSIGNMENT((#1));
        #3=IFCPROJECT('guid-proj',$,$,$,$,$,$,$,#2);
        #10=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2000.,4000.);
        #11=IFCDIRECTION((0.,0.,1.));
        #12=IFCEXTRUDEDAREASOLID(#10,$,#11,3000.);
        #13=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#12));
        #14=IFCPRODUCTDEFINITIONSHAPE($,$,(#13));
        #15=IFCWALL('guid-1',$,$,$,$,$,#14);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "2 caps + 4 sides");
    boolean sawDepthAtThreeMetres = false;
    boolean sawHalfWidthAtOneMetre = false;
    for (int i = 0; i < app.allPoints.getLength(); i++) {
      if (Math.abs(app.allPoints.getZ(i) - 3f) < 0.001f) sawDepthAtThreeMetres = true;
      if (Math.abs(app.allPoints.getX(i) - 1f) < 0.001f) sawHalfWidthAtOneMetre = true;
    }
    assertTrue(sawDepthAtThreeMetres, "3000mm extrusion depth should convert to 3m");
    assertTrue(sawHalfWidthAtOneMetre, "2000mm XDim (half-width 1000mm) should convert to 1m");
  }

  // ================= non-geometry product types are skipped on purpose =======

  @Test
  void importObjectsIFC_ifcSpace_importsItsOwnGeometry_defaultsToTheSpaceMaterial () throws IOException {
    Path f = ifcFile("ifc-space-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSPACE('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "ifcImportSpace is true by default, so a plain IfcSpace should import its own geometry");
    assertEquals(8, app.allFaces.options[0][0], "should default to IFC_MATERIAL_SPACE (8), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_ifcSpaceMaterialOverridesAnyAssociatedIfcMaterialName () throws IOException {
    Path f = ifcFile("ifc-space-material-override-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSPACE('guid-1',$,'Office 101',$,$,$,#11);
        #20=IFCMATERIAL('Concrete');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(8, app.allFaces.options[0][0],
      "like glass, a space's own material is unconditional - a room isn't real building fabric, so an associated material name shouldn't win here either");
  }

  @Test
  void ifcImportSpace_setFalse_excludesAnOrdinarySpace_butNotAPool () throws IOException {
    Path f = ifcFile("ifc-space-toggle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSPACE('guid-1',$,'Office 101',$,$,$,#11);
        #22=IFCSPACE('guid-2',$,'Pool',$,$,$,#11);
        """
    );

    app.ifcImportSpace = false; // IFC_IMPORT_SPACE itself is still true

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // Only the pool should have come through - the ordinary office
    // space should not have, same as the whole product type always has
    // while this toggle is off.
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(19, app.allFaces.options[0][0], "the pool should still import, with IFC_MATERIAL_WATER, regardless of ifcImportSpace");
  }

  // ================= IfcSite: topography, unlike the other spatial types =====

  @Test
  void importObjectsIFC_ifcSiteWithGeometry_importsItsOwnTopography_defaultingToEarthMaterial () throws IOException {
    Path f = ifcFile("ifc-site-topo-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((10.,0.,0.));
        #3=IFCCARTESIANPOINT((10.,10.,0.));
        #4=IFCCARTESIANPOINT((0.,10.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSITE('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num, "an IfcSite with geometry should start a group like any other product");
    assertEquals(1, app.allFaces.nodes.length, "IfcSite's own topography should import as a face");
    assertEquals(17, app.allFaces.options[0][0], "should default to IFC_MATERIAL_EARTH (17), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_ifcSiteWithNoRepresentation_isStillSkipped_justLikeAnyOtherProductWithoutGeometry () throws IOException {
    Path f = ifcFile("ifc-site-no-geometry-test", """
        #1=IFCSITE('guid-1',$,$,$,$,$,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allGroups.num, "IfcSite with Representation=$ shouldn't start a group either");
  }

  @Test
  void importObjectsIFC_ifcSiteWithAnExplicitMaterialName_usesThatInstead_notTheEarthDefault () throws IOException {
    Path f = ifcFile("ifc-site-material-override-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((10.,0.,0.));
        #3=IFCCARTESIANPOINT((10.,10.,0.));
        #4=IFCCARTESIANPOINT((0.,10.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSITE('guid-1',$,$,$,$,$,#11);
        #20=IFCMATERIAL('Concrete Paving');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0], "an explicit material-name match should win over the IfcSite earth default");
  }

  // ================= ifcImportOrient: rotate to the project's true north =====
  //
  // These fixtures' IFCGEOMETRICREPRESENTATIONCONTEXT(...) line - a
  // ContextIdentifier, ContextType, CoordinateSpaceDimension, Precision,
  // WorldCoordinateSystem, then TrueNorth - mirrors the exact attribute
  // order of real official buildingSMART sample files
  // (buildingSMART/IFC4.x-specification-models, e.g.
  // placements-and-gis-referencing/grid-placement and
  // geographic-referencing-utm), which also confirms TrueNorth is a
  // plain 2D IfcDirection (no Z component), same as used here.

  @Test
  void importObjectsIFC_trueNorth_angleIsReadFromTheGeometricRepresentationContextsTrueNorth () throws IOException {
    Path f = ifcFile("ifc-true-north-angle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCDIRECTION((1.,0.));
        #4=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#2,#3);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // TrueNorth (1,0) means true north points along the project's own
    // +X - 90 degrees away from +Y, where this file's own rotation
    // formula (atan2(dx,dy)) puts it.
    assertEquals(90f, app.ifcImportNorthRotationAngle, 0.0001f);
  }

  @Test
  void importObjectsIFC_trueNorth_noGeometricRepresentationContextInFile_angleIsZero_andGeometryImportsUntouched () throws IOException {
    Path f = ifcFile("ifc-true-north-no-context-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0f, app.ifcImportNorthRotationAngle, 0.0001f, "no IfcGeometricRepresentationContext at all means nothing to correct for");
    assertEquals(1f, app.allPoints.getX(1), 0.0001f, "geometry should import exactly as given");
    assertEquals(0f, app.allPoints.getY(1), 0.0001f);
  }

  @Test
  void importObjectsIFC_trueNorth_noTrueNorthOnTheContext_angleIsZero_andDoesNotTouchTheUsersOwnSelection () throws IOException {
    Path f = ifcFile("ifc-true-north-zero-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#21,$);
        """
    );

    // An arbitrary pre-existing selection/category, to confirm a
    // zero-angle import ("Don't rotate if the angle is zero") doesn't
    // even touch it - not just that it leaves the geometry unmoved.
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.faceSelection = new int[]{99};

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0f, app.ifcImportNorthRotationAngle, 0.0001f, "an unset ($) TrueNorth is the common case, and should read as a zero angle");

    float[][] expected = {{0, 0, 0}, {1, 0, 0}, {1, 1, 0}, {0, 1, 0}};
    for (int i = 0; i < 4; i++) {
      assertEquals(expected[i][0], app.allPoints.getX(i), 0.0001f, "point " + i + " x");
      assertEquals(expected[i][1], app.allPoints.getY(i), 0.0001f, "point " + i + " y");
    }

    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory, "a zero-angle import shouldn't touch the user's own current selection category");
    assertArrayEquals(new int[]{99}, app.Select3D.faceSelection, "...or their own face selection");
  }

  @Test
  void importObjectsIFC_trueNorth_explicitDefaultTrueNorth_angleIsZero () throws IOException {
    Path f = ifcFile("ifc-true-north-explicit-default-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCDIRECTION((0.,1.));
        #4=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#2,#3);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // (0,1) is IFC's own documented default for TrueNorth when it's
    // omitted entirely (meaning "the project's own +Y already is true
    // north") - an explicit (0,1) should read the same as not setting
    // it at all: zero rotation.
    assertEquals(0f, app.ifcImportNorthRotationAngle, 0.0001f);
  }

  @Test
  void importObjectsIFC_trueNorth_rotatesImportedFacesAroundTheWorldOrigin () throws IOException {
    Path f = ifcFile("ifc-true-north-rotate-faces-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCDIRECTION((1.,0.));
        #23=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#21,#22);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(90f, app.ifcImportNorthRotationAngle, 0.0001f);
    assertEquals(4, app.allPoints.getLength());

    // A 90-degree rotation about Z around the world origin sends
    // (x,y,0) to (-y,x,0) - see Rotate3D.rotateAroundVector()'s own
    // the_Vector==2 branch.
    float[][] expected = {{0, 0, 0}, {0, 1, 0}, {-1, 1, 0}, {-1, 0, 0}};
    for (int i = 0; i < 4; i++) {
      assertEquals(expected[i][0], app.allPoints.getX(i), 0.001f, "point " + i + " x");
      assertEquals(expected[i][1], app.allPoints.getY(i), 0.001f, "point " + i + " y");
      assertEquals(expected[i][2], app.allPoints.getZ(i), 0.001f, "point " + i + " z");
    }
  }

  @Test
  void importObjectsIFC_trueNorth_negativeAngle_rotatesTheOtherWay () throws IOException {
    Path f = ifcFile("ifc-true-north-negative-angle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCDIRECTION((-1.,0.));
        #23=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#21,#22);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(-90f, app.ifcImportNorthRotationAngle, 0.0001f);

    // A -90-degree rotation about Z around the world origin sends
    // (x,y,0) to (y,-x,0).
    float[][] expected = {{0, 0, 0}, {0, -1, 0}, {1, -1, 0}, {1, 0, 0}};
    for (int i = 0; i < 4; i++) {
      assertEquals(expected[i][0], app.allPoints.getX(i), 0.001f, "point " + i + " x");
      assertEquals(expected[i][1], app.allPoints.getY(i), 0.001f, "point " + i + " y");
    }
  }

  @Test
  void importObjectsIFC_trueNorth_alsoRotatesPlacedTrees_notJustFaces () throws IOException {
    Path f = ifcFile("ifc-true-north-rotate-trees-test", """
        #1=IFCCARTESIANPOINT((5.,7.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #4=IFCFURNISHINGELEMENT('guid-1',$,'Oak Tree',$,$,#3,$);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCDIRECTION((1.,0.));
        #23=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#21,#22);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allModel2Ds.num);
    // (5,7) rotated 90 degrees about Z around the origin -> (-7,5).
    assertEquals(-7f, app.allModel2Ds.XYZS[0][0], 0.001f, "x after a 90-degree true-north rotation");
    assertEquals(5f, app.allModel2Ds.XYZS[0][1], 0.001f, "y after a 90-degree true-north rotation");
  }

  @Test
  void importObjectsIFC_trueNorth_restoresTheUsersOwnSelectionAfterRotating () throws IOException {
    Path f = ifcFile("ifc-true-north-restore-selection-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCCARTESIANPOINT((5.,7.,0.));
        #14=IFCAXIS2PLACEMENT3D(#13,$,$);
        #15=IFCLOCALPLACEMENT($,#14);
        #16=IFCFURNISHINGELEMENT('guid-2',$,'Oak Tree',$,$,#15,$);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCDIRECTION((1.,0.));
        #23=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#21,#22);
        """
    );

    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.faceSelection = new int[]{42};
    app.Select3D.model2DSelection = new int[]{7};

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(90f, app.ifcImportNorthRotationAngle, 0.0001f);
    assertEquals(app.ObjectCategory.VERTEX, app.currentObjectCategory, "the north-rotation step should restore the user's own current category afterward");
    assertArrayEquals(new int[]{42}, app.Select3D.faceSelection, "...and their own face selection");
    assertArrayEquals(new int[]{7}, app.Select3D.model2DSelection, "...and their own model2D selection");
  }

  @Test
  void importObjectsIFC_trueNorth_multipleGeometricRepresentationContexts_usesTheLowestEntityId () throws IOException {
    Path f = ifcFile("ifc-true-north-multiple-contexts-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCDIRECTION((1.,0.));
        #23=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#21,#22);
        #30=IFCDIRECTION((-1.,0.));
        #31=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Plan',3,1.E-5,#21,#30);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // #23 ('Model', TrueNorth (1,0), 90 degrees) has the lower entity id
    // of the two contexts, so its own angle wins over #31's ('Plan',
    // -90 degrees).
    assertEquals(90f, app.ifcImportNorthRotationAngle, 0.0001f);
  }

  // ================= ifcImportRelocate: navigate to the site ==================

  @Test
  void importObjectsIFC_gotoLatLon_navigatesTheStationToIfcSitesRefLatLon () throws IOException {
    Path f = ifcFile("ifc-gotolatlon-reflatlon-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,(43,38,33),(-79,23,13),0.,$,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // 43 deg 38' 33" N, 79 deg 23' 13" W - rounded to 4 decimal places.
    assertNotNull(app.ifcImportGotoLatLon);
    assertEquals(43.6425f, app.ifcImportGotoLatLon[0], 0.0001f, "latitude");
    assertEquals(-79.3869f, app.ifcImportGotoLatLon[1], 0.0001f, "longitude");

    // __SETLATLON__ should actually have been called with it.
    assertEquals(43.6425f, app.STATION.getLatitude(), 0.0001f);
    assertEquals(-79.3869f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void importObjectsIFC_gotoLatLon_officialBuildingSmartSample_readsTheRealRefLatLon () throws IOException {
    // IfcSite's own line, verbatim, from buildingSMART's official
    // geographic-referencing-utm.ifc sample (buildingSMART/
    // IFC4.x-specification-models, placements-and-gis-referencing/
    // geographic-referencing-utm) - a real file demonstrating both
    // RefLatitude/RefLongitude AND IfcMapConversion/IfcProjectedCRS
    // together, which is also how this test independently confirms
    // IfcSite's own RefLatitude(9)/RefLongitude(10) attribute indices
    // against real, official data, not just a fixture built to match
    // this importer's own assumptions.
    Path f = ifcFile("ifc-gotolatlon-official-sample-test", """
        #100020=IFCSITE('1BPCQAtTW7GhKrUF$Sytrr',$,'Site',$,$,#100022,$,$,.ELEMENT.,(49,5,43,983700),(8,26,1,247300),113.7,$,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // 49 deg 5' 43.9837" N, 8 deg 26' 1.2473" E - Karlsruhe, Germany,
    // matching the file's own EPSG:25832 (UTM zone 32N / ETRS89) CRS.
    assertNotNull(app.ifcImportGotoLatLon);
    assertEquals(49.0956f, app.ifcImportGotoLatLon[0], 0.0001f, "latitude");
    assertEquals(8.4337f, app.ifcImportGotoLatLon[1], 0.0001f, "longitude");
    assertEquals(49.0956f, app.STATION.getLatitude(), 0.0001f);
    assertEquals(8.4337f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void importObjectsIFC_gotoLatLon_fourComponentCompoundAngle_includesTheMicrosecondsComponent () throws IOException {
    Path f = ifcFile("ifc-gotolatlon-microseconds-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,(43,38,33,500000),(0,0,0,0),0.,$,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // 500000 microseconds = 0.5 seconds, so 33" becomes 33.5".
    assertNotNull(app.ifcImportGotoLatLon);
    assertEquals(43.6426f, app.ifcImportGotoLatLon[0], 0.0001f, "43 deg 38' 33.5\" rounds to this at 4 decimal places");
  }

  @Test
  void importObjectsIFC_gotoLatLon_negativeDegreesComponent_onlyThatComponentCarriesTheSign () throws IOException {
    Path f = ifcFile("ifc-gotolatlon-negative-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,(-33,52,4),(151,12,36),0.,$,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNotNull(app.ifcImportGotoLatLon);
    assertTrue(app.ifcImportGotoLatLon[0] < 0, "negative degrees should make the whole latitude negative");
    assertEquals(-33.8678f, app.ifcImportGotoLatLon[0], 0.0001f);
    assertEquals(151.21f, app.ifcImportGotoLatLon[1], 0.0001f);
  }

  @Test
  void importObjectsIFC_gotoLatLon_unsetRefLatLon_andNoMapConversion_leavesTheStationUntouched () throws IOException {
    Path f = ifcFile("ifc-gotolatlon-unset-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,$,$,$,$,$);
        """
    );

    app.STATION.setLatitude(12.34f);
    app.STATION.setLongitude(56.78f);

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNull(app.ifcImportGotoLatLon, "an unset ($) RefLatitude/RefLongitude is not a (0,0,0) compound angle - it's absent");
    assertEquals(12.34f, app.STATION.getLatitude(), 0.0001f, "the station should be left exactly where it was");
    assertEquals(56.78f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void importObjectsIFC_gotoLatLon_noIfcSiteAtAll_leavesTheStationUntouched () throws IOException {
    Path f = ifcFile("ifc-gotolatlon-no-site-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    app.STATION.setLatitude(12.34f);
    app.STATION.setLongitude(56.78f);

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNull(app.ifcImportGotoLatLon);
    assertEquals(12.34f, app.STATION.getLatitude(), 0.0001f);
    assertEquals(56.78f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void importObjectsIFC_gotoLatLon_fallsBackToIfcMapConversion_whenRefLatLonIsUnset () throws IOException {
    Path f = ifcFile("ifc-gotolatlon-mapconversion-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,$,$,$,$,$);
        #2=IFCPROJECTEDCRS('WGS 84',$,$,$,$,$,$);
        #3=IFCMAPCONVERSION($,#2,-79.387,43.6425,0.,1.,0.,1.);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNotNull(app.ifcImportGotoLatLon, "no RefLatitude/RefLongitude, but an IfcMapConversion with plain geographic Eastings/Northings should still be usable");
    assertEquals(43.6425f, app.ifcImportGotoLatLon[0], 0.0001f, "Northings is latitude");
    assertEquals(-79.387f, app.ifcImportGotoLatLon[1], 0.0001f, "Eastings is longitude");
    assertEquals(43.6425f, app.STATION.getLatitude(), 0.0001f);
    assertEquals(-79.387f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void importObjectsIFC_gotoLatLon_ifcMapConversionWithTrueProjectedMetres_isNotMistakenForDegrees () throws IOException {
    // #1/#2 are, verbatim, the real IfcProjectedCRS/IfcMapConversion
    // lines from buildingSMART's own official geographic-referencing-utm.ifc
    // sample (see the test above) - 458657.30/5438232.25 are real
    // EPSG:25832 UTM-zone-32N Eastings/Northings in metres, not degrees.
    Path f = ifcFile("ifc-gotolatlon-mapconversion-utm-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,$,$,$,$,$);
        #2=IFCPROJECTEDCRS('EPSG:25832','UTM in band 32','ETRS89',$,'UTM','UTM32',$);
        #3=IFCMAPCONVERSION($,#2,458657.30,5438232.25,113.7,0.270600445976,0.962691746426,1000.);
        """
    );

    app.STATION.setLatitude(12.34f);
    app.STATION.setLongitude(56.78f);

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // A real UTM easting/northing (hundreds of thousands to millions of
    // metres) is nowhere near a plausible longitude/latitude - with no
    // map-projection engine to convert it properly, this should be left
    // alone rather than "navigating" somewhere wildly wrong.
    assertNull(app.ifcImportGotoLatLon);
    assertEquals(12.34f, app.STATION.getLatitude(), 0.0001f);
    assertEquals(56.78f, app.STATION.getLongitude(), 0.0001f);
  }

  @Test
  void importObjectsIFC_gotoLatLon_ifcSitesOwnRefLatLon_takesPriorityOverMapConversion () throws IOException {
    Path f = ifcFile("ifc-gotolatlon-priority-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,(43,38,33),(-79,23,13),0.,$,$);
        #2=IFCPROJECTEDCRS('WGS 84',$,$,$,$,$,$);
        #3=IFCMAPCONVERSION($,#2,10.,20.,0.,1.,0.,1.);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // IfcSite's own RefLatitude/RefLongitude should win over the
    // IfcMapConversion's own (10, 20), not just whichever is found first.
    assertEquals(43.6425f, app.ifcImportGotoLatLon[0], 0.0001f);
    assertEquals(-79.3869f, app.ifcImportGotoLatLon[1], 0.0001f);
  }

  @Test
  void importObjectsIFC_triangulatedIrregularNetwork_importsAsATerrainMesh_sameReaderAsTriangulatedFaceSet () throws IOException {
    Path f = ifcFile("ifc-tin-test", """
        #1=IFCCARTESIANPOINTLIST3D(((0.,0.,0.),(1.,0.,0.5),(0.,1.,0.2),(1.,1.,0.7)));
        #2=IFCTRIANGULATEDIRREGULARNETWORK(#1,$,.F.,((1,2,3),(2,4,3)),$,(0,0));
        #3=IFCSHAPEREPRESENTATION($,'Body','Tessellation',(#2));
        #4=IFCPRODUCTDEFINITIONSHAPE($,$,(#3));
        #5=IFCSITE('guid-1',$,$,$,$,$,#4);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length, "the TIN's two triangles should each become one face");
    for (int[] face : app.allFaces.nodes) {
      assertEquals(3, face.length);
    }
    assertEquals(17, app.allFaces.options[0][0], "terrain from a TIN should also default to IFC_MATERIAL_EARTH");
  }

  // ================= trees: placed natively, not imported as Faces ===========

  @Test
  void importObjectsIFC_treeNamedByProduct_isPlacedAsANativeModel2D_withHeightParsedFromItsName () throws IOException {
    Path f = ifcFile("ifc-tree-test", """
        #1=IFCCARTESIANPOINT((5.,7.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #4=IFCCARTESIANPOINT((0.,0.,0.));
        #5=IFCCARTESIANPOINT((1.,0.,0.));
        #6=IFCCARTESIANPOINT((1.,1.,0.));
        #7=IFCPOLYLOOP((#4,#5,#6));
        #8=IFCFACEOUTERBOUND(#7,.T.);
        #9=IFCFACE((#8));
        #10=IFCCLOSEDSHELL((#9));
        #11=IFCFACETEDBREP(#10);
        #12=IFCSHAPEREPRESENTATION($,'Body','Brep',(#11));
        #13=IFCPRODUCTDEFINITIONSHAPE($,$,(#12));
        #14=IFCFURNISHINGELEMENT('guid-1',$,'Tree - Deciduous - Generic : 30''',$,$,#3,#13);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "a tree's own proxy geometry should not be imported as Faces");
    assertEquals(1, app.allModel2Ds.num);
    assertEquals(5f, app.allModel2Ds.XYZS[0][0], 0.0001f, "x");
    assertEquals(7f, app.allModel2Ds.XYZS[0][1], 0.0001f, "y");
    // "30'" -> 30 * 0.3048 = 9.144m
    assertEquals(9.144f, app.allModel2Ds.XYZS[0][3], 0.01f, "height parsed from the name's \"30'\"");
  }

  @Test
  void importObjectsIFC_treeWithNoParseableHeight_defaultsToTenMetres_sameAsTree2sOwnDefault () throws IOException {
    Path f = ifcFile("ifc-tree-default-height-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #4=IFCFURNISHINGELEMENT('guid-1',$,'Oak Tree',$,$,#3,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // No Representation at all - a tree is still placed from just its
    // name/placement, unlike any other product type.
    assertEquals(1, app.allModel2Ds.num);
    assertEquals(10f, app.allModel2Ds.XYZS[0][3], 0.0001f);
  }

  @Test
  void importObjectsIFC_treeHeightScalesWithTheImportsOwnZScale () throws IOException {
    Path f = ifcFile("ifc-tree-scale-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #4=IFCFURNISHINGELEMENT('guid-1',$,'Tree',$,$,#3,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 2 /*sz*/);

    assertEquals(1, app.allModel2Ds.num);
    assertEquals(20f, app.allModel2Ds.XYZS[0][3], 0.0001f, "default 10m height should scale with sz (2x here)");
  }

  @Test
  void importObjectsIFC_streetLampIsNotMistakenForATree_wholeWordMatchOnly () throws IOException {
    Path f = ifcFile("ifc-not-a-tree-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBUILDINGELEMENTPROXY('guid-1',$,'Street Lamp',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allModel2Ds.num, "\"Street\" should never be mistaken for containing \"tree\"");
    assertEquals(1, app.allFaces.nodes.length, "it should import its own geometry as Faces instead");
  }

  // ================= solar devices: real geometry, always material 0 =========

  @Test
  void importObjectsIFC_ifcSolarDevice_importsItsRealGeometry_withMaterial0 () throws IOException {
    Path f = ifcFile("ifc-solardevice-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSOLARDEVICE('guid-1',$,$,$,$,$,#11,$,.SOLARPANEL.);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "IfcSolarDevice should import its own real geometry as Faces");
    assertEquals(4, app.allFaces.nodes[0].length, "kept as a quad, not triangulated, same as any other face");
    assertEquals(0, app.allFaces.options[0][0], "should always be material 0 (IFC_MATERIAL_SOLAR), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_genericProxyNamedSolarPanel_isAlsoRecognized_notJustIfcSolarDevice () throws IOException {
    Path f = ifcFile("ifc-solar-proxy-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBUILDINGELEMENTPROXY('guid-1',$,'Solar Collector - Flat Plate',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(0, app.allFaces.options[0][0], "a generic proxy named \"Solar Collector\" should also get material 0");
  }

  @Test
  void importObjectsIFC_solarDeviceMaterialOverridesAnyAssociatedIfcMaterialName () throws IOException {
    Path f = ifcFile("ifc-solar-material-override-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSOLARDEVICE('guid-1',$,'PV Panel',$,$,$,#11,$,.SOLARPANEL.);
        #20=IFCMATERIAL('Glass');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(0, app.allFaces.options[0][0],
      "the solar material is functional (tessellation), not cosmetic, so it should win over an associated material name too");
  }

  @Test
  void importObjectsIFC_solarDeviceDoesNotDisruptTheWallMaterialCycle () throws IOException {
    Path f = ifcFile("ifc-solar-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCSOLARDEVICE('guid-2',$,$,$,$,$,#11,$,.SOLARPANEL.);
        #14=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.options[0][0], "first wall: material cycle starts at 1");
    assertEquals(0, app.allFaces.options[1][0], "solar device: always material 0");
    assertEquals(2, app.allFaces.options[2][0], "second wall: material cycle continues at 2, not disrupted");
  }

  // ================= shading devices: louvers, brise-soleil, ... =============

  @Test
  void importObjectsIFC_ifcShadingDevice_importsItsRealGeometry_defaultsToSteel () throws IOException {
    Path f = ifcFile("ifc-shadingdevice-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSHADINGDEVICE('guid-1',$,$,$,$,$,#11,$,.LOUVER.);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "IfcShadingDevice should import its own real geometry as Faces");
    assertEquals(4, app.allFaces.nodes[0].length, "kept as a quad, not triangulated, same as any other face");
    assertEquals(12, app.allFaces.options[0][0], "an unmaterialed shading device should default to IFC_MATERIAL_STEEL (12), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_genericProxyNamedLouvre_isAlsoRecognized_notJustIfcShadingDevice () throws IOException {
    Path f = ifcFile("ifc-shading-proxy-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBUILDINGELEMENTPROXY('guid-1',$,'Louvre Screen',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(12, app.allFaces.options[0][0], "a generic proxy named \"Louvre Screen\" should also default to IFC_MATERIAL_STEEL");
  }

  @Test
  void importObjectsIFC_briseSoleilTwoWordNameMatch_isRecognized () throws IOException {
    Path f = ifcFile("ifc-shading-brisesoleil-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBUILDINGELEMENTPROXY('guid-1',$,'Brise-Soleil Fin',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(12, app.allFaces.options[0][0], "\"Brise-Soleil\" (hyphenated two-word name) should also be recognized");
  }

  @Test
  void importObjectsIFC_shadingDeviceExplicitMaterialWins_overTheSteelDefault () throws IOException {
    Path f = ifcFile("ifc-shading-material-override-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSHADINGDEVICE('guid-1',$,'Timber Louvre',$,$,$,#11,$,.LOUVER.);
        #20=IFCMATERIAL('Timber');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(13, app.allFaces.options[0][0],
      "unlike glass/solar, a shading device's own steel default is purely cosmetic, so an explicit material-name match (timber, 13) should still win");
  }

  @Test
  void importObjectsIFC_shadingDeviceDoesNotDisruptTheWallMaterialCycle () throws IOException {
    Path f = ifcFile("ifc-shading-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCSHADINGDEVICE('guid-2',$,$,$,$,$,#11,$,.LOUVER.);
        #14=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.options[0][0], "first wall: material cycle starts at 1");
    assertEquals(12, app.allFaces.options[1][0], "shading device: defaults to steel (12), same every time, not part of the cycle");
    assertEquals(2, app.allFaces.options[2][0], "second wall: material cycle continues at 2, not disrupted");
  }

  @Test
  void importObjectsIFC_shadingDeviceImportsEvenWhileFurnitureIsExcluded () throws IOException {
    // Mimics a file that (unusually) models a shading device as an
    // IfcFurnishingElement instead of IfcShadingDevice/a plain proxy -
    // the same kind of miscategorization ifcLooksLikeATree()/
    // ifcLooksLikeASolarDevice() already guard against for trees/solar
    // panels (see import_objects_IFC()'s own product-collection loop).
    Path f = ifcFile("ifc-shading-furniture-bypass-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCFURNISHINGELEMENT('guid-1',$,'Exterior Louvre Panel',$,$,$,#11);
        """
    );

    // ifcImportFurniture is false by default - confirmed by every
    // other furniture test in this file - so this alone proves the
    // shading-device recognition bypasses that exclusion, the same way
    // it already does for a tree/solar device/pool/vegetation.
    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "a shading device named this way should import despite ifcImportFurniture being false");
    assertEquals(0, app.ifcImportFurnitureExcludedCount, "and should not be counted as excluded furniture");
  }

  // ================= vegetation: green roof, green wall, garden/grass ========

  @Test
  void importObjectsIFC_roofNamedGreenRoof_defaultsToVegetationMaterial () throws IOException {
    Path f = ifcFile("ifc-greenroof-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCROOF('guid-1',$,'Green Roof - Extensive',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(18, app.allFaces.options[0][0], "should default to IFC_MATERIAL_VEGETATION (18), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_wallNamedGreenWall_alsoDefaultsToVegetationMaterial () throws IOException {
    Path f = ifcFile("ifc-greenwall-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,'Living Green Wall',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(18, app.allFaces.options[0][0]);
  }

  @Test
  void importObjectsIFC_siteNamedGarden_getsVegetationInsteadOfTheGenericEarthDefault () throws IOException {
    Path f = ifcFile("ifc-garden-site-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((10.,0.,0.));
        #3=IFCCARTESIANPOINT((10.,10.,0.));
        #4=IFCCARTESIANPOINT((0.,10.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSITE('guid-1',$,'Garden Area',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(18, app.allFaces.options[0][0], "a site explicitly named \"Garden\" should get vegetation (18), not the generic earth default (17)");
  }

  @Test
  void importObjectsIFC_vegetationDefaultLosesToAnExplicitAssociatedMaterialName () throws IOException {
    Path f = ifcFile("ifc-vegetation-material-override-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCROOF('guid-1',$,'Green Roof',$,$,$,#11);
        #20=IFCMATERIAL('Concrete Ballast');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0],
      "vegetation is purely cosmetic, unlike glass/solar, so an explicit material-name match (concrete, 11) should still win");
  }

  // ================= floors and exposed structural members ===================

  @Test
  void importObjectsIFC_ifcColumn_defaultsToConcrete () throws IOException {
    Path f = ifcFile("ifc-column-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCCOLUMN('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0], "an unmaterialed column should default to IFC_MATERIAL_CONCRETE (11), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_ifcBeamAndIfcMember_alsoDefaultToConcrete () throws IOException {
    Path f = ifcFile("ifc-beam-member-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBEAM('guid-1',$,$,$,$,$,#11);
        #13=IFCMEMBER('guid-2',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0], "IfcBeam");
    assertEquals(11, app.allFaces.options[1][0], "IfcMember");
  }

  @Test
  void importObjectsIFC_slabWithFloorPredefinedType_defaultsToConcrete () throws IOException {
    Path f = ifcFile("ifc-floor-slab-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSLAB('guid-1',$,$,$,$,$,#11,$,.FLOOR.);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0]);
  }

  @Test
  void importObjectsIFC_slabWithRoofPredefinedType_doesNotGetTheFloorDefault () throws IOException {
    Path f = ifcFile("ifc-roof-slab-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSLAB('guid-1',$,$,$,$,$,#11,$,.ROOF.);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(5, app.allFaces.options[0][0], "a .ROOF. slab shouldn't get the floor default - falls back to the fixed material (5)");
  }

  @Test
  void importObjectsIFC_slabNamedFloor_getsTheDefaultEvenWithoutThePredefinedTypeAttribute () throws IOException {
    Path f = ifcFile("ifc-floor-byname-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSLAB('guid-1',$,'Level 2 Floor',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0]);
  }

  @Test
  void importObjectsIFC_columnWithAnAssociatedSteelMaterial_stillWinsOverTheConcreteDefault () throws IOException {
    Path f = ifcFile("ifc-column-material-override-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCCOLUMN('guid-1',$,$,$,$,$,#11);
        #20=IFCMATERIAL('Structural Steel');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(12, app.allFaces.options[0][0], "an associated 'Structural Steel' material should win over the column's own concrete default");
  }

  @Test
  void importObjectsIFC_columnsDoNotDisruptTheWallMaterialCycle () throws IOException {
    Path f = ifcFile("ifc-column-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCCOLUMN('guid-2',$,$,$,$,$,#11);
        #14=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.options[0][0], "first wall: material cycle starts at 1");
    assertEquals(11, app.allFaces.options[1][0], "column: always concrete (11)");
    assertEquals(2, app.allFaces.options[2][0], "second wall: material cycle continues at 2, not disrupted");
  }

  // ================= pool water ================================================

  @Test
  void importObjectsIFC_slabNamedPool_defaultsToWaterMaterial () throws IOException {
    Path f = ifcFile("ifc-pool-slab-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((5.,0.,0.));
        #3=IFCCARTESIANPOINT((5.,3.,0.));
        #4=IFCCARTESIANPOINT((0.,3.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSLAB('guid-1',$,'Swimming Pool Water Surface',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(19, app.allFaces.options[0][0], "should default to IFC_MATERIAL_WATER (19), not the fixed material (5)");
  }

  @Test
  void importObjectsIFC_ifcSpaceNamedPool_getsWaterMaterial_takingPriorityOverTheGenericSpaceMaterial () throws IOException {
    Path f = ifcFile("ifc-pool-space-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((5.,0.,0.));
        #3=IFCCARTESIANPOINT((5.,3.,0.));
        #4=IFCCARTESIANPOINT((0.,3.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSPACE('guid-1',$,'Pool',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "an IfcSpace named \"Pool\" should still import its water surface");
    assertEquals(19, app.allFaces.options[0][0], "a space recognized as a pool is still more specifically a pool, so IFC_MATERIAL_WATER (19), not IFC_MATERIAL_SPACE (8), should win");
  }

  @Test
  void importObjectsIFC_ordinaryIfcSpaceAndAPool_bothImport_eachWithItsOwnMaterial () throws IOException {
    Path f = ifcFile("ifc-ordinary-space-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSPACE('guid-1',$,'Office 101',$,$,$,#11);
        #22=IFCSPACE('guid-2',$,'Pool',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // ifcImportSpace is true by default, so both should import now - the
    // office with the generic space material, the pool with its own.
    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(8, app.allFaces.options[0][0], "the office space");
    assertEquals(19, app.allFaces.options[1][0], "the pool");
  }

  @Test
  void importObjectsIFC_waterHeaterIsNotMistakenForAPool_bareWordIsNotEnough () throws IOException {
    Path f = ifcFile("ifc-waterheater-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBUILDINGELEMENTPROXY('guid-1',$,'Water Heater',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 5 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(5, app.allFaces.options[0][0], "\"Water Heater\" should not match pool detection (bare \"water\" is deliberately not a trigger word)");
  }

  @Test
  void importObjectsIFC_poolWaterMaterialLosesToAnExplicitAssociatedMaterialName () throws IOException {
    Path f = ifcFile("ifc-pool-material-override-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSLAB('guid-1',$,'Pool Deck',$,$,$,#11);
        #20=IFCMATERIAL('Concrete Paving');
        #21=IFCRELASSOCIATESMATERIAL('guid-2',$,$,$,(#12),#20);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(11, app.allFaces.options[0][0],
      "water is purely cosmetic, unlike glass/solar, so an explicit material-name match (concrete, 11) should still win over the pool default");
  }

  // ================= IfcMappedItem ("family/type" block instances) ===========

  @Test
  void importObjectsIFC_mappedItem_withIdentityMappingOrigin_translatesByItsLocalOrigin () throws IOException {
    Path f = ifcFile("ifc-mappeditem-translate-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCREPRESENTATIONMAP(#21,#10);
        #30=IFCCARTESIANPOINT((100.,200.,0.));
        #31=IFCCARTESIANTRANSFORMATIONOPERATOR3D($,$,#30,$,$);
        #32=IFCMAPPEDITEM(#22,#31);
        #33=IFCSHAPEREPRESENTATION($,'Body','MappedRepresentation',(#32));
        #34=IFCPRODUCTDEFINITIONSHAPE($,$,(#33));
        #35=IFCWINDOW('guid-1',$,$,$,$,$,#34);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "the mapped item's one quad face should be resolved, not skipped");
    assertEquals(4, app.allFaces.nodes[0].length, "kept as a quad, not triangulated");
    assertEquals(9, app.allFaces.options[0][0], "still an IfcWindow, so still always material 9");
    // the mapped square (0,0)-(1,0)-(1,1)-(0,1) translated by LocalOrigin (100,200,0)
    float[] expectedX = {100, 101, 101, 100};
    float[] expectedY = {200, 200, 201, 201};
    for (int i = 0; i < 4; i++) {
      assertEquals(expectedX[i], app.allPoints.getX(i), 0.0001f, "point " + i);
      assertEquals(expectedY[i], app.allPoints.getY(i), 0.0001f, "point " + i);
    }
    assertEquals(0, app.ifcImportSkippedCount, "a resolved mapped item shouldn't be counted as skipped");
  }

  @Test
  void importObjectsIFC_mappedItem_appliesScaleAndComposesWithTheProductsOwnPlacement () throws IOException {
    Path f = ifcFile("ifc-mappeditem-scale-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCREPRESENTATIONMAP(#21,#10);
        #30=IFCCARTESIANPOINT((0.,0.,0.));
        #31=IFCCARTESIANTRANSFORMATIONOPERATOR3D($,$,#30,2.,$);
        #32=IFCMAPPEDITEM(#22,#31);
        #33=IFCSHAPEREPRESENTATION($,'Body','MappedRepresentation',(#32));
        #34=IFCPRODUCTDEFINITIONSHAPE($,$,(#33));
        #40=IFCCARTESIANPOINT((10.,0.,0.));
        #41=IFCAXIS2PLACEMENT3D(#40,$,$);
        #42=IFCLOCALPLACEMENT($,#41);
        #43=IFCBUILDINGELEMENTPROXY('guid-1',$,$,$,$,#42,#34);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    // mapped square scaled by 2 -> (0,0)-(2,0)-(2,2)-(0,2), then
    // translated by the product's own placement (10,0,0)
    float[] expectedX = {10, 12, 12, 10};
    float[] expectedY = {0, 0, 2, 2};
    for (int i = 0; i < 4; i++) {
      assertEquals(expectedX[i], app.allPoints.getX(i), 0.0001f, "point " + i);
      assertEquals(expectedY[i], app.allPoints.getY(i), 0.0001f, "point " + i);
    }
  }

  @Test
  void importObjectsIFC_mappedItemWithMissingRepresentationMap_isSkippedAndCounted () throws IOException {
    Path f = ifcFile("ifc-mappeditem-broken-test", """
        #30=IFCCARTESIANPOINT((0.,0.,0.));
        #31=IFCCARTESIANTRANSFORMATIONOPERATOR3D($,$,#30,$,$);
        #32=IFCMAPPEDITEM(#999,#31);
        #33=IFCSHAPEREPRESENTATION($,'Body','MappedRepresentation',(#32));
        #34=IFCPRODUCTDEFINITIONSHAPE($,$,(#33));
        #35=IFCWALL('guid-1',$,$,$,$,$,#34);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.ifcImportSkippedCount);
  }

  // ================= ifcImportFurniture/ifcImportOrient/ifcImportRelocate: =====
  // ================= per-session toggles, not compile-time constants ==========

  @Test
  void ifcImportToggles_startAtTheirRespectiveConstantsOwnDefaultValue () {
    assertEquals(app.IFC_IMPORT_FURNITURE, app.ifcImportFurniture);
    assertEquals(app.IFC_IMPORT_NORTH, app.ifcImportOrient);
    assertEquals(app.IFC_IMPORT_GOTO_LATLON, app.ifcImportRelocate);
    assertEquals(app.IFC_IMPORT_SPACE, app.ifcImportSpace);
  }

  @Test
  void ifcImportShowOptionsDialog_defaultsToFalse_soCallingImportDirectlyNeverPopsADialog () throws IOException {
    // The options dialog is a real, blocking Swing dialog (see
    // ifcShowImportOptionsDialog() in fileSelected.pde) - every test in
    // this whole file calls import_objects_IFC() directly the way this
    // one does, and would hang waiting on a person who isn't there if
    // this flag defaulted to anything other than false, or if
    // import_objects_IFC() didn't leave it false afterward too.
    assertFalse(app.ifcImportShowOptionsDialog);

    Path f = ifcFile("ifc-no-options-dialog-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertFalse(app.ifcImportShowOptionsDialog, "should still be false afterward - nothing here should have armed it");
    assertEquals(1, app.allFaces.nodes.length, "the import itself should still have gone through");
  }

  @Test
  void ifcImportFurniture_setTrue_actuallyImportsFurniture_notJustTheConstant () throws IOException {
    Path f = ifcFile("ifc-furniture-toggle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCFURNISHINGELEMENT('guid-1',$,'Office Chair',$,$,$,#11);
        """
    );

    app.ifcImportFurniture = true; // IFC_IMPORT_FURNITURE itself is still false

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "flipping the variable (not the constant) should be enough to import furniture");
    assertEquals(0, app.ifcImportFurnitureExcludedCount);
  }

  @Test
  void ifcImportOrient_setFalse_skipsTrueNorthRotation_evenWithANonzeroTrueNorth () throws IOException {
    Path f = ifcFile("ifc-orient-toggle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCDIRECTION((1.,0.));
        #23=IFCGEOMETRICREPRESENTATIONCONTEXT($,'Model',3,1.E-5,#21,#22);
        """
    );

    app.ifcImportOrient = false; // IFC_IMPORT_NORTH itself is still true

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0f, app.ifcImportNorthRotationAngle, 0.0001f, "turning the variable off should skip rotating, even though this file's own TrueNorth is a real 90 degrees");
    assertEquals(1f, app.allPoints.getX(1), 0.0001f, "geometry should import unrotated");
    assertEquals(0f, app.allPoints.getY(1), 0.0001f);
  }

  @Test
  void ifcImportRelocate_setFalse_skipsNavigating_evenWithAUsableRefLatLon () throws IOException {
    Path f = ifcFile("ifc-relocate-toggle-test", """
        #1=IFCSITE('guid-site',$,$,$,$,$,$,$,$,(43,38,33),(-79,23,13),0.,$,$);
        """
    );

    app.ifcImportRelocate = false; // IFC_IMPORT_GOTO_LATLON itself is still true
    app.STATION.setLatitude(12.34f);
    app.STATION.setLongitude(56.78f);

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNull(app.ifcImportGotoLatLon, "turning the variable off should skip navigating, even though this file's own RefLatitude/RefLongitude are usable");
    assertEquals(12.34f, app.STATION.getLatitude(), 0.0001f, "the station should be left exactly where it was");
    assertEquals(56.78f, app.STATION.getLongitude(), 0.0001f);
  }

  // ================= furniture: excluded by default (ifcImportFurniture) ======

  @Test
  void importObjectsIFC_ordinaryFurnishingElement_isExcludedByDefault () throws IOException {
    Path f = ifcFile("ifc-furniture-excluded-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCFURNISHINGELEMENT('guid-1',$,'Office Chair',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "ordinary furniture should be excluded while ifcImportFurniture is false");
    assertEquals(0, app.allGroups.num, "an excluded furniture item shouldn't even start a group");
    assertEquals(1, app.ifcImportFurnitureExcludedCount);
    assertEquals(0, app.ifcImportSkippedCount, "excluded furniture is a deliberate choice, not an unsupported-item skip");
  }

  @Test
  void importObjectsIFC_ifcFurnitureAndIfcSystemFurnitureElement_alsoExcludedByDefault () throws IOException {
    Path f = ifcFile("ifc-furniture-types-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCFURNITURE('guid-1',$,'Desk',$,$,$,#11);
        #13=IFCSYSTEMFURNITUREELEMENT('guid-2',$,'Cubicle Panel',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(2, app.ifcImportFurnitureExcludedCount);
  }

  @Test
  void importObjectsIFC_treeModeledAsFurnishingElement_stillImportsDespiteTheFurnitureToggle () throws IOException {
    Path f = ifcFile("ifc-tree-furniture-exempt-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #4=IFCFURNISHINGELEMENT('guid-1',$,'Oak Tree',$,$,#3,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allModel2Ds.num, "a tree should still be placed, even though it's modeled as IfcFurnishingElement");
    assertEquals(0, app.ifcImportFurnitureExcludedCount, "a tree isn't counted as excluded furniture - it's its own feature");
  }

  @Test
  void importObjectsIFC_vegetationModeledAsFurnishingElement_stillImportsDespiteTheFurnitureToggle () throws IOException {
    Path f = ifcFile("ifc-vegetation-furniture-exempt-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCFURNISHINGELEMENT('guid-1',$,'Garden Planter',$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "a \"Garden Planter\" should still import despite being IfcFurnishingElement");
    assertEquals(18, app.allFaces.options[0][0], "and should still get the vegetation default");
    assertEquals(0, app.ifcImportFurnitureExcludedCount);
  }

  @Test
  void importObjectsIFC_furnitureDoesNotDisruptTheWallMaterialCycleOrGroupCount () throws IOException {
    Path f = ifcFile("ifc-furniture-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #13=IFCFURNISHINGELEMENT('guid-2',$,'Sofa',$,$,$,#11);
        #14=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "only the two walls should start groups - the excluded sofa shouldn't");
    assertEquals(1, app.allFaces.options[0][0], "first wall: material cycle starts at 1");
    assertEquals(2, app.allFaces.options[1][0], "second wall: material cycle continues at 2, not disrupted by the excluded sofa");
  }

  // ================= small IfcBuildingElementProxy objects (same toggle) =====

  @Test
  void importObjectsIFC_smallBuildingElementProxy_isExcludedByDefault () throws IOException {
    // A 0.1m cube - well under IFC_SMALL_OBJECT_MAX_DIMENSION (0.5m) on
    // every axis, standing in for something like a coffee cup.
    Path f = ifcFile("ifc-small-proxy-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,0.1,0.1);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,0.1);
        #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCBUILDINGELEMENTPROXY('guid-1',$,'Coffee Cup',$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "a 0.1m proxy should be excluded as a small object");
    assertEquals(0, app.allPoints.getLength(), "its points shouldn't be promoted either");
    assertEquals(1, app.ifcImportSmallObjectExcludedCount);
    assertEquals(0, app.ifcImportFurnitureExcludedCount, "small-object exclusion is tracked separately from furniture exclusion");
  }

  @Test
  void importObjectsIFC_largeBuildingElementProxy_stillImports_evenThoughItsTheSameEntityType () throws IOException {
    // A 2x2x2m box - the same IFC type as the coffee cup above, but
    // large enough (and with a Name that doesn't match the kitchen-
    // appliance/cabinet word list either - see
    // importObjectsIFC_kitchenApplianceBuildingElementProxy_isExcluded()
    // below for that) that it should never be excluded just for being
    // an IfcBuildingElementProxy - an elevator, say.
    Path f = ifcFile("ifc-large-proxy-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2.,2.);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,2.);
        #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCBUILDINGELEMENTPROXY('guid-1',$,'Elevator',$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "a 2m proxy should import normally (2 caps + 4 sides)");
    assertEquals(0, app.ifcImportSmallObjectExcludedCount);
    assertEquals(0, app.ifcImportFurnitureExcludedCount);
  }

  @Test
  void importObjectsIFC_kitchenApplianceBuildingElementProxy_isExcluded () throws IOException {
    // Checked against a real Revit export: every one of its own kitchen
    // appliances (branded "Miele") came through as
    // IfcBuildingElementProxy, large enough that the size filter alone
    // would never catch them - needs a Name/ObjectType word match
    // instead. One name per word-group this feature recognizes,
    // including both of the two-word conjunctions (deliberately not
    // bare "washer"/"range"/"hood" - too likely to mean something else
    // out of context).
    String[] applianceNames = {
      "Miele Oven H 5681 BP", "Miele Induction Cooktop KM 6350 LPT",
      "Miele Built-in Rangehood DA 2210", "Miele Built-under Dishwasher G 4101 U CS",
      "Miele MasterCool Fridge/Freezer KF 1911 Vi", "Miele Built-in Microwave M 8260-2",
      "Miele Tumble Dryer T 7944 C", "Miele Washing Machine W 5820 WPS",
      "Range Hood Custom"
    };
    for (String name : applianceNames) {
      Path f = ifcFile("ifc-appliance-" + name.hashCode(), """
          #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,0.8,0.8);
          #2=IFCDIRECTION((0.,0.,1.));
          #3=IFCEXTRUDEDAREASOLID(#1,$,#2,0.9);
          #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
          #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
          #6=IFCBUILDINGELEMENTPROXY('guid-1',$,'""" + name + """
          ',$,$,$,#5);
          """
      );

      app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

      assertEquals(0, app.allFaces.nodes.length, "'" + name + "' should be excluded as a kitchen appliance, even at 0.9m (too large for the size filter alone)");
      assertEquals(1, app.ifcImportFurnitureExcludedCount, "'" + name + "'");
    }
  }

  @Test
  void importObjectsIFC_cabinetOrStorageBuildingElementProxy_isExcluded () throws IOException {
    Path f = ifcFile("ifc-cabinet-proxy-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,1.5,0.4);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,0.9);
        #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCBUILDINGELEMENTPROXY('guid-1',$,'Pantry Cabinet',$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.ifcImportFurnitureExcludedCount);
  }

  @Test
  void importObjectsIFC_flowTerminalBathroomFixture_isExcluded () throws IOException {
    // Checked against a real Revit export: its own sink, faucet,
    // bathtub and lavatory instances all came through as
    // IfcFlowTerminal, not the more specific IfcSanitaryTerminal -
    // a known Revit IFC-export behavior.
    Path f = ifcFile("ifc-flow-terminal-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCFLOWTERMINAL('guid-1',$,'Bathtub-TOTO-Nexus-FBF794S',$,'Bathtub-TOTO-Nexus-FBF794S',$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.ifcImportFurnitureExcludedCount);
  }

  @Test
  void importObjectsIFC_sanitaryTerminal_isExcluded () throws IOException {
    // IfcSanitaryTerminal - IFC's own dedicated entity for the same
    // kind of fixture, for files from tools that do use it.
    Path f = ifcFile("ifc-sanitary-terminal-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCSANITARYTERMINAL('guid-1',$,'Toilet',$,$,$,#11,$,.TOILETPAN.);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.ifcImportFurnitureExcludedCount);
  }

  @Test
  void importObjectsIFC_ambiguousBareWordsDoNotFalselyExcludeUnrelatedProxies () throws IOException {
    // "range"/"washer"/"hood" alone must never trigger this exclusion -
    // each too likely to mean something else out of context (an
    // operating range, a mechanical fastener, a car's hood).
    String[] unrelatedNames = {"Operating Range Sensor", "Flat Washer M10", "Car Hood Panel"};
    for (String name : unrelatedNames) {
      Path f = ifcFile("ifc-ambiguous-" + name.hashCode(), """
          #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,0.3,0.3);
          #2=IFCDIRECTION((0.,0.,1.));
          #3=IFCEXTRUDEDAREASOLID(#1,$,#2,0.3);
          #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
          #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
          #6=IFCBUILDINGELEMENTPROXY('guid-1',$,'""" + name + """
          ',$,$,$,#5);
          """
      );

      app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

      // A 0.3m cube is also under the small-object size threshold, so
      // this only proves the *appliance/cabinet* exclusion didn't fire -
      // ifcImportFurnitureExcludedCount, not Faces/allPoints, is the
      // meaningful assertion here.
      assertEquals(0, app.ifcImportFurnitureExcludedCount, "'" + name + "' shouldn't be excluded as an appliance/cabinet");
    }
  }

  @Test
  void importObjectsIFC_smallNonProxyProduct_isNotExcluded_onlyBuildingElementProxyIs () throws IOException {
    // The same tiny 0.1m cube, but as an IfcFurnishingElement - already
    // excluded wholesale by the furniture toggle regardless of size -
    // and as an IfcWall, which should never be size-excluded at all.
    Path f = ifcFile("ifc-small-nonproxy-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,0.1,0.1);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,0.1);
        #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCWALL('guid-1',$,$,$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "a tiny IfcWall should still import - the size exclusion only applies to IfcBuildingElementProxy");
  }

  @Test
  void importObjectsIFC_smallBuildingElementProxyDoesNotDisruptTheWallMaterialCycleOrGroupCount () throws IOException {
    Path f = ifcFile("ifc-small-proxy-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,0.1,0.1);
        #21=IFCDIRECTION((0.,0.,1.));
        #22=IFCEXTRUDEDAREASOLID(#20,$,#21,0.1);
        #23=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#22));
        #24=IFCPRODUCTDEFINITIONSHAPE($,$,(#23));
        #25=IFCBUILDINGELEMENTPROXY('guid-2',$,'Vase',$,$,$,#24);
        #30=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length, "only the two walls' faces should be promoted");
    assertEquals(1, app.allFaces.options[0][0], "first wall: material cycle starts at 1");
    assertEquals(2, app.allFaces.options[1][0], "second wall: material cycle continues at 2, not disrupted by the excluded vase");
  }

  @Test
  void importObjectsIFC_pointIndicesStayCorrect_whenASmallObjectIsExcludedBetweenTwoWalls () throws IOException {
    // The trickiest part of the per-product staging/promotion refactor:
    // the excluded vase's own points must never "use up" any part of
    // the final index space, so the second wall's points land exactly
    // where they would have if the vase had never been in the file.
    Path f = ifcFile("ifc-small-proxy-indices-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,0.1,0.1);
        #21=IFCDIRECTION((0.,0.,1.));
        #22=IFCEXTRUDEDAREASOLID(#20,$,#21,0.1);
        #23=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#22));
        #24=IFCPRODUCTDEFINITIONSHAPE($,$,(#23));
        #25=IFCBUILDINGELEMENTPROXY('guid-2',$,'Vase',$,$,$,#24);
        #101=IFCCARTESIANPOINT((10.,0.,0.));
        #102=IFCCARTESIANPOINT((11.,0.,0.));
        #103=IFCCARTESIANPOINT((11.,1.,0.));
        #104=IFCCARTESIANPOINT((10.,1.,0.));
        #105=IFCPOLYLOOP((#101,#102,#103,#104));
        #106=IFCFACEOUTERBOUND(#105,.T.);
        #107=IFCFACE((#106));
        #108=IFCCLOSEDSHELL((#107));
        #109=IFCFACETEDBREP(#108);
        #110=IFCSHAPEREPRESENTATION($,'Body','Brep',(#109));
        #111=IFCPRODUCTDEFINITIONSHAPE($,$,(#110));
        #112=IFCWALL('guid-3',$,$,$,$,$,#111);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(8, app.allPoints.getLength(), "4 points per wall, none from the excluded vase");
    assertEquals(2, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{4, 5, 6, 7}, app.allFaces.nodes[1], "second wall's indices should pick up right where the first wall's left off");
    assertEquals(10f, app.allPoints.getX(4), 0.0001f);
  }

  // ================= bulk point/face queuing (performance fix) ===============

  @Test
  void importObjectsIFC_groupFaceRangesAreExactAfterBulkFlush_oneFaceThenSixFaces () throws IOException {
    // A single-face product followed by a 6-face extrusion - checks
    // allGroups.Faces[][] directly, the part of the queue-then-flush
    // refactor (see ifcQueuePoint()/ifcQueueFace()/
    // ifcFlushPendingGeometry() in import_objects_IFC.pde) most at risk
    // of an off-by-one, since group start/stop indices are now stamped
    // against "virtual" (not-yet-real) face indices during the import
    // and only become real once everything is flushed at the end.
    Path f = ifcFile("ifc-group-ranges-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2.,4.);
        #21=IFCDIRECTION((0.,0.,1.));
        #22=IFCEXTRUDEDAREASOLID(#20,$,#21,3.);
        #23=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#22));
        #24=IFCPRODUCTDEFINITIONSHAPE($,$,(#23));
        #25=IFCWALL('guid-2',$,$,$,$,$,#24);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(7, app.allFaces.nodes.length, "1 (wall) + 6 (extrusion: 2 caps + 4 sides)");
    assertEquals(2, app.allGroups.num);
    assertEquals(0, app.allGroups.getStart_Face(0));
    assertEquals(0, app.allGroups.getStop_Face(0));
    assertEquals(1, app.allGroups.getStart_Face(1));
    assertEquals(6, app.allGroups.getStop_Face(1));
  }

  @Test
  void importObjectsIFC_pointIndicesAreExactAfterBulkFlush_acrossMultipleProducts () throws IOException {
    // Two separate 4-point faces from two separate products - every
    // vertex should land at the right index once everything is flushed,
    // not just the right count.
    Path f = ifcFile("ifc-point-indices-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #101=IFCCARTESIANPOINT((10.,0.,0.));
        #102=IFCCARTESIANPOINT((11.,0.,0.));
        #103=IFCCARTESIANPOINT((11.,1.,0.));
        #104=IFCCARTESIANPOINT((10.,1.,0.));
        #105=IFCPOLYLOOP((#101,#102,#103,#104));
        #106=IFCFACEOUTERBOUND(#105,.T.);
        #107=IFCFACE((#106));
        #108=IFCCLOSEDSHELL((#107));
        #109=IFCFACETEDBREP(#108);
        #110=IFCSHAPEREPRESENTATION($,'Body','Brep',(#109));
        #111=IFCPRODUCTDEFINITIONSHAPE($,$,(#110));
        #112=IFCWALL('guid-2',$,$,$,$,$,#111);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(8, app.allPoints.getLength());
    assertEquals(2, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
    assertArrayEquals(new int[]{4, 5, 6, 7}, app.allFaces.nodes[1]);
    assertEquals(10f, app.allPoints.getX(4), 0.0001f, "second product's first point should start right after the first product's four");
  }

  @Test
  void importObjectsIFC_bulkFlushAppendsAfterPreExistingGeometry_doesNotOverwriteIt () throws IOException {
    // Importing into a scene that already has geometry (e.g. a second
    // IFC import in the same session) - the flush must append after
    // whatever already exists, not overwrite it. Build the "pre-
    // existing" geometry with a first import, then import again and
    // check the first import's own points/faces are untouched.
    Path f1 = ifcFile("ifc-preexisting-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        """
    );
    app.import_objects_IFC(f1.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    assertEquals(4, app.allPoints.getLength(), "setup check");
    assertEquals(1, app.allFaces.nodes.length, "setup check");

    Path f2 = ifcFile("ifc-second-import-test", """
        #1=IFCCARTESIANPOINT((50.,50.,0.));
        #2=IFCCARTESIANPOINT((51.,50.,0.));
        #3=IFCCARTESIANPOINT((51.,51.,0.));
        #4=IFCCARTESIANPOINT((50.,51.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-2',$,$,$,$,$,#11);
        """
    );
    app.import_objects_IFC(f2.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(8, app.allPoints.getLength());
    assertEquals(2, app.allFaces.nodes.length);
    // the first import's own points/faces should be exactly as they were
    assertEquals(0f, app.allPoints.getX(0), 0.0001f, "first import's own point 0 should be untouched");
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0], "first import's own face should be untouched");
    // the second import's geometry should be appended after it
    assertEquals(50f, app.allPoints.getX(4), 0.0001f);
    assertArrayEquals(new int[]{4, 5, 6, 7}, app.allFaces.nodes[1]);
  }

  // ================= people: human/entourage figures, not imported meshes ====

  @Test
  void importObjectsIFC_ifcActor_isPlacedAsANativePerson_notItsMappedMesh () throws IOException {
    Path f = ifcFile("ifc-actor-test", """
        #1=IFCCARTESIANPOINT((3.,4.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #10=IFCCARTESIANPOINT((0.,0.,0.));
        #11=IFCCARTESIANPOINT((1.,0.,0.));
        #12=IFCCARTESIANPOINT((1.,1.,0.));
        #13=IFCPOLYLOOP((#10,#11,#12));
        #14=IFCFACEOUTERBOUND(#13,.T.);
        #15=IFCFACE((#14));
        #16=IFCCLOSEDSHELL((#15));
        #17=IFCFACETEDBREP(#16);
        #18=IFCSHAPEREPRESENTATION($,'Body','Brep',(#17));
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCREPRESENTATIONMAP(#21,#18);
        #30=IFCCARTESIANPOINT((0.,0.,0.));
        #31=IFCCARTESIANTRANSFORMATIONOPERATOR3D($,$,#30,$,$);
        #32=IFCMAPPEDITEM(#22,#31);
        #33=IFCSHAPEREPRESENTATION($,'Body','MappedRepresentation',(#32));
        #34=IFCPRODUCTDEFINITIONSHAPE($,$,(#33));
        #35=IFCACTOR('guid-1',$,$,$,$,#3,#34);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "the actor's own mapped mesh should not be imported as Faces");
    assertEquals(1, app.allModel2Ds.num);
    assertEquals(3f, app.allModel2Ds.XYZS[0][0], 0.0001f, "x");
    assertEquals(4f, app.allModel2Ds.XYZS[0][1], 0.0001f, "y");
    assertEquals(2.5f, app.allModel2Ds.XYZS[0][3], 0.0001f, "fixed height 2.5, same as \"Person\"'s own default");
  }

  @Test
  void importObjectsIFC_buildingElementProxyWithHumanObjectType_isPlacedAsAPerson () throws IOException {
    Path f = ifcFile("ifc-proxy-human-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #4=IFCBUILDINGELEMENTPROXY('guid-1',$,$,$,'Human',#3,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allModel2Ds.num, "a Human-ObjectType proxy should be placed even with no Representation of its own");
  }

  @Test
  void importObjectsIFC_archvisionRpcHumanFigures_arePlacedAsNativePeople_notTheirMesh () throws IOException {
    // Archvision RPC ("Rich Photorealistic Content") is a widely-used
    // Revit entourage plugin - checked directly against a real Revit
    // export, whose own IfcBuildingElementProxy instances used exactly
    // this "RPC Male:<name>"/"RPC Female:<name>" pattern for its human
    // entourage figures, each carrying a real mapped mesh that should
    // be replaced, not imported.
    Path f = ifcFile("ifc-rpc-person-test", """
        #1=IFCCARTESIANPOINT((2.,3.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #10=IFCCARTESIANPOINT((0.,0.,0.));
        #11=IFCCARTESIANPOINT((1.,0.,0.));
        #12=IFCCARTESIANPOINT((1.,1.,0.));
        #13=IFCPOLYLOOP((#10,#11,#12));
        #14=IFCFACEOUTERBOUND(#13,.T.);
        #15=IFCFACE((#14));
        #16=IFCCLOSEDSHELL((#15));
        #17=IFCFACETEDBREP(#16);
        #18=IFCSHAPEREPRESENTATION($,'Body','Brep',(#17));
        #19=IFCPRODUCTDEFINITIONSHAPE($,$,(#18));
        #20=IFCBUILDINGELEMENTPROXY('guid-1','owner','RPC Female:YinYin:954641',$,'RPC Female:YinYin',#3,#19,'954641',.NOTDEFINED.);
        #30=IFCCARTESIANPOINT((5.,6.,0.));
        #31=IFCAXIS2PLACEMENT3D(#30,$,$);
        #32=IFCLOCALPLACEMENT($,#31);
        #33=IFCBUILDINGELEMENTPROXY('guid-2','owner','RPC Male:Alex:954779',$,'RPC Male:Alex',#32,#19,'954779',.NOTDEFINED.);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "neither RPC figure's own mapped mesh should be imported as Faces");
    assertEquals(2, app.allModel2Ds.num);
    assertEquals(2f, app.allModel2Ds.XYZS[0][0], 0.0001f, "RPC Female's x");
    assertEquals(3f, app.allModel2Ds.XYZS[0][1], 0.0001f, "RPC Female's y");
    assertEquals(5f, app.allModel2Ds.XYZS[1][0], 0.0001f, "RPC Male's x");
    assertEquals(6f, app.allModel2Ds.XYZS[1][1], 0.0001f, "RPC Male's y");
  }

  @Test
  void importObjectsIFC_rpcCarAndRpcTree_areNotMistakenForPeople () throws IOException {
    // The same "RPC <Category>:<Name>" convention names RPC cars and
    // trees too - a car should import as real geometry (there's no
    // native substitute for it, unlike a person or a tree), and a tree
    // should still go through the existing tree placement, not people.
    Path f = ifcFile("ifc-rpc-nonperson-test", """
        #1=IFCRECTANGLEPROFILEDEF(.AREA.,$,$,2.,2.);
        #2=IFCDIRECTION((0.,0.,1.));
        #3=IFCEXTRUDEDAREASOLID(#1,$,#2,2.);
        #4=IFCSHAPEREPRESENTATION($,'Body','SweptSolid',(#3));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCBUILDINGELEMENTPROXY('guid-1',$,'M_RPC Beetle:M_RPC Beetle:950367',$,'M_RPC Beetle:M_RPC Beetle',$,#5,'950367',.NOTDEFINED.);
        #11=IFCCARTESIANPOINT((0.,0.,0.));
        #12=IFCAXIS2PLACEMENT3D(#11,$,$);
        #13=IFCLOCALPLACEMENT($,#12);
        #14=IFCBUILDINGELEMENTPROXY('guid-2',$,'RPC Tree - Deciduous:Honey Locust - 25',$,'RPC Tree - Deciduous:Honey Locust - 25',#13,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(6, app.allFaces.nodes.length, "the RPC car should import as real geometry (2 caps + 4 sides)");
    assertEquals(1, app.allModel2Ds.num, "only the tree should land in allModel2Ds");
    assertEquals(1, app.ifcImportTreeCount, "the RPC tree should go through tree placement");
    assertEquals(0, app.ifcImportPersonCount, "neither the car nor the tree is a person");
  }

  @Test
  void importObjectsIFC_typeDefinitionEntities_areNeverCountedAsTreesOrPeople_onlyTheirInstancesAre () throws IOException {
    // Regression test for a real bug found while verifying the RPC
    // person fix against an actual Revit export: an IfcXxxType entity
    // (a type DEFINITION several placed instances can share, never
    // itself a placed instance) shares enough of IfcRoot's own
    // Name/Description prefix to pass ifcLooksLikeAProduct() - so
    // before ifcLooksLikeAProduct() itself excluded *TYPE entities, a
    // type definition named like a tree or an RPC person was being
    // swept in and counted/placed as a bogus extra one, alongside its
    // own real placed instance. Deliberately exercises both the tree
    // and the person path with one type entity each, alongside one real
    // instance of each, so a regression here fails loudly either way.
    Path f = ifcFile("ifc-type-entity-test", """
        #1=IFCBUILDINGELEMENTPROXYTYPE('type-guid-1',$,'RPC Tree - Deciduous:Honey Locust - 25',$,$,(#50),(#51),'1',$,.NOTDEFINED.);
        #10=IFCCARTESIANPOINT((0.,0.,0.));
        #11=IFCAXIS2PLACEMENT3D(#10,$,$);
        #12=IFCLOCALPLACEMENT($,#11);
        #13=IFCBUILDINGELEMENTPROXY('guid-1',$,'RPC Tree - Deciduous:Honey Locust - 25:100',$,'RPC Tree - Deciduous:Honey Locust - 25',#12,$);
        #20=IFCBUILDINGELEMENTPROXYTYPE('type-guid-2',$,'RPC Female:YinYin',$,$,(#52),(#53),'2',$,.NOTDEFINED.);
        #30=IFCCARTESIANPOINT((5.,0.,0.));
        #31=IFCAXIS2PLACEMENT3D(#30,$,$);
        #32=IFCLOCALPLACEMENT($,#31);
        #33=IFCBUILDINGELEMENTPROXY('guid-2',$,'RPC Female:YinYin:200',$,'RPC Female:YinYin',#32,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.ifcImportTreeCount, "only the real tree instance, not its type definition too");
    assertEquals(1, app.ifcImportPersonCount, "only the real RPC person instance, not its type definition too");
    assertEquals(2, app.allModel2Ds.num, "one tree + one person, nothing extra from either type entity");
  }

  @Test
  void importObjectsIFC_mepMaleOrFemaleConnector_isNotMistakenForAnRpcPerson () throws IOException {
    // "Male"/"Female" alone (common MEP connector/adapter/coupling
    // terminology) must never trigger person detection on their own -
    // only "rpc" together with "male"/"female" should.
    Path f = ifcFile("ifc-mep-male-female-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCBUILDINGELEMENTPROXY('guid-1',$,'Male Adapter Coupling',$,'Male Adapter Coupling',$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "a plain MEP male connector should import as real geometry, not a person");
    assertEquals(0, app.allModel2Ds.num);
  }

  @Test
  void importObjectsIFC_buildingElementProxyWithEntourageOrScaleFigureObjectType_isAlsoPlacedAsAPerson () throws IOException {
    Path f = ifcFile("ifc-proxy-entourage-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #4=IFCBUILDINGELEMENTPROXY('guid-1',$,$,$,'Entourage',#3,$);
        #11=IFCCARTESIANPOINT((5.,0.,0.));
        #12=IFCAXIS2PLACEMENT3D(#11,$,$);
        #13=IFCLOCALPLACEMENT($,#12);
        #14=IFCBUILDINGELEMENTPROXY('guid-2',$,$,$,'Scale Figure',#13,$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allModel2Ds.num);
  }

  @Test
  void importObjectsIFC_productOnHumanPresentationLayer_isPlacedAsAPerson () throws IOException {
    Path f = ifcFile("ifc-layer-humn-test", """
        #1=IFCCARTESIANPOINT((7.,8.,0.));
        #2=IFCAXIS2PLACEMENT3D(#1,$,$);
        #3=IFCLOCALPLACEMENT($,#2);
        #10=IFCCARTESIANPOINT((0.,0.,0.));
        #11=IFCCARTESIANPOINT((1.,0.,0.));
        #12=IFCCARTESIANPOINT((1.,1.,0.));
        #13=IFCPOLYLOOP((#10,#11,#12));
        #14=IFCFACEOUTERBOUND(#13,.T.);
        #15=IFCFACE((#14));
        #16=IFCCLOSEDSHELL((#15));
        #17=IFCFACETEDBREP(#16);
        #18=IFCSHAPEREPRESENTATION($,'Body','Brep',(#17));
        #19=IFCPRODUCTDEFINITIONSHAPE($,$,(#18));
        #20=IFCBUILDINGELEMENTPROXY('guid-1',$,$,$,$,#3,#19);
        #30=IFCPRESENTATIONLAYERASSIGNMENT('A-PROP-HUMN',$,(#18),$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "the layer-tagged geometry should not be imported as Faces");
    assertEquals(1, app.allModel2Ds.num);
    assertEquals(7f, app.allModel2Ds.XYZS[0][0], 0.0001f, "x");
    assertEquals(8f, app.allModel2Ds.XYZS[0][1], 0.0001f, "y");
  }

  @Test
  void importObjectsIFC_productNotOnHumanLayer_importsNormally () throws IOException {
    Path f = ifcFile("ifc-layer-unrelated-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCPRESENTATIONLAYERASSIGNMENT('A-WALL',$,(#10),$);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "an unrelated layer name shouldn't trigger person detection");
    assertEquals(0, app.allModel2Ds.num);
  }

  @Test
  void importObjectsIFC_peopleDoNotDisruptTheWallMaterialCycleOrGroupCount () throws IOException {
    Path f = ifcFile("ifc-person-cycle-test", """
        #1=IFCCARTESIANPOINT((0.,0.,0.));
        #2=IFCCARTESIANPOINT((1.,0.,0.));
        #3=IFCCARTESIANPOINT((1.,1.,0.));
        #4=IFCCARTESIANPOINT((0.,1.,0.));
        #5=IFCPOLYLOOP((#1,#2,#3,#4));
        #6=IFCFACEOUTERBOUND(#5,.T.);
        #7=IFCFACE((#6));
        #8=IFCCLOSEDSHELL((#7));
        #9=IFCFACETEDBREP(#8);
        #10=IFCSHAPEREPRESENTATION($,'Body','Brep',(#9));
        #11=IFCPRODUCTDEFINITIONSHAPE($,$,(#10));
        #12=IFCWALL('guid-1',$,$,$,$,$,#11);
        #20=IFCCARTESIANPOINT((0.,0.,0.));
        #21=IFCAXIS2PLACEMENT3D(#20,$,$);
        #22=IFCLOCALPLACEMENT($,#21);
        #23=IFCACTOR('guid-2',$,$,$,$,#22,$);
        #30=IFCWALL('guid-3',$,$,$,$,$,#11);
        """
    );

    app.import_objects_IFC(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    // Every candidate product - including the actor - still starts its
    // own group, same as a tree or anything else: group 1 (the actor's
    // own) ends up with an empty Faces range ([x,-1], the same "no
    // faces at all" sentinel an ordinary empty IfcProduct would leave)
    // and its own Model2Ds range instead.
    assertEquals(3, app.allGroups.num);
    assertEquals(0, app.allGroups.getStart_Face(0));
    assertEquals(0, app.allGroups.getStop_Face(0));
    assertTrue(app.allGroups.getStart_Face(1) > app.allGroups.getStop_Face(1), "the actor's own group should have an empty Faces range");
    assertEquals(0, app.allGroups.getStart_Model2D(1));
    assertEquals(0, app.allGroups.getStop_Model2D(1));
    assertEquals(1, app.allFaces.options[0][0], "first wall: material cycle starts at 1");
    assertEquals(2, app.allFaces.options[1][0], "second wall: material cycle continues at 2, not disrupted by the actor in between");
    assertEquals(1, app.allModel2Ds.num);
  }
}
