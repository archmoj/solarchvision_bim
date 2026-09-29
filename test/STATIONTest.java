import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class STATIONTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= getters / setters ====================================

  @Test
  void settersAndGetters_roundTripEachNumericField () {
    solarchvision_bim.STATION s = app.new STATION();

    s.setElevation(120.5f);
    s.setLatitude(45.5f);
    s.setLongitude(-73.5f);
    s.setTimezoneLongitude(-5f);

    assertEquals(120.5f, s.getElevation(), 0.0001f);
    assertEquals(45.5f, s.getLatitude(), 0.0001f);
    assertEquals(-73.5f, s.getLongitude(), 0.0001f);
    assertEquals(-5f, s.getTimezoneLongitude(), 0.0001f);
  }

  @Test
  void settersAndGetters_roundTripEachStringField () {
    solarchvision_bim.STATION s = app.new STATION();

    s.setCode("YUL");
    s.setCity("Montreal");
    s.setProvince("QC");
    s.setCountry("Canada");

    assertEquals("YUL", s.getCode());
    assertEquals("Montreal", s.getCity());
    assertEquals("QC", s.getProvince());
    assertEquals("Canada", s.getCountry());
  }

  @Test
  void settersAndGetters_roundTripEachFilenameField () {
    // setEnsembleObservationFilename previously assigned ensembleForecastFilename instead of its own
    // parameter (a copy-paste bug) - fixed in STATION.pde alongside this test.
    solarchvision_bim.STATION s = app.new STATION();

    s.setEnsembleObservationFilename("swob.csv");
    s.setEnsembleForecastFilename("naefs.csv");
    s.setClimateEngineeringFilename("cweeds.csv");
    s.setClimateTypicalYearFilename("tmyepw.csv");
    s.setClimateTypicalYearDownload("http://example.com/tmyepw.zip");

    assertEquals("swob.csv", s.getEnsembleObservationFilename());
    assertEquals("naefs.csv", s.getEnsembleForecastFilename());
    assertEquals("cweeds.csv", s.getClimateEngineeringFilename());
    assertEquals("tmyepw.csv", s.getClimateTypicalYearFilename());
    assertEquals("http://example.com/tmyepw.zip", s.getClimateTypicalYearDownload());
  }

  @Test
  void settersAndGetters_settingOneFilenameDoesNotDisturbTheOthers () {
    solarchvision_bim.STATION s = app.new STATION();
    s.setEnsembleForecastFilename("naefs.csv");

    s.setEnsembleObservationFilename("swob.csv"); // must not overwrite NAEFS, per the bug above

    assertEquals("swob.csv", s.getEnsembleObservationFilename());
    assertEquals("naefs.csv", s.getEnsembleForecastFilename());
  }

  // ================= constructors ==========================================

  @Test
  void defaultConstructor_leavesEveryFieldAtItsZeroOrEmptyDefault () {
    solarchvision_bim.STATION s = app.new STATION();

    assertEquals(0f, s.getElevation(), 0.0001f);
    assertEquals(0f, s.getLatitude(), 0.0001f);
    assertEquals("", s.getCode());
    assertEquals("", s.getCity());
  }

  @Test
  void fullConstructor_setsEveryFieldFromItsArguments () {
    solarchvision_bim.STATION s = app.new STATION(
      "YUL", "Montreal", "QC", "Canada",
      45.5f, -73.5f, -5f, 120.5f,
      "http://example.com/tmyepw.zip", "tmyepw.csv",
      "cweeds.csv", "naefs.csv", "swob.csv"
    );

    assertEquals("YUL", s.getCode());
    assertEquals("Montreal", s.getCity());
    assertEquals("QC", s.getProvince());
    assertEquals("Canada", s.getCountry());
    assertEquals(45.5f, s.getLatitude(), 0.0001f);
    assertEquals(-73.5f, s.getLongitude(), 0.0001f);
    assertEquals(-5f, s.getTimezoneLongitude(), 0.0001f);
    assertEquals(120.5f, s.getElevation(), 0.0001f);
    assertEquals("http://example.com/tmyepw.zip", s.getClimateTypicalYearDownload());
    assertEquals("tmyepw.csv", s.getClimateTypicalYearFilename());
    assertEquals("cweeds.csv", s.getClimateEngineeringFilename());
    assertEquals("naefs.csv", s.getEnsembleForecastFilename());
    assertEquals("swob.csv", s.getEnsembleObservationFilename());
  }

  // ================= to_XML / from_XML round trip ==========================

  @Test
  void toXMLThenFromXML_roundTripsTheFieldsToXMLActuallyWrites () {
    // to_XML only persists code/city/province/country, the four numeric
    // fields, and the NAEFS/CWEEDS/TMYEPW filenames - Ensemble Observation and
    // climateTypicalYearDownload are deliberately not part of the round trip.
    solarchvision_bim.STATION original = app.new STATION(
      "YUL", "Montreal", "QC", "Canada",
      45.5f, -73.5f, -5f, 120.5f,
      "http://example.com/tmyepw.zip", "tmyepw.csv",
      "cweeds.csv", "naefs.csv", "swob.csv"
    );

    processing.data.XML root = new processing.data.XML("root");
    original.to_XML(root);

    solarchvision_bim.STATION loaded = app.new STATION();
    loaded.from_XML(root);

    assertEquals("YUL", loaded.getCode());
    assertEquals("Montreal", loaded.getCity());
    assertEquals("QC", loaded.getProvince());
    assertEquals("Canada", loaded.getCountry());
    assertEquals(45.5f, loaded.getLatitude(), 0.0001f);
    assertEquals(-73.5f, loaded.getLongitude(), 0.0001f);
    assertEquals(-5f, loaded.getTimezoneLongitude(), 0.0001f);
    assertEquals(120.5f, loaded.getElevation(), 0.0001f);
    assertEquals("naefs.csv", loaded.getEnsembleForecastFilename());
    assertEquals("cweeds.csv", loaded.getClimateEngineeringFilename());
    assertEquals("tmyepw.csv", loaded.getClimateTypicalYearFilename());
  }
}
