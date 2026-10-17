
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
  }

  WORLD.revise();
  WIN3D.revise();
  STUDY.revise();
}
