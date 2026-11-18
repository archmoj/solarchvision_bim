import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;
import java.util.ArrayList;

// Covers mouseMapBindings.pde's own data layer - mouseMapBindings.pde's
// counterpart to KeyboardMapBindingsTest.java. Pure data/logic, no
// Processing graphics calls anywhere in this file, same reasoning as
// that file's own header comment.
class MouseMapBindingsTest {

  private solarchvision_bim app;

  @BeforeEach
  void setUp () {
    app = new solarchvision_bim();
  }

  @Test
  void buildMouseMapBindingsIfNeeded_isIdempotent () {
    app.buildMouseMapBindingsIfNeeded();
    ArrayList<String[]> first = app.mouseMapBindings;
    app.buildMouseMapBindingsIfNeeded();
    assertSame(first, app.mouseMapBindings, "a second call must not rebuild the table");
  }

  @Test
  void formatLine_joinsActionAndDescriptionWithAColon () {
    String line = app.mouseMapFormatLine(new String[]{"WORLD", "Left-click", "Pin the station list"});
    assertEquals("Left-click: Pin the station list", line);
  }

  @Test
  void describeViewport_world_coversHoverRightClickLeftClickDragAndScroll () {
    ArrayList<String> lines = app.mouseMapDescribeViewport("WORLD");
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Hover: ")));
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Right-click: ")));
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Left-click: ")));
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Drag: ")));
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Scroll: ")));
  }

  @Test
  void describeViewport_study_coversClickDragRightClickAndScroll () {
    ArrayList<String> lines = app.mouseMapDescribeViewport("STUDY");
    assertTrue(lines.contains("Left-click: Pin a hover point on the graph"));
    assertTrue(lines.contains("Drag: Pan the graph"));
    assertTrue(lines.contains("Right-click: Reset the graph's zoom and pan to the initial view"));
    assertTrue(lines.contains("Scroll: Zoom the graph in or out"));
  }

  @Test
  void describeViewport_win3d_includesTheGenericClickRowsAndEveryToolMode () {
    ArrayList<String> lines = app.mouseMapDescribeViewport("WIN3D");

    // The two mode-independent click rows.
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Left-click: ")));
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Right-click: ")));

    // A sampling of distinct tool modes, confirming "every mode,
    // enumerated" (not just whichever is "live") actually produced
    // separate rows for Left-drag/Right-drag/Scroll apiece - each mode
    // name must appear in parentheses on all three of its own lines.
    assertTrue(lines.contains("Left-drag (Terrain Orbit): Orbit the camera around the land"));
    assertTrue(lines.contains("Right-drag (Terrain Orbit): Pan"));
    assertTrue(lines.contains("Scroll (Terrain Orbit): Move toward wherever the mouse points"));

    assertTrue(lines.contains("Left-drag (Sky Dome Size): Orbit the camera"));
    assertTrue(lines.contains("Scroll (Sky Dome Size): Scale the sky dome"));

    assertTrue(lines.contains("Left-drag (All-Model Size): Orbit the camera"));
    assertTrue(lines.contains("Scroll (All-Model Size): Scale the whole model"));

    // Sky Dome Size and All-Model Size drag identically (both "Orbit the
    // camera" / "Pan") but must still be two SEPARATE mode rows, not
    // merged, because their Scroll behavior differs - the one merge this
    // table makes (Dist-to-Mouse / Pick Select, checked below) is the
    // only case where drag AND scroll both coincide.
    assertTrue(lines.contains("Left-drag (Dist-to-Mouse / Pick Select): Pan"));
    assertTrue(lines.contains("Right-drag (Dist-to-Mouse / Pick Select): Rotate the target"));
    assertTrue(lines.contains("Scroll (Dist-to-Mouse / Pick Select): Move toward wherever the mouse points"));
  }

  @Test
  void describeViewport_win3d_hasExactlyFiftyLines () {
    // 2 generic click rows + 16 tool modes * 3 (Left-drag/Right-drag/
    // Scroll) = 50 - a precise count so a future edit that silently
    // drops or duplicates a mode is caught immediately, not just the
    // sampling above.
    ArrayList<String> lines = app.mouseMapDescribeViewport("WIN3D");
    assertEquals(50, lines.size());
  }

  @Test
  void describeViewport_unknownViewport_returnsEmpty () {
    assertTrue(app.mouseMapDescribeViewport("NOPE").isEmpty());
  }

  @Test
  void everyRow_namesAKnownViewport () {
    app.buildMouseMapBindingsIfNeeded();
    for (String[] row : app.mouseMapBindings) {
      assertTrue(row[0].equals("WORLD") || row[0].equals("STUDY") || row[0].equals("WIN3D"),
          "unexpected viewport: " + row[0]);
    }
  }
}
