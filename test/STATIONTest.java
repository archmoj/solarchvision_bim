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
    s.setTimelong(-5f);

    assertEquals(120.5f, s.getElevation(), 0.0001f);
    assertEquals(45.5f, s.getLatitude(), 0.0001f);
    assertEquals(-73.5f, s.getLongitude(), 0.0001f);
    assertEquals(-5f, s.getTimelong(), 0.0001f);
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
    // setFilename_SWOB previously assigned filename_NAEFS instead of its own
    // parameter (a copy-paste bug) - fixed in STATION.pde alongside this test.
    solarchvision_bim.STATION s = app.new STATION();

    s.setFilename_SWOB("swob.csv");
    s.setFilename_NAEFS("naefs.csv");
    s.setFilename_CWEEDS("cweeds.csv");
    s.setFilename_TMYEPW("tmyepw.csv");
    s.setDownload_TMYEPW("http://example.com/tmyepw.zip");

    assertEquals("swob.csv", s.getFilename_SWOB());
    assertEquals("naefs.csv", s.getFilename_NAEFS());
    assertEquals("cweeds.csv", s.getFilename_CWEEDS());
    assertEquals("tmyepw.csv", s.getFilename_TMYEPW());
    assertEquals("http://example.com/tmyepw.zip", s.getDownload_TMYEPW());
  }

  @Test
  void settersAndGetters_settingOneFilenameDoesNotDisturbTheOthers () {
    solarchvision_bim.STATION s = app.new STATION();
    s.setFilename_NAEFS("naefs.csv");

    s.setFilename_SWOB("swob.csv"); // must not overwrite NAEFS, per the bug above

    assertEquals("swob.csv", s.getFilename_SWOB());
    assertEquals("naefs.csv", s.getFilename_NAEFS());
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
    assertEquals(-5f, s.getTimelong(), 0.0001f);
    assertEquals(120.5f, s.getElevation(), 0.0001f);
    assertEquals("http://example.com/tmyepw.zip", s.getDownload_TMYEPW());
    assertEquals("tmyepw.csv", s.getFilename_TMYEPW());
    assertEquals("cweeds.csv", s.getFilename_CWEEDS());
    assertEquals("naefs.csv", s.getFilename_NAEFS());
    assertEquals("swob.csv", s.getFilename_SWOB());
  }

  // ================= to_XML / from_XML round trip ==========================

  @Test
  void toXMLThenFromXML_roundTripsTheFieldsToXMLActuallyWrites () {
    // to_XML only persists code/city/province/country, the four numeric
    // fields, and the NAEFS/CWEEDS/TMYEPW filenames - SWOB and
    // Download_TMYEPW are deliberately not part of the round trip.
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
    assertEquals(-5f, loaded.getTimelong(), 0.0001f);
    assertEquals(120.5f, loaded.getElevation(), 0.0001f);
    assertEquals("naefs.csv", loaded.getFilename_NAEFS());
    assertEquals("cweeds.csv", loaded.getFilename_CWEEDS());
    assertEquals("tmyepw.csv", loaded.getFilename_TMYEPW());
  }
}
