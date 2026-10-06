String asciiArt = ("""
   _______  _______  ___      _______  ______    _______  __   __  __   __  ___   _______  ___   _______  __   __ 
  |.......||.......||...|    |.. _ ..||......|  |.......||..| |..||..| |..||...| |.......||...| |.......||..+ |..|
  |. _____||.. _ ..||...|    |..|_|..||.. _ .|  |.. ____||..|_|..||..|_|..||...| |. _____||...| |.. _ ..||...+|..|
  |.|_____ |..| |..||...|    |.......||..|_|.|  |..|     |.......||.......||...| |.|_____ |...| |..| |..||.......|
  |_____ .||..|_|..||...|___ |.......||.. __ +  |..|     |.. _ ..||.......||...| |_____ .||...| |..|_|..||.......|
   _____|.||.......||.......||.. _ ..||..|  + + |..|____ |..| |..| |.....| |...|  _____|.||...| |.......||..|+...|
  |_______||_______||_______||__| |__||__|   +_||_______||__| |__|  |___|  |___| |_______||___| |_______||__| +__|
""")
  .replace("+", "\\")
  .replace(".", "\u001B[90m$\u001B[0m");

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