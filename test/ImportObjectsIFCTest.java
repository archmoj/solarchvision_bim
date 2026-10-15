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
  void importObjectsIFC_faceBound_innerLoopIsIgnored_butOuterLoopStillImports () throws IOException {
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

    assertEquals(1, app.allFaces.nodes.length, "the outer boundary should still import as one solid face");
    assertEquals(4, app.allFaces.nodes[0].length);
    assertEquals(1, app.ifcImportHolesIgnoredCount, "the inner IfcFaceBound should be counted as an ignored hole");
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
    // IfcBooleanClippingResult (a documented limitation - boolean
    // operations aren't evaluated) stands in here for "a representation
    // item type this importer genuinely doesn't handle" - IfcMappedItem
    // used to be that case, until it gained its own support; a
    // malformed IfcMappedItem (e.g. a missing RepresentationMap) is
    // covered by its own, more specific test instead.
    Path f = ifcFile("ifc-skip-test", """
        #1=IFCBOOLEANCLIPPINGRESULT(.DIFFERENCE.,#2,#3);
        #4=IFCSHAPEREPRESENTATION($,'Body','Clipping',(#1));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCWALL('guid-1',$,$,$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "IfcBooleanClippingResult isn't supported, so no geometry should appear");
    assertEquals(1, app.ifcImportSkippedCount);
    assertEquals(Integer.valueOf(1), app.ifcImportSkippedReasons.get("IFCBOOLEANCLIPPINGRESULT"));
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
  void importObjectsIFC_ifcSpace_isNeverImportedEvenWithGeometry () throws IOException {
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

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allGroups.num, "IfcSpace shouldn't even start a group");
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
  void importObjectsIFC_ifcSpaceNamedPool_isImportedDespiteIfcSpaceNormallyBeingSkipped () throws IOException {
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
    assertEquals(19, app.allFaces.options[0][0]);
  }

  @Test
  void importObjectsIFC_ordinaryIfcSpaceIsStillSkipped_poolExceptionIsNarrow () throws IOException {
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
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "an ordinary IfcSpace should still be skipped - the pool exception shouldn't widen that");
    assertEquals(0, app.allGroups.num);
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

  // ================= furniture: excluded by default (IFC_IMPORT_FURNITURE) ===

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

    assertEquals(0, app.allFaces.nodes.length, "ordinary furniture should be excluded while IFC_IMPORT_FURNITURE is false");
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
}
