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

String[][] runAfterInitialization = new String[0][0];

void _useArg(String arg) {
  String CAP_arg = arg.toUpperCase();

  int _at = 0;
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