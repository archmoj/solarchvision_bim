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

  // Rotates (x, y, z) by angleDeg around the X axis (x is unchanged).
  private float[] rotateAroundX (float x, float y, float z, float angleDeg) {
    float ny = y * funcs.cos_ang(angleDeg) - z * funcs.sin_ang(angleDeg);
    float nz = y * funcs.sin_ang(angleDeg) + z * funcs.cos_ang(angleDeg);
    return new float[] { x, ny, nz };
  }

  // Rotates (x, y, z) by angleDeg around the Z axis (z is unchanged).
  private float[] rotateAroundZ (float x, float y, float z, float angleDeg) {
    float nx = x * funcs.cos_ang(angleDeg) - y * funcs.sin_ang(angleDeg);
    float ny = x * funcs.sin_ang(angleDeg) + y * funcs.cos_ang(angleDeg);
    return new float[] { nx, ny, z };
  }

  private float[] cameraPositionScaled () {
    return new float[] { this.CAM_x / OBJECTS_scale, this.CAM_y / OBJECTS_scale, this.CAM_z / OBJECTS_scale };
  }

  private float[] imageCenterRayScaled () {
    float[] ray_end = WIN3D.calculate_Click3D(0, 0);
    return new float[] { ray_end[0] / OBJECTS_scale, ray_end[1] / OBJECTS_scale, ray_end[2] / OBJECTS_scale };
  }

  void put_3DViewport () {
    if (this.ViewType == 1) {
      float aspect = 1.0 / this.view_R;
      float zFar = this.CAM_dist * this.CAM_clipFar;
      float zNear = this.CAM_dist * this.CAM_clipNear;

      this.graphics.perspective(this.CAM_fov, aspect, zNear, zFar);
    } else {
      float ZOOM = WIN3D.Orthographic_ZOOM();
      this.graphics.ortho(ZOOM * this.dX * -1, ZOOM * this.dX * 1, ZOOM * this.dY * -1, ZOOM * this.dY * 1, 0.00001, 100000);
    }

    this.graphics.translate(0.5 * this.dX, 0.5 * this.dY, 0); // << IMPORTANT!
    this.graphics.translate(this.position_X * this.scale, this.position_Y * this.scale, this.position_Z * this.scale);

    this.graphics.rotateX(this.rotation_X * PI / 180);
    this.graphics.rotateZ(this.rotation_Z * PI / 180);
  }

  float Orthographic_ZOOM () {
    float ZOOM = 0.5 * this.Zoom * PI / 180;
    ZOOM *= pow(pow(this.position_X, 2) + pow(this.position_Y, 2) + pow(this.position_Z, 2), 0.5);
    ZOOM /= this.refScale;
    return ZOOM;
  }

  void drawView () {
    if (!this.update) return;

    if (Select3D.update_BoundingBox) {
      Select3D.calculate_BoundingBox();
    }

    beginImageScale();

    int firstDay = IMPACTS_displayDay;
    int lastDay = IMPACTS_displayDay;
    if (this.fullPeriod_IMG) {
      this.fullPeriod_IMG = false;
      firstDay = 0;
      lastDay = STUDY.j_End;
    }

    int keep_IMPACTS_displayDay = IMPACTS_displayDay;
    for (IMPACTS_displayDay = lastDay; IMPACTS_displayDay >= firstDay; IMPACTS_displayDay--) {
      renderFrame();
    }
    IMPACTS_displayDay = keep_IMPACTS_displayDay;

    imageMode(CORNER);
    image(this.graphics, this.cX, this.cY, this.dX / this.ImageScale, this.dY / this.ImageScale);

    if (this.record_IMG || !this.record_AUTO) this.record_IMG = false;

    endImageScale();
  }

  private void beginImageScale () {
    if (this.record_IMG) this.ImageScale = 1; //2; //3;
    else this.ImageScale = 1;

    this.dX *= this.ImageScale;
    this.dY *= this.ImageScale;

    if (this.ImageScale != 1) {
      println("IMG:high-res");
      this.graphics = createGraphics(this.dX, this.dY, P3D);
    }
  }

  private void endImageScale () {
    this.dX /= this.ImageScale;
    this.dY /= this.ImageScale;

    if (this.ImageScale != 1) {
      this.graphics = createGraphics(this.dX, this.dY, P3D);
      this.updated();
    } else {
      this.updated();
      SOLARCHVISION_draw_Perspective_Internally();
    }
  }

  private void renderFrame () {
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

    drawSceneContents();

    this.graphics.hint(DISABLE_DEPTH_TEST);

    if (!(this.record_IMG || this.record_AUTO)) {
      WIN3D.draw_referencePivot();
    }

    this.graphics.popMatrix();

    this.drawPalette();

    this.graphics.endDraw();

    if (this.record_IMG || this.record_AUTO) {
      saveRecordedFrame();
    }
  }

  private void drawSceneContents () {
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
  }

  private void saveRecordedFrame () {
    String myFile = MAKE_Filename(createStamp(1, CLASS_STAMP));

    if (this.Impact_TYPE == Impact_ACTIVE) myFile += "_RAD";
    if (this.Impact_TYPE == Impact_PASSIVE) myFile += "_EFF";
    myFile += "_" + importedObjectName;
    myFile += ".jpg";

    this.graphics.save(myFile);
    println("File created:" + myFile);
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

  // --- palette overlay -----------------------------------------------------------------

  private boolean isSolarPaletteMode () {
    return (this.FacesShade == SHADE.Global_Solar) ||
           (this.FacesShade == SHADE.Vertex_Solar) ||
           (allSolarImpacts.displayImage && (allSections.SolarImpact.length > 0));
  }

  private float[] choosePaletteParams () {
    int type = 0;
    int direction = 1;
    float multiplier = 1;
    boolean draw_pal = false;

    if (isSolarPaletteMode()) {
      if (this.Impact_TYPE == Impact_ACTIVE) {
        type = allFaces.ACTIVE_palette_CLR;
        direction = allFaces.ACTIVE_palette_DIR;
        multiplier = allFaces.ACTIVE_palette_MLT;
      }
      if (this.Impact_TYPE == Impact_PASSIVE) {
        type = allFaces.PASSIVE_palette_CLR;
        direction = allFaces.PASSIVE_palette_DIR;
        multiplier = allFaces.PASSIVE_palette_MLT;
      }
      draw_pal = true;
    }

    if (this.FacesShade == SHADE.Vertex_Elevation) {
      type = Land3D.palette_CLR;
      direction = Land3D.palette_DIR;
      multiplier = Land3D.palette_MLT;
      draw_pal = true;
    }

    if (this.FacesShade == SHADE.Vertex_Solid) {
      type = allSolids.palette_CLR;
      direction = allSolids.palette_DIR;
      multiplier = allSolids.palette_MLT;
      draw_pal = true;
    }

    return new float[] { type, direction, multiplier, draw_pal ? 1 : 0 };
  }

  void drawPalette () {
    float[] palette = choosePaletteParams();
    int PAL_type = int(palette[0]);
    int PAL_direction = int(palette[1]);
    float PAL_multiplier = palette[2];
    if (palette[3] != 1) return;

    float the_scale = (this.ViewType == 1) ? (0.5 / tan(0.5 * this.CAM_fov)) : (0.5 / WIN3D.Orthographic_ZOOM());

    this.graphics.pushMatrix();

    this.CAM_fov = this.Zoom * PI / 180;
    this.CAM_dist = (0.5 * this.refScale) / tan(0.5 * this.CAM_fov);

    this.graphics.translate(0.5 * this.dX, 0.5 * this.dY, 0); // << IMPORTANT!

    float pal_length = 1 * SOLARCHVISION_pixel_H * this.ImageScale / the_scale;
    float y1 = -0.2 * (pal_length / 11.0) + (0.4 * this.dY / the_scale);
    float y2 = y1 + 0.4 * (pal_length / 11.0);
    float txtSize = y2 - y1;
    float y = 0.5 * (y1 + y2) - 0.1 * txtSize;

    for (int q = 0; q < 11; q++) {
      drawPaletteSegment(q, PAL_type, PAL_direction, PAL_multiplier, pal_length, y1, y2, y, txtSize);
    }

    drawPaletteCaption(pal_length, y, y1, txtSize);

    this.graphics.popMatrix();
  }

  private void drawPaletteSegment (int q, int PAL_type, int PAL_direction, float PAL_multiplier, float pal_length, float y1, float y2, float y, float txtSize) {
    float x1 = -0.5 * pal_length + q * (pal_length / 11.0);
    float x2 = x1 + (pal_length / 11.0);
    float x = 0.5 * (x1 + x2);

    float _u = 0.2 * q - 0.5;
    if (isSolarPaletteMode()) {
      if (this.Impact_TYPE == Impact_ACTIVE) _u = 0.1 * q;
      if (this.Impact_TYPE == Impact_PASSIVE) _u = 0.2 * q - 0.5;
    }
    _u = applyPalDirection(_u, PAL_direction);

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

    if (isSolarPaletteMode()) {
      if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(nf((funcs.roundTo(0.1 * q / PAL_multiplier, 0.1)), 1, 1), x, y, 0);
      if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(nf(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 0.1), 1, 1), x, y, 0);
    }

    if (this.FacesShade == SHADE.Vertex_Elevation) {
      this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), x, y, 0);
    }

    if (this.FacesShade == SHADE.Vertex_Solid) {
      this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), x, y, 0);
    }
  }

  private void drawPaletteCaption (float pal_length, float y, float y1, float txtSize) {
    this.graphics.noStroke();
    this.graphics.fill(127);

    String txt = "";
    this.graphics.textAlign(LEFT, CENTER);

    if ((this.FacesShade != SHADE.Vertex_Elevation) && (this.FacesShade != SHADE.Vertex_Solid)) {
      if (this.Impact_TYPE == Impact_ACTIVE) this.graphics.text(" kW/m²", 0.5 * pal_length, y, 0);
      if (this.Impact_TYPE == Impact_PASSIVE) this.graphics.text(" %kW°C/m²", 0.5 * pal_length, y, 0);

      txt += "SOLARCHVISION ";
      if (this.Impact_TYPE == Impact_ACTIVE) txt += "active model ";
      if (this.Impact_TYPE == Impact_PASSIVE) txt += "passive model ";

      if (IMPACTS_displayDay != 0) {
        txt += TIME.getDayText((IMPACTS_displayDay - 1) * STUDY.perDays + 286 + TIME.beginDay);
      } else {
        txt += TIME.getDayText(STUDY.j_Start * STUDY.perDays + 286 + TIME.beginDay) + " - ";
        txt += TIME.getDayText((STUDY.j_End - 1) * STUDY.perDays + 286 + TIME.beginDay);
      }
    }

    this.graphics.textAlign(CENTER, CENTER);
    this.graphics.text(txt, 0, y1 - 1.0 * txtSize, 0);
  }

  private void reviseViews () {
    this.revise();
    ROLLOUT.revise();
  }

  void keyPressed (KeyEvent e) {
    if (!this.include) return;
    if (e.isAltDown() || e.isControlDown()) return;

    if (key == CODED) {
      if (e.isShiftDown()) {
        handleShiftedArrowKeys(keyCode);
      } else {
        handleArrowKeys(keyCode);
      }
    } else {
      handleCommandKey(e);
    }
  }

  private void handleShiftedArrowKeys (int keyCode) {
    switch (keyCode) {

      case UP:
      case DOWN:
        float[] P = Select3D.getPivot();
        float x0 = P[0];
        float y0 = P[1];
        float z0 = P[2];

        if (WIN3D.UI_CurrentTask == UITASK.Rotate) {
          float r = (keyCode == DOWN) ? -5 : 5;
          int the_Vector = Select3D.rotVector;
          Rotate3D.selection(x0, y0, z0, r, the_Vector);
          SOLARCHVISION_model_changed();
        }

        if (WIN3D.UI_CurrentTask == UITASK.Scale) {
          float s = pow(2.0, 0.25);
          if (keyCode == DOWN) s = 1.0 / s;

          float sx = s, sy = s, sz = s;
          int the_Vector = Select3D.scaleVector;
          if (the_Vector == 0) { sy = 1; sz = 1; }
          if (the_Vector == 1) { sz = 1; sx = 1; }
          if (the_Vector == 2) { sx = 1; sy = 1; }

          Scale3D.selection(x0, y0, z0, sx, sy, sz);
          SOLARCHVISION_model_changed();
        }

        if (WIN3D.UI_CurrentTask == UITASK.Move) {
          float d = (keyCode == DOWN) ? -0.5 : 0.5;
          float dx = d, dy = d, dz = d;

          int the_Vector = Select3D.posVector;
          if (the_Vector == 0) { dy = 0; dz = 0; }
          if (the_Vector == 1) { dz = 0; dx = 0; }
          if (the_Vector == 2) { dx = 0; dy = 0; }

          Move3D.selection(dx, dy, dz);
          SOLARCHVISION_model_changed();
        }

        if (WIN3D.UI_TaskModifyParameter == 0) {
          if (WIN3D.UI_CurrentTask >= UITASK.Seed_Material) {
            int p = (keyCode == DOWN) ? -1 : 1;
            Edit3D.selection(p);
            SOLARCHVISION_model_changed();
          }
        }

        break;
    }
  }

  private void handleArrowKeys (int keyCode) {
    switch (keyCode) {
      case DOWN:
        WIN3D.rotateZ_3DViewport_around_Selection(this.rotation_T);
        reviseViews();
        break;
      case LEFT:
        WIN3D.rotateXY_3DViewport_around_Selection(-this.rotation_T);
        reviseViews();
        break;
      case RIGHT:
        WIN3D.rotateXY_3DViewport_around_Selection(this.rotation_T);
        reviseViews();
        break;
      case UP:
        WIN3D.rotateZ_3DViewport_around_Selection(-this.rotation_T);
        reviseViews();
        break;
    }
  }

  private void handleCommandKey (KeyEvent e) {
    switch (key) {

      case TAB:
        if (e.isShiftDown()) {
          this.Impact_TYPE = (this.Impact_TYPE + 1) % numberOfImpactVariations;
          if (this.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
          if (this.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
          reviseViews();
        }
        break;

      case DELETE:
        Delete3D.selection();
        reviseViews();
        break;

      case ',':
        if (this.ViewType == 1) this.position_Z += this.position_T * OBJECTS_scale;
        else this.Zoom /= pow(2.0, 0.25);
        reviseViews();
        break;

      case '.':
        if (this.ViewType == 1) this.position_Z -= this.position_T * OBJECTS_scale;
        else this.Zoom *= pow(2.0, 0.25);
        reviseViews();
        break;

      case '0':
        if (this.ViewType == 1) this.position_Z += this.position_T * OBJECTS_scale;
        else this.Zoom /= pow(2.0, 0.25);
        reviseViews();
        break;

      case '5':
        WIN3D.look_3DViewport_towards_Selection();
        reviseViews();
        break;

      case '4':
        this.rotation_Z += this.rotation_T;
        WIN3D.reverseTransform_3DViewport();
        reviseViews();
        break;
      case '6':
        this.rotation_Z -= this.rotation_T;
        WIN3D.reverseTransform_3DViewport();
        reviseViews();
        break;
      case '8':
        this.rotation_X -= this.rotation_T;
        WIN3D.reverseTransform_3DViewport();
        reviseViews();
        break;
      case '2':
        this.rotation_X += this.rotation_T;
        WIN3D.reverseTransform_3DViewport();
        reviseViews();
        break;

      case '1':
        this.position_X += this.position_T * OBJECTS_scale;
        reviseViews();
        break;
      case '3':
        this.position_X -= this.position_T * OBJECTS_scale;
        reviseViews();
        break;
      case '7':
        this.position_Y += this.position_T * OBJECTS_scale;
        reviseViews();
        break;
      case '9':
        this.position_Y -= this.position_T * OBJECTS_scale;
        reviseViews();
        break;

      case '*':
        WIN3D.move_3DViewport_towards_Selection(2.0);
        reviseViews();
        break;
      case '/':
        WIN3D.move_3DViewport_towards_Selection(0.5);
        reviseViews();
        break;

      case '+':
        this.Zoom = 2 * funcs.atan_ang((1.0 / 1.1) * funcs.tan_ang(0.5 * this.Zoom));
        reviseViews();
        break;
      case '-':
        this.Zoom = 2 * funcs.atan_ang((1.1 / 1.0) * funcs.tan_ang(0.5 * this.Zoom));
        reviseViews();
        break;

      case 'c':
        this.currentCamera += 1;
        if (this.currentCamera > allCameras.num - 1) this.currentCamera = 0;
        WIN3D.apply_currentCamera();
        SOLARCHVISION_modify_Viewport_Title();
        reviseViews();
        break;

      case 'C':
        this.currentCamera -= 1;
        if (this.currentCamera < 0) this.currentCamera = allCameras.num - 1;
        WIN3D.apply_currentCamera();
        SOLARCHVISION_modify_Viewport_Title();
        reviseViews();
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

      case 'd':
        IMPACTS_displayDay += 1;
        if (IMPACTS_displayDay > STUDY.j_End) IMPACTS_displayDay = 0;
        reviseViews();
        break;
      case 'D':
        IMPACTS_displayDay -= 1;
        if (IMPACTS_displayDay < 0) IMPACTS_displayDay = STUDY.j_End;
        reviseViews();
        break;

      case ENTER:
        if (this.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
        if (this.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
        reviseViews();
        break;

      case ' ':
        SOLARCHVISION_ShadeViewport(1);
        break;

      case BACKSPACE:
        SOLARCHVISION_ShadeViewport(-1);
        break;
    }
  }

  void look_3DViewport_towards_Direction (float Image_X, float Image_Y) {
    WIN3D.lookXY_3DViewport_towards_Direction(Image_X, Image_Y);
    WIN3D.lookZ_3DViewport_towards_Direction(Image_X, Image_Y);
  }

  private void rotateZTowards (float xB, float yB) {
    float[] O = cameraPositionScaled();
    float[] A = imageCenterRayScaled();
    this.rotation_Z += funcs.atan2_ang((yB - O[1]), (xB - O[0])) - funcs.atan2_ang((A[1] - O[1]), (A[0] - O[0]));
    WIN3D.reverseTransform_3DViewport();
  }

  private void rotateXTowards (float xB, float yB, float zB) {
    float[] O = cameraPositionScaled();
    float[] A = imageCenterRayScaled();
    this.rotation_X += funcs.atan2_ang((zB - O[2]), pow(pow(yB - O[1], 2) + pow(xB - O[0], 2), 0.5))
                      - funcs.atan2_ang((A[2] - O[2]), pow(pow(A[1] - O[1], 2) + pow(A[0] - O[0], 2), 0.5));
    WIN3D.reverseTransform_3DViewport();
  }

  void lookXY_3DViewport_towards_Direction (float Image_X, float Image_Y) {
    float[] P = WIN3D.calculate_Click3D(Image_X, Image_Y);
    rotateZTowards(P[0] / OBJECTS_scale, P[1] / OBJECTS_scale);
  }

  void lookZ_3DViewport_towards_Direction (float Image_X, float Image_Y) {
    float[] P = WIN3D.calculate_Click3D(Image_X, Image_Y);
    rotateXTowards(P[0] / OBJECTS_scale, P[1] / OBJECTS_scale, P[2] / OBJECTS_scale);
  }

  void look_3DViewport_towards_Selection () {
    WIN3D.lookXY_3DViewport_towards_Selection();
    WIN3D.lookZ_3DViewport_towards_Selection();
  }

  void lookXY_3DViewport_towards_Selection () {
    float[] P = Select3D.getPivot();
    rotateZTowards(P[0], P[1]);
  }

  void lookZ_3DViewport_towards_Selection () {
    float[] P = Select3D.getPivot();
    rotateXTowards(P[0], P[1], P[2]);
  }

  private void moveCameraTowards (float xO, float yO, float zO, float t) {
    float[] A = cameraPositionScaled();

    float dx = A[0] - xO;
    float dy = A[1] - yO;
    float dz = A[2] - zO;

    this.CAM_x = (xO + t * dx) * OBJECTS_scale;
    this.CAM_y = (yO + t * dy) * OBJECTS_scale;
    this.CAM_z = (zO + t * dz) * OBJECTS_scale;

    WIN3D.reverseTransform_3DViewport();
    //this.position_T *= t; // just to adjust panning better
  }

  void move_3DViewport_towards_Mouse (float t) {
    float Image_X = mouseX - (this.cX + 0.5 * this.dX);
    float Image_Y = mouseY - (this.cY + 0.5 * this.dY);
    float[] ray_end = WIN3D.calculate_Click3D(Image_X, Image_Y);
    moveCameraTowards(ray_end[0] / OBJECTS_scale, ray_end[1] / OBJECTS_scale, ray_end[2] / OBJECTS_scale, t);
  }

  void move_3DViewport_towards_Selection (float t) {
    float[] P = Select3D.getPivot();
    moveCameraTowards(P[0], P[1], P[2], t);
  }

  void rotateZ_3DViewport_around_Selection (float t) {
    this.rotation_X += t;

    float[] A = cameraPositionScaled();
    float[] P = Select3D.getPivot();

    float xB = A[0] - P[0];
    float yB = A[1] - P[1];
    float zB = A[2] - P[2];

    // rotate into the yz plane, rotate there by t, then rotate back
    float xC = xB * funcs.cos_ang(-this.rotation_Z) - yB * funcs.sin_ang(-this.rotation_Z);
    float yC = xB * funcs.sin_ang(-this.rotation_Z) + yB * funcs.cos_ang(-this.rotation_Z);
    float zC = zB;

    float xD = xC;
    float yD = yC * funcs.cos_ang(t) - zC * funcs.sin_ang(t);
    float zD = yC * funcs.sin_ang(t) + zC * funcs.cos_ang(t);

    float xE = xD * funcs.cos_ang(this.rotation_Z) - yD * funcs.sin_ang(this.rotation_Z);
    float yE = xD * funcs.sin_ang(this.rotation_Z) + yD * funcs.cos_ang(this.rotation_Z);
    float zE = zD;

    this.CAM_x = (xE + P[0]) * OBJECTS_scale;
    this.CAM_y = (yE + P[1]) * OBJECTS_scale;
    this.CAM_z = (zE + P[2]) * OBJECTS_scale;

    WIN3D.reverseTransform_3DViewport();
  }

  void rotateXY_3DViewport_around_Selection (float t) {
    this.rotation_Z += t;

    float[] A = cameraPositionScaled();
    float[] P = Select3D.getPivot();

    float dx = A[0] - P[0];
    float dy = A[1] - P[1];

    float xB = P[0] + dx * funcs.cos_ang(t) - dy * funcs.sin_ang(t);
    float yB = P[1] + dx * funcs.sin_ang(t) + dy * funcs.cos_ang(t);
    float zB = A[2];

    this.CAM_x = xB * OBJECTS_scale;
    this.CAM_y = yB * OBJECTS_scale;
    this.CAM_z = zB * OBJECTS_scale;

    WIN3D.reverseTransform_3DViewport();
  }

  void rotateXY_3DViewport_around_LandIntersection (float t) {
    float Image_X = SOLARCHVISION_X_click1 - (this.cX + 0.5 * this.dX);
    float Image_Y = SOLARCHVISION_Y_click1 - (this.cY + 0.5 * this.dY);

    float[] ray_direction = new float[3];
    float[] ray_start = { this.CAM_x, this.CAM_y, this.CAM_z };
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
    if (RxP[0] < 0) return;

    float xO = RxP[1] / OBJECTS_scale;
    float yO = RxP[2] / OBJECTS_scale;

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


  void reverseTransform_3DViewport () { // computes position_X/Y/Z from the current camera point
    float[] r1 = rotateAroundZ(this.CAM_x, this.CAM_y, this.CAM_z, -this.rotation_Z);
    float[] CAM1 = rotateAroundX(r1[0], r1[1], r1[2], -this.rotation_X);

    this.CAM_fov = this.Zoom * PI / 180;
    this.CAM_dist = (0.5 * this.refScale) / tan(0.5 * this.CAM_fov);
    float scaleFactor = tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);
    float CAM2_z = this.CAM_dist * scaleFactor; // CAM2_x, CAM2_y are 0 before scaling

    this.position_X = 0 - CAM1[0];
    this.position_Y = -(0 - CAM1[1]);
    this.position_Z = CAM2_z - CAM1[2];
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

    float scaleFactor = tan(0.5 * this.CAM_fov) / tan(0.5 * PI / 3.0);
    this.CAM_x = 0;
    this.CAM_y = 0;
    this.CAM_z = this.CAM_dist * scaleFactor;

    this.CAM_x -= this.position_X;
    this.CAM_y += this.position_Y;
    this.CAM_z -= this.position_Z;

    float[] r1 = rotateAroundX(this.CAM_x, this.CAM_y, this.CAM_z, this.rotation_X);
    float[] r2 = rotateAroundZ(r1[0], r1[1], r1[2], this.rotation_Z);

    this.CAM_x = r2[0];
    this.CAM_y = r2[1];
    this.CAM_z = r2[2];

    //println("Camera:", nf(this.CAM_x,0,4), nf(this.CAM_y,0,4), nf(this.CAM_z,0,4));
  }

  float[] calculate_Click3D (float Image_X, float Image_Y) {
    float PNT_x, PNT_y, PNT_z;

    if (this.ViewType == 1) {
      PNT_z = 0.5 / tan(0.5 * PI / 3.0); // for perspective: any value the plane we need the results on!
      PNT_x = PNT_z * Image_X / ((0.5 * this.scale / tan(0.5 * this.CAM_fov)) * this.refScale);
      PNT_y = PNT_z * -Image_Y / ((0.5 * this.scale / tan(0.5 * this.CAM_fov)) * this.refScale);
    } else {
      float ZOOM = this.Orthographic_ZOOM();
      PNT_z = (0.5 * this.refScale) / tan(0.5 * PI / 3.0); // for orthographic: should be this.
      PNT_x = ZOOM * Image_X / (0.5 * this.scale);
      PNT_y = ZOOM * -Image_Y / (0.5 * this.scale);
    }

    float[] r1 = rotateAroundX(PNT_x, PNT_y, PNT_z, -this.rotation_X);
    float[] r2 = rotateAroundZ(r1[0], r1[1], r1[2], this.rotation_Z);

    PNT_x = r2[0] + this.CAM_x;
    PNT_y = r2[1] + this.CAM_y;
    PNT_z = r2[2] - this.CAM_z;

    return new float[] { PNT_x, PNT_y, -PNT_z };
  }

  float[] calculate_Perspective_Internally (float x, float y, float z) {
    x -= this.CAM_x;
    y -= this.CAM_y;
    z += this.CAM_z;

    float[] r1 = rotateAroundZ(x, y, z, -this.rotation_Z);
    float[] r2 = rotateAroundX(r1[0], r1[1], r1[2], this.rotation_X);
    x = r2[0];
    y = r2[1];
    z = r2[2];

    float Image_X = FLOAT_undefined;
    float Image_Y = FLOAT_undefined;
    float Image_Z = -FLOAT_undefined; // negative so that it's automatically illuminated by draw()

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

    return new float[] { Image_X, Image_Y, Image_Z };
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

  float shadingQuality = 0.75f;
  boolean showShading = false;
  boolean showSolarImpact = false;
}
