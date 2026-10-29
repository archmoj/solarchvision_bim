import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Covers hoverOnWorldStations.pde's own pure logic: addNearbyWorldStationCandidates()
// (one dataset's own radius/visibility test) and collectNearbyWorldStationNames()
// (merging every dataset, closest-first, with duplicate short names dropped).
// clearWorldHover()/place_WORLD_hover() themselves touch real graphics (get()/
// image()/queueHover()) and aren't independently testable here, consistent with
// everything else this session that draws to a live PGraphics context (see e.g.
// StudySunpathHoverTest.java's own comment on this).
class WorldStationHoverTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();

    // A simple, exactly-invertible projection, chosen so station screen
    // positions are easy to reason about by hand: oX=0, sX=1, dX=360 makes
    // projX(lon) == lon + 180 (lon=-180 -> x=0, lon=0 -> x=180, lon=180 ->
    // x=360); oY=0, sY=1, dY=180 makes projY(lat) == 90 - lat (lat=90 ->
    // y=0, lat=0 -> y=90, lat=-90 -> y=180) - see WORLD.pde's own projX()/
    // projY() for the general formulas these are a special case of.
    app.WORLD.oX = 0;
    app.WORLD.oY = 0;
    app.WORLD.sX = 1;
    app.WORLD.sY = 1;
    app.WORLD.dX = 360;
    app.WORLD.dY = 180;
    app.WORLD.ImageScale = 1;
    app.WORLD.cX = 0;
    app.WORLD.cY = 0;

    // Whole-world view window by default - individual tests narrow this
    // when they specifically want to test isWithinView()'s own gating.
    app.WORLD.viewWindowLon1 = -180;
    app.WORLD.viewWindowLon2 = 180;
    app.WORLD.viewWindowLat1 = -90;
    app.WORLD.viewWindowLat2 = 90;

    // Every dataset's own "show all" markers off by default - individual
    // tests turn on whichever one(s) they need, same as a real session only
    // ever shows markers for datasets the user has actually switched on.
    app.WORLD.ensembleObservationDisplayAll = 0;
    app.WORLD.ensembleForecastDisplayAll = 0;
    app.WORLD.climateEngineeringDisplayAll = 0;
    app.WORLD.climateArchiveDisplayAll = 0;
    app.WORLD.climateTypicalYearDisplayAll = 0;

    app.ensembleObservationCoordinates = new solarchvision_bim.STATION[0];
    app.ensembleForecastCoordinates = new solarchvision_bim.STATION[0];
    app.climateEngineeringCoordinates = new solarchvision_bim.STATION[0];
    app.climateArchiveCoordinates = new solarchvision_bim.STATION[0];
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[0];
  }

  private solarchvision_bim.STATION stationAt (float lon, float lat, String code, String city) {
    solarchvision_bim.STATION s = app.new STATION();
    s.setLongitude(lon);
    s.setLatitude(lat);
    s.setCode(code);
    s.setCity(city);
    return s;
  }

  // ================= addNearbyWorldStationCandidates =========================

  @Test
  void addCandidates_includesAStationWithinRadius_usingCityByDefault () {
    // lon=1, lat=0 projects to (181, 90); mouse at local (180, 90) is 1px
    // away, comfortably inside the default 10px radius.
    solarchvision_bim.STATION[] coords = { stationAt(1, 0, "AAA", "Alpha City") };

    java.util.ArrayList<String> names = new java.util.ArrayList<String>();
    java.util.ArrayList<Float> distsSq = new java.util.ArrayList<Float>();
    app.addNearbyWorldStationCandidates(coords, 1, false, 180, 90, names, distsSq);

    assertEquals(1, names.size());
    assertEquals("Alpha City", names.get(0)); // useCode=false -> getCity()
  }

  @Test
  void addCandidates_usesCodeWhenUseCodeIsTrue () {
    solarchvision_bim.STATION[] coords = { stationAt(1, 0, "AAA", "Alpha City") };

    java.util.ArrayList<String> names = new java.util.ArrayList<String>();
    java.util.ArrayList<Float> distsSq = new java.util.ArrayList<Float>();
    app.addNearbyWorldStationCandidates(coords, 1, true, 180, 90, names, distsSq);

    assertEquals(1, names.size());
    assertEquals("AAA", names.get(0)); // useCode=true -> getCode()
  }

  @Test
  void addCandidates_excludesAStationOutsideTheRadius () {
    // lon=50, lat=0 projects to (230, 90) - 50px from a mouse at (180, 90),
    // well outside the default 10px radius.
    solarchvision_bim.STATION[] coords = { stationAt(50, 0, "FAR", "Far City") };

    java.util.ArrayList<String> names = new java.util.ArrayList<String>();
    java.util.ArrayList<Float> distsSq = new java.util.ArrayList<Float>();
    app.addNearbyWorldStationCandidates(coords, 1, false, 180, 90, names, distsSq);

    assertTrue(names.isEmpty());
  }

  @Test
  void addCandidates_excludesEverything_whenDisplayAllLevelIsZero () {
    // Close enough to match on distance alone, but this dataset's own
    // markers aren't switched on (displayAllLevel=0) - no marker is even
    // on screen to point at, so nothing should show up in the hover either.
    solarchvision_bim.STATION[] coords = { stationAt(1, 0, "AAA", "Alpha City") };

    java.util.ArrayList<String> names = new java.util.ArrayList<String>();
    java.util.ArrayList<Float> distsSq = new java.util.ArrayList<Float>();
    app.addNearbyWorldStationCandidates(coords, 0, false, 180, 90, names, distsSq);

    assertTrue(names.isEmpty());
  }

  @Test
  void addCandidates_excludesAStationOutsideTheCurrentViewWindow () {
    // Close enough on screen-pixel distance alone, but outside the
    // current lon/lat view window (isWithinView()) - e.g. a station just
    // past the edge of a panned/zoomed tile shouldn't surface in the
    // hover even if its raw projected position would coincidentally still
    // land near the mouse.
    app.WORLD.viewWindowLon1 = -180;
    app.WORLD.viewWindowLon2 = 0.5f; // excludes lon=1
    app.WORLD.viewWindowLat1 = -90;
    app.WORLD.viewWindowLat2 = 90;

    solarchvision_bim.STATION[] coords = { stationAt(1, 0, "AAA", "Alpha City") };

    java.util.ArrayList<String> names = new java.util.ArrayList<String>();
    java.util.ArrayList<Float> distsSq = new java.util.ArrayList<Float>();
    app.addNearbyWorldStationCandidates(coords, 1, false, 180, 90, names, distsSq);

    assertTrue(names.isEmpty());
  }

  @Test
  void addCandidates_wrapsLongitudesAbove180BeforeProjecting () {
    // A raw longitude of 359 is the same physical point as -1 - every
    // other WORLD station loop wraps this before using it (the "<<
    // important!" comments throughout WORLD.pde), and this one needs to
    // match, or a station just past the antimeridian would project to
    // completely the wrong side of the map.
    solarchvision_bim.STATION[] coords = { stationAt(359, 0, "WRP", "Wrap City") };

    java.util.ArrayList<String> names = new java.util.ArrayList<String>();
    java.util.ArrayList<Float> distsSq = new java.util.ArrayList<Float>();
    // lon=359 wraps to -1, which projects to local x=179 - 1px from a
    // mouse at local x=180.
    app.addNearbyWorldStationCandidates(coords, 1, false, 180, 90, names, distsSq);

    assertEquals(1, names.size());
    assertEquals("Wrap City", names.get(0));
  }

  // ================= collectNearbyWorldStationNames ===========================

  @Test
  void collect_returnsNull_whenNothingIsClose () {
    app.WORLD.climateTypicalYearDisplayAll = 1;
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{
      stationAt(50, 0, "FAR", "Far City")
    };

    assertNull(app.collectNearbyWorldStationNames(180, 90));
  }

  @Test
  void collect_mergesEveryDataset_closestFirst () {
    app.WORLD.ensembleObservationDisplayAll = 2; // SWOB -> getCode()
    app.WORLD.climateArchiveDisplayAll = 1;       // CLMREC -> getCity()

    // Both within the default radius of a mouse at local (180, 90): SWOB
    // 1px away (closer), CLMREC 3px away (farther).
    app.ensembleObservationCoordinates = new solarchvision_bim.STATION[]{
      stationAt(1, 0, "YYZ", "Toronto Pearson")
    };
    app.climateArchiveCoordinates = new solarchvision_bim.STATION[]{
      stationAt(3, 0, "YTO", "Toronto City")
    };

    String[] names = app.collectNearbyWorldStationNames(180, 90);

    assertNotNull(names);
    assertArrayEquals(new String[]{ "YYZ", "Toronto City" }, names);
  }

  @Test
  void collect_dropsDuplicateShortNames_keepingTheClosestOccurrence () {
    // Two different datasets happening to share the exact same short name
    // (e.g. a CWEEDS and a TMYEPW station for the same city) at slightly
    // different distances - the name should appear only once.
    app.WORLD.climateEngineeringDisplayAll = 1;
    app.WORLD.climateTypicalYearDisplayAll = 1;

    app.climateEngineeringCoordinates = new solarchvision_bim.STATION[]{
      stationAt(5, 0, "ENG", "Toronto") // farther, local x=185
    };
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{
      stationAt(1, 0, "EPW", "Toronto") // closer, local x=181
    };

    String[] names = app.collectNearbyWorldStationNames(180, 90);

    assertNotNull(names);
    assertArrayEquals(new String[]{ "Toronto" }, names); // once, not twice
  }

  @Test
  void collect_capsAtMaxNames_keepingTheClosestOnes_andNotesHowManyMoreThereWere () {
    // One more station than worldStationHoverMaxNames (8) allows, each a
    // little farther from the mouse than the last - zoomed way out over a
    // dense dataset, far more than 8 real stations can land within the
    // (now geographically huge) search radius at once, and the box
    // shouldn't grow to list all of them.
    app.WORLD.climateTypicalYearDisplayAll = 1;

    int stationCount = app.worldStationHoverMaxNames + 1;
    solarchvision_bim.STATION[] coords = new solarchvision_bim.STATION[stationCount];
    for (int i = 0; i < stationCount; i++) {
      // lon = i+1 -> local x = 181+i, i.e. (i+1)px from the mouse at
      // local x=180 - each one strictly farther than the last, all still
      // well inside the default 10px radius.
      coords[i] = stationAt(i + 1, 0, "S" + i, "City " + i);
    }
    app.climateTypicalYearCoordinates = coords;

    String[] names = app.collectNearbyWorldStationNames(180, 90);

    assertNotNull(names);
    assertEquals(app.worldStationHoverMaxNames + 1, names.length); // the 8 kept + one summary line
    assertEquals("City 0", names[0]); // closest station kept first
    assertEquals("City " + (app.worldStationHoverMaxNames - 1), names[app.worldStationHoverMaxNames - 1]); // 8th-closest, the last one actually kept
    assertEquals("+1 more nearby", names[app.worldStationHoverMaxNames]); // the 9th (farthest) station, summarized instead of listed
  }

  @Test
  void collect_doesNotAddASummaryLine_whenEverythingFitsUnderTheCap () {
    app.WORLD.climateTypicalYearDisplayAll = 1;
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{
      stationAt(1, 0, "A", "Alpha"),
      stationAt(2, 0, "B", "Beta")
    };

    String[] names = app.collectNearbyWorldStationNames(180, 90);

    assertArrayEquals(new String[]{ "Alpha", "Beta" }, names); // no "+N more" line
  }

  @Test
  void collect_ignoresStationsFartherThanTheHoverRadius () {
    app.WORLD.climateTypicalYearDisplayAll = 1;
    app.climateTypicalYearCoordinates = new solarchvision_bim.STATION[]{
      stationAt(1, 0, "NEAR", "Near City"),  // 1px away - included
      stationAt(90, 0, "FAR", "Far City")    // 90px away - excluded
    };

    String[] names = app.collectNearbyWorldStationNames(180, 90);

    assertNotNull(names);
    assertArrayEquals(new String[]{ "Near City" }, names);
  }

  // ================= WORLD.unprojLon / unprojLat ===============================
  // The inverse of WORLD.projX()/projY() - used by both
  // mouseClicked.pde's own handleWorldClickAt() and, below, a WORLD pin's
  // own geo-tracking.

  @Test
  void unproj_invertsProjExactly_acrossARangeOfPoints () {
    float[] lons = { -170, -90, -1, 0, 1, 90, 179 };
    float[] lats = { -89, -45, -1, 0, 1, 45, 89 };

    for (float lon : lons) {
      float x = app.WORLD.projX(lon);
      assertEquals(lon, app.WORLD.unprojLon(x), 0.0001f);
    }
    for (float lat : lats) {
      float y = app.WORLD.projY(lat);
      assertEquals(lat, app.WORLD.unprojLat(y), 0.0001f);
    }
  }

  @Test
  void unproj_matchesProjAtAnOffCenterProjection () {
    // A narrower, panned/zoomed-in window this time (oX/oY off zero,
    // sX/sY well under 1) - unprojLon()/unprojLat() must still invert
    // projX()/projY() exactly, not just for the simple setUp() case.
    app.WORLD.oX = 40;
    app.WORLD.oY = -10;
    app.WORLD.sX = 0.25f;
    app.WORLD.sY = 0.25f;

    float x = app.WORLD.projX(35);
    float y = app.WORLD.projY(-5);

    assertEquals(35f, app.WORLD.unprojLon(x), 0.0001f);
    assertEquals(-5f, app.WORLD.unprojLat(y), 0.0001f);
  }

  // ================= syncWorldHoverPointPositions ==============================
  // Keeps a WORLD-sourced pin (worldHoverPointGeo) tracking the same (lon,
  // lat) as WORLD itself pans/zooms, dropping it once that location is no
  // longer part of WORLD's own current view. A plain STUDY/WIN3D-style pin
  // (no worldHoverPointGeo entry) is left completely alone.

  @Test
  void sync_doesNothing_whenThereAreNoHoverPointsAtAll () {
    assertNull(app.allHoverPoints);

    app.syncWorldHoverPointPositions(); // must not throw

    assertNull(app.allHoverPoints);
  }

  @Test
  void sync_leavesAPlainScreenPin_completelyUntouched () {
    // A STUDY/WIN3D-style pin - never registered in worldHoverPointGeo -
    // even though its raw (x, y) happens to be inside WORLD's own current
    // bounds.
    int[] row = app.addHoverPoint(200, 90);

    app.syncWorldHoverPointPositions();

    assertArrayEquals(new int[]{ 200, 90 }, app.allHoverPoints[0]);
    assertSame(row, app.allHoverPoints[0]); // not replaced, not touched
  }

  @Test
  void sync_updatesAWorldPinsScreenPosition_whenTheMapHasPanned () {
    // Pinned at lon=10 while oX=0 - projX(10) = 190 (setUp()'s own simple
    // projection: x = lon + 180).
    int[] row = app.addHoverPoint(190, 90);
    app.worldHoverPointGeo.put(row, new float[]{ 10, 0 });

    // Simulate a pan: oX shifts by -20, as WORLD.draw() itself would have
    // already applied before drawAllHovers() runs this same frame (see
    // syncWorldHoverPointPositions()'s own comment on that ordering).
    app.WORLD.oX = -20;

    app.syncWorldHoverPointPositions();

    // projX(10) with the new oX=-20: dX*((10-(-20))/360+0.5)/sX = 210.
    assertEquals(210, app.allHoverPoints[0][0]);
    assertEquals(90, app.allHoverPoints[0][1]); // lat/oY/sY untouched - y unaffected
  }

  @Test
  void sync_shiftsAnAlreadyPlacedBoxByTheSameDeltaAsItsPin () {
    int[] row = app.addHoverPoint(190, 90, new float[]{ 250, 60 }); // box placed down-right of the pin
    app.worldHoverPointGeo.put(row, new float[]{ 10, 0 });

    app.WORLD.oX = -20; // same 20px rightward shift as the test above

    app.syncWorldHoverPointPositions();

    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(270, preferred[0], 0.0001f); // 250 + 20 - rode along with the pin
    assertEquals(60, preferred[1], 0.0001f); // y delta was 0 - untouched
  }

  @Test
  void sync_dropsAWorldPin_onceItsLocationPansOutsideTheViewWindow () {
    int[] row = app.addHoverPoint(190, 90);
    app.worldHoverPointGeo.put(row, new float[]{ 10, 0 });

    // Narrow the view window so lon=10 is no longer inside it - as if a
    // zoom/pan since the pin was placed moved it off the edge of the map.
    app.WORLD.viewWindowLon1 = -180;
    app.WORLD.viewWindowLon2 = 5;

    app.syncWorldHoverPointPositions();

    assertNull(app.allHoverPoints);
    assertTrue(app.worldHoverPointGeo.isEmpty());
    assertTrue(app.hoverPointPreferredPosition.isEmpty());
  }

  @Test
  void sync_dropsAWorldPin_whenItsProjectedPositionFallsOutsideWorldsOwnCanvas () {
    // Still inside the (wide-open) view window, but a tighter zoom (sX
    // shrunk well below 1, same as a real WORLD.draw() pass would set for
    // a more zoomed-in tile) now projects lon=170 well past dX's own
    // right edge - the same isInside(..., 0, 0, WORLD.dX, WORLD.dY) bound
    // addNearbyWorldStationCandidates() itself already checks before ever
    // treating a station as visible.
    int[] row = app.addHoverPoint(0, 0);
    app.worldHoverPointGeo.put(row, new float[]{ 170, 0 });

    app.WORLD.sX = 0.1f;

    app.syncWorldHoverPointPositions();

    assertNull(app.allHoverPoints);
  }

  @Test
  void sync_onlyDropsTheOneWorldPinThatWentOutOfView_leavingOthersInPlace () {
    int[] staysInView = app.addHoverPoint(190, 90); // lon=10
    app.worldHoverPointGeo.put(staysInView, new float[]{ 10, 0 });

    int[] goesOutOfView = app.addHoverPoint(0, 90); // lon=-180
    app.worldHoverPointGeo.put(goesOutOfView, new float[]{ -180, 0 });

    int[] plainScreenPin = app.addHoverPoint(300, 50); // never registered as WORLD-tracked

    app.WORLD.viewWindowLon1 = -5; // excludes lon=-180, keeps lon=10

    app.syncWorldHoverPointPositions();

    assertEquals(2, app.allHoverPoints.length);
    assertArrayEquals(new int[]{ 190, 90 }, app.allHoverPoints[0]);
    assertArrayEquals(new int[]{ 300, 50 }, app.allHoverPoints[1]); // the plain pin, untouched and still present
    assertFalse(app.worldHoverPointGeo.containsKey(goesOutOfView));
  }

  @Test
  void sync_doesNothingAtAll_whenTheProjectionHasNotActuallyChanged () {
    int[] row = app.addHoverPoint(190, 90, new float[]{ 250, 60 });
    app.worldHoverPointGeo.put(row, new float[]{ 10, 0 });

    app.syncWorldHoverPointPositions(); // nothing panned/zoomed since the pin was placed

    assertArrayEquals(new int[]{ 190, 90 }, app.allHoverPoints[0]);
    float[] preferred = app.hoverPointPreferredPosition.get(row);
    assertEquals(250, preferred[0], 0.0001f);
    assertEquals(60, preferred[1], 0.0001f);
  }
}
