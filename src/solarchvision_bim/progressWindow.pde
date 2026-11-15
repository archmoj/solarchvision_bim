// A small borderless native AWT window showing the progress of a long,
// synchronous computation (preBakeViewport() (preBakeViewport3D.pde);
// calculateVertexSolarArray.pde, the "Skin Potential" graph's own - see that
// file's own comment, since clicking "Skin Potential" itself (uiRollout.
// pde's render button, setimpactGraphIndex()) doesn't recompute
// anything, the underlying per-face data does; and every "Download .../
// Load ..." network action across the codebase, each driven by its own
// show*DownloadProgress/showImportProgress flag, globalVariables.pde) -
// NOT drawn through Processing's own P2D/JOGL-backed canvas at all. An
// earlier version tried drawing straight onto that canvas and forcing a
// mid-frame present via g.endDraw()/g.beginDraw() - it never actually
// appeared, which lines up with how this sketch's own renderer (P2D,
// solarchvision_bim.pde's own settings()) really presents frames: JOGL/
// NEWT's own animator thread drives the buffer swap on its own cycle,
// not simply whenever endDraw() happens to be called, so calling it
// manually mid an already-open frame didn't trigger one.
//
// AWT is a completely separate windowing toolkit from JOGL/NEWT, with
// its own event-dispatch thread, already running in this same JVM
// process regardless (java.awt.Toolkit/Clipboard are already imported,
// solarchvision_bim.pde's own imports) - a plain AWT Frame updates and
// actually appears on screen the moment repaint() is called, independent
// of whatever Processing's own thread is doing or blocked on. This is
// the standard, portable Java technique for showing progress during a
// long synchronous call, rather than something specific to this
// renderer - but it's still worth confirming directly once built, same
// as the earlier attempt should have been before being taken on faith.
//
// Floats free on screen rather than pinned to any particular Processing
// UI element (uiRollout.pde's own SOLARCHVISION current viewport button, say) - a
// separate OS window has no reliable way to know any Processing-drawn
// element's exact on-screen position (especially relative to Processing's
// own window, which this doesn't query), so centering on the default
// screen is the simplest, most robustly correct placement for either
// caller; move it if a more precise position turns out to matter once
// this is confirmed working.
// Whether a ProgressWindow (below) can actually be created here, on top
// of whichever show*Progress flag (globals.pde) a given caller checks -
// java.awt.GraphicsEnvironment.isHeadless() is the standard, reliable
// Java check for "is there an actual display to put a window on", NOT
// control != USER_AUTO (the existing console-bar guard throughout this
// codebase, e.g. calculateVertexSolarArray.pde's own) - that one only
// distinguishes interactive-GUI output from automated/batch output
// (control defaults to USER_GUI, not USER_AUTO, so it's true by default
// in a plain test app too), it was never meant to detect whether a
// display actually exists, and the two aren't reliably the same thing:
// a batch/USER_AUTO run can still have a real display, same as the many
// existing unit tests that call import_objects_OBJ()/import_objects_IFC()
// directly (confirmed, not assumed) do NOT have one at all - without
// this check, every one of those would have thrown
// java.awt.HeadlessException the moment this feature's own window tried
// to construct, something a console print() never risked.
boolean canShowProgressWindow () {
  return !java.awt.GraphicsEnvironment.isHeadless();
}

// U+2588 FULL BLOCK - the one character every console progress bar in
// this codebase draws with (the console text bar every "Download .../
// Load ..." action and importer prints, NOT the ProgressWindow above,
// which paints its own fill rect and needs no character at all).
// Centralized here, alongside the rest of the shared progress-bar
// helpers, so every call site reads PROGRESS_BAR_CHAR instead of
// repeating the literal - one edit, not a grep-and-replace across every
// download/import file, if it ever turns out to render as a '?' or a
// tofu box on some console/font combination instead of a solid block.
final char PROGRESS_BAR_CHAR = '█';

