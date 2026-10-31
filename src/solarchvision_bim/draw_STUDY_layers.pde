// One day index's own on-screen rectangle (already-converted real screen
// pixel coordinates, two opposite corners) - see STUDY.pde's own
// recordDayHighlightCandidate() for how these get built, and
// dayHighlightCandidates' own comment there for when the list holding
// them gets reset.
class StudyDayHighlightCandidate {
  int dayIndex;
  float x1, y1, x2, y2;
}

// Whether draw_STUDY_layers() itself drew a highlight rectangle last
// frame - separate from hover's own studyHover_wasShownLastFrame
// (hoverOnStudyImpact.pde), which only tracks hover BOXES. Needed because
// a frame with no hover box at all (mouse over WIN3D/WORLD, nothing
// pinned on STUDY) would otherwise never trigger studyHover_pre_screen's
// own restore - leaving a highlight from a now-stale impactDisplayDay
// stuck on screen forever, the exact bug report this file exists to fix.
boolean studyLayers_wasShownLastFrame = false;

// Draws impactDisplayDay's own highlight rectangle live, every frame,
// straight onto the screen - mirrors draw_WIN3D_layers.pde's own pattern
// for exactly the same underlying reason: STUDY.draw() only actually
// re-renders STUDY.graphics (the cached buffer, blitted to screen in
// endFrame()) when STUDY.update is set, since a full render replots every
// data point in the active graph(s) and is comparatively expensive - but
// impactDisplayDay ("Next/Previous Impact Day", actions.pde, and the
// matching case-bar buttons, UI_caseBar.pde) changes WITHOUT ever setting
// STUDY.update (deliberately: stepping through days is meant to feel
// instant, not trigger a full graph replot every click). A highlight
// drawn directly into STUDY.graphics would only ever show whichever day
// was selected the last time STUDY happened to re-render for some other
// reason - stale the rest of the time, exactly the bug report this file
// originally existed to fix.
//
// Instead, STUDY's own real render pass (drawDailyGrid()/plotHourly(),
// STUDY.pde) cheaply records every day index's own on-screen rectangle,
// for every panel it draws, into STUDY.dayHighlightCandidates - geometry
// only, no data lookups, so recording every day costs nothing extra
// worth skipping. This function then just filters that already-computed
// list by whichever day impactDisplayDay currently points to, every
// single frame, and strokes it directly - cheap enough to run on every
// frame regardless of whether STUDY itself rendered that frame.
//
// Drawing straight onto the screen has its own cost, though: since this
// paints outside STUDY's own cached buffer, the rectangle from a
// PREVIOUS frame (a now-stale day, after impactDisplayDay moved on)
// never gets erased on its own - nothing else repaints that screen
// region unless STUDY itself redraws. clearStudyHover() (hoverOnStudy
// Impact.pde) already solves exactly this "sticky pixels" problem for
// hover boxes over this same STUDY region, using a captured clean-screen
// snapshot (studyHover_pre_screen) it refreshes right after every real
// STUDY render and restores (erasing anything drawn on top since) every
// other frame. Calling it here, first, reuses that exact same snapshot
// as this function's own clean baseline too - rather than capturing a
// second, independent one of its own, which would race with hover's:
// whichever of the two captured second would permanently bake the
// other's just-drawn content into its own "clean" reference, corrupting
// every later restore. drawAllHovers() (hover.pde) calls clearStudyHover()
// again moments later this same frame regardless - safe, since by then
// STUDY.renderGeneration already matches what this call just recorded,
// making that second call a no-op.
//
// Called from solarchvision_bim.pde's own main draw loop, inside the same
// "!isBakingInProgress()" block draw_WIN3D_layers()/drawAllHovers() are,
// and before drawAllHovers() specifically - so the restore above (if a
// fresh capture is needed) happens before this function's own highlight
// is drawn, and that highlight itself ends up under the actual hover
// boxes drawAllHovers() draws afterward - below the hover layer, never on
// top of it, matching the original request.
void draw_STUDY_layers () {
  if (isBakingInProgress()) return;
  if (!STUDY.include) return;
  if (UI_menuBar.selected_parent != -1) return;

  clearStudyHover();

  if (STUDY.dayHighlightCandidates == null) return; // STUDY hasn't rendered even once yet

  // This function's own erase-before-redraw step, using that same shared
  // baseline - see this function's own header comment for why
  // clearStudyHover()'s own restore above isn't enough on its own.
  if (studyLayers_wasShownLastFrame && (studyHover_pre_screen != null)) {
    image(studyHover_pre_screen, STUDY.cX, STUDY.cY);
    studyLayers_wasShownLastFrame = false;
  }

  int j = impactDisplayDay - 1; // globals.pde's own "0:total 1:day-1 2:day-2 etc."
  if (j < 0) return; // "total" - the whole graph already is the range, nothing to single out

  boolean drewSomething = false;

  for (StudyDayHighlightCandidate c : STUDY.dayHighlightCandidates) {
    if (c.dayIndex != j) continue;

    pushStyle();
    rectMode(CORNERS);
    noFill();
    stroke(255, 127, 0); // same "currently selected" orange UI_caseBar's own highlighted buttons use
    strokeWeight(STUDY.strokeScale * 3);
    rect(c.x1, c.y1, c.x2, c.y2);
    popStyle();

    drewSomething = true;
  }

  studyLayers_wasShownLastFrame = drewSomething;
}
