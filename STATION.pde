class solarchvision_STATION {

  private final static String CLASS_STAMP = "STATION";

  private float elevation = 0;
  private float latitude = 0;
  private float longitude = 0;
  private float timelong = 0;
  private String code = "";
  private String city = "";
  private String province = "";
  private String country = "";
  private String filename_NAEFS = "";
  private String filename_CWEEDS = "";
  private String filename_TMYEPW = "";


  public float getElevation () { return this.elevation; }
  public float getLatitude () { return this.latitude; }
  public float getLongitude () { return this.longitude; }
  public float getTimelong () { return this.timelong; }
  public String getCode () { return this.code; }
  public String getCity () { return this.city; }
  public String getProvince () { return this.province; }
  public String getCountry () { return this.country; }
  public String getFilename_NAEFS () { return this.filename_NAEFS; }
  public String getFilename_CWEEDS () { return this.filename_CWEEDS; }
  public String getFilename_TMYEPW () { return this.filename_TMYEPW; }


  public void setElevation (float elevation) {
    this.elevation = elevation;
  }
  public void setLatitude (float latitude) {
    this.latitude = latitude;
  }
  public void setLongitude (float longitude) {
    this.longitude = longitude;
  }
  public void setTimelong (float timelong) {
    this.timelong = timelong;
  }
  public void setCode (String code) {
    this.code = code;
  }
  public void setCity (String city) {
    this.city = city;
  }
  public void setProvince (String province) {
    this.province = province;
  }
  public void setCountry (String country) {
    this.country = country;
  }
  public void setFilename_NAEFS (String filename_NAEFS) {
    this.filename_NAEFS = filename_NAEFS;
  }
  public void setFilename_CWEEDS (String filename_CWEEDS) {
    this.filename_CWEEDS = filename_CWEEDS;
  }
  public void setFilename_TMYEPW (String filename_TMYEPW) {
    this.filename_TMYEPW = filename_TMYEPW;
  }

  public solarchvision_STATION () {

  }

  public solarchvision_STATION (String code, String city, String province, String country,
                         float latitude, float longitude, float timelong, float elevation,
                         String filename_NAEFS, String filename_CWEEDS, String filename_TMYEPW) {

    this.code = code;
    this.city = city;
    this.province = province;
    this.country = country;

    this.filename_NAEFS = filename_NAEFS;
    this.filename_CWEEDS = filename_CWEEDS;
    this.filename_TMYEPW = filename_TMYEPW;

    this.elevation = elevation;
    this.latitude = latitude;
    this.longitude = longitude;
    this.timelong = timelong;
  }


  public void to_XML (XML xml) {

    XML child = xml.addChild(this.CLASS_STAMP);

    XML_setString(child, "code", this.getCode());
    XML_setString(child, "city", this.getCity());
    XML_setString(child, "province", this.getProvince());
    XML_setString(child, "country", this.getCountry());

    XML_setFloat(child, "elevation", this.getElevation());
    XML_setFloat(child, "latitude", this.getLatitude());
    XML_setFloat(child, "longitude", this.getLongitude());
    XML_setFloat(child, "timelong", this.getTimelong());

    XML_setString(child, "filename_NAEFS", this.getFilename_NAEFS());
    XML_setString(child, "filename_CWEEDS", this.getFilename_CWEEDS());
    XML_setString(child, "filename_TMYEPW", this.getFilename_TMYEPW());
  }


  public void from_XML (XML xml) {

    XML child = xml.getChild(this.CLASS_STAMP);

    this.setCode(XML_getString(child, "code"));
    this.setCity(XML_getString(child, "city"));
    this.setProvince(XML_getString(child, "province"));
    this.setCountry(XML_getString(child, "country"));

    this.setElevation(XML_getFloat(child, "elevation"));
    this.setLatitude(XML_getFloat(child, "latitude"));
    this.setLongitude(XML_getFloat(child, "longitude"));
    this.setTimelong(XML_getFloat(child, "timelong"));

    this.setFilename_NAEFS(XML_getString(child, "filename_NAEFS"));
    this.setFilename_CWEEDS(XML_getString(child, "filename_CWEEDS"));
    this.setFilename_TMYEPW(XML_getString(child, "filename_TMYEPW"));
  }
}