// Prints `count` more PROGRESS_BAR_CHAR characters, as one print() call
// instead of `count` separate ones - the exact throttle-and-print shape
// every caller above already built by hand, both for its own delta >= 1
// throttled steps and for its own final "flush whatever's left" call
// once the loop is done. A fresh StringBuilder each call (rather than one
// kept alive across a whole function, the way a few callers used to) -
// this is only ever called a few dozen times total per action (once per
// whole percentage point, not once per loop iteration), so the extra
// allocation is immaterial next to the network/file/compute work each
// caller is actually timing.
void printProgressBarChunk (int count) {
  StringBuilder barBuffer = new StringBuilder();
  for (int c = 0; c < count; c++) barBuffer.append(PROGRESS_BAR_CHAR);
  print(barBuffer.toString());
}

// Called by an abortable Download .../Load ... action right before it
// break/returns out of its own loop on ProgressWindow.abortRequested -
// one shared place for this message, same reasoning as every other
// helper in this file, rather than each caller printing its own slightly
// different wording.
void echoAbortProgress () {
  println("Aborted by Esc.");
}

// Moved from uiConsoleBar.pde - this is a shared progress-bar helper,
// not part of that file's own UI_consoleBar class or its command-bar
// drawing code.
void progressBarHeader () {
  println("       10%       20%       30%       40%       50%       60%       70%       80%       90%       100%");
  println(".........|.........|.........|.........|.........|.........|.........|.........|.........|.........|");
}

// The one ProgressWindow currently on screen, if any - null the rest of
// the time. Set in setVisible(true), cleared in setVisible(false)/
// dispose() (see those methods' own comments just below). Every
// existing caller only ever has at most one of these alive at once (see
// isInProgress()'s own comment, globalFunctions.pde, on why imports
// aren't reentrant - the same is true of every other show*Progress-
// gated action), so a single plain field is enough - this is NOT a
// stack/list of nested windows.
//
// Exists specifically so solarchvision_bim.pde's own keyPressed() can
// set abortRequested directly on whichever ProgressWindow is currently
// open, the moment it sees an Esc while isInProgress() is true - see
// that method's own comment for why this is the reliable path and
// escListener (below) often isn't: this sketch runs on P2D, which
// Processing drives through JOGL/NEWT, a native windowing layer
// entirely separate from java.awt - a real keystroke to the main
// sketch window (which keeps OS focus throughout, since this class
// never calls requestFocus()) reaches Processing's own keyPressed() via
// NEWT's own event pipeline, but never enters java.awt.Toolkit's event
// queue at all, so escListener below never fires for it. escListener is
// kept anyway (harmless, and still the only path that would work on a
// legacy AWT/JAVA2D renderer, or if an actual AWT/Swing window
// genuinely does have focus), but this field is what actually makes
// Esc work under P2D/NEWT in real, non-synthetic use.
ProgressWindow activeProgressWindow = null;

class ProgressWindow extends java.awt.Frame {
  volatile float fraction = 0;
  volatile boolean abortRequested = false;
  String label;

  // A Toolkit-level AWTEventListener, not a per-component KeyListener -
  // this window calls setFocusableWindowState(false) (below) precisely
  // so it never ends up with real OS keyboard focus in the first place,
  // so a plain KeyListener on it would never receive anything anyway. A
  // Toolkit-level listener sees every key event system-wide regardless
  // of which window currently has focus, so Esc aborts whether the
  // sketch window or this overlay (or neither) happens to have it.
  // Scoped to exactly while THIS window is visible - installed in
  // setVisible(true), removed again in setVisible(false) and dispose()
  // - so it doesn't keep listening, or keep this object reachable, once
  // the action that owns it has finished. Every existing caller's own
  // construct -> setVisible(true) -> ... -> dispose() lifecycle only
  // ever actually hits the dispose() removal, not setVisible(false),
  // but both are handled for whichever one a future caller ends up
  // using.
  java.awt.event.AWTEventListener escListener = null;

