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

  // ================= mouseMapZoneForAction() / mouseMapDescribeViewportZone() ================
  // Covers the per-button hover filtering UI_mouseGuide.pde's draw() now
  // applies - introduced alongside the illustration's own left/middle/
  // right-click button row and recentered scroll wheel.

  @Test
  void zoneForAction_leftPrefixed_isLEFT () {
    assertEquals("LEFT", app.mouseMapZoneForAction("Left-click"));
    assertEquals("LEFT", app.mouseMapZoneForAction("Left-drag (Terrain Orbit)"));
  }

  @Test
  void zoneForAction_rightPrefixed_isRIGHT () {
    assertEquals("RIGHT", app.mouseMapZoneForAction("Right-click"));
    assertEquals("RIGHT", app.mouseMapZoneForAction("Right-drag (Terrain Orbit)"));
  }

  @Test
  void zoneForAction_scrollPrefixed_isSCROLL () {
    assertEquals("SCROLL", app.mouseMapZoneForAction("Scroll"));
    assertEquals("SCROLL", app.mouseMapZoneForAction("Scroll (Terrain Orbit)"));
  }

  @Test
  void zoneForAction_hoverOrPlainDrag_isGENERAL () {
    assertEquals("GENERAL", app.mouseMapZoneForAction("Hover"));
    assertEquals("GENERAL", app.mouseMapZoneForAction("Drag"));
  }

  @Test
  void describeViewportZone_world_left_isOnlyTheLeftClickRow () {
    ArrayList<String> lines = app.mouseMapDescribeViewportZone("WORLD", "LEFT");
    assertEquals(1, lines.size());
    assertTrue(lines.get(0).startsWith("Left-click: "));
  }

  @Test
  void describeViewportZone_world_right_isOnlyTheRightClickRow () {
    ArrayList<String> lines = app.mouseMapDescribeViewportZone("WORLD", "RIGHT");
    assertEquals(1, lines.size());
    assertTrue(lines.get(0).startsWith("Right-click: "));
  }

  @Test
  void describeViewportZone_world_scroll_isOnlyTheScrollRow () {
    ArrayList<String> lines = app.mouseMapDescribeViewportZone("WORLD", "SCROLL");
    assertEquals(1, lines.size());
    assertTrue(lines.get(0).startsWith("Scroll: "));
  }

  @Test
  void describeViewportZone_world_general_isHoverAndDragOnly () {
    ArrayList<String> lines = app.mouseMapDescribeViewportZone("WORLD", "GENERAL");
    assertEquals(2, lines.size());
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Hover: ")));
    assertTrue(lines.stream().anyMatch(l -> l.startsWith("Drag: ")));
  }

  @Test
  void describeViewportZone_middle_isAlwaysEmpty_noMiddleClickBindingExistsAnywhere () {
    assertTrue(app.mouseMapDescribeViewportZone("WORLD", "MIDDLE").isEmpty());
    assertTrue(app.mouseMapDescribeViewportZone("STUDY", "MIDDLE").isEmpty());
    assertTrue(app.mouseMapDescribeViewportZone("WIN3D", "MIDDLE").isEmpty());
  }

  @Test
  void describeViewportZone_win3d_left_and_right_matchEveryModesOwnDragRowPlusTheGenericClick () {
    // 1 generic "Left-click" + 16 modes' own "Left-drag (...)" = 17.
    ArrayList<String> left = app.mouseMapDescribeViewportZone("WIN3D", "LEFT");
    assertEquals(17, left.size());
    ArrayList<String> right = app.mouseMapDescribeViewportZone("WIN3D", "RIGHT");
    assertEquals(17, right.size());
  }

  @Test
  void describeViewportZone_win3d_scroll_matchesEveryModesOwnScrollRow () {
    // 16 modes * 1 "Scroll (...)" row apiece = 16; WIN3D has no generic
    // unprefixed "Scroll" row of its own (every WIN3D scroll binding is
    // mode-specific).
    ArrayList<String> scroll = app.mouseMapDescribeViewportZone("WIN3D", "SCROLL");
    assertEquals(16, scroll.size());
  }

  @Test
  void zonePartition_everyRowForAViewport_landsInExactlyOneOfTheFourRealZones () {
    // LEFT + RIGHT + SCROLL + GENERAL must account for every row - this
    // is the same "the split covers the whole set, nothing falls
    // through" property check mergeCoplanar's own selection-preservation
    // fix cared about, just for a classification instead of a deletion.
    for (String viewport : new String[]{"WORLD", "STUDY", "WIN3D"}) {
      int whole = app.mouseMapDescribeViewport(viewport).size();
      int partitioned = app.mouseMapDescribeViewportZone(viewport, "LEFT").size()
          + app.mouseMapDescribeViewportZone(viewport, "RIGHT").size()
          + app.mouseMapDescribeViewportZone(viewport, "SCROLL").size()
          + app.mouseMapDescribeViewportZone(viewport, "GENERAL").size();
      assertEquals(whole, partitioned, viewport + ": zone split must account for every binding");
    }
  }
}
