class User3D {

  final static String CLASS_STAMP = "User3D";

  int creatorMaterial = 7; //0;
  int creatorTessellation = 0;
  int creatorLayer = 0;
  int creatorVisibility = 1; // 1: view 0: hide -1:freeze
  int creatorWeight = 0;
  int creatorClosed = 0;

  float creatorLength = 10;
  float creatorWidth = 10;
  float creatorHeight = 10;
  float creatorVolume = 0; //3000;
  float creatorOrientation = 0; // 360: viewport angle
  float creatorSuperellipsoidPowerX = CubePower;
  float creatorSuperellipsoidPowerY = CubePower;
  float creatorSuperellipsoidPowerZ = CubePower;
  float creatorUniformSuperellipsoidPower = 8;
  int creatorRandomSuperellipsoidPower = 0;
  int creatorSphereDegree = 4;
  int creatorCylinderDegree = 24;
  int creatorConeDegree = 24;
  int creatorPolygonDegree = 6;
  int creatorParametricTypeIndex = 1;
  int creatorPersonTypeIndex = 0;
  int creatorPlantTypeIndex = 0;

  int creatorModel1DTypeIndex = 0;
  int creatorModel1DDegreeMax = 8;
  int creatorModel1DSeed = -1; // -1:random, 0-99 choice
  float creatorModel1DTrunkSize = 1;
  float creatorModel1DLeafSize = 0.2;

  float creatorModel1DBranchTilt = 60.0;
  float creatorModel1DBranchTwist = 137.5; //golden angle ratio
  float creatorModel1DBranchRatio = 0.8;
  float creatorModel1DTreeBase = 2.0;





  int creatorMeshOrSolidMode = 0; // 0:Mesh 1:Solid
  int creatorSnapModeIndex = 0;

  int modifierTessellateRows = 3;
  int modifierTessellateColumns = 2;
  float modifierOpeningDepth = 1; // 1 = 1m
  float modifierOpeningArea = 0.25; //0-1, 0.25: 25% of the face area (i.e. for parallel openings)
  float modifierOpeningDeviation = 0.5; //0-1, 0.5: middle of the face edge (could be applied in rotated openning)
  float modifierOffsetAmount = 1.0; // 1 = 1m
  float modifierWeldThreshold = 0.1;

  float exporterScale = 1.0; //0.001; // 0.001: 1km --> 1
  int exporterYaxisUp = 1; //1; // 1: to fit in Unity3D

  int exporterPrecisionVertex = 6;
  int exporterPrecisionVertexTexture = 4;
  int exporterMaintainPolygons = 1; // 0: Exports each group3D to different individual faces, 1: Exports group3D to group3D

  boolean exporterMaterialLibrary = true;
  boolean exporterDoubleSided = true;
  int exporterColorscaleResolution = 256;

  public void to_XML (XML xml) {

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "creatorMaterial", this.creatorMaterial);
    XML_setInt(parent, "creatorTessellation", this.creatorTessellation);
    XML_setInt(parent, "creatorLayer", this.creatorLayer);
    XML_setInt(parent, "creatorVisibility", this.creatorVisibility);
    XML_setInt(parent, "creatorWeight", this.creatorWeight);
    XML_setInt(parent, "creatorClosed", this.creatorClosed);

    XML_setFloat(parent, "creatorLength", this.creatorLength);
    XML_setFloat(parent, "creatorWidth", this.creatorWidth);
    XML_setFloat(parent, "creatorHeight", this.creatorHeight);
    XML_setFloat(parent, "creatorVolume", this.creatorVolume);
    XML_setFloat(parent, "creatorOrientation", this.creatorOrientation);
    XML_setFloat(parent, "creatorSuperellipsoidPowerX", this.creatorSuperellipsoidPowerX);
    XML_setFloat(parent, "creatorSuperellipsoidPowerY", this.creatorSuperellipsoidPowerY);
    XML_setFloat(parent, "creatorSuperellipsoidPowerZ", this.creatorSuperellipsoidPowerZ);
    XML_setFloat(parent, "creatorUniformSuperellipsoidPower", this.creatorUniformSuperellipsoidPower);
    XML_setInt(parent, "creatorRandomSuperellipsoidPower", this.creatorRandomSuperellipsoidPower);
    XML_setInt(parent, "creatorSphereDegree", this.creatorSphereDegree);
    XML_setInt(parent, "creatorCylinderDegree", this.creatorCylinderDegree);
    XML_setInt(parent, "creatorConeDegree", this.creatorConeDegree);
    XML_setInt(parent, "creatorPolygonDegree", this.creatorPolygonDegree);
    XML_setInt(parent, "creatorParametricTypeIndex", this.creatorParametricTypeIndex);
    XML_setInt(parent, "creatorPersonTypeIndex", this.creatorPersonTypeIndex);
    XML_setInt(parent, "creatorPlantTypeIndex", this.creatorPlantTypeIndex);

    XML_setInt(parent, "creatorModel1DTypeIndex", this.creatorModel1DTypeIndex);
    XML_setInt(parent, "creatorModel1DDegreeMax", this.creatorModel1DDegreeMax);
    XML_setInt(parent, "creatorModel1DSeed", this.creatorModel1DSeed);
    XML_setFloat(parent, "creatorModel1DTrunkSize", this.creatorModel1DTrunkSize);
    XML_setFloat(parent, "creatorModel1DLeafSize", this.creatorModel1DLeafSize);

    XML_setInt(parent, "creatorMeshOrSolidMode", this.creatorMeshOrSolidMode);
    XML_setInt(parent, "creatorSnapModeIndex", this.creatorSnapModeIndex);

