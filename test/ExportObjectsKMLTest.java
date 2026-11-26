import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportKml() only ever reads allFaces/allPolylines/allPoints (see
// exportKml.pde's own file-header comment on "Scope", reusing
// exportGeojson.pde's own shared core) and writes plain XML via
// Processing's own saveXML() - like ExportObjectsGEOJSONTest.java's own
// exportGeojson(), this is directly callable from a bare, never-setup()'d
// instance with no Terrain.Mesh/WIN3D.graphics seeding.
//
// Every test below leaves locationLatitude/locationLongitude at their own
// default of (0, 0) - same reasoning as ExportObjectsGEOJSONTest.java's
// own header comment. Structure is checked by reading the written file's
// own XML back with app.loadXML() (the same built-in loadXML()
// exportKml.pde's own saveXML() mirrors, and importKml.pde/importDae.pde/
// importCitygml.pde already read production KML/COLLADA/CityGML files
// with), and by a real end-to-end round trip straight back through
// import_objects_KML() into a SEPARATE app instance - the same two-
// pronged approach ExportObjectsGEOJSONTest.java's own tests already take.
class ExportObjectsKMLTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
    app.reset_project_folder_to_default();
    app.update_project_folders();
  }

  private processing.data.XML readExported () {
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + ".kml");
    return app.loadXML(f.toString());
  }

  @Test
  void exportKml_withNoGeometryAtAll_writesAnEmptyDocument () {
    app.exportKml();

    processing.data.XML kml = readExported();
    assertEquals("kml", kml.getName());
    processing.data.XML document = kml.getChild("Document");
    assertNotNull(document);
    assertEquals(0, document.getChildren("Placemark").length);
  }

  @Test
  void exportKml_aSquareFace_becomesOnePlacemarkWithAPolygon () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportKml();

    processing.data.XML document = readExported().getChild("Document");
    processing.data.XML[] placemarks = document.getChildren("Placemark");
    assertEquals(1, placemarks.length);

    processing.data.XML polygon = placemarks[0].getChild("Polygon");
    assertNotNull(polygon);
    processing.data.XML ring = polygon.getChild("outerBoundaryIs").getChild("LinearRing");
    assertNull(polygon.getChild("innerBoundaryIs"), "no holes are ever reconstructed - see exportKml.pde's own 'Scope' comment");

    String coordsText = ring.getChild("coordinates").getContent().trim();
    String[] tuples = coordsText.split("\\s+");
    assertEquals(5, tuples.length, "4 distinct vertices + the closing duplicate of the first");
    assertEquals(tuples[0], tuples[4], "closed ring: last tuple equals the first");
  }

  @Test
  void exportKml_faceMaterialAndLayer_becomeExtendedDataEntries () {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportKml();

    processing.data.XML placemark = readExported().getChild("Document").getChildren("Placemark")[0];
    processing.data.XML extendedData = placemark.getChild("ExtendedData");
    assertNotNull(extendedData);

    boolean sawMaterial = false, sawLayer = false;
    for (processing.data.XML data : extendedData.getChildren("Data")) {
      String name = data.getString("name");
      String value = data.getChild("value").getContent();
      if (name.equals("material")) { assertEquals("7", value); sawMaterial = true; }
      if (name.equals("layer")) { assertEquals("3", value); sawLayer = true; }
    }
    assertTrue(sawMaterial, "expected a material Data entry");
    assertTrue(sawLayer, "expected a layer Data entry");
  }

  @Test
  void exportKml_faceExtraParams_mergeIntoTheExtendedDataEntries () {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportKml();

    processing.data.XML placemark = readExported().getChild("Document").getChildren("Placemark")[0];
    processing.data.XML extendedData = placemark.getChild("ExtendedData");
    assertNotNull(extendedData);

    boolean sawMaterial = false, sawLayer = false, sawOwner = false;
    for (processing.data.XML data : extendedData.getChildren("Data")) {
      String name = data.getString("name");
      String value = data.getChild("value").getContent();
      if (name.equals("material")) { assertEquals("7", value); sawMaterial = true; }
      if (name.equals("layer")) { assertEquals("3", value); sawLayer = true; }
      if (name.equals("owner")) { assertEquals("Acme", value); sawOwner = true; }
    }
    assertTrue(sawMaterial, "expected a material Data entry");
    assertTrue(sawLayer, "expected a layer Data entry");
    assertTrue(sawOwner, "expected an owner Data entry merged in from extraParams");
  }

  @Test
  void exportKml_faceExtraParamsCollidingWithMaterial_winsOverTheGeneratedMaterial () {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"material\": \"glass\"}");

    app.exportKml();

    processing.data.XML placemark = readExported().getChild("Document").getChildren("Placemark")[0];
    processing.data.XML extendedData = placemark.getChild("ExtendedData");

    boolean sawMaterial = false;
    for (processing.data.XML data : extendedData.getChildren("Data")) {
      if (data.getString("name").equals("material")) {
        assertEquals("glass", data.getChild("value").getContent(), "extraParams always wins a material/layer key collision");
        sawMaterial = true;
      }
    }
    assertTrue(sawMaterial, "expected a material Data entry");
  }

  @Test
  void exportKml_exportExtraParamsOff_suppressesTheMergeEntirely () {
    app.current_Material = 7;
    app.current_Layer = 3;
    app.exportExtraParams = false;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportKml();

    processing.data.XML placemark = readExported().getChild("Document").getChildren("Placemark")[0];
    processing.data.XML extendedData = placemark.getChild("ExtendedData");

    boolean sawMaterial = false, sawLayer = false, sawOwner = false;
    for (processing.data.XML data : extendedData.getChildren("Data")) {
      String name = data.getString("name");
      if (name.equals("material")) sawMaterial = true;
      if (name.equals("layer")) sawLayer = true;
      if (name.equals("owner")) sawOwner = true;
    }
    assertTrue(sawMaterial, "expected a material Data entry");
    assertTrue(sawLayer, "expected a layer Data entry");
    assertFalse(sawOwner, "exportExtraParams = false: no extraParams keys should be merged in");
  }

  @Test
  void exportKml_aHiddenFace_isSkipped () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    app.exportKml();

    assertEquals(0, readExported().getChild("Document").getChildren("Placemark").length);
  }

  @Test
  void exportKml_anOpenPolyline_becomesALineStringWithoutAClosingDuplicate () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 0);

    app.exportKml();

    processing.data.XML placemark = readExported().getChild("Document").getChildren("Placemark")[0];
    processing.data.XML lineString = placemark.getChild("LineString");
    assertNotNull(lineString);

    String coordsText = lineString.getChild("coordinates").getContent().trim();
    assertEquals(3, coordsText.split("\\s+").length, "open polyline: no closing duplicate added");
  }

  @Test
  void exportKml_aClosedPolyline_repeatsItsFirstCoordinateAtTheEnd () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportKml();

    String coordsText = readExported().getChild("Document").getChildren("Placemark")[0]
      .getChild("LineString").getChild("coordinates").getContent().trim();
    String[] tuples = coordsText.split("\\s+");
    assertEquals(4, tuples.length, "closed polyline: first coordinate repeated at the end");
    assertEquals(tuples[0], tuples[3]);
  }

  @Test
  void exportKml_noStandaloneAllPointsEntry_everBecomesAPlacemark () {
    app.allPoints.create(1, 2, 3);
    app.allPoints.create(4, 5, 6);

    app.exportKml();

    assertEquals(0, readExported().getChild("Document").getChildren("Placemark").length);
  }

  @Test
  void exportKml_roundTripsAFaceThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 5);
    int p1 = app.allPoints.create(20, 0, 5);
    int p2 = app.allPoints.create(20, 20, 5);
    int p3 = app.allPoints.create(0, 20, 5);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportKml();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".kml");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_KML(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(4, reader.allFaces.nodes[0].length);

    float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
    float minY = Float.MAX_VALUE, maxY = -Float.MAX_VALUE;
    for (int node : reader.allFaces.nodes[0]) {
      minX = Math.min(minX, reader.allPoints.getX(node));
      maxX = Math.max(maxX, reader.allPoints.getX(node));
      minY = Math.min(minY, reader.allPoints.getY(node));
      maxY = Math.max(maxY, reader.allPoints.getY(node));
      assertEquals(5f, reader.allPoints.getZ(node), 0.01f);
    }
    assertEquals(0f, minX, 0.5f);
    assertEquals(20f, maxX, 0.5f);
    assertEquals(0f, minY, 0.5f);
    assertEquals(20f, maxY, 0.5f);
  }

  @Test
  void exportKml_roundTripsAClosedPolylineThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportKml();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".kml");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_KML(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allPolylines.nodes.length);
    assertEquals(3, reader.allPolylines.nodes[0].length, "the written closing duplicate is stripped back out on import - see importKml.pde's own geojsonStripClosingDuplicate() comment");
    assertEquals(1, reader.allPolylines.getClose(0));
  }

  @Test
  void exportKml_roundTripsMaterialAndLayerThroughImportGrouping () throws IOException {
    // The round-trip this whole scheme exists for: typing "material"
    // into IMPORT.KML's own group-property option regroups by the
    // exact value this exporter wrote - two faces with different
    // materials should land in two different groups.
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

    app.exportKml();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".kml");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    reader.geojsonGroupProperty = "material";

    reader.import_objects_KML(exported.toString(), -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allFaces.nodes.length);
    assertNotEquals(reader.allFaces.getMaterial(0), reader.allFaces.getMaterial(1), "two different source materials should have started two different groups/material cycles");
  }
}
