PrintWriter htmlOutput;

void SOLARCHVISION_export_objects_HTML () {

  String fileBasename = ProjectName;

  String htmlFilename = Folder_Export3D + "/" + fileBasename + ".html";

  htmlOutput = createWriter(htmlFilename);

  htmlOutput.println("<html>");
  htmlOutput.println("\t<head>");
  htmlOutput.println("\t\t<title>" + ProjectName + "</title>");
  htmlOutput.println("\t\t<script type='text/javascript' src='https://www.x3dom.org/download/x3dom.js'></script>");
  htmlOutput.println("\t\t<link rel='stylesheet' type='text/css' href='https://www.x3dom.org/download/x3dom.css'></link>");
  htmlOutput.println("\t</head>");
  htmlOutput.println("\t<body>");
  htmlOutput.println("\t\t<x3d width='900px' height='600px'>");
  htmlOutput.println("\t\t\t<scene>");

  htmlOutput.println("\t\t\t\t<viewpoint position='0 0 100'></Viewpoint>");
/*
{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM00'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}


{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM01'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_X * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}

{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM02'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}


{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM03'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_X * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}


{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM04'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}

{
  htmlOutput.print  ("\t\t\t\t<viewpoint id='CAM05'");
  htmlOutput.print  (" position='" + nf(WIN3D.CAM_x, 0, 0) + " " + nf(WIN3D.CAM_y, 0, 0) + " " + nf(WIN3D.CAM_z, 0, 0) + "'");

  float c1 = funcs.cos_ang(WIN3D.rotation_Y * 0.5);
  float s1 = funcs.sin_ang(WIN3D.rotation_Y * 0.5);
  float c2 = funcs.cos_ang(WIN3D.rotation_X * 0.5);
  float s2 = funcs.sin_ang(WIN3D.rotation_X * 0.5);
  float c3 = funcs.cos_ang(WIN3D.rotation_Z * 0.5);
  float s3 = funcs.sin_ang(WIN3D.rotation_Z * 0.5);

  float qw = c1*c2*c3 + s1*s2*s3;
  float qx = s1*s2*c3 - c1*c2*s3;
  float qy = s1*c2*c3 + c1*s2*s3;
  float qz = c1*s2*c3 - s1*c2*s3;

  htmlOutput.print  (" orientation='" + nf(qw, 0, 0) + " " + nf(qx, 0, 0) + " " + nf(qy, 0, 0) + " " + nf(qz, 0, 0) + "'");
  htmlOutput.println("></Viewpoint>");
}
*/


  // Earth3D.draw(TypeWindow.HTML);

  // Land3D.draw(TypeWindow.HTML);

  // Tropo3D.draw(TypeWindow.HTML);

  allSections.draw(TypeWindow.HTML);

  allModel2Ds.draw(TypeWindow.HTML);

  allFaces.draw(TypeWindow.HTML);





  htmlOutput.println("\t\t\t</scene>");
  htmlOutput.println("\t\t</x3d>");

/*
  htmlOutput.println("\t\t<div id='camera_buttons' style='display: block;'>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM00').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM00<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM01').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM01<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM02').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM02<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM03').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM03<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM04').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM04<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t\t<button  onclick=\"document.getElementById('CAM05').setAttribute('set_bind","true');\" style='border: none; background: transparent; display: block'>CAM05<br><img src='camera.png'></button>");
  htmlOutput.println("\t\t</div>");
*/

  htmlOutput.println("\t</body>");
  htmlOutput.println("</html>");

  htmlOutput.flush();
  htmlOutput.close();

  println("End of creating html file.");

  println("File created:" + htmlFilename);

}
