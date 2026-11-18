// Single source of truth for everything UI_mouseGuide.pde draws hover
// text for - mouseMapBindings.pde's own counterpart to
// keyboardMapBindings.pde, same "separate registry kept in sync by
// hand" reasoning (see that file's own header comment).
//
// One row per {viewport, action, description}:
// - viewport is "WORLD", "STUDY", or "WIN3D".
// - action is what the user does - "Hover", "Left-click", "Right-click",
//   "Left-drag", "Right-drag", "Scroll" - prefixed with a short mode name
//   in parentheses for WIN3D rows whose behavior depends on
//   User3D.currentTool (e.g. "Left-drag (Terrain Orbit)"), since WIN3D's
//   left/right-drag and scroll meaning genuinely changes with the active
//   camera-navigation tool (mouseDragged.pde's dispatchWin3DTaskDrag(),
//   mouseWheel.pde's handleViewportWheel()) - there is no single "what
//   does left-drag do" answer for WIN3D the way there is for WORLD/STUDY.
// - description is the resulting action, in plain English.
//
// Scope is deliberately camera/view NAVIGATION only - WIN3D's object-
// editing tool modes (Move, Scale, Rotate, Seed_Material, and the rest
// of uiTask.pde's own list past the navigation ones below) have their
// own separate mouse semantics entirely and are a different feature area,
// matching the README's own "Camera and view navigation" section
// boundary this table was built from.
//
// Each WIN3D "mode" row-group corresponds to exactly one distinguishable
// combination of drag behavior (dispatchWin3DTaskDrag()'s own branches)
// and scroll behavior (handleViewportWheel()'s own branches) - two
// internal tool constants are merged into one mode here only when BOTH
// their drag AND their scroll behavior are identical (DistMouseXY_.../
// PickSelect is the only such merge; every other internal tool constant
// that *shares* drag behavior with another - e.g. zoom_Orbit_Pan/
// SkydomeSize/AllModelSize all orbit-camera/pan on drag - still gets its
// own mode row here, because their scroll behavior differs).
ArrayList<String[]> mouseMapBindings = null;

