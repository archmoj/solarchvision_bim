import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class DataUtilsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // --- getStart_CurrentDataSource / getEnd_CurrentDataSource -----------

  @Test
  void getStartAndEnd_dispatchToEachDataSourcesOwnFields () {
    app.CurrentDataSource = app.dataID_CLIMATE_CWEEDS;
    assertEquals(app.CLIMATE_CWEEDS_start, app.getStart_CurrentDataSource());
    assertEquals(app.CLIMATE_CWEEDS_end, app.getEnd_CurrentDataSource());

    app.CurrentDataSource = app.dataID_CLIMATE_CLMREC;
    assertEquals(app.CLIMATE_CLMREC_start, app.getStart_CurrentDataSource());
    // CLIMATE_CLMREC_end is seeded from year() (today's year), so this
    // reads it off `app` rather than hardcoding a value that would go
    // stale.
    assertEquals(app.CLIMATE_CLMREC_end, app.getEnd_CurrentDataSource());

    app.CurrentDataSource = app.dataID_CLIMATE_TMYEPW;
    assertEquals(app.CLIMATE_TMYEPW_start, app.getStart_CurrentDataSource());
    assertEquals(app.CLIMATE_TMYEPW_end, app.getEnd_CurrentDataSource());

    app.CurrentDataSource = app.dataID_ENSEMBLE_FORECAST;
    assertEquals(app.ENSEMBLE_FORECAST_start, app.getStart_CurrentDataSource());
    assertEquals(app.ENSEMBLE_FORECAST_end, app.getEnd_CurrentDataSource());

    app.CurrentDataSource = app.dataID_ENSEMBLE_OBSERVED;
    assertEquals(app.ENSEMBLE_OBSERVED_start, app.getStart_CurrentDataSource());
    assertEquals(app.ENSEMBLE_OBSERVED_end, app.getEnd_CurrentDataSource());
  }

  @Test
  void getStartAndEnd_defaultToMinusOneForAnUnrecognizedSource () {
    app.CurrentDataSource = -1; // none of the 5 known dataID_* constants
    assertEquals(-1, app.getStart_CurrentDataSource());
    assertEquals(-1, app.getEnd_CurrentDataSource());
  }

  // --- getReference_CurrentDataSource ---------------------------------

  @Test
  void getReference_buildsTheCWEEDSCitationFromTheStationFilename () {
    app.CurrentDataSource = app.dataID_CLIMATE_CWEEDS;
    String expected = app.STATION.getFilename_CWEEDS() + ".WY3"
      + ", Environment and Climate Change Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/";
    assertEquals(expected, app.getReference_CurrentDataSource());
  }

  @Test
  void getReference_isAFixedStringForCLMREC () {
    app.CurrentDataSource = app.dataID_CLIMATE_CLMREC;
    assertEquals(
      "Environment and Climate Change Canada website at https://climate.weather.gc.ca/climate_data",
      app.getReference_CurrentDataSource());
  }

  @Test
  void getReference_buildsTheTMYEPWCitationFromTheStationFilename () {
    app.CurrentDataSource = app.dataID_CLIMATE_TMYEPW;
    String expected = app.STATION.getFilename_TMYEPW() + ".epw";
    assertEquals(expected, app.getReference_CurrentDataSource());
  }

  @Test
  void getReference_isAFixedStringForEnsembleObserved () {
    app.CurrentDataSource = app.dataID_ENSEMBLE_OBSERVED;
    assertEquals(
      "Environment and Climate Change Canada website at https://dd.weather.gc.ca/observations/swob-ml/",
      app.getReference_CurrentDataSource());
  }

  @Test
  void getReference_isEmptyForAnUnrecognizedSource () {
    app.CurrentDataSource = -1;
    assertEquals("", app.getReference_CurrentDataSource());
  }

  // --- setValue / getValue_CurrentDataSource --------------------------

  @Test
  void setValueThenGetValue_roundTripsThroughTheRightArraySlot () {
    app.CurrentDataSource = app.dataID_CLIMATE_TMYEPW;
    app.CLIMATE_TMYEPW_values = new float[2][2][2][2]; // [i][j][Parameter_ID][k]

    app.setValue_CurrentDataSource(0, 0, 0, 0, 111f);
    app.setValue_CurrentDataSource(1, 0, 0, 0, 222f); // different i
    app.setValue_CurrentDataSource(0, 1, 0, 0, 333f); // different j
    app.setValue_CurrentDataSource(0, 0, 1, 0, 444f); // different k (3rd param)
    app.setValue_CurrentDataSource(0, 0, 0, 1, 555f); // different Parameter_ID (4th param)

    assertEquals(111f, app.getValue_CurrentDataSource(0, 0, 0, 0));
    assertEquals(222f, app.getValue_CurrentDataSource(1, 0, 0, 0));
    assertEquals(333f, app.getValue_CurrentDataSource(0, 1, 0, 0));
    assertEquals(444f, app.getValue_CurrentDataSource(0, 0, 1, 0));
    assertEquals(555f, app.getValue_CurrentDataSource(0, 0, 0, 1));
  }

  @Test
  void getValue_defaultsToFLOAT_undefinedForAnUnrecognizedSource () {
    app.CurrentDataSource = -1;
    assertEquals(app.FLOAT_undefined, app.getValue_CurrentDataSource(0, 0, 0, 0));
  }

  // --- setFlag_CurrentDataSource ---------------------------------------

  @Test
  void setFlag_writesIntoTheRightArraySlot () {
    app.CurrentDataSource = app.dataID_CLIMATE_TMYEPW;
    app.CLIMATE_TMYEPW_flags = new boolean[2][2][2][2]; // [i][j][Parameter_ID][k]

    app.setFlag_CurrentDataSource(1, 0, 0, 1, true);

    // setFlag_CurrentDataSource has no matching getter in this file, so
    // verify by reading the backing array directly - it's package-
    // private, same as every other field this test suite touches.
    assertTrue(app.CLIMATE_TMYEPW_flags[1][0][1][0]);   // (i=1, j=0, Parameter_ID=1, k=0)
    assertFalse(app.CLIMATE_TMYEPW_flags[0][0][0][0]);  // untouched slot stays false
  }
}
