class solarchvision_UI_menuBar {

  private final static String CLASS_STAMP = "UI_menuBar";

  // ---------------------------------------------------------------------
  // Layout / interaction state
  // ---------------------------------------------------------------------

  boolean update = true;

  float width_parent = 7 * MessageSize;
  float width_child = width_parent; // i.e. minimum size

  int selected_parent = -1;
  int selected_child = 0;

  // ---------------------------------------------------------------------
  // Layout constants
  // ---------------------------------------------------------------------

  private static final float PARENT_TEXT_SIZE_FACTOR = 1.25;
  private static final float CHILD_ROW_HEIGHT_FACTOR = 0.85;
  private static final float CHILD_WIDTH_PER_CHAR = 0.55;
  private static final char DIVIDER_MARK = '—';

  private static final int HOVER_COLOR_R = 255;
  private static final int HOVER_COLOR_G = 127;
  private static final int HOVER_COLOR_B = 0;

  // ---------------------------------------------------------------------
  // Menu data
  // ---------------------------------------------------------------------

  String[][] Items;

  private int LayersID_in_Bar;

  // Looks up whether a given menu item should be drawn "greyed out"
  // (i.e. the feature it toggles is currently hidden/off). Uses the
  // JDK's own java.util.function.BooleanSupplier (a top-level type)
  // rather than a custom nested interface: Processing classes are
  // non-static inner classes of the sketch, and older Java versions
  // don't allow declaring a (implicitly static) member interface
  // inside a non-static inner class.
  private HashMap<String, java.util.function.BooleanSupplier> disabledStateByItem;

  solarchvision_UI_menuBar () { // constructor
    this.Items = buildMenuItems();
    populateLayerMenu();
    this.disabledStateByItem = buildDisabledStateLookup();
  }

  // ---------------------------------------------------------------------
  // Data setup
  // ---------------------------------------------------------------------

