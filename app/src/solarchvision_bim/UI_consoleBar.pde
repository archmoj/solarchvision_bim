class UI_consoleBar {

  final static String CLASS_STAMP = "UI_consoleBar";

  boolean update = true;

  int cycleCursor = 0;
  int editCursor = 0;
  String editText = "";

  ArrayList<String> allCommands = new ArrayList<String>(Arrays.asList("Command Input:", ""));

  void emptyCommands() {
    this.allCommands = new ArrayList<String>();
    this.allCommands.add("");
  }

  final int maxDisplayLines = 2;
  final float hOne = pixel_D / (maxDisplayLines + 1);

  void drawEmptyDirective () {
    // empty background
    this.drawDirective("", true);
  }

  void drawDirective (String txt, boolean b) {
    // g (the PGraphics context) is only non-null once setup()/size() has
    // actually run - never true in a headless JUnit test
    if (g == null) return;

    float x = 0;
    float y = pixel_A + pixel_B + 2 * pixel_H + pixel_C + pixel_D - hOne;

    noStroke();
    fill(0);
    rect(x, y, width, hOne + 1);

    if(b) { // blue for commands/actions
      fill(127, 127, 255);
    } else { // red for hint
      fill(255, 127, 127);
    }
    textAlign(LEFT, TOP);
    textSize(1.15 * MessageSize);
    text(txt,
      x + 0.5 * MessageSize,
      y + 0.25 * MessageSize
    );
  }

  void draw () {
    if (this.update) {

      this.updated();

      if (typeUserCommand == 1) {
        fill(0, 0, 63);
      }
      else {
        fill(127);
      }
      noStroke();
      rect(0, pixel_A + pixel_B + 2 * pixel_H + pixel_C, width, pixel_D - hOne);

      noStroke();

      textSize(1.15 * MessageSize);


      pushMatrix();
      translate(0, 0.625 * MessageSize + pixel_A + pixel_B + 2 * pixel_H + pixel_C);

      for (int q = 0; q < maxDisplayLines; q++) {

        int n = this.allCommands.size() + q - maxDisplayLines;

        if ((0 <= n) && (n < this.allCommands.size())) {

          textAlign(LEFT, CENTER);
          fill(255);

          float x = 0.5 * MessageSize;
          float y = q * 1.5 * MessageSize;

          String txt = n < this.allCommands.size() - 1 ? this.allCommands.get(n) : this.editText;
          if(typeUserCommand == 0) {
            text(txt, x, y);
          } else {
            String txt_1 = txt;
            String txt_2 = "";
            String txt_3 = "";
            if(n == this.allCommands.size() - 1) {
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

  boolean isCurrentCommandEmpty() {
    if(this.editText.equals("")) {
      // Note here we clear the message as side effect
      this.drawEmptyDirective();

      return true;
    }
    return false;
  }

  String runCurrentCommand() {
    // record command
    this.allCommands.set(this.allCommands.size() - 1, this.editText);
    // reset editText
    this.editText = "";
    this.editCursor = 0;
    this.cycleCursor = this.allCommands.size();
    // run last command
    String lastCommand = this.allCommands.get(this.allCommands.size() - 1);
    if(lastCommand.equals("")) UI_consoleBar.drawEmptyDirective();
    return runScriptLine(lastCommand);
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
          String hint = runCurrentCommand();
          this.allCommands.add("");

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
            if(this.cycleCursor == this.allCommands.size() - 1) {
              // keep edit text inside last this.allCommands
              this.allCommands.set(this.cycleCursor, this.editText);
            }

            this.cycleCursor--;
            this.editText = this.allCommands.get(this.cycleCursor);
            this.editCursor = this.editText.length();
          }
          break;

        case DOWN:
          if (this.cycleCursor < this.allCommands.size() - 1) {
            this.cycleCursor++;
            this.editText = this.allCommands.get(this.cycleCursor);
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
          if(!isCurrentCommandEmpty()) {
            runCurrentCommand();
            this.allCommands.add("");
            this.editCursor = 0;
          }
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

final String ANSI_RESET  = "\u001B[0m";

final String ANSI_BLACK  = "\u001B[30m";
final String ANSI_RED    = "\u001B[31m";
final String ANSI_GREEN  = "\u001B[32m";
final String ANSI_YELLOW = "\u001B[33m";
final String ANSI_BLUE   = "\u001B[34m";
final String ANSI_PURPLE = "\u001B[35m";
final String ANSI_CYAN   = "\u001B[36m";
final String ANSI_WHITE  = "\u001B[37m";

final String ANSI_BLACK_BG  = "\u001B[40m";
final String ANSI_RED_BG    = "\u001B[41m";
final String ANSI_GREEN_BG  = "\u001B[42m";
final String ANSI_YELLOW_BG = "\u001B[43m";
final String ANSI_BLUE_BG   = "\u001B[44m";
final String ANSI_PURPLE_BG = "\u001B[45m";
final String ANSI_CYAN_BG   = "\u001B[46m";

final String OSC8_START = "\u001B]8;;";
final String OSC8_END   = "\u001B\\";
final String OSC8_CLOSE = "\u001B]8;;\u001B\\";

String terminalLink (String path) {
  File file = new File(path);
  String linkText = path; // file.getName();
  String fileUri = "file://" + file.getAbsolutePath();

  return (OSC8_START + fileUri + OSC8_END + linkText + OSC8_CLOSE);
}

String terminalLinkColor (String path) {
  if (control == USER_GUI) {
    return (
      ANSI_BLACK +
      ANSI_YELLOW_BG +
      terminalLink(path)+
      ANSI_RESET
    );
  }

  return (ANSI_GREEN + path + ANSI_RESET);
}

void printlnSaving (String path) {
  println("\nSaving:", terminalLinkColor(path));
}

final String ERROR_HEAD   = "<Error>: ";
final String ACTION_HEAD  = "[Action]: ";
final String COMMAND_HEAD = "(Command): ";
final String HINT_HEAD    = "Hint: ";

void printSameLine(String txt) {
  int paddingLength = terminalWidth - txt.length();
  if (paddingLength > 0) {
    txt += " ".repeat(paddingLength);
  }

  print("\r" + txt);
}

void displayDirective(String txt) {
  printDirective(txt);
  UI_consoleBar.drawDirective(txt, true);
}

void printDirective(String txt) {
  if (
    logLevel == LOGLEVEL_PRINT_ONLY ||
    logLevel == LOGLEVEL_GUI_AND_PRINT
  ) {
    if (control == USER_GUI) {
      printSameLine(ANSI_BLACK + ANSI_BLUE_BG + txt + ANSI_RESET);
    } else {
      println(txt);
    }
  }
}

void printFeedback(String txt, boolean isUnrecognizedCommand) {
  if (
    logLevel == LOGLEVEL_PRINT_ONLY ||
    logLevel == LOGLEVEL_GUI_AND_PRINT
  ) {
    if (isUnrecognizedCommand) {
      printError(txt);
    } else {
      println("\n" + ANSI_BLUE + ANSI_YELLOW_BG + HINT_HEAD + txt + ANSI_RESET);
    }
  }
}

void printError (String txt) {
  if (
    logLevel == LOGLEVEL_PRINT_ONLY ||
    logLevel == LOGLEVEL_GUI_AND_PRINT
  ) {
    println("\n" + ERROR_HEAD + ANSI_YELLOW + ANSI_RED_BG + txt + ANSI_RESET);
  }
}

void progressBarHeader () {
  println("       10%       20%       30%       40%       50%       60%       70%       80%       90%       100%");
  println(".........|.........|.........|.........|.........|.........|.........|.........|.........|.........|");
}
