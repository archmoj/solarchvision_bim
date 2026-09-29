class STATION {

  final static String CLASS_STAMP = "STATION";

  float elevation = 0;
  float latitude = 0;
  float longitude = 0;
  float timezoneLongitude = 0;
  String code = "";
  String city = "";
  String province = "";
  String country = "";
  String ensembleObservationFilename = "";
  String ensembleForecastFilename = "";
  String climateEngineeringFilename = "";
  String climateTypicalYearFilename = "";
  String climateTypicalYearDownload = "";


  public float getElevation () { return this.elevation; }
  public float getLatitude () { return this.latitude; }
  public float getLongitude () { return this.longitude; }
  public float getTimezoneLongitude () { return this.timezoneLongitude; }
  public String getCode () { return this.code; }
  public String getCity () { return this.city; }
  public String getProvince () { return this.province; }
  public String getCountry () { return this.country; }
  public String getEnsembleObservationFilename () { return this.ensembleObservationFilename; }
  public String getEnsembleForecastFilename () { return this.ensembleForecastFilename; }
  public String getClimateEngineeringFilename () { return this.climateEngineeringFilename; }
  public String getClimateTypicalYearFilename () { return this.climateTypicalYearFilename; }
  public String getClimateTypicalYearDownload () { return this.climateTypicalYearDownload; }


  public void setElevation (float elevation) {
    this.elevation = elevation;
  }
  public void setLatitude (float latitude) {
    this.latitude = latitude;
  }
  public void setLongitude (float longitude) {
    this.longitude = longitude;
  }
  public void setTimezoneLongitude (float timezoneLongitude) {
    this.timezoneLongitude = timezoneLongitude;
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
  public void setEnsembleObservationFilename (String ensembleObservationFilename) {
    this.ensembleObservationFilename = ensembleObservationFilename;
  }
  public void setEnsembleForecastFilename (String ensembleForecastFilename) {
    this.ensembleForecastFilename = ensembleForecastFilename;
  }
  public void setClimateEngineeringFilename (String climateEngineeringFilename) {
    this.climateEngineeringFilename = climateEngineeringFilename;
  }
  public void setClimateTypicalYearFilename (String climateTypicalYearFilename) {
    this.climateTypicalYearFilename = climateTypicalYearFilename;
  }
  public void setClimateTypicalYearDownload (String climateTypicalYearDownload) {
    this.climateTypicalYearDownload = climateTypicalYearDownload;
  }

  public STATION () {

  }

  public STATION (String code, String city, String province, String country,
                         float latitude, float longitude, float timezoneLongitude, float elevation,
                         String climateTypicalYearDownload, String climateTypicalYearFilename,
                         String climateEngineeringFilename, String ensembleForecastFilename, String ensembleObservationFilename) {

    this.code = code;
    this.city = city;
    this.province = province;
    this.country = country;

    this.ensembleObservationFilename = ensembleObservationFilename;
    this.ensembleForecastFilename = ensembleForecastFilename;
    this.climateEngineeringFilename = climateEngineeringFilename;
    this.climateTypicalYearFilename = climateTypicalYearFilename;
    this.climateTypicalYearDownload = climateTypicalYearDownload;

    this.elevation = elevation;
    this.latitude = latitude;
    this.longitude = longitude;
    this.timezoneLongitude = timezoneLongitude;
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
    XML_setFloat(child, "timezoneLongitude", this.getTimezoneLongitude());

    XML_setString(child, "ensembleForecastFilename", this.getEnsembleForecastFilename());
    XML_setString(child, "climateEngineeringFilename", this.getClimateEngineeringFilename());
    XML_setString(child, "climateTypicalYearFilename", this.getClimateTypicalYearFilename());
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
    this.setTimezoneLongitude(XML_getFloat(child, "timezoneLongitude"));

    this.setEnsembleForecastFilename(XML_getString(child, "ensembleForecastFilename"));
    this.setClimateEngineeringFilename(XML_getString(child, "climateEngineeringFilename"));
    this.setClimateTypicalYearFilename(XML_getString(child, "climateTypicalYearFilename"));
  }
}
