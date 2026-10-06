class WIN3D {

  final static String CLASS_STAMP = "WIN3D";

  // scales
  float scale;
  // (top-left) corner
  int cX = pixel_W;
  int cY = pixel_A + pixel_B + 0;
  // width and height
  int dX = pixel_W;
  int dY = pixel_H;
  float view_R = float(dY) / float(dX);

  float positionX = 0;
  float positionY = 5;
  float positionZ = 55;
  float positionStep = 1.0; // step

  float rotationX = 90;
  float rotationY = 0;
  float rotationZ = -45.0;
  float rotationStep = 5.0; // step

  float zoom = 90.0; //60.0; // / (pixel_H / 300.0);

  int projectionTypeIndex = 1; // 0: Ortho 1: Perspective

  boolean update = true;
  boolean include = true;

  boolean fullPeriod_IMG = false;
  boolean record_IMG = false;
  boolean record_AUTO = false;

  float ImageScale = 1.0;

  float cameraX;
  float cameraY;
  float cameraZ;
  float cameraFieldOfView;
  float cameraDistance;

  float cameraClipNear = 0.01;
  float cameraClipFar = 2000000000.0;

  float referenceScale = 100; // it improves displaying the shaded scene!

  int currentCameraIndex = 0; // 0 = Free Viewport | etc.= Saved Viewport

  int currentTool = UITASK.zoom_Orbit_Pan;
  int targetAxisIndex = 0; // 0-1
  int toolParameterModifier = 0; //to modify objects with several parameters e.g. allModel1Ds

  int shadingMode = SHADE.Surface_Materials; //Shade_Surface_White; // <<<<<

  int impactTypeIndex = Impact_ACTIVE;

  PGraphics graphics;

  // Rotates (x, y, z) by angleDeg around the X axis (x is unchanged).
  float[] rotateAroundX (float x, float y, float z, float angleDeg) {
    float ny = y * funcs.cos_ang(angleDeg) - z * funcs.sin_ang(angleDeg);
    float nz = y * funcs.sin_ang(angleDeg) + z * funcs.cos_ang(angleDeg);
    return new float[] { x, ny, nz };
  }

  // Rotates (x, y, z) by angleDeg around the Z axis (z is unchanged).
  float[] rotateAroundZ (float x, float y, float z, float angleDeg) {
    float nx = x * funcs.cos_ang(angleDeg) - y * funcs.sin_ang(angleDeg);
    float ny = x * funcs.sin_ang(angleDeg) + y * funcs.cos_ang(angleDeg);
    return new float[] { nx, ny, z };
  }

  float[] cameraPositionScaled () {
    return new float[] { this.cameraX / overallScale, this.cameraY / overallScale, this.cameraZ / overallScale };
  }

  float[] imageCenterRayScaled () {
    float[] ray_end = this.calculate_Click3D(0, 0);
    return new float[] { ray_end[0] / overallScale, ray_end[1] / overallScale, ray_end[2] / overallScale };
  }

  void put_3DViewport () {
    if (this.projectionTypeIndex == 1) {
      float aspect = 1.0 / this.view_R;
      float zFar = this.cameraDistance * this.cameraClipFar;
      float zNear = this.cameraDistance * this.cameraClipNear;

      this.graphics.perspective(this.cameraFieldOfView, aspect, zNear, zFar);
    } else {
      float ZOOM = this.Orthographic_ZOOM();
      this.graphics.ortho(ZOOM * this.dX * -1, ZOOM * this.dX * 1, ZOOM * this.dY * -1, ZOOM * this.dY * 1, 0.00001, 100000);
    }

    this.graphics.translate(0.5 * this.dX, 0.5 * this.dY, 0); // << IMPORTANT!
    this.graphics.translate(this.positionX * this.scale, this.positionY * this.scale, this.positionZ * this.scale);

    this.graphics.rotateX(this.rotationX * PI / 180);
    this.graphics.rotateZ(this.rotationZ * PI / 180);
  }

  float Orthographic_ZOOM () {
    float ZOOM = 0.5 * this.zoom * PI / 180;
    ZOOM *= pow(pow(this.positionX, 2) + pow(this.positionY, 2) + pow(this.positionZ, 2), 0.5);
    ZOOM /= this.referenceScale;
    return ZOOM;
  }

  void draw () {
    if (!this.update) return;

    if (Select3D.update_BoundingBox) {
      Select3D.calculate_BoundingBox();
    }

    beginImageScale();

    int firstDay = impactDisplayDay;
    int lastDay = impactDisplayDay;
    if (this.fullPeriod_IMG) {
      this.fullPeriod_IMG = false;
      firstDay = 0;
      lastDay = STUDY.endDay;
    }

    int keep_impactDisplayDay = impactDisplayDay;
    for (impactDisplayDay = lastDay; impactDisplayDay >= firstDay; impactDisplayDay--) {
      renderFrame();
    }
    impactDisplayDay = keep_impactDisplayDay;

    imageMode(CORNER);
    image(this.graphics, this.cX, this.cY, this.dX / this.ImageScale, this.dY / this.ImageScale);

    if (this.record_IMG || !this.record_AUTO) this.record_IMG = false;

    endImageScale();
  }

  void beginImageScale () {
    if (this.record_IMG) this.ImageScale = 1; //2; //3;
    else this.ImageScale = 1;

    this.dX *= this.ImageScale;
    this.dY *= this.ImageScale;

    if (this.ImageScale != 1) {
      println("IMG:high-res");
      this.graphics = createGraphics(this.dX, this.dY, P3D);
    }
  }

  void endImageScale () {
    this.dX /= this.ImageScale;
    this.dY /= this.ImageScale;

    if (this.ImageScale != 1) {
      this.graphics = createGraphics(this.dX, this.dY, P3D);
      this.updated();
    } else {
      this.updated();
      Overlay3D.draw();
    }
  }

  void renderFrame () {
    this.graphics.beginDraw();

    this.scale = this.dY / this.referenceScale; // fits field of view to window's height

    this.graphics.background(233);
    this.graphics.fill(127);
    this.graphics.strokeWeight(0);

    this.graphics.pushMatrix();
    this.graphics.hint(ENABLE_DEPTH_TEST);

    this.record_last3DViewport();
    this.transform_3DViewport();
    this.put_3DViewport();

    drawSceneContents();

    this.graphics.hint(DISABLE_DEPTH_TEST);

    if (!(this.record_IMG || this.record_AUTO)) {
      this.draw_referencePivot();
    }

    this.graphics.popMatrix();

    this.drawPalette();

    this.graphics.endDraw();

    if (this.record_IMG || this.record_AUTO) {
      saveRecordedFrame();
    }
  }

  void drawSceneContents () {
    Sky3D.draw(TypeWindow.WIN3D);
    Sun3D.drawPattern(TypeWindow.WIN3D, 0, 0, 0, 0.975 * Sky3D.radius);
    Sun3D.drawPath(TypeWindow.WIN3D, 0, 0, 0, 0.975 * Sky3D.radius);
    Sun3D.drawGrid(TypeWindow.WIN3D, 0, 0, 0, 0.975 * Sky3D.radius, 0, 360);
    Sun3D.draw();
    Moon3D.draw();
    Earth3D.draw(TypeWindow.WIN3D);
    Terrain.draw(TypeWindow.WIN3D);
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

  void saveRecordedFrame () {
    String myFile = MAKE_Filename(createStamp(1, CLASS_STAMP));

    if (this.impactTypeIndex == Impact_ACTIVE) myFile += "_RAD";
    if (this.impactTypeIndex == Impact_PASSIVE) myFile += "_EFF";
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

  boolean isSolarPaletteMode () {
    return (this.shadingMode == SHADE.Global_Solar) ||
           (this.shadingMode == SHADE.Vertex_Solar) ||
           (allSolarImpacts.displayImage && (allSections.SolarImpact.length > 0));
  }

  float[] choosePaletteParams () {
    int type = 0;
    int direction = 1;
    float multiplier = 1;
    boolean draw_pal = false;

    if (isSolarPaletteMode()) {
      if (this.impactTypeIndex == Impact_ACTIVE) {
        type = allFaces.activeColorscaleIndex;
        direction = allFaces.activeColorscaleDirection;
        multiplier = allFaces.activeColorscaleFactor;
      }
      if (this.impactTypeIndex == Impact_PASSIVE) {
        type = allFaces.passiveColorscaleIndex;
        direction = allFaces.passiveColorscaleDirection;
        multiplier = allFaces.passiveColorscaleFactor;
      }
      draw_pal = true;
    }

    if (this.shadingMode == SHADE.Vertex_Elevation) {
      type = Terrain.colorScaleIndex;
      direction = Terrain.colorScaleDirection;
      multiplier = Terrain.colorScaleFactor;
      draw_pal = true;
    }

    if (this.shadingMode == SHADE.Vertex_Solid) {
      type = allSolids.colorScaleIndex;
      direction = allSolids.colorScaleDirection;
      multiplier = allSolids.colorScaleFactor;
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

    float the_scale = (this.projectionTypeIndex == 1) ? (0.5 / tan(0.5 * this.cameraFieldOfView)) : (0.5 / this.Orthographic_ZOOM());

    this.graphics.pushMatrix();

    this.cameraFieldOfView = this.zoom * PI / 180;
    this.cameraDistance = (0.5 * this.referenceScale) / tan(0.5 * this.cameraFieldOfView);

    this.graphics.translate(0.5 * this.dX, 0.5 * this.dY, 0); // << IMPORTANT!

    float pal_length = 1 * pixel_H * this.ImageScale / the_scale;
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

  void drawPaletteSegment (int q, int PAL_type, int PAL_direction, float PAL_multiplier, float pal_length, float y1, float y2, float y, float txtSize) {
    float x1 = -0.5 * pal_length + q * (pal_length / 11.0);
    float x2 = x1 + (pal_length / 11.0);
    float x = 0.5 * (x1 + x2);

    float _u = 0.2 * q - 0.5;
    if (isSolarPaletteMode()) {
      if (this.impactTypeIndex == Impact_ACTIVE) _u = 0.1 * q;
      if (this.impactTypeIndex == Impact_PASSIVE) _u = 0.2 * q - 0.5;
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
      if (this.impactTypeIndex == Impact_ACTIVE) this.graphics.text(nf((funcs.roundTo(0.1 * q / PAL_multiplier, 0.1)), 1, 1), x, y, 0);
      if (this.impactTypeIndex == Impact_PASSIVE) this.graphics.text(nf(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 0.1), 1, 1), x, y, 0);
    }

    if (this.shadingMode == SHADE.Vertex_Elevation) {
      this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), x, y, 0);
    }

    if (this.shadingMode == SHADE.Vertex_Solid) {
      this.graphics.text(nf(int(funcs.roundTo(0.4 * (q - 5) / PAL_multiplier, 1)), 1), x, y, 0);
    }
  }

  void drawPaletteCaption (float pal_length, float y, float y1, float txtSize) {
    this.graphics.noStroke();
    this.graphics.fill(127);

    String txt = "";
    this.graphics.textAlign(LEFT, CENTER);

    if ((this.shadingMode != SHADE.Vertex_Elevation) && (this.shadingMode != SHADE.Vertex_Solid)) {
      if (this.impactTypeIndex == Impact_ACTIVE) this.graphics.text(" kW/m²", 0.5 * pal_length, y, 0);
      if (this.impactTypeIndex == Impact_PASSIVE) this.graphics.text(" %kW°C/m²", 0.5 * pal_length, y, 0);

      txt += "SOLARCHVISION ";
      if (this.impactTypeIndex == Impact_ACTIVE) txt += "active model ";
      if (this.impactTypeIndex == Impact_PASSIVE) txt += "passive model ";

      if (impactDisplayDay != 0) {
        txt += TIME.getDayText((impactDisplayDay - 1) * STUDY.dayIncrement + 286 + TIME.beginDay);
      } else {
        txt += TIME.getDayText(STUDY.startDay * STUDY.dayIncrement + 286 + TIME.beginDay) + " - ";
        txt += TIME.getDayText((STUDY.endDay - 1) * STUDY.dayIncrement + 286 + TIME.beginDay);
      }
    }

    this.graphics.textAlign(CENTER, CENTER);
    this.graphics.text(txt, 0, y1 - 1.0 * txtSize, 0);
  }

  void reviseViews () {
    this.revise();
    UI_rollout.revise();
  }

  // --- Continuous key-hold navigation ---------------------------------
  // Processing 4's P2D/P3D (JOGL/NEWT) windowing surface, unlike v2, does
  // not forward the OS's key-repeat events while a key is held down: a
  // held key only ever produces a single keyPressed(). To get the old
  // "keep navigating until key up" behavior back, we instead track which
  // navigation key is currently held and re-run its action from draw(),
  // via processHeldKey(), for as long as it stays held, rather than
  // relying on repeat events that Processing no longer sends.
  // Delay-then-repeat, like an OS key-repeat setting, at frameRate(24):
  // ~0.25s before the first repeat, then one step every frame (~24/s).
  static final int NAV_KEY_INITIAL_DELAY_FRAMES = 6;
  static final int NAV_KEY_REPEAT_FRAMES = 1;
  boolean navKeyHeld = false;
  boolean navKeyRepeatable = false;
  boolean navKeyCoded = false;
  char navKeyChar = 0;
  int navKeyCode = 0;
  boolean navKeyShift = false;
  boolean navKeyCtrl = false;
  boolean navKeyAlt = false;
  int navKeyFrameCounter = 0;
  boolean navKeyRepeating = false;

  void keyPressed (KeyEvent e) {
    if (!this.include) return;

    boolean altDown = e.isAltDown();
    if (altDown && !(
      (key == CODED) && (
        (keyCode == UP) ||
        (keyCode == LEFT) ||
        (keyCode == DOWN) ||
        (keyCode == RIGHT)
      )
    )) return;

    boolean ctrlDown = e.isControlDown();
    if (ctrlDown && !(
      (key == ',') || (key == '.'))
    ) return;

    this.navKeyAlt = altDown;
    this.navKeyCtrl = ctrlDown;
    this.navKeyCoded = (key == CODED);
    this.navKeyChar = key;
    this.navKeyCode = keyCode;
    this.navKeyShift = e.isShiftDown();

    // Arrow keys / Shift+arrows (camera or selection nudges) always repeat
    // while held; among the plain command keys, only the incremental
    // view rotate/pan/zoom ones do (this also covers Ctrl+,/Ctrl+., since
    // ',' and '.' are already repeatable below regardless of Ctrl).
    // Everything else (camera cycling, shading toggle, day-cycle, Delete,
    // rebuild-trigger, snap-to-look, Shift+Tab) is a discrete/one-shot/
    // destructive action and must stay single-press only, regardless of
    // how long the key is held.
    this.navKeyRepeatable = !altDown &&
      (this.navKeyCoded || isRepeatableCommandKey(this.navKeyChar));


    this.navKeyHeld = true;
    this.navKeyFrameCounter = 0;
    this.navKeyRepeating = false;

    this.dispatchNavKey();
  }

  boolean isRepeatableCommandKey (char cmdKey) {
    switch (cmdKey) {
      case ',':
      case '.':
      case '0':
      case '4':
      case '6':
      case '8':
      case '2':
      case '1':
      case '3':
      case '7':
      case '9':
      case '*':
      case '/':
      case '+':
      case '-':
        return true;
      default:
        return false;
    }
  }

  // Called once per frame from the sketch's draw(); re-fires the held
  // key's action for as long as it remains held and is repeatable.
  void processHeldKey () {
    if (this.include && this.navKeyHeld && this.navKeyRepeatable) {
      this.navKeyFrameCounter++;
      int threshold = this.navKeyRepeating ? NAV_KEY_REPEAT_FRAMES : NAV_KEY_INITIAL_DELAY_FRAMES;
      if (this.navKeyFrameCounter >= threshold) {
        this.navKeyFrameCounter = 0;
        this.navKeyRepeating = true;
        this.dispatchNavKey();
      }
    }
  }

  // Uses the global keyReleased() (no KeyEvent overload needed, matching
  // the sketch's existing keyReleased() convention) so it can be called
  // unconditionally without worrying about which handler owns the event.
  void keyReleased () {
    if (!this.navKeyHeld) return;

    boolean releasedCoded = (key == CODED);
    if (releasedCoded != this.navKeyCoded) return;

    if (releasedCoded) {
      if (keyCode == this.navKeyCode) this.navKeyHeld = false;
    } else {
      if (key == this.navKeyChar) this.navKeyHeld = false;
    }
  }

  void dispatchNavKey () {
    if (this.navKeyCoded) {
      if (this.navKeyAlt) {
        handleAltArrowKeys(this.navKeyCode);
      } else if (this.navKeyShift) {
        handleShiftedArrowKeys(this.navKeyCode);
      } else {
        handleArrowKeys(this.navKeyCode);
      }
    } else if (this.navKeyCtrl) {
      handleCtrlCommandKey(this.navKeyChar);
    } else {
      handleCommandKey(this.navKeyChar, this.navKeyShift);
    }
  }

  void handleCtrlCommandKey (char cmdKey) {
    switch (cmdKey) {
      case ',':
        callAction("Nudge Closer to Selection");
        break;

      case '.':
        callAction("Nudge Away from Selection");
        break;
    }
  }

  // Order here is adjustShadeTime() then ShadeViewport() - opposite of
  // ' '/BACKSPACE above, which is ShadeViewport() then adjustShadeTime() -
  // preserved exactly as it always was rather than unified, since that's
  // a real difference in the original code, not an inconsistency this
  // refactor should quietly paper over.
  void handleAltArrowKeys (int keyCode) {
    switch (keyCode) {
      case RIGHT:
        runScriptLines(new String[]{"Shade Time +1 Hour", "Shade Viewport"});
        this.revise();
        break;

      case LEFT:
        runScriptLines(new String[]{"Shade Time -1 Hour", "Shade Viewport"});
        this.revise();
        break;

      case UP:
        runScriptLines(new String[]{"Shade Time +1 Day", "Shade Viewport"});
        this.revise();
        break;

      case DOWN:
        runScriptLines(new String[]{"Shade Time -1 Day", "Shade Viewport"});
        this.revise();
        break;
    }
  }

  void handleShiftedArrowKeys (int keyCode) {
    switch (keyCode) {
      case UP:
        callAction("Increase Tool Parameter");
        break;
      case DOWN:
        callAction("Decrease Tool Parameter");
        break;
    }
  }

  void handleArrowKeys (int keyCode) {
    switch (keyCode) {
      case DOWN:
        callAction("Orbit Down Around Selection");
        reviseViews();
        break;
      case LEFT:
        callAction("Orbit Left Around Selection");
        reviseViews();
        break;
      case RIGHT:
        callAction("Orbit Right Around Selection");
        reviseViews();
        break;
      case UP:
        callAction("Orbit Up Around Selection");
        reviseViews();
        break;
    }
  }

  void handleCommandKey (char cmdKey, boolean shiftDown) {
    switch (cmdKey) {

      case TAB:
        if (shiftDown) {
          callAction("Toggle Impact Type");
          reviseViews();
        }
        break;

      case DELETE:
        callAction("Delete Selection");
        reviseViews();
        break;

      // '0' has always been an exact duplicate of ',' (see "Zoom Out"'s
      // own comment in actions.pde) - both just run it.
      case ',':
      case '0':
        callAction("Zoom Out");
        reviseViews();
        break;

      case '.':
        callAction("Zoom In");
        reviseViews();
        break;

      case '5':
        // "Look at selection" does more than this key used to (also
        // switches to the CameraDistance tool, see UI_setTo_View_LookAtSelection)
        // - reused as-is rather than as a stripped-down duplicate, on the
        // view that "the same thing" means the existing, richer action,
        // not a new minimal one built to avoid its side effect. No
        // separate reviseViews() after: that action already calls
        // UI_rollout.revise() and view_changed() (= WIN3D.revise())
        // itself, which together are exactly what reviseViews() does.
        runScriptLines(new String[]{"Look at selection"});
        break;

      case '4':
        callAction("Turn View Left");
        reviseViews();
        break;
      case '6':
        callAction("Turn View Right");
        reviseViews();
        break;
      case '8':
        callAction("Turn View Up");
        reviseViews();
        break;
      case '2':
        callAction("Turn View Down");
        reviseViews();
        break;

      case '1':
        callAction("Pan Left");
        reviseViews();
        break;
      case '3':
        callAction("Pan Right");
        reviseViews();
        break;
      case '7':
        callAction("Pan Forward");
        reviseViews();
        break;
      case '9':
        callAction("Pan Backward");
        reviseViews();
        break;

      case '*':
        callAction("Dolly Away From Selection");
        reviseViews();
        break;
      case '/':
        callAction("Dolly Toward Selection");
        reviseViews();
        break;

      case '+':
        callAction("Narrow Field of View");
        reviseViews();
        break;
      case '-':
        callAction("Widen Field of View");
        reviseViews();
        break;

      case 'c':
        callAction("Next Camera");
        reviseViews();
        break;

      case 'C':
        callAction("Previous Camera");
        reviseViews();
        break;

      case 't':
        callAction("Advance Troposphere Time");
        break;
      case 'T':
        callAction("Rewind Troposphere Time");
        break;

      case 'd':
        callAction("Next Impact Day");
        reviseViews();
        break;
      case 'D':
        callAction("Previous Impact Day");
        reviseViews();
        break;

      case ENTER:
        callAction("Recalculate Solar Impact");
        reviseViews();
        break;

      // No reviseViews()/revise() after either: that was already true
      // before these ran through allActions (ShadeViewport()/
      // adjustShadeTime() apparently don't need one here), so this
      // preserves that exactly rather than adding a refresh call that
      // wasn't there before.
      case ' ':
        runScriptLines(new String[]{"Shade Viewport", "Shade Time +1 Hour"});
        break;

      case BACKSPACE:
        runScriptLines(new String[]{"Shade Viewport", "Shade Time -1 Hour"});
        break;
    }
  }

  void look_3DViewport_towards_Direction (float Image_X, float Image_Y) {
    this.lookXY_3DViewport_towards_Direction(Image_X, Image_Y);
    this.lookZ_3DViewport_towards_Direction(Image_X, Image_Y);
  }

  void rotateZTowards (float xB, float yB) {
    float[] O = cameraPositionScaled();
    float[] A = imageCenterRayScaled();
    this.rotationZ += funcs.atan2_ang((yB - O[1]), (xB - O[0])) - funcs.atan2_ang((A[1] - O[1]), (A[0] - O[0]));
    this.reverseTransform_3DViewport();
  }

  void rotateXTowards (float xB, float yB, float zB) {
    float[] O = cameraPositionScaled();
    float[] A = imageCenterRayScaled();
    this.rotationX += funcs.atan2_ang((zB - O[2]), pow(pow(yB - O[1], 2) + pow(xB - O[0], 2), 0.5))
                      - funcs.atan2_ang((A[2] - O[2]), pow(pow(A[1] - O[1], 2) + pow(A[0] - O[0], 2), 0.5));
    this.reverseTransform_3DViewport();
  }

  void lookXY_3DViewport_towards_Direction (float Image_X, float Image_Y) {
    float[] P = this.calculate_Click3D(Image_X, Image_Y);
    rotateZTowards(P[0] / overallScale, P[1] / overallScale);
  }

  void lookZ_3DViewport_towards_Direction (float Image_X, float Image_Y) {
    float[] P = this.calculate_Click3D(Image_X, Image_Y);
    rotateXTowards(P[0] / overallScale, P[1] / overallScale, P[2] / overallScale);
  }

  void look_3DViewport_towards_Selection () {
    this.lookXY_3DViewport_towards_Selection();
    this.lookZ_3DViewport_towards_Selection();
  }

  void lookXY_3DViewport_towards_Selection () {
    float[] P = Select3D.getPivot();
    rotateZTowards(P[0], P[1]);
  }

  void lookZ_3DViewport_towards_Selection () {
    float[] P = Select3D.getPivot();
    rotateXTowards(P[0], P[1], P[2]);
  }

  void moveCameraTowards (float xO, float yO, float zO, float t) {
    float[] A = cameraPositionScaled();

    float dx = A[0] - xO;
    float dy = A[1] - yO;
    float dz = A[2] - zO;

    this.cameraX = (xO + t * dx) * overallScale;
    this.cameraY = (yO + t * dy) * overallScale;
    this.cameraZ = (zO + t * dz) * overallScale;

    this.reverseTransform_3DViewport();
    //this.positionStep *= t; // just to adjust panning better
  }

  void move_3DViewport_towards_Mouse (float t) {
    float Image_X = mouseX - (this.cX + 0.5 * this.dX);
    float Image_Y = mouseY - (this.cY + 0.5 * this.dY);
    float[] ray_end = this.calculate_Click3D(Image_X, Image_Y);
    moveCameraTowards(ray_end[0] / overallScale, ray_end[1] / overallScale, ray_end[2] / overallScale, t);
  }

  void move_3DViewport_towards_Selection (float t) {
    float[] P = Select3D.getPivot();
    moveCameraTowards(P[0], P[1], P[2], t);
  }

  void rotateZ_3DViewport_around_Selection (float t) {
    this.rotationX += t;

    float[] A = cameraPositionScaled();
    float[] P = Select3D.getPivot();

    float xB = A[0] - P[0];
    float yB = A[1] - P[1];
    float zB = A[2] - P[2];

    // rotate into the yz plane, rotate there by t, then rotate back
    float xC = xB * funcs.cos_ang(-this.rotationZ) - yB * funcs.sin_ang(-this.rotationZ);
    float yC = xB * funcs.sin_ang(-this.rotationZ) + yB * funcs.cos_ang(-this.rotationZ);
    float zC = zB;

    float xD = xC;
    float yD = yC * funcs.cos_ang(t) - zC * funcs.sin_ang(t);
    float zD = yC * funcs.sin_ang(t) + zC * funcs.cos_ang(t);

    float xE = xD * funcs.cos_ang(this.rotationZ) - yD * funcs.sin_ang(this.rotationZ);
    float yE = xD * funcs.sin_ang(this.rotationZ) + yD * funcs.cos_ang(this.rotationZ);
    float zE = zD;

    this.cameraX = (xE + P[0]) * overallScale;
    this.cameraY = (yE + P[1]) * overallScale;
    this.cameraZ = (zE + P[2]) * overallScale;

    this.reverseTransform_3DViewport();
  }

  void rotateXY_3DViewport_around_Selection (float t) {
    this.rotationZ += t;

    float[] A = cameraPositionScaled();
    float[] P = Select3D.getPivot();

    float dx = A[0] - P[0];
    float dy = A[1] - P[1];

    float xB = P[0] + dx * funcs.cos_ang(t) - dy * funcs.sin_ang(t);
    float yB = P[1] + dx * funcs.sin_ang(t) + dy * funcs.cos_ang(t);
    float zB = A[2];

    this.cameraX = xB * overallScale;
    this.cameraY = yB * overallScale;
    this.cameraZ = zB * overallScale;

    this.reverseTransform_3DViewport();
  }

  void rotateXY_3DViewport_around_LandIntersection (float t) {
    float Image_X = X_click1 - (this.cX + 0.5 * this.dX);
    float Image_Y = Y_click1 - (this.cY + 0.5 * this.dY);

    ClickRay ray = computeClickRay(Image_X, Image_Y);
    float[] ray_start = ray.start;
    float[] ray_direction = ray.direction;

    float[] RxP = Terrain.intersect(ray_start, ray_direction);
    if (RxP[0] < 0) return;

    float xO = RxP[1] / overallScale;
    float yO = RxP[2] / overallScale;

    float xA = ray_start[0];
    float yA = ray_start[1];
    float zA = ray_start[2];

    float dx = xA - xO;
    float dy = yA - yO;

    this.rotationZ += t;

    float xB = xO + dx * funcs.cos_ang(t) - dy * funcs.sin_ang(t);
    float yB = yO + dx * funcs.sin_ang(t) + dy * funcs.cos_ang(t);
    float zB = zA;

    this.cameraX = xB * overallScale;
    this.cameraY = yB * overallScale;
    this.cameraZ = zB * overallScale;

    this.reverseTransform_3DViewport();
  }


  void reverseTransform_3DViewport () { // computes positionX/Y/Z from the current camera point
    float[] r1 = rotateAroundZ(this.cameraX, this.cameraY, this.cameraZ, -this.rotationZ);
    float[] CAM1 = rotateAroundX(r1[0], r1[1], r1[2], -this.rotationX);

    this.cameraFieldOfView = this.zoom * PI / 180;
    this.cameraDistance = (0.5 * this.referenceScale) / tan(0.5 * this.cameraFieldOfView);
    float scaleFactor = tan(0.5 * this.cameraFieldOfView) / tan(0.5 * PI / 3.0);
    float CAM2_z = this.cameraDistance * scaleFactor; // CAM2_x, CAM2_y are 0 before scaling

    this.positionX = 0 - CAM1[0];
    this.positionY = -(0 - CAM1[1]);
    this.positionZ = CAM2_z - CAM1[2];
  }

  void record_last3DViewport () {
    allCameras.set_posX(this.currentCameraIndex, this.positionX);
    allCameras.set_posY(this.currentCameraIndex, this.positionY);
    allCameras.set_posZ(this.currentCameraIndex, this.positionZ);
    allCameras.set_posT(this.currentCameraIndex, this.positionStep);
    allCameras.set_rotX(this.currentCameraIndex, this.rotationX);
    allCameras.set_rotY(this.currentCameraIndex, this.rotationY);
    allCameras.set_rotZ(this.currentCameraIndex, this.rotationZ);
    allCameras.set_rotT(this.currentCameraIndex, this.rotationStep);
    allCameras.set_zoom(this.currentCameraIndex, this.zoom);
    allCameras.set_type(this.currentCameraIndex, this.projectionTypeIndex);
  }

  void apply_currentCameraIndex () {
    this.positionX = allCameras.get_posX(this.currentCameraIndex);
    this.positionY = allCameras.get_posY(this.currentCameraIndex);
    this.positionZ = allCameras.get_posZ(this.currentCameraIndex);
    this.positionStep = allCameras.get_posT(this.currentCameraIndex);
    this.rotationX = allCameras.get_rotX(this.currentCameraIndex);
    this.rotationY = allCameras.get_rotY(this.currentCameraIndex);
    this.rotationZ = allCameras.get_rotZ(this.currentCameraIndex);
    this.rotationStep = allCameras.get_rotT(this.currentCameraIndex);
    this.zoom       = allCameras.get_zoom(this.currentCameraIndex);
    this.projectionTypeIndex   = allCameras.get_type(this.currentCameraIndex);
  }

  void transform_3DViewport () {
    this.cameraFieldOfView = this.zoom * PI / 180;
    this.cameraDistance = (0.5 * this.referenceScale) / tan(0.5 * this.cameraFieldOfView);

    float scaleFactor = tan(0.5 * this.cameraFieldOfView) / tan(0.5 * PI / 3.0);
    this.cameraX = 0;
    this.cameraY = 0;
    this.cameraZ = this.cameraDistance * scaleFactor;

    this.cameraX -= this.positionX;
    this.cameraY += this.positionY;
    this.cameraZ -= this.positionZ;

    float[] r1 = rotateAroundX(this.cameraX, this.cameraY, this.cameraZ, this.rotationX);
    float[] r2 = rotateAroundZ(r1[0], r1[1], r1[2], this.rotationZ);

    this.cameraX = r2[0];
    this.cameraY = r2[1];
    this.cameraZ = r2[2];
  }

  float[] calculate_Click3D (float Image_X, float Image_Y) {
    float PNT_x, PNT_y, PNT_z;

    if (this.projectionTypeIndex == 1) {
      PNT_z = 0.5 / tan(0.5 * PI / 3.0); // for perspective: any value the plane we need the results on!
      PNT_x = PNT_z * Image_X / ((0.5 * this.scale / tan(0.5 * this.cameraFieldOfView)) * this.referenceScale);
      PNT_y = PNT_z * -Image_Y / ((0.5 * this.scale / tan(0.5 * this.cameraFieldOfView)) * this.referenceScale);
    } else {
      float ZOOM = this.Orthographic_ZOOM();
      PNT_z = (0.5 * this.referenceScale) / tan(0.5 * PI / 3.0); // for orthographic: should be this.
      PNT_x = ZOOM * Image_X / (0.5 * this.scale);
      PNT_y = ZOOM * -Image_Y / (0.5 * this.scale);
    }

    float[] r1 = rotateAroundX(PNT_x, PNT_y, PNT_z, -this.rotationX);
    float[] r2 = rotateAroundZ(r1[0], r1[1], r1[2], this.rotationZ);

    PNT_x = r2[0] + this.cameraX;
    PNT_y = r2[1] + this.cameraY;
    PNT_z = r2[2] - this.cameraZ;

    return new float[] { PNT_x, PNT_y, -PNT_z };
  }

  // Transforms an object-space point into camera space (translated,
  // rotated, but not yet projected). Exposed separately from
  // calculate_Perspective_Internally so callers can interpolate two
  // camera-space points against the near plane (z == 0) before
  // projecting - e.g. when a line segment has one end in front of the
  // camera and one end behind it.
  float[] calculate_CameraSpace_Internally (float x, float y, float z) {
    x -= this.cameraX;
    y -= this.cameraY;
    z -= this.cameraZ;

    float[] r1 = rotateAroundZ(x, y, -z, -this.rotationZ);
    float[] r2 = rotateAroundX(r1[0], r1[1], r1[2], this.rotationX);

    return new float[] { r2[0], r2[1], r2[2] };
  }

  // Projects an already camera-space point (see
  // calculate_CameraSpace_Internally) to image space. Returns undefined
  // Image_X/Image_Y and a negative Image_Z whenever z <= 0, i.e. the
  // point is behind (or exactly at) the camera plane.
  float[] calculate_Perspective_fromCameraSpace (float x, float y, float z) {
    float Image_X = FLOAT_undefined;
    float Image_Y = FLOAT_undefined;
    float Image_Z = -FLOAT_undefined; // negative so that it's automatically illuminated by draw()

    if (z > 0) {
      if (this.projectionTypeIndex == 1) {
        Image_X = (x / z) * (0.5 * this.scale / tan(0.5 * this.cameraFieldOfView)) * this.referenceScale;
        Image_Y = -(y / z) * (0.5 * this.scale / tan(0.5 * this.cameraFieldOfView)) * this.referenceScale;
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

  float[] calculate_Perspective_Internally (float x, float y, float z) {
    float[] cam = calculate_CameraSpace_Internally(x, y, z);
    return calculate_Perspective_fromCameraSpace(cam[0], cam[1], cam[2]);
  }


  void incrementParameter (int direction) {
    float[] P = Select3D.getPivot();
    float x0 = P[0];
    float y0 = P[1];
    float z0 = P[2];

    if (this.currentTool == UITASK.Rotate) {
      float r = 5.0 * direction;
      int the_Vector = Select3D.rotationVectorIndex;
      Rotate3D.selection(x0, y0, z0, r, the_Vector);
      model_changed();
    }

    if (this.currentTool == UITASK.Scale) {
      float s = pow(2.0, 0.25);
      if (direction < 0) s = 1.0 / s;

      float sx = s, sy = s, sz = s;
      int the_Vector = Select3D.scaleVectorIndex;
      if (the_Vector == 0) { sy = 1; sz = 1; }
      if (the_Vector == 1) { sz = 1; sx = 1; }
      if (the_Vector == 2) { sx = 1; sy = 1; }

      Scale3D.selection(x0, y0, z0, sx, sy, sz);
      model_changed();
    }

    if (this.currentTool == UITASK.Move) {
      float d = 0.5 * direction;
      float dx = d, dy = d, dz = d;

      int the_Vector = Select3D.positionVectorIndex;
      if (the_Vector == 0) { dy = 0; dz = 0; }
      if (the_Vector == 1) { dz = 0; dx = 0; }
      if (the_Vector == 2) { dx = 0; dy = 0; }

      Move3D.selection(dx, dy, dz);
      model_changed();
    }

    if (this.toolParameterModifier == 0) {
      if (this.currentTool >= UITASK.Seed_Material) {
        int p = direction;
        Edit3D.selection(p);
        model_changed();
      }
    }
  }


  public void to_XML (XML xml) {
    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setFloat(parent, "cameraX", this.cameraX);
    XML_setFloat(parent, "cameraY", this.cameraY);
    XML_setFloat(parent, "cameraZ", this.cameraZ);
    XML_setFloat(parent, "cameraFieldOfView", this.cameraFieldOfView);
    XML_setFloat(parent, "cameraDistance", this.cameraDistance);
    XML_setFloat(parent, "cameraClipNear", this.cameraClipNear);
    XML_setFloat(parent, "cameraClipFar", this.cameraClipFar);
    XML_setInt(parent, "currentCameraIndex", this.currentCameraIndex);

    XML_setFloat(parent, "referenceScale", this.referenceScale);
    XML_setFloat(parent, "positionX", this.positionX);
    XML_setFloat(parent, "positionY", this.positionY);
    XML_setFloat(parent, "positionZ", this.positionZ);
    XML_setFloat(parent, "positionStep", this.positionStep);
    XML_setFloat(parent, "rotationX", this.rotationX);
    XML_setFloat(parent, "rotationY", this.rotationY);
    XML_setFloat(parent, "rotationZ", this.rotationZ);
    XML_setFloat(parent, "rotationStep", this.rotationStep);
    XML_setFloat(parent, "zoom", this.zoom);
    XML_setInt(parent, "projectionTypeIndex", this.projectionTypeIndex);
    XML_setInt(parent, "shadingMode", this.shadingMode);

    XML_setInt(parent, "currentTool", this.currentTool);
    XML_setInt(parent, "targetAxisIndex", this.targetAxisIndex);
    XML_setInt(parent, "toolParameterModifier", this.toolParameterModifier);

    XML_setInt(parent, "impactTypeIndex", this.impactTypeIndex);
  }

  public void from_XML (XML xml) {
    XML parent = xml.getChild(this.CLASS_STAMP);

    this.cameraX = XML_getFloat(parent, "cameraX");
    this.cameraY = XML_getFloat(parent, "cameraY");
    this.cameraZ = XML_getFloat(parent, "cameraZ");
    this.cameraFieldOfView = XML_getFloat(parent, "cameraFieldOfView");
    this.cameraDistance = XML_getFloat(parent, "cameraDistance");
    this.cameraClipNear = XML_getFloat(parent, "cameraClipNear");
    this.cameraClipFar = XML_getFloat(parent, "cameraClipFar");
    this.currentCameraIndex = XML_getInt(parent, "currentCameraIndex");

    this.referenceScale = XML_getFloat(parent, "referenceScale");
    this.positionX = XML_getFloat(parent, "positionX");
    this.positionY = XML_getFloat(parent, "positionY");
    this.positionZ = XML_getFloat(parent, "positionZ");
    this.positionStep = XML_getFloat(parent, "positionStep");
    this.rotationX = XML_getFloat(parent, "rotationX");
    this.rotationY = XML_getFloat(parent, "rotationY");
    this.rotationZ = XML_getFloat(parent, "rotationZ");
    this.rotationStep = XML_getFloat(parent, "rotationStep");

    this.zoom = XML_getFloat(parent, "zoom");
    this.projectionTypeIndex = XML_getInt(parent, "projectionTypeIndex");
    this.shadingMode = XML_getInt(parent, "shadingMode");

    this.currentTool = XML_getInt(parent, "currentTool");
    this.targetAxisIndex = XML_getInt(parent, "targetAxisIndex");
    this.toolParameterModifier = XML_getInt(parent, "toolParameterModifier");

    this.impactTypeIndex = XML_getInt(parent, "impactTypeIndex");
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
