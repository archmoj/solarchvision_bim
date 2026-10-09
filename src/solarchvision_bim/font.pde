final String DEFAULT_FONT = "font/selawk.ttf";

String currentFont = DEFAULT_FONT;

PFont font;

final int maxFontSize = 36;
final boolean smoothFont = true;

void loadCurrentFontStyle () {

  println("Loading font:", currentFont);

  font = createFont(currentFont, maxFontSize, smoothFont);

  ResetFontStyle();
}

void ResetFontStyle () {

  textFont(font);
  WORLD.graphics.textFont(font);
  WIN3D.graphics.textFont(font);
  STUDY.graphics.textFont(font);
}
