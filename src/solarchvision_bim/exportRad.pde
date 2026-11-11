PrintWriter radOutput;

void exportRadiance () {

  // See isFileOperationInProgress's own comment (globalFunctions.pde)
  // for why - bare statement (this function has only the one exit
  // point below, so nothing further to guard); cleared at this
  // function's own end.
  isFileOperationInProgress = true;

  String fileBasename = ProjectName;

  String radFilename = Folder_Export3D + "/" + fileBasename + ".rad";

  // Radiance (and this project's own test suite) expect the .rad file's
  // line endings to be plain "\n" everywhere, regardless of the
  // platform this runs on. The PrintWriter createWriter() returns
  // writes System.lineSeparator() on println() instead (i.e. "\r\n" on
  // Windows), which would otherwise silently turn every multi-line
  // match against this file's content into a mismatch on Windows while
  // still passing on Linux/macOS - so override println() here to always
  // emit "\n" rather than touching every call site below and in
  // faces.pde's own RAD3D branch.
  radOutput = new PrintWriter(createWriter(radFilename)) {
    @Override
    public void println () {
      write("\n");
    }
    @Override
    public void println (String x) {
      print(x);
      write("\n");
    }
  };

  radOutput.println("#SOLARCHVISION");
  radOutput.println();



  Terrain.draw(TypeWindow.RAD3D);

  allFaces.draw(TypeWindow.RAD3D);



  for (int i = 15; i < 180; i += 15) {
    radOutput.println("!gensky -ang " + nf(i, 0) + " 45 +s -trb 4.0");
  }

  radOutput.flush();
  radOutput.close();

  println("\nFile created:" + radFilename);


  String batFilename = radFilename.replace(".rad", ".bat");
  PrintWriter batOutput = createWriter(batFilename);

  String octFilename = radFilename.replace(".rad", ".oct");

  // radFilename/octFilename are always built with "/" (see above), same
  // as Folder_Export3D itself, but the tests compare this line's own
  // path text against java.nio.file.Path's own toString() (which
  // normalizes to the platform's native separator - "\" on Windows,
  // "/" elsewhere): on Linux/macOS this is already a no-op, but on
  // Windows it's what makes this line's paths match "\"-separated
  // rather than staying mixed with the "/" that BaseFolder's own
  // Windows-native temp directory wouldn't otherwise contain.
  String Command1 = "oconv " + radFilename.replace('/', File.separatorChar);
  Command1 += " > " + octFilename.replace('/', File.separatorChar);
  batOutput.println(Command1);

  String Command2 = "rvu";

  //Command2 += " -vtl"; //parallel
  Command2 += " -vtv"; //perspective
  //Command2 += " -vth"; //hemispherical
  //Command2 += " -vtc"; //cylindrical
  //Command2 += " -vta"; //angular
  //Command2 += " -vts"; //stereographic

  Command2 += " -vv " + nf(WIN3D.zoom, 0, 0);
  Command2 += " -vh " + nf(2 * funcs.atan_ang((WIN3D.dX / float(WIN3D.dY)) * funcs.tan_ang(0.5 * WIN3D.zoom)), 0, 0);

  Command2 += " -vp " + nf(WIN3D.cameraX / overallScale, 0, 0) + " " + nf(WIN3D.cameraY / overallScale, 0, 0) + " " + nf(WIN3D.cameraZ / overallScale, 0, 0);

  float dx = funcs.cos_ang(90 - WIN3D.rotationX) * funcs.cos_ang(90 - WIN3D.rotationZ);
  float dy = funcs.cos_ang(90 - WIN3D.rotationX) * funcs.sin_ang(90 - WIN3D.rotationZ);
  float dz = funcs.sin_ang(90 - WIN3D.rotationX);

  Command2 += " -vd " + nf(-dx , 0, 0) + " " + nf(dy, 0, 0) + " " + nf(-dz, 0, 0);

  float ux = 0;
  float uy = 0;
  float uz = 1;
  if (abs(dz) > 0.99) {
    ux = funcs.cos_ang(90 + WIN3D.rotationZ);
    uy = funcs.sin_ang(90 + WIN3D.rotationZ);
    uz = 0;
  }
  Command2 += " -vu " + nf(ux, 0, 0) + " " + nf(uy, 0, 0) + " " + nf(uz, 0, 0);







  Command2 += " -av 0.5 0.5 0.5";
  Command2 += " -pe 0.001";
  Command2 += " -ab 1";
  Command2 += " " + octFilename.replace('/', char(92));
  batOutput.println(Command2);

  batOutput.println("cmd /k"); // leave command prompt open

  batOutput.flush();
  batOutput.close();

  isFileOperationInProgress = false;
}
