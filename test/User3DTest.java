import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class User3DTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.User3D.creatorMaterial = 3;
    app.User3D.creatorTessellation = 1;
    app.User3D.creatorLayer = 2;
    app.User3D.creatorVisibility = 0;
    app.User3D.creatorWeight = 4;
    app.User3D.creatorClosed = 1;

    app.User3D.creatorLength = 11;
    app.User3D.creatorWidth = 12;
    app.User3D.creatorHeight = 13;
    app.User3D.creatorVolume = 14;
    app.User3D.creatorOrientation = 15;
    app.User3D.creatorSuperellipsoidPowerX = 2.1f;
    app.User3D.creatorSuperellipsoidPowerY = 2.2f;
    app.User3D.creatorSuperellipsoidPowerZ = 2.3f;
    app.User3D.creatorUniformSuperellipsoidPower = 9;
    app.User3D.creatorRandomSuperellipsoidPower = 1;
    app.User3D.creatorSphereDegree = 5;
    app.User3D.creatorCylinderDegree = 30;
    app.User3D.creatorConeDegree = 31;
    app.User3D.creatorPolygonDegree = 8;
    app.User3D.creatorParametricTypeIndex = 2;
    app.User3D.creatorPersonTypeIndex = 1;
    app.User3D.creatorPlantTypeIndex = 1;

    app.User3D.creatorModel1DTypeIndex = 3;
    app.User3D.creatorModel1DDegreeMax = 10;
    app.User3D.creatorModel1DSeed = 42;
    app.User3D.creatorModel1DTrunkSize = 1.5f;
    app.User3D.creatorModel1DLeafSize = 0.3f;

    app.User3D.creatorMeshOrSolidMode = 1;
    app.User3D.creatorSnapModeIndex = 1;

    app.User3D.modifierTessellateRows = 4;
    app.User3D.modifierTessellateColumns = 5;
    app.User3D.modifierOpeningDepth = 2;
    app.User3D.modifierOpeningArea = 0.3f;
    app.User3D.modifierOpeningDeviation = 0.6f;
    app.User3D.modifierOffsetAmount = 1.5f;
    app.User3D.modifierWeldThreshold = 0.2f;

    app.User3D.exporterScale = 0.5f;
    app.User3D.exporterYaxisUp = 0;
    app.User3D.exporterPrecisionVertex = 8;
    app.User3D.exporterPrecisionVertexTexture = 5;
    app.User3D.exporterMaintainPolygons = 0;
    app.User3D.exporterMaterialLibrary = false;
    app.User3D.exporterDoubleSided = false;
    app.User3D.exporterColorscaleResolution = 128;

    processing.data.XML root = new processing.data.XML("root");
    app.User3D.to_XML(root);

    solarchvision_bim.User3D fresh = app.new User3D();
    fresh.from_XML(root);

    assertEquals(3, fresh.creatorMaterial);
    assertEquals(0, fresh.creatorVisibility);

    assertEquals(11f, fresh.creatorLength, 0.0001f);
    assertEquals(15f, fresh.creatorOrientation, 0.0001f);
    assertEquals(2.1f, fresh.creatorSuperellipsoidPowerX, 0.0001f);
    assertEquals(9f, fresh.creatorUniformSuperellipsoidPower, 0.0001f);
    assertEquals(1, fresh.creatorRandomSuperellipsoidPower);
    assertEquals(5, fresh.creatorSphereDegree);
    assertEquals(30, fresh.creatorCylinderDegree);
    assertEquals(31, fresh.creatorConeDegree);
    assertEquals(2, fresh.creatorParametricTypeIndex);
    assertEquals(1, fresh.creatorPlantTypeIndex);

    assertEquals(3, fresh.creatorModel1DTypeIndex);
    assertEquals(10, fresh.creatorModel1DDegreeMax);
    assertEquals(42, fresh.creatorModel1DSeed);
    assertEquals(1.5f, fresh.creatorModel1DTrunkSize, 0.0001f);
    assertEquals(0.3f, fresh.creatorModel1DLeafSize, 0.0001f);

    assertEquals(1, fresh.creatorMeshOrSolidMode);
    assertEquals(1, fresh.creatorSnapModeIndex);

    assertEquals(4, fresh.modifierTessellateRows);
    assertEquals(5, fresh.modifierTessellateColumns);
    assertEquals(2f, fresh.modifierOpeningDepth, 0.0001f);
    assertEquals(0.3f, fresh.modifierOpeningArea, 0.0001f);
    assertEquals(0.6f, fresh.modifierOpeningDeviation, 0.0001f);
    assertEquals(1.5f, fresh.modifierOffsetAmount, 0.0001f);
    assertEquals(0.2f, fresh.modifierWeldThreshold, 0.0001f);

    assertEquals(0.5f, fresh.exporterScale, 0.0001f);
    assertEquals(0, fresh.exporterYaxisUp);
    assertEquals(8, fresh.exporterPrecisionVertex);
    assertEquals(5, fresh.exporterPrecisionVertexTexture);
    assertEquals(0, fresh.exporterMaintainPolygons);
    assertFalse(fresh.exporterMaterialLibrary);
    assertFalse(fresh.exporterDoubleSided);
    assertEquals(128, fresh.exporterColorscaleResolution);
  }
}
