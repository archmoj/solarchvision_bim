import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

// exportCitygml() only ever reads allFaces/allPoints (never allPolylines -
// see exportCitygml.pde's own file-header comment on why Polylines are
// out of scope here) and writes plain XML via Processing's own saveXML() -
// like ExportObjectsKMLTest.java's own exportKml(), this is directly
// callable from a bare, never-setup()'d instance with no Terrain.Mesh/
// WIN3D.graphics seeding.
//
// Unlike ExportObjectsGEOJSONTest.java/ExportObjectsKMLTest.java, no
// locationLatitude/locationLongitude reasoning applies here at all -
// exportCitygml() never reverse-projects (see exportCitygml.pde's own
// "Coordinates" comment), so every exported coordinate is expected to
// equal its own allPoints value exactly. Structure is checked by reading
// the written file's own XML back with app.loadXML(), and by a real end-
// to-end round trip straight back through import_objects_CITYGML() into
// a SEPARATE app instance - the same two-pronged approach
// ExportObjectsKMLTest.java's own tests already take.
class ExportObjectsCITYGMLTest {

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
    Path f = Path.of(app.Folder_Export3D, app.ProjectName + ".gml");
    return app.loadXML(f.toString());
  }

  @Test
  void exportCitygml_withNoFaces_writesAnEmptyCityModel () {
    app.exportCitygml();

    processing.data.XML cityModel = readExported();
    assertEquals("CityModel", cityModel.getName());
    assertEquals(0, cityModel.getChildren("cityObjectMember").length);
  }

  @Test
  void exportCitygml_aSquareFace_becomesOneBuildingWithAPolygon () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportCitygml();

    processing.data.XML cityModel = readExported();
    processing.data.XML[] members = cityModel.getChildren("cityObjectMember");
    assertEquals(1, members.length);

    processing.data.XML building = members[0].getChild("bldg:Building");
    assertNotNull(building);
    assertEquals("face_0", building.getString("gml:id"));

    processing.data.XML polygon = building.getChild("bldg:lod2MultiSurface").getChild("gml:MultiSurface")
      .getChild("gml:surfaceMember").getChild("gml:Polygon");
    assertNotNull(polygon);
    assertNull(polygon.getChild("gml:interior"), "no holes are ever reconstructed");

    processing.data.XML posListEl = polygon.getChild("gml:exterior").getChild("gml:LinearRing").getChild("gml:posList");
    assertEquals("3", posListEl.getString("srsDimension"));

    String[] numbers = posListEl.getContent().trim().split("\\s+");
    assertEquals(15, numbers.length, "4 distinct XYZ triples + the closing duplicate of the first = 5 triples * 3 numbers");
    assertEquals(numbers[0], numbers[12], "closed ring: last X equals the first");
    assertEquals(numbers[1], numbers[13]);
    assertEquals(numbers[2], numbers[14]);
  }

  @Test
  void exportCitygml_coordinatesAreWrittenExactlyAsStored_noProjection () {
    int p0 = app.allPoints.create(1.5f, -2.25f, 100.125f);
    int p1 = app.allPoints.create(5, 5, 5);
    int p2 = app.allPoints.create(-3, 7, 2);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportCitygml();

    String[] numbers = readExported().getChildren("cityObjectMember")[0].getChild("bldg:Building")
      .getChild("bldg:lod2MultiSurface").getChild("gml:MultiSurface").getChild("gml:surfaceMember")
      .getChild("gml:Polygon").getChild("gml:exterior").getChild("gml:LinearRing")
      .getChild("gml:posList").getContent().trim().split("\\s+");

    assertEquals(1.5f, Float.parseFloat(numbers[0]), 0.0001f);
    assertEquals(-2.25f, Float.parseFloat(numbers[1]), 0.0001f);
    assertEquals(100.125f, Float.parseFloat(numbers[2]), 0.0001f);
  }

  @Test
  void exportCitygml_faceMaterialAndLayer_becomeGenericAttributes () {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportCitygml();

    processing.data.XML building = readExported().getChildren("cityObjectMember")[0].getChild("bldg:Building");

    boolean sawMaterial = false, sawLayer = false;
    for (processing.data.XML attr : building.getChildren("gen:intAttribute")) {
      String name = attr.getString("name");
      String value = attr.getChild("gen:value").getContent();
      if (name.equals("material")) { assertEquals("7", value); sawMaterial = true; }
      if (name.equals("layer")) { assertEquals("3", value); sawLayer = true; }
    }
    assertTrue(sawMaterial, "expected a material gen:intAttribute entry");
    assertTrue(sawLayer, "expected a layer gen:intAttribute entry");
  }

  @Test
  void exportCitygml_aHiddenFace_isSkipped () {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    app.exportCitygml();

    assertEquals(0, readExported().getChildren("cityObjectMember").length);
  }

  @Test
  void exportCitygml_polylinesAreNeverExported () {
    // importCitygml.pde has no LineString/Curve reading at all (its own
    // v1 scope is Polygon geometry only) - see exportCitygml.pde's own
    // "Coordinates"/scope comment on why a Polyline would produce a file
    // IMPORT.CITYGML could never read back.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    app.allPolylines.create(new int[]{ p0, p1 });

    app.exportCitygml();

    assertEquals(0, readExported().getChildren("cityObjectMember").length);
  }

  @Test
  void exportCitygml_aVerticalWallFace_isNeverRewound () {
    // A vertical face (zero XY-plane signed area) - exportGeojson.pde's/
    // exportKml.pde's own shoelace rewinding would be meaningless here;
    // exportCitygml.pde never attempts it (see this file's own header
    // comment, "Winding"), so the ring comes back out in exactly the
    // order it was created, vertex for vertex.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 0, 5);
    int p3 = app.allPoints.create(0, 0, 5);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportCitygml();

    String[] numbers = readExported().getChildren("cityObjectMember")[0].getChild("bldg:Building")
      .getChild("bldg:lod2MultiSurface").getChild("gml:MultiSurface").getChild("gml:surfaceMember")
      .getChild("gml:Polygon").getChild("gml:exterior").getChild("gml:LinearRing")
      .getChild("gml:posList").getContent().trim().split("\\s+");

    // First (and last, closing) triple should be exactly p0's own (0,0,0) -
    // i.e. vertex order was preserved, not reordered by any winding check.
    assertEquals(0f, Float.parseFloat(numbers[0]), 0.0001f);
    assertEquals(0f, Float.parseFloat(numbers[1]), 0.0001f);
    assertEquals(0f, Float.parseFloat(numbers[2]), 0.0001f);
    // Second triple should be p1's own (10,0,0).
    assertEquals(10f, Float.parseFloat(numbers[3]), 0.0001f);
    assertEquals(0f, Float.parseFloat(numbers[4]), 0.0001f);
    assertEquals(0f, Float.parseFloat(numbers[5]), 0.0001f);
  }

  @Test
  void exportCitygml_roundTripsAFaceThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 5);
    int p1 = app.allPoints.create(20, 0, 5);
    int p2 = app.allPoints.create(20, 20, 5);
    int p3 = app.allPoints.create(0, 20, 5);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportCitygml();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".gml");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_CITYGML(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(4, reader.allFaces.nodes[0].length);
    // lod2MultiSurface classifies as volumetric (citygmlCollectGeometryContainers())
    // so this is read back as a flat face, never re-extruded.
    assertEquals(0, reader.geojsonSolidsImported);

    for (int node : reader.allFaces.nodes[0]) {
      assertEquals(5f, reader.allPoints.getZ(node), 0.01f, "coordinates round-trip exactly, no projection involved");
    }
  }

  @Test
  void exportCitygml_roundTripsMaterialAndLayerThroughImportGrouping () throws IOException {
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

    app.exportCitygml();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".gml");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    reader.geojsonGroupProperty = "material";

    reader.import_objects_CITYGML(exported.toString(), -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allFaces.nodes.length);
    assertNotEquals(reader.allFaces.getMaterial(0), reader.allFaces.getMaterial(1), "two different source materials should have started two different groups/material cycles");
  }
}
