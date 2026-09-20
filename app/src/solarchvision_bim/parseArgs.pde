void parseArgs(String[] passedArgs) {
  // Check if any custom arguments were passed via --args
  if (
    passedArgs != null &&
    passedArgs.length > 0 &&
    passedArgs[0] == "--args"
  ) {
    for (int i = 1; i < passedArgs.length; i++) {
      _useArg(passedArgs[i]);
    }
  }
}

void _useArg(String arg) {
  String CAP_arg = arg.toUpperCase();

  int _at = 0;
  int input_int = 0;
  float input_float = 0;
  String input_str = "";
  String[] _tokens;

  _at = CAP_arg.indexOf("AUTO");
  if (_at == 0) {
    _tokens = split(CAP_arg, '=');
    if (_tokens.length > 1) {
      input_str = _tokens[1];
      if (input_str.equals("USER")) SOLARCHVISION_automated = USER_INT;
      else if (input_str.equals("PDF")) SOLARCHVISION_automated = AUTO_PDF;
      else if (input_str.equals("GIF")) SOLARCHVISION_automated = AUTO_GIF;
      else if (input_str.equals("BMP")) SOLARCHVISION_automated = AUTO_BMP;
      else if (input_str.equals("JPG")) SOLARCHVISION_automated = AUTO_JPG;
      else if (input_str.equals("PNG")) SOLARCHVISION_automated = AUTO_PNG;
      else if (input_str.equals("TIF")) SOLARCHVISION_automated = AUTO_TIF;
    }
  }
}
