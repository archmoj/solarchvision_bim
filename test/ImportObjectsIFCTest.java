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
    Path f = ifcFile("ifc-skip-test", """
        #1=IFCMAPPEDITEM(#2,#3);
        #4=IFCSHAPEREPRESENTATION($,'Body','MappedRepresentation',(#1));
        #5=IFCPRODUCTDEFINITIONSHAPE($,$,(#4));
        #6=IFCWALL('guid-1',$,$,$,$,$,#5);
        """
    );

    app.import_objects_IFC(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length, "IfcMappedItem isn't supported yet, so no geometry should appear");
    assertEquals(1, app.ifcImportSkippedCount);
    assertEquals(Integer.valueOf(1), app.ifcImportSkippedReasons.get("IFCMAPPEDITEM"));
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
}