void buildMouseMapBindingsIfNeeded () {
  if (mouseMapBindings != null) return;
  mouseMapBindings = new ArrayList<String[]>();

  String[][] fixed = {

    // --- WORLD (map - viewportMap.pde/mouseClicked.pde/mouseDragged.pde/mouseWheel.pde) ---
    {"WORLD", "Hover", "Show the short name of whichever weather/climate stations are nearby"},
    {"WORLD", "Right-click", "Set the project location here, and zoom in to confirm where it landed"},
    {"WORLD", "Left-click", "Pin the nearby-station list in place instead of it following the mouse"},
    {"WORLD", "Drag", "Pan the map (once zoomed in past the initial 1x/2x levels - handleWorldDrag())"},
    {"WORLD", "Scroll", "Zoom the map in or out"},

    // --- STUDY (hourly/probability graph - viewport2D.pde) ---
    {"STUDY", "Left-click", "Pin a hover point on the graph"},
    {"STUDY", "Drag", "Pan the graph"},
    {"STUDY", "Right-click", "Reset the graph's zoom and pan to the initial view"},
    {"STUDY", "Scroll", "Zoom the graph in or out"},

    // --- WIN3D (3D viewport) ---
    {"WIN3D", "Left-click", "Pin a hover point, or place an object on an existing 3D surface when an object type is selected"},
    {"WIN3D", "Right-click", "Pin a hover point, or place an object on the land surface when an object type is selected"},

    // Terrain Orbit (UITASK.TerrainOrbit_Pan_TargetRollZ)
    {"WIN3D", "Left-drag (Terrain Orbit)", "Orbit the camera around the land"},
    {"WIN3D", "Right-drag (Terrain Orbit)", "Pan"},
    {"WIN3D", "Scroll (Terrain Orbit)", "Move toward wherever the mouse points"},

    // Pan, X-locked (UITASK.PanX_TargetRoll)
    {"WIN3D", "Left-drag (Pan X-locked)", "Pan horizontally"},
    {"WIN3D", "Right-drag (Pan X-locked)", "Pan vertically"},
    {"WIN3D", "Scroll (Pan X-locked)", "Adjust the horizontal position"},

    // Pan, Y-locked (UITASK.PanY_TargetRoll)
    {"WIN3D", "Left-drag (Pan Y-locked)", "Pan vertically"},
    {"WIN3D", "Right-drag (Pan Y-locked)", "Pan horizontally"},
    {"WIN3D", "Scroll (Pan Y-locked)", "Adjust the vertical position"},

    // Pan / Rotate Target (UITASK.Pan_TargetRoll)
    {"WIN3D", "Left-drag (Pan / Rotate Target)", "Pan"},
    {"WIN3D", "Right-drag (Pan / Rotate Target)", "Rotate the target"},
    {"WIN3D", "Scroll (Pan / Rotate Target)", "Zoom in or out"},

    // Dist-to-Mouse / Pick Select (UITASK.DistMouseXY_TargetRollXY_TargetRollZ, UITASK.PickSelect - identical drag AND scroll, merged into one mode)
    {"WIN3D", "Left-drag (Dist-to-Mouse / Pick Select)", "Pan"},
    {"WIN3D", "Right-drag (Dist-to-Mouse / Pick Select)", "Rotate the target"},
    {"WIN3D", "Scroll (Dist-to-Mouse / Pick Select)", "Move toward wherever the mouse points"},

    // Camera Roll / Pan (UITASK.CameraRoll_Pan)
    {"WIN3D", "Left-drag (Camera Roll / Pan)", "Roll the camera"},
    {"WIN3D", "Right-drag (Camera Roll / Pan)", "Pan"},
    {"WIN3D", "Scroll (Camera Roll / Pan)", "Zoom in or out"},

    // Camera Distance (UITASK.CameraDistance_TargetRollXY_TargetRollZ)
    {"WIN3D", "Left-drag (Camera Distance)", "Roll the camera"},
    {"WIN3D", "Right-drag (Camera Distance)", "Pan"},
    {"WIN3D", "Scroll (Camera Distance)", "Move toward or away from the selection"},

    // Camera Roll, axis-split (UITASK.CameraRollXY_CameraRollZ)
    {"WIN3D", "Left-drag (Camera Roll axis-split)", "Roll the camera (XY)"},
    {"WIN3D", "Right-drag (Camera Roll axis-split)", "Roll the camera (Z)"},
    {"WIN3D", "Scroll (Camera Roll axis-split)", "Adjust whichever roll axis is active"},

    // Target Roll / Pan (UITASK.TargetRoll_Pan)
    {"WIN3D", "Left-drag (Target Roll / Pan)", "Rotate the target"},
    {"WIN3D", "Right-drag (Target Roll / Pan)", "Pan"},
    {"WIN3D", "Scroll (Target Roll / Pan)", "Zoom in or out"},

    // Target Roll, axis-split (UITASK.TargetRollXY_TargetRollZ)
    {"WIN3D", "Left-drag (Target Roll axis-split)", "Rotate the target (axis depends on which is active)"},
    {"WIN3D", "Right-drag (Target Roll axis-split)", "Rotate the target (the other axis)"},
    {"WIN3D", "Scroll (Target Roll axis-split)", "Adjust whichever target-roll axis is active"},

    // Orbit / Pan (UITASK.zoom_Orbit_Pan)
    {"WIN3D", "Left-drag (Orbit / Pan)", "Orbit the camera"},
    {"WIN3D", "Right-drag (Orbit / Pan)", "Pan"},
    {"WIN3D", "Scroll (Orbit / Pan)", "Zoom in or out"},

    // Sky Dome Size (UITASK.SkydomeSize)
    {"WIN3D", "Left-drag (Sky Dome Size)", "Orbit the camera"},
    {"WIN3D", "Right-drag (Sky Dome Size)", "Pan"},
    {"WIN3D", "Scroll (Sky Dome Size)", "Scale the sky dome"},

    // All-Model Size (UITASK.AllModelSize)
    {"WIN3D", "Left-drag (All-Model Size)", "Orbit the camera"},
    {"WIN3D", "Right-drag (All-Model Size)", "Pan"},
    {"WIN3D", "Scroll (All-Model Size)", "Scale the whole model"},

    // Height Pan (UITASK.Pan_Height)
    {"WIN3D", "Left-drag (Height Pan)", "Pan vertically (height)"},
    {"WIN3D", "Right-drag (Height Pan)", "Pan horizontally"},
    {"WIN3D", "Scroll (Height Pan)", "Adjust elevation"},

    // 3D Model Size (UITASK.ModelSize_Pan_TargetRoll)
    {"WIN3D", "Left-drag (3D Model Size)", "Pan"},
    {"WIN3D", "Right-drag (3D Model Size)", "Rotate the target"},
    {"WIN3D", "Scroll (3D Model Size)", "Scale selected objects"},

    // Truck / Orbit (UITASK.Truck_Orbit - further split by
    // User3D.toolParameterModifier/targetAxisIndex in
    // handleTruckOrbitTask()/handleTruckOrbitWheel(), compressed to one
    // mode here rather than enumerating all 4 sub-combinations)
    {"WIN3D", "Left-drag (Truck / Orbit)", "Pan or orbit along one axis, depending on the active Truck/Orbit and axis setting"},
    {"WIN3D", "Right-drag (Truck / Orbit)", "Pan or orbit along the other axis"},
    {"WIN3D", "Scroll (Truck / Orbit)", "Adjust whichever axis is active"},
  };
  for (String[] row : fixed) mouseMapBindings.add(row);
}

String mouseMapFormatLine (String[] row) {
  String action = row[1];
  String description = row[2];
  return action + ": " + description;
}

// Every binding for the given viewport ("WORLD", "STUDY", or "WIN3D"),
// in table order - what hovering that viewport's touchpad drawing shows
// in UI_mouseGuide.pde. Unlike keyboardMapDescribeModifier()'s
// aggregation (which only matches bindings that require a given
// modifier), this is a plain exact-match filter - viewport is already
// the precise lookup key, there's no combination logic needed.
ArrayList<String> mouseMapDescribeViewport (String viewport) {
  buildMouseMapBindingsIfNeeded();
  ArrayList<String> lines = new ArrayList<String>();
  for (String[] row : mouseMapBindings) {
    if (row[0].equals(viewport)) lines.add(mouseMapFormatLine(row));
  }
  return lines;
}
