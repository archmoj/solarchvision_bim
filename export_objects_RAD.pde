PrintWriter radOutput;

void SOLARCHVISION_export_objects_RAD () {

  String fileBasename = ProjectName;

  String radFilename = Folder_Export3D + "/" + fileBasename + ".rad";

  radOutput = createWriter(radFilename);

  radOutput.println("#SOLARCHVISION");
  radOutput.println();



  Land3D.draw(TypeWindow.RAD3D);

  allFaces.draw(TypeWindow.RAD3D);



  for (int i = 15; i < 180; i += 15) {
    radOutput.println("!gensky -ang " + nf(i, 0) + " 45 +s -trb 4.0");
  }

  radOutput.flush();
  radOutput.close();

  println("End of creating rad file.");

  println("File created:" + radFilename);


  String batFilename = radFilename.replace(".rad", ".bat");
  PrintWriter batOutput = createWriter(batFilename);

  String Command1 = "oconv " + radFilename;
  String octFilename = radFilename.replace(".rad", ".oct");
  Command1 += " > " + octFilename;
  batOutput.println(Command1);

  String Command2 = "rvu";

  //Command2 += " -vtl"; //parallel
  Command2 += " -vtv"; //perspective
  //Command2 += " -vth"; //hemispherical
  //Command2 += " -vtc"; //cylindrical
  //Command2 += " -vta"; //angular
  //Command2 += " -vts"; //stereographic

  Command2 += " -vv " + nf(WIN3D.Zoom, 0, 0);
  Command2 += " -vh " + nf(2 * funcs.atan_ang((WIN3D.dX / float(WIN3D.dY)) * funcs.tan_ang(0.5 * WIN3D.Zoom)), 0, 0);

  Command2 += " -vp " + nf(WIN3D.CAM_x / OBJECTS_scale, 0, 0) + " " + nf(WIN3D.CAM_y / OBJECTS_scale, 0, 0) + " " + nf(WIN3D.CAM_z / OBJECTS_scale, 0, 0);

  float dx = funcs.cos_ang(90 - WIN3D.rotation_X) * funcs.cos_ang(90 - WIN3D.rotation_Z);
  float dy = funcs.cos_ang(90 - WIN3D.rotation_X) * funcs.sin_ang(90 - WIN3D.rotation_Z);
  float dz = funcs.sin_ang(90 - WIN3D.rotation_X);

  Command2 += " -vd " + nf(-dx , 0, 0) + " " + nf(dy, 0, 0) + " " + nf(-dz, 0, 0);

  float ux = 0;
  float uy = 0;
  float uz = 1;
  if (abs(dz) > 0.99) {
    ux = funcs.cos_ang(90 + WIN3D.rotation_Z);
    uy = funcs.sin_ang(90 + WIN3D.rotation_Z);
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


}
