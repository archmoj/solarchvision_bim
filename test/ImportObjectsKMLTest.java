import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_KML() is built directly on top of importGeojson.pde's own
// shared core - see importKml.pde's own header comment. Like
// ImportObjectsGEOJSONTest.java's/ImportObjectsTOPOJSONTest.java's own
// tests, this is directly testable from a bare, never-setup()'d instance
// with no extra seeding.
//
// As with the GeoJSON/TopoJSON test files, no exact "magic number"
// projected lon/lat is ever asserted - only structure (point/line/face
// counts, which points end up in which face) and the z/altitude
// pass-through, which never goes through convert_lonlat2XY().
class ImportObjectsKMLTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
  }

  private Path kmlFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".kml");
    Files.writeString(f, body);
    return f;
  }

  private void doImport (Path f) {
    app.import_objects_KML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
  }

  private static String kml (String body) {
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        + "<kml xmlns=\"http://www.opengis.net/kml/2.2\"><Document>" + body + "</Document></kml>";
  }

  // ================= Point ========================================================

  @Test
  void importObjectsKML_point_importsABareVertex () throws IOException {
    Path f = kmlFile("kml-point-test", kml(
        "<Placemark><Point><coordinates>1,2,0</coordinates></Point></Placemark>"));

    doImport(f);

    assertEquals(1, app.allPoints.getLength());
    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.allPolylines.nodes.length);
  }

  @Test
  void importObjectsKML_point_appliesTheOffsetAndScaleToAltitudeOnly () throws IOException {
    Path f = kmlFile("kml-point-altitude-test", kml(
        "<Placemark><Point><coordinates>0,0,3</coordinates></Point></Placemark>"));

    app.import_objects_KML(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(10f, app.allPoints.getX(0), 0.01f);
    assertEquals(20f, app.allPoints.getY(0), 0.01f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f, "cz=30 + sz=2 * alt=3 == 36");
  }

  @Test
  void importObjectsKML_point_withNoAltitude_defaultsToZero () throws IOException {
    Path f = kmlFile("kml-point-no-altitude-test", kml(
        "<Placemark><Point><coordinates>1,2</coordinates></Point></Placemark>"));

    doImport(f);

    assertEquals(0f, app.allPoints.getZ(0), 0.0001f);
  }

  // ================= LineString / bare LinearRing ================================

  @Test
  void importObjectsKML_lineString_open_importsAnOpenPolyline () throws IOException {
    Path f = kmlFile("kml-linestring-open-test", kml(
        "<Placemark><LineString><coordinates>0,0,0 1,0,0 1,1,0</coordinates></LineString></Placemark>"));

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsKML_lineString_selfClosing_isAutoDetectedAsClosed () throws IOException {
    Path f = kmlFile("kml-linestring-closed-test", kml(
        "<Placemark><LineString><coordinates>0,0 1,0 1,1 0,0</coordinates></LineString></Placemark>"));

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(1, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsKML_coordinatesAcrossMultipleLines_areAllRead () throws IOException {
    // KML commonly wraps/indents <coordinates> text across several lines -
    // splitTokens() should treat newlines the same as any other whitespace.
    Path f = kmlFile("kml-multiline-coordinates-test", kml(
        "<Placemark><LineString><coordinates>\n0,0,0\n1,0,0\n1,1,0\n</coordinates></LineString></Placemark>"));

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
  }

  @Test
  void importObjectsKML_bareLinearRing_isReadAsAClosedLine () throws IOException {
    Path f = kmlFile("kml-bare-linearring-test", kml(
        "<Placemark><LinearRing><coordinates>0,0 1,0 1,1 0,0</coordinates></LinearRing></Placemark>"));

    doImport(f);

    assertEquals(0, app.allFaces.nodes.length, "a bare LinearRing outside a Polygon is a line, never a face");
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(1, app.allPolylines.getClose(0));
  }

  // ================= Polygon: flat faces, holes ===================================

  @Test
  void importObjectsKML_polygon_holeFree_importsOneFlatFace () throws IOException {
    Path f = kmlFile("kml-polygon-test", kml(
        "<Placemark><Polygon><outerBoundaryIs><LinearRing>"
        + "<coordinates>0,0 2,0 2,2 0,2 0,0</coordinates>"
        + "</LinearRing></outerBoundaryIs></Polygon></Placemark>"));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length, "the ring's own repeated closing point should be stripped");
  }

  @Test
  void importObjectsKML_polygonWithOneHole_bridgesItIntoASingleFace () throws IOException {
    // Same shape/assertion as ImportObjectsGEOJSONTest.java's/
    // ImportObjectsTOPOJSONTest.java's own identical hole tests - outer(4)
    // + hole(3) + 2 bridge-duplicate vertices == 9.
    Path f = kmlFile("kml-polygon-hole-test", kml(
        "<Placemark><Polygon>"
        + "<outerBoundaryIs><LinearRing><coordinates>0,0 10,0 10,10 0,10 0,0</coordinates></LinearRing></outerBoundaryIs>"
        + "<innerBoundaryIs><LinearRing><coordinates>4,4 6,4 5,6 4,4</coordinates></LinearRing></innerBoundaryIs>"
        + "</Polygon></Placemark>"));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length, "a hole is bridged into the outer boundary as ONE single face");
    assertEquals(4 + 3 + 2, app.allFaces.nodes[0].length);
  }

  @Test
  void importObjectsKML_polygonWithTwoHoles_bridgesBothIntoASingleFace () throws IOException {
    Path f = kmlFile("kml-polygon-two-holes-test", kml(
        "<Placemark><Polygon>"
        + "<outerBoundaryIs><LinearRing><coordinates>0,0 20,0 20,20 0,20 0,0</coordinates></LinearRing></outerBoundaryIs>"
        + "<innerBoundaryIs><LinearRing><coordinates>2,2 4,2 3,4 2,2</coordinates></LinearRing></innerBoundaryIs>"
        + "<innerBoundaryIs><LinearRing><coordinates>10,10 12,10 11,12 10,10</coordinates></LinearRing></innerBoundaryIs>"
        + "</Polygon></Placemark>"));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4 + 3 + 2 + 3 + 2, app.allFaces.nodes[0].length, "outer(4) + hole1(3)+2 + hole2(3)+2");
  }

  @Test
  void importObjectsKML_polygonWithNoOuterBoundary_isSkippedWithoutThrowing () throws IOException {
    Path f = kmlFile("kml-polygon-no-outer-test", kml("<Placemark><Polygon></Polygon></Placemark>"));

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allFaces.nodes.length);
    assertTrue(app.geojsonImportSkippedCount > 0);
  }

  // ================= MultiGeometry ================================================

  @Test
  void importObjectsKML_multiGeometry_recursesIntoEveryMember () throws IOException {
    Path f = kmlFile("kml-multigeometry-test", kml(
        "<Placemark><MultiGeometry>"
        + "<Point><coordinates>0,0</coordinates></Point>"
        + "<LineString><coordinates>0,0 1,0</coordinates></LineString>"
        + "<Polygon><outerBoundaryIs><LinearRing><coordinates>0,0 1,0 1,1 0,1 0,0</coordinates></LinearRing></outerBoundaryIs></Polygon>"
        + "</MultiGeometry></Placemark>"));

    doImport(f);

    assertEquals(1, app.geojsonPointsImported);
    assertEquals(1, app.geojsonLinesImported);
    assertEquals(1, app.geojsonFlatFacesImported);
  }

  // ================= geojsonHeightProperty via ExtendedData, reused as-is ========

  @Test
  void importObjectsKML_polygonWithMatchingPositiveHeightProperty_isExtrudedIntoASolid () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = kmlFile("kml-polygon-extrude-test", kml(
        "<Placemark>"
        + "<ExtendedData><Data name=\"height\"><value>5</value></Data></ExtendedData>"
        + "<Polygon><outerBoundaryIs><LinearRing><coordinates>0,0 2,0 2,2 0,2 0,0</coordinates></LinearRing></outerBoundaryIs></Polygon>"
        + "</Placemark>"));

    doImport(f);

    // n=4: 1 bottom cap + 1 top cap + 4 wall quads == 6 faces, 2n==8 points.
    assertEquals(6, app.allFaces.nodes.length);
    assertEquals(8, app.allPoints.getLength());
  }

  @Test
  void importObjectsKML_polygonWithHeightViaSchemaData_isExtrudedIntoASolid () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = kmlFile("kml-polygon-extrude-schemadata-test", kml(
        "<Placemark>"
        + "<ExtendedData><SchemaData><SimpleData name=\"height\">5</SimpleData></SchemaData></ExtendedData>"
        + "<Polygon><outerBoundaryIs><LinearRing><coordinates>0,0 2,0 2,2 0,2 0,0</coordinates></LinearRing></outerBoundaryIs></Polygon>"
        + "</Placemark>"));

    doImport(f);

    assertEquals(6, app.allFaces.nodes.length);
    assertEquals(8, app.allPoints.getLength());
  }

  @Test
  void importObjectsKML_polygonWithNoExtendedData_staysFlat () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = kmlFile("kml-polygon-no-extendeddata-test", kml(
        "<Placemark><Polygon><outerBoundaryIs><LinearRing><coordinates>0,0 2,0 2,2 0,2 0,0</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>"));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  // ================= nested Folders, multiple Placemarks, grouping ===============

  @Test
  void importObjectsKML_placemarksNestedInsideFolders_areAllFound () throws IOException {
    Path f = kmlFile("kml-nested-folders-test", kml(
        "<Folder><Folder>"
        + "<Placemark><Point><coordinates>0,0</coordinates></Point></Placemark>"
        + "</Folder>"
        + "<Placemark><Point><coordinates>1,0</coordinates></Point></Placemark>"
        + "</Folder>"));

    doImport(f);

    assertEquals(2, app.allPoints.getLength());
  }

  @Test
  void importObjectsKML_groupPropertyChange_startsANewGroupAndCyclesMaterial () throws IOException {
    app.geojsonGroupProperty = "layer";

    Path f = kmlFile("kml-group-change-test", kml(
        "<Placemark><ExtendedData><Data name=\"layer\"><value>WALLS</value></Data></ExtendedData>"
        + "<Polygon><outerBoundaryIs><LinearRing><coordinates>0,0 1,0 1,1 0,1 0,0</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>"
        + "<Placemark><ExtendedData><Data name=\"layer\"><value>ROOF</value></Data></ExtendedData>"
        + "<Polygon><outerBoundaryIs><LinearRing><coordinates>5,5 6,5 6,6 5,6 5,5</coordinates></LinearRing></outerBoundaryIs></Polygon></Placemark>"));

    app.import_objects_KML(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "each distinct grouping-property value should start its own group");
  }

  // ================= malformed input / headless safety ===========================

  @Test
  void importObjectsKML_placemarkWithNoRecognizedGeometry_isSkippedWithoutThrowing () throws IOException {
    Path f = kmlFile("kml-no-geometry-test", kml("<Placemark><name>Nothing here</name></Placemark>"));

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allPoints.getLength());
    assertEquals(1, app.geojsonImportSkippedCount);
  }

  @Test
  void importObjectsKML_unparseableFile_doesNotThrow () throws IOException {
    Path f = kmlFile("kml-malformed-test", "<kml><Document><Placemark>");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allPoints.getLength());
  }

  @Test
  void importObjectsKML_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = kmlFile("kml-headless-test", kml(
        "<Placemark><Point><coordinates>0,0</coordinates></Point></Placemark>"));

    app.showImportProgress = true;

    assertDoesNotThrow(() -> doImport(f));
  }

  // ================= extraParams captured from ExtendedData =============

  @Test
  void importObjectsKML_polygonPlacemark_capturesItsOwnExtendedDataAsExtraParams () throws IOException {
    Path f = kmlFile("kml-polygon-extraparams-test", kml(
        "<Placemark>"
        + "<ExtendedData><Data name=\"name\"><value>Lot 7</value></Data></ExtendedData>"
        + "<Polygon><outerBoundaryIs><LinearRing><coordinates>0,0 2,0 2,2 0,2 0,0</coordinates></LinearRing></outerBoundaryIs></Polygon>"
        + "</Placemark>"));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"name\": \"Lot 7\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsKML_lineStringPlacemark_capturesItsOwnExtendedDataAsExtraParams () throws IOException {
    Path f = kmlFile("kml-linestring-extraparams-test", kml(
        "<Placemark>"
        + "<ExtendedData><Data name=\"name\"><value>Trail A</value></Data></ExtendedData>"
        + "<LineString><coordinates>0,0 1,0 1,1</coordinates></LineString>"
        + "</Placemark>"));

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals("{\"name\": \"Trail A\"}", app.allPolylines.getExtraParams(0));
  }
}
