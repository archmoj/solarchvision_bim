void SOLARCHVISION_export_objects_SCR () {

  String fileBasename = ProjectName;

  String scrFilename = Folder_Export3D + "/" + fileBasename + ".scr";

  PrintWriter scrOutput = createWriter(scrFilename);

  scrOutput.println("-osnap off");

  for (int f = 0; f < allFaces.nodes.length; f++) {

    if ((allFaces.nodes[f].length == 3) || (allFaces.nodes[f].length == 4)) {

      scrOutput.println("3dface");

      for (int j = 0; j < allFaces.nodes[f].length; j++) {

        float x = allPoints.getX(allFaces.nodes[f][j]);
        float y = allPoints.getY(allFaces.nodes[f][j]);
        float z = allPoints.getZ(allFaces.nodes[f][j]);

        scrOutput.println(nf(x, 0, User3D.export_PrecisionVertex) + "," + nf(y, 0, User3D.export_PrecisionVertex) + "," + nf(z, 0, User3D.export_PrecisionVertex));
      }
      scrOutput.println();
      scrOutput.println();
    }
  }

  for (int f = 0; f < allPolylines.nodes.length; f++) {

    scrOutput.println("line");

    for (int j = 0; j < allPolylines.nodes[f].length; j++) {

      float x = allPoints.getX(allPolylines.nodes[f][j]);
      float y = allPoints.getY(allPolylines.nodes[f][j]);
      float z = allPoints.getZ(allPolylines.nodes[f][j]);

      scrOutput.println(nf(x, 0, User3D.export_PrecisionVertex) + "," + nf(y, 0, User3D.export_PrecisionVertex) + "," + nf(z, 0, User3D.export_PrecisionVertex));
    }

    if (allPolylines.getMaterial(f) == 1) {
      scrOutput.println("c");
    }
    else {
      scrOutput.println();
    }
  }

  scrOutput.println("zoom e");

  scrOutput.flush();
  scrOutput.close();

  println("End of scripting lines and meshes.");

  println("File created:" + scrFilename);
}
