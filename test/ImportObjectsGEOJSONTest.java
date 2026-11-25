import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// import_objects_GEOJSON() is a plain Processing-JSONObject/JSONArray
// parser plus calls to allPoints.create()/allFaces.create()/allPolylines.
// add_Polyline()/allGroups.beginNewGroup() - like ImportObjectsDXFTest.java's
// own import_objects_DXF() tests, this is directly testable from a bare,
// never-setup()'d instance with no extra seeding.
//
// Every test below leaves locationLatitude/locationLongitude at their own
// default of (0, 0) (globalVariables.pde) unless a test says otherwise, so
// Functions.convert_lonlat2XY() projects around the origin - see
// importGeojson.pde's own header comment for why no exact "magic number"
// projected coordinate is asserted anywhere below: the tests instead pin
// down structure (point/face/polyline counts, which points end up in which
// face, relative ordering) and the un-projected cz/sz pass-through for
// altitude, mirroring geojsonCoordToXYZ()'s own documented behavior without
// re-deriving convert_lonlat2XY()'s own equirectangular formula by hand.
class ImportObjectsGEOJSONTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See ImportObjectsDXFTest.java's own identical setUp() for why.
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
  }

  private Path geojsonFile (String name, String body) throws IOException {
    Path f = Files.createTempFile(name, ".geojson");
    Files.writeString(f, body);
    return f;
  }

  // Default import() args every test below starts from, same shape
  // ImportObjectsDXFTest.java's own tests already use: m=0, tes=0, lyr=0,
  // vsb=1, wgt=0, clz=0 (open unless the file's own coordinates close the
  // loop), cx/cy/cz=0, sx/sy/sz=1.
  private void doImport (Path f) {
    app.import_objects_GEOJSON(f.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);
  }

  // ================= Point / MultiPoint =========================================

  @Test
  void importObjectsGEOJSON_point_importsABareVertex () throws IOException {
    Path f = geojsonFile("geojson-point-test", "{\"type\":\"Point\",\"coordinates\":[1,2]}");

    doImport(f);

    assertEquals(1, app.allPoints.getLength());
    assertEquals(0, app.allFaces.nodes.length, "a bare Point never becomes a face - same no-standalone-point-object precedent as importLas.pde's own un-meshed point cloud");
    assertEquals(0, app.allPolylines.nodes.length);
  }

  @Test
  void importObjectsGEOJSON_multiPoint_importsOneBareVertexPerMember () throws IOException {
    Path f = geojsonFile("geojson-multipoint-test", "{\"type\":\"MultiPoint\",\"coordinates\":[[0,0],[1,0],[2,0]]}");

    doImport(f);

    assertEquals(3, app.allPoints.getLength());
    assertEquals(0, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsGEOJSON_point_appliesTheOffsetAndScaleToAltitudeOnly () throws IOException {
    // lon/lat go through convert_lonlat2XY() (see this file's own header
    // comment on why no exact projected number is pinned down), but
    // altitude is a straight cz + sz * alt pass-through, same as every
    // other importer's own z handling - this is what's asserted here.
    Path f = geojsonFile("geojson-point-altitude-test", "{\"type\":\"Point\",\"coordinates\":[0,0,3]}");

    app.import_objects_GEOJSON(f.toString(), 0, 0, 0, 1, 0, 0, /*cx,cy,cz*/ 10, 20, 30, /*sx,sy,sz*/ 2, 2, 2);

    assertEquals(10f, app.allPoints.getX(0), 0.01f, "lon 0 around lon0 0 projects to local x 0, plus cx offset");
    assertEquals(20f, app.allPoints.getY(0), 0.01f, "lat 0 around lat0 0 projects to local y 0, plus cy offset");
    assertEquals(36f, app.allPoints.getZ(0), 0.0001f, "cz=30 + sz=2 * alt=3 == 36");
  }

  @Test
  void importObjectsGEOJSON_greaterLongitude_projectsToAGreaterLocalX () throws IOException {
    // Pins down relative ordering/sign of the projection without hard-coding
    // convert_lonlat2XY()'s own exact equirectangular formula.
    Path f = geojsonFile("geojson-multipoint-ordering-test", "{\"type\":\"MultiPoint\",\"coordinates\":[[1,0],[2,0]]}");

    doImport(f);

    assertTrue(app.allPoints.getX(1) > app.allPoints.getX(0), "a larger longitude (with latitude/lat0/lon0 all held equal) should project to a larger local x");
  }

  // ================= LineString / MultiLineString ===============================

  @Test
  void importObjectsGEOJSON_lineString_open_importsAnOpenPolyline () throws IOException {
    Path f = geojsonFile("geojson-linestring-open-test", "{\"type\":\"LineString\",\"coordinates\":[[0,0],[1,0],[1,1]]}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
    assertEquals(0, app.allPolylines.getClose(0), "no repeated first/last point - stays open");
  }

  @Test
  void importObjectsGEOJSON_lineString_selfClosing_isAutoDetectedAsClosed () throws IOException {
    // The file's own coordinates repeat [0,0] at the end - the same
    // repetition-based auto-detect importObj.pde's own objHandleLine()/
    // importDxf.pde's own dxfEmitPolyline() already use, not a separate flag.
    Path f = geojsonFile("geojson-linestring-closed-test", "{\"type\":\"LineString\",\"coordinates\":[[0,0],[1,0],[1,1],[0,0]]}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length, "the repeated closing point should be stripped, leaving the 3 distinct points");
    assertEquals(1, app.allPolylines.getClose(0));
  }

  @Test
  void importObjectsGEOJSON_multiLineString_importsOnePolylinePerMember () throws IOException {
    Path f = geojsonFile("geojson-multilinestring-test", "{\"type\":\"MultiLineString\",\"coordinates\":[[[0,0],[1,0]],[[0,1],[1,1],[1,2]]]}");

    doImport(f);

    assertEquals(2, app.allPolylines.nodes.length);
    assertEquals(2, app.allPolylines.nodes[0].length);
    assertEquals(3, app.allPolylines.nodes[1].length);
  }

  // ================= Polygon / MultiPolygon: flat faces =========================

  @Test
  void importObjectsGEOJSON_polygon_holeFree_importsOneFlatFaceWithTheClosingDuplicateStripped () throws IOException {
    Path f = geojsonFile("geojson-polygon-test",
        "{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]]}");

    doImport(f);

    assertEquals(4, app.allPoints.getLength(), "a Polygon ring is always explicitly closed (RFC 7946 3.1.6) - the repeated closing point is always stripped, unconditionally");
    assertEquals(1, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  @Test
  void importObjectsGEOJSON_multiPolygon_importsOneFlatFacePerMember () throws IOException {
    Path f = geojsonFile("geojson-multipolygon-test",
        "{\"type\":\"MultiPolygon\",\"coordinates\":["
        + "[[[0,0],[1,0],[1,1],[0,1],[0,0]]],"
        + "[[[10,10],[11,10],[11,11],[10,11],[10,10]]]"
        + "]}");

    doImport(f);

    assertEquals(2, app.allFaces.nodes.length);
    assertEquals(4, app.allFaces.nodes[0].length);
    assertEquals(4, app.allFaces.nodes[1].length);
  }

  @Test
  void importObjectsGEOJSON_degenerateRing_fewerThanThreeDistinctPoints_isSkipped () throws IOException {
    // Only 2 distinct points once the closing duplicate is stripped - not a
    // real polygon ring, same "skip, don't crash" tolerance every other
    // malformed-geometry case in this importer already follows.
    Path f = geojsonFile("geojson-degenerate-polygon-test",
        "{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[0,0]]]}");

    doImport(f);

    assertEquals(0, app.allFaces.nodes.length);
    assertEquals(1, app.geojsonImportSkippedCount);
  }

  @Test
  void importObjectsGEOJSON_unrecognizedGeometryType_isSkippedWithoutThrowing () throws IOException {
    Path f = geojsonFile("geojson-unrecognized-test", "{\"type\":\"Circle\",\"coordinates\":[0,0],\"radius\":5}");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allPoints.getLength());
    assertEquals(1, app.geojsonImportSkippedCount);
  }

  // ================= Polygon with holes: PolygonHoles.mergeHolesIntoOuterLoop ===

  @Test
  void importObjectsGEOJSON_polygonWithOneHole_bridgesItIntoASingleFace () throws IOException {
    // Outer: a 4-point square. Hole: a 3-point triangle. PolygonHoles.
    // splice() (polygonHoles.pde line 400) builds the bridged loop as:
    // outer[0..outerIndex] (outerIndex+1 points) + the hole walked all the
    // way around AND BACK to its own start (holeLen+1 points) + one more
    // repeat of outer[outerIndex] (1 point) + the rest of outer
    // (outer.size()-outerIndex-1 points) == outer.size() + hole.size() + 2
    // total points - i.e. bridging always costs exactly 2 extra vertices
    // (one duplicate on each side of the zero-area "slit"), whichever
    // outerIndex/holeStart the nearest-point search inside
    // mergeHolesIntoOuterLoop() happens to pick.
    Path f = geojsonFile("geojson-polygon-hole-test",
        "{\"type\":\"Polygon\",\"coordinates\":["
        + "[[0,0],[10,0],[10,10],[0,10],[0,0]],"
        + "[[4,4],[6,4],[5,6],[4,4]]"
        + "]}");

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length, "a hole is bridged into the outer boundary as ONE single face, never triangulated");
    assertEquals(4 + 3 + 2, app.allFaces.nodes[0].length, "outer(4) + hole(3) + 2 bridge-duplicate vertices");
    assertEquals(app.allFaces.nodes[0].length, app.allPoints.getLength());
  }

  // ================= Polygon with geojsonHeightProperty: extrusion ==============

  @Test
  void importObjectsGEOJSON_polygonWithMatchingPositiveHeightProperty_isExtrudedIntoASolid () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = geojsonFile("geojson-polygon-extrude-test",
        "{\"type\":\"Feature\",\"properties\":{\"height\":5},"
        + "\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]]}}");

    doImport(f);

    // n=4: 1 bottom cap + 1 top cap + 4 wall quads == 6 faces, 2n==8 points
    // (one bottom + one top vertex created per outer-ring point - never
    // shared with a flat face's own points, see geojsonEmitExtrudedSolid()'s
    // own comment).
    assertEquals(6, app.allFaces.nodes.length);
    assertEquals(8, app.allPoints.getLength());

    // Every wall quad has exactly 4 corners; both caps are n-gons (4), not
    // triangulated.
    for (int[] face : app.allFaces.nodes) assertEquals(4, face.length);
  }

  @Test
  void importObjectsGEOJSON_polygonWithHeightPropertyNamedButAbsent_staysFlat () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = geojsonFile("geojson-polygon-no-height-test",
        "{\"type\":\"Feature\",\"properties\":{\"name\":\"no height here\"},"
        + "\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]]}}");

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length, "the named height property isn't present on this Feature, so it stays a flat face");
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  @Test
  void importObjectsGEOJSON_polygonWithNonPositiveHeightProperty_staysFlat () throws IOException {
    app.geojsonHeightProperty = "height";

    Path f = geojsonFile("geojson-polygon-zero-height-test",
        "{\"type\":\"Feature\",\"properties\":{\"height\":0},"
        + "\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[2,0],[2,2],[0,2],[0,0]]]}}");

    doImport(f);

    assertEquals(1, app.allFaces.nodes.length, "a height of 0 (or negative) is never an extrusion, same as this importer's own documented tolerance");
    assertEquals(4, app.allFaces.nodes[0].length);
  }

  // ================= FeatureCollection / GeometryCollection =====================

  @Test
  void importObjectsGEOJSON_featureCollection_aggregatesEveryFeature () throws IOException {
    Path f = geojsonFile("geojson-featurecollection-test",
        "{\"type\":\"FeatureCollection\",\"features\":["
        + "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]}},"
        + "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[0,0],[1,0]]}},"
        + "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}"
        + "]}");

    doImport(f);

    assertEquals(1, app.geojsonPointsImported);
    assertEquals(1, app.geojsonLinesImported);
    assertEquals(1, app.geojsonFlatFacesImported);
    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(1, app.allFaces.nodes.length);
  }

  @Test
  void importObjectsGEOJSON_featureCollection_nullGeometryFeature_isSkippedNotAnError () throws IOException {
    // RFC 7946 explicitly allows a Feature's own "geometry" to be null.
    Path f = geojsonFile("geojson-null-geometry-test",
        "{\"type\":\"FeatureCollection\",\"features\":["
        + "{\"type\":\"Feature\",\"properties\":{},\"geometry\":null},"
        + "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]}}"
        + "]}");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(1, app.allPoints.getLength());
    assertEquals(1, app.geojsonImportSkippedCount);
  }

  @Test
  void importObjectsGEOJSON_geometryCollection_recursesIntoEveryMember () throws IOException {
    Path f = geojsonFile("geojson-geometrycollection-test",
        "{\"type\":\"GeometryCollection\",\"geometries\":["
        + "{\"type\":\"Point\",\"coordinates\":[0,0]},"
        + "{\"type\":\"LineString\",\"coordinates\":[[0,0],[1,0]]},"
        + "{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}"
        + "]}");

    doImport(f);

    assertEquals(1, app.geojsonPointsImported);
    assertEquals(1, app.geojsonLinesImported);
    assertEquals(1, app.geojsonFlatFacesImported);
  }

  @Test
  void importObjectsGEOJSON_bareTopLevelGeometry_withNoFeatureOrFeatureCollectionWrapper_isImported () throws IOException {
    // RFC 7946 section 3 allows the root GeoJSON object to be a bare
    // Geometry directly, with no enclosing Feature/FeatureCollection.
    Path f = geojsonFile("geojson-bare-geometry-test", "{\"type\":\"LineString\",\"coordinates\":[[0,0],[1,0],[1,1]]}");

    doImport(f);

    assertEquals(1, app.allPolylines.nodes.length);
    assertEquals(3, app.allPolylines.nodes[0].length);
  }

  // ================= grouping: geojsonGroupProperty =============================

  @Test
  void importObjectsGEOJSON_groupPropertyChange_startsANewGroupAndCyclesMaterial () throws IOException {
    app.geojsonGroupProperty = "layer";

    Path f = geojsonFile("geojson-group-change-test",
        "{\"type\":\"FeatureCollection\",\"features\":["
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"WALLS\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}},"
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"ROOF\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}"
        + "]}");

    app.import_objects_GEOJSON(f.toString(), -1 /*m*/, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, app.allGroups.num, "each distinct grouping-property value should start its own group");
    assertEquals(1, app.allFaces.options[0][0], "m == -1 cycles once per group-property change, starting at 1");
    assertEquals(2, app.allFaces.options[1][0]);
  }

  @Test
  void importObjectsGEOJSON_sameGroupPropertyValueAcrossFeatures_staysInOneGroup () throws IOException {
    app.geojsonGroupProperty = "layer";

    Path f = geojsonFile("geojson-group-same-test",
        "{\"type\":\"FeatureCollection\",\"features\":["
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"WALLS\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}},"
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"WALLS\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}"
        + "]}");

    doImport(f);

    assertEquals(1, app.allGroups.num);
  }

  @Test
  void importObjectsGEOJSON_groupPropertyBlank_neverStartsANewGroupOnItsOwn () throws IOException {
    // Default - geojsonGroupProperty left blank entirely, so this
    // Feature's own differing "layer" values are never read as a
    // grouping key at all - same "optional, tag/property-driven
    // grouping that may never fire" precedent importObj.pde's own "g"
    // tag already sets (ImportObjectsOBJTest.java has no "zero g tags"
    // case of its own either, for the same reason): with nothing to
    // react to, import_objects_GEOJSON() itself never calls
    // allGroups.beginNewGroup() - the real app flow's own
    // _fileSelected_ImportGeojson() is what pre-seeds the one group
    // every import lands in by default (same "if (allGroups.num == 0)"
    // guard _fileSelected_ImportDxf()/_fileSelected_ImportObj() already
    // use), not import_objects_GEOJSON() called directly, as here.
    Path f = geojsonFile("geojson-no-group-option-test",
        "{\"type\":\"FeatureCollection\",\"features\":["
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"WALLS\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}},"
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"ROOF\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}"
        + "]}");

    doImport(f);

    assertEquals(0, app.allGroups.num, "with geojsonGroupProperty blank, the differing \"layer\" property values should be ignored entirely - no group-start signal at all");
    assertEquals(2, app.allFaces.nodes.length, "both polygons should still import fine with no group ever started");
  }

  @Test
  void importObjectsGEOJSON_doesNotStartNewGroups_whenAddingToLastGroup () throws IOException {
    app.geojsonGroupProperty = "layer";
    app.addToLastGroup = true;
    app.allGroups.beginNewGroup(0, 0, 0, 1, 1, 1, 0, 0, 0); // the "last group" to add into

    Path f = geojsonFile("geojson-group-addtolast-test",
        "{\"type\":\"FeatureCollection\",\"features\":["
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"WALLS\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}},"
        + "{\"type\":\"Feature\",\"properties\":{\"layer\":\"ROOF\"},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0,0],[1,0],[1,1],[0,1],[0,0]]]}}"
        + "]}");

    doImport(f);

    assertEquals(1, app.allGroups.num, "both grouping-property changes should have added to the one pre-existing group, not started new ones");
  }

  // ================= progress window headless-safety ===========================
  // Same guarantee ImportObjectsDXFTest.java's own identical test already
  // makes explicit for import_objects_DXF() - see that file's own comment.

  @Test
  void importObjectsGEOJSON_neverThrowsHeadlessExceptionEvenWithShowImportProgressOn () throws IOException {
    Path f = geojsonFile("geojson-headless-test",
        "{\"type\":\"FeatureCollection\",\"features\":["
        + "{\"type\":\"Feature\",\"properties\":{},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]}}"
        + "]}");

    app.showImportProgress = true;

    assertDoesNotThrow(() -> doImport(f));
  }

  @Test
  void importObjectsGEOJSON_unparseableFile_doesNotThrow () throws IOException {
    Path f = geojsonFile("geojson-malformed-test", "{ this is not valid json");

    assertDoesNotThrow(() -> doImport(f));

    assertEquals(0, app.allPoints.getLength());
  }
}
