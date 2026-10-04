class UI_toolBar {

  final static String CLASS_STAMP = "UI_toolBar";

  boolean update = true;

  float tab = pixel_B;

  String[][] Items = {
    {
      "11", "Top", "Front", "Left", "Back", "Right", "Bottom", "S.W.", "S.E.", "N.E.", "N.W.", "Cam00", "View Point", "2.0"
    }
    ,
    {
      "2", "all", "3D", "graph", "map", "View Layout", "1"
    }
    ,

    {
      "2", "orthographic", "perspective", "Projection Type", "1.0"
    }
    ,
    {
      "1", "", "Look At Origin", "1.0"
    }
    ,
    {
      "1", "", "Look At Direction", "1.0"
    }
    ,
    {
      "1", "", "Look At Selection", "1.0"
    }
    ,
    {
      "3", "", "z", "xy", "Camera Roll", "1.0"
    }
    ,
    {
      "1", "", "Camera Distance", "1.0"
    }
    ,
    {
      "1", "", "Dist XY", "1.0"
    }
    ,
    {
      "1", "", "Dist Z", "1.0"
    }
    ,
    {
      "3", "z", "x", "y", "Truck", "1.0"
    }
    ,
    {
      "1", "", "Terrain Orbit", "1.0"
    }
    ,
    {
      "1", "", "xy", "z", "Orbit", "1.0"
    }
    ,
    {
      "1", "", "z", "xy", "Target Roll", "1.0"
    }
    ,
    {
      "1", "", "x", "y", "Pan", "1.0"
    }
    ,
    {
      "1", "±", "normal", "Zoom", "1.0"
    }
    ,
    {
      "1", "", "All Model Size", "1.0"
    }
    ,
    {
      "1", "", "3D Model Size", "1.0"
    }
    ,
    {
      "1", "", "Skydome Size", "1.0"
    }
    ,

    {
      "3", "1D-Tree", "2D-Tree", "Person", "Living Type", "2.5"
    }
    ,
    {
      "1", "House1", "House2", "House3", "Box", "Cushion", "Cone", "Cylinder", "Sphere", "Octahedron", "Icosahedron", "Pyramid", "Hyper", "Plane", "Polygon", "Extrude", "Parametric", "Point", "Polyline", "Surface", "Building Type", "3.5"
    }
    ,
    {
      "1", "Mesh", "Solid", "Model Type", "2.0"
    }
    ,

    {
      "4", "Terrain", "1D", "2D", "Group", "Face", "Vertex", "Soft", "Solid", "Section", "Camera", "Polyline", "Layer Type", "2.0"
    }
    ,
    {
      "1", "±", "+", "-", "Pick Select", "1.0"
    }
    ,
    {
      "1", "±", "+", "-", "Window Select", "1.0"
    }
    ,
    {
      "2", "X<", "X|", "X>", "PivotX", "1.0"
    }
    ,
    {
      "2", "Y<", "Y|", "Y>", "PivotY", "1.0"
    }
    ,
    {
      "2", "Z<", "Z|", "Z>", "PivotZ", "1.0"
    }
    ,
    //{"1", "±", "+", "-", "Drop", "1.0"},
    {
      "4", "x", "y", "z", "xyz", "xy", "angle", "Get Length", "1.0"
    }
    ,
    {
      "3", "x", "y", "z", "xyz", "Move", "1.0"
    }
    ,
    {
      "3", "x", "y", "z", "xyz", "Scale", "1.0"
    }
    ,
    {
      "3", "x", "y", "z", "Rotate", "1.0"
    }
    ,
    //{"3", "x", "y", "z", "xyz", "Power", "1.0"},
    {
      "1", "0", "1", "2", "3", "Change Seed/Material", "1.0"
    }
    ,
    {
      "1", "0", "1", "2", "3", "Change Tessellation", "1.0"
    }
    ,
    {
      "1", "0", "1", "2", "3", "Change Layer", "1.0"
    }
    ,
    {
      "1", "0", "1", "2", "3", "Change Visibility", "1.0"
    }
    ,
    {
      "1", "0", "1", "2", "3", "Change Weight", "1.0"
    }
    ,
    {
      "1", "1", "2", "3", "Normal", "1.0"
    }
    ,
    {
      "1", "", "First Vertex", "1.0"
    }
  };



  int Selection = -1;


  boolean displayText;


  void highlight (String s) {

    int break_loops = 0;

    for (int i = 0; i < this.Items.length; i++) {
      for (int j = 1; j < this.Items[i].length - 2; j++) {
        if (this.Items[i][j].equals(s)) {

          this.Items[i][0] = nf(j, 0);

          break_loops = 1;
        }

        if (break_loops == 1) break;
      }
      if (break_loops == 1) break;
    }
  }

  boolean HelperState = false;

  // ---------------------------------------------------------------------
  // Data layout of a row in `Items`:
  //   Items[row][0]              -> index of the currently selected option (stored as a String)
  //   Items[row][1 .. n-3]       -> the selectable option labels for this toolbar item
  //   Items[row][length - 2]     -> "Bar_Switch": the identifier for which action/icon this item drives
  //   Items[row][length - 1]     -> width multiplier, relative to `tab`
  // ---------------------------------------------------------------------

  void draw () {

    if (!this.update) return;

    this.updated();

    fill(0);
    noStroke();
    rect(0, pixel_A, width, pixel_B);

    X_control = 0; //0.25 * MessageSize;
    Y_control = pixel_A + 0.5 * pixel_B;

    float cx = X_control;
    float cy = Y_control;
    float cr = 0.5 * pixel_B;

    for (int i = 0; i < this.Items.length; i++) {
      cx += this.drawItem(i, cx, cy, cr);
    }

    X_clicked = -1;
    Y_clicked = -1;
  }

  // Draws a single toolbar item (its box, optional click handling, icon/label),
  // and returns the item's on-screen width so the caller can advance cx.
  float drawItem (int i, float cx, float cy, float cr) {

    String Bar_Switch = this.Items[i][this.Items[i].length - 2];

    if (Bar_Switch.equals("Layer Type")) {
      this.Items[i][0] = nf(currentObjectCategory + 1, 0);
    }

    int j = int(this.Items[i][0]);
    float Item_width = this.tab * float(this.Items[i][this.Items[i].length - 1]);

    noFill();
    stroke(255);
    strokeWeight(1);
    rect(cx, cy - cr, Item_width, pixel_B);
    strokeWeight(0);

    if (isInside(X_clicked, Y_clicked, cx, cy - cr, cx + Item_width, cy + cr)) {
      j = this.handleClick(i, j, Bar_Switch, cx, cy, cr, Item_width);
    }

    this.displayText = true;

    this.drawIcon(Bar_Switch, j, cx + 0.5 * Item_width, cy, 0.5 * pixel_B);

    if (this.displayText) { // writing titles where the icon is not available
      textAlign(CENTER, CENTER);
      stroke(255);
      fill(255);
      textSize(MessageSize);
      text(this.Items[i][j], cx + 0.5 * Item_width, cy);
    }

    return Item_width;
  }

  // Handles a click/hover on toolbar item i. Returns the (possibly updated) selected index j.
  int handleClick (int i, int j, String Bar_Switch, float cx, float cy, float cr, float Item_width) {

    if (mouseButton == CENTER) {
      this.toggleHelper(i, j, Bar_Switch, cx, cy, cr, Item_width);
      return j;
    }

    if (mouseButton == RIGHT) {
      j = this.advanceSelection(i, j, -1);
      this.dismissHelper();
    }

    if (mouseButton == LEFT) {
      j = this.advanceSelection(i, j, 1);
      this.dismissHelper();
    }

    fill(255, 127, 0);
    noStroke();
    rect(cx, cy - cr, Item_width, pixel_B);

    this.performAction(Bar_Switch, i, j);

    return j;
  }

  // Shows/hides the tooltip helper for the currently hovered item.
  void toggleHelper (int i, int j, String Bar_Switch, float cx, float cy, float cr, float Item_width) {

    HelperState = !HelperState;

    if (!HelperState) {
      UI_menuBar.revise();
      return;
    }

    String HelperText = Bar_Switch;
    if (
      this.Items[i].length > 4 &&
      this.Items[i][j] != "" &&
      Bar_Switch != "View Point"
    ) {
      HelperText += ": " + this.Items[i][j];
    }

    float estimatedWidth = textWidth(HelperText) + MessageSize;

    // draw over menu bar
    float HelperY = cy - cr - pixel_A;
    float HelperH = pixel_A;
    float HelperX = cx;
    float HelperW = max(pixel_B * 2, estimatedWidth);
    if (HelperX + HelperW > width) HelperX -= HelperW - pixel_B;

    fill(127, 255, 0);
    noStroke();
    rect(HelperX, HelperY, HelperW, HelperH);

    fill(0);
    text(HelperText, HelperX, HelperY, HelperW, HelperH);

    noFill();
    stroke(127, 255, 0);
    strokeWeight(4);
    rect(cx + 4, cy - cr + 4, Item_width - 8, pixel_B - 8);
    strokeWeight(0);
  }

  // Closes the tooltip helper (if open) and asks the menu bar to redraw.
  void dismissHelper () {
    if (HelperState) {
      HelperState = false;
      UI_menuBar.revise();
    }
  }

  // Cycles the selected option of item i by `direction` (+1 or -1), wrapping around.
  // On the first click after selecting a different item, it only focuses the item
  // (matching the original behavior) rather than advancing the selection.
  int advanceSelection (int i, int j, int direction) {

    if (this.Selection != i) {
      this.Selection = i;
      return j;
    }

    int lastOptionIndex = this.Items[i].length - 3;
    int n = j + direction;

    if (direction > 0 && n >= this.Items[i].length - 2) n = 1;
    if (direction < 0 && n <= 0) n = lastOptionIndex;

    this.Items[i][0] = nf(n, 0);
    return n;
  }

  // Performs the action associated with a toolbar item once it has been clicked.
  void performAction (String Bar_Switch, int i, int j) {

    switch (Bar_Switch) {

      case "Layer Type":
        currentObjectCategory = j - 1;
        if (currentObjectCategory == ObjectCategory.SOFTVERTEX) {
          Select3D.convert_Vertex_to_softSelection();
        }
        UI_rollout.revise();
        view_changed();
        break;

      case "Model Type":
        User3D.creatorMeshOrSolidMode = j - 1;
        UI_rollout.revise();
        break;

      case "Living Type":
      case "Building Type":
        // Each of these (no args) already exists as a shape command's
        // own no-args hint branch, which calls the exact same
        // UI_setTo_Create_X() this toolbar button called directly -
        // confirmed one at a time by reading each command's own branch,
        // not assumed from name similarity (two are genuinely
        // surprising: "Mesh" is what UI_setTo_Create_Face() belongs to,
        // not a "Face" command, and "PolygonMesh"'s own no-args branch
        // calls UI_setTo_Create_Plane() - a pre-existing mismatch in
        // that command itself, predating this change, not something
        // introduced here; preserved exactly rather than silently
        // "corrected" to UI_setTo_Create_Polygon(), which would be a
        // separate, unverified behavior change beyond reuse).
        // "Point" and "Polygon" are left as direct calls: no existing
        // command's no-args branch calls UI_setTo_Create_Vertex() or
        // UI_setTo_Create_Polygon() at all. "Parametric" is also left
        // direct: the "Parametric" command's own no-args branch
        // hardcodes UI_setTo_Create_Parametric(0), not this button's
        // own User3D.creatorParametricTypeIndex - reusing it would
        // silently drop the currently-selected parametric type.
        switch (this.Items[i][j]) {
          case "1D-Tree": runScriptLine("Tree1"); break;
          case "2D-Tree": runScriptLine("Tree2"); break;
          case "Person": runScriptLine("Person"); break;
          case "Point": UI_setTo_Create_Vertex(); break;
          case "Polyline": runScriptLine("Polyline"); break;
          case "Surface": runScriptLine("Mesh"); break;
          case "Pyramid": runScriptLine("Pyramid"); break;
          case "Plane": runScriptLine("PolygonMesh"); break;
          case "Polygon": UI_setTo_Create_Polygon(); break;
          case "Extrude": runScriptLine("PolygonExtrude"); break;
          case "Hyper": runScriptLine("PolygonHyper"); break;
          case "House3": runScriptLine("House3"); break;
          case "House2": runScriptLine("House2"); break;
          case "House1": runScriptLine("House1"); break;
          case "Box": runScriptLine("Box"); break;
          case "Icosahedron": runScriptLine("Icosahedron"); break;
          case "Octahedron": runScriptLine("Octahedron"); break;
          case "Sphere": runScriptLine("Sphere"); break;
          case "Cylinder": runScriptLine("Cylinder"); break;
          case "Cone": runScriptLine("Cone"); break;
          case "Cushion": runScriptLine("Cushion"); break;
          case "Parametric": UI_setTo_Create_Parametric(User3D.creatorParametricTypeIndex); break;
        }
        break;

      // "0"/"1"/"2" of each of these five match an existing "Change
      // X"/"Pick X"/"Assign X" action exactly (checked against actions.pde
      // directly for each, not assumed from the pattern repeating); "3"
      // has no existing match for any of them (UI_setTo_Modify_*(3) is
      // simply never registered), so stays a direct call.
      case "Change Seed/Material":
        switch (this.Items[i][j]) {
          case "0": runScriptLine("Change Seed/Material"); break;
          case "1": runScriptLine("Pick Seed/Material"); break;
          case "2": runScriptLine("Assign Seed/Material"); break;
          case "3": UI_setTo_Modify_Seed(3); break;
        }
        break;

      case "Change Tessellation":
        switch (this.Items[i][j]) {
          case "0": runScriptLine("Change tessellation"); break;
          case "1": runScriptLine("Pick tessellation"); break;
          case "2": runScriptLine("Assign tessellation"); break;
          case "3": UI_setTo_Modify_Tessellation(3); break;
        }
        break;

      case "Change Layer":
        switch (this.Items[i][j]) {
          case "0": runScriptLine("Change Layer"); break;
          case "1": runScriptLine("Pick Layer"); break;
          case "2": runScriptLine("Assign Layer"); break;
          case "3": UI_setTo_Modify_Layer(3); break;
        }
        break;

      case "Change Visibility":
        switch (this.Items[i][j]) {
          case "0": runScriptLine("Change Visibility"); break;
          case "1": runScriptLine("Pick Visibility"); break;
          case "2": runScriptLine("Assign Visibility"); break;
          case "3": UI_setTo_Modify_Visibility(3); break;
        }
        break;

      case "Change Weight":
        switch (this.Items[i][j]) {
          case "0": runScriptLine("Change Weight"); break;
          case "1": runScriptLine("Pick Weight"); break;
          case "2": runScriptLine("Assign Weight"); break;
          case "3": UI_setTo_Modify_Weight(3); break;
        }
        break;

      case "Normal":
        switch (this.Items[i][j]) {
          case "1": runScriptLine("Flip Normal"); break;
          case "2": runScriptLine("Set-Out Normal"); break;
          case "3": runScriptLine("Set-In Normal"); break;
        }
        break;

      case "First Vertex":
        if ((this.Items[i][j]).equals("")) runScriptLine("Get FirstVertex");
        break;

      // Power/Scale/Move/GetLength all cleanly have an existing action
      // for every j-1 value this button can produce - unlike Rotate
      // just below, none of these have a 0/1/2/3(/4) mismatch.
      case "Power":
        if (j - 1 == 0) runScriptLine("PowerX");
        else if (j - 1 == 1) runScriptLine("PowerY");
        else if (j - 1 == 2) runScriptLine("PowerZ");
        else runScriptLine("Power");
        break;

      // "ScaleX"/"ScaleY"/"ScaleZ" are fine (not in bypassAllActionsFor),
      // but bare "Scale" collides with the "SCALE s=? sx=? sy=? sz=?
      // x=? y=? z=?" switch-case command - "scale" is in
      // bypassAllActionsFor for that command's own sake, so
      // runScriptLine("Scale") would silently reach that command's
      // no-args hint branch instead of the putAction-registered
      // UI_setTo_Modify_Scale(3). Found by checking every name used here
      // against bypassAllActionsFor directly (not assumed safe), the
      // same way "Rotate" below was found. j-1==3 kept as the direct
      // call it already was.
      case "Scale":
        if (j - 1 == 0) runScriptLine("ScaleX");
        else if (j - 1 == 1) runScriptLine("ScaleY");
        else if (j - 1 == 2) runScriptLine("ScaleZ");
        else UI_setTo_Modify_Scale(j - 1);
        break;

      // Same reasoning as Scale above: bare "Move" collides with the
      // "MOVE dx=? dy=? dz=?" switch-case command ("move" is in
      // bypassAllActionsFor for that command's sake), so j-1==3 stays a
      // direct call; "MoveX"/"MoveY"/"MoveZ" are fine.
      case "Move":
        if (j - 1 == 0) runScriptLine("MoveX");
        else if (j - 1 == 1) runScriptLine("MoveY");
        else if (j - 1 == 2) runScriptLine("MoveZ");
        else UI_setTo_Modify_Move(j - 1);
        break;

      case "Get Length":
        if (j - 1 == 0) runScriptLine("Get dX");
        else if (j - 1 == 1) runScriptLine("Get dY");
        else if (j - 1 == 2) runScriptLine("Get dZ");
        else if (j - 1 == 3) runScriptLine("Get dXYZ");
        else if (j - 1 == 4) runScriptLine("Get dXY");
        else UI_setTo_Modify_GetLength(j - 1);
        break;

      // Per "maintain Rotate behavior as is", kept fully direct for
      // every value, unlike Power/Scale/Move/GetLength above. Two
      // separate, independent reasons, not one:
      // (1) actions.pde's own "Rotate" action maps to
      //     UI_setTo_Modify_Rotate(2), the same value as "RotateZ" - not
      //     (3), the way the all-axes variant of Power/Scale/Move/
      //     GetLength each correctly does. Routing j-1==3 through
      //     "Rotate" would silently change this button's all-axes case
      //     to Z-only.
      // (2) "RotateX"/"RotateY"/"RotateZ" (the would-be reuse for
      //     j-1==0/1/2) are each unreachable via runScriptLine(...) at
      //     all: "rotatex"/"rotatey"/"rotatez" are in
      //     bypassAllActionsFor, for the sake of the "ROTATE[X|Y|Z] r=?
      //     x=? y=? z=?" switch-case command - a real collision found
      //     by checking every name used on this page against
      //     bypassAllActionsFor directly, not assumed safe from Power/
      //     Scale/Move's own sibling names being fine. A first attempt
      //     at reusing these left rotationVectorIndex wrong for every
      //     value except 3 - caught by checking actual resulting state,
      //     not just that runScriptLine returned without error.
      case "Rotate": UI_setTo_Modify_Rotate(j - 1); break;

      case "Drop":
        if (j - 1 == 0) runScriptLine("Drop on LandSurface");
        else if (j - 1 == 1) runScriptLine("Drop on ModelSurface (Down)");
        else if (j - 1 == 2) runScriptLine("Drop on ModelSurface (Up)");
        else UI_setTo_Modify_Drop(j - 1);
        break;

      case "Projection Type":
        if (j - 1 == 0) runScriptLine("Orthographic");
        else if (j - 1 == 1) runScriptLine("Perspective");
        else UI_setTo_View_ProjectionType(j - 1);
        break;

      case "Pick Select":
        if (j - 1 == 0) runScriptLine("Pick Select");
        else if (j - 1 == 1) runScriptLine("Pick Select+");
        else if (j - 1 == 2) runScriptLine("Pick Select-");
        else UI_setTo_View_PickSelect(j - 1);
        break;

      case "Window Select":
        if (j - 1 == 0) runScriptLine("Window Select");
        else if (j - 1 == 1) runScriptLine("Window Select+");
        else if (j - 1 == 2) runScriptLine("Window Select-");
        else UI_setTo_View_WindowSelect(j - 1);
        break;

      case "PivotX":
        if (j - 2 == -1) runScriptLine("PivotX:Minimum");
        else if (j - 2 == 0) runScriptLine("PivotX:Center");
        else if (j - 2 == 1) runScriptLine("PivotX:Maximum");
        else UI_setTo_View_PivotX(j - 2);
        break;

      case "PivotY":
        if (j - 2 == -1) runScriptLine("PivotY:Minimum");
        else if (j - 2 == 0) runScriptLine("PivotY:Center");
        else if (j - 2 == 1) runScriptLine("PivotY:Maximum");
        else UI_setTo_View_PivotY(j - 2);
        break;

      case "PivotZ":
        if (j - 2 == -1) runScriptLine("PivotZ:Minimum");
        else if (j - 2 == 0) runScriptLine("PivotZ:Center");
        else if (j - 2 == 1) runScriptLine("PivotZ:Maximum");
        else UI_setTo_View_PivotZ(j - 2);
        break;

      case "Terrain Orbit": runScriptLine("TerrainOrbit"); break;

      case "Orbit":
        if (j - 1 == 0) runScriptLine("Orbit");
        else if (j - 1 == 1) runScriptLine("OrbitZ");
        else if (j - 1 == 2) runScriptLine("OrbitXY");
        else UI_setTo_View_Orbit(j - 1);
        break;

      case "Camera Roll":
        if (j - 1 == 0) runScriptLine("CameraRoll");
        else if (j - 1 == 1) runScriptLine("CameraRollZ");
        else if (j - 1 == 2) runScriptLine("CameraRollXY");
        else UI_setTo_View_CameraRoll(j - 1);
        break;

      case "Target Roll":
        if (j - 1 == 0) runScriptLine("TargetRoll");
        else if (j - 1 == 1) runScriptLine("TargetRollZ");
        else if (j - 1 == 2) runScriptLine("TargetRollXY");
        else UI_setTo_View_TargetRoll(j - 1);
        break;

      // Only index 0 has an existing action for any of these three -
      // kept as a direct call otherwise rather than assumed unreachable.
      case "Look At Origin":
        if (j - 1 == 0) runScriptLine("Look at origin");
        else UI_setTo_View_LookAtOrigin(j - 1);
        break;

      case "Look At Direction":
        if (j - 1 == 0) runScriptLine("Look at direction");
        else UI_setTo_View_LookAtDirection(j - 1);
        break;

      case "Look At Selection":
        if (j - 1 == 0) runScriptLine("Look at selection");
        else UI_setTo_View_LookAtSelection(j - 1);
        break;

      case "Pan":
        if (j - 1 == 0) runScriptLine("Pan");
        else if (j - 1 == 1) runScriptLine("PanX");
        else if (j - 1 == 2) runScriptLine("PanY");
        else UI_setTo_View_Pan(j - 1);
        break;

      case "Zoom":
        // "Zoom"/"Zoom as default" cover the UI_setTo_View_ZOOM(...)
        // call itself; the toolbar's own this.Items[i][0] reset is
        // this button's own bookkeeping, not part of either action, so
        // it stays here unchanged - same reasoning as mouseReleased.pde's
        // Section branch keeping its own extra bookkeeping separate from
        // the "Section" command it calls.
        if (j - 1 == 0) runScriptLine("Zoom");
        else if (j - 1 == 1) runScriptLine("Zoom as default");
        else UI_setTo_View_ZOOM(j - 1);
        this.Items[i][0] = "1"; // << set it to default choice next time
        break;

      case "Camera Distance": runScriptLine("CameraDistance"); break;

      case "Dist XY": runScriptLine("DistMouseXY"); break;

      case "Dist Z": runScriptLine("DistZ"); break; // NOTE: intentionally forwards to Truck

      case "Truck":
        if (j - 1 == 0) runScriptLine("TruckZ");
        else if (j - 1 == 1) runScriptLine("TruckX");
        else if (j - 1 == 2) runScriptLine("TruckY");
        else UI_setTo_View_Truck(j - 1);
        break;

      case "3D Model Size": runScriptLine("3DModelSize"); break;

      case "Skydome Size": runScriptLine("SkydomeSize"); break;

      case "All Model Size": runScriptLine("AllModelSize"); break;

      case "View Layout":
        if (j - 1 == 0) runScriptLine("Display All Viewports");
        else if (j - 1 == 1) runScriptLine("Enlarge 3D Viewport");
        else if (j - 1 == 2) runScriptLine("Enlarge Time Viewport");
        else if (j - 1 == 3) runScriptLine("Enlarge Map Viewport");
        else UI_setTo_Viewport(j - 1);
        break;

      case "View Point": {
        String[] viewPointNames = {"Top", "Front", "Left", "Back", "Right", "Bottom", "S.W.", "S.E.", "N.E.", "N.W."};
        int vpIndex = j - 1;
        if ((vpIndex >= 0) && (vpIndex < viewPointNames.length)) {
          runScriptLine(viewPointNames[vpIndex]);
        } else {
          UI_setTo_View_3DViewPoint(vpIndex);
        }
        break;
      }
    }
  }

  // Draws the icon for a toolbar item, if one exists for its Bar_Switch.
  // Each drawX method sets this.displayText = false as a side effect,
  // so the label is only shown for items with no dedicated icon.
  void drawIcon (String Bar_Switch, int j, float cx, float cy, float r) {

    switch (Bar_Switch) {
      case "Drop": this.drawDrop(j, cx, cy, r); break;
      case "Get Length": this.drawGetLength(j, cx, cy, r); break;
      case "Move": this.drawMove(j, cx, cy, r); break;
      case "Scale": this.drawScale(j, cx, cy, r); break;
      case "Power": this.drawPower(j, cx, cy, r); break;
      case "Rotate": this.drawRotate(j, cx, cy, r); break;
      case "Change Seed/Material": this.drawSeed(j, cx, cy, r); break;
      case "Change Tessellation": this.drawtessellation(j, cx, cy, r); break;
      case "Change Layer": this.drawLayer(j, cx, cy, r); break;
      case "Change Visibility": this.drawVisibility(j, cx, cy, r); break;
      case "Change Weight": this.drawWeight(j, cx, cy, r); break;
      case "Normal": this.drawNormal(j, cx, cy, r); break;
      case "First Vertex": this.drawFirstVertex(j, cx, cy, r); break;
      case "Pick Select": this.drawPickSelect(j, cx, cy, r); break;
      case "Window Select": this.drawWindowSelect(j, cx, cy, r); break;
      case "Projection Type": this.drawProjectionType(j, cx, cy, r); break;
      case "Zoom": this.drawZOOM(j, cx, cy, r); break;
      case "Terrain Orbit": this.drawTerrainOrbit(j, cx, cy, r); break;
      case "Orbit": this.drawOrbit(j, cx, cy, r); break;
      case "Camera Roll": this.drawCameraRoll(j, cx, cy, r); break;
      case "Target Roll": this.drawTargetRoll(j, cx, cy, r); break;
      case "Camera Distance": this.drawCameraDistance(j, cx, cy, r); break;
      case "Look At Origin": this.drawLookAtOrigin(j, cx, cy, r); break;
      case "Look At Direction": this.drawLookAtDirection(j, cx, cy, r); break;
      case "Look At Selection": this.drawLookAtSelection(j, cx, cy, r); break;
      case "Pan": this.drawPan(j, cx, cy, r); break;
      case "Dist XY": this.drawDistMouseXY(j, cx, cy, r); break;
      case "Dist Z": this.drawDistZ(j, cx, cy, r); break;
      case "Truck": this.drawTruck(j, cx, cy, r); break;
      case "3D Model Size": this.draw3DModelSize(j, cx, cy, r); break;
      case "Skydome Size": this.drawSkydomeSize(j, cx, cy, r); break;
      case "All Model Size": this.drawAllModelSize(j, cx, cy, r); break;
      case "View Layout": this.draw3DViewSpace(j, cx, cy, r); break;
    }
  }

  void drawMouse (int _type, float x, float y, float r) {

    float d = 0.4 * r;

    for (int i = 0; i < 3; i++) {

      float dx = 0;
      float dy = 0;

      if (i == 0) {
        dx = 0.5 * d;
        dy = 0.5 * d;
        strokeWeight(1);
        stroke(63);
        fill(63);
      } else if (i == 1) {
        strokeWeight(3);
        stroke(0);
        fill(0);
      } else {
        strokeWeight(1);
        stroke(1);
        stroke(255);
        fill(255);
      }

      pushMatrix();
      translate(x + d + dx, y + d + dy);

      triangle(-d, -d, -d, d, d, -d);

      if (i == 1) {
        strokeWeight(2 + d);
      } else {
        strokeWeight(d);
      }

      line(0, 0, d, d);

      popMatrix();
    }

    strokeWeight(0);
  }

  void drawPickSelect (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    fill(255);

    float d = 0.3 * r;
    triangle(-d, -d, -d, d, d, -d);

    strokeWeight(5);
    line(0, 0, d, d);

    stroke(0, 127, 255);
    strokeWeight(3);
    if (_type == 2) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
      line(-0.5 * r, -0.75 * r, -0.5 * r, -0.25 * r);
    }
    if (_type == 3) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawWindowSelect (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    fill(63);
    rect(-0.5 * r, -0.5 * r, 1.25 * r, 1.25 * r);

    strokeWeight(1);
    stroke(255);
    fill(255);

    float d = 0.3 * r;
    triangle(-d, -d, -d, d, d, -d);

    strokeWeight(5);
    line(0, 0, d, d);

    stroke(0, 127, 255);
    strokeWeight(3);
    if (_type == 2) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
      line(-0.5 * r, -0.75 * r, -0.5 * r, -0.25 * r);
    }
    if (_type == 3) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawDrop (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    fill(0);

    float d = 0.8 * r;

    if (_type == 1) {
      ellipse(0, 0, 2 * d, d);
    }
    if ((_type == 2) || (_type == 3)) {
      beginShape();
      vertex(0, 0.5 * d);
      vertex(funcs.cos_ang(30) * d, 0);
      vertex(0, -0.5 * d);
      vertex(-funcs.cos_ang(30) * d, 0);
      endShape(CLOSE);
    }




    strokeWeight(2);
    stroke(255);
    fill(0);

    if (_type == 1) {
      line(0, 0, 0, -d);
      line(0, 0, 0 - 0.25 * d, 0.25 * -d);
      line(0, 0, 0 + 0.25 * d, 0.25 * -d);

      line(0, 0, 0, d);
      line(0, 0, 0 - 0.25 * d, 0.25 * d);
      line(0, 0, 0 + 0.25 * d, 0.25 * d);
    }

    if (_type == 2) {
      line(0, 0.25 * d, 0, -d);
      line(0, 0.25 * d, 0 - 0.25 * d, 0);
      line(0, 0.25 * d, 0 + 0.25 * d, 0);
    }

    if (_type == 3) {
      line(0, 0.25 * -d, 0, d);
      line(0, 0.25 * -d, 0 - 0.25 * d, 0);
      line(0, 0.25 * -d, 0 + 0.25 * d, 0);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawGetLength (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    noFill();


    float d = 0.8 * r;

    beginShape();
    vertex(0, 0);
    vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
    vertex(0, -d);
    vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
    endShape(CLOSE);

    beginShape();
    vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
    vertex(0, 0);
    vertex(0, d);
    vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
    endShape(CLOSE);

    beginShape();
    vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
    vertex(0, 0);
    vertex(0, d);
    vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
    endShape(CLOSE);


    strokeWeight(2);
    stroke(0, 127, 255);
    fill(0);

    if (_type == 1) {
      line(0, 0, funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
    }
    if (_type == 2) {
      line(0, 0, funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
    }
    if (_type == 3) {
      line(0, 0, -funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
    }
    if (_type == 4) {
      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);
    }
    if (_type == 5) {
      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);
    }
    if (_type == 6) {
      line(0, 0, 0, -d);
    }


    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawMove (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(0, 0, 0.8 * r, 0);
    line(0, 0, 0, -0.8 * r);
    line(0, 0, -0.4 * r, 0.4 * r);

    strokeWeight(3);
    stroke(255);
    noFill();

    if (_type == 1) line(-0.8 * r, 0, 0.8 * r, 0);
    if (_type == 2) line(0.4 * r, -0.4 * r, -0.4 * r, 0.4 * r);
    if (_type == 3) line(0, 0.8 * r, 0, -0.8 * r);
    if (_type == 4) line(-0.4 * r, -0.4 * r, 0.4 * r, 0.4 * r);

    noStroke();
    fill(255, 0, 0);
    float d = 5;
    if (_type == 1) {
      ellipse(-0.8 * r, 0, d, d);
      ellipse(0.8 * r, 0, d, d);
    }
    if (_type == 2) {
      ellipse(0.4 * r, -0.4 * r, d, d);
      ellipse(-0.4 * r, 0.4 * r, d, d);
    }
    if (_type == 3) {
      ellipse(0, 0.8 * r, d, d);
      ellipse(0, -0.8 * r, d, d);
    }
    if (_type == 4) {
      ellipse(-0.4 * r, -0.4 * r, d, d);
      ellipse(0.4 * r, 0.4 * r, d, d);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }

  void drawScale (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(0, 0, 0.8 * r, 0);
    line(0, 0, 0, -0.8 * r);
    line(0, 0, -0.4 * r, 0.4 * r);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(-0.8 * r, 0, 0.8 * r, 0);
    line(0, 0.8 * r, 0, -0.8 * r);
    line(0.4 * r, -0.4 * r, -0.4 * r, 0.4 * r);

    strokeWeight(5);
    stroke(0, 255, 0);
    noFill();

    if (_type == 1) line(-0.4 * r, 0, 0.4 * r, 0);
    if (_type == 2) line(0.2 * r, -0.2 * r, -0.2 * r, 0.2 * r);
    if (_type == 3) line(0, 0.4 * r, 0, -0.4 * r);
    if (_type == 4) {
      line(-0.4 * r, 0, 0.4 * r, 0);
      line(0, 0.4 * r, 0, -0.4 * r);
      line(0.2 * r, -0.2 * r, -0.2 * r, 0.2 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawPower (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(0, 0, 0.8 * r, 0);
    line(0, 0, 0, -0.8 * r);
    line(0, 0, -0.4 * r, 0.4 * r);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(-0.8 * r, 0, 0.8 * r, 0);
    line(0, 0.8 * r, 0, -0.8 * r);
    line(0.4 * r, -0.4 * r, -0.4 * r, 0.4 * r);

    strokeWeight(3);
    stroke(0, 127, 255);
    noFill();

    if (_type == 1) line(-0.4 * r, 0, 0.4 * r, 0);
    if (_type == 2) line(0.2 * r, -0.2 * r, -0.2 * r, 0.2 * r);
    if (_type == 3) line(0, 0.4 * r, 0, -0.4 * r);
    if (_type == 4) {
      line(-0.4 * r, 0, 0.4 * r, 0);
      line(0, 0.4 * r, 0, -0.4 * r);
      line(0.2 * r, -0.2 * r, -0.2 * r, 0.2 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawRotate (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(0, 0, 0.8 * r, 0);
    line(0, 0, 0, -0.8 * r);
    line(0, 0, -0.4 * r, 0.4 * r);

    strokeWeight(3);
    stroke(255);
    noFill();

    if (_type == 1) line(-0.8 * r, 0, 0.8 * r, 0);
    if (_type == 2) line(0.4 * r, -0.4 * r, -0.4 * r, 0.4 * r);
    if (_type == 3) line(0, 0.8 * r, 0, -0.8 * r);

    strokeWeight(2);
    stroke(0, 127, 255);
    noFill();
    float d = 0.85 * r;
    if (_type == 1) {
      arc(0, 0, d, d, 0.25 * PI, 1.75 * PI);
    }
    if (_type == 2) {
      arc(0, 0, d, d, (0.25 + 0.75) * PI, (1.75 + 0.75) * PI);
    }
    if (_type == 3) {
      arc(0, 0, d, d, (0.25 - 0.5) * PI, (1.75 - 0.5) * PI);
    }


    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }





  void drawSeed (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(0, 0, 0.8 * r, 0);
    line(0, 0, 0, -0.8 * r);
    line(0, 0, -0.4 * r, 0.4 * r);

    strokeWeight(1);
    stroke(255);
    noFill();

    line(-0.8 * r, 0, 0.8 * r, 0);
    line(0, 0.8 * r, 0, -0.8 * r);
    line(0.4 * r, -0.4 * r, -0.4 * r, 0.4 * r);

    strokeWeight(1);
    stroke(255, 255, 0);
    noFill();

    for (int i = 0; i < 360; i += 30) {
      float d = random(0.25, 0.75);

      line(0, 0, 0.8 * r * d * cos(i), 0.8 * r * d * sin(i));
    }

    stroke(0, 127, 255);
    strokeWeight(3);
    if (_type == 2) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
    }
    if (_type == 3) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
      line(-0.5 * r, -0.75 * r, -0.5 * r, -0.25 * r);
    }
    if (_type == 4) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
      line(-0.7 * r, -0.3 * r, -0.3 * r, -0.7 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }



  void drawtessellation (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    float d = 1.25 * r;

    strokeWeight(2);
    stroke(255);
    fill(63);
    rect(-0.5 * d, -0.5 * d, d, d);

    strokeWeight(1);
    stroke(191);
    fill(191);

    for (int i = 1; i < 4; i++) {
      float w = (0.25 * i - 0.5) * d;
      line(-0.5 * d, w, 0.5 * d, w);
      line(w, -0.5 * d, w, 0.5 * d);
    }

    stroke(0, 127, 255);
    strokeWeight(3);
    if (_type == 2) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
    }
    if (_type == 3) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
      line(-0.5 * r, -0.75 * r, -0.5 * r, -0.25 * r);
    }
    if (_type == 4) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
      line(-0.7 * r, -0.3 * r, -0.3 * r, -0.7 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawLayer (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    float d = 0.8 * r;

    strokeWeight(1);
    stroke(255);
    fill(0);

    beginShape();
    vertex(0, d);
    vertex(funcs.cos_ang(30) * d, 0.5 * d);
    vertex(0, 0);
    vertex(-funcs.cos_ang(30) * d, 0.5 * d);
    endShape(CLOSE);

    strokeWeight(2);
    stroke(255);
    fill(0, 127, 255);

    beginShape();
    vertex(0, 0.5 * d);
    vertex(funcs.cos_ang(30) * d, 0);
    vertex(0, -0.5 * d);
    vertex(-funcs.cos_ang(30) * d, 0);
    endShape(CLOSE);

    stroke(0, 127, 255);
    strokeWeight(3);
    if (_type == 2) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
    }
    if (_type == 3) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
      line(-0.5 * r, -0.75 * r, -0.5 * r, -0.25 * r);
    }
    if (_type == 4) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
      line(-0.7 * r, -0.3 * r, -0.3 * r, -0.7 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawVisibility (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    float d = 0.8 * r;

    strokeWeight(1);
    stroke(255);
    fill(0);

    beginShape();
    vertex(0, d);
    vertex(funcs.cos_ang(30) * d, 0.5 * d);
    vertex(0, 0);
    vertex(-funcs.cos_ang(30) * d, 0.5 * d);
    endShape(CLOSE);

    strokeWeight(0);
    stroke(255);
    fill(127, 127);

    beginShape();
    vertex(0, 0.5 * d);
    vertex(funcs.cos_ang(30) * d, 0);
    vertex(0, -0.5 * d);
    vertex(-funcs.cos_ang(30) * d, 0);
    endShape(CLOSE);

    stroke(0, 127, 255);
    strokeWeight(3);
    if (_type == 2) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
    }
    if (_type == 3) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
      line(-0.5 * r, -0.75 * r, -0.5 * r, -0.25 * r);
    }
    if (_type == 4) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
      line(-0.7 * r, -0.3 * r, -0.3 * r, -0.7 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawWeight (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);


    strokeWeight(1);
    stroke(255);
    fill(63);
    //rect(-0.5 * r, -0.5 * r, r, r);

    float d = r * pow(2, 0.5);

    strokeWeight(1);
    noFill();
    ellipse(0, 0, d, d);

    strokeWeight(1);
    noFill();
    arc(0, -r, d, d, 0.25 * PI, 0.75 * PI);
    arc(r, 0, d, d, 0.75 * PI, 1.25 * PI);
    arc(0, r, d, d, 1.25 * PI, 1.75 * PI);
    arc(-r, 0, d, d, 1.75 * PI, 2.25 * PI);


    stroke(0, 127, 255);
    strokeWeight(3);
    if (_type == 2) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
    }
    if (_type == 3) {
      line(-0.75 * r, -0.5 * r, -0.25 * r, -0.5 * r);
      line(-0.5 * r, -0.75 * r, -0.5 * r, -0.25 * r);
    }
    if (_type == 4) {
      line(-0.7 * r, -0.7 * r, -0.3 * r, -0.3 * r);
      line(-0.7 * r, -0.3 * r, -0.3 * r, -0.7 * r);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawNormal (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    float d = 0.8 * r;

    strokeWeight(2);
    stroke(255);
    fill(0);

    beginShape();
    vertex(0, 0.5 * d);
    vertex(funcs.cos_ang(30) * d, 0);
    vertex(0, -0.5 * d);
    vertex(-funcs.cos_ang(30) * d, 0);
    endShape(CLOSE);

    if (_type == 1) {
      line(0, 0, 0, -d);
      line(0 - 0.25 * d, -d + 0.25 * d, 0, -d);
      line(0 + 0.25 * d, -d + 0.25 * d, 0, -d);

      line(0, 0.5 * d, 0, d);
      line(0 - 0.25 * d, d - 0.25 * d, 0, d);
      line(0 + 0.25 * d, d - 0.25 * d, 0, d);
    }

    if (_type == 2) {
      line(0, 0, 0, -d);
      line(0 - 0.25 * d, -d + 0.25 * d, 0, -d);
      line(0 + 0.25 * d, -d + 0.25 * d, 0, -d);
    }


    if (_type == 3) {
      line(0, 0, 0, d);
      line(0 - 0.25 * d, d - 0.25 * d, 0, d);
      line(0 + 0.25 * d, d - 0.25 * d, 0, d);
    }


    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawFirstVertex (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    float d = 0.8 * r;

    strokeWeight(2);
    stroke(255);
    fill(0);

    beginShape();
    vertex(0, d);
    vertex(funcs.cos_ang(30) * d, 0.5 * d);
    vertex(0, 0);
    vertex(-funcs.cos_ang(30) * d, 0.5 * d);
    endShape(CLOSE);

    stroke(255, 0, 0);
    ellipse(0, 0, 0.25 * d, 0.25 * d);

    fill(255);
    textSize(d);
    textAlign(CENTER, BOTTOM);
    text("1st", 0, 0);

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }



  void draw3DViewSpace (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(2);
    stroke(255);
    noFill();

    strokeWeight(1);
    stroke(255);
    if (_type == 1) fill(63);
    if (_type == 2) fill(191);
    rect(-0.75 * r, -0.75 * r, 1.5 * r, 1.5 * r);

    if (_type == 1) fill(191);
    if (_type == 2) fill(63);
    rect(-0.75 * r, -0.75 * r, 0.75 * r, 0.75 * r);

    strokeWeight(2);
    line(0, 0, 0.75 * r, 0.75 * r);

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }

  void drawProjectionType (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(2);
    stroke(255);
    fill(0);


    float d = 0.8 * r;

    if (_type == 1) {

      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);
    }

    if (_type == 2) {

      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0.75 * funcs.sin_ang(0) * d, 0.75 * -funcs.cos_ang(0) * d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(0.75 * funcs.sin_ang(120) * d, 0.75 * -funcs.cos_ang(120) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(0.75 * funcs.sin_ang(240) * d, 0.75 * -funcs.cos_ang(240) * d);
      endShape(CLOSE);
    }



    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawTruck (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);


    stroke(255);
    fill(0);

    float d = 0.625 * r;

    float a = 0;
    float b = 0;
    if (_type == 1) {
      a = funcs.cos_ang(30) * d;
      b = -funcs.sin_ang(30) * d;
    }
    if (_type == 2) {
      a = -funcs.cos_ang(30) * d;
      b = -funcs.sin_ang(30) * d;
    }
    if (_type == 3) {
      a = 0;
      b = d;
    }

    strokeWeight(1);
    {
      pushMatrix();
      translate(0.5 * a, 0.5 * b);

      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      popMatrix();
    }




    strokeWeight(2);
    {
      pushMatrix();
      translate(-0.5 * a, -0.5 * b);

      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      popMatrix();
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }




  void drawZOOM (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    {
      pushMatrix();
      translate(0.25 * r, 0.25 * r);

      stroke(255);

      fill(0);
      strokeWeight(1);
      ellipse(-0.4 * r, -0.4 * r, 0.8 * r, 0.8 * r);

      noFill();
      strokeWeight(4);
      line(-0.1 * r, -0.1 * r, 0.3 * r, 0.3 * r);

      strokeWeight(2);
      stroke(255, 255, 0);
      if (_type == 1) {
        line(-0.6 * r, -0.4 * r, -0.2 * r, -0.4 * r);
        line(-0.4 * r, -0.6 * r, -0.4 * r, -0.2 * r);
      }
      if (_type == 2) {
        line(-0.6 * r, -0.4 * r, -0.2 * r, -0.4 * r);
      }

      popMatrix();
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }



  void draw3DModelSize (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    stroke(255);
    fill(0);
    strokeWeight(2);
    ellipse(0, 0, r, r);
    noFill();
    strokeWeight(1);
    ellipse(0, 0, 1.5 * r, 1.5 * r);

    strokeWeight(1);
    line(-0.75 * r, 0, -0.5 * r, 0);
    line(0, -0.75 * r, 0, -0.5 * r);
    line(0.75 * r, 0, 0.5 * r, 0);
    line(0, 0.75 * r, 0, 0.5 * r);


    strokeWeight(2);
    stroke(255, 255, 0);
    line(-0.2 * r, 0, 0.2 * r, 0);
    line(0, -0.2 * r, 0, 0.2 * r);

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }





  void drawAllModelSize (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    float d = 0.75 * r;

    stroke(255);
    fill(0);
    strokeWeight(1);
    ellipse(0, 0, d, d);
    noFill();
    strokeWeight(1);
    ellipse(0, 0, 2 * d, 2 * d);

    strokeWeight(1);
    line(-1 * d, 0, -0.5 * d, 0);
    line(0, -1 * d, 0, -0.5 * d);
    line(1 * d, 0, 0.5 * d, 0);
    line(0, 1 * d, 0, 0.5 * d);


    strokeWeight(2);
    stroke(255, 255, 0);
    line(-0.2 * r, 0, 0.2 * r, 0);
    line(0, -0.2 * r, 0, 0.2 * r);

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawSkydomeSize (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    {
      pushMatrix();
      translate(0, 0.125 * r);

      float d = 1.0 * r;

      strokeWeight(1);
      stroke(255);
      fill(0);
      arc(0, 0, d, d, PI, 2 * PI);
      arc(0, 0, d, 0.333 * d, 0, PI);

      d = 1.5 * r;

      strokeWeight(2);
      stroke(255);
      noFill();
      arc(0, 0, d, d, PI, 2 * PI);
      arc(0, 0, d, 0.333 * d, 0, PI);

      popMatrix();
    }

    strokeWeight(2);
    stroke(255, 255, 0);
    line(-0.2 * r, 0, 0.2 * r, 0);
    line(0, -0.2 * r, 0, 0.2 * r);

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawTerrainOrbit (int _type, float x, float y, float r) {

    {
      pushMatrix();
      translate(x, y);
      translate(-0.333 * r, -0.333 * r); // <<<<<<

      float d = 1.0 * r;

      strokeWeight(1);
      stroke(255);
      fill(0);
      ellipse(0, 0, d, d);

      strokeWeight(2);
      stroke(255);
      noFill();

      if (_type == 3) arc(0, 0, d, 0.333 * d, 0, PI);
      if (_type == 2) arc(0, 0, 0.333 * d, d, 0.5 * PI, 1.5 * PI);
      if (_type == 1) {
        arc(0, 0, 0.333 * d, d, 0.5 * PI, 1.5 * PI);
        arc(0, 0, d, 0.333 * d, 0, PI);
      }

      strokeWeight(0);

      popMatrix();
    }

    {
      pushMatrix();
      translate(x, y);
      translate(0.333 * r, 0.333 * r); // <<<<<<

      float d = 0.75 * r;

      strokeWeight(1);
      stroke(255);
      noFill();
      arc(0, 0, d, d, 0, PI);

      stroke(255);
      noFill();

      for (float i = -1.5; i <= 1.5; i++) {
        line(i * 0.25 * d - 0.125 * d, -0.5 * d, i * 0.25 * d + 0.125 * d, 0);

        if (i < 1.5) arc(i * 0.25 * d, -0.5 * d, 0.25 * d, 0.25 * d, PI, 2*PI);
      }

      strokeWeight(0);

      popMatrix();
    }

    this.displayText = false;
  }

  void drawOrbit (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    float d = 1.5 * r;

    strokeWeight(1);
    stroke(255);
    fill(0);
    ellipse(0, 0, d, d);

    strokeWeight(2);
    stroke(255);
    noFill();

    if (_type == 3) arc(0, 0, d, 0.333 * d, 0, PI);
    if (_type == 2) arc(0, 0, 0.333 * d, d, 0.5 * PI, 1.5 * PI);
    if (_type == 1) {
      arc(0, 0, 0.333 * d, d, 0.5 * PI, 1.5 * PI);
      arc(0, 0, d, 0.333 * d, 0, PI);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawLookAtOrigin (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(2);
    stroke(255);
    fill(127, 63, 0);

    {
      float d = 0.8 * r;

      line(0, 0, funcs.cos_ang(90) * d, -funcs.sin_ang(90) * d);
      line(0, 0, funcs.cos_ang(210) * d, -funcs.sin_ang(210) * d);
      line(0, 0, funcs.cos_ang(330) * d, -funcs.sin_ang(330) * d);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawLookAtDirection (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(2);
    stroke(255);
    fill(127, 63, 0);

    {
      float d = 0.8 * r;

      line(-d,d/2,d,d/2);
      line(d/2,-d,d/2,d);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawLookAtSelection (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(2);
    stroke(255);
    fill(127, 63, 0);

    {
      float d = 0.8 * r;

      line(0, 0, funcs.cos_ang(90) * d, -funcs.sin_ang(90) * d);
      line(0, 0, funcs.cos_ang(210) * d, -funcs.sin_ang(210) * d);
      line(0, 0, funcs.cos_ang(330) * d, -funcs.sin_ang(330) * d);
    }

    {
      //float d = 0.625 * r;
      float d = 0.5 * r;

      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawCameraRoll (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    {
      float d = 1.5 * r;

      strokeWeight(1);
      stroke(255);
      fill(0);
      ellipse(0, 0, d, d);
    }


    strokeWeight(1);
    stroke(255);
    fill(127, 63, 0);
    {
      //float d = 0.625 * r;
      float d = 0.5 * r;

      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);
    }



    {
      float d = 1.5 * r;

      strokeWeight(2);
      stroke(255);
      noFill();

      if (_type == 3) arc(0, 0, d, 0.333 * d, 0, PI);
      if (_type == 2) arc(0, 0, 0.333 * d, d, 0.5 * PI, 1.5 * PI);
      if (_type == 1) {
        arc(0, 0, 0.333 * d, d, 0.5 * PI, 1.5 * PI);
        arc(0, 0, d, 0.333 * d, 0, PI);
      }
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }



  void drawTargetRoll (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    {

      float d = 1.5 * r;

      strokeWeight(1);
      stroke(255);
      fill(0);
      rect(-d/2, -d/2, d, d);

      strokeWeight(2);
      stroke(255);
      noFill();

      if (_type == 3) arc(0, 0, d, 0.333 * d, PI, 2 * PI);
      if (_type == 2) arc(0, 0, 0.333 * d, d, -0.5 * PI, 0.5 * PI);
      if (_type == 1) {
        arc(0, 0, 0.333 * d, d, -0.5 * PI, 0.5 * PI);
        arc(0, 0, d, 0.333 * d, PI, 2 * PI);
      }
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }


  void drawPan (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    {
      float d = 1.0 * r;

      strokeWeight(1);
      stroke(255);
      noFill();
      arc(0, 0, d, d, 0, PI);

      stroke(255);
      noFill();

      for (float i = -1.5; i <= 1.5; i++) {
        line(i * 0.25 * d - 0.125 * d, -0.5 * d, i * 0.25 * d + 0.125 * d, 0);

        if (i < 1.5) arc(i * 0.25 * d, -0.5 * d, 0.25 * d, 0.25 * d, PI, 2*PI);
      }
    }

    strokeWeight(2);
    stroke(255);
    noFill();
    {
      float d = 0.75 * r;

      if (_type == 2) {
        line(-1 * d, 0, -0.5 * d, 0);
        line(1 * d, 0, 0.5 * d, 0);
      }
      if (_type == 3) {
        line(0, -1 * d, 0, -0.5 * d);
        line(0, 1 * d, 0, 0.5 * d);
      }
    }

    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }



  void drawDistMouseXY (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    line(-r, -0.5 * r, r, -0.5 * r);
    strokeWeight(2);
    line(-0.5 * r, -0.5 * r, r, 0);
    line(-0.5 * r, -0.5 * r, -r, 0);
    strokeWeight(2);
    line(-0.5 * r, -0.5 * r, 0, r);


    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }



  void drawCameraDistance (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    line(-r, 0, r, 0);
    strokeWeight(2);
    line(0, 0, r, 0.5 * r);
    line(0, 0, -r, 0.5 * r);
    strokeWeight(2);
    line(0, 0, 0, r);

    strokeWeight(1);
    stroke(255);
    fill(127, 63, 0);
    {
      //float d = 0.625 * r;
      float d = 0.5 * r;

      beginShape();
      vertex(0, 0);
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, -d);
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      endShape(CLOSE);

      beginShape();
      vertex(funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);

      beginShape();
      vertex(-funcs.cos_ang(30) * d, -funcs.sin_ang(30) * d);
      vertex(0, 0);
      vertex(0, d);
      vertex(-funcs.cos_ang(30) * d, (1 - funcs.sin_ang(30)) * d);
      endShape(CLOSE);
    }


    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }



  void drawDistZ (int _type, float x, float y, float r) {

    pushMatrix();
    translate(x, y);

    strokeWeight(1);
    stroke(255);
    line(-r, 0, r, 0);
    strokeWeight(2);
    line(0, 0, r, 0.5 * r);
    line(0, 0, -r, 0.5 * r);
    strokeWeight(2);
    line(0, 0, 0, r);


    strokeWeight(0);

    popMatrix();

    this.displayText = false;
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
