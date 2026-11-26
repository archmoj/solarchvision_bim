import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.Path;

// exportShapefile() only ever reads allFaces/allPolylines/allPoints (see
// exportShapefile.pde's own file-header comment on "Scope"/structure) and
// writes plain bytes via saveBytes()/saveStrings() - like
// ExportObjectsLASTest.java's own exportLas(), this is directly callable
// from a bare, never-setup()'d instance with no Terrain.Mesh/WIN3D.graphics
// seeding.
//
// Every test below leaves locationLatitude/locationLongitude at their own
// default of (0, 0) - same reasoning as ExportObjectsGEOJSONTest.java's
// own header comment, since exportShapefile.pde reverse-projects through
// exportGeojson.pde's own exportGeojsonPointToLonLatAlt() exactly like
// GeoJSON/KML export do.
//
// Test-side byte reading mixes java.nio.ByteBuffer orders field by field -
// this format's own header genuinely mixes big-endian (file_code,
// file_length) and little-endian (version, shape_type, bounding box)
// fields, which importShapefile.pde's own shpReadInt32BE()/binReadU32LE()
// already read the same mixed way; see that file's own header comment.
class ExportObjectsSHAPEFILETest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () throws java.io.IOException {
    app = new solarchvision_bim();
    app.BaseFolder = java.nio.file.Files.createTempDirectory("solarchvision-bim-test").toString();
    app.sketchPath();
    app.reset_project_folder_to_default();
    app.update_project_folders();
  }

  private ByteBuffer readBE (Path f) throws IOException {
    return ByteBuffer.wrap(Files.readAllBytes(f)).order(ByteOrder.BIG_ENDIAN);
  }

  private ByteBuffer readLE (Path f) throws IOException {
    return ByteBuffer.wrap(Files.readAllBytes(f)).order(ByteOrder.LITTLE_ENDIAN);
  }

  @Test
  void exportShapefile_withNoGeometryAtAll_writesAnEmptyButValidShpFile () throws IOException {
    app.exportShapefile();

    Path shp = Path.of(app.Folder_Export3D, app.ProjectName + ".shp");
    assertTrue(Files.exists(shp));
    assertEquals(100, Files.size(shp), "header only, no records");

    assertEquals(9994, readBE(shp).getInt(0), "file_code");
    assertEquals(15, readLE(shp).getInt(32), "shape_type: PolygonZ");

    Path dbf = Path.of(app.Folder_Export3D, app.ProjectName + ".dbf");
    assertEquals(0, readLE(dbf).getInt(4), "num_records");

    Path prj = Path.of(app.Folder_Export3D, app.ProjectName + ".prj");
    assertTrue(Files.readString(prj).trim().startsWith("GEOGCS"), "shpDetectLonLatFromPrj() only checks this prefix - see importShapefile.pde");
  }

  @Test
  void exportShapefile_withNoVisiblePolylines_neverWritesTheLinesFileSet () {
    app.exportShapefile();

    Path linesShp = Path.of(app.Folder_Export3D, app.ProjectName + "_lines.shp");
    assertFalse(Files.exists(linesShp), "no Polylines in the scene - the optional _lines file set should never be created");
  }

  @Test
  void exportShapefile_aSquareFace_writesOnePolygonZRecordWithAClosedRing () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportShapefile();

    Path shp = Path.of(app.Folder_Export3D, app.ProjectName + ".shp");
    ByteBuffer shpBE = readBE(shp);
    ByteBuffer shpLE = readLE(shp);

    assertEquals(1, shpBE.getInt(100), "record_number");
    int contentLengthWords = shpBE.getInt(104);
    assertEquals(15, shpLE.getInt(108), "shape type inside the record body: PolygonZ");

    int numParts = shpLE.getInt(108 + 32 + 4);
    int numPoints = shpLE.getInt(108 + 32 + 8);
    assertEquals(1, numParts);
    assertEquals(5, numPoints, "4 distinct vertices + the closing duplicate of the first");

    // Body size check: 4(shapeType)+32(bbox)+4(numParts)+4(numPoints)+4(parts)+16*5(points)+16(zRange)+8*5(zValues) = 48+80+16+40 = 184 bytes = 92 words
    assertEquals(184 / 2, contentLengthWords);

    Path shx = Path.of(app.Folder_Export3D, app.ProjectName + ".shx");
    assertEquals(108, Files.size(shx), "100-byte header + one 8-byte index entry");
    ByteBuffer shxBE = readBE(shx);
    assertEquals(50, shxBE.getInt(100), "offset in words to the one record's own header, right after the 100-byte (50-word) main header");
    assertEquals(contentLengthWords, shxBE.getInt(104));
  }

  @Test
  void exportShapefile_aClockwiseLocalRing_isRewoundCounterclockwiseFirstThenStoredClockwise () throws IOException {
    // A ring wound COUNTERCLOCKWISE in local XY (and therefore - at the
    // default (0,0) origin - also counterclockwise once reverse-projected
    // to lon/lat) should come out the other end wound CLOCKWISE, the
    // opposite of exportGeojson.pde's own convention - see
    // exportShapefile.pde's own "Winding" comment.
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    int p3 = app.allPoints.create(0, 10, 0); // counterclockwise in local XY
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportShapefile();

    Path shp = Path.of(app.Folder_Export3D, app.ProjectName + ".shp");
    ByteBuffer shpLE = readLE(shp);
    int pointsOffset = 108 + 32 + 4 + 4 + 4; // shapeType + bbox + numParts + numPoints + parts[0]
    int numPoints = shpLE.getInt(108 + 32 + 8);

    double area = 0;
    for (int i = 0; i < numPoints - 1; i++) { // last point duplicates the first - don't double-count it
      double x0 = shpLE.getDouble(pointsOffset + i * 16);
      double y0 = shpLE.getDouble(pointsOffset + i * 16 + 8);
      int j = (i + 1) % (numPoints - 1);
      double x1 = shpLE.getDouble(pointsOffset + j * 16);
      double y1 = shpLE.getDouble(pointsOffset + j * 16 + 8);
      area += x0 * y1 - x1 * y0;
    }
    assertTrue(area / 2.0 < 0, "ring should have been rewound to a negative (clockwise) signed area, was " + (area / 2.0));
  }

  @Test
  void exportShapefile_faceMaterialAndLayer_areWrittenToTheDbf () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportShapefile();

    byte[] dbf = Files.readAllBytes(Path.of(app.Folder_Export3D, app.ProjectName + ".dbf"));
    ByteBuffer dbfLE = ByteBuffer.wrap(dbf).order(ByteOrder.LITTLE_ENDIAN);
    int headerLen = dbfLE.getShort(8) & 0xFFFF;
    int recordLen = dbfLE.getShort(10) & 0xFFFF;
    assertEquals(1 + 10 + 10, recordLen, "deletion flag + 2 fields of width 10");

    String row = new String(dbf, headerLen, recordLen, java.nio.charset.StandardCharsets.US_ASCII);
    assertEquals(' ', row.charAt(0), "not deleted");
    String materialField = row.substring(1, 11).trim();
    String layerField = row.substring(11, 21).trim();
    assertEquals("7", materialField);
    assertEquals("3", layerField);
  }

  @Test
  void exportShapefile_faceExtraParams_getsItsOwnDbfColumn () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportShapefile();

    byte[] dbf = Files.readAllBytes(Path.of(app.Folder_Export3D, app.ProjectName + ".dbf"));
    ByteBuffer dbfLE = ByteBuffer.wrap(dbf).order(ByteOrder.LITTLE_ENDIAN);
    int headerLen = dbfLE.getShort(8) & 0xFFFF;
    int recordLen = dbfLE.getShort(10) & 0xFFFF;
    assertEquals(1 + 10 + 10 + 254, recordLen, "deletion flag + material/layer fields + the extraParams field");

    // Field descriptor #3 (after the 32-byte header proper and the two
    // material/layer descriptors) should be the Character field named
    // "extraParams".
    int thirdFieldDescriptorOffset = 32 + 32 * 2;
    String thirdFieldName = new String(dbf, thirdFieldDescriptorOffset, 11, java.nio.charset.StandardCharsets.US_ASCII).trim();
    assertEquals("extraParams", thirdFieldName);
    assertEquals('C', (char) dbf[thirdFieldDescriptorOffset + 11]);

    String row = new String(dbf, headerLen, recordLen, java.nio.charset.StandardCharsets.ISO_8859_1);
    String extraParamsField = row.substring(1 + 10 + 10, 1 + 10 + 10 + 254).trim();
    assertEquals("{\"owner\": \"Acme\"}", extraParamsField);
  }

  @Test
  void exportShapefile_noFaceHasExtraParams_omitsTheExtraParamsColumnEntirely () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });

    app.exportShapefile();

    byte[] dbf = Files.readAllBytes(Path.of(app.Folder_Export3D, app.ProjectName + ".dbf"));
    ByteBuffer dbfLE = ByteBuffer.wrap(dbf).order(ByteOrder.LITTLE_ENDIAN);
    int recordLen = dbfLE.getShort(10) & 0xFFFF;
    assertEquals(1 + 10 + 10, recordLen, "no record has extraParams: the dbf should be unchanged from before this feature existed");
  }

  @Test
  void exportShapefile_exporterExtraParamsOff_omitsTheExtraParamsColumnEvenIfSet () throws IOException {
    app.current_Material = 7;
    app.current_Layer = 3;
    app.User3D.exporterExtraParams = false;
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setExtraParams(0, "{\"owner\": \"Acme\"}");

    app.exportShapefile();

    byte[] dbf = Files.readAllBytes(Path.of(app.Folder_Export3D, app.ProjectName + ".dbf"));
    ByteBuffer dbfLE = ByteBuffer.wrap(dbf).order(ByteOrder.LITTLE_ENDIAN);
    int recordLen = dbfLE.getShort(10) & 0xFFFF;
    assertEquals(1 + 10 + 10, recordLen, "exporterExtraParams = false: no extraParams column should be added");
  }

  @Test
  void exportShapefile_aHiddenFace_isSkipped () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(1, 0, 0);
    int p2 = app.allPoints.create(1, 1, 0);
    app.allFaces.create(new int[]{ p0, p1, p2 });
    app.allFaces.setVisibility(0, 0);

    app.exportShapefile();

    Path shp = Path.of(app.Folder_Export3D, app.ProjectName + ".shp");
    assertEquals(100, Files.size(shp), "the hidden face should have left the file empty");
  }

  @Test
  void exportShapefile_aPolyline_writesTheOptionalLinesFileSet () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(5, 0, 0);
    int p2 = app.allPoints.create(5, 5, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 0);

    app.exportShapefile();

    Path linesShp = Path.of(app.Folder_Export3D, app.ProjectName + "_lines.shp");
    assertTrue(Files.exists(linesShp));
    assertEquals(13, readLE(linesShp).getInt(32), "shape_type: PolyLineZ");

    ByteBuffer shpLE = readLE(linesShp);
    int numPoints = shpLE.getInt(108 + 32 + 8);
    assertEquals(3, numPoints, "open polyline: no closing duplicate added");
  }

  @Test
  void exportShapefile_roundTripsAFaceThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 5);
    int p1 = app.allPoints.create(20, 0, 5);
    int p2 = app.allPoints.create(20, 20, 5);
    int p3 = app.allPoints.create(0, 20, 5);
    app.allFaces.create(new int[]{ p0, p1, p2, p3 });

    app.exportShapefile();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".shp");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_SHP(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allFaces.nodes.length);
    assertEquals(4, reader.allFaces.nodes[0].length);

    float minX = Float.MAX_VALUE, maxX = -Float.MAX_VALUE;
    float minY = Float.MAX_VALUE, maxY = -Float.MAX_VALUE;
    for (int node : reader.allFaces.nodes[0]) {
      minX = Math.min(minX, reader.allPoints.getX(node));
      maxX = Math.max(maxX, reader.allPoints.getX(node));
      minY = Math.min(minY, reader.allPoints.getY(node));
      maxY = Math.max(maxY, reader.allPoints.getY(node));
      assertEquals(5f, reader.allPoints.getZ(node), 0.01f, "altitude round-trips with no further projection applied to it");
    }
    assertEquals(0f, minX, 0.5f);
    assertEquals(20f, maxX, 0.5f);
    assertEquals(0f, minY, 0.5f);
    assertEquals(20f, maxY, 0.5f);
  }

  @Test
  void exportShapefile_roundTripsAPolylineThroughImport () throws IOException {
    int p0 = app.allPoints.create(0, 0, 0);
    int p1 = app.allPoints.create(10, 0, 0);
    int p2 = app.allPoints.create(10, 10, 0);
    app.allPolylines.create(new int[]{ p0, p1, p2 });
    app.allPolylines.setClose(0, 1);

    app.exportShapefile();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + "_lines.shp");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();

    reader.import_objects_SHP(exported.toString(), 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(1, reader.allPolylines.nodes.length);
    assertEquals(3, reader.allPolylines.nodes[0].length, "the written closing duplicate is stripped back out on import");
    assertEquals(1, reader.allPolylines.getClose(0));
  }

  @Test
  void exportShapefile_roundTripsMaterialAndLayerThroughImportGrouping () throws IOException {
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

    app.exportShapefile();
    Path exported = Path.of(app.Folder_Export3D, app.ProjectName + ".shp");

    solarchvision_bim reader = new solarchvision_bim();
    reader.BaseFolder = app.BaseFolder;
    reader.sketchPath();
    reader.geojsonGroupProperty = "material";

    reader.import_objects_SHP(exported.toString(), -1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1);

    assertEquals(2, reader.allFaces.nodes.length);
    assertNotEquals(reader.allFaces.getMaterial(0), reader.allFaces.getMaterial(1), "two different source materials should have started two different groups/material cycles");
  }
}
