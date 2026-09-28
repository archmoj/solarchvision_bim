class UI_consoleBar {

  final static String CLASS_STAMP = "UI_consoleBar";

  boolean update = true;

  int editCursor = 0;

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
      rect(0, pixel_A + pixel_B + 2 * pixel_H + pixel_C, width, pixel_D);

      noStroke();

      textSize(1.25 * MessageSize);


      pushMatrix();
      translate(0, 0.625 * MessageSize + pixel_A + pixel_B + 2 * pixel_H + pixel_C);

      for (int q = 0; q < maxDisplayLines; q++) {

        int n = allCommands.length + q - maxDisplayLines;

        if ((0 <= n) && (n < allCommands.length)) {

          textAlign(RIGHT, CENTER);
          fill(255,127,0);
          text(allMessages[n], width - 0.5 * MessageSize, q * 1.5 * MessageSize);

          textAlign(LEFT, CENTER);
          fill(255);

          String txt = allCommands[n];
          if(n == allCommands.length - 1) {
            // text with cursor
            if(this.editCursor < allCommands[allCommands.length - 1].length()) {
              txt =
                txt.substring(0, this.editCursor) + "|" +
                txt.substring(this.editCursor);
            } else {
              txt += "|";
            }
          }
          text(txt, 0.5 * MessageSize, q * 1.5 * MessageSize);

        }
      }

      popMatrix();

      X_clicked = -1;
      Y_clicked = -1;
    }
  }

  void revise () {
    this.update = true;
  }
  void updated () {
    this.update = false;
  }

  String runLastCommand() {
    return runScriptLine(allCommands[allCommands.length - 1]);
  }

  void keyPressed (KeyEvent e) {
    if (e.isControlDown() && (!e.isAltDown()) && (e.getKeyCode() == 86)) { // key code 86 corresponds to V (Ctrl+V)
      String[] allLines = split(getClipboardText(), '\n');

      for (int i = 0; i < allLines.length; i++) {
        String line = allLines[i];
        if(i == 0) {
          allCommands[allCommands.length - 1] =
          allCommands[allCommands.length - 1].substring(0, this.editCursor) + line +
          allCommands[allCommands.length - 1].substring(this.editCursor);
          this.editCursor += line.length();
        } else {
          // run previous command before adding new line
          String hint = runLastCommand();
          allMessages[allMessages.length - 1] = hint;
          allCommands = concat(allCommands, new String[] {""});
          allMessages = concat(allMessages, new String[] {""});

          // interrupt in case of error
          if(hint.equals(UnrecognizedCommand)) break;

          // add new line
          allCommands[allCommands.length - 1] = line;
        }
      }
    } else if ((!e.isAltDown()) && (!e.isControlDown())) {

      if (key == CODED) {
        switch (keyCode) {

          case LEFT:
            if (this.editCursor > 0) this.editCursor--;
            break;

          case RIGHT:
            if (this.editCursor < allCommands[allCommands.length - 1].length()) this.editCursor++;
            break;
        }

        return;
      } else {
        switch(key) {

          case ENTER:
            allMessages[allMessages.length - 1] = runLastCommand();
            allCommands = concat(allCommands, new String[] {""});
            allMessages = concat(allMessages, new String[] {""});
            this.editCursor = 0;
            break;

          case BACKSPACE:
            if (this.editCursor > 0) {
              allCommands[allCommands.length - 1] =
              allCommands[allCommands.length - 1].substring(0, this.editCursor - 1) +
              allCommands[allCommands.length - 1].substring(this.editCursor);

              this.editCursor--;
            }
            break;

          case DELETE:
            if (this.editCursor < allCommands[allCommands.length - 1].length()) {
              allCommands[allCommands.length - 1] =
              allCommands[allCommands.length - 1].substring(0, this.editCursor) +
              allCommands[allCommands.length - 1].substring(this.editCursor + 1);
            }
            break;

          default:
            if ((31 < key) && (key < 127)) {
              allCommands[allCommands.length - 1] =
              allCommands[allCommands.length - 1].substring(0, this.editCursor) + key +
              allCommands[allCommands.length - 1].substring(this.editCursor);

              this.editCursor++;
            }
            break;
        }
      }
    }
  }
}

private static String getClipboardText () {
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
