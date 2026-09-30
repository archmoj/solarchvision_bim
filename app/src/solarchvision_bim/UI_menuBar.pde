class UI_menuBar {

  final static String CLASS_STAMP = "UI_menuBar";

  // ---------------------------------------------------------------------
  // Layout / interaction state
  // ---------------------------------------------------------------------

  boolean update = true;

  int selected_parent = -1;
  int selected_child = 0;

  // ---------------------------------------------------------------------
  // Layout constants
  // ---------------------------------------------------------------------

  static final float PARENT_TEXT_SIZE_FACTOR = 1.25;
  static final float CHILD_ROW_HEIGHT_FACTOR = 0.85;
  static final char DIVIDER_MARK = '—';
  final String ___divider___ = String.valueOf(DIVIDER_MARK);

  static final int HOVER_COLOR_R = 255;
  static final int HOVER_COLOR_G = 127;
  static final int HOVER_COLOR_B = 0;

  // ---------------------------------------------------------------------
  // Menu data
  // ---------------------------------------------------------------------

  String[][] Items;

  int LayersID_in_Bar;

  // Looks up whether a given menu item should be drawn "greyed out"
  // (i.e. the feature it toggles is currently hidden/off). Uses the
  // JDK's own java.util.function.BooleanSupplier (a top-level type)
  // rather than a custom nested interface: Processing classes are
  // non-static inner classes of the sketch, and older Java versions
  // don't allow declaring a (implicitly static) member interface
  // inside a non-static inner class.
  HashMap<String, java.util.function.BooleanSupplier> disabledStateByItem;

  UI_menuBar () { // constructor
    this.Items = buildMenuItems();
    this.disabledStateByItem = buildDisabledStateLookup();
  }

  // ---------------------------------------------------------------------
  // Data setup
  // ---------------------------------------------------------------------

  String[][] buildMenuItems() {
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
      ___divider___,
      "Import 3D-model...",
      "Import Command File...",
      ___divider___,
      "Hold",
      "Fetch",
      ___divider___,
      "Save",
      "Save As...",
      ___divider___,
      "Export 3D-model > SCR",
      "Export 3D-model > RAD",
      "Export 3D-model > HTML",
      "Export 3D-model > OBJ",
      "Export 3D-model > OBJ (date-series)",
      "Export 3D-model > OBJ (time-series)",
      ___divider___,
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
      ___divider___,
      "Screenshot",
      "Screenshot+Click",
      "Screenshot+Drag",
      ___divider___,
      "REC. Time Graph",
      "REC. Location Graph",
      "REC. Solid Graph",
      "REC. Screenshot",
      "Stop REC.",
      ___divider___,
      "Add People on Land",
      "Add 2D-Trees on Land",
      "Add 1D-Trees on Land",
      ___divider___,
      "Clone Selection (Identical)",
      "Clone Selection (Variation)",
      ___divider___,
      "Delete Selection",
      "Delete Scene Empty Groups",
      "Delete Scene Isolated Vertices",
      "Delete Selection Isolated Vertices",
      "Delete All-Model1Ds",
      "Delete All-Model2Ds",
      "Delete All-Groups",
      "Delete All-Solids",
      "Delete All-Sections",
      "Delete All-Cameras",
      "Delete All-Faces",
      "Delete All-Polylines",
      "Delete All"
    }
    ,
    {
      "Location",
      "Update Station",
      ___divider___,
      "Use Climate Typical Year",
      "Use Climate Engineering",
      "Use Climate Archive",
      "Use Ensemble Observation",
      "Use Ensemble Forecast",
      ___divider___,
      "Update Climate Typical Year",
      "Update Climate Engineering",
      "Update Climate Archive",
      "Update Ensemble Observation",
      "Update Ensemble Forecast",
      ___divider___,
      "Load Toroposphere",
      "Load Land Mesh",
      "Load Land Texture",
      "Download Land Mesh",
      "Download Land Texture",
      ___divider___,
      "Download Climate Typical Year",
      "Download Climate Archive",
      "Download Ensemble Forecast",
      "Download Ensemble Observation",
      ___divider___,
      "Show/Hide Climate Typical Year stations",
      "Show/Hide Climate Typical Year nearest",
      "Show/Hide Climate Engineering stations",
      "Show/Hide Climate Engineering nearest",
      "Show/Hide Climate Archive stations",
      "Show/Hide Climate Archive nearest",
      "Show/Hide Ensemble Observation stations",
      "Show/Hide Ensemble Observation nearest",
      "Show/Hide Ensemble Forecast stations",
      "Show/Hide Ensemble Forecast nearest"
    }
    ,
    {
      "Setup",
      "Display All Viewports",
      "Enlarge 3D Viewport",
      "Enlarge Map Viewport",
      "Enlarge Time Viewport",
      ___divider___,
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
      ___divider___,
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
      ___divider___,
      "Orientation potential (active)",
      "Orientation potential (passive)",
      ___divider___,
      "Hourly sun position (active)",
      "Hourly sun position (passive)",
      ___divider___,
      "Annual cycle sun path (active)",
      "Annual cycle sun path (passive)",
      ___divider___,
      "Urban solar potential (active)",
      "Urban solar potential (passive)",
      ___divider___,
      "Shade Viewport",
      ___divider___,
      "Prebake Viewport",
      "Prebake Selected Sections",
      ___divider___,
      "Process Active Impact",
      "Process Passive Impact",
      ___divider___,
      "Process Solid Impact",
      "Run wind 3D-model"
    }
    ,
    {
      "3D-shade",
      "Active Shade",
      "Passive Shade",
      ___divider___,
      "Shade Surface Wire",
      "Shade Surface Base",
      "Shade Surface White",
      "Shade Surface Materials",
      ___divider___,
      "Shade Global Solar",
      "Shade Vertex Solar",
      ___divider___,
      "Shade Vertex Solid",
      "Shade Vertex Elevation"
    }
    ,
    {
      "3D-view",
      "Viewport >> Camera",
      "Camera >> Viewport",
      ___divider___,
      "Camera View",
      ___divider___,
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
      ___divider___,
      "Perspective",
      "Orthographic",
      ___divider___,
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
      ___divider___,
      "Section",
      "Camera",
      ___divider___,
      "1D-Tree",
      "2D-Tree",
      "Person",
      ___divider___,
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
      ___divider___,
      "House1",
      "House2",
      "House3",
      ___divider___,
      "Parametric 1",
      "Parametric 2",
      "Parametric 3",
      "Parametric 4",
      "Parametric 5",
      "Parametric 6",
      ___divider___,
      "Solid",
      "Point",
      "Polyline",
      ___divider___,
      "LandMesh >> Group",
      "LandGap >> Group"
    }
    ,
    {
      "3D-select",
      "Pick Select",
      "Pick Select+",
      "Pick Select-",
      ___divider___,
      "Window Select",
      "Window Select+",
      "Window Select-",
      ___divider___,
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
      ___divider___,
      "Soft Selection",
      "Invert Selection",
      "Deselect All",
      ___divider___,
      "Select All",
      "Select All-Sections",
      "Select All-Cameras",
      "Select All-Groups",
      "Select All-Solids",
      "Select All-Model1Ds",
      "Select All-Model2Ds",
      "Select All-Polylines",
      "Select All-Faces",
      "Select All Vertices",
      "Select All LandPoints",
      ___divider___,
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
      ___divider___,
      "Faces >> Vertices",
      "Vertices >> Faces",
      ___divider___,
      "Polylines >> Vertices",
      "Vertices >> Polylines",
      ___divider___,
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
      ___divider___,
      "Group Selection",
      "Ungroup Selection",
      ___divider___,
      "Tessellate Triangular",
      "Tessellate Rectangular",
      "Tessellate Rows & Columns",
      ___divider___,
      "Insert Corner Openings",
      "Insert Parallel Openings",
      "Insert Rotated Openings",
      "Insert Edge Openings",
      ___divider___,
      "Offset(above) Vertices",
      "Offset(below) Vertices",
      "Offset(expand) Vertices",
      "Offset(shrink) Vertices",
      ___divider___,
      "Extrude Face Edges",
      "Optimize Faces",
      "Auto-Normal Selected Faces",
      "Force Triangulate Selected Faces",
      ___divider___,
      "Separate Selected Vertices",
      "Reposition Selected Vertices",
      "Weld Objects Selected Vertices",
      "Weld Scene Selected Vertices",
      "Flatten Selected LandPoints",
      ___divider___,
      "Reverse Visibility of All-Faces",
      "Hide All-Faces",
      "Hide Selected Faces",
      "Unhide Selected Faces",
      "Unhide All-Faces",
      "Isolate Selection",
      ___divider___,
      "Reverse Visibility of All-Polylines",
      "Hide All-Polylines",
      "Hide Selected Polylines",
      "Unhide Selected Polylines",
      "Unhide All-Polylines"
    }
    ,
    {
      "3D-match",
      "Save Current ReferenceBox",
      "Reset Saved ReferenceBox",
      "Use Selection ReferenceBox",
      "Use Origin ReferenceBox",
      ___divider___,
      "PivotX:Minimum",
      "PivotX:Center",
      "PivotX:Maximum",
      "PivotY:Minimum",
      "PivotY:Center",
      "PivotY:Maximum",
      "PivotZ:Minimum",
      "PivotZ:Center",
      "PivotZ:Maximum",
      ___divider___,
      "Pick Seed/Material",
      "Pick tessellation",
      "Pick Layer",
      "Pick Visibility",
      "Pick DegreeMax",
      "Pick TrunkSize",
      "Pick LeafSize",
      "Pick Model1DsProps",
      ___divider___,
      "Assign Seed/Material",
      "Assign tessellation",
      "Assign Layer",
      "Assign Visibility",
      "Assign DegreeMax",
      "Assign TrunkSize",
      "Assign LeafSize",
      "Assign Model1DsProps",
      "Assign Pivot",
      ___divider___,
      "Drop on LandSurface",
      "Drop on ModelSurface (Up)",
      "Drop on ModelSurface (Down)",
      ___divider___,
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
      ___divider___,
      "Rotate",
      "RotateX",
      "RotateY",
      "RotateZ",
      ___divider___,
      "Scale",
      "ScaleX",
      "ScaleY",
      "ScaleZ",
      ___divider___,
      "Power",
      "PowerX",
      "PowerY",
      "PowerZ",
      ___divider___,
      "Flip Normal",
      "Set-Out Normal",
      "Set-In Normal",
      "Get FirstVertex",
      ___divider___,
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
  void populateLayerMenu() {
    LayersID_in_Bar = -1;
    for (int i = 0; i < this.Items.length; i++) {
      if (this.Items[i][0].equals("Layer")) {
        LayersID_in_Bar = i;
        break;
      }
    }

    this.Items[LayersID_in_Bar] = new String[allLayers.length + numberOfDevelopedLayers + 1]; // +1 for the divider
    this.Items[LayersID_in_Bar][0] = "Layer";

    for (int i = 0; i < allLayers.length; i++) {
      this.Items[LayersID_in_Bar][i + 1] = allLayers[i].descriptions[Language_EN];
    }

    int base = allLayers.length;
    this.Items[LayersID_in_Bar][base + 0] = ___divider___;
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
  HashMap<String, java.util.function.BooleanSupplier> buildDisabledStateLookup() {
    HashMap<String, java.util.function.BooleanSupplier> map = new HashMap<String, java.util.function.BooleanSupplier>();

    // "Location" menu
    map.put(toggleKey("Location", "Show/Hide Ensemble Observation stations"),   () -> WORLD.ensembleObservationDisplayAll == 0);
    map.put(toggleKey("Location", "Show/Hide Ensemble Observation nearest"),    () -> !WORLD.ensembleObservationDisplayNear);
    map.put(toggleKey("Location", "Show/Hide Ensemble Forecast stations"),  () -> WORLD.ensembleForecastDisplayAll == 0);
    map.put(toggleKey("Location", "Show/Hide Ensemble Forecast nearest"),   () -> !WORLD.ensembleForecastDisplayNear);
    map.put(toggleKey("Location", "Show/Hide Climate Engineering stations"), () -> WORLD.climateEngineeringDisplayAll == 0);
    map.put(toggleKey("Location", "Show/Hide Climate Engineering nearest"),  () -> !WORLD.climateEngineeringDisplayNear);
    map.put(toggleKey("Location", "Show/Hide Climate Archive stations"), () -> WORLD.climateArchiveDisplayAll == 0);
    map.put(toggleKey("Location", "Show/Hide Climate Archive nearest"),  () -> !WORLD.climateArchiveDisplayNear);
    map.put(toggleKey("Location", "Show/Hide Climate Typical Year stations"), () -> WORLD.climateTypicalYearDisplayAll == 0);
    map.put(toggleKey("Location", "Show/Hide Climate Typical Year nearest"),  () -> !WORLD.climateTypicalYearDisplayNear);

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

    map.put(toggleKey("3D-display", "Show/Hide Selected Solids"),                 () -> !Select3D.solidDisplayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Sections"),               () -> !Select3D.sectionDisplayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Cameras"),                () -> !Select3D.cameraDisplayFrustum);
    map.put(toggleKey("3D-display", "Show/Hide Selected LandPoints"),             () -> !Select3D.LandPoint_displayPoints);
    map.put(toggleKey("3D-display", "Show/Hide Selected Faces"),                  () -> !Select3D.faceDisplayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Polylines"),              () -> !Select3D.polylineDisplayVertices);
    map.put(toggleKey("3D-display", "Show/Hide Selected Faces Vertex Count"),     () -> !Select3D.faceDisplayVertexIndices);
    map.put(toggleKey("3D-display", "Show/Hide Selected Polylines Vertex Count"), () -> !Select3D.polylineDisplayVertexIndices);
    map.put(toggleKey("3D-display", "Show/Hide Selected Vertices"),               () -> !Select3D.vertexDisplayMarkers);
    map.put(toggleKey("3D-display", "Show/Hide Selected REF Pivot"),              () -> !Select3D.pivotDisplayReference);
    map.put(toggleKey("3D-display", "Show/Hide Selected Group Pivot"),            () -> !Select3D.groupDisplayPivot);
    map.put(toggleKey("3D-display", "Show/Hide Selected Group Edges"),            () -> !Select3D.groupDisplayEdges);
    map.put(toggleKey("3D-display", "Show/Hide Selected Group Box"),              () -> !Select3D.groupDisplayBox);
    map.put(toggleKey("3D-display", "Show/Hide Selected 2D Edges"),               () -> !Select3D.model2DDisplayBounds);
    map.put(toggleKey("3D-display", "Show/Hide Selected 1D Edges"),               () -> !Select3D.model1DDisplayBounds);

    return map;
  }

  String toggleKey(String parentLabel, String childLabel) {
    return parentLabel + "\u0000" + childLabel;
  }

  boolean isItemDisabled(int parentIndex, int childIndex) {
    java.util.function.BooleanSupplier state = disabledStateByItem.get(toggleKey(this.Items[parentIndex][0], this.Items[parentIndex][childIndex]));
    return (state != null) && state.getAsBoolean();
  }

  boolean isDivider(String label) {
    return label.charAt(0) == DIVIDER_MARK;
  }

  // ---------------------------------------------------------------------
  // Drawing
  // ---------------------------------------------------------------------

  private boolean isMenuLayerPopulated = false;
  private float currentParentWidth = 0;

  void draw () {
    if (!this.update) return;
    this.updated();

    if(!isMenuLayerPopulated) {
      populateLayerMenu();
      isMenuLayerPopulated = true;
    }

    fill(127);
    noStroke();
    rect(0, 0, width, pixel_A);

    X_control = 0; //0.25 * MessageSize;
    Y_control = 0.5 * pixel_A;

    float cx = X_control;
    currentParentWidth = 0;
    for (int i = 0; i < this.Items.length; i++) {
      textSize(PARENT_TEXT_SIZE_FACTOR * MessageSize);
      cx += currentParentWidth;
      currentParentWidth = textWidth(this.Items[i][0]) + 2 * padParentWidth;

      float cy = Y_control;
      float cr = 0.5 * pixel_A;

      drawParentTab(i, cx, cy, cr);

      if (this.selected_parent == i) {
        drawChildMenu(i, cx, cy, cr);
      }
    }

    X_clicked = -1;
    Y_clicked = -1;
  }

  // Draws a single top-level tab (e.g. "File", "Tools", ...) and updates
  // selection state when the mouse is hovering over it.
  void drawParentTab(int i, float cx, float cy, float cr) {
    if (!this.deselecting && !isHoverSuppressed() && isInside(mouseX, mouseY, cx, cy - cr, cx + currentParentWidth, cy + cr)) {
      if (this.selected_parent == -1) {
        pre_screen = get(0, pixel_A, width, height - pixel_A);
        //println("Screen GET!");
      }
      this.selected_parent = i;
      this.selected_child = 0;
    }

    textAlign(LEFT, CENTER);

    if (this.selected_parent == i) {
      noStroke();
      fill(0, 127, 255);
      float r = 2 * padParentWidth;
      rect(
          cx, cy - cr, currentParentWidth, 2 * cr, // corners
          r, r, r, r // round corners
      );
    }
    stroke(255);
    fill(255);

    if (this.selected_parent == i) {
      stroke(0);
      fill(0);
    }
    text(this.Items[i][0], cx + padParentWidth, cy - 0.125 * MessageSize);
  }

  final float padParentWidth = 0.75 * MessageSize;
  final float padChildrenWidth = 0.5 * MessageSize;

  // Draws the dropdown for the currently open parent tab.
  void drawChildMenu(int i, float cx, float cy, float cr) {
    image(pre_screen, 0, pixel_A);
    if (!isHoverSuppressed()) {
      this.selected_child = 0;
    }

    // set textSize here so that textWidth use that
    textSize(MessageSize);
    float widthChildren = computeChildMenuWidth(i);

    for (int j = 1; j < this.Items[i].length; j++) {
      drawChildRow(i, j, cx, cy, cr, widthChildren);
    }
  }

  float computeChildMenuWidth(int parentIndex) {
    float widthChildren = 0;
    for (int j = 1; j < this.Items[parentIndex].length; j++) {
      float estimatedWidth = textWidth(this.Items[parentIndex][j]);
      if (widthChildren < estimatedWidth) widthChildren = estimatedWidth;
    }
    // add padding to both sides
    widthChildren += 2 * padChildrenWidth;

    return widthChildren;
  }

  // Draws one row (item or divider) of an open dropdown, including hover
  // highlighting and the disabled/greyed-out state.
  void drawChildRow(int i, int j, float cx, float cy, float cr, float widthChildren) {
    float rowTop = cy - cr + pixel_A + (j - 1) * pixel_A * CHILD_ROW_HEIGHT_FACTOR;
    float rowHeight = pixel_A * CHILD_ROW_HEIGHT_FACTOR;

    String label = this.Items[i][j];
    boolean isSelectable = !isDivider(label);

    boolean isHovered = isSelectable && !isHoverSuppressed() && isInside(
      UI_X_moved, UI_Y_moved,
      cx, ceil(cy - cr + j * pixel_A * CHILD_ROW_HEIGHT_FACTOR) + 1,
      cx + widthChildren, floor(cy + cr + j * pixel_A * CHILD_ROW_HEIGHT_FACTOR) - 1
    );

    if (isHovered) {
      this.selected_child = j;
    }

    // highlight the selected row whether it was selected by mouse or keyboard
    if (isSelectable && (this.selected_child == j)) {
      fill(HOVER_COLOR_R, HOVER_COLOR_G, HOVER_COLOR_B);
    } else {
      fill(0, 0, 63, 223);
    }
    noStroke();
    float r = 2 * padParentWidth;
    if(j == 1) {
      rect(
        cx, rowTop, widthChildren, rowHeight,
        r, r, 0, 0 // round corners
      );
    } else if(j < this.Items[i].length - 1) {
      rect(cx, rowTop, widthChildren, rowHeight);
    } else {
      rect(
        cx, rowTop, widthChildren, rowHeight,
        0, 0, r, r // round corners
      );
    }

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

    if(isSelectable) {
      text(label, cx + padChildrenWidth, rowTop + cr - 0.1 * MessageSize);
    } else {
      stroke(0, 127, 255);
      strokeWeight(2);
      line(
        cx + padChildrenWidth,                                rowTop + cr,
        cx + padChildrenWidth + widthChildren - 2 * padChildrenWidth, rowTop + cr
      );
      strokeWeight(0);
      noStroke();
    }
  }

  // ---------------------------------------------------------------------
  // Keyboard navigation
  // ---------------------------------------------------------------------

  // Once the keyboard moves the selection, mouse hover is ignored until
  // the mouse actually moves again; otherwise a resting mouse pointer
  // would override the keyboard selection on every redraw.
  private boolean keyboardNavigated = false;
  private int keyboardNavigated_X_moved = -1;
  private int keyboardNavigated_Y_moved = -1;

  boolean isHoverSuppressed () {
    return this.keyboardNavigated &&
      (UI_X_moved == this.keyboardNavigated_X_moved) &&
      (UI_Y_moved == this.keyboardNavigated_Y_moved);
  }

  // Returns the next selectable child of parent p starting from `from`
  // and moving in direction `dir` (+1 / -1). Dividers are skipped. Index 0
  // (the parent tab itself, i.e. "no child") is always a valid stop.
  // Returns `from` if there is nowhere to go.
  int stepChild (int p, int from, int dir) {
    for (int j = from + dir; (j >= 0) && (j < this.Items[p].length); j += dir) {
      if ((j == 0) || !isDivider(this.Items[p][j])) return j;
    }
    return from;
  }

  // Clamp child j into parent p's range and make sure it is not a divider.
  int clampChild (int p, int j) {
    j = max(0, min(j, this.Items[p].length - 1));
    if ((j > 0) && isDivider(this.Items[p][j])) {
      int k = stepChild(p, j, -1);
      if ((k == 0) && (j < this.Items[p].length - 1)) {
        int m = stepChild(p, j, 1);
        if (m != j) k = m;
      }
      j = k;
    }
    return j;
  }

  // Handles Up/Down/Left/Right/Enter while a menu is open.
  // Returns true if the key was consumed so that other elements must not
  // process it.
  // --- Continuous key-hold navigation (see WIN3D.pde) ------------------
  // Processing does not forward OS key-repeat events while a key stays
  // held, so Up/Down/Left/Right are re-run once per frame (from draw(),
  // via processHeldKey()) for as long as they remain held. Enter is a
  // discrete/destructive action and must stay single-press only.
  boolean navKeyHeld = false;
  int navKeyCode = 0;
  // Delay-then-repeat, like an OS key-repeat setting, at frameRate(24):
  // ~0.25s before the first repeat, then one step every frame (~24/s).
  static final int NAV_KEY_INITIAL_DELAY_FRAMES = 6;
  static final int NAV_KEY_REPEAT_FRAMES = 1;
  int navKeyFrameCounter = 0;
  boolean navKeyRepeating = false;

  boolean keyPressed (KeyEvent e) {
    if (this.selected_parent == -1) return false;
    if (e.isControlDown() || e.isAltDown()) return false;

    boolean isCoded = (e.getKey() == CODED);
    int code = e.getKeyCode();

    boolean isEnter = !isCoded && ((e.getKey() == ENTER) || (e.getKey() == RETURN));
    boolean isArrow = isCoded && ((code == UP) || (code == DOWN) || (code == LEFT) || (code == RIGHT));

    if (!isEnter && !isArrow) return false;

    if (isEnter) {
      this.runSelectedItem();
      this.deselect();
      X_clicked = -1;
      Y_clicked = -1;
      return true;
    }

    this.navKeyHeld = true;
    this.navKeyCode = code;
    this.navKeyFrameCounter = 0;
    this.navKeyRepeating = false;

    this.moveSelection(code);
    return true;
  }

  // Moves selected_parent / selected_child for one arrow key press.
  // Shared by keyPressed() (first press) and processHeldKey() (repeat).
  void moveSelection (int code) {
    int p = this.selected_parent;
    int c = this.selected_child;

    if (code == DOWN) {
      c = stepChild(p, c, 1);
    } else if (code == UP) {
      c = stepChild(p, c, -1);
    } else if (code == RIGHT) {
      p = min(p + 1, this.Items.length - 1);
      c = clampChild(p, c);
    } else if (code == LEFT) {
      p = max(p - 1, 0);
      c = clampChild(p, c);
    }

    this.selected_parent = p;
    this.selected_child = c;

    this.keyboardNavigated = true;
    this.keyboardNavigated_X_moved = UI_X_moved;
    this.keyboardNavigated_Y_moved = UI_Y_moved;

    this.revise();
  }

  // Called once per frame from the sketch's draw(); re-fires the held
  // arrow key's action for as long as it remains held and the menu is
  // still open.
  void processHeldKey () {
    if (this.navKeyHeld && (this.selected_parent != -1)) {
      this.navKeyFrameCounter++;
      int threshold = this.navKeyRepeating ? NAV_KEY_REPEAT_FRAMES : NAV_KEY_INITIAL_DELAY_FRAMES;
      if (this.navKeyFrameCounter >= threshold) {
        this.navKeyFrameCounter = 0;
        this.navKeyRepeating = true;
        this.moveSelection(this.navKeyCode);
      }
    }
  }

  // Matches the global keyReleased() convention (no KeyEvent overload
  // needed): uses the sketch's global key/keyCode.
  void keyReleased () {
    if (!this.navKeyHeld) return;
    if ((key == CODED) && (keyCode == this.navKeyCode)) {
      this.navKeyHeld = false;
    }
  }

  // Runs the action of the currently selected menu item.
  // Shared by mouse click (mouseClicked.pde) and the Enter key.
  void runSelectedItem () {
    if (this.selected_parent == -1) return;
    if (this.selected_child == 0) return;

    String menu_option = this.Items[this.selected_parent][this.selected_child];
    menu_option = menu_option.toLowerCase();
    Action action = allActions.get(menu_option);
    if (action != null) {
      action.run(new String[0]);
    }

    if (this.Items[this.selected_parent][0].equals("Layer")) {
      if (this.selected_child > 0) {
        if (this.selected_child < allLayers.length) {
          changeCurrentLayerTo(this.selected_child - 1);
          developLayerId = currentLayerId;
          STUDY.revise();
        } else if (menu_option.charAt(0) != '—') {
          developLayerOption = this.selected_child - allLayers.length - 1; // -1 for the divider
          postProcess_developDATA(currentDataSource);
          changeCurrentLayerTo(LAYER_developed.id);
          STUDY.revise();
        }
      }
    }
  }

  private boolean deselecting = false;

  void deselect () {
    image(pre_screen, 0, pixel_A);

    this.selected_parent = -1;
    this.selected_child = 0;
    this.keyboardNavigated = false;
    this.revise();

    deselecting = true;
    this.draw();
    deselecting = false;
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
