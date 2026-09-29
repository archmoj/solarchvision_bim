import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class DataUtilsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // --- getStart_currentDataSource / getEnd_currentDataSource -----------

  @Test
  void getStartAndEnd_dispatchToEachDataSourcesOwnFields () {
    app.currentDataSource = app.dataID_climateEngineering;
    assertEquals(app.climateEngineeringStart, app.getStart_currentDataSource());
    assertEquals(app.climateEngineeringEnd, app.getEnd_currentDataSource());

    app.currentDataSource = app.dataID_climateArchive;
    assertEquals(app.climateArchiveStart, app.getStart_currentDataSource());
    // climateArchiveEnd is seeded from year() (today's year), so this
    // reads it off `app` rather than hardcoding a value that would go
    // stale.
    assertEquals(app.climateArchiveEnd, app.getEnd_currentDataSource());

    app.currentDataSource = app.dataID_climateTmyEpw;
    assertEquals(app.climateTypicalYearStart, app.getStart_currentDataSource());
    assertEquals(app.climateTypicalYearEnd, app.getEnd_currentDataSource());

    app.currentDataSource = app.dataID_ensembleForecast;
    assertEquals(app.ensembleForecastStart, app.getStart_currentDataSource());
    assertEquals(app.ensembleForecastEnd, app.getEnd_currentDataSource());

    app.currentDataSource = app.dataID_ensembleObservation;
    assertEquals(app.ensembleObservationStart, app.getStart_currentDataSource());
    assertEquals(app.ensembleObservationEnd, app.getEnd_currentDataSource());
  }

  @Test
  void getStartAndEnd_defaultToMinusOneForAnUnrecognizedSource () {
    app.currentDataSource = -1; // none of the 5 known dataID_* constants
    assertEquals(-1, app.getStart_currentDataSource());
    assertEquals(-1, app.getEnd_currentDataSource());
  }

  // --- getReference_currentDataSource ---------------------------------

  @Test
  void getReference_buildsTheCWEEDSCitationFromTheStationFilename () {
    app.currentDataSource = app.dataID_climateEngineering;
    String expected = app.STATION.getClimateEngineeringFilename() + ".WY3"
      + ", Environment and Climate Change Canada: ftp://ftp.tor.ec.gc.ca/Pub/Normals/";
    assertEquals(expected, app.getReference_currentDataSource());
  }

  @Test
  void getReference_isAFixedStringForCLMREC () {
    app.currentDataSource = app.dataID_climateArchive;
    assertEquals(
      "Environment and Climate Change Canada website at https://climate.weather.gc.ca/climate_data",
      app.getReference_currentDataSource());
  }

  @Test
  void getReference_buildsTheTMYEPWCitationFromTheStationFilename () {
    app.currentDataSource = app.dataID_climateTmyEpw;
    String expected = app.STATION.getClimateTypicalYearFilename() + ".epw";
    assertEquals(expected, app.getReference_currentDataSource());
  }

  @Test
  void getReference_isAFixedStringForEnsembleObserved () {
    app.currentDataSource = app.dataID_ensembleObservation;
    assertEquals(
      "Environment and Climate Change Canada website at https://dd.weather.gc.ca/observations/swob-ml/",
      app.getReference_currentDataSource());
  }

  @Test
  void getReference_isEmptyForAnUnrecognizedSource () {
    app.currentDataSource = -1;
    assertEquals("", app.getReference_currentDataSource());
  }

  // --- setValue / getValue_currentDataSource --------------------------

  @Test
  void setValueThenGetValue_roundTripsThroughTheRightArraySlot () {
    app.currentDataSource = app.dataID_climateTmyEpw;
    app.climateTmyEpw_values = new float[2][2][2][2]; // [i][j][Parameter_ID][k]

    app.setValue_currentDataSource(0, 0, 0, 0, 111f);
    app.setValue_currentDataSource(1, 0, 0, 0, 222f); // different i
    app.setValue_currentDataSource(0, 1, 0, 0, 333f); // different j
    app.setValue_currentDataSource(0, 0, 1, 0, 444f); // different k (3rd param)
    app.setValue_currentDataSource(0, 0, 0, 1, 555f); // different Parameter_ID (4th param)

    assertEquals(111f, app.getValue_currentDataSource(0, 0, 0, 0));
    assertEquals(222f, app.getValue_currentDataSource(1, 0, 0, 0));
    assertEquals(333f, app.getValue_currentDataSource(0, 1, 0, 0));
    assertEquals(444f, app.getValue_currentDataSource(0, 0, 1, 0));
    assertEquals(555f, app.getValue_currentDataSource(0, 0, 0, 1));
  }

  @Test
  void getValue_defaultsToFLOAT_undefinedForAnUnrecognizedSource () {
    app.currentDataSource = -1;
    assertEquals(app.FLOAT_undefined, app.getValue_currentDataSource(0, 0, 0, 0));
  }

  // --- setFlag_currentDataSource ---------------------------------------

  @Test
  void setFlag_writesIntoTheRightArraySlot () {
    app.currentDataSource = app.dataID_climateTmyEpw;
    app.climateTmyEpw_flags = new boolean[2][2][2][2]; // [i][j][Parameter_ID][k]

    app.setFlag_currentDataSource(1, 0, 0, 1, true);

    // setFlag_currentDataSource has no matching getter in this file, so
    // verify by reading the backing array directly - it's package-
    // private, same as every other field this test suite touches.
    assertTrue(app.climateTmyEpw_flags[1][0][1][0]);   // (i=1, j=0, Parameter_ID=1, k=0)
    assertFalse(app.climateTmyEpw_flags[0][0][0][0]);  // untouched slot stays false
  }
}
