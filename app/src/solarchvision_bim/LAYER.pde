int _numberOfLayers = 0;

class LAYER {

  final static String CLASS_STAMP = "LAYER";

  public int id;

  public String unit = "";
  public String name = "";
  public String[] descriptions = new String [numberOfLanguages];

  public float verticalUnitScale = 1;
  public float verticalUnitOffset = 0;
  public float verticalNegativePadding = 0;

  LAYER (float verticalUnitScale, float verticalUnitOffset, float verticalNegativePadding, String unit, String description_EN, String description_FR, String name) {

    this.verticalUnitScale = verticalUnitScale;
    this.verticalUnitOffset = verticalUnitOffset;
    this.verticalNegativePadding = verticalNegativePadding;
    this.unit = unit;
    this.name = name;
    this.descriptions[Language_EN] = description_EN;
    this.descriptions[Language_FR] = description_FR;

    this.id = _numberOfLayers;
    _numberOfLayers++;
  }

  public void to_XML (XML xml) {

    XML parent = xml.addChild(this.CLASS_STAMP + "_" + nf(this.id, 0));

    XML_setInt(parent, "id", this.id);

    XML_setString(parent, "unit", this.unit);
    XML_setString(parent, "name", this.name);
    XML_setString(parent, "description_EN", this.descriptions[Language_EN]);
    XML_setString(parent, "description_FR", this.descriptions[Language_FR]);

    XML_setFloat(parent, "verticalUnitScale", this.verticalUnitScale);
    XML_setFloat(parent, "verticalUnitOffset", this.verticalUnitOffset);
    XML_setFloat(parent, "verticalNegativePadding", this.verticalNegativePadding);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP + "_" + nf(this.id, 0));

    XML parent = xml.getChild(this.CLASS_STAMP + "_" + nf(this.id, 0));

    this.id = XML_getInt(parent, "id");

    this.unit = XML_getString(parent, "unit");
    this.name = XML_getString(parent, "name");
    this.descriptions[Language_EN] = XML_getString(parent, "description_EN");
    this.descriptions[Language_FR] = XML_getString(parent, "description_FR");

    this.verticalUnitScale = XML_getFloat(parent, "verticalUnitScale");
    this.verticalUnitOffset = XML_getFloat(parent, "verticalUnitOffset");
    this.verticalNegativePadding = XML_getFloat(parent, "verticalNegativePadding");
  }


}