  private String[][] buildMenuItems() {
    return new String[][] {
    {
      "About",
      "SOLARCHVISION-BIM6D",
      "Designed & developed by",
      "Mojtaba Samimi",
      "www.solarchvision.com"
    }
    ,
    {
      "File",
      "New",
      "Open...",
      "——————————————————",
      "Import 3D-model...",
      "Import Command File...",
      "——————————————————",
      "Hold",
      "Fetch",
      "——————————————————",
      "Save",
      "Save As...",
      "——————————————————",
      "Export 3D-model > SCR",
      "Export 3D-model > RAD",
      "Export 3D-model > HTML",
      "Export 3D-model > OBJ",
      "Export 3D-model > OBJ (date-series)",
      "Export 3D-model > OBJ (time-series)",
      "——————————————————",
      "Quit"
    }
    ,
    {
      "Tools",
      "JPG Time Graph",
      "PDF Time Graph",
      "JPG Location Graph",
      "PDF Location Graph",
      "JPG 3D Graph",
      "JPG 3D Full-Period",
      "——————————————————",
      "Screenshot",
      "Screenshot+Click",
      "Screenshot+Drag",
      "——————————————————",
      "REC. Time Graph",
      "REC. Location Graph",
      "REC. Solid Graph",
      "REC. Screenshot",
      "Stop REC.",
      "——————————————————",
      "Add People on Land",
      "Add 2D-Trees on Land",
      "Add 1D-Trees on Land",
      "——————————————————",
      "Clone Selection (Identical)",
      "Clone Selection (Variation)",
      "——————————————————",
      "Delete Selection",
      "Delete Scene Empty Groups",
      "Delete Scene Isolated Vertices",
      "Delete Selection Isolated Vertices",
      "Delete All Model1Ds",
      "Delete All Model2Ds",
      "Delete All Groups",
      "Delete All Solids",
      "Delete All Sections",
      "Delete All Cameras",
      "Delete All Faces",
      "Delete All Polylines",
      "Delete All"
    }
    ,
    {
      "Location",
      "Update Station",
      "———————————————",
      "Use typical year (TMY)",
      "Use long-term (CWEEDS)",
      "Use long-term (CLMREC)",
      "Use real-time observed (SWOB)",
      "Use weather forecast (NAEFS)",
      "———————————————",
      "Update TMYEPW",
      "Update CWEEDS",
      "Update CLMREC",
      "Update SWOB",
      "Update NAEFS",
      "———————————————",
      "Load Toroposphere",
      "Load Land Mesh",
      "Load Land Texture",
      "Download Land Mesh",
      "Download Land Texture",
      "———————————————",
      "Download NAEFS",
      "Download SWOB",
      "Download CLMREC",
      "———————————————",
      "Show/Hide TMYEPW stations",
      "Show/Hide TMYEPW nearest",
      "Show/Hide CWEEDS stations",
      "Show/Hide CWEEDS nearest",
      "Show/Hide CLMREC stations",
      "Show/Hide CLMREC nearest",
      "Show/Hide SWOB stations",
      "Show/Hide SWOB nearest",
      "Show/Hide NAEFS stations",
      "Show/Hide NAEFS nearest"
    }
    ,
    {
      "Setup",
      "Display All Viewports",
      "Enlarge 3D Viewport",
      "Enlarge Map Viewport",
      "Enlarge Time Viewport",
      "——————————",
      "Layout -2",
      "Layout -1",
      "Layout 0",
      "Layout 1",
      "Layout 2",
      "Layout 3",
      "Layout 4",
      "Layout 5",
      "Layout 6",
      "Layout 7",
      "Layout 8",
      "——————————",
      "3D-model 1",
      "3D-model 2",
      "3D-model 3",
      "3D-model 4",
      "3D-model 5",
      "3D-model 6",
      "3D-model 7",
      "3D-model 8",
      "3D-model 9",
      "3D-model 10",
      "3D-model 11"
    }
    ,
    {
      "Layer"
      // Parameters are added here later in the process.
    }
    ,
    {
      "Analysis",
      "Wind pattern (active)",
      "Wind pattern (passive)",
      "————————————————",
      "Orientation potential (active)",
      "Orientation potential (passive)",
      "————————————————",
      "Hourly sun position (active)",
      "Hourly sun position (passive)",
      "————————————————",
      "Annual cycle sun path (active)",
      "Annual cycle sun path (passive)",
      "————————————————",
      "Urban solar potential (active)",
      "Urban solar potential (passive)",
      "————————————————",
      "Shade Viewport",
      "————————————————",
      "Prebake Viewport",
      "Prebake Selected Sections",
      "————————————————",
      "Process Active Impact",
      "Process Passive Impact",
      "————————————————",
      "Process Solid Impact",
      "Run wind 3D-model"
    }
    ,
    {
      "3D-shade",
      "Active Shade",
      "Passive Shade",
      "————————————",
      "Shade Surface Wire",
      "Shade Surface Base",
      "Shade Surface White",
      "Shade Surface Materials",
      "————————————",
      "Shade Global Solar",
      "Shade Vertex Solar",
      "————————————",
      "Shade Vertex Solid",
      "Shade Vertex Elevation"
    }
    ,
    {
      "3D-view",
      "Viewport >> Camera",
      "Camera >> Viewport",
      "—————————",
      "Camera View",
      "—————————",
      "Top",
      "Front",
      "Left",
      "Back",
      "Right",
      "Bottom",
      "S.W.",
      "S.E.",
      "N.E.",
      "N.W.",
      "—————————",
      "Perspective",
      "Orthographic",
      "—————————",
      "Zoom",
      "Zoom as default",
      "Look at origin",
      "Look at direction",
      "Look at selection",
      "Pan",
      "PanX",
      "PanY",
      "LandOrbit",
      "Orbit",
      "OrbitXY",
      "OrbitZ",
      "CameraRoll",
      "CameraRollXY",
      "CameraRollZ",
      "TargetRoll",
      "TargetRollXY",
      "TargetRollZ",
      "TruckX",
      "TruckY",
      "TruckZ",
      "DistZ",
      "DistMouseXY",
      "CameraDistance",
      "3DModelSize",
      "SkydomeSize"
    }
    ,
    {
      "3D-display",
      "Show/Hide Land Mesh",
      "Show/Hide Land Texture",
      "Show/Hide Land Points",
      "Show/Hide Land Depth",
      "Show/Hide Vertices",
      "Show/Hide Edges",
      "Show/Hide Normals",
      "Show/Hide Leaves",
      "Show/Hide Model1Ds",
      "Show/Hide Model2Ds",
      "Show/Hide Polylines",
      "Show/Hide Faces",
      "Show/Hide Solids",
      "Show/Hide Cameras",
      "Show/Hide Sections",
      "Show/Hide Sky",
      "Show/Hide Sun Grid",
      "Show/Hide Sun Path",
      "Show/Hide Sun Pattern",
      "Show/Hide Sun Surface",
      "Show/Hide Moon Surface",
      "Show/Hide Troposphere",
      "Show/Hide Earth Surface",
      "Show/Hide Solar Section",
      "Show/Hide Solid Section",
      "Show/Hide Wind Flow",
      "Show/Hide Selected Solids",
      "Show/Hide Selected Sections",
      "Show/Hide Selected Cameras",
      "Show/Hide Selected LandPoints",
      "Show/Hide Selected Faces",
      "Show/Hide Selected Faces Vertex Count",
      "Show/Hide Selected Polylines Vertex Count",
      "Show/Hide Selected Vertices",
      "Show/Hide Selected REF Pivot",
      "Show/Hide Selected Group Pivot",
      "Show/Hide Selected Group Edges",
      "Show/Hide Selected Group Box",
      "Show/Hide Selected 2D Edges",
      "Show/Hide Selected 1D Edges",
    }
    ,
    {
      "3D-create",
      "Begin New Group at Origin",
      "Begin New Group at Pivot",
      "—————————————",
      "Section",
      "Camera",
      "—————————————",
      "1D-Tree",
      "2D-Tree",
      "Person",
      "—————————————",
      "Box",
      "Cushion",
      "Cylinder",
      "Sphere",
      "Octahedron",
      "Icosahedron",
      "Pyramid",
      "Hyper",
      "Plane",
      "Surface",
      "Polygon",
      "Extrude",
      "—————————————",
      "House1",
      "House2",
      "House3",
      "—————————————",
      "Parametric 1",
      "Parametric 2",
      "Parametric 3",
      "Parametric 4",
      "Parametric 5",
      "Parametric 6",
      "—————————————",
      "Solid",
      "Point",
      "Polyline",
      "—————————————",
      "LandMesh >> Group",
      "LandGap >> Group"
    }
    ,
    {
      "3D-select",
      "Pick Select",
      "Pick Select+",
      "Pick Select-",
      "———————————————",
      "Window Select",
      "Window Select+",
      "Window Select-",
      "———————————————",
      "Select Section",
      "Select Camera",
      "Select Group",
      "Select Solid",
      "Select Model1Ds",
      "Select Model2Ds",
      "Select Polyline",
      "Select Face",
      "Select Vertex",
      "Select LandPoint",
      "———————————————",
      "Soft Selection",
      "Invert Selection",
      "Deselect All",
      "———————————————",
      "Select All",
      "Select All Sections",
      "Select All Cameras",
      "Select All Groups",
      "Select All Solids",
      "Select All Model1Ds",
      "Select All Model2Ds",
      "Select All Polylines",
      "Select All Faces",
      "Select All Vertices",
      "Select All LandPoints",
      "———————————————",
      "Select Near Selected Vertices",
      "Select Scene Isolated Vertices"
    }
    ,
    {
      "3D-access",
      "Groups >> Faces",
      "Groups >> Vertices",
      "Groups >> Model1Ds",
      "Groups >> Model2Ds",
      "Groups >> Solids",
      "Groups >> Polylines",
      "——————————",
      "Faces >> Vertices",
      "Vertices >> Faces",
      "——————————",
      "Polylines >> Vertices",
      "Vertices >> Polylines",
      "——————————",
      "Faces >> Groups",
      "Vertices >> Groups",
      "Model1Ds >> Groups",
      "Model2Ds >> Groups",
      "Solids >> Groups",
      "Polylines >> Groups"
    }
    ,
    {
      "3D-modify",
      "Attach to Last Group",
      "Dettach from Groups Selection",
      "——————————————————",
      "Group Selection",
      "Ungroup Selection",
      "——————————————————",
      "Tessellate Triangular",
      "Tessellate Rectangular",
      "Tessellate Rows & Columns",
      "——————————————————",
      "Insert Corner Opennings",
      "Insert Parallel Opennings",
      "Insert Rotated Opennings",
      "Insert Edge Opennings",
      "——————————————————",
      "Offset(above) Vertices",
      "Offset(below) Vertices",
      "Offset(expand) Vertices",
      "Offset(shrink) Vertices",
      "——————————————————",
      "Extrude Face Edges",
      "Optimize Faces",
      "Auto-Normal Selected Faces",
      "Force Triangulate Selected Faces",
      "——————————————————",
      "Separate Selected Vertices",
      "Reposition Selected Vertices",
      "Weld Objects Selected Vertices",
      "Weld Scene Selected Vertices",
      "Flatten Selected LandPoints",
      "——————————————————",
      "Reverse Visibility of All Faces",
      "Hide All Faces",
      "Hide Selected Faces",
      "Unhide Selected Faces",
      "Unhide All Faces",
      "Isolate Selection",
      "——————————————————",
      "Reverse Visibility of All Polylines",
      "Hide All Polylines",
      "Hide Selected Polylines",
      "Unhide Selected Polylines",
      "Unhide All Polylines"
    }
    ,
    {
      "3D-match",
      "Save Current ReferenceBox",
      "Reset Saved ReferenceBox",
      "Use Selection ReferenceBox",
      "Use Origin ReferenceBox",
      "—————————————",
      "PivotX:Minimum",
      "PivotX:Center",
      "PivotX:Maximum",
      "PivotY:Minimum",
      "PivotY:Center",
      "PivotY:Maximum",
      "PivotZ:Minimum",
      "PivotZ:Center",
      "PivotZ:Maximum",
      "—————————————",
      "Pick Seed/Material",
      "Pick tessellation",
      "Pick Layer",
      "Pick Visibility",
      "Pick DegreeMax",
      "Pick TrunkSize",
      "Pick LeafSize",
      "Pick Model1DsProps",
      "—————————————",
      "Assign Seed/Material",
      "Assign tessellation",
      "Assign Layer",
      "Assign Visibility",
      "Assign DegreeMax",
      "Assign TrunkSize",
      "Assign LeafSize",
      "Assign Model1DsProps",
      "Assign Pivot",
      "—————————————",
      "Drop on LandSurface",
      "Drop on ModelSurface (Up)",
      "Drop on ModelSurface (Down)",
      "—————————————",
      "Get dX",
      "Get dY",
      "Get dZ",
      "Get dXYZ",
      "Get dXY"
    }
    ,
    {
      "3D-alter",
      "Move",
      "MoveX",
      "MoveY",
      "MoveZ",
      "——————————",
      "Rotate",
      "RotateX",
      "RotateY",
      "RotateZ",
      "——————————",
      "Scale",
      "ScaleX",
      "ScaleY",
      "ScaleZ",
      "——————————",
      "Power",
      "PowerX",
      "PowerY",
      "PowerZ",
      "——————————",
      "Flip Normal",
      "Set-Out Normal",
      "Set-In Normal",
      "Get FirstVertex",
      "——————————",
      "Change Seed/Material",
      "Change tessellation",
      "Change Layer",
      "Change Visibility",
      "Change Weight",
      "Change DegreeMax",
      "Change BranchTilt",
      "Change BranchTwist",
      "Change BranchRatio",
      "Change TreeBase",
      "Change TrunkSize",
      "Change LeafSize"
    }
  };
  }

