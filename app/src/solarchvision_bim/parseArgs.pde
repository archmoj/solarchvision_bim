void parseArgs(String[] passedArgs) {
  // Check if any custom arguments were passed via --args
  if (
    passedArgs != null &&
    passedArgs.length > 0 &&
    passedArgs[0].equals("--args")
  ) {
    for (int i = 1; i < passedArgs.length; i++) {
      _useArg(passedArgs[i]);
    }
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
      if (input_str.equals("GUI")) SOLARCHVISION_control = USER_GUI;
      else if (input_str.equals("AUTO")) SOLARCHVISION_control = USER_AUTO;
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
