import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import processing.data.XML;

// Every to_XML()/from_XML() pair in this codebase goes through these
// wrappers hundreds of times over (this suite's own save/load tests -
// SaveProjectTest.java, LoadProjectTest.java, SaveLoadSectionTexturesTest.
// java - already exercise the "tag present" path heavily that way), but
// never the one behavior that's actually easy to get wrong here: what
// each one does for a tag that was never written at all. The four
// XML_get*() wrappers turn out to disagree with each other in that
// exact case (confirmed directly against the real compiled app, not
// assumed from Processing's own docs) - XML_getBoolean() in particular
// only avoids a NullPointerException here because Boolean.parseBoolean()
// itself tolerates a null argument.
class XmlHelpersTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  // ================= missing-tag defaults =================================

  @Test
  void xmlGetString_onAMissingTag_returnsNull () {
    XML root = new XML("root");

    assertNull(app.XML_getString(root, "missing"));
  }

  @Test
  void xmlGetFloat_onAMissingTag_returnsZero () {
    XML root = new XML("root");

    assertEquals(0f, app.XML_getFloat(root, "missing"), 0.0001f);
  }

  @Test
  void xmlGetInt_onAMissingTag_returnsZero () {
    XML root = new XML("root");

    assertEquals(0, app.XML_getInt(root, "missing"));
  }

  @Test
  void xmlGetBoolean_onAMissingTag_returnsFalse_ratherThanThrowing () {
    // XML_getBoolean() reads the tag as a string (XML.getString(), which
    // is null when the tag is missing - see xmlGetString_... above) and
    // passes that straight to Boolean.parseBoolean(), which treats a
    // null argument the same as any other non-"true" string: false,
    // not a NullPointerException.
    XML root = new XML("root");

    assertEquals(Boolean.FALSE, app.XML_getBoolean(root, "missing"));
  }

  @Test
  void xmlGetContent_onAFreshElementWithNoContentEverSet_returnsEmptyString_notNull () {
    // Distinct from the missing-TAG defaults just above: this is a
    // child element itself, read before anything ever called
    // XML_setContent() on it - confirmed to come back "" rather than
    // null, unlike XML_getString()'s own missing-attribute default.
    XML child = new XML("child");

    assertEquals("", app.XML_getContent(child));
  }

  // ================= round trip (set then get) =============================

  @Test
  void xmlSetAndGetFloat_roundTrips () {
    XML root = new XML("root");

    app.XML_setFloat(root, "f", 3.5f);

    assertEquals(3.5f, app.XML_getFloat(root, "f"), 0.0001f);
  }

  @Test
  void xmlSetAndGetInt_roundTrips () {
    XML root = new XML("root");

    app.XML_setInt(root, "i", 7);

    assertEquals(7, app.XML_getInt(root, "i"));
  }

  @Test
  void xmlSetAndGetString_roundTrips () {
    XML root = new XML("root");

    app.XML_setString(root, "s", "hello");

    assertEquals("hello", app.XML_getString(root, "s"));
  }

  @Test
  void xmlSetAndGetContent_roundTrips () {
    XML child = new XML("child");

    app.XML_setContent(child, "some text");

    assertEquals("some text", app.XML_getContent(child));
  }

  @Test
  void xmlSetAndGetBoolean_roundTripsBothTrueAndFalse () {
    // XML_setBoolean() stores it as the literal string "true"/"false"
    // (Boolean.toString()) rather than through XML.setBoolean() itself -
    // confirming both directions actually agree with each other, not
    // just that "true" happens to work.
    XML root = new XML("root");

    app.XML_setBoolean(root, "bTrue", true);
    app.XML_setBoolean(root, "bFalse", false);

    assertEquals(Boolean.TRUE, app.XML_getBoolean(root, "bTrue"));
    assertEquals(Boolean.FALSE, app.XML_getBoolean(root, "bFalse"));
  }
}
