void load_project (String myFile) {

  myFile = myFile.replace(char(92), '/');


  boolean continue_process = true;

  XML xml = parseXML("<?xml version='1.0' encoding='UTF-8'?>" + char(13) + "<empty>" + char(13) + "</empty>");

  try {
    xml = loadXML(myFile);
  }
  catch (Exception e) {
    println("Can't read:", myFile);
    continue_process = false;
  }

  if (continue_process) {

    try {
      parse_XML_variables(xml, false); // first try: loading without printing logs
    }
    catch (Exception e) {
      println("Problem loading variables:", myFile);

      parse_XML_variables(xml, true); // second try with printing logs
      System.exit(1);
    }

    // loading only weather data //
    update_station(1);
    update_station(2);
    update_station(3);
    update_station(4);
    ///////////////////////////////

    addNewSelectionToPreviousSelection = 0;

    addToLastGroup = false;

    UI_setTo_Create_Nothing();

    WORLD.autoView = true;

    WORLD.VIEW_id = WORLD.FindGoodViewport(LocationLON, LocationLAT);

    update_frame_layout();

    UI_rollout.revise();
    WORLD.revise();
    STUDY.revise();
    UI_menuBar.revise();
    UI_toolBar.revise();
    UI_caseBar.revise();
    view_changed();


    allSolarImpacts.rebuild_Image_array = true;
    allWindRoses.rebuild_Image_array = true;

    if (WIN3D.FacesShade == SHADE.Vertex_Solar) VertexSolar_rebuild_array = true;
    if (WIN3D.FacesShade == SHADE.Global_Solar) GlobalSolar_rebuild_array = true;

    VertexSolar_resize_array();
    GlobalSolar_resize_array();


    modify_Viewport_Title();
  }

}
