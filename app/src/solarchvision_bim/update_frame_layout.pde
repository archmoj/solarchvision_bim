
int ViewLayout = 0;

void update_frame_layout () {
  if (ViewLayout == 0) {

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
  } else if (ViewLayout == 1) {

    STUDY.include = false;
    WIN3D.include = true;
    WORLD.include = false;

    WIN3D.cX = 0;
    WIN3D.cY = pixel_A + pixel_B + 0;
    WIN3D.dX = 2 * pixel_W;
    WIN3D.dY = 2 * pixel_H;
    WIN3D.view_R = float(WIN3D.dY) / float(WIN3D.dX);
    WIN3D.graphics = createGraphics(WIN3D.dX, WIN3D.dY, P3D);
  } else if (ViewLayout == 2) {

    STUDY.include = true;
    WIN3D.include = false;
    WORLD.include = false;

    STUDY.cX = 0;
    STUDY.cY = pixel_A + pixel_B + 0;
    STUDY.dX = 2 * pixel_W;
    STUDY.dY = 2 * pixel_H;
    STUDY.view_R = float(STUDY.dY) / float(STUDY.dX);
    STUDY.graphics = createGraphics(STUDY.dX, STUDY.dY, P2D);
  } else if (ViewLayout == 3) {

    STUDY.include = false;
    WIN3D.include = false;
    WORLD.include = true;

    WORLD.cX = 0;
    WORLD.cY = pixel_A + pixel_B + 0;
    WORLD.dX = 2 * pixel_W;
    WORLD.dY = 2 * pixel_H;
    WORLD.graphics = createGraphics(WORLD.dX, WORLD.dY, P2D);
  }

  WORLD.revise();
  WIN3D.revise();
  STUDY.revise();
}
