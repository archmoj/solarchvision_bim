import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportTopojson() only ever reads allFaces/allPolylines/allPoints (see
// exportTopojson.pde's own file-header comment) and writes plain JSON via
// Processing's own saveJSONObject() - like ExportObjectsGEOJSONTest.java's
// own exportGeojson(), this is directly callable from a bare, never-
// setup()'d instance with no Terrain.Mesh/WIN3D.graphics seeding.
//
// Every test below leaves locationLatitude/locationLongitude at their own
// default of (0, 0) - same reasoning as ExportObjectsGEOJSONTest.java's
// own header comment. Structure is checked two ways: by reading the
// written file's own JSON directly (processing.data.JSONObject/JSONArray,
// the same classes exportTopojson.pde itself writes with), and by a real
// end-to-end round trip straight back through import_objects_TOPOJSON()
// into a SEPARATE app instance - the same two-pronged approach every
// prior GIS exporter's own test file already takes.
class ExportObjectsTOPOJSONTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
    app.reset_project_folder_to_default();
    app.update_project_folders();
  }

  private processing.data.JSONObject readExported () throws IOException {
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + ".topojson");
    return processing.data.JSONObject.parse(Files.readString(f));
  }

  @Test
  void exportTopojson_withNoGeometryAtAll_writesAnEmptyTopology () throws IOException {
    app.exportTopojson();

    processing.data.JSONObject root = readExported();

    assertEquals("Topology", root.getString("type"));
    assertEquals(0, root.getJSONObject("objects").keys().size());
    assertEquals(0, root.getJSONArray("arcs").size());
  }

  @Test
  void exportTopojson_aSquareFace_becomesOneTopLevelPolygonObjectWithAClosedArc () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportTopojson();

    processing.data.JSONObject root = readExported();
    processing.data.JSONObject objects = root.getJSONObject("objects");
    assertEquals(1, objects.keys().size());
    assertTrue(objects.hasKey("face_0"));

    processing.data.JSONObject faceObj = objects.getJSONObject("face_0");
    assertEquals("Polygon", faceObj.getString("type"));

    processing.data.JSONArray rings = faceObj.getJSONArray("arcs");
    assertEquals(1, rings.size(), "no holes are ever reconstructed - see exportGeojson.pde's own 'Scope' comment, reused here");

    processing.data.JSONArray ringOfArcIndexes = rings.getJSONArray(0);
    assertEquals(1, ringOfArcIndexes.size(), "this ring's own single, never-shared arc");
    int arcIndex = ringOfArcIndexes.getInt(0);

    processing.data.JSONArray arc = root.getJSONArray("arcs").getJSONArray(arcIndex);
    assertEquals(5, arc.size(), "4 distinct vertices + the closing duplicate of the first");

    processing.data.JSONArray first = arc.getJSONArray(0);
    processing.data.JSONArray last = arc.getJSONArray(arc.size() - 1);
    assertEquals(first.getFloat(0), last.getFloat(0), 0.0001f, "closed arc: last position equals the first");
    assertEquals(first.getFloat(1), last.getFloat(1), 0.0001f);
  }

  @Test
  void exportTopojson_noTransformIsEverWritten () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportTopojson();

    assertFalse(readExported().hasKey("transform"), "unquantized output - see exportTopojson.pde's own header comment");
  }

  @Test
  void exportTopojson_aClockwiseFace_isRewoundCounterclockwise () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(0, 10, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(10, 0, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 }); // clockwise in local XY

    app.exportTopojson();

    processing.data.JSONObject root = readExported();
    int arcIndex = root.getJSONObject("objects").getJSONObject("face_0")
      .getJSONArray("arcs").getJSONArray(0).getInt(0);
    processing.data.JSONArray arc = root.getJSONArray("arcs").getJSONArray(arcIndex);

    float area = 0;
    int n = arc.size() - 1; // last point duplicates the first - don't double-count it
    for (int i = 0; i < n; i++) {
      processing.data.JSONArray a = arc.getJSONArray(i);
      processing.data.JSONArray b = arc.getJSONArray((i + 1) % n);
      area += a.getFloat(0) * b.getFloat(1) - b.getFloat(0) * a.getFloat(1);
    }
    assertTrue(area / 2.0f > 0, "arc should have been rewound to a positive (counterclockwise) signed area, was " + (area / 2.0f));
  }

  @Test
  void exportTopojson_faceMaterialAndLayer_becomePropertiesOnItsTopLevelObject () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportTopojson();

    processing.data.JSONObject properties = readExported().getJSONObject("objects").getJSONObject("face_0").getJSONObject("properties");
    assertEquals(7, properties.getInt("material"));
    assertEquals(3, properties.getInt("layer"));
  }

  @Test
  void exportTopojson_faceExtraParams_mergeIntoTheTopLevelObjectsProperties () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportTopojson();

    processing.data.JSONObject properties = readExported().getJSONObject("objects").getJSONObject("face_0").getJSONObject("properties");
    assertEquals(7, properties.getInt("material"));
    assertEquals(3, properties.getInt("layer"));
    assertEquals("Acme", properties.getString("owner"));
  }

  @Test
  void exportTopojson_faceExtraParamsCollidingWithLayer_winsOverTheGeneratedLayer () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"layer\": \"roof\"}");

    app.exportTopojson();

    processing.data.JSONObject properties = readExported().getJSONObject("objects").getJSONObject("face_0").getJSONObject("properties");
    assertEquals(7, properties.getInt("material"));
    assertEquals("roof", properties.getString("layer"), "extraParams always wins a material/layer key collision");
  }

  @Test
  void exportTopojson_exporterExtraParamsOff_suppressesTheMergeEntirely () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    app.User3D.exporterExtraParams = false;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportTopojson();

    processing.data.JSONObject properties = readExported().getJSONObject("objects").getJSONObject("face_0").getJSONObject("properties");
    assertEquals(7, properties.getInt("material"));
    assertEquals(3, properties.getInt("layer"));
    assertFalse(properties.hasKey("owner"), "exporterExtraParams = false: no extraParams keys should be merged in");
  }

  @Test
  void exportTopojson_aHiddenFace_isSkipped () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    app.exportTopojson();

    assertEquals(0, readExported().getJSONObject("objects").keys().size());
  }

  @Test
  void exportTopojson_anOpenPolyline_becomesALineStringObjectWithoutAClosingDuplicate () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 0);

    app.exportTopojson();

    processing.data.JSONObject root = readExported();
    processing.data.JSONObject objects = root.getJSONObject("objects");
    assertTrue(objects.hasKey("line_0"));

    processing.data.JSONObject lineObj = objects.getJSONObject("line_0");
    assertEquals("LineString", lineObj.getString("type"));

    processing.data.JSONArray arcIndexes = lineObj.getJSONArray("arcs");
    assertEquals(1, arcIndexes.size(), "this line's own single, never-shared arc");

    processing.data.JSONArray arc = root.getJSONArray("arcs").getJSONArray(arcIndexes.getInt(0));
    assertEquals(3, arc.size(), "open polyline: no closing duplicate added");
  }

  @Test
  void exportTopojson_aClosedPolyline_repeatsItsFirstPositionAtTheEndOfItsArc () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportTopojson();

    processing.data.JSONObject root = readExported();
    int arcIndex = root.getJSONObject("objects").getJSONObject("line_0").getJSONArray("arcs").getInt(0);
    processing.data.JSONArray arc = root.getJSONArray("arcs").getJSONArray(arcIndex);
    assertEquals(4, arc.size(), "closed polyline: first position repeated at the end");

    processing.data.JSONArray first = arc.getJSONArray(0);
    processing.data.JSONArray last = arc.getJSONArray(arc.size() - 1);
    assertEquals(first.getFloat(0), last.getFloat(0), 0.0001f);
    assertEquals(first.getFloat(1), last.getFloat(1), 0.0001f);
  }

  @Test
  void exportTopojson_noStandaloneAllPointsEntry_everBecomesATopLevelObject () throws IOException {
    app.allPoints.create(1, 2, 3);
    app.allPoints.create(4, 5, 6);

    app.exportTopojson();

    assertEquals(0, readExported().getJSONObject("objects").keys().size());
  }

  @Test
  void exportTopojson_roundTripsAFaceThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 5);
    int p1 = app.allPoints.create(20, 0, 5);
    int p2 = app.allPoints.create(20, 20, 5);
    int p3 = app.allPoints.create(0, 20, 5);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportTopojson();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".topojson");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_TOPOJSON(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(4, reader.allFaces.nodes[0].length);

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
  void exportTopojson_roundTripsAClosedPolylineThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportTopojson();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".topojson");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_TOPOJSON(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allPolylines.nodes.length);
    assertEquals(3, reader.allPolylines.nodes[0].length, "the written closing duplicate is stripped back out on import, same as any other already-closed LineString");
    assertEquals(1, reader.allPolylines.getClose(0));
  }

  @Test
  void exportTopojson_roundTripsMaterialAndLayerThroughImportGrouping () throws IOException {
    app.current_Material = 1;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.current_Material = 2;
    int p3 = app.allPoints.create(5, 5, 0);
    int p4 = app.allPoints.create(6, 5, 0);
    int p5 = app.allPoints.create(6, 6, 0);
    app.allFaces.create(new int[]{ p3, p4, p5 });

    app.exportTopojson();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".topojson");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    reader.geojsonGroupProperty = "material";

    reader.import_objects_TOPOJSON(exported.toString(), -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allFaces.nodes.length);
    assertNotEquals(reader.allFaces.getMaterial(0), reader.allFaces.getMaterial(1), "two different source materials, each its own top-level TopoJSON object, should have started two different groups/material cycles");
  }
}
