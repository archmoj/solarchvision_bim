class solarchvision_UI_commandBar {

  private final static String CLASS_STAMP = "UI_commandBar";

  boolean update = true;

  void draw () {
    if (this.update) {

      this.updated();

      int maxDisplayLines = 3;

      if (typeUserCommand == 1) {
        fill(0);
      }
      else {
        fill(63);
      }
      noStroke();
      rect(0, SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + SOLARCHVISION_pixel_C, width, SOLARCHVISION_pixel_D);

      noStroke();

      textSize(1.25 * MessageSize);


      pushMatrix();
      translate(0, 0.625 * MessageSize + SOLARCHVISION_pixel_A + SOLARCHVISION_pixel_B + 2 * SOLARCHVISION_pixel_H + SOLARCHVISION_pixel_C);

      for (int q = 0; q < maxDisplayLines; q++) {

        int n = allCommands.length + q - maxDisplayLines;

        if ((0 <= n) && (n < allCommands.length)) {

          textAlign(RIGHT, CENTER);
          fill(255,127,0);
          text(allMessages[n], width - 0.5 * MessageSize, q * 1.5 * MessageSize);

          textAlign(LEFT, CENTER);
          fill(255);
          text(allCommands[n], 0.5 * MessageSize, q * 1.5 * MessageSize);

        }
      }

      popMatrix();

      SOLARCHVISION_X_clicked = -1;
      SOLARCHVISION_Y_clicked = -1;
    }
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }
}
