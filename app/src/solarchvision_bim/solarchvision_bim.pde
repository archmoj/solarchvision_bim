import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Calendar;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import org.apache.commons.compress.compressors.bzip2.BZip2CompressorInputStream;
import processing.data.IntList;
import processing.pdf.*;

String SOLARCHVISION_version = "2026";

String BaseFolder = sketchPath();
String SceneName = "";

float MessageSize = 15.0;
int SOLARCHVISION_pixel_A = 24; // menu bar
int SOLARCHVISION_pixel_B = 42; // 3D tool bar
int SOLARCHVISION_pixel_C = 72; // case bar
int SOLARCHVISION_pixel_D = 72; // command bar

int SOLARCHVISION_pixel_H = 100; // just an initial value
int SOLARCHVISION_pixel_W = 100; // just an initial value

void setup () {
  parseArgs(args);

  fullScreen(P2D);

  SOLARCHVISION_pixel_W = (width - UI_rollout.dX) / 2;
  SOLARCHVISION_pixel_H = (height - (SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + SOLARCHVISION_pixel_C + SOLARCHVISION_pixel_D)) / 2;

  // resize windows
  MESSAGE = new solarchvision_MESSAGE();
  UI_rollout = new solarchvision_UI_rollout();
  WIN3D = new solarchvision_WIN3D();
  WORLD = new solarchvision_WORLD();
  STUDY = new solarchvision_STUDY();

  SOLARCHVISION_draw_frame_icon();

  TIME.date = (286 + TIME.convert2Date(TIME.month, TIME.day)) % 365; // 0 presents March 21, 286 presents Jan.01, 345 presents March.01
  //if (TIME.hour >= 12) TIME.date += 0.5;

  VertexSolar_resize_array();
  GlobalSolar_resize_array();

  Tropo3D.resize_images();

  Earth3D.resize_images();

  Sun3D.load_images();
  Moon3D.load_images();

  WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);

  WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);

  STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);

  SKY2D_graphics = createGraphics(SKY2D_X_View, SKY2D_Y_View, P3D);

  SOLARCHVISION_loadDefaultFontStyle();

  changeCurrentLayerTo(5); // pointing to air temperature variable i.e. on the list of allLayers

  frameRate(24);

  loop();
}

int Last_initializationStep = 1000;
int InitializationStep = 0;

void draw () {

  //println("frameCount:", frameCount);

  WIN3D.processHeldKey();

  if (!draw_initial_frames()) {
    applyRolloutUpdate();

    if (FRAME_record_AUTO) {
      if (STUDY.update) FRAME_record_IMG = true;
      if (WIN3D.update) FRAME_record_IMG = true;
      if (WORLD.update) FRAME_record_IMG = true;
      //if (UI_menuBar.update) FRAME_record_IMG = true;
      //if (UI_toolBar.update) FRAME_record_IMG = true;
      //if (UI_caseBar.update) FRAME_record_IMG = true;
    }

    if (STUDY.include && STUDY.update) STUDY.drawView();
    if (STUDY.record_PDF == true) {
      STUDY.record_PDF = false;
    } else {
      if (WORLD.include && WORLD.update) WORLD.drawView();
      if (WORLD.record_PDF == true) {
        WORLD.record_PDF = false;
      } else {
        draw_WIN3D_layers();
        draw_UI_layers();

        if (FRAME_record_IMG) {
          SOLARCHVISION_RecordFrame();
          FRAME_record_IMG = false;
        }
      }
    }

    //noLoop(); // <<<<<<<<<<<<
  }
}

void keyPressed (KeyEvent e) {

  //println("key: " + key);
  //println("keyCode: " + keyCode);

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == USER_GUI) {
      SOLARCHVISION_X_clicked = -1;
      SOLARCHVISION_Y_clicked = -1;

      if ((UI_menuBar.selected_parent != -1) || (UI_menuBar.selected_child != 0)) {

        UI_menuBar.selected_parent = -1;
        UI_menuBar.selected_child = 0;

        image(pre_screen, 0, SOLARCHVISION_pixel_A);
      }

      if (e.isControlDown()) {
        if (!addNewSelectionToPreviousSelection_isOverridden) {
          addNewSelectionToPreviousSelection_beforeModifierKey = addNewSelectionToPreviousSelection;
          addNewSelectionToPreviousSelection_isOverridden = true;
        }
        addNewSelectionToPreviousSelection = 1;
      } else if (e.isAltDown()) {
        if (!addNewSelectionToPreviousSelection_isOverridden) {
          addNewSelectionToPreviousSelection_beforeModifierKey = addNewSelectionToPreviousSelection;
          addNewSelectionToPreviousSelection_isOverridden = true;
        }
        addNewSelectionToPreviousSelection = -1;
      } else {
        addNewSelectionToPreviousSelection = 0;
      }

      if (typeUserCommand == 0) {

        UI_commandBar.updated();

        if (UI_rollout.isEditingSpinner()) {
          UI_rollout.keyPressed(e);
        } else {
          STUDY.keyPressed(e);
          WORLD.keyPressed(e);
          WIN3D.keyPressed(e);
        }
      }
      else {

        UI_commandBar.revise();

        COMIN_keyPressed(e);
      }

      if ((e.isAltDown() != true) && (e.isControlDown() != true)) {

        if (key != CODED) {
          switch(key) {

            case TAB:
              if ((e.isShiftDown() != true) && !UI_rollout.isEditingSpinner()) {
                typeUserCommand = (typeUserCommand + 1) % 2;
                UI_commandBar.revise();
              }
              break;
          }

          if(key == ESC) {
            key = 0; // Overrides the default ESC key behavior that exits a Processing sketch

            if (SOLARCHVISION_cancelActivePickList()) {
              WORLD.revise();
            }
          }

        }
      }

      if ((STUDY.update) || (WORLD.update) || (WIN3D.update) || (UI_rollout.update)) redraw();
    }
  }
}

void keyReleased () {

  WIN3D.keyReleased();

  if ((key == CODED) && ((keyCode == CONTROL) || (keyCode == ALT))) {
    addNewSelectionToPreviousSelection = addNewSelectionToPreviousSelection_beforeModifierKey;
    addNewSelectionToPreviousSelection_isOverridden = false;
  } else {
    addNewSelectionToPreviousSelection = 0;
  }
}
