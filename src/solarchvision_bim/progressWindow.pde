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

class ProgressWindow extends java.awt.Frame {
  volatile float fraction = 0;
  String label;

  ProgressWindow (String label) {
    super(label);
    this.label = label;
    this.setUndecorated(true);
    this.setSize(560, 44); // 2x the original 280 width - same height
    this.setLocationRelativeTo(null); // centers on the default screen
    this.setAlwaysOnTop(true);
    this.setBackground(new java.awt.Color(223, 223, 223));
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
    g.drawString(this.label + ": " + (int) (this.fraction * 100) + "%", 10, h - 16);
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