  ProgressWindow (String label) {
    super(label);
    this.label = label;
    this.setUndecorated(true);
    this.setSize(560, 44); // 2x the original 280 width - same height
    this.setLocationRelativeTo(null); // centers on the default screen
    this.setAlwaysOnTop(true);

    // Without this, a click on this window (or Alt+Tab reaching it, since
    // it's a real top-level window) can give it genuine OS keyboard
    // focus - and once it has that, real keystrokes go to IT, not to the
    // main sketch's own NEWT window, so Esc stops working via the one
    // path that's actually proven reliable (activeProgressWindow, set
    // from the sketch's own keyPressed() - see that field's own
    // comment). This window has nothing on it that needs a real click
    // anymore (no button, no decorations), so there's no downside left
    // to it never taking focus at all.
    this.setFocusableWindowState(false);

    this.setBackground(new java.awt.Color(223, 223, 223));
    this.setFont(new java.awt.Font(java.awt.Font.SANS_SERIF, java.awt.Font.BOLD, 18)); // was the AWT default (~11-12pt) - bumped up for readability
  }

  void setVisible (boolean show) {
    super.setVisible(show);
    if (show) {
      activeProgressWindow = this; // see that field's own comment for why - the real, reliable abort path under P2D/NEWT
      if (this.escListener == null) {
        this.escListener = (java.awt.AWTEvent e) -> {
          java.awt.event.KeyEvent ke = (java.awt.event.KeyEvent) e;
          if ((ke.getID() == java.awt.event.KeyEvent.KEY_PRESSED) && (ke.getKeyCode() == java.awt.event.KeyEvent.VK_ESCAPE)) {
            this.abortRequested = true;
          }
        };
        java.awt.Toolkit.getDefaultToolkit().addAWTEventListener(this.escListener, java.awt.AWTEvent.KEY_EVENT_MASK);
      }
    } else {
      this.removeEscListener();
      if (activeProgressWindow == this) activeProgressWindow = null;
    }
  }

  void removeEscListener () {
    if (this.escListener != null) {
      java.awt.Toolkit.getDefaultToolkit().removeAWTEventListener(this.escListener);
      this.escListener = null;
    }
  }

  void dispose () {
    this.removeEscListener();
    if (activeProgressWindow == this) activeProgressWindow = null;
    super.dispose();
  }

  void paint (java.awt.Graphics g) {
    int w = this.getWidth();
    int h = this.getHeight();

    g.setColor(new java.awt.Color(191, 191, 191));
    g.fillRect(5, 5, w - 11, h - 11);

    g.setColor(java.awt.Color.BLACK);
    g.drawRect(5, 5, w - 11, h - 11);

    g.setColor(new java.awt.Color(63, 191, 63));
    g.fillRect(6, 6, (int) ((w - 12) * constrain(this.fraction, 0, 1)), h - 12);

    g.setColor(java.awt.Color.WHITE);
    g.setFont(this.getFont());
    g.drawString(this.label + ": " + (int) (this.fraction * 100) + "%", 10, h - 14);
  }

  // Paints synchronously, directly on the calling thread, rather than
  // calling this.repaint() (AWT's normal path) - repaint() only queues a
  // paint event for AWT's own event-dispatch thread to get to whenever it
  // next runs, which is fine when each call here is separated by enough
  // real work (preBakeViewport()'s own ray-casting, calculate_
  // VertexSolar_array()'s own per-face loop) for the EDT to catch up in
  // between, but import_objects_IFC()'s/import_objects_OBJ()'s own per-
  // entity/per-line parsing can be fast enough that the whole import
  // finishes and dispose()s this window before the EDT ever gets a single
  // chance to actually paint anything - an empty window that flashes by,
  // confirmed against a real IFC import, not a hypothetical. Painting
  // directly here - still just as cheap and rare as before (only called
  // from inside each caller's own delta >= 1 throttle, not every single
  // iteration) - guarantees the bar is actually drawn before this method,
  // and whatever loop iteration called it, returns, regardless of how
  // fast the surrounding work is.
  void updateFraction (float f) {
    this.fraction = f;
    java.awt.Graphics g = this.getGraphics();
    if (g != null) {
      this.paint(g);
      g.dispose();
    }
  }
}
