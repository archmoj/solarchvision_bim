import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_DAE() is a plain COLLADA(.dae)-format XML parser plus
// calls to allPoints.create()/allFaces.create()/allGroups.beginNewGroup() -
// no WIN3D.graphics, no PImage, so like ImportObjectsOBJTest.java's own
// import_objects_OBJ() tests, this is directly testable from a bare,
// never-setup()'d instance with no extra seeding.
//
// Each test below writes the smallest COLLADA document that exercises one
// path - see importDae.pde's own file-header comment for exactly
// which elements/attributes each path corresponds to, and for the
// documented v1-scope limitations (only <triangles>/<polylist>, only the
// VERTEX-semantic input, no materials of its own) a couple of tests below
// confirm.
class ImportObjectsDAETest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path daeFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".dae");
    Files.writeString(f, body);
    return f;
  }

  // A one-node, one-geometry, one-<triangles>-primitive document - the
  // smallest shape import_objects_DAE() can actually read anything from:
  // <scene><instance_visual_scene> -> <visual_scene><node> ->
  // <instance_geometry> -> <geometry><mesh><vertices>/<triangles>.
  private String oneTriangleDocument () {
    return """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="9">0 0 0 1 0 0 1 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2</p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """;
  }

  // ================= <triangles> ==============================================

  @Test
  void importObjectsDAE_triangles_importsOneTriangleFace () throws IOException {
    Path f = daeFile("dae-triangles-test", oneTriangleDocument());

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0]);
  }

  @Test
  void importObjectsDAE_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path f = daeFile("dae-transform-test", oneTriangleDocument());

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    // vertex 1 (1,0,0): (cx + sx*x, cy + sy*y, cz + sz*z) = (10+2, 20, 30)
    assertEquals(12f, app.allPoints.getX(1), 0.0001f);
    assertEquals(20f, app.allPoints.getY(1), 0.0001f);
    assertEquals(30f, app.allPoints.getZ(1), 0.0001f);
  }

  // ================= <polylist> - variable vertex count per polygon ============

  @Test
  void importObjectsDAE_polylist_handlesPolygonsWithMoreThanThreeVertices () throws IOException {
    Path f = daeFile("dae-polylist-quad-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="12">0 0 0 1 0 0 1 1 0 0 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <polylist count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <vcount>4</vcount>
                  <p>0 1 2 3</p>
                </polylist>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length, "a 4-vertex <polylist> polygon should stay a quad, not split into triangles");
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
  }

  // ================= multi-input primitives: only VERTEX's own offset is read =

  @Test
  void importObjectsDAE_triangles_withNormalAndTexcoordInputs_stillReadsOnlyThePositionIndex () throws IOException {
    // Three interleaved inputs (NORMAL offset 1, TEXCOORD offset 2, VERTEX
    // offset 0) - stride is 3, so only every 3rd number in <p> is the
    // position index this importer actually uses; see
    // daePrimitiveStride()'s own comment.
    Path f = daeFile("dae-multi-input-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="9">0 0 0 1 0 0 1 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <input semantic="NORMAL" source="#geom1-normals" offset="1"/>
                  <input semantic="TEXCOORD" source="#geom1-uvs" offset="2"/>
                  <p>0 0 0 1 0 0 2 0 0</p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allFaces.nodes[0], "stride 3, offset 0 - position indices 0,1,2 out of every 3rd slot");
  }

  // ================= node hierarchy and transforms ============================

  @Test
  void importObjectsDAE_nodeTranslate_isAppliedToThatNodesOwnGeometry () throws IOException {
    Path f = daeFile("dae-node-translate-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="3">0 0 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="0">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p></p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <translate>5 6 7</translate>
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPoints.getLength());
    assertEquals(5f, app.allPoints.getX(0), 0.0001f);
    assertEquals(6f, app.allPoints.getY(0), 0.0001f);
    assertEquals(7f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsDAE_nestedNode_composesItsOwnTransformOntoItsParentsOwn () throws IOException {
    Path f = daeFile("dae-nested-node-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="3">0 0 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="0">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p></p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="parent">
                <translate>10 0 0</translate>
                <node id="child">
                  <translate>0 1 0</translate>
                  <instance_geometry url="#geom1"/>
                </node>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPoints.getLength());
    assertEquals(10f, app.allPoints.getX(0), 0.0001f, "parent's own translate");
    assertEquals(1f, app.allPoints.getY(0), 0.0001f, "composed with the child's own translate");
  }

  // ================= grouping/material cycling: one per <instance_geometry> ===

  @Test
  void importObjectsDAE_oneGroupPerInstanceGeometry_whenNotAddingToLastGroup () throws IOException {
    Path f = daeFile("dae-groups-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="9">0 0 0 1 0 0 1 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2</p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
              <node id="node2">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num);
    assertEquals(1, app.allFaces.options[0][0], "m == -1 cycles material once per instance_geometry, starting at 1");
    assertEquals(2, app.allFaces.options[1][0]);
  }

  @Test
  void importObjectsDAE_doesNotStartNewGroups_whenAddingToLastGroup () throws IOException {
    app.addToLastGroup = true;
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // the "last group" to add into

    Path f = daeFile("dae-addtolastgroup-test", oneTriangleDocument());

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num, "the one instance_geometry should have added to the one pre-existing group, not started a new one");
  }

  // ================= unsupported/skipped shapes ================================

  @Test
  void importObjectsDAE_curvesOffByDefault_linesPrimitiveIsSkippedWithoutThrowing () throws IOException {
    // <lines> is a real COLLADA primitive type, but daeImportCurves
    // defaults to false, so it should still be skipped entirely, not
    // crash the whole import - see the "withCurvesOn" tests below for
    // the same document with the toggle flipped on.
    Path f = daeFile("dae-unsupported-primitive-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="6">0 0 0 1 0 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <lines count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1</p>
                </lines>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    assertDoesNotThrow(() -> {
      app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length, "a <lines> primitive carries no face geometry this importer reads");
    assertEquals(0, app.allPolylines.nodes.length, "daeImportCurves defaults to false: nothing should land in allPolylines either");
  }

  // ================= <lines>/<linestrips> (daeImportCurves) ====================
  // Mirrors ImportObjectsGLBTest.java's own "line primitives" section -
  // see importDae.pde's own daePrimitiveLines()/daePrimitiveLinestrips()
  // comments for exactly what each does and why.

  @Test
  void importObjectsDAE_lines_withCurvesOn_importsOneTwoPointPolylinePerPair () throws IOException {
    app.daeImportCurves = true;

    Path f = daeFile("dae-lines-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="12">0 0 0 1 0 0 1 1 0 0 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <lines count="2">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2 3</p>
                </lines>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(2, app.allPolylines.nodes.length, "<lines> draws disconnected segments: one pair, one Polyline each");
    assertArrayEquals(new int[]{0, 1}, app.allPolylines.nodes[0]);
    assertArrayEquals(new int[]{2, 3}, app.allPolylines.nodes[1]);
    assertEquals(0, app.allPolylines.getClose(0));
    assertEquals(0, app.allPolylines.getClose(1));
  }

  @Test
  void importObjectsDAE_linestrips_withCurvesOn_importsOneOpenPolylinePerP () throws IOException {
    app.daeImportCurves = true;

    Path f = daeFile("dae-linestrips-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="18">0 0 0 1 0 0 1 1 0 2 0 0 2 1 0 2 2 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <linestrips count="2">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2</p>
                  <p>3 4 5</p>
                </linestrips>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allPolylines.nodes.length, "two <p> elements inside <linestrips> should each become their own Polyline");
    assertArrayEquals(new int[]{0, 1, 2}, app.allPolylines.nodes[0]);
    assertArrayEquals(new int[]{3, 4, 5}, app.allPolylines.nodes[1]);
    assertEquals(0, app.allPolylines.getClose(0));
    assertEquals(0, app.allPolylines.getClose(1));
  }

  @Test
  void importObjectsDAE_linestrip_repeatingTheFirstVertexAsTheLast_isReadAsAClosedLoop () throws IOException {
    app.daeImportCurves = true;

    Path f = daeFile("dae-linestrip-closed-test", """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="9">0 0 0 1 0 0 1 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <linestrips count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2 0</p>
                </linestrips>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """
    );

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allPolylines.nodes.length);
    assertArrayEquals(new int[]{0, 1, 2}, app.allPolylines.nodes[0], "the repeated closing vertex should be dropped, not kept as a 4th node");
    assertEquals(1, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsDAE_triangles_areStillReadAlongsideLinesWhenCurvesAreOn () throws IOException {
    app.daeImportCurves = true;

    Path f = daeFile("dae-triangles-and-lines-test", oneTriangleDocument());

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "turning curves on should not stop <triangles> from importing");
    assertEquals(0, app.allPolylines.nodes.length);
  }

  @Test
  void importObjectsDAE_noVisualScene_doesNotThrow () throws IOException {
    Path f = daeFile("dae-no-scene-test", "<COLLADA><library_geometries></library_geometries></COLLADA>");

    assertDoesNotThrow(() -> {
      app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsOBJTest.java's own identical test already
  // makes explicit for import_objects_OBJ() - see that file's own comment.

  @Test
  void importObjectsDAE_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = daeFile("dae-headless-test", oneTriangleDocument());

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }

  // ================= Step 5: extraParams captured from node/geometry name =======

  @Test
  void importObjectsDAE_triangles_capturesTheInstancingNodesOwnNameAsExtraParams () throws IOException {
    String document = """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="9">0 0 0 1 0 0 1 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2</p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1" name="Roof">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """;
    Path f = daeFile("dae-node-name-extraparams-test", document);

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"name\": \"Roof\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsDAE_triangles_fallsBackToTheGeometrysOwnNameWhenTheNodeHasNone () throws IOException {
    String document = """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1" name="RoofGeom">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="9">0 0 0 1 0 0 1 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2</p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node>
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """;
    Path f = daeFile("dae-geometry-name-extraparams-test", document);

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"name\": \"RoofGeom\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsDAE_importExtraParamsFalse_suppressesCaptureEvenWithARealName () throws IOException {
    app.importExtraParams = false;

    String document = """
        <COLLADA>
          <library_geometries>
            <geometry id="geom1">
              <mesh>
                <source id="geom1-positions">
                  <float_array count="9">0 0 0 1 0 0 1 1 0</float_array>
                </source>
                <vertices id="geom1-vertices">
                  <input semantic="POSITION" source="#geom1-positions"/>
                </vertices>
                <triangles count="1">
                  <input semantic="VERTEX" source="#geom1-vertices" offset="0"/>
                  <p>0 1 2</p>
                </triangles>
              </mesh>
            </geometry>
          </library_geometries>
          <library_visual_scenes>
            <visual_scene id="Scene">
              <node id="node1" name="Roof">
                <instance_geometry url="#geom1"/>
              </node>
            </visual_scene>
          </library_visual_scenes>
          <scene>
            <instance_visual_scene url="#Scene"/>
          </scene>
        </COLLADA>
        """;
    Path f = daeFile("dae-extraparams-off-test", document);

    app.import_objects_DAE(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals("", app.allFaces.getExtraParams(0), "unchecking the shared importExtraParams option (fileSelected.pde) opts out of extraParams capture for a simplified import");
  }
}