    XML_setInt(parent, "modifierTessellateRows", this.modifierTessellateRows);
    XML_setInt(parent, "modifierTessellateColumns", this.modifierTessellateColumns);
    XML_setFloat(parent, "modifierOpeningDepth", this.modifierOpeningDepth);
    XML_setFloat(parent, "modifierOpeningArea", this.modifierOpeningArea);
    XML_setFloat(parent, "modifierOpeningDeviation", this.modifierOpeningDeviation);
    XML_setFloat(parent, "modifierWeldThreshold", this.modifierWeldThreshold);
    XML_setFloat(parent, "modifierOffsetAmount", this.modifierOffsetAmount);

    XML_setFloat(parent, "exporterScale", this.exporterScale);
    XML_setInt(parent, "exporterYaxisUp", this.exporterYaxisUp);
    XML_setInt(parent, "exporterPrecisionVertex", this.exporterPrecisionVertex);
    XML_setInt(parent, "exporterPrecisionVertexTexture", this.exporterPrecisionVertexTexture);
    XML_setInt(parent, "exporterMaintainPolygons", this.exporterMaintainPolygons);
    XML_setBoolean(parent, "exporterMaterialLibrary", this.exporterMaterialLibrary);
    XML_setBoolean(parent, "exporterDoubleSided", this.exporterDoubleSided);
    XML_setInt(parent, "exporterColorscaleResolution", this.exporterColorscaleResolution);

  }


  public void from_XML (XML xml) {

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.creatorMaterial = XML_getInt(parent, "creatorMaterial");
    this.creatorTessellation = XML_getInt(parent, "creatorTessellation");
    this.creatorLayer = XML_getInt(parent, "creatorLayer");
    this.creatorVisibility = XML_getInt(parent, "creatorVisibility");
    this.creatorWeight = XML_getInt(parent, "creatorWeight");
    this.creatorClosed = XML_getInt(parent, "creatorClosed");

    this.creatorLength = XML_getFloat(parent, "creatorLength");
    this.creatorWidth = XML_getFloat(parent, "creatorWidth");
    this.creatorHeight = XML_getFloat(parent, "creatorHeight");
    this.creatorVolume = XML_getFloat(parent, "creatorVolume");
    this.creatorOrientation = XML_getFloat(parent, "creatorOrientation");

    this.creatorSuperellipsoidPowerX = XML_getFloat(parent, "creatorSuperellipsoidPowerX");
    this.creatorSuperellipsoidPowerY = XML_getFloat(parent, "creatorSuperellipsoidPowerY");
    this.creatorSuperellipsoidPowerZ = XML_getFloat(parent, "creatorSuperellipsoidPowerZ");
    this.creatorUniformSuperellipsoidPower = XML_getFloat(parent, "creatorUniformSuperellipsoidPower");
    this.creatorRandomSuperellipsoidPower = XML_getInt(parent, "creatorRandomSuperellipsoidPower");

    this.creatorSphereDegree = XML_getInt(parent, "creatorSphereDegree");
    this.creatorCylinderDegree = XML_getInt(parent, "creatorCylinderDegree");
    this.creatorConeDegree = XML_getInt(parent, "creatorConeDegree");
    this.creatorPolygonDegree = XML_getInt(parent, "creatorPolygonDegree");

    this.creatorParametricTypeIndex = XML_getInt(parent, "creatorParametricTypeIndex");
    this.creatorPersonTypeIndex = XML_getInt(parent, "creatorPersonTypeIndex");
    this.creatorPlantTypeIndex = XML_getInt(parent, "creatorPlantTypeIndex");

    this.creatorModel1DTypeIndex = XML_getInt(parent, "creatorModel1DTypeIndex");
    this.creatorModel1DDegreeMax = XML_getInt(parent, "creatorModel1DDegreeMax");
    this.creatorModel1DSeed = XML_getInt(parent, "creatorModel1DSeed");
    this.creatorModel1DTrunkSize = XML_getFloat(parent, "creatorModel1DTrunkSize");
    this.creatorModel1DLeafSize = XML_getFloat(parent, "creatorModel1DLeafSize");

    this.creatorMeshOrSolidMode = XML_getInt(parent, "creatorMeshOrSolidMode");
    this.creatorSnapModeIndex = XML_getInt(parent, "creatorSnapModeIndex");

    this.modifierTessellateRows = XML_getInt(parent, "modifierTessellateRows");
    this.modifierTessellateColumns = XML_getInt(parent, "modifierTessellateColumns");
    this.modifierOpeningDepth = XML_getFloat(parent, "modifierOpeningDepth");
    this.modifierOpeningArea = XML_getFloat(parent, "modifierOpeningArea");
    this.modifierOpeningDeviation = XML_getFloat(parent, "modifierOpeningDeviation");
    this.modifierWeldThreshold = XML_getFloat(parent, "modifierWeldThreshold");
    this.modifierOffsetAmount = XML_getFloat(parent, "modifierOffsetAmount");

    this.exporterScale = XML_getFloat(parent, "exporterScale");
    this.exporterYaxisUp = XML_getInt(parent, "exporterYaxisUp");
    this.exporterPrecisionVertex = XML_getInt(parent, "exporterPrecisionVertex");
    this.exporterPrecisionVertexTexture = XML_getInt(parent, "exporterPrecisionVertexTexture");
    this.exporterMaintainPolygons = XML_getInt(parent, "exporterMaintainPolygons");
    this.exporterMaterialLibrary  = XML_getBoolean(parent, "exporterMaterialLibrary");
    this.exporterDoubleSided = XML_getBoolean(parent, "exporterDoubleSided");
    this.exporterColorscaleResolution = XML_getInt(parent, "exporterColorscaleResolution");

  }


}
