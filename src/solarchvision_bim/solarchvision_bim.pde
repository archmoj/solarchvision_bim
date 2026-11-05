import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.UnsupportedFlavorException;
import java.io.InputStreamReader;
import java.io.BufferedReader;
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

String BaseFolder;
String SceneName = "";

String version = "2027";

void settings () {
  locateBaseFolder();

  parseArgs(args);

  if (screenWidth > 0 && screenHeight > 0) { // set by arg e.g. SCREEN=1280x720
    size(screenWidth, screenHeight, P2D);
  } else if (control == USER_AUTO) { // used in image tests
    size(1920, 1080, P2D);
  } else { // case of USER_GUI without SCREEN arg
    fullScreen(P2D);
  }

  // Since Processing 4.4.3, pixelDensity() defaults to matching the
  // display's own density (2 on a Retina/Windows-HiDPI screen) instead of
  // always 1 - this sketch predates that change and, like most pre-4.4.3
  // code, assumes 1 everywhere: every pixel-array allocation sized off
  // width/height or WIN3D.dX/dY (pixel_W/pixel_H in setup(), shadeBuffer/
  // Shade_RGBA in shadeViewport3D.pde, ...) only comes out correct, and
  // only stays the single consistent size those arrays need to be copied
  // into each other safely, at density 1. Has to go here, after size()/
  // fullScreen() above (whichever branch ran), rather than in setup():
  // this sketch already declares its own settings(), and a pixelDensity()
  // call left inside setup() instead makes Processing's preprocessor
  // synthesize a *second* settings() to hold it - colliding with this one
  // ("Duplicate method settings()") rather than actually running early
  // enough to matter.
  pixelDensity(1);
}

void setup () {
  if(userPointSize > 0) {
    MessageSize = userPointSize * 96 / 72.0;
  } else {
    MessageSize = height / 60.0;
  }

  pixel_A = int(MessageSize * 1.5); // menu bar
  pixel_B = int(MessageSize * 2.25); // 3D tool bar
  pixel_C = int(MessageSize * 4.5); // case bar
  pixel_D = int(MessageSize * 4.5); // command bar

  UI_rollout.dX = calcRolloutWidth();

  pixel_W = (width - UI_rollout.dX) / 2;
  pixel_H = (height - (pixel_A + pixel_B + pixel_C + pixel_D)) / 2;

  // resize windows
  MESSAGE = new MESSAGE();
  UI_rollout = new UI_rollout();
  UI_menuBar = new UI_menuBar();
  UI_toolBar = new UI_toolBar();
  UI_caseBar = new UI_caseBar();
  UI_consoleBar = new UI_consoleBar();
  WIN3D = new WIN3D();
  WORLD = new WORLD();
  STUDY = new STUDY();

  update_input_folders();

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

  loadCurrentFontStyle();

  changeCurrentLayerTo(5); // pointing to air temperature variable i.e. on the list of allLayers

  frameRate(24);

  loop();
}

int Last_initializationStep = 25; // <<< adjust me if draw_initial_frames changed
int InitializationStep = 0;

int stepAfterInitialization = 0;

