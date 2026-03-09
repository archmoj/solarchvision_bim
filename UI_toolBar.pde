class solarchvision_UI_toolBar {

  private final static String CLASS_STAMP = "UI_toolBar";

  boolean update = true;

  float tab = SOLARCHVISION_pixel_B;

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
      "1", "", "Land Orbit", "1.0"
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
      "3", "3D-Tree", "2D-Tree", "Person", "Living Type", "1.5"
    }
    ,
    {
      "1", "House1", "House2", "House3", "Box", "Cushion", "Cylinder", "Sphere", "Octahedron", "Icosahedron", "Pyramid", "Hyper", "Plane", "Polygon", "Extrude", "Parametric", "Point", "Polyline", "Surface", "Building Type", "2.5"
    }
    ,
    {
      "1", "Mesh", "Solid", "Model Type", "2.0"
    }
    ,

    {
      "4", "Land", "1D", "2D", "Group", "Face", "Vertex", "Soft", "Solid", "Section", "Camera", "Polyline", "Layer Type", "2.0"
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

  void draw () {

    if (this.update) {

      this.updated();

      fill(0);
      noStroke();
      rect(0, SOLARCHVISION_pixel_A, width, SOLARCHVISION_pixel_B);

      X_control = 0; //0.25 * MessageSize;
      Y_control = SOLARCHVISION_pixel_A + 0.5 * SOLARCHVISION_pixel_B;

      float cx = X_control;
      float cy = Y_control;
      float cr = 0.5 * SOLARCHVISION_pixel_B;

      for (int i = 0; i < this.Items.length; i++) {

        {
          String Bar_Switch = this.Items[i][this.Items[i].length - 2];

          if (Bar_Switch.equals("Layer Type")) {
            this.Items[i][0] = nf(current_ObjectCategory + 1, 0);
          }
        }



        int j = int(this.Items[i][0]);

        float Item_width = this.tab * float(this.Items[i][this.Items[i].length - 1]);

        noFill();
        stroke(255);
        strokeWeight(1);
        rect(cx, cy - cr, Item_width, SOLARCHVISION_pixel_B);
        strokeWeight(0);



        if (isInside(SOLARCHVISION_X_clicked, SOLARCHVISION_Y_clicked, cx, cy - cr, cx + Item_width, cy + cr)) {
          String Bar_Switch = this.Items[i][this.Items[i].length - 2];

          if (mouseButton == CENTER) {
            HelperState = !HelperState;
            if(HelperState) {
              String HelperText = Bar_Switch;
              if(
                this.Items[i].length > 4 &&
                this.Items[i][j] != "" &&
                Bar_Switch != "View Point"
              ) {
                HelperText += ": " + this.Items[i][j];
              }

              float estimatedWidth = HelperText.length() * MessageSize * 0.55;

              // draw over menu bar
              float HelperY = cy - cr - SOLARCHVISION_pixel_A;
              float HelperH = SOLARCHVISION_pixel_A;
              float HelperX = cx;
              float HelperW = max(SOLARCHVISION_pixel_B * 2, estimatedWidth);
              if(HelperX + HelperW > width) HelperX -= HelperW - SOLARCHVISION_pixel_B;

              fill(127, 255, 0);
              noStroke();
              rect(HelperX, HelperY, HelperW, HelperH);

              fill(0);
              text(HelperText, HelperX, HelperY, HelperW, HelperH);

              noFill();
              stroke(127, 255, 0);
              strokeWeight(4);
              rect(cx + 4, cy - cr + 4, Item_width - 8, SOLARCHVISION_pixel_B - 8);
              strokeWeight(0);

            } else {
              UI_menuBar.revise();
            }
          } else {

            if (mouseButton == RIGHT) {

              if (this.Selection != i) {
                this.Selection = i;
              } else {

                int n = int(this.Items[i][0]);

                n -= 1;

                if (n <= 0) n = this.Items[i].length - 3;

                this.Items[i][0] = nf(n, 0);

                j = n;
              }

              if(HelperState) {
                HelperState = false;
                UI_menuBar.revise();
              }
            }

            if (mouseButton == LEFT) {

              if (this.Selection != i) {
                this.Selection = i;
              } else {

                int n = int(this.Items[i][0]);

                n += 1;

                if (n >= this.Items[i].length - 2) n = 1;

                this.Items[i][0] = nf(n, 0);

                j = n;
              }

              if(HelperState) {
                HelperState = false;
                UI_menuBar.revise();
              }
            }

            fill(255, 127, 0);
            noStroke();
            rect(cx, cy - cr, Item_width, SOLARCHVISION_pixel_B);

            if (Bar_Switch.equals("Layer Type")) {
              current_ObjectCategory = j - 1;

              if (current_ObjectCategory == ObjectCategory.SOFTVERTEX) {
                Select3D.convert_Vertex_to_softSelection();
              }

              ROLLOUT.revise();
              SOLARCHVISION_view_changed();
            }

            if (Bar_Switch.equals("Model Type")) {
              User3D.create_MeshOrSolid = j - 1;

              ROLLOUT.revise();
            }

            if ((Bar_Switch.equals("Living Type")) || (Bar_Switch.equals("Building Type"))) {
              if ((this.Items[i][j]).equals("3D-Tree")) UI_set_to_Create_allModel1Ds();
              else if ((this.Items[i][j]).equals("2D-Tree")) UI_set_to_Create_Tree();
              else if ((this.Items[i][j]).equals("Person")) UI_set_to_Create_Person();
              else if ((this.Items[i][j]).equals("Point")) UI_set_to_Create_Vertex();
              else if ((this.Items[i][j]).equals("Polyline")) UI_set_to_Create_Polyline();
              else if ((this.Items[i][j]).equals("Surface")) UI_set_to_Create_Face();
              else if ((this.Items[i][j]).equals("Pyramid")) UI_set_to_Create_Pyramid();
              else if ((this.Items[i][j]).equals("Plane")) UI_set_to_Create_Plane();
              else if ((this.Items[i][j]).equals("Polygon")) UI_set_to_Create_Polygon();
              else if ((this.Items[i][j]).equals("Extrude")) UI_set_to_Create_Extrude();
              else if ((this.Items[i][j]).equals("Hyper")) UI_set_to_Create_Hyper();
              else if ((this.Items[i][j]).equals("House3")) UI_set_to_Create_House3();
              else if ((this.Items[i][j]).equals("House2")) UI_set_to_Create_House2();
              else if ((this.Items[i][j]).equals("House1")) UI_set_to_Create_House1();
              else if ((this.Items[i][j]).equals("Box")) UI_set_to_Create_Box();
              else if ((this.Items[i][j]).equals("Icosahedron")) UI_set_to_Create_Octahedron();
              else if ((this.Items[i][j]).equals("Octahedron")) UI_set_to_Create_Octahedron();
              else if ((this.Items[i][j]).equals("Sphere")) UI_set_to_Create_Sphere();
              else if ((this.Items[i][j]).equals("Cylinder")) UI_set_to_Create_Cylinder();
              else if ((this.Items[i][j]).equals("Cushion")) UI_set_to_Create_Cushion();
              else if ((this.Items[i][j]).equals("Parametric")) UI_set_to_Create_Parametric(User3D.create_Parametric_Type);
            }

            if (Bar_Switch.equals("Change Seed/Material")) {
              if ((this.Items[i][j]).equals("0")) UI_set_to_Modify_Seed(0);
              if ((this.Items[i][j]).equals("1")) UI_set_to_Modify_Seed(1);
              if ((this.Items[i][j]).equals("2")) UI_set_to_Modify_Seed(2);
              if ((this.Items[i][j]).equals("3")) UI_set_to_Modify_Seed(3);
            }

            if (Bar_Switch.equals("Change Tessellation")) {
              if ((this.Items[i][j]).equals("0")) UI_set_to_Modify_Tessellation(0);
              if ((this.Items[i][j]).equals("1")) UI_set_to_Modify_Tessellation(1);
              if ((this.Items[i][j]).equals("2")) UI_set_to_Modify_Tessellation(2);
              if ((this.Items[i][j]).equals("3")) UI_set_to_Modify_Tessellation(3);
            }

            if (Bar_Switch.equals("Change Layer")) {
              if ((this.Items[i][j]).equals("0")) UI_set_to_Modify_Layer(0);
              if ((this.Items[i][j]).equals("1")) UI_set_to_Modify_Layer(1);
              if ((this.Items[i][j]).equals("2")) UI_set_to_Modify_Layer(2);
              if ((this.Items[i][j]).equals("3")) UI_set_to_Modify_Layer(3);
            }

            if (Bar_Switch.equals("Change Visibility")) {
              if ((this.Items[i][j]).equals("0")) UI_set_to_Modify_Visibility(0);
              if ((this.Items[i][j]).equals("1")) UI_set_to_Modify_Visibility(1);
              if ((this.Items[i][j]).equals("2")) UI_set_to_Modify_Visibility(2);
              if ((this.Items[i][j]).equals("3")) UI_set_to_Modify_Visibility(3);
            }

            if (Bar_Switch.equals("Change Weight")) {
              if ((this.Items[i][j]).equals("0")) UI_set_to_Modify_Weight(0);
              if ((this.Items[i][j]).equals("1")) UI_set_to_Modify_Weight(1);
              if ((this.Items[i][j]).equals("2")) UI_set_to_Modify_Weight(2);
              if ((this.Items[i][j]).equals("3")) UI_set_to_Modify_Weight(3);
            }

            if (Bar_Switch.equals("Normal")) {
              if ((this.Items[i][j]).equals("1")) UI_set_to_Modify_Normal(1);
              if ((this.Items[i][j]).equals("2")) UI_set_to_Modify_Normal(2);
              if ((this.Items[i][j]).equals("3")) UI_set_to_Modify_Normal(3);
            }

            if (Bar_Switch.equals("First Vertex")) {
              if ((this.Items[i][j]).equals("")) UI_set_to_Modify_FirstVertex(1);
            }



            if (Bar_Switch.equals("Rotate")) UI_set_to_Modify_Rotate(j - 1);
            if (Bar_Switch.equals("Power")) UI_set_to_Modify_Power(j - 1);
            if (Bar_Switch.equals("Scale")) UI_set_to_Modify_Scale(j - 1);
            if (Bar_Switch.equals("Move")) UI_set_to_Modify_Move(j - 1);
            if (Bar_Switch.equals("Get Length")) UI_set_to_Modify_GetLength(j - 1);
            if (Bar_Switch.equals("Drop")) UI_set_to_Modify_Drop(j - 1);

            if (Bar_Switch.equals("Projection Type")) UI_set_to_View_ProjectionType(j - 1);

            if (Bar_Switch.equals("Pick Select")) UI_set_to_View_PickSelect(j - 1);
            if (Bar_Switch.equals("Window Select")) UI_set_to_View_WindowSelect(j - 1);

            if (Bar_Switch.equals("PivotX")) UI_set_to_View_PivotX(j - 2);
            if (Bar_Switch.equals("PivotY")) UI_set_to_View_PivotY(j - 2);
            if (Bar_Switch.equals("PivotZ")) UI_set_to_View_PivotZ(j - 2);

            if (Bar_Switch.equals("Land Orbit")) UI_set_to_View_LandOrbit(0);

            if (Bar_Switch.equals("Orbit")) UI_set_to_View_Orbit(j - 1);
            if (Bar_Switch.equals("Camera Roll")) UI_set_to_View_CameraRoll(j - 1);
            if (Bar_Switch.equals("Target Roll")) UI_set_to_View_TargetRoll(j - 1);

            if (Bar_Switch.equals("Look At Origin")) UI_set_to_View_LookAtOrigin(j - 1);
            if (Bar_Switch.equals("Look At Direction")) UI_set_to_View_LookAtDirection(j - 1);
            if (Bar_Switch.equals("Look At Selection")) UI_set_to_View_LookAtSelection(j - 1);

            if (Bar_Switch.equals("Pan")) {

              UI_set_to_View_Pan(j - 1);
            }

            if (Bar_Switch.equals("Zoom")) {
              UI_set_to_View_ZOOM(j - 1);

              this.Items[i][0] = "1"; // << set it to default choice next time
            }

            if (Bar_Switch.equals("Camera Distance")) UI_set_to_View_CameraDistance(0);

            if (Bar_Switch.equals("Dist XY")) UI_set_to_View_DistMouseXY(0);

            if (Bar_Switch.equals("Dist Z")) UI_set_to_View_Truck(0);
            if (Bar_Switch.equals("Truck")) UI_set_to_View_Truck(j - 1);

            if (Bar_Switch.equals("3D Model Size")) UI_set_to_View_3DModelSize();

            if (Bar_Switch.equals("Skydome Size")) UI_set_to_View_SkydomeSize();

            if (Bar_Switch.equals("All Model Size")) UI_set_to_View_AllModelSize();

            if (Bar_Switch.equals("View Layout")) UI_set_to_Viewport(j - 1);

            if (Bar_Switch.equals("View Point")) UI_set_to_View_3DViewPoint(j - 1);
          }
        }


        this.displayText = true;

        { // drawing the icons where available

          String Bar_Switch = this.Items[i][this.Items[i].length - 2];

          if (Bar_Switch.equals("Drop")) {
            UI_toolBar.drawDrop(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Get Length")) {
            UI_toolBar.drawGetLength(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Move")) {
            UI_toolBar.drawMove(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Scale")) {
            UI_toolBar.drawScale(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Power")) {
            UI_toolBar.drawPower(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Rotate")) {
            UI_toolBar.drawRotate(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Change Seed/Material")) {
            UI_toolBar.drawSeed(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Change Tessellation")) {
            UI_toolBar.drawtessellation(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Change Layer")) {
            UI_toolBar.drawLayer(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Change Visibility")) {
            UI_toolBar.drawVisibility(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Change Weight")) {
            UI_toolBar.drawWeight(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Normal")) {
            UI_toolBar.drawNormal(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("First Vertex")) {
            UI_toolBar.drawFirstVertex(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }

          if (Bar_Switch.equals("Pick Select")) {
            UI_toolBar.drawPickSelect(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Window Select")) {
            UI_toolBar.drawWindowSelect(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Projection Type")) {
            UI_toolBar.drawProjectionType(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Zoom")) {
            UI_toolBar.drawZOOM(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Land Orbit")) {
            UI_toolBar.drawLandOrbit(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Orbit")) {
            UI_toolBar.drawOrbit(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Camera Roll")) {
            UI_toolBar.drawCameraRoll(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Target Roll")) {
            UI_toolBar.drawTargetRoll(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Camera Distance")) {
            UI_toolBar.drawCameraDistance(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Look At Origin")) {
            UI_toolBar.drawLookAtOrigin(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Look At Direction")) {
            UI_toolBar.drawLookAtDirection(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Look At Selection")) {
            UI_toolBar.drawLookAtSelection(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Pan")) {
            UI_toolBar.drawPan(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Dist XY")) {
            UI_toolBar.drawDistMouseXY(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Dist Z")) {
            UI_toolBar.drawDistZ(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Truck")) {
            UI_toolBar.drawTruck(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("3D Model Size")) {
            UI_toolBar.draw3DModelSize(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("Skydome Size")) {
            UI_toolBar.drawSkydomeSize(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
          if (Bar_Switch.equals("All Model Size")) {
            UI_toolBar.drawAllModelSize(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }

          if (Bar_Switch.equals("View Layout")) {
            UI_toolBar.draw3DViewSpace(j, cx + 0.5 * Item_width, cy, 0.5 * SOLARCHVISION_pixel_B);
          }
        }

        if (this.displayText) { // writing titles where the icon is not available

          textAlign(CENTER, CENTER);
          stroke(255);
          fill(255);
          textSize(MessageSize);

          text(this.Items[i][j], cx + 0.5 * Item_width, cy);
        }


        cx += Item_width;
      }


      SOLARCHVISION_X_clicked = -1;
      SOLARCHVISION_Y_clicked = -1;
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


  void drawLandOrbit (int _type, float x, float y, float r) {

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
