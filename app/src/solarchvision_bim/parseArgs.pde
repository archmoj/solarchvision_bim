

String asciiArt = ("""
   _______  _______  ___      _______  ______    _______  __   __  __   __  ___   _______  ___   _______  __   __ 
  |SSSSSSS||OOOOOOO||lll|    |aaaaaaa||rrrrrr|  |ccccccc||hh| |hh||vv| |vv||III| |sssssss||iii| |ooooooo||nn+ |nn|
  |S _____||OO _ OO||lll|    |aa _ aa||rr _ r|  |cc ____||hh|_|hh||vv|_|vv||III| |s _____||iii| |oo _ oo||nnn+|nn|
  |S|_____ |OO| |OO||lll|    |aa|_|aa||rr|_|r|  |cc|     |hhhhhhh||vvvvvvv||III| |s|_____ |iii| |oo| |oo||nnnnnnn|
  |_____ S||OO|_|OO||lll|___ |aaaaaaa||rr __ +  |cc|     |hh _ hh||vvvvvvv||III| |_____ s||iii| |oo|_|oo||nnnnnnn|
   _____|S||OOOOOOO||lllllll||aa _ aa||rr|  + + |cc|____ |hh| |hh| |vvvvv| |III|  _____|s||iii| |ooooooo||nn|+nnn|
  |_______||_______||_______||__| |__||__|   +_||_______||__| |__|  |___|  |___| |_______||___| |_______||__| +__|
""")
  .replace("+", "\\")
  .replace("S", "\u001B[2;31m$\u001B[0m")    // S = Dim Red
  .replace("O", "\u001B[2;31m$\u001B[0m")    // O = Dim Red
  .replace("l", "\u001B[2;33m$\u001B[0m")    // l = Dim Yellow / Ochre
  .replace("a", "\u001B[2;33m$\u001B[0m")    // a = Dim Yellow / Ochre
  .replace("r", "\u001B[2;32m$\u001B[0m")    // r = Dim Green
  .replace("c", "\u001B[2;32m$\u001B[0m")    // c = Dim Green
  .replace("h", "\u001B[2;36m$\u001B[0m")    // h = Dim Cyan / Slate Blue
  .replace("v", "\u001B[2;36m$\u001B[0m")    // v = Dim Cyan / Slate Blue
  .replace("I", "\u001B[2;34m$\u001B[0m")    // I = Dim Blue
  .replace("s", "\u001B[2;34m$\u001B[0m")    // s = Dim Blue
  .replace("i", "\u001B[2;35m$\u001B[0m")    // i = Dim Purple / Indigo
  .replace("o", "\u001B[2;35m$\u001B[0m")    // o = Dim Purple / Indigo
  .replace("n", "\u001B[90m$\u001B[0m");     // n = Gray

void parseArgs(String[] passedArgs) {
  println(asciiArt);

  if (passedArgs == null || passedArgs.length == 0) return;

  // Old processing-java packages sketch args behind a literal "--args"
  // sentinel; the new (4.5.x) CLI's docs say it forwards trailing args to
  // the sketch directly, with no such marker. Accept both.
  int start = passedArgs[0].equals("--args") ? 1 : 0;
  for (int i = start; i < passedArgs.length; i++) {
    _useArg(passedArgs[i]);
  }
}

String[][] runAfterInitialization = new String[0][0];

final int LOGLEVEL_GUI_AND_PRINT = 3;
final int LOGLEVEL_GUI_ONLY      = 2;
final int LOGLEVEL_PRINT_ONLY    = 1;
final int LOGLEVEL_DISABLED      = 0;
final int LOGLEVEL_IS_NOT_SET    = -1;

int logLevel = LOGLEVEL_GUI_AND_PRINT; //LOGLEVEL_IS_NOT_SET;


void _useArg(String arg) {
  String CAP_arg = arg.toUpperCase();

  int _at = 0;
  String input_str = "";
  String[] _tokens;

  _at = CAP_arg.indexOf("LOGLEVEL");
  if (_at == 0) {
    _tokens = split(CAP_arg, '=');
    if (_tokens.length > 1) {
      logLevel = PApplet.parseInt(_tokens[1]);
    }
  }

  _at = CAP_arg.indexOf("USER");
  if (_at == 0) {
    _tokens = split(CAP_arg, '=');
    if (_tokens.length > 1) {
      input_str = _tokens[1];
      if (input_str.equals("GUI")) {
        control = USER_GUI;
        if (logLevel == LOGLEVEL_IS_NOT_SET) logLevel = LOGLEVEL_GUI_ONLY;
      }
      else if (input_str.equals("AUTO")) {
        control = USER_AUTO;
        if (logLevel == LOGLEVEL_IS_NOT_SET) logLevel = LOGLEVEL_PRINT_ONLY;
      }
    }
  }

  _at = CAP_arg.indexOf("SCREEN");
  if (_at == 0) {
    _tokens = split(CAP_arg, '=');
    if (_tokens.length > 1) {
      String[] widthXheight = _tokens[1].split("X");
      screenWidth = PApplet.parseInt(widthXheight[0]);
      screenHeight = PApplet.parseInt(widthXheight[1]);
    }
  }

  _at = CAP_arg.indexOf("FONTSIZE");
  if (_at == 0) {
    _tokens = split(CAP_arg, '=');
    if (_tokens.length > 1) {
      userPointSize = PApplet.parseFloat(_tokens[1]);
    }
  }

  _at = CAP_arg.indexOf("FONT");
  if (_at == 0) {
    _tokens = split(CAP_arg, '=');
    if (_tokens.length > 1) {
      currentFont = split(arg, '=')[1]
        .replace("-", " ")
        .replace("_", " ");

      if (currentFont.equals("?")) {
        String[] fontList = PFont.list();
        for (int i = 0; i < fontList.length; i++) {
          println(fontList[i]);
        }
      }
    }
  }

  _at = CAP_arg.indexOf("RUN");
  if (_at == 0) {
    _tokens = split(arg, '=');
    if (_tokens.length > 1) {
      input_str = _tokens[1];
      if (!input_str.equals("")) {
        runAfterInitialization = splitByEqualSign(loadStrings(input_str));
      }
    }
  }
}


String[][] splitByEqualSign(String[] original) {
  String[][] sections = new String[0][]; // Fixed: Initialized with size 0
  int count = 0;
  int start = 0;

  while (start < original.length) {
      // Find where this current section ends (by looking for the next "=")
      int end = start + 1;
      while (
        end < original.length &&
        (
          original[end] == null ||
          !original[end].startsWith("=")
        )
      ) {
          end++;
      }

      // Expand our outer array by 1 element manually
      sections = Arrays.copyOf(sections, count + 1);

      // Shallow copy the segment
      sections[count] = Arrays.copyOfRange(original, start, end);

      count++;
      start = end; // Move to the start of the next section
  }

  return sections;
}