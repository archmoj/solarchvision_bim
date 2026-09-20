String Default_Font = "Liberation Sans";

PFont SOLARCHVISION_font;

void SOLARCHVISION_loadDefaultFontStyle () {

  println("Loading font:", Default_Font);

  SOLARCHVISION_font = createFont(Default_Font, 36, true);

  SOLARCHVISION_ResetFontStyle();
}

void SOLARCHVISION_ResetFontStyle () {

  textFont(SOLARCHVISION_font);
  WORLD.graphics.textFont(SOLARCHVISION_font);
  WIN3D.graphics.textFont(SOLARCHVISION_font);
  STUDY.graphics.textFont(SOLARCHVISION_font);
}
