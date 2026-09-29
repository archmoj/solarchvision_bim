import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class GetStartKEndKTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void cweeds_passesThroughWithinBoundsThenMakesItZeroBased () {
    app.currentDataSource = app.dataID_climateEngineering;
    app.sampleYearStart = 1980; // within [climateEngineeringStart, _end] = [1970, 2017]
    app.sampleYearEnd = 2000;

    int[] range = app.get_startK_endK();

    assertEquals(1980 - app.climateEngineeringStart, range[0]);
    assertEquals(2000 - app.climateEngineeringStart, range[1]);
  }

  @Test
  void cweeds_clampsOutOfBoundsSampleRangeToTheDataSourcesOwnRange () {
    app.currentDataSource = app.dataID_climateEngineering;
    app.sampleYearStart = 1900; // below climateEngineeringStart (1970)
    app.sampleYearEnd = 2100;   // above climateEngineeringEnd (2017)

    int[] range = app.get_startK_endK();

    assertEquals(0, range[0]); // clamped to climateEngineeringStart, then zero-based
    assertEquals(app.climateEngineeringEnd - app.climateEngineeringStart, range[1]);
  }

  @Test
  void clmrec_clampsTheSameWayAsCweeds () {
    app.currentDataSource = app.dataID_climateArchive;
    app.sampleYearStart = 1900; // below climateArchiveStart (2000)
    app.sampleYearEnd = 2100;   // above climateArchiveEnd (year(), i.e. this year)

    int[] range = app.get_startK_endK();

    assertEquals(0, range[0]);
    assertEquals(app.climateArchiveEnd - app.climateArchiveStart, range[1]);
  }

  @Test
  void climate_typical_year_alwaysReturnsZeroZeroRegardlessOfSampleYearFields () {
    app.currentDataSource = app.dataID_climateTmyEpw;
    app.sampleYearStart = 1980;
    app.sampleYearEnd = 2000;

    int[] range = app.get_startK_endK();

    assertArrayEquals(new int[]{0, 0}, range);
  }

  @Test
  void ensembleForecast_subtractsItsStartButDoesNotClampToItsOwnEnd () {
    // Unlike the CWEEDS/CLMREC branches, this one has no bounds-check
    // against ensembleForecastEnd at all - only ensembleForecastStart
    // is subtracted. So a sampleMemberEnd past the real end (43) passes
    // straight through un-clamped; this test documents that asymmetry
    // rather than assuming it's a bug (both DataUtilsTest's dispatch
    // functions and this one read the same Sample*/currentDataSource
    // state, so it's worth knowing this branch behaves differently).
    app.currentDataSource = app.dataID_ensembleForecast;
    app.sampleMemberStart = 5;
    app.sampleMemberEnd = 100; // past ensembleForecastEnd (43) - not clamped

    int[] range = app.get_startK_endK();

    assertEquals(5 - app.ensembleForecastStart, range[0]);
    assertEquals(100 - app.ensembleForecastStart, range[1]);
  }

  @Test
  void ensembleObserved_subtractsItsStartWithNoClamping () {
    app.currentDataSource = app.dataID_ensembleObservation;
    app.sampleStationStart = 1;
    app.sampleStationEnd = 1;

    int[] range = app.get_startK_endK();

    assertEquals(1 - app.ensembleObservationStart, range[0]);
    assertEquals(1 - app.ensembleObservationStart, range[1]);
  }

  @Test
  void unrecognizedSource_leavesBothIndicesAtTheirMinusOneDefault () {
    app.currentDataSource = -1;
    int[] range = app.get_startK_endK();
    assertArrayEquals(new int[]{-1, -1}, range);
  }
}
