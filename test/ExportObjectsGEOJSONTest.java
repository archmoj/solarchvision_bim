import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportGeojson() only ever reads allFaces/allPolylines/allPoints (see
// exportGeojson.pde's own file-header comment on "Scope") and writes
// plain JSON via Processing's own saveJSONObject() - like
// ExportObjectsLASTest.java's own exportLas(), this is directly callable
// from a bare, never-setup()'d instance with no Terrain.Mesh/WIN3D.graphics
// seeding.
//
// Every test below leaves locationLatitude/locationLongitude at their own
// default of (0, 0) (globalVariables.pde), so Functions.convert_XY2lonlat()
// projects around the origin - same "no exact magic-number projected
// coordinate asserted, structure instead" precedent
// ImportObjectsGEOJSONTest.java's own header comment already explains, just
// facing the opposite direction here. Structure is checked two ways: by
// reading the written file's own JSON directly (processing.data.JSONObject/
// JSONArray, the same classes exportGeojson.pde itself writes with - see
// Earth3DTest.java's own fully-qualified processing.data.XML precedent for
// why these aren't a bare top-level import in a .java test file the way
// they're a bare type in a .pde production file), and by a real end-to-end
// round trip straight back through import_objects_GEOJSON() into a SEPARATE
// app instance - the same two-pronged approach ExportObjectsLASTest.java's
// own byte-level + round-trip tests already take for LAS.
class ExportObjectsGEOJSONTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    // See Earth3DTest.java's own comment on why this isn't
    // app.locateBaseFolder().
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath(); // side effect: lazily caches into PApplet's own sketchPath field - see ExportObjectsLASTest.java's own identical comment
    app.reset_project_folder_to_default(); // Folder_Project is null until this runs
    app.update_project_folders(); // Folder_Export3D is null until this runs
  }

  private processing.data.JSONObject readExported (String suffixedName) throws IOException {
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + suffixedName);
    return processing.data.JSONObject.parse(Files.readString(f));
  }

  @Test
  void exportGeojson_withNoGeometryAtAll_writesAnEmptyFeatureCollection () throws IOException {
    app.exportGeojson();

    processing.data.JSONObject root = readExported(".geojson");

    assertEquals("FeatureCollection", root.getString("type"));
    assertEquals(0, root.getJSONArray("features").size());
  }

  @Test
  void exportGeojson_aSquareFace_becomesOnePolygonFeatureWithAClosedRing () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportGeojson();

    processing.data.JSONObject root = readExported(".geojson");
    processing.data.JSONArray features = root.getJSONArray("features");
    assertEquals(1, features.size());

    processing.data.JSONObject feature = features.getJSONObject(0);
    assertEquals("Feature", feature.getString("type"));

    processing.data.JSONObject geometry = feature.getJSONObject("geometry");
    assertEquals("Polygon", geometry.getString("type"));

    processing.data.JSONArray rings = geometry.getJSONArray("coordinates");
    assertEquals(1, rings.size(), "no holes are ever reconstructed - see exportGeojson.pde's own 'Scope' comment");

    processing.data.JSONArray ring = rings.getJSONArray(0);
    assertEquals(5, ring.size(), "4 distinct vertices + the closing duplicate of the first (RFC 7946 section 3.1.6)");

    processing.data.JSONArray first = ring.getJSONArray(0);
    processing.data.JSONArray last = ring.getJSONArray(ring.size() - 1);
    assertEquals(first.getFloat(0), last.getFloat(0), 0.0001f, "closed ring: last position equals the first");
    assertEquals(first.getFloat(1), last.getFloat(1), 0.0001f);
  }

  @Test
  void exportGeojson_aClockwiseFace_isRewoundCounterclockwise () throws IOException {
    // Same square as above, but its own node loop is wound CLOCKWISE in
    // local XY (and therefore - locationLongitude/Latitude both sitting
    // at the default (0,0) origin - also clockwise once reverse-projected
    // into lon/lat, since convert_XY2lonlat() is a simple, orientation-
    // preserving equirectangular projection at the equator/meridian) -
    // exportGeojsonBuildPolygonFeature() should detect this via its own
    // shoelace signed-area check and reverse it, per RFC 7946 section
    // 3.1.6's own counterclockwise-exterior-ring convention (see this
    // file's own header comment and exportGeojson.pde's own "Winding"
    // comment).
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(0, 10, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(10, 0, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 }); // clockwise in local XY

    app.exportGeojson();

    processing.data.JSONObject root = readExported(".geojson");
    processing.data.JSONArray ring = root.getJSONArray("features").getJSONObject(0)
      .getJSONObject("geometry").getJSONArray("coordinates").getJSONArray(0);

    float area = 0;
    int n = ring.size() - 1; // last point duplicates the first - don't double-count it
    for (int i = 0; i < n; i++) {
      processing.data.JSONArray a = ring.getJSONArray(i);
      processing.data.JSONArray b = ring.getJSONArray((i + 1) % n);
      area += a.getFloat(0) * b.getFloat(1) - b.getFloat(0) * a.getFloat(1);
    }
    assertTrue(area / 2.0f > 0, "ring should have been rewound to a positive (counterclockwise) signed area, was " + (area / 2.0f));
  }

  @Test
  void exportGeojson_faceMaterialAndLayer_becomePropertiesOnTheFeature () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportGeojson();

    processing.data.JSONObject properties = readExported(".geojson").getJSONArray("features")
      .getJSONObject(0).getJSONObject("properties");
    assertEquals(7, properties.getInt("material"));
    assertEquals(3, properties.getInt("layer"));
  }

  @Test
  void exportGeojson_faceExtraParams_mergeIntoTheFeatureProperties () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportGeojson();

    processing.data.JSONObject properties = readExported(".geojson").getJSONArray("features")
      .getJSONObject(0).getJSONObject("properties");
    assertEquals(7, properties.getInt("material"));
    assertEquals(3, properties.getInt("layer"));
    assertEquals("Acme", properties.getString("owner"));
  }

  @Test
  void exportGeojson_faceExtraParamsCollidingWithMaterial_winsOverTheGeneratedMaterial () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"material\": \"glass\"}");

    app.exportGeojson();

    processing.data.JSONObject properties = readExported(".geojson").getJSONArray("features")
      .getJSONObject(0).getJSONObject("properties");
    assertEquals("glass", properties.getString("material"), "extraParams always wins a material/layer key collision");
    assertEquals(3, properties.getInt("layer"));
  }

  @Test
  void exportGeojson_exportExtraParamsOff_suppressesTheMergeEntirely () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    app.exportExtraParams = false;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportGeojson();

    processing.data.JSONObject properties = readExported(".geojson").getJSONArray("features")
      .getJSONObject(0).getJSONObject("properties");
    assertEquals(7, properties.getInt("material"));
    assertEquals(3, properties.getInt("layer"));
    assertFalse(properties.hasKey("owner"), "exportExtraParams = false: no extraParams keys should be merged in");
  }

  @Test
  void exportGeojson_aHiddenFace_isSkipped () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    app.exportGeojson();

    assertEquals(0, readExported(".geojson").getJSONArray("features").size());
  }

  @Test
  void exportGeojson_anOpenPolyline_becomesALineStringWithoutAClosingDuplicate () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 0);

    app.exportGeojson();

    processing.data.JSONObject feature = readExported(".geojson").getJSONArray("features").getJSONObject(0);
    assertEquals("LineString", feature.getJSONObject("geometry").getString("type"));

    processing.data.JSONArray coords = feature.getJSONObject("geometry").getJSONArray("coordinates");
    assertEquals(3, coords.size(), "open polyline: no closing duplicate added");
  }

  @Test
  void exportGeojson_aClosedPolyline_repeatsItsFirstCoordinateAtTheEnd () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportGeojson();

    processing.data.JSONArray coords = readExported(".geojson").getJSONArray("features").getJSONObject(0)
      .getJSONObject("geometry").getJSONArray("coordinates");
    assertEquals(4, coords.size(), "closed polyline: first coordinate repeated at the end");

    processing.data.JSONArray first = coords.getJSONArray(0);
    processing.data.JSONArray last = coords.getJSONArray(coords.size() - 1);
    assertEquals(first.getFloat(0), last.getFloat(0), 0.0001f);
    assertEquals(first.getFloat(1), last.getFloat(1), 0.0001f);
  }

  @Test
  void exportGeojson_noStandaloneAllPointsEntry_everBecomesAFeature () throws IOException {
    // allPoints is an append-only pool with no "this one is really a
    // standalone point" bookkeeping - see exportGeojson.pde's own "Scope"
    // comment, and exportLas.pde's own header comment for the same
    // observation on the way LAS export already treats allPoints.
    app.allPoints.create(1, 2, 3);
    app.allPoints.create(4, 5, 6);

    app.exportGeojson();

    assertEquals(0, readExported(".geojson").getJSONArray("features").size());
  }

  @Test
  void exportGeojson_roundTripsAFaceThroughImport () throws IOException {
    // The real end-to-end check (ExportObjectsLASTest.java's own
    // "exportLas_exportATriangle_thenImportIt_roundTripsItsVertices" does
    // the same thing for LAS): export a real face, then feed that exact
    // file straight into import_objects_GEOJSON() in a SEPARATE app
    // instance, and confirm the same polygon comes back - both ends share
    // the same default (0,0) locationLongitude/locationLatitude, so the
    // forward reverse-projection (export) and its own inverse (import)
    // cancel out exactly.
    int p0 = app.allPoints.create(0, 0, 5);
    int p1 = app.allPoints.create(20, 0, 5);
    int p2 = app.allPoints.create(20, 20, 5);
    int p3 = app.allPoints.create(0, 20, 5);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportGeojson();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".geojson");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_GEOJSON(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(4, reader.allFaces.nodes[0].length);

    // Gather the reimported face's own vertex XY's into a simple bounding
    // box rather than asserting any particular winding/starting-vertex,
    // since exportGeojsonBuildPolygonFeature()'s own winding-normalization
    // (see the "rewound counterclockwise" test above) is free to reorder
    // (and, for an already-correctly-wound ring, never rotate) the ring's
    // own starting point.
    float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
    float minY = Float.MAX_VALUE, maxY = -Float.MAX_VALUE;
    for (int node : reader.allFaces.nodes[0]) {
      minX = Math.min(minX, reader.allPoints.getX(node));
      maxX = Math.max(maxX, reader.allPoints.getX(node));
      minY = Math.min(minY, reader.allPoints.getY(node));
      maxY = Math.max(maxY, reader.allPoints.getY(node));
      assertEquals(5f, reader.allPoints.getZ(node), 0.01f, "altitude round-trips with no projection involved");
    }
    assertEquals(0f, minX, 0.5f);
    assertEquals(20f, maxX, 0.5f);
    assertEquals(0f, minY, 0.5f);
    assertEquals(20f, maxY, 0.5f);
  }

  @Test
  void exportGeojson_roundTripsAClosedPolylineThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportGeojson();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".geojson");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_GEOJSON(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allPolylines.nodes.length);
    assertEquals(3, reader.allPolylines.nodes[0].length, "the written closing duplicate is stripped back out on import, same as any other already-closed LineString - see importGeojson.pde's own geojsonStripClosingDuplicate()");
    assertEquals(1, reader.allPolylines.getClose(0), "a LineString whose own coordinates already close the loop re-imports as closed");
  }
}
