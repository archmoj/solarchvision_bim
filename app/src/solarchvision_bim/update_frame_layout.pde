
int ViewLayout = 0;

void SOLARCHVISION_update_frame_layout () {
  if (ViewLayout == 0) {

    STUDY.include = true;
    WIN3D.include = true;
    WORLD.include = true;

    WIN3D.cX = SOLARCHVISION_pixel_W;;
    WIN3D.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WIN3D.dX = SOLARCHVISION_pixel_W;
    WIN3D.dY = SOLARCHVISION_pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);

    WORLD.cX = 0;
    WORLD.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WORLD.dX = SOLARCHVISION_pixel_W;
    WORLD.dY = SOLARCHVISION_pixel_H;
    WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);

    STUDY.cX = 0;
    STUDY.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + SOLARCHVISION_pixel_H;
    STUDY.dX = 2 * SOLARCHVISION_pixel_W;
    STUDY.dY = 1 * SOLARCHVISION_pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (ViewLayout == 1) {

    STUDY.include = false;
    WIN3D.include = true;
    WORLD.include = false;

    WIN3D.cX = 0;
    WIN3D.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WIN3D.dX = 2 * SOLARCHVISION_pixel_W;
    WIN3D.dY = 2 * SOLARCHVISION_pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);
  } else if (ViewLayout == 2) {

    STUDY.include = true;
    WIN3D.include = false;
    WORLD.include = false;

    STUDY.cX = 0;
    STUDY.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    STUDY.dX = 2 * SOLARCHVISION_pixel_W;
    STUDY.dY = 2 * SOLARCHVISION_pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (ViewLayout == 3) {

    STUDY.include = false;
    WIN3D.include = false;
    WORLD.include = true;

    WORLD.cX = 0;
    WORLD.cY = SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 0;
    WORLD.dX = 2 * SOLARCHVISION_pixel_W;
    WORLD.dY = 2 * SOLARCHVISION_pixel_H;
    WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);
  }

  WORLD.revise();
  WIN3D.revise();
  STUDY.revise();
}
