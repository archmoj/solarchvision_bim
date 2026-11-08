String IMAGE_directory = "../../input/images/trees_raw/";
String[] IMAGE_Files = getfiles(IMAGE_directory);

int _frame = 0;

void setup() {
  //size(800, 800, P2D);
}

void draw() {
  _frame += 1;

  if (_frame <= IMAGE_Files.length) {
  //if (_frame <= 1) {

    int i = _frame - 1;

    int _L = IMAGE_Files[i].length();
    String _Extention = IMAGE_Files[i].substring(_L - 4,_L);
    //println(_Extention);
    if (_Extention.toLowerCase().equals(".png")) {
      String _Filename = IMAGE_Files[i].substring(0,_L - 4);
      println (_Filename);

      PImage Image_RGBA = loadImage(IMAGE_directory + "/" + IMAGE_Files[i]);
      int w = Image_RGBA.width;
      int h = Image_RGBA.height;
      float p = 0.0; 
      {
        p = 0.05;
        PImage CROP_RGBA = Image_RGBA.get(floor(w * p),floor(h * p * 2),floor(w * (1 - 2 * p)),floor(h * (1 - 2 * p)));
        CROP_RGBA.save(IMAGE_directory + "/CROP/" + _Filename + "_A" + _Extention);
      }
      {
        p = 0.075;
        PImage CROP_RGBA = Image_RGBA.get(floor(w * p),floor(h * p * 2),floor(w * (1 - 2 * p)),floor(h * (1 - 2 * p)));
        CROP_RGBA.save(IMAGE_directory + "/CROP/" + _Filename + "_B" + _Extention);
      }
      {
        p = 0.1;
        PImage CROP_RGBA = Image_RGBA.get(floor(w * p),floor(h * p * 2),floor(w * (1 - 2 * p)),floor(h * (1 - 2 * p)));
        CROP_RGBA.save(IMAGE_directory + "/CROP/" + _Filename + "_C" + _Extention);
      }


    }
  }
  else{
    exit();
  }
}


String[] getfiles (String _Folder) {
  File dir = new File(_Folder);

  String[] filenames = dir.list();

  if (filenames != null) {
    for (int i = 0; i < filenames.length; i++) {
      //println(filenames[i]);
    }
  }
  return filenames;
}
