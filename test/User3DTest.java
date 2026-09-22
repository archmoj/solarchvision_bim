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
    app.User3D.default_Material = 3;
    app.User3D.default_Tessellation = 1;
    app.User3D.default_Layer = 2;
    app.User3D.default_Visibility = 0;
    app.User3D.default_Weight = 4;
    app.User3D.default_Closed = 1;

    app.User3D.create_Length = 11;
    app.User3D.create_Width = 12;
    app.User3D.create_Height = 13;
    app.User3D.create_Volume = 14;
    app.User3D.create_Orientation = 15;
    app.User3D.create_powX = 2.1f;
    app.User3D.create_powY = 2.2f;
    app.User3D.create_powZ = 2.3f;
    app.User3D.create_powAll = 9;
    app.User3D.create_powRnd = 1;
    app.User3D.create_SphereDegree = 5;
    app.User3D.create_CylinderDegree = 30;
    app.User3D.create_PolyDegree = 8;
    app.User3D.create_Parametric_Type = 2;
    app.User3D.create_Person_Type = 1;
    app.User3D.create_Plant_Type = 1;

    app.User3D.create_Model1D_Type = 3;
    app.User3D.create_Model1D_DegreeMax = 10;
    app.User3D.create_Model1D_Seed = 42;
    app.User3D.create_Model1D_TrunkSize = 1.5f;
    app.User3D.create_Model1D_LeafSize = 0.3f;

    app.User3D.create_MeshOrSolid = 1;
    app.User3D.create_Snap = 1;

    app.User3D.modify_TessellateRows = 4;
    app.User3D.modify_TessellateColumns = 5;
    app.User3D.modify_OpenningDepth = 2;
    app.User3D.modify_OpenningArea = 0.3f;
    app.User3D.modify_OpenningDeviation = 0.6f;
    app.User3D.modify_OffsetAmount = 1.5f;
    app.User3D.modify_WeldTreshold = 0.2f;

    app.User3D.export_Scale = 0.5f;
    app.User3D.export_FlipZYaxis = 0;
    app.User3D.export_PrecisionVertex = 8;
    app.User3D.export_PrecisionVtexture = 5;
    app.User3D.export_PolyToPoly = 0;
    app.User3D.export_MaterialLibrary = false;
    app.User3D.export_BackSides = false;
    app.User3D.export_PaletteResolution = 128;

    processing.data.XML root = new processing.data.XML("root");
    app.User3D.to_XML(root);

    solarchvision_bim.User3D fresh = app.new User3D();
    fresh.from_XML(root);

    assertEquals(3, fresh.default_Material);
    assertEquals(0, fresh.default_Visibility);

    assertEquals(11f, fresh.create_Length, 0.0001f);
    assertEquals(15f, fresh.create_Orientation, 0.0001f);
    assertEquals(2.1f, fresh.create_powX, 0.0001f);
    assertEquals(9f, fresh.create_powAll, 0.0001f);
    assertEquals(1, fresh.create_powRnd);
    assertEquals(5, fresh.create_SphereDegree);
    assertEquals(30, fresh.create_CylinderDegree);
    assertEquals(2, fresh.create_Parametric_Type);
    assertEquals(1, fresh.create_Plant_Type);

    assertEquals(3, fresh.create_Model1D_Type);
    assertEquals(10, fresh.create_Model1D_DegreeMax);
    assertEquals(42, fresh.create_Model1D_Seed);
    assertEquals(1.5f, fresh.create_Model1D_TrunkSize, 0.0001f);
    assertEquals(0.3f, fresh.create_Model1D_LeafSize, 0.0001f);

    assertEquals(1, fresh.create_MeshOrSolid);
    assertEquals(1, fresh.create_Snap);

    assertEquals(4, fresh.modify_TessellateRows);
    assertEquals(5, fresh.modify_TessellateColumns);
    assertEquals(2f, fresh.modify_OpenningDepth, 0.0001f);
    assertEquals(0.3f, fresh.modify_OpenningArea, 0.0001f);
    assertEquals(0.6f, fresh.modify_OpenningDeviation, 0.0001f);
    assertEquals(1.5f, fresh.modify_OffsetAmount, 0.0001f);
    assertEquals(0.2f, fresh.modify_WeldTreshold, 0.0001f);

    assertEquals(0.5f, fresh.export_Scale, 0.0001f);
    assertEquals(0, fresh.export_FlipZYaxis);
    assertEquals(8, fresh.export_PrecisionVertex);
    assertEquals(5, fresh.export_PrecisionVtexture);
    assertEquals(0, fresh.export_PolyToPoly);
    assertFalse(fresh.export_MaterialLibrary);
    assertFalse(fresh.export_BackSides);
    assertEquals(128, fresh.export_PaletteResolution);
  }
}
