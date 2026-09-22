import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

class NearestStationTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  private solarchvision_bim.STATION stationAt (float lon, float lat) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setLongitude(lon);
    s.setLatitude(lat);
    return s;
  }

  // --- findNearestStation ------------------------------

  @Test
  void findNearestStation_picksTheClosestByGreatCircleDistance () {
    app.STATION.setLongitude(0);
    app.STATION.setLatitude(0);

    solarchvision_bim.STATION[] coords = {
      stationAt(10, 10),  // far
      stationAt(1, 1),    // closest
      stationAt(-5, -5)   // medium
    };

    solarchvision_bim.NearestStation nearest = app.findNearestStation(coords);

    assertEquals(1, nearest.index);
    float expectedDist = app.funcs.lon_lat_dist(1, 1, 0, 0);
    assertEquals(expectedDist, nearest.dist, 1f);
  }

  @Test
  void findNearestStation_wrapsLongitudesAbove180BeforeMeasuring () {
    // A raw longitude of 190 is the same physical point as -170 - the
    // function is supposed to wrap it before measuring, so a station
    // "at" 190 right next to a reference station at -170 should come
    // out essentially co-located, not ~360 degrees apart.
    app.STATION.setLongitude(-170);
    app.STATION.setLatitude(0);

    solarchvision_bim.STATION[] coords = { stationAt(190, 0) };

    solarchvision_bim.NearestStation nearest = app.findNearestStation(coords);

    assertEquals(0, nearest.index);
    assertEquals(0f, nearest.dist, 1f); // co-located after wrapping, not a near-antipodal distance
  }

  // --- findNearbyStations -------------------------------

  @Test
  void findNearbyStations_returnsOnlyThoseWithinMaxDistSortedAscending () {
    solarchvision_bim.STATION[] coords = {
      stationAt(1.0f, 0),  // included, 3rd closest
      stationAt(0.1f, 0),  // included, closest
      stationAt(10.0f, 0), // excluded - too far
      stationAt(0.5f, 0)   // included, 2nd closest
    };

    // A threshold strictly between the 1deg and 10deg distances, derived
    // from the same trusted lon_lat_dist rather than a hardcoded meter
    // value: everything within 1deg qualifies, the 10deg station doesn't.
    float dist1deg = app.funcs.lon_lat_dist(0, 0, 1.0f, 0);
    float dist10deg = app.funcs.lon_lat_dist(0, 0, 10.0f, 0);
    float maxDist = 0.5f * (dist1deg + dist10deg);

    int[] result = app.findNearbyStations(coords, 0, 0, maxDist, 10);

    assertArrayEquals(new int[]{1, 3, 0}, result); // indices of 0.1, 0.5, 1.0 deg stations, ascending distance
  }

  @Test
  void findNearbyStations_truncatesToMaxCountAfterSorting () {
    solarchvision_bim.STATION[] coords = {
      stationAt(1.0f, 0),
      stationAt(0.1f, 0),
      stationAt(0.5f, 0)
    };

    float dist1deg = app.funcs.lon_lat_dist(0, 0, 1.0f, 0);
    int[] result = app.findNearbyStations(coords, 0, 0, dist1deg + 1f, 2);

    assertEquals(2, result.length);
    assertArrayEquals(new int[]{1, 2}, result); // only the 2 closest (0.1deg, 0.5deg), not the 3rd
  }

  @Test
  void findNearbyStations_alsoWrapsLongitudesAbove180 () {
    solarchvision_bim.STATION[] coords = { stationAt(190, 0) };
    // Reference point at -170: a raw-190 station is co-located with it
    // once wrapped, so it should be found well within a tight maxDist.
    int[] result = app.findNearbyStations(coords, -170, 0, 1000f, 10);
    assertArrayEquals(new int[]{0}, result);
  }
}
