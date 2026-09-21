void CommandLine_keyPressed (KeyEvent e) {
  if ((!e.isAltDown()) && (!e.isControlDown())) {

    if (key != CODED) {
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
