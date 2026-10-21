
int viewLayout = 0;

void update_frame_layout () {
  if (viewLayout == 0) {

    STUDY.include = true;
    WIN3D.include = true;
    WORLD.include = true;

    WIN3D.cX = pixel_W;;
    WIN3D.cY = pixel_A + pixel_B + 0;
    WIN3D.dX = pixel_W;
    WIN3D.dY = pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);

    WORLD.cX = 0;
    WORLD.cY = pixel_A + pixel_B + 0;
    WORLD.dX = pixel_W;
    WORLD.dY = pixel_H;
    WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);

    STUDY.cX = 0;
    STUDY.cY = pixel_A + pixel_B + pixel_H;
    STUDY.dX = 2 * pixel_W;
    STUDY.dY = 1 * pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (viewLayout == 1) {

    STUDY.include = false;
    WIN3D.include = true;
    WORLD.include = false;

    WIN3D.cX = 0;
    WIN3D.cY = pixel_A + pixel_B + 0;
    WIN3D.dX = 2 * pixel_W;
    WIN3D.dY = 2 * pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);
  } else if (viewLayout == 2) {

    STUDY.include = true;
    WIN3D.include = false;
    WORLD.include = false;

    STUDY.cX = 0;
    STUDY.cY = pixel_A + pixel_B + 0;
    STUDY.dX = 2 * pixel_W;
    STUDY.dY = 2 * pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (viewLayout == 3) {

    STUDY.include = false;
    WIN3D.include = false;
    WORLD.include = true;

    WORLD.cX = 0;
    WORLD.cY = pixel_A + pixel_B + 0;
    WORLD.dX = 2 * pixel_W;
    WORLD.dY = 2 * pixel_H;
    WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);
  }

  if(WIN3D.include) {
    model_changed(); // to update 3D caches (Faces, Model1Ds, Terrain)

    // WIN3D.graphics was just recreated above via createGraphics() - any
    // win3DCache PShape built against the old graphics context must be
    // rebuilt against the new one too, same reasoning as the Faces/
    // Model1Ds/Terrain caches invalidated by model_changed() just above.
    // Sky3D already uses a winCacheGeneration counter like those three (see
    // Sky3D.pde / calculate_GlobalSolar_array.pde), so bump it the same
    // way; Sun3D/Moon3D/Earth3D have no such counter - their
    // win3DCache_isValid() just checks win3DCache != null (see their own
    // "WIN3D retained-mode cache" blocks), so null the cache out directly.
    if (Sky3D != null) Sky3D.winCacheGeneration++;
    if (Sun3D != null) Sun3D.win3DCache = null;
    if (Moon3D != null) Moon3D.win3DCache = null;
    if (Earth3D != null) Earth3D.win3DCache = null;

    // Sun3D keeps a SECOND, separate WIN3D cache besides win3DCache above
    // - win3DCache_gridSegments, built by drawGrid() for the sun-path
    // grid lines. Its own win3DCache_gridIsValid() bakes WIN3D.scale into
    // the cached segment coordinates (see drawGridSegment()) but never
    // checks WIN3D.scale itself, so - unlike win3DCache above - nulling
    // win3DCache doesn't also cover this one. Null it the same way, or
    // the grid keeps replaying at the old viewport's scale after a
    // resize.
    if (Sun3D != null) Sun3D.win3DCache_gridSegments = null;

    // Sun3D keeps a THIRD and FOURTH WIN3D cache too - win3DCache_pathSegments
    // and win3DCache_pattern (drawPath()/drawPattern(), via drawCycles()):
    // both bake WIN3D.scale into their cached positions, and
    // win3DCache_pathSegments also bakes WIN3D.dY directly into each
    // segment's stroke weight (0.01 * WIN3D.dY - see drawPath()'s own
    // comment on that entry's layout). Neither is covered by nulling
    // win3DCache/win3DCache_gridSegments above. Unlike those two, these
    // caches already key off a generation counter for exactly this kind
    // of "everything not cheaply enumerable" case (see winCache_
    // dataGeneration's own comment) - bumping it here invalidates both at
    // once, no separate null-out needed. Without this, "Enlarge 3D
    // Viewport" leaves the sun path/pattern rendering at the old
    // viewport's scale (narrower segments, wrong stroke weight) until
    // something unrelated happens to call UI_caseBar.revise() and bump
    // this same counter as a side effect - which is what made the bug
    // look like it "fixes itself" a frame or two later instead of never.
    if (Sun3D != null) Sun3D.winCache_dataGeneration++;

    // See win3DOverlay_resyncGenerationAfterResize()'s own comment: the
    // model_changed() call just above was for the new WIN3D.graphics
    // context, not an actual geometry edit, so don't let it falsely hide
    // the solar-impact overlay.
    allSolarImpacts.win3DOverlay_resyncGenerationAfterResize();
  }

  WORLD.revise();
  WIN3D.revise();
  STUDY.revise();
}
