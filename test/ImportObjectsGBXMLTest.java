import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_GBXML() is a plain gbXML-format XML parser plus calls to
// allPoints.create()/allFaces.create()/allGroups.beginNewGroup() - no
// WIN3D.graphics, no PImage, so like ImportObjectsOBJTest.java's own
// import_objects_OBJ() tests, this is directly testable from a bare,
// never-setup()'d instance with no extra seeding.
//
// Each test below writes the smallest gbXML document that exercises one
// path - see importGbxml.pde's own file-header comment for
// exactly which elements/attributes each path corresponds to, and for
// the documented v1-scope limitations (Opening geometry is never
// actually subtracted from its host Surface; Opening's own
// RectangularGeometry, in the host surface's local 2D plane, isn't
// supported; "Air" boundaries are skipped, not imported).
class ImportObjectsGBXMLTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field, which loadStrings()/loadImage()/createInput() check directly - without this they throw "Files must be loaded inside setup() or after it has been called." even though BaseFolder above is already set
  }

  private Path gbxmlFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".xml");
    Files.writeString(f, body);
    return f;
  }

  // ================= PlanarGeometry/PolyLoop - the general case =================

  @Test
  void importObjectsGBXML_planarGeometry_importsAQuadWallSurfaceAsOneNgon () throws IOException {
    Path f = gbxmlFile("gbxml-planar-quad-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="wall1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(4, app.allPoints.getLength());
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length, "a 4-point PolyLoop should stay a quad, not split into triangles");
    assertArrayEquals(new int[]{0, 1, 2, 3}, app.allFaces.nodes[0]);
    assertEquals(1, app.gbxmlImportSurfaceCount);
  }

  @Test
  void importObjectsGBXML_appliesTheOffsetAndScaleToEveryVertex () throws IOException {
    Path f = gbxmlFile("gbxml-transform-real-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="Roof">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>2</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>5</Coordinate><Coordinate>6</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>7</Coordinate><Coordinate>8</Coordinate><Coordinate>9</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    // (cx + sx*x, cy + sy*y, cz + sz*z) for the first point (1,2,3)
    assertEquals(12f, app.allPoints.getX(0), 0.0001f);
    assertEquals(24f, app.allPoints.getY(0), 0.0001f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f);
  }

  // ================= RectangularGeometry fallback ================================

  @Test
  void importObjectsGBXML_rectangularGeometry_isUsedWhenPlanarGeometryIsMissing () throws IOException {
    // Azimuth 0 (north), Tilt 90 (vertical) - this importer's own derived
    // basis puts Width along world +X and Height along world +Z, the
    // outward normal along world +Y - see importGbxml.pde's own
    // gbxmlRectangularGeometryPoints() comment for the full derivation.
    Path f = gbxmlFile("gbxml-rectangular-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="wall1" surfaceType="ExteriorWall">
              <RectangularGeometry>
                <Azimuth>0</Azimuth>
                <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                <Tilt>90</Tilt>
                <Width>4</Width>
                <Height>3</Height>
              </RectangularGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);

    float[][] expected = {{0, 0, 0}, {4, 0, 0}, {4, 0, 3}, {0, 0, 3}};
    for (int i = 0; i < 4; i++) {
      assertEquals(expected[i][0], app.allPoints.getX(i), 0.001f, "point " + i);
      assertEquals(expected[i][1], app.allPoints.getY(i), 0.001f, "point " + i);
      assertEquals(expected[i][2], app.allPoints.getZ(i), 0.001f, "point " + i);
    }
  }

  @Test
  void importObjectsGBXML_planarGeometryIsPreferredOverRectangularGeometry_whenBothArePresent () throws IOException {
    Path f = gbxmlFile("gbxml-planar-preferred-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="wall1" surfaceType="ExteriorWall">
              <RectangularGeometry>
                <Azimuth>0</Azimuth>
                <CartesianPoint><Coordinate>99</Coordinate><Coordinate>99</Coordinate><Coordinate>99</Coordinate></CartesianPoint>
                <Tilt>90</Tilt>
                <Width>4</Width>
                <Height>3</Height>
              </RectangularGeometry>
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>1</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(3, app.allFaces.nodes[0].length, "the explicit PlanarGeometry triangle should win, not the RectangularGeometry quad");
    assertEquals(0f, app.allPoints.getX(0), 0.0001f);
  }

  // ================= Opening ======================================================

  @Test
  void importObjectsGBXML_windowOpening_isImportedAsGlass () throws IOException {
    Path f = gbxmlFile("gbxml-window-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="wall1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
              <Opening id="win1" windowType="FixedWindow">
                <PlanarGeometry>
                  <PolyLoop>
                    <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                    <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                    <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>2</Coordinate></CartesianPoint>
                    <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>2</Coordinate></CartesianPoint>
                  </PolyLoop>
                </PlanarGeometry>
              </Opening>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 7 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length, "the host Surface and its own Opening each become their own face");
    assertEquals(7, app.allFaces.options[0][0], "the host wall keeps the caller's own material");
    assertEquals(app.IFC_MATERIAL_GLASS, app.allFaces.options[1][0], "a window Opening always draws as glass, regardless of m");
    assertEquals(1, app.gbxmlImportOpeningCount);
  }

  @Test
  void importObjectsGBXML_doorOpening_readsAsItsHostSurfacesOwnMaterial () throws IOException {
    Path f = gbxmlFile("gbxml-door-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="wall1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
              <Opening id="door1" windowType="NonSlidingDoor">
                <PlanarGeometry>
                  <PolyLoop>
                    <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                    <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                    <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>2</Coordinate></CartesianPoint>
                  </PolyLoop>
                </PlanarGeometry>
              </Opening>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 7 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(7, app.allFaces.options[0][0]);
    assertEquals(7, app.allFaces.options[1][0], "a door isn't glass - it should read as the same material as its host surface");
  }

  @Test
  void importObjectsGBXML_airOpening_isSkipped () throws IOException {
    Path f = gbxmlFile("gbxml-air-opening-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="wall1" surfaceType="InteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
              <Opening id="opening1" windowType="Air">
                <PlanarGeometry>
                  <PolyLoop>
                    <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                    <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                    <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>2</Coordinate></CartesianPoint>
                  </PolyLoop>
                </PlanarGeometry>
              </Opening>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.nodes.length, "only the host wall should have become a face - the Air opening has no physical construction");
    assertEquals(0, app.gbxmlImportOpeningCount);
    assertEquals(1, app.gbxmlImportAirBoundarySkippedCount);
  }

  // ================= surfaceType -> material =====================================

  @Test
  void importObjectsGBXML_airSurface_isSkippedEntirely () throws IOException {
    Path f = gbxmlFile("gbxml-air-surface-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="Air">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.gbxmlImportSurfaceCount);
    assertEquals(1, app.gbxmlImportAirBoundarySkippedCount);
  }

  @Test
  void importObjectsGBXML_floorSurfaceType_defaultsToConcrete () throws IOException {
    Path f = gbxmlFile("gbxml-floor-material-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="InteriorFloor">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>4</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    // m == -1 (cycle through 1-8) should NOT apply here - a floor always
    // reads as concrete, the same unconditional priority import
    // Ifc.pde's own ifcLooksLikeAFloor() default gets.
    app.import_objects_GBXML(f.toString(), -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(app.IFC_MATERIAL_CONCRETE, app.allFaces.options[0][0]);
  }

  @Test
  void importObjectsGBXML_shadeSurfaceType_defaultsToSteel () throws IOException {
    Path f = gbxmlFile("gbxml-shade-material-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="Shade">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>2</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(app.IFC_MATERIAL_STEEL, app.allFaces.options[0][0]);
  }

  @Test
  void importObjectsGBXML_exteriorWall_hasNoForcedMaterial_fallsBackToCycling () throws IOException {
    Path f = gbxmlFile("gbxml-wall-cycle-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>2</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
            <Surface id="s2" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>2</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allFaces.options[0][0]);
    assertEquals(2, app.allFaces.options[1][0]);
  }

  // ================= lengthUnit ===================================================

  @Test
  void importObjectsGBXML_millimetersLengthUnit_convertsCoordinatesToMetres () throws IOException {
    Path f = gbxmlFile("gbxml-mm-test", """
        <gbXML lengthUnit="Millimeters">
          <Campus>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>1000</Coordinate><Coordinate>2000</Coordinate><Coordinate>3000</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4000</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>4000</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0.001f, app.gbxmlLengthUnitScale, 0.0000001f);
    assertEquals(1f, app.allPoints.getX(0), 0.0001f);
    assertEquals(2f, app.allPoints.getY(0), 0.0001f);
    assertEquals(3f, app.allPoints.getZ(0), 0.0001f);
  }

  @Test
  void importObjectsGBXML_noLengthUnitDeclared_assumesMetres () throws IOException {
    Path f = gbxmlFile("gbxml-no-unit-test", """
        <gbXML>
          <Campus>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>2</Coordinate><Coordinate>3</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>4</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>4</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1f, app.gbxmlLengthUnitScale, 0.0000001f);
  }

  // ================= gbxmlImportOrient: rotate to the project's true north ======

  @Test
  void importObjectsGBXML_cadModelAzimuth_rotatesImportedFacesAroundTheWorldOrigin () throws IOException {
    Path f = gbxmlFile("gbxml-azimuth-rotate-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Location>
              <CADModelAzimuth>90</CADModelAzimuth>
            </Location>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>1</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(90f, app.gbxmlImportNorthRotationAngle, 0.0001f);

    // A 90-degree rotation about Z around the world origin sends
    // (x,y,0) to (-y,x,0) - see importIfc.pde's own
    // ifcRotateImportedModelToTrueNorth()/Rotate3D.rotateAroundVector()'s
    // own comment, reused as-is here (see this file's own header
    // comment).
    assertEquals(0f, app.allPoints.getX(0), 0.001f);
    assertEquals(1f, app.allPoints.getY(0), 0.001f);
    assertEquals(0f, app.allPoints.getX(1), 0.001f);
    assertEquals(2f, app.allPoints.getY(1), 0.001f);
  }

  @Test
  void importObjectsGBXML_cadModelAzimuth_notReadAtAll_whenOrientIsOff () throws IOException {
    app.gbxmlImportOrient = false;

    Path f = gbxmlFile("gbxml-azimuth-off-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Location>
              <CADModelAzimuth>90</CADModelAzimuth>
            </Location>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>2</Coordinate><Coordinate>1</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(0f, app.gbxmlImportNorthRotationAngle, 0.0001f);
    assertEquals(1f, app.allPoints.getX(0), 0.001f, "geometry should be untouched when gbxmlImportOrient is off");
  }

  // ================= gbxmlImportRelocate: navigate to the site's location =======

  @Test
  void importObjectsGBXML_gotoLatLon_navigatesTheStationToTheFilesOwnLocation () throws IOException {
    Path f = gbxmlFile("gbxml-gotolatlon-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Location>
              <Latitude>43.6425</Latitude>
              <Longitude>-79.3869</Longitude>
            </Location>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>1</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNotNull(app.gbxmlImportGotoLatLon);
    assertEquals(43.6425f, app.gbxmlImportGotoLatLon[0], 0.0001f, "latitude");
    assertEquals(-79.3869f, app.gbxmlImportGotoLatLon[1], 0.0001f, "longitude");

    // The actual move is deferred to draw() (solarchvision_bim.pde), not
    // performed synchronously here - see pendingGotoLatLon's own comment
    // (globalFunctions.pde) for why (update_station(), what __SETLATLON__()
    // calls, isn't safe to run on an importer's own thread). This confirms
    // the request was actually QUEUED for draw() to pick up, without
    // calling update_station() here - unsafe in this bare, never-setup()'d
    // test instance.
    assertNotNull(app.pendingGotoLatLon, "the navigation request should have been queued for draw() to perform");
    assertEquals(43.6425f, app.pendingGotoLatLon[0], 0.0001f, "queued latitude");
  }

  @Test
  void importObjectsGBXML_gotoLatLon_noLocationInFile_staysNull () throws IOException {
    Path f = gbxmlFile("gbxml-no-location-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>1</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertNull(app.gbxmlImportGotoLatLon);
  }

  // ================= grouping ======================================================

  @Test
  void importObjectsGBXML_doesNotStartNewGroups_whenAddingToLastGroup () throws IOException {
    app.addToLastGroup = true;
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // the "last group" to add into

    Path f = gbxmlFile("gbxml-addtolastgroup-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>1</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
            <Surface id="s2" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>1</Coordinate><Coordinate>1</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, app.allGroups.num, "both Surfaces should have added to the one pre-existing group, not started new ones");
  }

  // ================= malformed/degenerate input ====================================

  @Test
  void importObjectsGBXML_surfaceWithNoUsableGeometry_isSkippedWithoutThrowing () throws IOException {
    Path f = gbxmlFile("gbxml-no-geometry-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="ExteriorWall"/>
          </Campus>
        </gbXML>
        """
    );

    assertDoesNotThrow(() -> {
      app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.gbxmlImportSurfaceCount);
    assertEquals(1, app.gbxmlImportSkippedCount);
  }

  @Test
  void importObjectsGBXML_notAnXmlFile_doesNotThrow () throws IOException {
    Path f = gbxmlFile("gbxml-not-xml-test", "this is not XML at all");

    assertDoesNotThrow(() -> {
      app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });

    assertEquals(0, app.allFaces.nodes.length);
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsOBJTest.java's own identical test already
  // makes explicit for import_objects_OBJ() - see that file's own comment.

  @Test
  void importObjectsGBXML_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = gbxmlFile("gbxml-headless-test", """
        <gbXML lengthUnit="Meters">
          <Campus>
            <Surface id="s1" surfaceType="ExteriorWall">
              <PlanarGeometry>
                <PolyLoop>
                  <CartesianPoint><Coordinate>0</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>0</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                  <CartesianPoint><Coordinate>1</Coordinate><Coordinate>1</Coordinate><Coordinate>0</Coordinate></CartesianPoint>
                </PolyLoop>
              </PlanarGeometry>
            </Surface>
          </Campus>
        </gbXML>
        """
    );

    app.showImportProgress = true;

    assertDoesNotThrow(() -> {
      app.import_objects_GBXML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
    });
  }
}
