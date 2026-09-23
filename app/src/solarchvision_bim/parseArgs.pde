void parseArgs(String[] passedArgs) {
  if (passedArgs == null || passedArgs.length == 0) return;

  // Old processing-java packages sketch args behind a literal "--args"
  // sentinel; the new (4.5.x) CLI's docs say it forwards trailing args to
  // the sketch directly, with no such marker. Accept both.
  int start = passedArgs[0].equals("--args") ? 1 : 0;
  for (int i = start; i < passedArgs.length; i++) {
    _useArg(passedArgs[i]);
  }
}

String runAfterInitialization = "";

void _useArg(String arg) {
  String CAP_arg = arg.toUpperCase();

  int _at = 0;
  int input_int = 0;
  float input_float = 0;
  String input_str = "";
  String[] _tokens;

  _at = CAP_arg.indexOf("USER");
  if (_at == 0) {
    _tokens = split(CAP_arg, '=');
    if (_tokens.length > 1) {
      input_str = _tokens[1];
      if (input_str.equals("GUI")) control = USER_GUI;
      else if (input_str.equals("AUTO")) control = USER_AUTO;
    }
  }

  _at = CAP_arg.indexOf("RUN");
  if (_at == 0) {
    _tokens = split(arg, '=');
    if (_tokens.length > 1) {
      input_str = _tokens[1];
      if (!input_str.equals("")) runAfterInitialization = input_str;
    }
  }
}
