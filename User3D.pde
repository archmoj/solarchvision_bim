class solarchvision_User3D {

  private final static String CLASS_STAMP = "User3D";

  int default_Material = 7; //0;
  int default_Tessellation = 0;
  int default_Layer = 0;
  int default_Visibility = 1; // 1: view 0: hide -1:freeze
  int default_Weight = 0;
  int default_Closed = 0;

  float create_Length = 10;
  float create_Width = 10;
  float create_Height = 10;
  float create_Volume = 0; //3000;
  float create_Orientation = 0; // 360: viewport angle
  float create_powX = CubePower;
  float create_powY = CubePower;
  float create_powZ = CubePower;
  float create_powAll = 8;
  int create_powRnd = 0;
  int create_SphereDegree = 4;
  int create_CylinderDegree = 24;
  int create_PolyDegree = 6;
  int create_Parametric_Type = 1;
  int create_Person_Type = 0;
  int create_Plant_Type = 0;

  int create_Model1D_Type = 0;
  int create_Model1D_DegreeMax = 8;
  int create_Model1D_Seed = -1; // -1:random, 0-99 choice
  float create_Model1D_TrunkSize = 1;
  float create_Model1D_LeafSize = 0.2;

  float create_Model1D_BranchTilt = 60.0;
  float create_Model1D_BranchTwist = 137.5; //golden angle ratio
  float create_Model1D_BranchRatio = 0.8;
  float create_Model1D_TreeBase = 2.0;





  int create_MeshOrSolid = 0; // 0:Mesh 1:Solid
  int create_Snap = 0;

  int modify_TessellateRows = 6;
  int modify_TessellateColumns = 30;
  float modify_OpenningDepth = 1; // 1 = 1m
  float modify_OpenningArea = 0.25; //0-1, 0.25: 25% of the face area (i.e. for parallel openings)
  float modify_OpenningDeviation = 0.5; //0-1, 0.5: middle of the face edge (could be applied in rotated openning)
  float modify_OffsetAmount = 1.0; // 1 = 1m
  float modify_WeldTreshold = 0.1;

  float export_Scale = 1.0; //0.001; // 0.001: 1km --> 1
  int export_FlipZYaxis = 1; //1; // 1: to fit in Unity3D

  int export_PrecisionVertex = 6;
  int export_PrecisionVtexture = 4;
  int export_PolyToPoly = 1; // 0: Exports each group3D to different individual faces, 1: Exports group3D to group3D

  boolean export_MaterialLibrary = true;
  boolean export_BackSides = true;
  int export_PalletResolution = 256;

  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "default_Material", this.default_Material);
    XML_setInt(parent, "default_Tessellation", this.default_Tessellation);
    XML_setInt(parent, "default_Layer", this.default_Layer);
    XML_setInt(parent, "default_Visibility", this.default_Visibility);
    XML_setInt(parent, "default_Weight", this.default_Weight);
    XML_setInt(parent, "default_Closed", this.default_Closed);

    XML_setFloat(parent, "create_Length", this.create_Length);
    XML_setFloat(parent, "create_Width", this.create_Width);
    XML_setFloat(parent, "create_Height", this.create_Height);
    XML_setFloat(parent, "create_Volume", this.create_Volume);
    XML_setFloat(parent, "create_Orientation", this.create_Orientation);
    XML_setFloat(parent, "create_powX", this.create_powX);
    XML_setFloat(parent, "create_powY", this.create_powY);
    XML_setFloat(parent, "create_powZ", this.create_powZ);
    XML_setFloat(parent, "create_powAll", this.create_powAll);
    XML_setInt(parent, "create_powRnd", this.create_powRnd);
    XML_setInt(parent, "create_SphereDegree", this.create_SphereDegree);
    XML_setInt(parent, "create_CylinderDegree", this.create_CylinderDegree);
    XML_setInt(parent, "create_PolyDegree", this.create_PolyDegree);
    XML_setInt(parent, "create_Parametric_Type", this.create_Parametric_Type);
    XML_setInt(parent, "create_Person_Type", this.create_Person_Type);
    XML_setInt(parent, "create_Plant_Type", this.create_Plant_Type);

    XML_setInt(parent, "create_Model1D_Type", this.create_Model1D_Type);
    XML_setInt(parent, "create_Model1D_DegreeMax", this.create_Model1D_DegreeMax);
    XML_setInt(parent, "create_Model1D_Seed", this.create_Model1D_Seed);
    XML_setFloat(parent, "create_Model1D_TrunkSize", this.create_Model1D_TrunkSize);
    XML_setFloat(parent, "create_Model1D_LeafSize", this.create_Model1D_LeafSize);

    XML_setInt(parent, "create_Model1D_Type", this.create_Model1D_Type);
    XML_setInt(parent, "create_Model1D_DegreeMax", this.create_Model1D_DegreeMax);
    XML_setInt(parent, "create_Model1D_Seed", this.create_Model1D_Seed);
    XML_setFloat(parent, "create_Model1D_TrunkSize", this.create_Model1D_TrunkSize);
    XML_setFloat(parent, "create_Model1D_LeafSize", this.create_Model1D_LeafSize);

    XML_setInt(parent, "create_MeshOrSolid", this.create_MeshOrSolid);
    XML_setInt(parent, "create_Snap", this.create_Snap);

    XML_setInt(parent, "modify_TessellateRows", this.modify_TessellateRows);
    XML_setInt(parent, "modify_TessellateColumns", this.modify_TessellateColumns);
    XML_setFloat(parent, "modify_OpenningDepth", this.modify_OpenningDepth);
    XML_setFloat(parent, "modify_OpenningArea", this.modify_OpenningArea);
    XML_setFloat(parent, "modify_OpenningDeviation", this.modify_OpenningDeviation);
    XML_setFloat(parent, "modify_WeldTreshold", this.modify_WeldTreshold);
    XML_setFloat(parent, "modify_OffsetAmount", this.modify_OffsetAmount);

    XML_setFloat(parent, "export_Scale", this.export_Scale);
    XML_setInt(parent, "export_FlipZYaxis", this.export_FlipZYaxis);
    XML_setInt(parent, "export_PrecisionVertex", this.export_PrecisionVertex);
    XML_setInt(parent, "export_PrecisionVtexture", this.export_PrecisionVtexture);
    XML_setInt(parent, "export_PolyToPoly", this.export_PolyToPoly);
    XML_setBoolean(parent, "export_MaterialLibrary", this.export_MaterialLibrary);
    XML_setBoolean(parent, "export_BackSides", this.export_BackSides);
    XML_setInt(parent, "export_PalletResolution", this.export_PalletResolution);

  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.default_Material = XML_getInt(parent, "default_Material");
    this.default_Tessellation = XML_getInt(parent, "default_Tessellation");
    this.default_Layer = XML_getInt(parent, "default_Layer");
    this.default_Visibility = XML_getInt(parent, "default_Visibility");
    this.default_Weight = XML_getInt(parent, "default_Weight");
    this.default_Closed = XML_getInt(parent, "default_Closed");

    this.create_Length = XML_getFloat(parent, "create_Length");
    this.create_Width = XML_getFloat(parent, "create_Width");
    this.create_Height = XML_getFloat(parent, "create_Height");
    this.create_Volume = XML_getFloat(parent, "create_Volume");
    this.create_Orientation = XML_getFloat(parent, "create_Orientation");
    this.create_powX = XML_getFloat(parent, "create_powX");
    this.create_powY = XML_getFloat(parent, "create_powY");
    this.create_powZ = XML_getFloat(parent, "create_powZ");
    this.create_powAll = XML_getFloat(parent, "create_powAll");
    this.create_powRnd = XML_getInt(parent, "create_powRnd");
    this.create_SphereDegree = XML_getInt(parent, "create_SphereDegree");
    this.create_CylinderDegree = XML_getInt(parent, "create_CylinderDegree");
    this.create_PolyDegree = XML_getInt(parent, "create_PolyDegree");
    this.create_Parametric_Type = XML_getInt(parent, "create_Parametric_Type");
    this.create_Person_Type = XML_getInt(parent, "create_Person_Type");
    this.create_Plant_Type = XML_getInt(parent, "create_Plant_Type");

    this.create_Model1D_Type = XML_getInt(parent, "create_Model1D_Type");
    this.create_Model1D_DegreeMax = XML_getInt(parent, "create_Model1D_DegreeMax");
    this.create_Model1D_Seed = XML_getInt(parent, "create_Model1D_Seed");
    this.create_Model1D_TrunkSize = XML_getFloat(parent, "create_Model1D_TrunkSize");
    this.create_Model1D_LeafSize = XML_getFloat(parent, "create_Model1D_LeafSize");

    this.create_Model1D_Type = XML_getInt(parent, "create_Model1D_Type");
    this.create_Model1D_DegreeMax = XML_getInt(parent, "create_Model1D_DegreeMax");
    this.create_Model1D_Seed = XML_getInt(parent, "create_Model1D_Seed");
    this.create_Model1D_TrunkSize = XML_getFloat(parent, "create_Model1D_TrunkSize");
    this.create_Model1D_LeafSize = XML_getFloat(parent, "create_Model1D_LeafSize");

    this.create_MeshOrSolid = XML_getInt(parent, "create_MeshOrSolid");
    this.create_Snap = XML_getInt(parent, "create_Snap");

    this.modify_TessellateRows = XML_getInt(parent, "modify_TessellateRows");
    this.modify_TessellateColumns = XML_getInt(parent, "modify_TessellateColumns");
    this.modify_OpenningDepth = XML_getFloat(parent, "modify_OpenningDepth");
    this.modify_OpenningArea = XML_getFloat(parent, "modify_OpenningArea");
    this.modify_OpenningDeviation = XML_getFloat(parent, "modify_OpenningDeviation");
    this.modify_WeldTreshold = XML_getFloat(parent, "modify_WeldTreshold");
    this.modify_OffsetAmount = XML_getFloat(parent, "modify_OffsetAmount");

    this.export_Scale = XML_getFloat(parent, "export_Scale");
    this.export_FlipZYaxis = XML_getInt(parent, "export_FlipZYaxis");
    this.export_PrecisionVertex = XML_getInt(parent, "export_PrecisionVertex");
    this.export_PrecisionVtexture = XML_getInt(parent, "export_PrecisionVtexture");
    this.export_PolyToPoly = XML_getInt(parent, "export_PolyToPoly");
    this.export_MaterialLibrary  = XML_getBoolean(parent, "export_MaterialLibrary");
    this.export_BackSides = XML_getBoolean(parent, "export_BackSides");
    this.export_PalletResolution = XML_getInt(parent, "export_PalletResolution");

  }


}
