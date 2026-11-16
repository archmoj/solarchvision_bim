int _numberOfLayers = 0;

class LAYER {

  final static String CLASS_STAMP = "layer";

  public int id;

  public String unit = "";
  public String name = "";
  public String[] descriptions = new String [numberOfLanguages];

  public float verticalUnitScale = 1;
  public float verticalUnitOffset = 0;
  public float verticalNegativePadding = 0;

  LAYER (float verticalUnitScale, float verticalUnitOffset, float verticalNegativePadding, String unit, String descriptionEn, String descriptionFr, String name) {

    this.verticalUnitScale = verticalUnitScale;
    this.verticalUnitOffset = verticalUnitOffset;
    this.verticalNegativePadding = verticalNegativePadding;
    this.unit = unit;
    this.name = name;
    this.descriptions[Language_EN] = descriptionEn;
    this.descriptions[Language_FR] = descriptionFr;

    this.id = _numberOfLayers;
    _numberOfLayers++;
  }

  // Every other array-of-many class (Solids, Sections, Points, Faces,
  // Cameras, Polylines, Model1Ds, Model2Ds) serializes as one wrapper
  // element carrying a declared "ni" count plus N generic
  // <item id="i"> children - a file can say how many of itself it
  // holds without the reader already knowing. LAYER used to be the
  // lone exception, baking its own array index straight into a unique
  // top-level element name (<layer0>, <layer1>, ...) with no wrapper
  // and no declared count, so only code that already knew
  // allLayers.length could find them all. Each LAYER instance still
  // serializes itself (there's no single "Layers" container class the
  // way Solids/Sections have one), but now shares one <layer> wrapper
  // across every call - created on the first instance's to_XML() and
  // reused by the rest - and appends itself as a generic <item>,
  // matching everyone else's on-disk shape. Callers
  // (saveProject.pde/parseXmlVariables.pde) are unchanged: each still
  // just calls allLayers[i].to_XML(xml)/from_XML(xml) once per layer.
  public void to_XML (XML xml) {

    XML parent = xml.getChild(this.CLASS_STAMP);
    if (parent == null) parent = xml.addChild(this.CLASS_STAMP);
    XML_setInt(parent, "ni", allLayers.length);

    XML child = parent.addChild("item");

    XML_setInt(child, "id", this.id);

    XML_setString(child, "unit", this.unit);
    XML_setString(child, "name", this.name);
    XML_setString(child, "descriptionEn", this.descriptions[Language_EN]);
    XML_setString(child, "descriptionFr", this.descriptions[Language_FR]);

    XML_setFloat(child, "verticalUnitScale", this.verticalUnitScale);
    XML_setFloat(child, "verticalUnitOffset", this.verticalUnitOffset);
    XML_setFloat(child, "verticalNegativePadding", this.verticalNegativePadding);
  }


  public void from_XML (XML xml) {

    //println("\nLoading:" + this.CLASS_STAMP + " id=" + nf(this.id, 0));

    XML parent = xml.getChild(this.CLASS_STAMP);

    XML child = null;
    if (parent != null) {
      XML[] items = parent.getChildren("item");
      for (int k = 0; k < items.length; k++) {
        if (XML_getInt(items[k], "id") == this.id) {
          child = items[k];
          break;
        }
      }
    }

    this.id = XML_getInt(child, "id");

    this.unit = XML_getString(child, "unit");
    this.name = XML_getString(child, "name");
    this.descriptions[Language_EN] = XML_getString(child, "descriptionEn");
    this.descriptions[Language_FR] = XML_getString(child, "descriptionFr");

    this.verticalUnitScale = XML_getFloat(child, "verticalUnitScale");
    this.verticalUnitOffset = XML_getFloat(child, "verticalUnitOffset");
    this.verticalNegativePadding = XML_getFloat(child, "verticalNegativePadding");
  }


}
