// Shared OnChange follow-up callbacks: the work a field needs done
// beyond a plain revise() when its value actually changes (see
// applyRolloutUpdate.pde for the equivalent logic this used to run once
// per frame via a before/after diff). Declared as fields, once, here -
// rather than on UI_rollout - so the exact same callback object can be
// reused from anywhere that isn't UI_rollout itself: passed straight into
// the interactive this.Spinner(...) call in UI_rollout.draw() so it fires
// immediately on a GUI-driven change, from registerSpinnerActions() for a
// command-line-driven change, and from applyRolloutUpdate.pde's diff
// blocks for any other way the field could change (e.g. loading a saved
// project). Assigning a lambda here only builds the callback object; the
// body itself only runs later, once something actually invokes it, so
// it's safe even though other globals (TIME, WORLD, etc.) aren't fully
// set up yet at the point this react instance itself is constructed.
class react {

  OnChange applyTimeChange = (o, n) -> {
    TIME.beginDay = TIME.convert2Date(TIME.month, TIME.day);
    TIME.hour = int(24 * (TIME.date - int(TIME.date)));
    TIME.date = (TIME.hour / 24.0) + (286 + TIME.convert2Date(TIME.month, TIME.day)) % 365;
    println("DATE:", TIME.date, "\tHOUR:", TIME.hour);
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  };

  // GUI-driven change: LocationLAT/LocationLON already hold the new
  // value by the time this fires (applyRolloutUpdate.pde's diff runs
  // after UI_rollout.draw() has applied the spinner's return value), so
  // push them into STATION and let update_station(0) do the same full
  // refresh SETLAT/SETLON do on the command-line path - it already
  // includes WORLD.FindGoodViewport(...) and WORLD.revise().
  OnChange applyLocationChange = (o, n) -> {
    STATION.setLatitude(LocationLAT);
    STATION.setLongitude(LocationLON);
    update_station(0);
  };

  OnChange viewChangedOnly = (o, n) -> { if (o == n) return; view_changed(); };
  OnChange caseBarOnly = (o, n) -> { if (o == n) return; UI_caseBar.revise(); };
  OnChange recalcImpact = (o, n) -> { if (o == n) return; allSolidImpacts.calculate_Impact_selectedSections(); view_changed(); };
  OnChange selectionChangedOnly = (o, n) -> { if (o == n) return; selection_changed(); };
  OnChange softSelectionChanged = (o, n) -> { if (o == n) return; Select3D.convert_Vertex_to_softSelection(); };
  OnChange impactsUpdateFlag = (o, n) -> { if (o == n) return; STUDY.Impacts_update = true; UI_caseBar.updated(); };

  // Move/Rotate/Scale-by-delta spinners: applyRolloutUpdate.pde applies the
  // *difference* between the old and new spinner reading as a transform on
  // the current selection, rather than treating the field as a plain
  // setting - replicated here using the old/new values OnChange gets.
  // The o == n guard matters here beyond just skipping redundant work: with
  // no change, d/r/s below would be 0/0/1 (a genuine no-op), but calling
  // model_changed() unconditionally every frame would still force a
  // constant, needless redraw.
  OnChange applyPosValue = (o, n) -> {
    if (o == n) return;
    float d = n - o;
    float dx = d, dy = d, dz = d;
    int the_Vector = Select3D.posVector;
    if (the_Vector == 0) { dy = 0; dz = 0; }
    if (the_Vector == 1) { dz = 0; dx = 0; }
    if (the_Vector == 2) { dx = 0; dy = 0; }
    Move3D.selection(dx, dy, dz);
    model_changed();
  };
  OnChange applyRotValue = (o, n) -> {
    if (o == n) return;
    float[] P = Select3D.getPivot();
    float r = n - o;
    Rotate3D.selection(P[0], P[1], P[2], r, Select3D.rotVector);
    model_changed();
  };
  OnChange applyScaleValue = (o, n) -> {
    if (o == n) return;
    float[] P = Select3D.getPivot();
    float s = pow(2.0, n - o);
    float sx = s, sy = s, sz = s;
    int the_Vector = Select3D.scaleVector;
    if (the_Vector == 0) { sy = 1; sz = 1; }
    if (the_Vector == 1) { sz = 1; sx = 1; }
    if (the_Vector == 2) { sx = 1; sy = 1; }
    Scale3D.selection(P[0], P[1], P[2], sx, sy, sz);
    model_changed();
  };

  // One-off follow-up callbacks (each used by exactly one spinner).
  OnChange applyStudyJEnd = (o, n) -> {
    if (o == n) return;
    UI_caseBar.revise();
    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;
    allSolarImpacts.rebuild_Image_array = true;
    allWindRoses.rebuild_Image_array = true;
    allSections.resize_solarImpact_array();
  };
  // TIME.updateDate() derives month/day/hour from date (the inverse of
  // applyTimeChange, which derives date from month/day). The original
  // applyRolloutUpDate.pde relied on this cascading into month/day/hour
  // changing and being picked up by a second, separate diff check later in
  // the same frame to reload the ensemble forecast; made explicit here
  // instead of relying on that ordering. Its call site in
  // applyRolloutUpdate.pde keeps its own if-wrapper (rather than an o == n
  // guard here) because it also needs an immediate UI_rollout.draw() -
  // unsafe to fold into a callback that may itself run from inside
  // Spinner(), which draw() is already in the middle of calling.
  OnChange applyTimeDate = (o, n) -> {
    TIME.updateDate();
    update_ENSEMBLE_FORECAST(TIME.year, TIME.month, TIME.day, TIME.hour);
  };
  OnChange applyLandLoadTextures = (o, n) -> { if (o == n) return; Land3D.update_textures(); model_changed(); };
  OnChange applyLandLoadMesh = (o, n) -> { if (o == n) return; Land3D.update_mesh(); model_changed(); };
  OnChange applyCurrentCamera = (o, n) -> {
    if (o == n) return;
    WIN3D.apply_currentCamera();
    modify_Viewport_Title();
    view_changed();
  };
  OnChange applyCreatePowAll = (o, n) -> {
    if (o == n) return;
    User3D.create_powX = User3D.create_powAll;
    User3D.create_powY = User3D.create_powAll;
    User3D.create_powZ = User3D.create_powAll;
    UI_rollout.revise();
  };
}
