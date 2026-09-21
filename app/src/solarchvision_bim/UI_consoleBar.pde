class solarchvision_UI_consoleBar {

  final static String CLASS_STAMP = "UI_consoleBar";

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

  void keyPressed (KeyEvent e) {
    if ((!e.isAltDown()) && (!e.isControlDown())) {

      if(key == 22) { // ASCII code 22 corresponds to Ctrl+V
        allCommands[allCommands.length - 1] += pasteTextFromClipboard();
      } else if (key != CODED) {
        switch(key) {

          case ENTER:
            String[] newCommand = {""};
            String[] newMessage = {""};

            allMessages[allMessages.length - 1] = SOLARCHVISION_runScriptLine(allCommands[allCommands.length - 1]);

            allCommands = concat(allCommands, newCommand);
            allMessages = concat(allMessages, newMessage);
            break;

          case BACKSPACE:
              if (allCommands[allCommands.length - 1].length() > 0) {
                allCommands[allCommands.length - 1] = allCommands[allCommands.length - 1].substring(0, allCommands[allCommands.length - 1].length() - 1);
              }
              break;

          default:
            if ((31 < key) && (key < 127)) {
              allCommands[allCommands.length - 1] += key;
            }
            break;
        }
      }
    }
  }
}

private static String pasteTextFromClipboard () {
  try {
      Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
      Transferable contents = clipboard.getContents(null);
      if (contents != null && contents.isDataFlavorSupported(DataFlavor.stringFlavor)) {
          return (String) contents.getTransferData(DataFlavor.stringFlavor);
      }
  } catch (UnsupportedFlavorException | IOException e) {
      e.printStackTrace();
  } catch (IllegalStateException e) {
      System.err.println("Clipboard is busy. Try again.");
  }

  return null;
}