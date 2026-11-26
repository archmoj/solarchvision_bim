import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_TOPOJSON() is built directly on top of importGeojson.pde's
// own shared core - see importTopojson.pde's own header comment. Like
// ImportObjectsGEOJSONTest.java's own import_objects_GEOJSON() tests, this
// is directly testable from a bare, never-setup()'d instance with no extra
// seeding.
//
// Every test below either carries no "transform" at all (arc/Point values
// are then already final, plain numbers - no quantization/delta-decoding
// involved) or a "transform" with scale [1,1] and translate [0,0] (a no-op
// transform that still exercises the actual accumulate-then-scale-then-
// translate decode path) - so, as with ImportObjectsGEOJSONTest.java, no
// exact "magic number" projected lon/lat is ever asserted: only structure
// (point/line/face counts, which points end up in which face) and the
// z/altitude pass-through, which never goes through convert_lonlat2XY().
class ImportObjectsTOPOJSONTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
  }

  private Path topojsonFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".topojson");
    Files.writeString(f, body);
    return f;
  }

  private void doImport (Path f) {
    app.import_objects_TOPOJSON(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
  }

  // ================= arcs, no transform at all ==================================

  @Test
  void importObjectsTOPOJSON_lineString_oneArc_noTransform_importsAnOpenPolyline () throws IOException {
    Path f = topojsonFile("topojson-line-noquant-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0],[1,1]]],"
        + "\"objects\":{\"line\":{\"type\":\"LineString\",\"arcs\":[0]}}}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0), "no repeated first/last point - stays open");
  }

  @Test
  void importObjectsTOPOJSON_lineString_selfClosingArc_isAutoDetectedAsClosed () throws IOException {
    Path f = topojsonFile("topojson-line-closed-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0],[1,1],[0,0]]],"
        + "\"objects\":{\"ring\":{\"type\":\"LineString\",\"arcs\":[0]}}}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length, "the repeated closing point should be stripped");
    assertEquals(1, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsTOPOJSON_negativeArcIndex_reversesTheArc () throws IOException {
    // Arc 0 goes (lon 0,lat 0)->(lon 2,lat 0)->(lon 4,lat 0) - latitude held
    // at 0 throughout so the only thing that varies, and that this test
    // needs to check, is longitude (via convert_lonlat2XY()'s own
    // monotonic-in-longitude-at-a-fixed-latitude x); holding latitude fixed
    // also sidesteps that function's own lon/lat coupling (x is scaled by
    // cos(lat)), which would otherwise make two points sharing a longitude
    // at different latitudes project to very slightly different x values.
    // Index -1 (= ~0, i.e. arc 0 reversed) should walk it backwards:
    // lon 4 -> lon 2 -> lon 0, i.e. a strictly DEcreasing local x.
    Path f = topojsonFile("topojson-reversed-arc-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[2,0],[4,0]]],"
        + "\"objects\":{\"line\":{\"type\":\"LineString\",\"arcs\":[-1]}}}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    int[] nodes = app.allPolylines.nodes[0];
    assertEquals(3, nodes.length);
    assertTrue(app.allPoints.getX(nodes[0]) > app.allPoints.getX(nodes[1]), "reversed walk: lon 4 before lon 2");
    assertTrue(app.allPoints.getX(nodes[1]) > app.allPoints.getX(nodes[2]), "reversed walk: lon 2 before lon 0");
  }

  @Test
  void importObjectsTOPOJSON_lineString_twoArcs_stitchesThemDroppingTheSharedEndpoint () throws IOException {
    // Arc 0: (0,0)->(1,0). Arc 1: (1,0)->(1,1)->(1,2) - its own first point
    // (1,0) is the shared endpoint with arc 0's own last point, and must be
    // dropped once stitched, leaving 4 distinct points total, not 5.
    Path f = topojsonFile("topojson-two-arcs-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0]],[[1,0],[1,1],[1,2]]],"
        + "\"objects\":{\"line\":{\"type\":\"LineString\",\"arcs\":[0,1]}}}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(4, app.allPolylines.nodes[0].length, "arc 0's own 2 points + arc 1's own 3 points - 1 shared endpoint == 4");
  }

  @Test
  void importObjectsTOPOJSON_multiLineString_importsOnePolylinePerMember () throws IOException {
    Path f = topojsonFile("topojson-multilinestring-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0]],[[0,1],[1,1],[1,2]]],"
        + "\"objects\":{\"lines\":{\"type\":\"MultiLineString\",\"arcs\":[[0],[1]]}}}");

    doImport(f);

    assertEquals(2, app.allPolylines.nodes.length);
    assertEquals(2, app.allPolylines.nodes[0].length);
    assertEquals(3, app.allPolylines.nodes[1].length);
  }

  // ================= Polygon / MultiPolygon: flat faces =========================

  @Test
  void importObjectsTOPOJSON_polygon_oneArcClosedRing_importsOneFlatFace () throws IOException {
    Path f = topojsonFile("topojson-polygon-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]],"
        + "\"objects\":{\"square\":{\"type\":\"Polygon\",\"arcs\":[[0]]}}}");

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length, "the arc's own repeated closing point should be stripped");
  }

  @Test
  void importObjectsTOPOJSON_multiPolygon_importsOneFlatFacePerMember () throws IOException {
    Path f = topojsonFile("topojson-multipolygon-test",
        "{\"type\":\"Topology\",\"arcs\":["
        + "[[0,0],[1,0],[1,1],[0,1],[0,0]],"
        + "[[10,10],[11,10],[11,11],[10,11],[10,10]]"
        + "],\"objects\":{\"squares\":{\"type\":\"MultiPolygon\",\"arcs\":[[[0]],[[1]]]}}}");

    doImport(f);

    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
    assertEquals(4, app.allFaces.nodes[1].length);
  }

  @Test
  void importObjectsTOPOJSON_outOfRangeArcIndex_isSkippedWithoutThrowing () throws IOException {
    Path f = topojsonFile("topojson-bad-arc-index-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0]]],"
        + "\"objects\":{\"line\":{\"type\":\"LineString\",\"arcs\":[5]}}}");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allPolylines.nodes.length);
    assertTrue(app.geojsonImportSkippedCount > 0);
  }

  // ================= Polygon with holes: shared geojsonEmitPolygonFromRings ====

  @Test
  void importObjectsTOPOJSON_polygonWithOneHole_bridgesItIntoASingleFace () throws IOException {
    // Same shape/assertion as ImportObjectsGEOJSONTest.java's own
    // importObjectsGEOJSON_polygonWithOneHole_bridgesItIntoASingleFace() -
    // outer(4) + hole(3) + 2 bridge-duplicate vertices == 9.
    Path f = topojsonFile("topojson-polygon-hole-test",
        "{\"type\":\"Topology\",\"arcs\":["
        + "[[0,0],[10,0],[10,10],[0,10],[0,0]],"
        + "[[4,4],[6,4],[5,6],[4,4]]"
        + "],\"objects\":{\"donut\":{\"type\":\"Polygon\",\"arcs\":[[0],[1]]}}}");

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length, "a hole is bridged into the outer boundary as ONE single face");
    assertEquals(4 + 3 + 2, app.allFaces.nodes[0].length);
  }

  // ================= geojsonHeightProperty: extrusion, reused as-is ==============

  @Test
  void importObjectsTOPOJSON_polygonWithMatchingPositiveHeightProperty_isExtrudedIntoASolid () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = topojsonFile("topojson-polygon-extrude-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]],"
        + "\"objects\":{\"building\":{\"type\":\"Polygon\",\"properties\":{\"height\":5},\"arcs\":[[0]]}}}");

    doImport(f);

    // n=4: 1 bottom cap + 1 top cap + 4 wall quads == 6 faces, 2n==8 points.
    assertEquals(6, app.allFaces.nodes.length);
    assertEquals(8, app.allPoints.getLength());
  }

  @Test
  void importObjectsTOPOJSON_polygonWithHeightPropertyNamedButAbsent_staysFlat () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = topojsonFile("topojson-polygon-no-height-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]],"
        + "\"objects\":{\"plot\":{\"type\":\"Polygon\",\"properties\":{\"name\":\"no height here\"},\"arcs\":[[0]]}}}");

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  // ================= Point / MultiPoint - coordinates, never arcs ===============

  @Test
  void importObjectsTOPOJSON_point_noTransform_importsABareVertex () throws IOException {
    Path f = topojsonFile("topojson-point-test",
        "{\"type\":\"Topology\",\"arcs\":[],\"objects\":{\"p\":{\"type\":\"Point\",\"coordinates\":[1,2]}}}");

    doImport(f);

    assertEquals(1, app.allPoints.getLength());
    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsTOPOJSON_point_withNoOpTransform_dequantizesCorrectly () throws IOException {
    // scale [1,1]/translate [0,0] is a no-op transform, but it still
    // exercises the actual "value * scale + translate" dequantize path
    // (rather than the no-transform passthrough) - altitude isn't part of
    // the transform's own 2 dimensions here, so it stays a straight
    // cz + sz * alt pass-through, same as GeoJSON's own identical test.
    Path f = topojsonFile("topojson-point-transform-test",
        "{\"type\":\"Topology\",\"transform\":{\"scale\":[1,1],\"translate\":[0,0]},\"arcs\":[],"
        + "\"objects\":{\"p\":{\"type\":\"Point\",\"coordinates\":[0,0,3]}}}");

    app.import_objects_TOPOJSON(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(10f, app.allPoints.getX(0), 0.01f);
    assertEquals(20f, app.allPoints.getY(0), 0.01f);
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f, "cz=30 + sz=2 * alt=3 == 36");
  }

  @Test
  void importObjectsTOPOJSON_multiPoint_eachCoordinateIsIndependentlyDequantized () throws IOException {
    // Per the TopoJSON spec, Point/MultiPoint coordinates are never
    // delta-encoded against one another (unlike an arc's own points) -
    // with a no-op transform, each of these 3 points should land exactly
    // where it says, not accumulated onto the previous one.
    Path f = topojsonFile("topojson-multipoint-test",
        "{\"type\":\"Topology\",\"transform\":{\"scale\":[1,1],\"translate\":[0,0]},\"arcs\":[],"
        + "\"objects\":{\"pts\":{\"type\":\"MultiPoint\",\"coordinates\":[[5,5],[5,5],[5,5]]}}}");

    doImport(f);

    assertEquals(3, app.allPoints.getLength());
    for (int i = 0; i < 3; i++) {
      assertEquals(app.allPoints.getX(0), app.allPoints.getX(i), 0.01, "every point carries the same raw coordinate, so every one should project identically - no cumulative drift");
    }
  }

  // ================= GeometryCollection =========================================

  @Test
  void importObjectsTOPOJSON_geometryCollection_recursesIntoEveryMember () throws IOException {
    Path f = topojsonFile("topojson-geometrycollection-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0]],[[0,0],[1,0],[1,1],[0,1],[0,0]]],"
        + "\"objects\":{\"stuff\":{\"type\":\"GeometryCollection\",\"geometries\":["
        + "{\"type\":\"Point\",\"coordinates\":[0,0]},"
        + "{\"type\":\"LineString\",\"arcs\":[0]},"
        + "{\"type\":\"Polygon\",\"arcs\":[[1]]}"
        + "]}}}");

    doImport(f);

    assertEquals(1, app.geojsonPointsImported);
    assertEquals(1, app.geojsonLinesImported);
    assertEquals(1, app.geojsonFlatFacesImported);
  }

  // ================= multiple named objects / grouping ===========================

  @Test
  void importObjectsTOPOJSON_multipleNamedObjects_areAllImported () throws IOException {
    Path f = topojsonFile("topojson-multiobject-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0],[1,1],[0,1],[0,0]],[[5,5],[6,5],[6,6],[5,6],[5,5]]],"
        + "\"objects\":{"
        + "\"a\":{\"type\":\"Polygon\",\"arcs\":[[0]]},"
        + "\"b\":{\"type\":\"Polygon\",\"arcs\":[[1]]}"
        + "}}");

    doImport(f);

    assertEquals(2, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsTOPOJSON_groupPropertyChange_startsANewGroupAndCyclesMaterial () throws IOException {
    app.geojsonGroupProperty = "layer";

    Path f = topojsonFile("topojson-group-change-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0],[1,1],[0,1],[0,0]],[[5,5],[6,5],[6,6],[5,6],[5,5]]],"
        + "\"objects\":{"
        + "\"a\":{\"type\":\"Polygon\",\"properties\":{\"layer\":\"WALLS\"},\"arcs\":[[0]]},"
        + "\"b\":{\"type\":\"Polygon\",\"properties\":{\"layer\":\"ROOF\"},\"arcs\":[[1]]}"
        + "}}");

    app.import_objects_TOPOJSON(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "each distinct grouping-property value should start its own group");
  }

  // ================= malformed root / headless safety ===========================

  @Test
  void importObjectsTOPOJSON_rootTypeNotTopology_isSkippedWithoutThrowing () throws IOException {
    Path f = topojsonFile("topojson-not-a-topology-test", "{\"type\":\"FeatureCollection\",\"features\":[]}");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allPoints.getLength());
  }

  @Test
  void importObjectsTOPOJSON_unparseableFile_doesNotThrow () throws IOException {
    Path f = topojsonFile("topojson-malformed-test", "{ this is not valid json");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allPoints.getLength());
  }

  @Test
  void importObjectsTOPOJSON_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = topojsonFile("topojson-headless-test",
        "{\"type\":\"Topology\",\"arcs\":[],\"objects\":{\"p\":{\"type\":\"Point\",\"coordinates\":[0,0]}}}");

    app.showImportProgress = true;

    assertDoesNotThrow(() -> doImport(f));
  }

  // ================= extraParams captured from object "properties" ======

  @Test
  void importObjectsTOPOJSON_polygonObject_capturesItsOwnPropertiesAsExtraParams () throws IOException {
    Path f = topojsonFile("topojson-polygon-extraparams-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]],"
        + "\"objects\":{\"building\":{\"type\":\"Polygon\",\"properties\":{\"name\":\"Lot 7\"},\"arcs\":[[0]]}}}");

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length);
    assertEquals("{\"name\": \"Lot 7\"}", app.allFaces.getExtraParams(0));
  }

  @Test
  void importObjectsTOPOJSON_lineStringObject_capturesItsOwnPropertiesAsExtraParams () throws IOException {
    Path f = topojsonFile("topojson-linestring-extraparams-test",
        "{\"type\":\"Topology\",\"arcs\":[[[0,0],[1,0],[1,1]]],"
        + "\"objects\":{\"line\":{\"type\":\"LineString\",\"properties\":{\"name\":\"Trail A\"},\"arcs\":[0]}}}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals("{\"name\": \"Trail A\"}", app.allPolylines.getExtraParams(0));
  }
}
