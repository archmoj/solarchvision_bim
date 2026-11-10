import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

// Model2DsTest.java already exercises PEOPLE_KIND/TREES_KIND extensively,
// but only ever through Model2Ds (the placement class) using them -
// Model2DKind's own small, pure helper methods (indexOfFile(),
// filenameOf(), imageRatio(), model2DKindByTag()) and its two fixed
// per-family properties (isTree()/hasCanopyCap()/isScalable()) were
// never directly tested on their own. None of these need loadImages()
// (the one method here that actually touches disk/PImage) - Filenames/
// fileCount/ImageRatios are set directly instead, the same way
// Model2DsTest.java's own tests already set fileCount/Images directly
// rather than calling loadImages().
class Model2DKindTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= isTree() / hasCanopyCap() / isScalable() ============
  // Fixed per-family properties, not state - confirmed here directly
  // rather than only implied by Model2DsTest.java's own comment on one
  // of its own tests ("a kind's own isTree() is just a fixed property of
  // PEOPLE_KIND, not ...").

  @Test
  void peopleKind_isNeitherATreeNorScalable_andHasNoCanopyCap () {
    assertFalse(app.PEOPLE_KIND.isTree());
    assertFalse(app.PEOPLE_KIND.hasCanopyCap());
    assertFalse(app.PEOPLE_KIND.isScalable());
  }

  @Test
  void treesKind_isATreeAndScalable_andHasACanopyCap () {
    assertTrue(app.TREES_KIND.isTree());
    assertTrue(app.TREES_KIND.hasCanopyCap());
    assertTrue(app.TREES_KIND.isScalable());
  }

  @Test
  void treesKindsTag_isTREES_peopleKindsTag_isPEOPLE () {
    // The tag string itself - matches Model2Ds.create()'s own `t`
    // parameter and the scripting commands (Person/Tree2/Tree1) - see
    // this class's own field comment.
    assertEquals("TREES", app.TREES_KIND.tag);
    assertEquals("PEOPLE", app.PEOPLE_KIND.tag);
  }

  // ================= indexOfFile() ========================================

  @Test
  void indexOfFile_returnsTheOneBasedIndex_ofAMatchingFilename () {
    app.TREES_KIND.Filenames = new String[]{ "oak.png", "pine.png", "birch.png" };
    app.TREES_KIND.fileCount = 3;

    assertEquals(1, app.TREES_KIND.indexOfFile("oak.png"));
    assertEquals(2, app.TREES_KIND.indexOfFile("pine.png"));
    assertEquals(3, app.TREES_KIND.indexOfFile("birch.png"));
  }

  @Test
  void indexOfFile_returnsZero_forAFilenameThatIsNotThere () {
    // The graceful "not found" fallback this.from_XML() relies on for a
    // file that's since been renamed or deleted (see this class's own
    // comment) - rather than throwing.
    app.TREES_KIND.Filenames = new String[]{ "oak.png" };
    app.TREES_KIND.fileCount = 1;

    assertEquals(0, app.TREES_KIND.indexOfFile("maple.png"));
  }

  @Test
  void indexOfFile_onAFreshKindWithNoFilesLoaded_returnsZero () {
    // fileCount defaults to 0 (loadImages() never called) - the loop
    // itself never runs, same not-found result as a genuine miss above.
    assertEquals(0, app.TREES_KIND.indexOfFile("anything.png"));
  }

  // ================= filenameOf() =========================================

  @Test
  void filenameOf_returnsTheFilename_atAValidOneBasedIndex () {
    app.TREES_KIND.Filenames = new String[]{ "oak.png", "pine.png" };
    app.TREES_KIND.fileCount = 2;

    assertEquals("oak.png", app.TREES_KIND.filenameOf(1));
    assertEquals("pine.png", app.TREES_KIND.filenameOf(2));
  }

  @Test
  void filenameOf_returnsEmptyString_forAnOutOfBoundsIndex () {
    app.TREES_KIND.Filenames = new String[]{ "oak.png" };
    app.TREES_KIND.fileCount = 1;

    assertEquals("", app.TREES_KIND.filenameOf(0));
    assertEquals("", app.TREES_KIND.filenameOf(-1));
    assertEquals("", app.TREES_KIND.filenameOf(2)); // one past fileCount
  }

  // ================= imageRatio() =========================================
  // The safe accessor every caller now goes through instead of reading
  // ImageRatios[n] directly (this class's own comment) - "ratio unknown"
  // defaults to 1 (square) in every case below, not an exception.

  @Test
  void imageRatio_returnsOne_whenImageRatiosHasNeverBeenPopulated () {
    // loadImages() never called - exactly the "a unit test building a
    // kind by hand" case this method's own comment calls out by name.
    assertNull(app.TREES_KIND.ImageRatios, "sanity check, not the point of this test");

    assertEquals(1f, app.TREES_KIND.imageRatio(1), 0.0001f);
  }

  @Test
  void imageRatio_returnsTheRealRatio_whenPopulatedAndInBounds () {
    app.TREES_KIND.ImageRatios = new float[]{ 0, 1.5f, 0.75f }; // index 0 left unused, by convention

    assertEquals(1.5f, app.TREES_KIND.imageRatio(1), 0.0001f);
    assertEquals(0.75f, app.TREES_KIND.imageRatio(2), 0.0001f);
  }

  @Test
  void imageRatio_returnsOne_forAnOutOfBoundsIndex_evenWhenPopulated () {
    app.TREES_KIND.ImageRatios = new float[]{ 0, 1.5f };

    assertEquals(1f, app.TREES_KIND.imageRatio(-1), 0.0001f);
    assertEquals(1f, app.TREES_KIND.imageRatio(2), 0.0001f); // one past the array's own length
  }

  // ================= model2DKindByTag() ===================================

  @Test
  void model2DKindByTag_resolvesEachRealTagToItsOwnSingleton () {
    assertSame(app.PEOPLE_KIND, app.model2DKindByTag("PEOPLE"));
    assertSame(app.TREES_KIND, app.model2DKindByTag("TREES"));
  }

  @Test
  void model2DKindByTag_fallsBackToPeopleKind_forAnUnrecognizedTag () {
    // The defensive fallback this method's own comment describes - e.g.
    // a project file written by a newer build with a kind this one
    // doesn't know about yet - rather than throwing or returning null.
    assertSame(app.PEOPLE_KIND, app.model2DKindByTag("SHRUBS"));
    assertSame(app.PEOPLE_KIND, app.model2DKindByTag(""));
  }
}
