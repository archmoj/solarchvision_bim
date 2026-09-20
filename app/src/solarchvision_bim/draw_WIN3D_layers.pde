void draw_WIN3D_layers () {
  if (!WIN3D.include) return;

  if (WIN3D.update) {

    SOLARCHVISION_regenerate_desired_bakings();

    WIN3D.drawView();
  }

  if (WIN3D.showShading) {
    WIN3D.showShading = false;
    image(Shade_RGBA, WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY);
  }

  if (WIN3D.showSolarImpact) {
    WIN3D.showSolarImpact = false;

    if(IMPACTS_displayDay < allSolarImpacts.Image[STUDY.Impact_TYPE].length) {
      PImage img = allSolarImpacts.Image[STUDY.Impact_TYPE][IMPACTS_displayDay];
      float w = img.width;
      float h = img.height;
      float aspect1 = 1.0f * w / h;
      float aspect2 = 1.0f * WIN3D.dX / WIN3D.dY;
      float r = aspect2 / aspect1;

      if(r == 1) {
        image(img, WIN3D.cX, WIN3D.cY, WIN3D.dX, WIN3D.dY);
      }
      else if(r > 1) {
        float newWidth = aspect1 * WIN3D.dY;
        image(img,
          WIN3D.cX + (WIN3D.dX - newWidth) / 2,
          WIN3D.cY,
          newWidth,
          WIN3D.dY
        );
      } else { // case of r < 1
        float extraWidth = aspect1 * WIN3D.dY;
        float deltaRatio = (extraWidth - WIN3D.dX) / WIN3D.dX;
        image(img.get(
            (int) (w * deltaRatio / 2),
            (int) 0,
            (int) (w - w * deltaRatio),
            (int) h
          ),
          WIN3D.cX,
          WIN3D.cY,
          WIN3D.dX,
          WIN3D.dY
        );
      }
    }
  }
}