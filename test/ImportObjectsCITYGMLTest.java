import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_CITYGML() is built directly on top of importGeojson.pde's
// own shared core - see importCitygml.pde's own header comment. Like
// ImportObjectsGEOJSONTest.java's/ImportObjectsTOPOJSONTest.java's/
// ImportObjectsKMLTest.java's own tests, this is directly testable from a
// bare, never-setup()'d instance with no extra seeding.
//
// Every test fixture here deliberately uses a DIFFERENT namespace prefix
// pair than the usual "bldg"/"gml" convention ("b"/"g") for ONE representative
// test (citygmlPrefix_anyPrefixMappedToTheRightNamespaceWorks, see below) to
// prove this importer really is prefix-agnostic (citygmlLocalName()'s own
// comment) rather than hard-coding "bldg:"/"gml:" - every other test below
// uses the conventional "bldg"/"gml" prefixes, same as virtually every
// real-world CityGML file.
class ImportObjectsCITYGMLTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
  }

  private Path gmlFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".gml");
    Files.writeString(f, body);
    return f;
  }

  private void doImport (Path f) {
    app.import_objects_CITYGML(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
  }

  private static String citygml (String body) {
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        + "<core:CityModel xmlns:core=\"http://www.opengis.net/citygml/2.0\""
        + " xmlns:bldg=\"http://www.opengis.net/citygml/building/2.0\""
        + " xmlns:gml=\"http://www.opengis.net/gml\""
        + " xmlns:gen=\"http://www.opengis.net/citygml/generics/2.0\">"
        + body + "</core:CityModel>";
  }

  private static String member (String building) {
    return "<core:cityObjectMember>" + building + "</core:cityObjectMember>";
  }

  // A simple unit-square-footprint LOD1 box, as 6 real gml:Polygon faces
  // (bottom, top, 4 walls) wrapped in a lod1Solid/exterior/
  // CompositeSurface/surfaceMember chain - this importer never needs to
  // understand that wrapping explicitly (importCitygml.pde's own header
  // comment), it just finds every Polygon inside it.
  private static String lod1Box () {
    return "<bldg:Building gml:id=\"BLDG_1\">"
        + "<bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + poly("0 0 0 1 0 0 1 1 0 0 1 0 0 0 0")
        + poly("0 0 1 0 1 1 1 1 1 1 0 1 0 0 1")
        + poly("0 0 0 1 0 0 1 0 1 0 0 1 0 0 0")
        + poly("1 0 0 1 1 0 1 1 1 1 0 1 1 0 0")
        + poly("1 1 0 0 1 0 0 1 1 1 1 1 1 1 0")
        + poly("0 1 0 0 0 0 0 0 1 0 1 1 0 1 0")
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid>"
        + "</bldg:Building>";
  }

  private static String poly (String posList) {
    return "<gml:surfaceMember><gml:Polygon><gml:exterior><gml:LinearRing><gml:posList>"
        + posList + "</gml:posList></gml:LinearRing></gml:exterior></gml:Polygon></gml:surfaceMember>";
  }

  // ================= LOD1 Solid: direct face-per-polygon, no extrusion ===========

  @Test
  void importObjectsCITYGML_lod1Solid_importsOneFacePerPolygon () throws IOException {
    Path f = gmlFile("citygml-lod1-test", citygml(member(lod1Box())));

    doImport(f);

    assertEquals(6, app.allFaces.nodes.length);
    for (int[] face : app.allFaces.nodes) assertEquals(4, face.length, "every box face's own closing duplicate should be stripped to 4 points");
  }

  // ================= LOD2 boundedBy / _BoundarySurface ============================

  @Test
  void importObjectsCITYGML_lod2BoundedBy_importsOneFacePerBoundarySurfacePolygon () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_2\">"
        + "<bldg:boundedBy><bldg:GroundSurface><bldg:lod2MultiSurface><gml:MultiSurface>"
        + poly("0 0 0 1 0 0 1 1 0 0 1 0 0 0 0")
        + "</gml:MultiSurface></bldg:lod2MultiSurface></bldg:GroundSurface></bldg:boundedBy>"
        + "<bldg:boundedBy><bldg:RoofSurface><bldg:lod2MultiSurface><gml:MultiSurface>"
        + poly("0 0 3 1 1 3 1 0 3 0 0 3")
        + "</gml:MultiSurface></bldg:lod2MultiSurface></bldg:RoofSurface></bldg:boundedBy>"
        + "<bldg:boundedBy><bldg:WallSurface><bldg:lod2MultiSurface><gml:MultiSurface>"
        + poly("0 0 0 1 0 0 1 0 3 0 0 3 0 0 0")
        + "</gml:MultiSurface></bldg:lod2MultiSurface></bldg:WallSurface></bldg:boundedBy>"
        + "</bldg:Building>";

    Path f = gmlFile("citygml-lod2-test", citygml(member(building)));

    doImport(f);

    assertEquals(3, app.allFaces.nodes.length);
  }

  // ================= LOD0 footprint: extrusion-eligible ===========================

  @Test
  void importObjectsCITYGML_lod0FootprintWithMeasuredHeight_isExtrudedIntoASolid () throws IOException {
    app.geojsonHeightProperty = "measuredHeight";

    String building = "<bldg:Building gml:id=\"BLDG_3\">"
        + "<bldg:measuredHeight uom=\"m\">5</bldg:measuredHeight>"
        + "<bldg:lod0FootPrint><gml:MultiSurface>"
        + poly("0 0 0 2 0 0 2 2 0 0 2 0 0 0 0")
        + "</gml:MultiSurface></bldg:lod0FootPrint>"
        + "</bldg:Building>";

    Path f = gmlFile("citygml-lod0-extrude-test", citygml(member(building)));

    doImport(f);

    // n=4: 1 bottom cap + 1 top cap + 4 wall quads == 6 faces.
    assertEquals(6, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsCITYGML_lod0FootprintWithNoHeightPropertyConfigured_staysFlat () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_4\">"
        + "<bldg:measuredHeight uom=\"m\">5</bldg:measuredHeight>"
        + "<bldg:lod0FootPrint><gml:MultiSurface>"
        + poly("0 0 0 2 0 0 2 2 0 0 2 0 0 0 0")
        + "</gml:MultiSurface></bldg:lod0FootPrint>"
        + "</bldg:Building>";

    Path f = gmlFile("citygml-lod0-noextrude-test", citygml(member(building)));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  @Test
  void importObjectsCITYGML_volumetricAndFootprintBothPresent_volumetricWinsAndFootprintIsIgnored () throws IOException {
    app.geojsonHeightProperty = "measuredHeight"; // would extrude the footprint if it were ever reached

    String building = "<bldg:Building gml:id=\"BLDG_5\">"
        + "<bldg:measuredHeight uom=\"m\">5</bldg:measuredHeight>"
        + "<bldg:lod0FootPrint><gml:MultiSurface>"
        + poly("0 0 0 2 0 0 2 2 0 0 2 0 0 0 0")
        + "</gml:MultiSurface></bldg:lod0FootPrint>"
        + "<bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + poly("0 0 0 1 0 0 1 1 0 0 1 0 0 0 0")
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid>"
        + "</bldg:Building>";

    Path f = gmlFile("citygml-volumetric-wins-test", citygml(member(building)));

    doImport(f);

    // Only the lod1Solid's own single Polygon should be imported (1 flat
    // face, never extruded) - the lod0FootPrint is ignored entirely once a
    // volumetric container is found, per importCitygml.pde's own header
    // comment.
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(0, app.geojsonSolidsImported);
  }

  // ================= Polygon holes ================================================

  @Test
  void importObjectsCITYGML_polygonWithOneHole_bridgesItIntoASingleFace () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_6\">"
        + "<bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + "<gml:surfaceMember><gml:Polygon>"
        + "<gml:exterior><gml:LinearRing><gml:posList>0 0 0 4 0 0 4 4 0 0 4 0 0 0 0</gml:posList></gml:LinearRing></gml:exterior>"
        + "<gml:interior><gml:LinearRing><gml:posList>1 1 0 2 1 0 2 2 0 1 1 0</gml:posList></gml:LinearRing></gml:interior>"
        + "</gml:Polygon></gml:surfaceMember>"
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid>"
        + "</bldg:Building>";

    Path f = gmlFile("citygml-hole-test", citygml(member(building)));

    doImport(f);

    // outer(4) + hole(3) + 2 bridge-duplicate vertices == 9, same bridging
    // convention ImportObjectsKMLTest.java's own identical hole test uses.
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4 + 3 + 2, app.allFaces.nodes[0].length);
  }

  // ================= BuildingPart aggregation =====================================

  @Test
  void importObjectsCITYGML_buildingPartNestedInsideBuilding_aggregatesIntoTheSameBuilding () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_7\">"
        + "<bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + poly("0 0 0 1 0 0 1 1 0 0 1 0 0 0 0")
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid>"
        + "<bldg:consistsOfBuildingPart><bldg:BuildingPart gml:id=\"BLDG_7_PART\">"
        + "<bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + poly("5 5 0 6 5 0 6 6 0 5 6 0 5 5 0")
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid>"
        + "</bldg:BuildingPart></bldg:consistsOfBuildingPart>"
        + "</bldg:Building>";

    Path f = gmlFile("citygml-buildingpart-test", citygml(member(building)));

    doImport(f);

    // Both the Building's own Polygon AND its nested BuildingPart's own
    // Polygon should be imported - as part of ONE Building (no separate
    // top-level object for the BuildingPart), per importCitygml.pde's own
    // header comment.
    assertEquals(2, app.allFaces.nodes.length);
  }

  // ================= coordinate system: planar-by-default, lon/lat opt-in ========

  @Test
  void importObjectsCITYGML_coordinatesDefaultToAlreadyLocalPlanarMeters () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_8\">"
        + "<bldg:lod0FootPrint><gml:MultiSurface>"
        + poly("100 200 3 101 200 3 101 201 3 100 201 3 100 200 3")
        + "</gml:MultiSurface></bldg:lod0FootPrint></bldg:Building>";

    Path f = gmlFile("citygml-planar-default-test", citygml(member(building)));

    app.import_objects_CITYGML(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    // No projection at all by default: straight cx+sx*x / cy+sy*y / cz+sz*z,
    // exactly like importDxf.pde's/importObj.pde's own planar coordinates -
    // this is directly, exactly assertable (unlike the lon/lat case below,
    // which goes through convert_lonlat2XY()).
    float[] p0 = {app.allPoints.getX(0), app.allPoints.getY(0), app.allPoints.getZ(0)};
    assertEquals(10f + 2f * 100f, p0[0], 0.001f);
    assertEquals(20f + 2f * 200f, p0[1], 0.001f);
    assertEquals(30f + 2f * 3f, p0[2], 0.001f);
  }

  @Test
  void importObjectsCITYGML_coordinatesAreLonLatOption_routesThroughTheSharedProjection () throws IOException {
    app.citygmlCoordinatesAreLonLat = true;

    // Same "hold latitude at 0, assert relative x ordering rather than an
    // exact projected value" technique ImportObjectsTOPOJSONTest.java's own
    // importObjectsTOPOJSON_negativeArcIndex_reversesTheArc test already
    // uses, for the same reason: convert_lonlat2XY()'s own exact output
    // isn't this test's concern, only that this option actually engages it
    // (very different from the straight planar passthrough above) rather
    // than being ignored.
    String building = "<bldg:Building gml:id=\"BLDG_9\">"
        + "<bldg:lod0FootPrint><gml:MultiSurface>"
        + poly("2 0 0 1 0 0 0 0 0 2 0 0")
        + "</gml:MultiSurface></bldg:lod0FootPrint></bldg:Building>";

    Path f = gmlFile("citygml-lonlat-test", citygml(member(building)));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    int[] nodes = app.allFaces.nodes[0];
    float x0 = app.allPoints.getX(nodes[0]);
    float x1 = app.allPoints.getX(nodes[1]);
    float x2 = app.allPoints.getX(nodes[2]);
    assertTrue(x0 > x1 && x1 > x2, "lon 2 > lon 1 > lon 0 should still project to decreasing local x");
    assertNotEquals(2f, x0, 0.001f, "a lon/lat value should be projected, not passed straight through as planar meters");
  }

  // ================= grouping via the synthetic gmlId property ===================

  @Test
  void importObjectsCITYGML_groupPropertyGmlId_startsANewGroupPerBuilding () throws IOException {
    app.geojsonGroupProperty = "gmlId";

    String b1 = "<bldg:Building gml:id=\"BLDG_A\"><bldg:lod0FootPrint><gml:MultiSurface>"
        + poly("0 0 0 1 0 0 1 1 0 0 1 0 0 0 0") + "</gml:MultiSurface></bldg:lod0FootPrint></bldg:Building>";
    String b2 = "<bldg:Building gml:id=\"BLDG_B\"><bldg:lod0FootPrint><gml:MultiSurface>"
        + poly("5 5 0 6 5 0 6 6 0 5 6 0 5 5 0") + "</gml:MultiSurface></bldg:lod0FootPrint></bldg:Building>";

    Path f = gmlFile("citygml-group-test", citygml(member(b1) + member(b2)));

    app.import_objects_CITYGML(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "each distinct gml:id should start its own group");
  }

  // ================= alternate gml:pos encoding ===================================

  @Test
  void importObjectsCITYGML_linearRingWithBarePosElements_readsTheSamePoints () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_10\"><bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + "<gml:surfaceMember><gml:Polygon><gml:exterior><gml:LinearRing>"
        + "<gml:pos>0 0 0</gml:pos><gml:pos>1 0 0</gml:pos><gml:pos>1 1 0</gml:pos><gml:pos>0 1 0</gml:pos><gml:pos>0 0 0</gml:pos>"
        + "</gml:LinearRing></gml:exterior></gml:Polygon></gml:surfaceMember>"
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid></bldg:Building>";

    Path f = gmlFile("citygml-pos-test", citygml(member(building)));

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  // ================= arbitrary namespace prefixes (prefix-agnostic matching) =====

  @Test
  void importObjectsCITYGML_arbitraryNamespacePrefixes_stillImportCorrectly () throws IOException {
    String doc = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        + "<c:CityModel xmlns:c=\"http://www.opengis.net/citygml/2.0\""
        + " xmlns:b=\"http://www.opengis.net/citygml/building/2.0\""
        + " xmlns:g=\"http://www.opengis.net/gml\">"
        + "<c:cityObjectMember><b:Building g:id=\"BLDG_11\">"
        + "<b:lod1Solid><g:Solid><g:exterior><g:CompositeSurface>"
        + "<g:surfaceMember><g:Polygon><g:exterior><g:LinearRing><g:posList>0 0 0 1 0 0 1 1 0 0 1 0 0 0 0</g:posList></g:LinearRing></g:exterior></g:Polygon></g:surfaceMember>"
        + "</g:CompositeSurface></g:exterior></g:Solid></b:lod1Solid>"
        + "</b:Building></c:cityObjectMember></c:CityModel>";

    Path f = gmlFile("citygml-prefix-test", doc);

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  // ================= malformed input / degenerate geometry / headless safety =====

  @Test
  void importObjectsCITYGML_polygonWithNoExteriorRing_isSkippedWithoutThrowing () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_12\"><bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + "<gml:surfaceMember><gml:Polygon></gml:Polygon></gml:surfaceMember>"
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid></bldg:Building>";

    Path f = gmlFile("citygml-no-exterior-test", citygml(member(building)));

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.geojsonImportSkippedCount);
  }

  @Test
  void importObjectsCITYGML_degenerateRing_isSkippedWithoutThrowing () throws IOException {
    String building = "<bldg:Building gml:id=\"BLDG_13\"><bldg:lod1Solid><gml:Solid><gml:exterior><gml:CompositeSurface>"
        + poly("0 0 0 1 0 0 0 0 0")
        + "</gml:CompositeSurface></gml:exterior></gml:Solid></bldg:lod1Solid></bldg:Building>";

    Path f = gmlFile("citygml-degenerate-test", citygml(member(building)));

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.geojsonImportSkippedCount);
  }

  @Test
  void importObjectsCITYGML_noBuildingsAtAll_importsNothingWithoutThrowing () throws IOException {
    Path f = gmlFile("citygml-no-buildings-test", citygml("<core:cityObjectMember><gen:GenericCityObject gml:id=\"X\"/></core:cityObjectMember>"));

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(0, app.geojsonImportSkippedCount, "a non-Building feature this version doesn't look for is never even visited, let alone counted as skipped");
  }

  @Test
  void importObjectsCITYGML_unparseableFile_doesNotThrow () throws IOException {
    Path f = gmlFile("citygml-malformed-test", "<core:CityModel><core:cityObjectMember><bldg:Building>");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsCITYGML_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = gmlFile("citygml-headless-test", citygml(member(lod1Box())));

    app.showImportProgress = true;

    assertDoesNotThrow(() -> doImport(f));
  }
}
