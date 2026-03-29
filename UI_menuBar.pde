class solarchvision_UI_menuBar {

  private final static String CLASS_STAMP = "UI_menuBar";

  boolean update = true;

  float width_parent = 7 * MessageSize;
  float width_child = width_parent; // i.e. minimum size

  int selected_parent = -1;
  int selected_child = 0;

  String[][] Items = {
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
      "Render Viewport",
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





  private int LayersID_in_Bar;

  solarchvision_UI_menuBar () { // constructor

    // finding id of "Layer" in the list

    LayersID_in_Bar = -1;
    for (int i = 0; i < this.Items.length; i++) {
       if (this.Items[i][0].equals("Layer")) {
         LayersID_in_Bar = i;
         break;
       }
    }

    this.Items[LayersID_in_Bar] = new String [numberOfLayers + numberOfDevelopedLayers + 1]; // +1 for the divider

    this.Items[LayersID_in_Bar][0] = "Layer";

    for (int i = 0; i < numberOfLayers; i++) {

      this.Items[LayersID_in_Bar][i + 1] = allLayers[i].descriptions[Language_EN];
    }

    this.Items[LayersID_in_Bar][numberOfLayers + 0] = "———————————————————";
    this.Items[LayersID_in_Bar][numberOfLayers + 1] = "Wind power";
    this.Items[LayersID_in_Bar][numberOfLayers + 2] = "Radiation on solar tracker";
    this.Items[LayersID_in_Bar][numberOfLayers + 3] = "Radiation on surface with inclination";
    this.Items[LayersID_in_Bar][numberOfLayers + 4] = "Radiation on South surface";
    this.Items[LayersID_in_Bar][numberOfLayers + 5] = "Radiation on East surface";
    this.Items[LayersID_in_Bar][numberOfLayers + 6] = "Radiation on North surface";
    this.Items[LayersID_in_Bar][numberOfLayers + 7] = "Radiation on West surface";
    this.Items[LayersID_in_Bar][numberOfLayers + 8] = "Radiation on S.E. surface";
    this.Items[LayersID_in_Bar][numberOfLayers + 9] = "Radiation on N.E. surface";
    this.Items[LayersID_in_Bar][numberOfLayers + 10] = "Radiation on N.W. surface";
    this.Items[LayersID_in_Bar][numberOfLayers + 11] = "Radiation on S.W. surface";

  }


  void draw () {

    if (this.update) {

      //println("update BAR!");

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

        if (isInside(mouseX, mouseY, cx, cy - cr, cx + this.width_parent, cy + cr)) {

          if (this.selected_parent == -1) {

            pre_screen = get(0, SOLARCHVISION_pixel_A, width, height - SOLARCHVISION_pixel_A);

            //println("Screen GET!");
          }

          this.selected_parent = i;

          this.selected_child = 0;
        }


        textAlign(LEFT, CENTER);
        textSize(1.25 * MessageSize);

        if (this.selected_parent == i) {
          stroke(0);
          fill(0);
        } else {
          stroke(255);
          fill(255);
        }

        text(this.Items[i][0], cx + 0.5 * MessageSize, cy - 0.125 * MessageSize);



        if (this.selected_parent == i) {

          image(pre_screen, 0, SOLARCHVISION_pixel_A);

          this.selected_child = 0;


          float widthChildren = this.width_child;

          for (int j = 1; j < this.Items[this.selected_parent].length; j++) {
            float estimatedWidth = this.Items[this.selected_parent][j].length() * MessageSize * 0.55;
            if (widthChildren < estimatedWidth) widthChildren = estimatedWidth;
          }

          for (int j = 1; j < this.Items[this.selected_parent].length; j++) {
            if (
              (this.Items[this.selected_parent][j].charAt(0) != '—') &&
              (isInside(UI_X_moved, UI_Y_moved, cx, ceil(cy - cr + j * SOLARCHVISION_pixel_A * 0.85) + 1, cx + widthChildren, floor(cy + cr + j * SOLARCHVISION_pixel_A * 0.85) - 1))
            ) {

              this.selected_child = j;

              fill(255, 127, 0);
              noStroke();
              rect(cx, cy - cr + SOLARCHVISION_pixel_A + (j - 1) * SOLARCHVISION_pixel_A * 0.85, widthChildren, SOLARCHVISION_pixel_A * 0.85);
            } else {

              fill(0, 223);
              noStroke();
              rect(cx, cy - cr + SOLARCHVISION_pixel_A + (j - 1) * SOLARCHVISION_pixel_A * 0.85, widthChildren, SOLARCHVISION_pixel_A * 0.85);
            }

            textAlign(LEFT, CENTER);

            if (this.selected_child == j) {

              stroke(0);
              fill(0);
            } else {
              stroke(255);
              fill(255);

              if (this.Items[i][0].equals("Location")) {
                if (this.Items[i][j].equals("Show/Hide SWOB stations")) {
                  if (WORLD.displayAll_SWOB == 0) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide SWOB nearest")) {
                  if (WORLD.displayNear_SWOB == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide NAEFS stations")) {
                  if (WORLD.displayAll_NAEFS == 0) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide NAEFS nearest")) {
                  if (WORLD.displayNear_NAEFS == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide CWEEDS stations")) {
                  if (WORLD.displayAll_CWEEDS == 0) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide CWEEDS nearest")) {
                  if (WORLD.displayNear_CWEEDS == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide CLMREC stations")) {
                  if (WORLD.displayAll_CLMREC == 0) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide CLMREC nearest")) {
                  if (WORLD.displayNear_CLMREC == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide TMYEPW stations")) {
                  if (WORLD.displayAll_TMYEPW == 0) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide TMYEPW nearest")) {
                  if (WORLD.displayNear_TMYEPW == false) {
                    stroke(127);
                    fill(127);
                  }
                }
              }

              if (this.Items[i][0].equals("3D-display")) {
                if (this.Items[i][j].equals("Show/Hide Land Mesh")) {
                  if (Land3D.displaySurface == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Land Texture")) {
                  if (Land3D.displayTexture == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Land Points")) {
                  if (Land3D.displayPoints == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Land Depth")) {
                  if (Land3D.displayDepth == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Vertices")) {
                  if (allPoints.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Edges")) {
                  if (allFaces.displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Normals")) {
                  if (allFaces.displayNormals == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Leaves")) {
                  if (allModel1Ds.displayLeaves == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Model1Ds")) {
                  if (allModel1Ds.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Model2Ds")) {
                  if (allModel2Ds.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Polylines")) {
                  if (allFaces.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Faces")) {
                  if (allFaces.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Solids")) {
                  if (allSolids.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Sections")) {
                  if (allSections.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Cameras")) {
                  if (allCameras.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Sky")) {
                  if (Sky3D.displaySurface == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Sun Grid")) {
                  if (Sun3D.displayGrid == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Sun Path")) {
                  if (Sun3D.displayPath == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Sun Pattern")) {
                  if (Sun3D.displayPattern == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Sun Surface")) {
                  if (Sun3D.displaySurface == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Moon Surface")) {
                  if (Moon3D.displaySurface == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Earth Surface")) {
                  if (Earth3D.displaySurface == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Troposphere")) {
                  if (Tropo3D.displaySurface == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Solar Section")) {
                  if (allSolarImpacts.displayImage == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Solid Section")) {
                  if (allSolidImpacts.displayImage == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Wind Flow")) {
                  if (allWindFlows.displayAll == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Solids")) {
                  if (Select3D.Solid_displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Sections")) {
                  if (Select3D.Section_displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Cameras")) {
                  if (Select3D.Camera_displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected LandPoints")) {
                  if (Select3D.LandPoint_displayPoints == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Faces")) {
                  if (Select3D.Face_displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Polylines")) {
                  if (Select3D.Polyline_displayVertices == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Faces Vertex Count")) {
                  if (Select3D.Face_displayVertexCount == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Polylines Vertex Count")) {
                  if (Select3D.Polyline_displayVertexCount == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Vertices")) {
                  if (Select3D.Vertex_displayVertices == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected REF Pivot")) {
                  if (Select3D.displayReferencePivot == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Group Pivot")) {
                  if (Select3D.displayReferencePivot == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Group Edges")) {
                  if (Select3D.Group_displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected Group Box")) {
                  if (Select3D.Group_displayBox == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected 2D Edges")) {
                  if (Select3D.Model2D_displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
                if (this.Items[i][j].equals("Show/Hide Selected 1D Edges")) {
                  if (Select3D.Model1D_displayEdges == false) {
                    stroke(127);
                    fill(127);
                  }
                }
              }
            }

            textSize(MessageSize);
            text(this.Items[i][j], cx + 0.5 * MessageSize, cy - 0.1 * MessageSize + SOLARCHVISION_pixel_A + (j - 1) * SOLARCHVISION_pixel_A * 0.85);
          }
        }
      }

      SOLARCHVISION_X_clicked = -1;
      SOLARCHVISION_Y_clicked = -1;
    }

  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
