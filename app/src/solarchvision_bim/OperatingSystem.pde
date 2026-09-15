class solarchvision_OperatingSystem {

  private final static String CLASS_STAMP = "OperatingSystem";

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
}
