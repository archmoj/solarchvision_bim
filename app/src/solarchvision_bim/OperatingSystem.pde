class OperatingSystem {

  final static String CLASS_STAMP = "OperatingSystem";

  String[] getFiles (String _Folder) {
    //println(_Folder);
    String[] filenames = new String[0];
    File dir = new File(_Folder);
    if (dir.exists() && dir.isDirectory()) {
      filenames = concat(filenames, dir.list());
      if (filenames != null) {
        for (int i = 0; i < filenames.length; i++) {
          //println(filenames[i]);
        }
      }
    }
    return filenames;
  }

  String getFilenameFromPath (String path) {
    File file = new File(path);
    return split(file.getName(),'.')[0]; // using the first text before dot
  }

  int getTerminalWidth() {
    String os = System.getProperty("os.name").toLowerCase();
    try {
      ProcessBuilder pb;
      if (os.contains("win")) {
        // Windows: Queries the current command prompt buffer
        pb = new ProcessBuilder("cmd.exe", "/c", "mode con");
      } else {
        // Unix/Linux/macOS: Directs tput to look at the process's controlling tty
        pb = new ProcessBuilder("sh", "-c", "tput cols 2>/dev/tty");
      }

      Process process = pb.start();
      try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
        String line;
        if (os.contains("win")) {
          // Windows output contains "Columns:    80"
          while ((line = reader.readLine()) != null) {
            if (line.trim().startsWith("Columns:")) {
              return Integer.parseInt(line.replaceAll("[^0-9]", ""));
            }
          }
        } else {
          // Unix simply outputs the number (e.g., "120")
          line = reader.readLine();
          if (line != null) {
            return Integer.parseInt(line.trim());
          }
        }
      }
    } catch (Exception e) {
      // Silently fall back if terminal is detached or environments lack tools
    }
    return 120; // fallback
  }
}