  // Finds the "Layer" tab and rebuilds its child items from the live
  // layer list plus the fixed set of "developed" analysis layers.
  private void populateLayerMenu() {
    LayersID_in_Bar = -1;
    for (int i = 0; i < this.Items.length; i++) {
      if (this.Items[i][0].equals("Layer")) {
        LayersID_in_Bar = i;
        break;
      }
    }

    this.Items[LayersID_in_Bar] = new String[numberOfLayers + numberOfDevelopedLayers + 1]; // +1 for the divider
    this.Items[LayersID_in_Bar][0] = "Layer";

    for (int i = 0; i < numberOfLayers; i++) {
      this.Items[LayersID_in_Bar][i + 1] = allLayers[i].descriptions[Language_EN];
    }

    int base = numberOfLayers;
    this.Items[LayersID_in_Bar][base + 0] = "———————————————————";
    this.Items[LayersID_in_Bar][base + 1] = "Wind power";
    this.Items[LayersID_in_Bar][base + 2] = "Radiation on solar tracker";
    this.Items[LayersID_in_Bar][base + 3] = "Radiation on surface with inclination";
    this.Items[LayersID_in_Bar][base + 4] = "Radiation on South surface";
    this.Items[LayersID_in_Bar][base + 5] = "Radiation on East surface";
    this.Items[LayersID_in_Bar][base + 6] = "Radiation on North surface";
    this.Items[LayersID_in_Bar][base + 7] = "Radiation on West surface";
    this.Items[LayersID_in_Bar][base + 8] = "Radiation on S.E. surface";
    this.Items[LayersID_in_Bar][base + 9] = "Radiation on N.E. surface";
    this.Items[LayersID_in_Bar][base + 10] = "Radiation on N.W. surface";
    this.Items[LayersID_in_Bar][base + 11] = "Radiation on S.W. surface";
  }

