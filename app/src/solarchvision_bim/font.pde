String Default_Font = "Liberation Sans";

PFont font;

void loadDefaultFontStyle () {

  println("Loading font:", Default_Font);

  font = createFont(Default_Font, 36, true);

  ResetFontStyle();
}

void ResetFontStyle () {

  textFont(font);
  WORLD.graphics.textFont(font);
  WIN3D.graphics.textFont(font);
  STUDY.graphics.textFont(font);
}
