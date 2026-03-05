void SOLARCHVISION_export_objects_OBJ (String suffix) {

  String fileBasename = ProjectName + suffix;

  String objFilename = Folder_Export3D + "/" + fileBasename + ".obj";
  String mtlFilename = Folder_Export3D + "/" + fileBasename + ".mtl";


  if (User3D.export_MaterialLibrary) {
    mtlOutput = createWriter(mtlFilename);
    mtlOutput.println("#SOLARCHVISION");
  }

  objOutput = createWriter(objFilename);
  objOutput.println("#SOLARCHVISION");
  if (User3D.export_MaterialLibrary) {
    objOutput.println("mtllib " + fileBasename + ".mtl");
  }

  obj_lastVertexNumber = 0;
  obj_lastVtextureNumber = 0;
  obj_lastFaceNumber = 0;
  obj_lastGroupNumber = 0;






  Earth3D.draw(TypeWindow.OBJ3D);

  Land3D.draw(TypeWindow.OBJ3D);

  Tropo3D.draw(TypeWindow.OBJ3D);

  allSections.draw(TypeWindow.OBJ3D);

  allModel1Ds.draw(TypeWindow.OBJ3D);

  allModel2Ds.draw(TypeWindow.OBJ3D);

  allFaces.draw(TypeWindow.OBJ3D);

  allWindFlows.draw(TypeWindow.OBJ3D);

  Sky3D.draw(TypeWindow.OBJ3D);

  if (Sun3D.displayPattern) {

    float keep_STUDY_perDays = STUDY.perDays;
    int keep_STUDY_joinDays = STUDY.joinDays;
    if ((CurrentDataSource == dataID_ENSEMBLE_FORECAST) ||
        (CurrentDataSource == dataID_ENSEMBLE_OBSERVED)) {
      STUDY.perDays = 1;
      STUDY.joinDays = 1;
    }

    float previous_DATE = TIME.date;

    Sun3D.drawCycles(TypeWindow.STUDY, 0, 0, 0, 0.975 * Sky3D.scale);

    STUDY.perDays = keep_STUDY_perDays;
    STUDY.joinDays = keep_STUDY_joinDays;
    TIME.date = previous_DATE;
    TIME.updateDate();
  }

  if (User3D.export_MaterialLibrary) {
    mtlOutput.flush();
    mtlOutput.close();
  }

  objOutput.flush();
  objOutput.close();


  println("End of exporting the mesh.");

  println("File created:" + objFilename);
}
