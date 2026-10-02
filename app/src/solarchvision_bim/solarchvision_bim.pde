import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.DecimalFormat;
import java.util.Calendar;
import java.util.Arrays;
import java.util.HashSet;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import org.apache.commons.compress.compressors.bzip2.BZip2CompressorInputStream;
import processing.data.IntList;
import processing.pdf.*;

String version = "2026";

String BaseFolder = sketchPath();
String SceneName = "";

float MessageSize = 15.0;
int pixel_A = 24; // menu bar
int pixel_B = 42; // 3D tool bar
int pixel_C = 72; // case bar
int pixel_D = 72; // command bar

int pixel_H = 100; // just an initial value
int pixel_W = 100; // just an initial value

void settings () {
  // parseArgs() has to run here, not (only) in setup() below, because
  // the size()/fullScreen() decision right after it depends on `control`
  // and - unlike fullScreen(), which this sketch has always called from
  // setup() without issue - a literal size() call is only allowed inside
  // settings() in compiled/CLI mode ("When not using the PDE, size() can
  // only be used inside settings()", confirmed by this exact
  // IllegalStateException the first time this was tried from setup()
  // instead). args is a standard sketch field, populated before either
  // settings() or setup() runs, so it's available here just as it was
  // there.
  parseArgs(args);

  // fullScreen() sizes the window to whatever the OS reports as the
  // display resolution - correct for a real interactive user, but not
  // reliable for automated (USER_AUTO) runs: Linux's CI only gets
  // 1920x1080 screenshots because Xvfb is explicitly started with
  // -screen 0 1920x1080x24 (see test/run_integration.sh's own comment on
  // needing a display at all), while GitHub's windows-latest runners
  // default their headless session to 1024x768 with no supported way to
  // change it (a long-standing, still-open upstream limitation - see
  // actions/runner-images#2935). Fixing the size explicitly here, only
  // for USER_AUTO, gets every automated run - on any platform - the same
  // 1920x1080 canvas regardless of what the OS itself reports, without
  // changing fullScreen()'s real-user behavior at all.
  if (control == USER_AUTO) {
    size(1920, 1080, P2D);
  } else {
    fullScreen(P2D);
  }
}

void setup () {

  pixel_W = (width - UI_rollout.dX) / 2;
  pixel_H = (height - (pixel_A + pixel_B + pixel_C + pixel_D)) / 2;

  // resize windows
  MESSAGE = new MESSAGE();
  UI_rollout = new UI_rollout();
  WIN3D = new WIN3D();
  WORLD = new WORLD();
  STUDY = new STUDY();

  draw_frame_icon();

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

  loadDefaultFontStyle();

  changeCurrentLayerTo(5); // pointing to air temperature variable i.e. on the list of allLayers

  frameRate(24);

  loop();
}

int Last_initializationStep = 25; // <<< adjust me if draw_initial_frames changed
int InitializationStep = 0;

int stepAfterInitialization = 0;

