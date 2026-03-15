class solarchvision_WIN3D {

  private final static String CLASS_STAMP = "WIN3D";

  // scales
  float scale;
  // (top-left) corner
  int cX = SOLARCHVISION_pixel_W;
  int cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
  // width and height
  int dX = SOLARCHVISION_pixel_W;
  int dY = SOLARCHVISION_pixel_H;
  float view_R = float(dY) / float(dX);

  float position_X = 0;
  float position_Y = 5;
  float position_Z = 60;
  float position_T = 1.0;

  float rotation_X = 90; //90; //75; //0;
  float rotation_Y = 0;
  float rotation_Z = 90; //0; //180; //135;
  float rotation_T = 5.0;

  float Zoom = 90.0; //60.0; // / (SOLARCHVISION_pixel_H / 300.0);

  int ViewType = 1; // 0: Ortho 1: Perspective

  boolean update = true;
  boolean include = true;

  boolean fullPeriod_IMG = false;
  boolean record_IMG = false;
  boolean record_AUTO = false;

  float ImageScale = 1.0;

  float CAM_x;
  float CAM_y;
  float CAM_z;
  float CAM_fov;
  float CAM_dist;

  float CAM_clipNear = 0.01;
  float CAM_clipFar = 2000000000.0;

  float refScale = 100; // it improves displaying the shaded scene!

  int currentCamera = 0; // 0 = Free Viewport | etc.= Saved Viewport

  int UI_CurrentTask = UITASK.Zoom_Orbit_Pan;
  int UI_OptionXorY = 0; // 0-1
  int UI_TaskModifyParameter = 0; //to modify objects with several parameters e.g. allModel1Ds

  int FacesShade = SHADE.Surface_Materials; //Shade_Surface_White; // <<<<<

  int Impact_TYPE = Impact_ACTIVE;


  PGraphics graphics;

  void put_3DViewport () {

    if (this.ViewType == 1) {

      float aspect = 1.0 / this.view_R;

      float zFar = this.CAM_dist * this.CAM_clipFar;
      float zNear = this.CAM_dist * this.CAM_clipNear;

      this.graphics.perspective(this.CAM_fov, aspect, zNear, zFar);
    } else {

      float ZOOM = WIN3D.Orthographic_ZOOM();

      this.graphics.ortho(ZOOM * this.dX * -1, ZOOM * this.dX * 1, ZOOM  * this.dY * -1, ZOOM  * this.dY * 1, 0.00001, 100000);
    }

    this.graphics.translate(0.5 * this.dX, 0.5 * this.dY, 0); // << IMPORTANT!

    this.graphics.translate(this.position_X * this.scale, this.position_Y * this.scale, this.position_Z * this.scale);

    this.graphics.rotateX(this.rotation_X * PI / 180);
    this.graphics.rotateZ(this.rotation_Z * PI / 180);
  }



  void drawView () {

    if (this.update) {
      if (Select3D.update_BoundingBox) {
        Select3D.calculate_BoundingBox();
      }

      if (this.record_IMG) this.ImageScale = 1; //2; //3;
      else this.ImageScale = 1;

      //////////////////////////////////
      this.dX *= this.ImageScale;
      this.dY *= this.ImageScale;
      //////////////////////////////////

      if (this.ImageScale != 1) {
        println("IMG:high-res");
        this.graphics = createGraphics(this.dX, this.dY, P3D);
      }

      int firstDay = IMPACTS_displayDay;
      int lastDay = IMPACTS_displayDay;

      if (this.fullPeriod_IMG) {
        this.fullPeriod_IMG = false;

        firstDay = 0;
        lastDay = STUDY.j_End;
      }

      int keep_IMPACTS_displayDay = IMPACTS_displayDay;
      for (IMPACTS_displayDay = lastDay; IMPACTS_displayDay >= firstDay; IMPACTS_displayDay--) {

        this.graphics.beginDraw();

        this.scale = this.dY / this.refScale; // fits field of view to window's height

        this.graphics.background(233);

        this.graphics.fill(127);
        this.graphics.strokeWeight(0);

        this.graphics.pushMatrix();

        this.graphics.hint(ENABLE_DEPTH_TEST);

        WIN3D.record_last3DViewport();

        WIN3D.transform_3DViewport();

        WIN3D.put_3DViewport();

        Sky3D.draw(TypeWindow.WIN3D);

        Sun3D.drawPattern(TypeWindow.WIN3D, 0, 0, 0, 0.975 * Sky3D.scale);

        Sun3D.drawPath(TypeWindow.WIN3D, 0, 0, 0, 0.975 * Sky3D.scale);

        Sun3D.drawGrid(TypeWindow.WIN3D, 0, 0, 0, 0.975 * Sky3D.scale, 0, 360);

        Sun3D.draw();

        Moon3D.draw();

        Earth3D.draw(TypeWindow.WIN3D);

        Land3D.draw(TypeWindow.WIN3D);

        Tropo3D.draw(TypeWindow.WIN3D);

        allFaces.draw(TypeWindow.WIN3D);

        allPolylines.draw(TypeWindow.WIN3D);

        allPoints.draw();

        allModel1Ds.draw(TypeWindow.WIN3D);

        allWindRoses.draw();

        allSections.draw(TypeWindow.WIN3D);

        allCameras.draw();

        allSolids.draw();

        allSolidImpacts.draw_lines();

        allSolidImpacts.draw_points();

        allModel2Ds.draw(TypeWindow.WIN3D);

        allWindFlows.draw(TypeWindow.WIN3D);

        this.graphics.hint(DISABLE_DEPTH_TEST);

        if ((this.record_IMG) || (this.record_AUTO)) {
        }
        else {
          WIN3D.draw_referencePivot();
        }

        this.graphics.popMatrix();


        this.drawPallet();

        this.graphics.endDraw();

        if ((this.record_IMG) || (this.record_AUTO)) {
          String myFile = MAKE_Filename(createStamp(1, CLASS_STAMP));

          if (this.Impact_TYPE == Impact_ACTIVE) {
            myFile += "_RAD";
          }
          if (this.Impact_TYPE == Impact_PASSIVE) {
            myFile += "_EFF";
          }
          myFile += "_" + importedObjectName;
          myFile += ".jpg";

          this.graphics.save(myFile);
          println("File created:" + myFile);
        }
      }
      IMPACTS_displayDay = keep_IMPACTS_displayDay;

      imageMode(CORNER);
      image(this.graphics, this.cX, this.cY, this.dX / this.ImageScale, this.dY / this.ImageScale);



      if ((this.record_IMG) || (this.record_AUTO == false)) this.record_IMG = false;

      //////////////////////////////////
      this.dX /= this.ImageScale;
      this.dY /= this.ImageScale;
      //////////////////////////////////

      if (this.ImageScale != 1) {
        this.graphics = createGraphics(this.dX, this.dY, P3D);
        this.updated();
      } else {
        this.updated();

        SOLARCHVISION_draw_Perspective_Internally();
      }

    }
  }



  void draw_referencePivot () {


    this.graphics.strokeWeight(3);
    this.graphics.stroke(127, 0, 255, 127);
    this.graphics.fill(127, 0, 255, 127);

    float[] P = Select3D.getPivot();

    float x = P[0];
    float y = P[1];
    float z = P[2];


    this.graphics.pushMatrix();
    this.graphics.translate(x * this.scale, -y * this.scale, z * this.scale);

    //this.graphics.sphere(1); // <<<<<< size

    this.graphics.popMatrix();

    this.graphics.strokeWeight(0);
  }



  void drawPallet () {

    boolean draw_pal = false;

    int PAL_type = 0;
    int PAL_direction = 1;
    float PAL_multiplier = 1;

    if ((this.FacesShade == SHADE.Global_Solar) ||
        (this.FacesShade == SHADE.Vertex_Solar)) {

      if (this.Impact_TYPE == Impact_ACTIVE) {
        PAL_type = allFaces.ACTIVE_pallet_CLR;
        PAL_direction = allFaces.ACTIVE_pallet_DIR;
        PAL_multiplier = allFaces.ACTIVE_pallet_MLT;
      }
      if (this.Impact_TYPE == Impact_PASSIVE) {
        PAL_type = allFaces.PASSIVE_pallet_CLR;
        PAL_direction = allFaces.PASSIVE_pallet_DIR;
        PAL_multiplier = allFaces.PASSIVE_pallet_MLT;
      }

      draw_pal = true;
    }

    if (this.FacesShade == SHADE.Vertex_Elevation) {

      PAL_type = Land3D.pallet_CLR;
      PAL_direction = Land3D.pallet_DIR;
      PAL_multiplier = Land3D.pallet_MLT;

      draw_pal = true;
    }

    if (this.FacesShade == SHADE.Vertex_Solid) {

      PAL_type = allSolids.pallet_CLR;
      PAL_direction = allSolids.pallet_DIR;
      PAL_multiplier = allSolids.pallet_MLT;

      draw_pal = true;
    }

    if (draw_pal) {

      float the_scale = 1;

      if (this.ViewType == 1) {
        the_scale *= (0.5 / tan(0.5 * this.CAM_fov));
      } else {
        float ZOOM = WIN3D.Orthographic_ZOOM();
        the_scale *= (0.5 / ZOOM);
      }

      this.graphics.pushMatrix();

      this.CAM_fov = this.Zoom * PI / 180;

      this.CAM_dist = (0.5 * this.refScale) / tan(0.5 * this.CAM_fov);

      if (this.ViewType == 1) {

        float aspect = 1.0 / this.view_R;

        float zFar = this.CAM_dist * 1000;
        float zNear = this.CAM_dist * 0.001;
      } else {

        float ZOOM = WIN3D.Orthographic_ZOOM();
      }

      this.graphics.translate(0.5 * this.dX, 0.5 * this.dY, 0); // << IMPORTANT!

      float pal_length = 1 * SOLARCHVISION_pixel_H * this.ImageScale / the_scale;

      float y1 = -0.2 * (pal_length / 11.0) + (0.4 * this.dY / the_scale);
      float y2 = y1 + 0.4 * (pal_length / 11.0);

      float txtSize = y2 - y1;

      float y = 0.5 * (y1 + y2) - 0.1 * txtSize;

      for (int q = 0; q < 11; q++) {

        float x1 = -0.5 * pal_length + q * (pal_length / 11.0);
        float x2 = x1 + (pal_length / 11.0);

        float x = 0.5 * (x1 + x2);

        float _u = 0.2 * q - 0.5;

        if ((this.FacesShade == SHADE.Global_Solar) ||
            (this.FacesShade == SHADE.Vertex_Solar)) {

          if (this.Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
          if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.2 * q - 0.5;
        }

        if (PAL_direction == -1) _u = 1 - _u;
        if (PAL_direction == -2) _u = 0.5 - 0.5 * _u;
        if (PAL_direction == 2) _u =  0.5 * _u;

        float[] COL = PAINT.getColorStyle(PAL_type, _u);

        this.graphics.stroke(COL[1], COL[2], COL[3], COL[0]);
        this.graphics.fill(COL[1], COL[2], COL[3], COL[0]);

        this.graphics.strokeWeight(0);

        this.graphics.beginShape();
        this.graphics.vertex(x1, y1, 0);
        this.graphics.vertex(x1, y2, 0);
        this.graphics.vertex(x2, y2, 0);
        this.graphics.vertex(x2, y1, 0);
        this.graphics.endShape(CLOSE);

        if (COL[1] + COL[2] + COL[3] > 1.75 * 255) {
          this.graphics.stroke(127);
          this.graphics.fill(127);
          this.graphics.strokeWeight(0);
        } else {
          this.graphics.stroke(255);
          this.graphics.fill(255);
          this.graphics.strokeWeight(2);
        }

        this.graphics.textSize(txtSize);
        this.graphics.textAlign(CENTER, CENTER);



        if ((this.FacesShade == SHADE.Global_Solar) ||
            (this.FacesShade == SHADE.Vertex_Solar)) {

          if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(nf((funcs.roundTo(0.1 * q / PAL_multiplier, 0.1)), 1, 1), x, y, 0);
          if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), x, y, 0);
        }

        if (this.FacesShade == SHADE.Vertex_Elevation) {
          this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), x, y, 0);
        }

        if (this.FacesShade == SHADE.Vertex_Solid) {
          this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), x, y, 0);
        }
      }

      this.graphics.noStroke();
      this.graphics.fill(127);

      String txt = "";

      this.graphics.textAlign(LEFT, CENTER);
      if (this.FacesShade == SHADE.Vertex_Elevation) {
      } else if (this.FacesShade == SHADE.Vertex_Solid) {
      } else {
        if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(" kW/m²", 0.5 * pal_length, y, 0);
        if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(" %kW°C/m²", 0.5 * pal_length, y, 0);

        txt += "SOLARCHVISION ";

        if (this.Impact_TYPE == Impact_ACTIVE) txt += "active model ";
        if (this.Impact_TYPE == Impact_PASSIVE) txt += "passive model ";

        if (IMPACTS_displayDay != 0) {
          txt += TIME.getDayText((IMPACTS_displayDay - 1) * STUDY.perDays + 286 + TIME.beginDay);
        }
        else {
          txt += TIME.getDayText( STUDY.j_Start    * STUDY.perDays + 286 + TIME.beginDay) + " - ";
          txt += TIME.getDayText((STUDY.j_End - 1) * STUDY.perDays + 286 + TIME.beginDay);
        }
      }

      this.graphics.textAlign(CENTER, CENTER);
      this.graphics.text(txt, 0, y1 - 1.0 * txtSize, 0);

      this.graphics.popMatrix();
    }
  }






  void keyPressed (KeyEvent e) {

    if ((e.isAltDown() != true) && (e.isControlDown() != true)) {

      if (key == CODED) {
        if (e.isShiftDown() == true) {
          switch(keyCode) {

          case UP :
          case DOWN :
            float[] P = Select3D.getPivot();

            float x0 = P[0];
            float y0 = P[1];
            float z0 = P[2];

            if (WIN3D.UI_CurrentTask == UITASK.Rotate) { // rotate
              float r = 5;
              if(keyCode == DOWN) r = -r;

              int the_Vector = Select3D.rotVector;
              Rotate3D.selection(x0, y0, z0, r, the_Vector);
              SOLARCHVISION_model_changed();
            }

            if (WIN3D.UI_CurrentTask == UITASK.Scale) { // scale
              float s = pow(2.0, 0.25);
              if(keyCode == DOWN) s = 1.0 / s;

              float sx = s;
              float sy = s;
              float sz = s;

              int the_Vector = Select3D.scaleVector;

              if (the_Vector == 0) { sy = 1; sz = 1; }
              if (the_Vector == 1) { sz = 1; sx = 1; }
              if (the_Vector == 2) { sx = 1; sy = 1; }

              Scale3D.selection(x0, y0, z0, sx, sy, sz);
              SOLARCHVISION_model_changed();
            }

            if (WIN3D.UI_CurrentTask == UITASK.Move) { // move

              float d = 0.5;
              if(keyCode == DOWN) d = -d;

              float dx = d;
              float dy = d;
              float dz = d;

              int the_Vector = Select3D.posVector;

              if (the_Vector == 0) { dy = 0; dz = 0; }
              if (the_Vector == 1) { dz = 0; dx = 0; }
              if (the_Vector == 2) { dx = 0; dy = 0; }

              Move3D.selection(dx, dy, dz);
              SOLARCHVISION_model_changed();
            }

            if (WIN3D.UI_TaskModifyParameter == 0) {
              if (WIN3D.UI_CurrentTask >= UITASK.Seed_Material) { // other properties

                int p = 1;
                if(keyCode == DOWN) p = -p;

                Edit3D.selection(p);

                SOLARCHVISION_model_changed();
              }
            }

            break;

          }
        } else {
          switch(keyCode) {

          case DOWN :
            WIN3D.rotateZ_3DViewport_around_Selection(this.rotation_T);
            this.revise();
            ROLLOUT.revise();
            break;

          case LEFT :
            WIN3D.rotateXY_3DViewport_around_Selection(-this.rotation_T);
            this.revise();
            ROLLOUT.revise();
            break;

          case RIGHT :
            WIN3D.rotateXY_3DViewport_around_Selection(this.rotation_T);
            this.revise();
            ROLLOUT.revise();
            break;

          case UP :
            WIN3D.rotateZ_3DViewport_around_Selection(-this.rotation_T);
            this.revise();
            ROLLOUT.revise();
            break;

          }
        }
      } else {
        switch(key) {

        case TAB:
          if (e.isShiftDown() == true) {
            this.Impact_TYPE = (this.Impact_TYPE + 1) % numberOfImpactVariations;
            if (this.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
            if (this.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;

            this.revise();
            ROLLOUT.revise();
          }
          break;

        case DELETE:
          Delete3D.selection();

          this.revise();
          ROLLOUT.revise();

          break;

        case ',' :
          if (this.ViewType == 1) {
            this.position_Z += this.position_T * OBJECTS_scale;
            this.revise();
            ROLLOUT.revise();
          } else {
            this.Zoom /= pow(2.0, 0.25);
            this.revise();
            ROLLOUT.revise();
          }
          break;

        case '.' :
          if (this.ViewType == 1) {
            this.position_Z -= this.position_T * OBJECTS_scale;
            this.revise();
            ROLLOUT.revise();
          } else {
            this.Zoom *= pow(2.0, 0.25);
            this.revise();
            ROLLOUT.revise();
          }
          break;

        case '0' :
          if (this.ViewType == 1) {
            this.position_Z += this.position_T * OBJECTS_scale;
            this.revise();
            ROLLOUT.revise();
          } else {
            this.Zoom /= pow(2.0, 0.25);
            this.revise();
            ROLLOUT.revise();
          }
          break;

        case '5' :
          WIN3D.look_3DViewport_towards_Selection();
          this.revise();
          ROLLOUT.revise();
          break;

        case '4' :
          this.rotation_Z += this.rotation_T;
          WIN3D.reverseTransform_3DViewport();
          this.revise();
          ROLLOUT.revise();
          break;
        case '6' :
          this.rotation_Z -= this.rotation_T;
          WIN3D.reverseTransform_3DViewport();
          this.revise();
          ROLLOUT.revise();
          break;
        case '8' :
          this.rotation_X -= this.rotation_T;
          WIN3D.reverseTransform_3DViewport();
          this.revise();
          ROLLOUT.revise();
          break;
        case '2' :
          this.rotation_X += this.rotation_T;
          WIN3D.reverseTransform_3DViewport();
          this.revise();
          ROLLOUT.revise();
          break;

        case '1' :
          this.position_X += this.position_T * OBJECTS_scale;
          this.revise();
          ROLLOUT.revise();
          break;
        case '3' :
          this.position_X -= this.position_T * OBJECTS_scale;
          this.revise();
          ROLLOUT.revise();
          break;
        case '7' :
          this.position_Y += this.position_T * OBJECTS_scale;
          this.revise();
          ROLLOUT.revise();
          break;
        case '9' :
          this.position_Y -= this.position_T * OBJECTS_scale;
          this.revise();
          ROLLOUT.revise();
          break;


        case '*' :
          WIN3D.move_3DViewport_towards_Selection(2.0);
          this.revise();
          ROLLOUT.revise();
          break;
        case '/' :
          WIN3D.move_3DViewport_towards_Selection(0.5);
          this.revise();
          ROLLOUT.revise();
          break;


        case '+' :
          this.Zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * this.Zoom));
          this.revise();
          ROLLOUT.revise();
          break;
        case '-' :
          this.Zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * this.Zoom));
          this.revise();
          ROLLOUT.revise();
          break;

        case 'c':
          this.currentCamera += 1;
          if (this.currentCamera > allCameras.num - 1) this.currentCamera = 0;
          WIN3D.apply_currentCamera();

          SOLARCHVISION_modify_Viewport_Title();

          this.revise();
          ROLLOUT.revise();
          break;

        case 'C':
          this.currentCamera -= 1;
          if (this.currentCamera < 0) this.currentCamera = allCameras.num - 1;
          WIN3D.apply_currentCamera();

          SOLARCHVISION_modify_Viewport_Title();

          this.revise();
          ROLLOUT.revise();
          break;


        case 't':
          Tropo3D.i_Map += TROPO_deltaTime;
          if (Tropo3D.i_Map > STUDY.i_End) Tropo3D.i_Map -= TROPO_deltaTime;
          WORLD.revise();
          WIN3D.revise();
          break;
        case 'T':
          Tropo3D.i_Map -= TROPO_deltaTime;
          if (Tropo3D.i_Map < STUDY.i_Start) Tropo3D.i_Map += TROPO_deltaTime;
          WORLD.revise();
          WIN3D.revise();
          break;

        case 'd' :
          IMPACTS_displayDay += 1;
          if (IMPACTS_displayDay > STUDY.j_End) IMPACTS_displayDay = 0;
          this.revise();
          ROLLOUT.revise();
          break;
        case 'D' :
          IMPACTS_displayDay -= 1;
          if (IMPACTS_displayDay < 0) IMPACTS_displayDay = STUDY.j_End;
          this.revise();
          ROLLOUT.revise();
          break;


        case ENTER:
          if (this.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
          if (this.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
          this.revise();
          ROLLOUT.revise();
          break;

        case ' ':
          SOLARCHVISION_RecordFrame();
          ROLLOUT.revise();
          break;

        }

      }
    }
  }


  float Orthographic_ZOOM () {

    float ZOOM = 0.5 * this.Zoom * PI / 180;

    ZOOM *= pow(pow(this.position_X, 2) + pow(this.position_Y, 2) + pow(this.position_Z, 2), 0.5);

    ZOOM /= this.refScale;

    return ZOOM;
  }



  void look_3DViewport_towards_Direction (float Image_X, float Image_Y) {

    WIN3D.lookXY_3DViewport_towards_Direction(Image_X, Image_Y);
    WIN3D.lookZ_3DViewport_towards_Direction(Image_X, Image_Y);
  }

  void lookXY_3DViewport_towards_Direction (float Image_X, float Image_Y) {

    float xO = this.CAM_x / OBJECTS_scale;
    float yO = this.CAM_y / OBJECTS_scale;
    float zO = this.CAM_z / OBJECTS_scale;

    float[] ray_end = WIN3D.calculate_Click3D(0, 0);
    float xA = ray_end[0] / OBJECTS_scale;
    float yA = ray_end[1] / OBJECTS_scale;
    float zA = ray_end[2] / OBJECTS_scale;

    float[] P = WIN3D.calculate_Click3D(Image_X, Image_Y);

    float xB = P[0] / OBJECTS_scale;
    float yB = P[1] / OBJECTS_scale;
    float zB = P[2] / OBJECTS_scale;


    this.rotation_Z += funcs.atan2_ang((yB - yO), (xB - xO)) - funcs.atan2_ang((yA - yO), (xA - xO));

    WIN3D.reverseTransform_3DViewport();
  }


  void lookZ_3DViewport_towards_Direction (float Image_X, float Image_Y) {

    float xO = this.CAM_x / OBJECTS_scale;
    float yO = this.CAM_y / OBJECTS_scale;
    float zO = this.CAM_z / OBJECTS_scale;

    float[] ray_end = WIN3D.calculate_Click3D(0, 0);
    float xA = ray_end[0] / OBJECTS_scale;
    float yA = ray_end[1] / OBJECTS_scale;
    float zA = ray_end[2] / OBJECTS_scale;

    float[] P = WIN3D.calculate_Click3D(Image_X, Image_Y);

    float xB = P[0] / OBJECTS_scale;
    float yB = P[1] / OBJECTS_scale;
    float zB = P[2] / OBJECTS_scale;

    this.rotation_X += funcs.atan2_ang((zB - zO), pow(pow(yB - yO, 2) + pow(xB - xO, 2), 0.5)) - funcs.atan2_ang((zA - zO), pow(pow(yA - yO, 2) + pow(xA - xO, 2), 0.5));

    WIN3D.reverseTransform_3DViewport();
  }


  void look_3DViewport_towards_Selection () {

    WIN3D.lookXY_3DViewport_towards_Selection();
    WIN3D.lookZ_3DViewport_towards_Selection();
  }

  void lookXY_3DViewport_towards_Selection () {

    float xO = this.CAM_x / OBJECTS_scale;
    float yO = this.CAM_y / OBJECTS_scale;
    float zO = this.CAM_z / OBJECTS_scale;

    float[] ray_end = WIN3D.calculate_Click3D(0, 0);
    float xA = ray_end[0] / OBJECTS_scale;
    float yA = ray_end[1] / OBJECTS_scale;
    float zA = ray_end[2] / OBJECTS_scale;

    float[] P = Select3D.getPivot();

    float xB = P[0];
    float yB = P[1];
    float zB = P[2];


    this.rotation_Z += funcs.atan2_ang((yB - yO), (xB - xO)) - funcs.atan2_ang((yA - yO), (xA - xO));

    WIN3D.reverseTransform_3DViewport();
  }


  void lookZ_3DViewport_towards_Selection () {

    float xO = this.CAM_x / OBJECTS_scale;
    float yO = this.CAM_y / OBJECTS_scale;
    float zO = this.CAM_z / OBJECTS_scale;

    float[] ray_end = WIN3D.calculate_Click3D(0, 0);
    float xA = ray_end[0] / OBJECTS_scale;
    float yA = ray_end[1] / OBJECTS_scale;
    float zA = ray_end[2] / OBJECTS_scale;

    float[] P = Select3D.getPivot();

    float xB = P[0];
    float yB = P[1];
    float zB = P[2];

    this.rotation_X += funcs.atan2_ang((zB - zO), pow(pow(yB - yO, 2) + pow(xB - xO, 2), 0.5)) - funcs.atan2_ang((zA - zO), pow(pow(yA - yO, 2) + pow(xA - xO, 2), 0.5));

    WIN3D.reverseTransform_3DViewport();
  }

  void move_3DViewport_towards_Mouse (float t) {

    float xA = this.CAM_x / OBJECTS_scale;
    float yA = this.CAM_y / OBJECTS_scale;
    float zA = this.CAM_z / OBJECTS_scale;

    float Image_X = mouseX - (this.cX + 0.5 * this.dX);
    float Image_Y = mouseY - (this.cY + 0.5 * this.dY);

    float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);
    float xO = ray_end[0] / OBJECTS_scale;
    float yO = ray_end[1] / OBJECTS_scale;
    float zO = ray_end[2] / OBJECTS_scale;

    float dx = xA - xO;
    float dy = yA - yO;
    float dz = zA - zO;

    float xB = xO + t * dx;
    float yB = yO + t * dy;
    float zB = zO + t * dz;

    this.CAM_x = xB * OBJECTS_scale;
    this.CAM_y = yB * OBJECTS_scale;
    this.CAM_z = zB * OBJECTS_scale;

    WIN3D.reverseTransform_3DViewport();


    //this.position_T *= t; // just to adjust panning better
  }

  void move_3DViewport_towards_Selection (float t) {

    float xA = this.CAM_x / OBJECTS_scale;
    float yA = this.CAM_y / OBJECTS_scale;
    float zA = this.CAM_z / OBJECTS_scale;

    float[] P = Select3D.getPivot();

    float xO = P[0];
    float yO = P[1];
    float zO = P[2];

    float dx = xA - xO;
    float dy = yA - yO;
    float dz = zA - zO;

    float xB = xO + t * dx;
    float yB = yO + t * dy;
    float zB = zO + t * dz;

    this.CAM_x = xB * OBJECTS_scale;
    this.CAM_y = yB * OBJECTS_scale;
    this.CAM_z = zB * OBJECTS_scale;

    WIN3D.reverseTransform_3DViewport();


    //this.position_T *= t; // just to adjust panning better
  }

  void rotateZ_3DViewport_around_Selection (float t) {

    this.rotation_X += t;

    float xA = this.CAM_x / OBJECTS_scale;
    float yA = this.CAM_y / OBJECTS_scale;
    float zA = this.CAM_z / OBJECTS_scale;

    float[] P = Select3D.getPivot();

    float xO = P[0];
    float yO = P[1];
    float zO = P[2];

    float xB = xA - xO;
    float yB = yA - yO;
    float zB = zA - zO;

    // rotate to make it on yz plane

    float xC = xB * funcs.cos_ang(-this.rotation_Z) - yB * funcs.sin_ang(-this.rotation_Z);
    float yC = xB * funcs.sin_ang(-this.rotation_Z) + yB * funcs.cos_ang(-this.rotation_Z);
    float zC = zB;

    // rotate it on yz plane

    float xD = xC;
    float yD = yC * funcs.cos_ang(t) - zC * funcs.sin_ang(t);
    float zD = yC * funcs.sin_ang(t) + zC * funcs.cos_ang(t);

    // rotate to back from yz plane

    float xE = xD * funcs.cos_ang(this.rotation_Z) - yD * funcs.sin_ang(this.rotation_Z);
    float yE = xD * funcs.sin_ang(this.rotation_Z) + yD * funcs.cos_ang(this.rotation_Z);
    float zE = zD;

    float xF = xE + xO;
    float yF = yE + yO;
    float zF = zE + zO;

    this.CAM_x = xF * OBJECTS_scale;
    this.CAM_y = yF * OBJECTS_scale;
    this.CAM_z = zF * OBJECTS_scale;

    WIN3D.reverseTransform_3DViewport();
  }


  void rotateXY_3DViewport_around_Selection (float t) {

    this.rotation_Z += t;

    float xA = this.CAM_x / OBJECTS_scale;
    float yA = this.CAM_y / OBJECTS_scale;
    float zA = this.CAM_z / OBJECTS_scale;

    float[] P = Select3D.getPivot();

    float xO = P[0];
    float yO = P[1];
    float zO = P[2];

    float dx = xA - xO;
    float dy = yA - yO;

    float xB = xO + dx * funcs.cos_ang(t) - dy * funcs.sin_ang(t);
    float yB = yO + dx * funcs.sin_ang(t) + dy * funcs.cos_ang(t);
    float zB = zA;

    this.CAM_x = xB * OBJECTS_scale;
    this.CAM_y = yB * OBJECTS_scale;
    this.CAM_z = zB * OBJECTS_scale;

    WIN3D.reverseTransform_3DViewport();
  }


  void rotateXY_3DViewport_around_LandIntersection (float t) {

    float Image_X = SOLARCHVISION_X_click1 - (this.cX + 0.5 * this.dX);
    float Image_Y = SOLARCHVISION_Y_click1 - (this.cY + 0.5 * this.dY);

    float[] ray_direction = new float [3];

    float[] ray_start = {
      this.CAM_x, this.CAM_y, this.CAM_z
    };

    float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);

    ray_start[0] /= OBJECTS_scale;
    ray_start[1] /= OBJECTS_scale;
    ray_start[2] /= OBJECTS_scale;

    ray_end[0] /= OBJECTS_scale;
    ray_end[1] /= OBJECTS_scale;
    ray_end[2] /= OBJECTS_scale;

    if (this.ViewType == 0) {
      float[] ray_center = WIN3D.calculate_Click3D(0, 0);

      ray_center[0] /= OBJECTS_scale;
      ray_center[1] /= OBJECTS_scale;
      ray_center[2] /= OBJECTS_scale;

      ray_start[0] += ray_end[0] - ray_center[0];
      ray_start[1] += ray_end[1] - ray_center[1];
      ray_start[2] += ray_end[2] - ray_center[2];
    }

    ray_direction[0] = ray_end[0] - ray_start[0];
    ray_direction[1] = ray_end[1] - ray_start[1];
    ray_direction[2] = ray_end[2] - ray_start[2];


    float[] RxP = Land3D.intersect(ray_start, ray_direction);

    if (RxP[0] >= 0) {

      float xO = RxP[1] / OBJECTS_scale;
      float yO = RxP[2] / OBJECTS_scale;
      float zO = RxP[3] / OBJECTS_scale;

      float xA = ray_start[0];
      float yA = ray_start[1];
      float zA = ray_start[2];

      float dx = xA - xO;
      float dy = yA - yO;

      this.rotation_Z += t;

      float xB = xO + dx * funcs.cos_ang(t) - dy * funcs.sin_ang(t);
      float yB = yO + dx * funcs.sin_ang(t) + dy * funcs.cos_ang(t);
      float zB = zA;

      this.CAM_x = xB * OBJECTS_scale;
      this.CAM_y = yB * OBJECTS_scale;
      this.CAM_z = zB * OBJECTS_scale;

      WIN3D.reverseTransform_3DViewport();
    }
  }


  void reverseTransform_3DViewport () { // computing this.position_X, this.position_Y and this.position_Z from new set of camera start and end points.

    float px, py, pz;

    px = this.CAM_x;
    py = this.CAM_y;
    pz = this.CAM_z;

    float CAM_x1, CAM_y1, CAM_z1;

    CAM_z1 = pz;
    CAM_x1 = px * funcs.cos_ang(-this.rotation_Z) - py * funcs.sin_ang(-this.rotation_Z);
    CAM_y1 = px * funcs.sin_ang(-this.rotation_Z) + py * funcs.cos_ang(-this.rotation_Z);

    px = CAM_x1;
    py = CAM_y1;
    pz = CAM_z1;

    CAM_x1 = px;
    CAM_y1 = py * funcs.cos_ang(-this.rotation_X) - pz * funcs.sin_ang(-this.rotation_X);
    CAM_z1 = py * funcs.sin_ang(-this.rotation_X) + pz * funcs.cos_ang(-this.rotation_X);


    float CAM_x2, CAM_y2, CAM_z2;

    this.CAM_fov = this.Zoom * PI / 180;

    this.CAM_dist = (0.5 * this.refScale) / tan(0.5 * this.CAM_fov);

    CAM_x2 = 0;
    CAM_y2 = 0;
    CAM_z2 = this.CAM_dist;

    CAM_x2 *= tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);
    CAM_y2 *= tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);
    CAM_z2 *= tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);


    this.position_X = CAM_x2 - CAM_x1;
    this.position_Y = -(CAM_y2 - CAM_y1);
    this.position_Z = CAM_z2 - CAM_z1;
  }


  void record_last3DViewport () {

    allCameras.set_posX(this.currentCamera, this.position_X);
    allCameras.set_posY(this.currentCamera, this.position_Y);
    allCameras.set_posZ(this.currentCamera, this.position_Z);
    allCameras.set_posT(this.currentCamera, this.position_T);
    allCameras.set_rotX(this.currentCamera, this.rotation_X);
    allCameras.set_rotY(this.currentCamera, this.rotation_Y);
    allCameras.set_rotZ(this.currentCamera, this.rotation_Z);
    allCameras.set_rotT(this.currentCamera, this.rotation_T);
    allCameras.set_zoom(this.currentCamera, this.Zoom);
    allCameras.set_type(this.currentCamera, this.ViewType);
  }


  void apply_currentCamera () {

    this.position_X = allCameras.get_posX(this.currentCamera);
    this.position_Y = allCameras.get_posY(this.currentCamera);
    this.position_Z = allCameras.get_posZ(this.currentCamera);
    this.position_T = allCameras.get_posT(this.currentCamera);
    this.rotation_X = allCameras.get_rotX(this.currentCamera);
    this.rotation_Y = allCameras.get_rotY(this.currentCamera);
    this.rotation_Z = allCameras.get_rotZ(this.currentCamera);
    this.rotation_T = allCameras.get_rotT(this.currentCamera);
    this.Zoom       = allCameras.get_zoom(this.currentCamera);
    this.ViewType   = allCameras.get_type(this.currentCamera);
  }


  void transform_3DViewport () {

    this.CAM_fov = this.Zoom * PI / 180;

    this.CAM_dist = (0.5 * this.refScale) / tan(0.5 * this.CAM_fov);

    this.CAM_x = 0;
    this.CAM_y = 0;
    this.CAM_z = this.CAM_dist;


    this.CAM_x *= tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);
    this.CAM_y *= tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);
    this.CAM_z *= tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);

    this.CAM_x -= this.position_X;
    this.CAM_y += this.position_Y;
    this.CAM_z -= this.position_Z;

    float px, py, pz;

    px = this.CAM_x;
    py = this.CAM_y * funcs.cos_ang(this.rotation_X) - this.CAM_z * funcs.sin_ang(this.rotation_X);
    pz = this.CAM_y * funcs.sin_ang(this.rotation_X) + this.CAM_z * funcs.cos_ang(this.rotation_X);

    this.CAM_x = px;
    this.CAM_y = py;
    this.CAM_z = pz;

    pz = this.CAM_z;
    px = this.CAM_x * funcs.cos_ang(this.rotation_Z) - this.CAM_y * funcs.sin_ang(this.rotation_Z);
    py = this.CAM_x * funcs.sin_ang(this.rotation_Z) + this.CAM_y * funcs.cos_ang(this.rotation_Z);

    this.CAM_x = px;
    this.CAM_y = py;
    this.CAM_z = pz;

    //println("Camera:", nf(this.CAM_x,0,4), nf(this.CAM_y,0,4), nf(this.CAM_z,0,4));
  }



  float[] calculate_Click3D (float Image_X, float Image_Y) {

    float PNT_x = FLOAT_undefined;
    float PNT_y = FLOAT_undefined;
    float PNT_z = FLOAT_undefined;

    if (this.ViewType == 1) {

      PNT_z = 0.5/ tan(0.5 * PI / 3.0); //100; // for perspective: any value the plane we need the results on!

      PNT_x = PNT_z * Image_X / ((0.5 * this.scale / tan(0.5 * this.CAM_fov)) * this.refScale);
      PNT_y = PNT_z * -Image_Y / ((0.5 * this.scale / tan(0.5 * this.CAM_fov)) * this.refScale);
    } else {
      float ZOOM = this.Orthographic_ZOOM();

      PNT_z = (0.5 * this.refScale) / tan(0.5 * PI / 3.0); // for orthographic: should be this.

      PNT_x = ZOOM * Image_X / (0.5 * this.scale);
      PNT_y = ZOOM * -Image_Y / (0.5 * this.scale);
    }

    float px, py, pz;

    px = PNT_x;
    py = PNT_y * funcs.cos_ang(-this.rotation_X) - PNT_z * funcs.sin_ang(-this.rotation_X);
    pz = PNT_y * funcs.sin_ang(-this.rotation_X) + PNT_z * funcs.cos_ang(-this.rotation_X);

    PNT_x = px;
    PNT_y = py;
    PNT_z = pz;

    pz = PNT_z;
    px = PNT_x * funcs.cos_ang(this.rotation_Z) - PNT_y * funcs.sin_ang(this.rotation_Z);
    py = PNT_x * funcs.sin_ang(this.rotation_Z) + PNT_y * funcs.cos_ang(this.rotation_Z);

    PNT_x = px;
    PNT_y = py;
    PNT_z = pz;

    PNT_x += this.CAM_x;
    PNT_y += this.CAM_y;
    PNT_z -= this.CAM_z;

    float[] return_array = {
      PNT_x, PNT_y, -PNT_z
    };

    return return_array;
  }




  float[] calculate_Perspective_Internally (float x, float y, float z) {

    float Image_X = FLOAT_undefined;
    float Image_Y = FLOAT_undefined;
    float Image_Z = -FLOAT_undefined; // negative so that it automatically illuminated by Draw function


    float px, py, pz;

    x -= this.CAM_x;
    y -= this.CAM_y;
    z += this.CAM_z;

    pz = z;
    px = x * funcs.cos_ang(-this.rotation_Z) - y * funcs.sin_ang(-this.rotation_Z);
    py = x * funcs.sin_ang(-this.rotation_Z) + y * funcs.cos_ang(-this.rotation_Z);

    x = px;
    y = py;
    z = pz;

    px = x;
    py = y * funcs.cos_ang(this.rotation_X) - z * funcs.sin_ang(this.rotation_X);
    pz = y * funcs.sin_ang(this.rotation_X) + z * funcs.cos_ang(this.rotation_X);

    x = px;
    y = py;
    z = pz;


    if (z > 0) {
      if (this.ViewType == 1) {

        Image_X = (x / z) * (0.5 * this.scale / tan(0.5 * this.CAM_fov)) * this.refScale;
        Image_Y = -(y / z) * (0.5 * this.scale / tan(0.5 * this.CAM_fov)) * this.refScale;
        Image_Z = z;
      } else {

        float ZOOM = this.Orthographic_ZOOM();

        Image_X = (x / ZOOM) * (0.5 * this.scale);
        Image_Y = -(y / ZOOM) * (0.5 * this.scale);
        Image_Z = z;
      }
    }

    float[] theValues = {
      Image_X, Image_Y, Image_Z
    };

    return theValues;
  }




  public void to_XML (XML xml) {

    println("Saving:" + this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setFloat(parent, "CAM_x", this.CAM_x);
    XML_setFloat(parent, "CAM_y", this.CAM_y);
    XML_setFloat(parent, "CAM_z", this.CAM_z);
    XML_setFloat(parent, "CAM_fov", this.CAM_fov);
    XML_setFloat(parent, "CAM_dist", this.CAM_dist);
    XML_setFloat(parent, "CAM_clipNear", this.CAM_clipNear);
    XML_setFloat(parent, "CAM_clipFar", this.CAM_clipFar);
    XML_setInt(parent, "currentCamera", this.currentCamera);

    XML_setFloat(parent, "refScale", this.refScale);
    XML_setFloat(parent, "position_X", this.position_X);
    XML_setFloat(parent, "position_Y", this.position_Y);
    XML_setFloat(parent, "position_Z", this.position_Z);
    XML_setFloat(parent, "position_T", this.position_T);
    XML_setFloat(parent, "rotation_X", this.rotation_X);
    XML_setFloat(parent, "rotation_Y", this.rotation_Y);
    XML_setFloat(parent, "rotation_Z", this.rotation_Z);
    XML_setFloat(parent, "rotation_T", this.rotation_T);
    XML_setFloat(parent, "Zoom", this.Zoom);
    XML_setInt(parent, "ViewType", this.ViewType);
    XML_setInt(parent, "FacesShade", this.FacesShade);

    XML_setInt(parent, "UI_CurrentTask", this.UI_CurrentTask);
    XML_setInt(parent, "UI_OptionXorY", this.UI_OptionXorY);
    XML_setInt(parent, "UI_TaskModifyParameter", this.UI_TaskModifyParameter);

    XML_setInt(parent, "Impact_TYPE", this.Impact_TYPE);
  }


  public void from_XML (XML xml) {

    println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.CAM_x = XML_getFloat(parent, "CAM_x");
    this.CAM_y = XML_getFloat(parent, "CAM_y");
    this.CAM_z = XML_getFloat(parent, "CAM_z");
    this.CAM_fov = XML_getFloat(parent, "CAM_fov");
    this.CAM_dist = XML_getFloat(parent, "CAM_dist");
    this.CAM_clipNear = XML_getFloat(parent, "CAM_clipNear");
    this.CAM_clipFar = XML_getFloat(parent, "CAM_clipFar");
    this.currentCamera = XML_getInt(parent, "currentCamera");

    this.refScale = XML_getFloat(parent, "refScale");
    this.position_X = XML_getFloat(parent, "position_X");
    this.position_Y = XML_getFloat(parent, "position_Y");
    this.position_Z = XML_getFloat(parent, "position_Z");
    this.position_T = XML_getFloat(parent, "position_T");
    this.rotation_X = XML_getFloat(parent, "rotation_X");
    this.rotation_Y = XML_getFloat(parent, "rotation_Y");
    this.rotation_Z = XML_getFloat(parent, "rotation_Z");
    this.rotation_T = XML_getFloat(parent, "rotation_T");
    this.Zoom = XML_getFloat(parent, "Zoom");
    this.ViewType = XML_getInt(parent, "ViewType");
    this.FacesShade = XML_getInt(parent, "FacesShade");

    this.UI_CurrentTask = XML_getInt(parent, "UI_CurrentTask");
    this.UI_OptionXorY = XML_getInt(parent, "UI_OptionXorY");
    this.UI_TaskModifyParameter = XML_getInt(parent, "UI_TaskModifyParameter");

    this.Impact_TYPE = XML_getInt(parent, "Impact_TYPE");
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
