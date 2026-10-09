String TERRAINTAP_API_KEY = "";

void load_env () {
  String[] lines = loadStrings(".env");
  if (lines != null) {
    int len = lines.length;
    for (int i = 0; i < len; i++) {
      String[] parts = lines[i].split("=");
      if(parts.length > 1) {
        String key = parts[0];
        String val = parts[1];
        if(key.equals("TERRAINTAP_API_KEY")) {
          TERRAINTAP_API_KEY = val;
        }
      }
    }
  }
}