void draw () {
  if (isBakingInProgress()) return;

  WIN3D.processHeldKey();
  UI_menuBar.processHeldKey();
  UI_consoleBar.processHeldKey();
  UI_rollout.processHeldKey();

  if (!draw_initial_frames()) {
    // Captured before draining: distinguishes "ran something this frame"
    // from "there was already nothing left to do", which the USER_AUTO
    // exit check below needs (pendingScriptLines is itself empty either
    // way by the time this line finishes).
    boolean hadPendingScriptLines = !pendingScriptLines.isEmpty();
    runPendingScriptLines();
    stepAfterInitialization++;

    // Viewport3D's own undo/redo recording - polled once per frame
    // rather than hooked to a begin/end pair; see undoRedoViewport3D.pde's
    // own header comment for why. Run after runPendingScriptLines()
    // (which is how held-drag/scroll camera moves actually reach WIN3D,
    // via mouseDragged.pde/mouseWheel.pde's own +PanView/+TurnView/...
    // script lines) so this frame's change, if any, is already live on
    // WIN3D by the time it's checked.
    trackViewport3DChange();

    applyRolloutUpdate();

    // STATION's own undo/redo recording - same once-per-frame polling,
    // same reasoning; see undoRedoStation.pde's own header comment.
    // Placed after, not alongside, trackViewport3DChange() above:
    // STATION's own GUI spinner-drag path (react.pde's own
    // applyLocationChange, "Location Latitude"/"Location Longitude")
    // only actually reaches STATION from inside applyRolloutUpdate()
    // itself, unlike WIN3D's own camera moves - so this frame's change,
    // if any, from either that path or runPendingScriptLines()'s own
    // SETLAT/SETLON/... commands further up, is already live on STATION
    // by the time it's checked here.
    trackStationChange();

    // Viewport2D's (STUDY's) own undo/redo recording - same once-per-
    // frame polling, same reasoning, same placement as
    // trackStationChange() just above; see undoRedoViewport2D.pde's own
    // header comment. STUDY's own GUI spinner-drag path (uiRollout.pde's
    // own `STUDY.endDay = vm.endDay(1);` and its many siblings) only
    // actually reaches STUDY from inside applyRolloutUpdate() itself,
    // so this frame's change, if any, is already live on STUDY by the
    // time it's checked here. Reads STUDY only (STUDY.to_XML()) - it
    // doesn't touch the rebuild flags regenerate_desired_bakings() below
    // reads, so it's safe to run before that call despite this
    // comment's own ordering concern, which is about STUDY.draw()
    // itself, not about reading STUDY's own current field values.
    trackViewport2DChange();

    // Must run before STUDY.draw(): STUDY's own plotImpact_global() calls
    // GlobalSolar_resize_array() whenever GlobalSolar_rebuild_array is set
    // (just to keep the array's dimensions right for plotting), and that
    // resize clears the array back to FLOAT_undefined and resets the flag
    // to false as a side effect - exactly the same flag
    // regenerate_desired_bakings() below checks. If STUDY.draw() ran
    // first, it would consume the flag with a blank array, and
    // draw_WIN3D_layers() further down would then find the flag already
    // false and skip the real recalculation, leaving the 3D view's Global
    // Solar shading empty until something (e.g. "Recalculate Solar
    // Impact") re-flagged it. Vertex Solar has no equivalent earlier
    // consumer, so it was never affected by this ordering. Doing the one
    // real regeneration for the frame here, before anything else gets a
    // chance to read (and incidentally clear) the flags, means every
    // consumer downstream - STUDY's graphs and WIN3D's 3D view alike -
    // sees the same, already-fresh data.
    regenerate_desired_bakings();

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
        if (!isBakingInProgress()) {
          draw_WIN3D_layers();
          draw_STUDY_layers();
          drawAllHovers();

          draw_UI_layers();

          if(stepAfterInitialization == 1) {
            UI_consoleBar.drawEmptyDirective();
          }

          if (FRAME_record_IMG) {
            RecordFrame();
            FRAME_record_IMG = false;
          }
        }
      }
    }

    if (control == USER_AUTO) {
      // One frame after pendingScriptLines last had anything in it (not
      // the instant it empties - that's still the same frame whatever
      // was queued is being run): gives that last frame's render/screenshot
      // one full cycle to actually happen before the process exits. If
      // nothing was ever queued (no RUN=<file> given), this is simply the
      // first post-initialization frame.
      if (!hadPendingScriptLines) {
        // One-time: confirms the normal USER_AUTO exit path was actually
        // reached (as opposed to the process being torn down some other
        // way - a CI timeout, a crash, etc.)
        println();
        println("draw(): USER_AUTO exiting at frameCount=" + frameCount + ", stepAfterInitialization=" + stepAfterInitialization);
        exit();
      }
    }

    //noLoop(); // <<<<<<<<<<<<
  }
}

