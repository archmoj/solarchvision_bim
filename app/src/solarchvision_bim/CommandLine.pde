HashMap<String,String> parseParams(String[] parts) {
  HashMap<String,String> p = new HashMap<String,String>();
  for (int q = 1; q < parts.length; q++) {
    String[] kv = split(parts[q], '=');
    if (kv.length > 1) {
      p.put(kv[0].toLowerCase(), kv[1]);
    }
  }
  return p;
}

float getF(HashMap<String,String> p, String key, float def) {
  return p.containsKey(key) ? float(p.get(key)) : def;
}

int getI(HashMap<String,String> p, String key, int def) {
  return p.containsKey(key) ? int(p.get(key)) : def;
}

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
