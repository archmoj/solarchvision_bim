import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Exercises solarchvision_WORLD (WORLD.pde), reached through the
// pre-constructed `app.WORLD` field. This is the flat 2D world-map
// overview window (distinct from WIN3D's 3D viewport).
//
// NOT covered: listAllImages()/loadImages()/getTileImage() - real file
// system access (OPESYS.getFiles, loadImage) against a real map-tile
// folder this checkout doesn't have. drawZoomedTiles()/drawMarker()/
// drawLabel()/beginMarkerBatch()/addMarkerToBatch()/endMarkerBatch()/
// drawStationDataset()/drawView()/keyPressed() - all real rendering
// (this.graphics calls) or, for keyPressed(), trivial glue around
// FindGoodViewport()+revise() gated on a real KeyEvent's modifier keys,
// which FindGoodViewport() below already covers more directly.
// FindGoodViewport() IS covered, with autoView=true set up so the
// found viewport always matches the starting VIEW_id - deliberately
// avoiding the one case (a genuinely different viewport being found)
// that would trigger loadImages()'s real file read.
//
// A fresh `app` per test since these mutate shared scene state.
class WORLDTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= resetPan / revise / updated ========================

  @Test
  void resetPan_zerosBothPanOffsets () {
    app.WORLD.panOffsetLon = 5;
    app.WORLD.panOffsetLat = -3;
    app.WORLD.resetPan();
    assertEquals(0f, app.WORLD.panOffsetLon, 0.0001f);
    assertEquals(0f, app.WORLD.panOffsetLat, 0.0001f);
  }

  @Test
  void reviseThenUpdated_toggleTheUpdateFlag () {
    app.WORLD.update = false;
    app.WORLD.revise();
    assertTrue(app.WORLD.update);
    app.WORLD.updated();
    assertFalse(app.WORLD.update);
  }

  // ================= hideAllMarkersAndLabels ============================

  @Test
  void hideAllMarkersAndLabels_clearsEveryDatasetsDisplayFlags () {
    app.WORLD.displayAll_SWOB = 2;
    app.WORLD.displayNear_SWOB = true;
    app.WORLD.displayAll_TMYEPW = 1;
    app.WORLD.displayNear_TMYEPW = true;

    app.WORLD.hideAllMarkersAndLabels();

    assertEquals(0, app.WORLD.displayAll_SWOB);
    assertFalse(app.WORLD.displayNear_SWOB);
    assertEquals(0, app.WORLD.displayAll_TMYEPW);
    assertFalse(app.WORLD.displayNear_TMYEPW);
  }

  // ================= projX / projY / isWithinView =======================

  @Test
  void projXAndProjY_mapLonLatToPixelSpace () {
    app.WORLD.dX = 360;
    app.WORLD.dY = 180;
    app.WORLD.oX = 0;
    app.WORLD.oY = 0;
    app.WORLD.sX = 1;
    app.WORLD.sY = 1;

    assertEquals(180f, app.WORLD.projX(0), 0.001f);  // lon 0 -> center of the 360-wide image
    assertEquals(360f, app.WORLD.projX(180), 0.001f); // lon 180 -> right edge
    assertEquals(90f, app.WORLD.projY(0), 0.001f);   // lat 0 -> vertical center
    assertEquals(0f, app.WORLD.projY(90), 0.001f);   // lat 90 (north) -> top (Y flipped)
  }

  @Test
  void isWithinView_checksAgainstTheCurrentViewWindowNotVIEWidsBounds () {
    app.WORLD.viewWindowLon1 = -10;
    app.WORLD.viewWindowLon2 = 10;
    app.WORLD.viewWindowLat1 = -5;
    app.WORLD.viewWindowLat2 = 5;

    assertTrue(app.WORLD.isWithinView(0, 0));
    assertFalse(app.WORLD.isWithinView(20, 0));
    assertFalse(app.WORLD.isWithinView(0, 20));
  }

  // ================= FindGoodViewport ===================================

  @Test
  void findGoodViewport_returnsTheCurrentViewIdUnchangedWhenAutoViewIsOff () {
    app.WORLD.autoView = false;
    app.WORLD.VIEW_id = 3;

    int result = app.WORLD.FindGoodViewport(0, 0);

    assertEquals(3, result);
  }

  @Test
  void findGoodViewport_picksTheContainingTileWithoutTriggeringARealImageLoad () {
    // Set up a single "E"-prefixed tile (matching Zoom 5-9) that
    // comfortably contains the test point, at index 0 - matching the
    // starting VIEW_id, so FindGoodViewport's "found a different
    // viewport" branch (which calls the real loadImages()) never fires.
    app.WORLD.numMaps = 1;
    app.WORLD.VIEW_Filenames = new String[]{"E_tile.jpg"};
    app.WORLD.VIEW_BoundariesX = new float[][]{{-10, 10}};
    app.WORLD.VIEW_BoundariesY = new float[][]{{-10, 10}};
    app.WORLD.Zoom = 5;
    app.WORLD.autoView = true;
    app.WORLD.VIEW_id = 0;

    int result = app.WORLD.FindGoodViewport(0, 0);

    assertEquals(0, result);
  }

  @Test
  void findGoodViewport_ignoresTilesWhosePrefixDoesNotMatchTheCurrentZoom () {
    app.WORLD.numMaps = 1;
    app.WORLD.VIEW_Filenames = new String[]{"A_tile.jpg"}; // "A" is for Zoom 1, not 5
    app.WORLD.VIEW_BoundariesX = new float[][]{{-10, 10}};
    app.WORLD.VIEW_BoundariesY = new float[][]{{-10, 10}};
    app.WORLD.Zoom = 5;
    app.WORLD.autoView = true;
    app.WORLD.VIEW_id = 0;

    int result = app.WORLD.FindGoodViewport(0, 0);

    assertEquals(0, result); // no "E" candidate matched, so VIEW_id (0) is returned unchanged
  }

  // ================= to_XML / from_XML round trip ======================

  @Test
  void toXMLThenFromXML_roundTripsEveryField () {
    app.WORLD.Zoom = 3;
    app.WORLD.displayAll_SWOB = 2;
    app.WORLD.displayAll_NAEFS = 1;
    app.WORLD.displayAll_CWEEDS = 2;
    app.WORLD.displayAll_CLMREC = 1;
    app.WORLD.displayAll_TMYEPW = 0;
    app.WORLD.displayNear_SWOB = true;
    app.WORLD.displayNear_NAEFS = false;
    app.WORLD.displayNear_CWEEDS = true;
    app.WORLD.displayNear_CLMREC = false;
    app.WORLD.displayNear_TMYEPW = true;

    processing.data.XML root = new processing.data.XML("root");
    app.WORLD.to_XML(root);

    solarchvision_bim.solarchvision_WORLD fresh = app.new solarchvision_WORLD();
    fresh.from_XML(root);

    assertEquals(3, fresh.Zoom);
    assertEquals(2, fresh.displayAll_SWOB);
    assertEquals(1, fresh.displayAll_NAEFS);
    assertEquals(2, fresh.displayAll_CWEEDS);
    assertEquals(1, fresh.displayAll_CLMREC);
    assertEquals(0, fresh.displayAll_TMYEPW);
    assertTrue(fresh.displayNear_SWOB);
    assertFalse(fresh.displayNear_NAEFS);
    assertTrue(fresh.displayNear_CWEEDS);
    assertFalse(fresh.displayNear_CLMREC);
    assertTrue(fresh.displayNear_TMYEPW);
  }
}