void draw () {

  //println("frameCount:", frameCount);
  if (frameCount <= 30) {
    // Temporary, scoped to the initialization window only (not forever -
    // this would be excessive noise for a real GUI session running for
    // minutes): draw_initial_frames() only returns false once
    // frameCount > 22 (see its own comment there), each frameCount up to
    // that doing a specific piece of startup work - this shows exactly
    // which one (if any) the sketch actually reaches before whatever is
    // stalling the Windows image-generation job stalls it, rather than
    // only knowing (from this file's other diagnostic prints, which
    // never appeared) that it never got past frame 22 at all.
    println("draw(): frameCount=" + frameCount);
  }

  WIN3D.processHeldKey();
  UI_menuBar.processHeldKey();
  UI_consoleBar.processHeldKey();
  UI_rollout.processHeldKey();

  if (!draw_initial_frames()) {
    if (stepAfterInitialization == 0) {
      // One-time, not per-frame: confirms draw_initial_frames() actually
      // completed at all (if this line never appears in a run's log, the
      // draw loop itself never got past initialization - a rendering-
      // level problem, upstream of anything to do with USER=AUTO/RUN=
      // argument parsing) and shows exactly what loadStrings(RUN=...)
      // in parseArgs.pde actually produced, directly rather than only
      // inferred indirectly (e.g. from the absence of a NullPointerException
      // that a null loadStrings() result would otherwise cause here).
      println("draw(): initialization complete at frameCount=" + frameCount + ", runAfterInitialization.length=" + runAfterInitialization.length);
    }
    if(stepAfterInitialization < runAfterInitialization.length) {
      runScriptLines(runAfterInitialization[stepAfterInitialization]);
    }
    stepAfterInitialization++;

    applyRolloutUpdate();

    if (FRAME_record_AUTO) {
      if (STUDY.update) FRAME_record_IMG = true;
      if (WIN3D.update) FRAME_record_IMG = true;
      if (WORLD.update) FRAME_record_IMG = true;
      //if (UI_menuBar.update) FRAME_record_IMG = true;
      //if (UI_toolBar.update) FRAME_record_IMG = true;
      //if (UI_caseBar.update) FRAME_record_IMG = true;
    }

    if (STUDY.include && STUDY.update) STUDY.draw();
    if (STUDY.record_PDF == true) {
      STUDY.record_PDF = false;
    } else {
      if (WORLD.include && WORLD.update) WORLD.draw();
      if (WORLD.record_PDF == true) {
        WORLD.record_PDF = false;
      } else {
        draw_WIN3D_layers();
        draw_UI_layers();

        if (FRAME_record_IMG) {
          RecordFrame();
          FRAME_record_IMG = false;
        }
      }
    }

    if (control == USER_AUTO) {
      if(stepAfterInitialization > runAfterInitialization.length) {
        // One-time: confirms the normal USER_AUTO exit path was actually
        // reached (as opposed to the process being torn down some other
        // way - a CI timeout, a crash, etc.)
        println("draw(): USER_AUTO exiting at frameCount=" + frameCount + ", stepAfterInitialization=" + stepAfterInitialization);
        exit();
      }
    }

    //noLoop(); // <<<<<<<<<<<<
  }
}

void keyPressed (KeyEvent e) {

  //println("key: " + key);
  //println("keyCode: " + keyCode);

  if (frameCount > Last_initializationStep) {

    if (control == USER_GUI) {
      X_clicked = -1;
      Y_clicked = -1;

      // Arrow keys and Enter drive the open menu and must not reach other elements
      if (UI_menuBar.keyPressed(e)) {
        redraw();
        return;
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

        UI_consoleBar.updated();

        if (UI_rollout.isEditingSpinner()) {
          UI_rollout.keyPressed(e);
        } else {
          STUDY.keyPressed(e);
          WORLD.keyPressed(e);
          WIN3D.keyPressed(e);
        }
      }
      else {

        UI_consoleBar.revise();

        UI_consoleBar.keyPressed(e);
      }

      if ((e.isAltDown() != true) && (e.isControlDown() != true)) {

        if (key != CODED) {
          switch(key) {

            case TAB:
              if ((e.isShiftDown() != true) && !UI_rollout.isEditingSpinner()) {
                typeUserCommand = (typeUserCommand + 1) % 2;
                UI_consoleBar.revise();
              }
              break;
          }

          if(key == ESC) {
            key = 0; // Overrides the default ESC key behavior that exits a Processing sketch

            if (UI_menuBar.selected_parent != -1) {
              UI_menuBar.deselect();
            } else if (typeUserCommand == 1) {
              typeUserCommand = 0;
              UI_consoleBar.revise();
            } else if (cancelActivePickList()) {
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
  UI_menuBar.keyReleased();
  UI_consoleBar.keyReleased();
  UI_rollout.keyReleased();

  if ((key == CODED) && ((keyCode == CONTROL) || (keyCode == ALT))) {
    addNewSelectionToPreviousSelection = addNewSelectionToPreviousSelection_beforeModifierKey;
    addNewSelectionToPreviousSelection_isOverridden = false;
  } else {
    addNewSelectionToPreviousSelection = 0;
  }
}
