class UI_consoleBar {

  final static String CLASS_STAMP = "UI_consoleBar";

  boolean update = true;

  int cycleCursor = 0;
  int editCursor = 0;
  String editText = "";

  void draw () {
    if (this.update) {

      this.updated();

      int maxDisplayLines = 3;

      if (typeUserCommand == 1) {
        fill(0, 0, 63);
      }
      else {
        fill(127);
      }
      noStroke();
      rect(0, pixel_A + pixel_B + 2 * pixel_H + pixel_C, width, pixel_D);

      noStroke();

      textSize(1.15 * MessageSize);


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

          float x = 0.5 * MessageSize;
          float y = q * 1.5 * MessageSize;

          String txt = n < allCommands.length - 1 ? allCommands[n] : this.editText;
          if(typeUserCommand == 0) {
            text(txt, x, y);
          } else {
            String txt_1 = txt;
            String txt_2 = "";
            String txt_3 = "";
            if(n == allCommands.length - 1) {
              // text with cursor
              if(this.editCursor < this.editText.length()) {
                txt_1 = txt.substring(0, this.editCursor);
                txt_3 = txt.substring(this.editCursor);
              }
              txt_2 = "|";
            }
            text(txt_1, x, y);
            if(!txt_2.equals("")) {
              float offset = textWidth(txt_1); // measure previous text
              fill(255, 0, 0);
              text(txt_2, offset + x, y);

              if(!txt_3.equals("")) {
                offset += textWidth(txt_2); // measure previous text
                fill(255);
                text(txt_3, offset + x, y);
              }
            }
          }
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
    // record command
    allCommands[allCommands.length - 1] = this.editText;
    // reset editText
    this.editText = "";
    this.editCursor = 0;
    this.cycleCursor = allCommands.length;
    // run last command
    return runScriptLine(allCommands[allCommands.length - 1]);
  }

  // --- Continuous key-hold repeat (see WIN3D.pde) -----------------------
  // Processing does not forward OS key-repeat events while a key stays
  // held, so the arrow keys and Backspace/Delete are re-run once per
  // frame (from draw(), via processHeldKey()) for as long as they remain
  // held. Enter, Ctrl+V and printable character typing stay single-press.
  boolean navKeyHeld = false;
  boolean navKeyCoded = false;
  char navKeyChar = 0;
  int navKeyCode = 0;
  // Delay-then-repeat, like an OS key-repeat setting, at frameRate(24):
  // ~0.25s before the first repeat, then one step every frame (~24/s).
  static final int NAV_KEY_INITIAL_DELAY_FRAMES = 6;
  static final int NAV_KEY_REPEAT_FRAMES = 1;
  int navKeyFrameCounter = 0;
  boolean navKeyRepeating = false;

  void keyPressed (KeyEvent e) {
    if (e.isControlDown() && (!e.isAltDown()) && (e.getKeyCode() == 86)) { // key code 86 corresponds to V (Ctrl+V)
      this.navKeyHeld = false;

      String[] allLines = split(getClipboardText(), '\n');

      for (int i = 0; i < allLines.length; i++) {
        String line = allLines[i];
        if(i == 0) {
          this.editText =
          this.editText.substring(0, this.editCursor) + line +
          this.editText.substring(this.editCursor);
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
          this.editText = line;
        }
      }
    } else if ((!e.isAltDown()) && (!e.isControlDown())) {

      boolean isCoded = (key == CODED);
      char keyChar = key;
      int code = keyCode;

      boolean isRepeatableArrow = isCoded &&
        ((code == UP) || (code == DOWN) || (code == LEFT) || (code == RIGHT));
      boolean isRepeatableEdit = !isCoded && ((keyChar == BACKSPACE) || (keyChar == DELETE));

      this.navKeyHeld = isRepeatableArrow || isRepeatableEdit;
      this.navKeyCoded = isCoded;
      this.navKeyChar = keyChar;
      this.navKeyCode = code;
      this.navKeyFrameCounter = 0;
      this.navKeyRepeating = false;

      this.dispatchEditKey(isCoded, code, keyChar);
    }
  }

  // Applies one coded (arrow) or uncoded (Enter/Backspace/Delete/typed
  // character) key action. Shared by keyPressed() (first press) and
  // processHeldKey() (repeat).
  void dispatchEditKey (boolean isCoded, int code, char keyChar) {
    if (isCoded) {
      switch (code) {

        case UP:
          if (this.cycleCursor > 0) {
            if(this.cycleCursor == allCommands.length - 1) {
              // keep edit text inside last allCommands
              allCommands[this.cycleCursor] = this.editText;
            }

            this.cycleCursor--;
            this.editText = allCommands[this.cycleCursor];
            this.editCursor = this.editText.length();
          }
          break;

        case DOWN:
          if (this.cycleCursor < allCommands.length - 1) {
            this.cycleCursor++;
            this.editText = allCommands[this.cycleCursor];
            this.editCursor = this.editText.length();
          }
          break;

        case LEFT:
          if (this.editCursor > 0) this.editCursor--;
          break;

        case RIGHT:
          if (this.editCursor < this.editText.length()) this.editCursor++;
          break;
      }
    } else {
      switch(keyChar) {

        case ENTER:
          allMessages[allMessages.length - 1] = runLastCommand();
          allCommands = concat(allCommands, new String[] {""});
          allMessages = concat(allMessages, new String[] {""});
          this.editCursor = 0;
          break;

        case BACKSPACE:
          if (this.editCursor > 0) {
            this.editText =
            this.editText.substring(0, this.editCursor - 1) +
            this.editText.substring(this.editCursor);

            this.editCursor--;
          }
          break;

        case DELETE:
          if (this.editCursor < this.editText.length()) {
            this.editText =
            this.editText.substring(0, this.editCursor) +
            this.editText.substring(this.editCursor + 1);
          }
          break;

        default:
          if ((31 < keyChar) && (keyChar < 127)) {
            this.editText =
            this.editText.substring(0, this.editCursor) + keyChar +
            this.editText.substring(this.editCursor);

            this.editCursor++;
          }
          break;
      }
    }

    this.revise();
  }

  // Called once per frame from the sketch's draw(); re-fires the held
  // key's action for as long as it remains held.
  void processHeldKey () {
    if (this.navKeyHeld) {
      this.navKeyFrameCounter++;
      int threshold = this.navKeyRepeating ? NAV_KEY_REPEAT_FRAMES : NAV_KEY_INITIAL_DELAY_FRAMES;
      if (this.navKeyFrameCounter >= threshold) {
        this.navKeyFrameCounter = 0;
        this.navKeyRepeating = true;
        this.dispatchEditKey(this.navKeyCoded, this.navKeyCode, this.navKeyChar);
      }
    }
  }

  // Matches the global keyReleased() convention (no KeyEvent overload
  // needed): uses the sketch's global key/keyCode.
  void keyReleased () {
    if (!this.navKeyHeld) return;

    boolean releasedCoded = (key == CODED);
    if (releasedCoded != this.navKeyCoded) return;

    if (releasedCoded) {
      if (keyCode == this.navKeyCode) this.navKeyHeld = false;
    } else {
      if (key == this.navKeyChar) this.navKeyHeld = false;
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
