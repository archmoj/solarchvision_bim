void draw_frame_icon () {
  int frame_icon_size = 64;

  PGraphics frame_icon = createGraphics(frame_icon_size, frame_icon_size);

  frame_icon.beginDraw();

  //frame_icon.image(loadImage(BaseFolder + "/input/images/icon/s-icon.png"), 0, 0 );

  frame_icon.background(0);
  //frame_icon.background(63,63,255,255);

  //frame_icon.fill(255,127);
  frame_icon.fill(255, 255, 0, 127);

  frame_icon.textAlign(CENTER, CENTER);
  frame_icon.textSize(1.0 * frame_icon_size);
  frame_icon.text("S", 0.20 * frame_icon_size, 0.4 * frame_icon_size);
  frame_icon.text("A", 0.50 * frame_icon_size, 0.4 * frame_icon_size);
  frame_icon.text("V", 0.80 * frame_icon_size, 0.4 * frame_icon_size);

  frame_icon.endDraw();
  //frame.setIconImage(frame_icon.image);

  //frame.setTitle("SOLARCHVISION-" + version);
}
