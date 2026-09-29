import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

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

    solarchvision_bim.WORLD fresh = app.new WORLD();
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

  // ================= keyPressed (top-level guard only) ===================
  // The rest of keyPressed(KeyEvent e) - the '`'/'~' zoom-cycle switch -
  // touches e.isAltDown()/e.isControlDown() unconditionally right after
  // this guard, so it isn't callable with a real event here without
  // constructing one (see test/README.md - no test in this suite
  // constructs a KeyEvent). The include guard itself is still safely
  // testable, since it returns before e is ever touched.

  @Test
  void keyPressed_doesNothingAndDoesNotTouchTheEventWhenIncludeIsFalse () {
    app.WORLD.include = false;
    assertDoesNotThrow(() -> app.WORLD.keyPressed(null));
  }

  // ================= handlePlainCharKey ===================================
  // Extracted out of keyPressed(KeyEvent) so the actual zoom-cycling logic
  // (previously only reachable through e.isAltDown()/isControlDown()) can
  // be exercised directly, the same way STUDY.pde's handlePlainCharKey() is.

  @Test
  void handlePlainCharKey_backtick_decrementsZoom () {
    app.WORLD.autoView = false; // keep FindGoodViewport() a no-op passthrough
    app.WORLD.Zoom = 5;
    app.key = '`';

    app.WORLD.handlePlainCharKey();

    assertEquals(4, app.WORLD.Zoom);
  }

  @Test
  void handlePlainCharKey_backtick_wrapsFrom0To9 () {
    app.WORLD.autoView = false;
    app.WORLD.Zoom = 0;
    app.key = '`';

    app.WORLD.handlePlainCharKey();

    assertEquals(9, app.WORLD.Zoom);
  }

  @Test
  void handlePlainCharKey_tilde_incrementsZoom () {
    app.WORLD.autoView = false;
    app.WORLD.Zoom = 5;
    app.key = '~';

    app.WORLD.handlePlainCharKey();

    assertEquals(6, app.WORLD.Zoom);
  }

  @Test
  void handlePlainCharKey_tilde_wrapsFrom9To0 () {
    app.WORLD.autoView = false;
    app.WORLD.Zoom = 9;
    app.key = '~';

    app.WORLD.handlePlainCharKey();

    assertEquals(0, app.WORLD.Zoom);
  }

  @Test
  void handlePlainCharKey_backtickThenTilde_roundTripsZoom () {
    app.WORLD.autoView = false;
    app.WORLD.Zoom = 5;

    app.key = '`';
    app.WORLD.handlePlainCharKey();
    app.key = '~';
    app.WORLD.handlePlainCharKey();

    assertEquals(5, app.WORLD.Zoom);
  }

  @Test
  void handlePlainCharKey_flagsWorldForRedraw () {
    app.WORLD.autoView = false;
    app.WORLD.update = false;
    app.key = '`';

    app.WORLD.handlePlainCharKey();

    assertTrue(app.WORLD.update);
  }

  @Test
  void handlePlainCharKey_ignoresAnyOtherCharacter () {
    app.WORLD.autoView = false;
    app.WORLD.Zoom = 5;
    app.key = 'a'; // not '`' or '~'

    app.WORLD.handlePlainCharKey();

    assertEquals(5, app.WORLD.Zoom);
  }
}