  // Builds the lookup used to grey out toggle-style menu items whose
  // underlying feature is currently switched off.
  private HashMap<String, java.util.function.BooleanSupplier> buildDisabledStateLookup() {
    HashMap<String, java.util.function.BooleanSupplier> map = new HashMap<String, java.util.function.BooleanSupplier>();

    // "Location" menu
    map.put(toggleKey("Location", "Show/Hide SWOB stations"),   () -> WORLD.displayAll_SWOB == 0);
    map.put(toggleKey("Location", "Show/Hide SWOB nearest"),    () -> !WORLD.displayNear_SWOB);
    map.put(toggleKey("Location", "Show/Hide NAEFS stations"),  () -> WORLD.displayAll_NAEFS == 0);
    map.put(toggleKey("Location", "Show/Hide NAEFS nearest"),   () -> !WORLD.displayNear_NAEFS);
    map.put(toggleKey("Location", "Show/Hide CWEEDS stations"), () -> WORLD.displayAll_CWEEDS == 0);
    map.put(toggleKey("Location", "Show/Hide CWEEDS nearest"),  () -> !WORLD.displayNear_CWEEDS);
    map.put(toggleKey("Location", "Show/Hide CLMREC stations"), () -> WORLD.displayAll_CLMREC == 0);
    map.put(toggleKey("Location", "Show/Hide CLMREC nearest"),  () -> !WORLD.displayNear_CLMREC);
    map.put(toggleKey("Location", "Show/Hide TMYEPW stations"), () -> WORLD.displayAll_TMYEPW == 0);
    map.put(toggleKey("Location", "Show/Hide TMYEPW nearest"),  () -> !WORLD.displayNear_TMYEPW);

    // "3D-display" menu
    map.put(toggleKey("3D-display", "Show/Hide Land Mesh"),     () -> !Land3D.displaySurface);
    map.put(toggleKey("3D-display", "Show/Hide Land Texture"),  () -> !Land3D.displayTexture);
    map.put(toggleKey("3D-display", "Show/Hide Land Points"),   () -> !Land3D.displayPoints);
    map.put(toggleKey("3D-display", "Show/Hide Land Depth"),    () -> !Land3D.displayDepth);
    map.put(toggleKey("3D-display", "Show/Hide Vertices"),      () -> !allPoints.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Edges"),         () -> !allFaces.displayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Normals"),       () -> !allFaces.displayNormals);
    map.put(toggleKey("3D-display", "Show/Hide Leaves"),        () -> !allModel1Ds.displayLeaves);
    map.put(toggleKey("3D-display", "Show/Hide Model1Ds"),      () -> !allModel1Ds.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Model2Ds"),      () -> !allModel2Ds.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Polylines"),     () -> !allPolylines.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Faces"),         () -> !allFaces.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Solids"),        () -> !allSolids.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Sections"),      () -> !allSections.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Cameras"),       () -> !allCameras.displayAll);
    map.put(toggleKey("3D-display", "Show/Hide Sky"),           () -> !Sky3D.displaySurface);
    map.put(toggleKey("3D-display", "Show/Hide Sun Grid"),      () -> !Sun3D.displayGrid);
    map.put(toggleKey("3D-display", "Show/Hide Sun Path"),      () -> !Sun3D.displayPath);
    map.put(toggleKey("3D-display", "Show/Hide Sun Pattern"),   () -> !Sun3D.displayPattern);
    map.put(toggleKey("3D-display", "Show/Hide Sun Surface"),   () -> !Sun3D.displaySurface);
    map.put(toggleKey("3D-display", "Show/Hide Moon Surface"),  () -> !Moon3D.displaySurface);
    map.put(toggleKey("3D-display", "Show/Hide Earth Surface"), () -> !Earth3D.displaySurface);
    map.put(toggleKey("3D-display", "Show/Hide Troposphere"),   () -> !Tropo3D.displaySurface);
    map.put(toggleKey("3D-display", "Show/Hide Solar Section"), () -> !allSolarImpacts.displayImage);
    map.put(toggleKey("3D-display", "Show/Hide Solid Section"), () -> !allSolidImpacts.displayImage);
    map.put(toggleKey("3D-display", "Show/Hide Wind Flow"),     () -> !allWindFlows.displayAll);

    map.put(toggleKey("3D-display", "Show/Hide Selected Solids"),                 () -> !Select3D.Solid_displayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Sections"),               () -> !Select3D.Section_displayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Cameras"),                () -> !Select3D.Camera_displayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected LandPoints"),             () -> !Select3D.LandPoint_displayPoints);
    map.put(toggleKey("3D-display", "Show/Hide Selected Faces"),                  () -> !Select3D.Face_displayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Polylines"),              () -> !Select3D.Polyline_displayVertices);
    map.put(toggleKey("3D-display", "Show/Hide Selected Faces Vertex Count"),     () -> !Select3D.Face_displayVertexCount);
    map.put(toggleKey("3D-display", "Show/Hide Selected Polylines Vertex Count"), () -> !Select3D.Polyline_displayVertexCount);
    map.put(toggleKey("3D-display", "Show/Hide Selected Vertices"),               () -> !Select3D.Vertex_displayVertices);
    map.put(toggleKey("3D-display", "Show/Hide Selected REF Pivot"),              () -> !Select3D.displayReferencePivot);
    map.put(toggleKey("3D-display", "Show/Hide Selected Group Pivot"),            () -> !Select3D.Group_displayPivot);
    map.put(toggleKey("3D-display", "Show/Hide Selected Group Edges"),            () -> !Select3D.Group_displayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Group Box"),              () -> !Select3D.Group_displayBox);
    map.put(toggleKey("3D-display", "Show/Hide Selected 2D Edges"),               () -> !Select3D.Model2D_displayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected 1D Edges"),               () -> !Select3D.Model1D_displayEdges);

    return map;
  }

  private String toggleKey(String parentLabel, String childLabel) {
    return parentLabel + "\u0000" + childLabel;
  }

  private boolean isItemDisabled(int parentIndex, int childIndex) {
    java.util.function.BooleanSupplier state = disabledStateByItem.get(toggleKey(this.Items[parentIndex][0], this.Items[parentIndex][childIndex]));
    return (state != null) && state.getAsBoolean();
  }

  private boolean isDivider(String label) {
    return label.charAt(0) == DIVIDER_MARK;
  }

  // ---------------------------------------------------------------------
  // Drawing
  // ---------------------------------------------------------------------

  void draw () {
    if (!this.update) return;

    this.updated();

    fill(127);
    noStroke();
    rect(0, 0, width, SOLARCHVISION_pixel_A);

    X_control = 0; //0.25 * MessageSize;
    Y_control = 0.5 * SOLARCHVISION_pixel_A;

    for (int i = 0; i < this.Items.length; i++) {
      float cx = X_control + i * this.width_parent;
      float cy = Y_control;
      float cr = 0.5 * SOLARCHVISION_pixel_A;

      drawParentTab(i, cx, cy, cr);

      if (this.selected_parent == i) {
        drawChildMenu(i, cx, cy, cr);
      }
    }

    SOLARCHVISION_X_clicked = -1;
    SOLARCHVISION_Y_clicked = -1;
  }

  // Draws a single top-level tab (e.g. "File", "Tools", ...) and updates
  // selection state when the mouse is hovering over it.
  private void drawParentTab(int i, float cx, float cy, float cr) {
    if (isInside(mouseX, mouseY, cx, cy - cr, cx + this.width_parent, cy + cr)) {
      if (this.selected_parent == -1) {
        pre_screen = get(0, SOLARCHVISION_pixel_A, width, height - SOLARCHVISION_pixel_A);
        //println("Screen GET!");
      }
      this.selected_parent = i;
      this.selected_child = 0;
    }

    textAlign(LEFT, CENTER);
    textSize(PARENT_TEXT_SIZE_FACTOR * MessageSize);

    if (this.selected_parent == i) {
      stroke(0);
      fill(0);
    } else {
      stroke(255);
      fill(255);
    }

    text(this.Items[i][0], cx + 0.5 * MessageSize, cy - 0.125 * MessageSize);
  }

  // Draws the dropdown for the currently open parent tab.
  private void drawChildMenu(int i, float cx, float cy, float cr) {
    image(pre_screen, 0, SOLARCHVISION_pixel_A);
    this.selected_child = 0;

    float widthChildren = computeChildMenuWidth(i);

    for (int j = 1; j < this.Items[i].length; j++) {
      drawChildRow(i, j, cx, cy, cr, widthChildren);
    }
  }

  // The dropdown is at least as wide as width_child, but grows to fit
  // its longest label.
  private float computeChildMenuWidth(int parentIndex) {
    float widthChildren = this.width_child;
    for (int j = 1; j < this.Items[parentIndex].length; j++) {
      float estimatedWidth = this.Items[parentIndex][j].length() * MessageSize * CHILD_WIDTH_PER_CHAR;
      if (widthChildren < estimatedWidth) widthChildren = estimatedWidth;
    }
    return widthChildren;
  }

  // Draws one row (item or divider) of an open dropdown, including hover
  // highlighting and the disabled/greyed-out state.
  private void drawChildRow(int i, int j, float cx, float cy, float cr, float widthChildren) {
    float rowTop = cy - cr + SOLARCHVISION_pixel_A + (j - 1) * SOLARCHVISION_pixel_A * CHILD_ROW_HEIGHT_FACTOR;
    float rowHeight = SOLARCHVISION_pixel_A * CHILD_ROW_HEIGHT_FACTOR;

    String label = this.Items[i][j];
    boolean isSelectable = !isDivider(label);

    boolean isHovered = isSelectable && isInside(
      UI_X_moved, UI_Y_moved,
      cx, ceil(cy - cr + j * SOLARCHVISION_pixel_A * CHILD_ROW_HEIGHT_FACTOR) + 1,
      cx + widthChildren, floor(cy + cr + j * SOLARCHVISION_pixel_A * CHILD_ROW_HEIGHT_FACTOR) - 1
    );

    if (isHovered) {
      this.selected_child = j;
      fill(HOVER_COLOR_R, HOVER_COLOR_G, HOVER_COLOR_B);
    } else {
      fill(0, 223);
    }
    noStroke();
    rect(cx, rowTop, widthChildren, rowHeight);

    textAlign(LEFT, CENTER);
    if (this.selected_child == j) {
      stroke(0);
      fill(0);
    } else if (isItemDisabled(i, j)) {
      stroke(127);
      fill(127);
    } else {
      stroke(255);
      fill(255);
    }

    textSize(MessageSize);
    text(label, cx + 0.5 * MessageSize, rowTop + cr - 0.1 * MessageSize);
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
