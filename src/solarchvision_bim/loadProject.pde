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

    // parse_XML_variables() reaches beginModel3DChange()/endModel3DChange()
    // repeatedly on its own (several classes' from_XML() -> makeEmpty(),
    // each now its own complete begin/end pair - see those classes' own
    // comments), the exact same cascade undoRedo.pde's
    // restoreProjectModel3DSnapshot() already guards against with
    // isRestoringModel3DSnapshot - but this function is Open/Fetch's own
    // "restore everything from XML" path, not that one, and had no
    // equivalent guard: opening or fetching ANY project was recording
    // several spurious, partially-loaded undo-history entries, one per
    // class's own makeEmpty() call, exactly the kind of corruption
    // isRestoringModel3DSnapshot exists to prevent - just via a different
    // caller than the one it was first written for.
    isRestoringModel3DSnapshot = true;
    try {
      try {
        parse_XML_variables(xml, false, true); // first try: loading without printing logs
      }
      catch (Exception e) {
        println("Problem loading variables:", myFile);

        parse_XML_variables(xml, true, true); // second try with printing logs
        System.exit(1);
      }
    } finally {
      isRestoringModel3DSnapshot = false;
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

    WORLD.VIEW_id = WORLD.FindGoodViewport(locationLongitude, locationLatitude);

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

    find_which_bakings_to_regenerate();

    VertexSolar_resize_array();
    GlobalSolar_resize_array();


    modify_Viewport_Title();

    // Resolves undoRedo.pde's own previously-open question ("should
    // New/Open/Fetch clear and reseed this history") - now that a
    // different project's own content just fully replaced whatever was
    // live before, the undo history needs to start fresh from exactly
    // this state, not keep referring to the previous project's: without
    // this, pressing Ctrl+Z right after opening a different file could
    // try to restore a snapshot that belongs to the project that was
    // open before it.
    seedModel3DHistory();
  }

}
