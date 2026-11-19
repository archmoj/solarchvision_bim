import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeAll;
import static org.junit.jupiter.api.Assertions.*;

import java.util.ArrayList;
import java.util.List;

// CommandRegistryTest.java guards one half of the menu/action pairing:
// no two commands silently collide under the same registered key. This
// file guards the other half, found during a deliberate sweep for the
// same "two things that should stay in sync but don't" bug class that
// motivated Select3D's own clampSoftSelectionToCurrentData() fix - every
// leaf item actually printed in UI_menuBar's own Items table must
// resolve to a real, registered allActions entry, the exact same lookup
// runSelectedItem() (uiMenuBar.pde) performs for a real mouse click or
// Enter key. Before this file existed, nothing checked this directly:
// a typo'd or never-registered caption just silently did nothing when
// clicked - no exception, no test failure, nothing - which is exactly
// how "Select All Vertices" (registered as "Select All Verices", one
// letter short) and 4 of the 5 Modify > *Polylines commands (never
// registered under their own name at all - 2109-2133's own
// changeVisibilityPolylines_Scene()/_Selection()/reverseVisibility
// Polylines_Scene() in modify3D.pde sat fully implemented and already
// used internally by isolate_Selection(), but with no putAction of
// their own) went unnoticed. A 6th, subtler case this same sweep found:
// "Hide Selected Polylines" WAS reachable, but ran the WRONG handler -
// Select3D's own polyline-vertex-marker overlay toggle, registered
// under the identical literal caption the Modify menu also used for its
// own, unrelated geometry-visibility command. The exact bug
// CommandRegistryTest.java exists to catch for "Hide Selected Faces"
// (see that file's own header comment) recurred here unnoticed, because
// there was only ONE registration of the string, not two - nothing for
// its own duplicate-key scan to flag.
class MenuItemReachabilityTest {

  private static solarchvision_bim app;

  @BeforeAll
  static void setUp () {
    app = new solarchvision_bim();
    app.build_allActions();

    // globalVariables.pde's own field-initializer (`UI_menuBar UI_menuBar
    // = new UI_menuBar();`) runs - in field-declaration order - before
    // ___divider___'s own initializer does, so the Items table it builds
    // that first time around has a Java null in place of every divider
    // (buildMenuItems() reads ___divider___'s value at that moment, not
    // a live reference). Rebuilding now, with the whole app object (and
    // ___divider___ with it) fully constructed, is what the real app
    // does too - solarchvision_bim.pde's setup() independently calls
    // `UI_menuBar = new UI_menuBar();` a second time for the same
    // reason, replacing this exact stale first instance before the user
    // ever sees a menu.
    app.UI_menuBar.Items = app.UI_menuBar.buildMenuItems();
  }

  // Mirrors runSelectedItem()'s own lookup exactly (uiMenuBar.pde): just
  // toLowerCase(), no underscore substitution - putAction() registers
  // that exact form too (its own "withSpace" fallback), so this is
  // genuinely the same key a real click would look up, not an
  // approximation of it.
  private static String menuLookupKey (String caption) {
    return caption.toLowerCase();
  }

  @Test
  void everyMenuItemResolvesToARegisteredAction () {
    List<String> missing = new ArrayList<>();
    String[][] items = app.UI_menuBar.Items;

    for (int p = 0; p < items.length; p++) {
      String parentName = items[p][0];
      if (parentName.equals("About")) continue; // purely informational panel - title/author/URL, never meant to run anything

      for (int c = 1; c < items[p].length; c++) {
        String item = items[p][c];
        if (item.equals(app.___divider___)) continue;

        if (!app.allActions.containsKey(menuLookupKey(item))) {
          missing.add(parentName + " > " + item);
        }
      }
    }

    assertTrue(missing.isEmpty(),
      "Menu item(s) with no registered action - a silent no-op click, " +
      "exactly how \"Select All Vertices\"/the Modify>*Polylines commands " +
      "went unnoticed:\n" + missing);
  }

  // ================= the specific bugs this sweep found, pinned down ========
  // Narrower than the exhaustive scan above (which only proves a key
  // resolves to SOME action): each of these confirms the menu item's own
  // key reaches the SPECIFIC handler its caption promises, the same way
  // CommandRegistryTest's hideSelectedFacesEdges_actuallyTogglesSelect3D
  // FaceDisplayEdges() does for its own Faces pair.

