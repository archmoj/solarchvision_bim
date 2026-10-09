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
        // Queued whole, as one flat array - runScriptLines itself (see
        // runScript.pde) splits at "=" dividers as it goes, deferring
        // whatever comes after one to a later draw() frame, rather than
        // this needing to pre-split into per-frame sections up front.
        queuePendingScriptLines(loadStrings(input_str));
      }
    }
  }
}