void keyPressed (KeyEvent e) {
  if (isBakingInProgress()) return;

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

      boolean wasEditingSpinner = UI_rollout.isEditingSpinner();

      // Global Undo/Redo - Ctrl+Z / Ctrl+Y for the model (Scene3D),
      // Ctrl+Shift+Z / Ctrl+Shift+Y for the camera/view (Viewport3D) -
      // two independent histories, see undoRedoViewport3D.pde's own
      // header comment for why they never overlap. Checked here, before
      // the typeUserCommand/wasEditingSpinner dispatch below, so it only
      // ever fires while the person isn't actively typing a console
      // command or editing a spinner's value (same context
      // STUDY/WORLD/WIN3D.keyPressed() get called in just below), and so
      // it works regardless of which viewport or tool is active - rather
      // than being one more case inside WIN3D.keyPressed()'s own Ctrl-key
      // guard there, which is deliberately narrow (only Ctrl+,/Ctrl+.)
      // and scoped to viewport navigation, not a fit for something meant
      // to work everywhere. Routed through callAction(), same as every
      // other keyboard-triggered command in this file, so Undo/Redo are
      // also reachable from the command line
      if (!wasEditingSpinner && (typeUserCommand == 0) &&
          e.isControlDown() && !e.isAltDown()) {
        if (e.getKeyCode() == 90) { // 90 = Z
          if (e.isShiftDown()) {
            callAction("Undo Viewport3D Change");
          } else {
            callAction("Undo Scene3D Change");
          }
          redraw();
          return;
        }

        if (e.getKeyCode() == 89) { // 89 = Y
          if (e.isShiftDown()) {
            callAction("Redo Viewport3D Change");
          } else {
            callAction("Redo Scene3D Change");
          }
          redraw();
          return;
        }
      }

      // Whether THIS keypress is the one that's about to reach
      // UI_rollout.keyPressed(e) below AND is an Esc - i.e. whether an Esc
      // is about to cancel an in-progress spinner edit there (uiRollout.pde's
      // own "case ESC": drops the typed text, sets editActive false, leaves
      // the spinner's real value untouched). Captured BEFORE that call runs,
      // specifically because isEditingSpinner() checked AFTER it would
      // always read "not editing" - cancelling IS what sets editActive
      // false, as part of handling this exact keypress - so checking it
      // fresh further down could never tell "Esc just cancelled a spinner
      // edit" apart from "Esc arrived with nothing active" (the whole point
      // of this flag). Used below to stop that one Esc there, rather than
      // (as `wasEditingSpinner` alone would, mishandling the admittedly
      // unreachable-today case of a spinner edit somehow still active while
      // typeUserCommand==1) blocking every later Esc cascade a spinner
      // merely happens to still be active for.
      boolean escAboutToCancelSpinnerEdit = wasEditingSpinner && (typeUserCommand == 0) && (key == ESC);

      if (typeUserCommand == 0) {

        UI_consoleBar.updated();

        if (wasEditingSpinner) {
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

            // An Esc that just cancelled a spinner edit (escAboutToCancelSpinnerEdit,
            // above) already did its one job up there - UI_rollout.keyPressed(e)
            // dropped the typed text and left the spinner's real value
            // untouched - and must stop there. Without this check, every Esc
            // keypress still falls all the way through this same cascade
            // regardless of what it already did above, so cancelling a spinner
            // edit would ALSO close an open menu, dismiss a pick list, or (what
            // was actually being seen) silently remove a pinned STUDY/WIN3D
            // hover point the person never asked to touch - none of which "stop
            // typing in this box" should ever imply.
            if (escAboutToCancelSpinnerEdit) {
              // handled above - nothing else should happen for this Esc
            } else if (UI_menuBar.selected_parent != -1) {
              UI_menuBar.deselect();
            } else if (typeUserCommand == 1) {
              typeUserCommand = 0;
              UI_consoleBar.revise();
            } else if (cancelActivePickList()) {
              WORLD.revise();
            } else if (dismissShading()) {
              // shadeViewport3D.pde's own dismissShading() - checked (and,
              // same as escAboutToCancelSpinnerEdit above, stops this
              // cascade right here) before removeLastHoverPoint() below,
              // so an Esc that was actually meant to end the sticky
              // shaded-viewport preview (see WIN3D.showShading's own
              // comment) can never also silently remove a pinned hover
              // point underneath it. dismissShading() already forces its
              // own repaint (view_changed()) - nothing else to do here.
            } else if (removeLastHoverPoint()) {
              redraw();
            }
          }

        }
      }

      if ((STUDY.update) || (WORLD.update) || (WIN3D.update) || (UI_rollout.update)) redraw();
    }
  }
}

void keyReleased () {
  if (isBakingInProgress()) return;

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