  @Test
  void selectAllVertices_isReachableAndSelectsEveryVertex () {
    app.allVertices = new float[][]{{0,0,0},{1,1,1},{2,2,2}};
    app.currentObjectCategory = app.ObjectCategory.VERTEX;
    app.Select3D.vertexSelection = new int[0];

    app.allActions.get("select all vertices").run(new String[0]);

    assertArrayEquals(new int[]{0, 1, 2}, app.Select3D.vertexSelection);
  }

  @Test
  void selectAllTerrainVertices_isReachableAndSelectsEveryTerrainVertex () {
    app.Terrain.rowCount = 2;
    app.Terrain.columnCount = 3;
    app.currentObjectCategory = app.ObjectCategory.TERRAIN;
    app.Select3D.terrainVertexSelection = new int[0];

    app.allActions.get("select all terrain vertices").run(new String[0]);

    assertArrayEquals(new int[]{0, 1, 2, 3, 4, 5}, app.Select3D.terrainVertexSelection);
  }

  @Test
  void hideSelectedPolylines_actuallyHidesThePolylineGeometryNotTheVertexOverlay () {
    // The exact collision: must reach Modify3D.changeVisibilityPolylines_
    // Selection(0), never Select3D.polylineDisplayVertices.
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0, 0, 0}}; // [material, tessellation, layer, visibility, weight, close, curveType, isArc] - see Polylines' own getters/setters
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.Select3D.polylineSelection = new int[]{0};
    app.Select3D.polylineDisplayVertices = true; // must be left untouched by this command

    assertDoesNotThrow(() -> app.allActions.get("hide selected polylines").run(new String[0]));

    assertEquals(0, app.allPolylines.getVisibility(0), "the polyline geometry itself must now be hidden");
    assertTrue(app.Select3D.polylineDisplayVertices, "the vertex-marker overlay toggle must not be touched by this command");
  }

  @Test
  void unhideSelectedPolylines_isReachable () {
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0, 0, 0}};
    app.allPolylines.setVisibility(0, 0);
    app.currentObjectCategory = app.ObjectCategory.POLYLINE;
    app.Select3D.polylineSelection = new int[]{0};

    app.allActions.get("unhide selected polylines").run(new String[0]);

    assertEquals(1, app.allPolylines.getVisibility(0));
  }

  @Test
  void hideAllPolylines_isReachable () {
    app.allPolylines.nodes = new int[][]{{0, 1}, {1, 2}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0, 0, 0}};

    app.allActions.get("hide all polylines").run(new String[0]);

    assertEquals(0, app.allPolylines.getVisibility(0));
    assertEquals(0, app.allPolylines.getVisibility(1));
  }

  @Test
  void unhideAllPolylines_isReachable () {
    app.allPolylines.nodes = new int[][]{{0, 1}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0, 0, 0}};
    app.allPolylines.setVisibility(0, 0);

    app.allActions.get("unhide all polylines").run(new String[0]);

    assertEquals(1, app.allPolylines.getVisibility(0));
  }

  @Test
  void reverseVisibilityOfAllPolylines_isReachable () {
    app.allPolylines.nodes = new int[][]{{0, 1}, {1, 2}};
    app.allPolylines.options = new int[][]{{0, 0, 0, 0, 0, 0, 0, 0}, {0, 0, 0, 1, 0, 0, 0, 0}};

    app.allActions.get("reverse visibility of all polylines").run(new String[0]);

    assertEquals(1, app.allPolylines.getVisibility(0));
    assertEquals(0, app.allPolylines.getVisibility(1));
  }

  @Test
  void showHideSelectedPolylinesVertices_stillReachableUnderItsRenamedCaption () {
    app.Select3D.polylineDisplayVertices = true;

    app.allActions.get("hide selected polylines vertices").run(new String[0]);
    assertFalse(app.Select3D.polylineDisplayVertices);

    app.allActions.get("show selected polylines vertices").run(new String[0]);
    assertTrue(app.Select3D.polylineDisplayVertices);

    app.allActions.get("show/hide selected polylines vertices").run(new String[0]);
    assertFalse(app.Select3D.polylineDisplayVertices);
  }
}
