import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_Land3D.getLandGrid (Land3D.pde) - a pure
// function that samples a point on a polar grid centered on the
// station, used to build the terrain mesh's lon/lat lookup points. It's
// built entirely from funcs (already covered by FunctionsTest.java) and
// STATION's current position, with no file I/O or loaded mesh data
// needed. Reached through the pre-constructed `app.Land3D` field;
// already package-private, no visibility changes needed.
class LandGridTest {

  private static solarchvision_bim app;
  private static final float EPS = 0.0001f;

  // The 50m-in-degrees step size baked into getLandGrid's source.
  private static final double STP_LAT = 1.0 / 2224.5968;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void row0_alwaysReturnsTheStationsOwnPositionRegardlessOfColumn () {
    // i=0 collapses the polar grid's radius to 0 (r = (i>0) ? ... : 0),
    // so every column in that innermost row is just the station itself.
    double stationLon = app.STATION.getLongitude();
    double stationLat = app.STATION.getLatitude();

    double[] atColumn0 = app.Land3D.getLandGrid(0, 0);
    double[] atColumn5 = app.Land3D.getLandGrid(0, 5);
    double[] atLastColumn = app.Land3D.getLandGrid(0, app.Land3D.num_columns - 1);

    for (double[] p : new double[][]{atColumn0, atColumn5, atLastColumn}) {
      assertEquals(stationLon, p[0], EPS);
      assertEquals(stationLat, p[1], EPS);
    }
  }

  @Test
  void row1_offsetsByOneStepAtTheColumnAnglesCosAndSin () {
    // i=1 gives r = q^0 = 1 (a single 50m-equivalent step), so column 0
    // (angle 0deg: cos=1, sin=0) should offset purely in longitude, and
    // the column at 90deg (angle t=90 happens at column num_columns/4
    // for the default 25-column, 15deg-per-column grid, i.e. column 6)
    // should offset purely in latitude.
    double stationLon = app.STATION.getLongitude();
    double stationLat = app.STATION.getLatitude();
    double stpLon = STP_LAT / app.funcs.cos_ang(app.STATION.getLatitude());

    double[] atAngle0 = app.Land3D.getLandGrid(1, 0);
    assertEquals(stationLon + stpLon, atAngle0[0], EPS);
    assertEquals(stationLat, atAngle0[1], EPS);

    double[] atAngle90 = app.Land3D.getLandGrid(1, 6); // 6 * 15deg = 90deg
    assertEquals(stationLon, atAngle90[0], EPS);
    assertEquals(stationLat + STP_LAT, atAngle90[1], EPS);
  }

  @Test
  void radiusGrowsByPowersOfSqrt2WithEachRow () {
    // r = q^(i-1) where q = sqrt(2), so row 2's offset (at the same
    // angle) should be sqrt(2) times row 1's offset.
    double stationLon = app.STATION.getLongitude();

    double[] row1 = app.Land3D.getLandGrid(1, 0);
    double[] row2 = app.Land3D.getLandGrid(2, 0);

    double row1Offset = row1[0] - stationLon;
    double row2Offset = row2[0] - stationLon;

    assertEquals(Math.sqrt(2), row2Offset / row1Offset, EPS);
  }
}
