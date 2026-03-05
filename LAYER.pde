class solarchvision_LAYER {

  private final static String CLASS_STAMP = "LAYER";

  public int id;

  public String unit = "";
  public String name = "";
  public String[] descriptions = new String [numberOfLanguages];

  public float V_scale = 1;
  public float V_offset = 0;
  public float V_belowLine = 0;

  solarchvision_LAYER (float V_scale, float V_offset, float V_belowLine, String unit, String description_EN, String description_FR, String name) {

    this.V_scale = V_scale;
    this.V_offset = V_offset;
    this.V_belowLine = V_belowLine;
    this.unit = unit;
    this.name = name;
    this.descriptions[Language_EN] = description_EN;
    this.descriptions[Language_FR] = description_FR;

    this.id = numberOfLayers;
    numberOfLayers++;
  }

  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP + "_" + nf(this.id, 0));

    XML parent = xml.addChild(this.CLASS_STAMP + "_" + nf(this.id, 0));

    XML_setInt(parent, "id", this.id);

    XML_setString(parent, "unit", this.unit);
    XML_setString(parent, "name", this.name);
    XML_setString(parent, "description_EN", this.descriptions[Language_EN]);
    XML_setString(parent, "description_FR", this.descriptions[Language_FR]);

    XML_setFloat(parent, "V_scale", this.V_scale);
    XML_setFloat(parent, "V_offset", this.V_offset);
    XML_setFloat(parent, "V_belowLine", this.V_belowLine);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP + "_" + nf(this.id, 0));

    XML parent = xml.getChild(this.CLASS_STAMP + "_" + nf(this.id, 0));

    this.id = XML_getInt(parent, "id");

    this.unit = XML_getString(parent, "unit");
    this.name = XML_getString(parent, "name");
    this.descriptions[Language_EN] = XML_getString(parent, "description_EN");
    this.descriptions[Language_FR] = XML_getString(parent, "description_FR");

    this.V_scale = XML_getFloat(parent, "V_scale");
    this.V_offset = XML_getFloat(parent, "V_offset");
    this.V_belowLine = XML_getFloat(parent, "V_belowLine");
  }


}
