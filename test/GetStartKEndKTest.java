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
    app.CurrentDataSource = app.dataID_CLIMATE_CWEEDS;
    app.SampleYear_Start = 1980; // within [CLIMATE_CWEEDS_start, _end] = [1970, 2017]
    app.SampleYear_End = 2000;

    int[] range = app.get_startK_endK();

    assertEquals(1980 - app.CLIMATE_CWEEDS_start, range[0]);
    assertEquals(2000 - app.CLIMATE_CWEEDS_start, range[1]);
  }

  @Test
  void cweeds_clampsOutOfBoundsSampleRangeToTheDataSourcesOwnRange () {
    app.CurrentDataSource = app.dataID_CLIMATE_CWEEDS;
    app.SampleYear_Start = 1900; // below CLIMATE_CWEEDS_start (1970)
    app.SampleYear_End = 2100;   // above CLIMATE_CWEEDS_end (2017)

    int[] range = app.get_startK_endK();

    assertEquals(0, range[0]); // clamped to CLIMATE_CWEEDS_start, then zero-based
    assertEquals(app.CLIMATE_CWEEDS_end - app.CLIMATE_CWEEDS_start, range[1]);
  }

  @Test
  void clmrec_clampsTheSameWayAsCweeds () {
    app.CurrentDataSource = app.dataID_CLIMATE_CLMREC;
    app.SampleYear_Start = 1900; // below CLIMATE_CLMREC_start (2000)
    app.SampleYear_End = 2100;   // above CLIMATE_CLMREC_end (year(), i.e. this year)

    int[] range = app.get_startK_endK();

    assertEquals(0, range[0]);
    assertEquals(app.CLIMATE_CLMREC_end - app.CLIMATE_CLMREC_start, range[1]);
  }

  @Test
  void tmyepw_alwaysReturnsZeroZeroRegardlessOfSampleYearFields () {
    app.CurrentDataSource = app.dataID_CLIMATE_TMYEPW;
    app.SampleYear_Start = 1980;
    app.SampleYear_End = 2000;

    int[] range = app.get_startK_endK();

    assertArrayEquals(new int[]{0, 0}, range);
  }

  @Test
  void ensembleForecast_subtractsItsStartButDoesNotClampToItsOwnEnd () {
    // Unlike the CWEEDS/CLMREC branches, this one has no bounds-check
    // against ENSEMBLE_FORECAST_end at all - only ENSEMBLE_FORECAST_start
    // is subtracted. So a SampleMember_End past the real end (43) passes
    // straight through un-clamped; this test documents that asymmetry
    // rather than assuming it's a bug (both DataUtilsTest's dispatch
    // functions and this one read the same Sample*/CurrentDataSource
    // state, so it's worth knowing this branch behaves differently).
    app.CurrentDataSource = app.dataID_ENSEMBLE_FORECAST;
    app.SampleMember_Start = 5;
    app.SampleMember_End = 100; // past ENSEMBLE_FORECAST_end (43) - not clamped

    int[] range = app.get_startK_endK();

    assertEquals(5 - app.ENSEMBLE_FORECAST_start, range[0]);
    assertEquals(100 - app.ENSEMBLE_FORECAST_start, range[1]);
  }

  @Test
  void ensembleObserved_subtractsItsStartWithNoClamping () {
    app.CurrentDataSource = app.dataID_ENSEMBLE_OBSERVED;
    app.SampleStation_Start = 1;
    app.SampleStation_End = 1;

    int[] range = app.get_startK_endK();

    assertEquals(1 - app.ENSEMBLE_OBSERVED_start, range[0]);
    assertEquals(1 - app.ENSEMBLE_OBSERVED_start, range[1]);
  }

  @Test
  void unrecognizedSource_leavesBothIndicesAtTheirMinusOneDefault () {
    app.CurrentDataSource = -1;
    int[] range = app.get_startK_endK();
    assertArrayEquals(new int[]{-1, -1}, range);
  }
}
