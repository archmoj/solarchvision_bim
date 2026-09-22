boolean draw_initial_frames () {
  if (frameCount == 1) {

    background(223);

    update_project_folders();

    float cr;

    cr = pixel_H / 2;
    //PImage logo = loadImage(BaseFolder + "/input/images/logo/SOLARCHVISION.jpg");
    //imageMode(CENTER);
    //image(logo, 0.5 * width, 0.5 * height - cr + (0.075 * cr), 3.05 * cr, 3.05 * cr);
    imageMode(CORNER);

    strokeWeight(1);
    stroke(0);
    noFill();

    ellipseMode(CENTER);

    strokeWeight(0);
    stroke(191);
    fill(191);
    ellipse(0.2 * width, 0.5 * height - cr, 2 * cr, 2 * cr);

    draw_logo(0.2 * width, 0.5 * height - cr, 0, cr, 1, 1);
    strokeWeight(2);
    stroke(0);
    noFill();
    ellipse(0.2 * width, 0.5 * height - cr, 2 * cr, 2 * cr);

    draw_logo(0.5 * width, 0.5 * height - cr, 0, cr, 0, 1);
    draw_logo(0.5 * width, 0.5 * height - cr, 0, cr, 0, 2);
    strokeWeight(2);
    stroke(0);
    noFill();
    ellipse(0.5 * width, 0.5 * height - cr, 2 * cr, 2 * cr);

    strokeWeight(0);
    stroke(191);
    fill(191);
    ellipse(0.8 * width, 0.5 * height - cr, 2 * cr, 2 * cr);

    draw_logo(0.8 * width, 0.5 * height - cr, 0, cr, -1, 1);
    strokeWeight(2);
    stroke(0);
    noFill();
    ellipse(0.8 * width, 0.5 * height - cr, 2 * cr, 2 * cr);

    strokeWeight(0);

    stroke(255);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(3 * MessageSize);
    text(version + " model integrations (BIM-6D)", 0.5 * width, 0.05 * height);

    stroke(0);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(3 * MessageSize);
    text("SOLARCHVISION", 0.5 * width, 0.6 * height);

    stroke(0);
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(1.5 * MessageSize);
    text("Raz, Mehr, Mehraz solarch studio\n1998-" + version + "\nAuthor: Mojtaba Samimi\nwww.solarchvision.com", 0.5 * width, 0.75 * height);

    textAlign(CENTER, CENTER);
    textSize(1.25 * MessageSize);
  } else if (frameCount == 2) {
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("WORLD.listAllImages", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 3) {
    WORLD.listAllImages();
    WORLD.loadImages(WORLD.VIEW_id); // to load the globe image into memory

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Model2Ds.load_images", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 4) {
    allModel2Ds.load_images();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_SWOB", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 5) {
    inputCoordinates_SWOB();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_NAEFS", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 6) {
    inputCoordinates_NAEFS();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_CWEEDS", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 7) {
    inputCoordinates_CWEEDS();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_CLMREC", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 8) {
    inputCoordinates_CLMREC();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("inputCoordinates_TMYEPW", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 9) {
    inputCoordinates_TMYEPW();
    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("TIME.updateDate", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 10) {
    TIME.updateDate();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("load .env file", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 11) {
    load_env();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_station(start)", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 12) {
    update_station(0);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_CLIMATE_TMYEPW", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 13) {
    update_station(1);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_CLIMATE_CWEEDS", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 14) {
    update_station(2);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_CLIMATE_CLMREC", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 15) {
    update_station(3);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_ENSEMBLE_OBSERVED", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 16) {
    update_station(4);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("update_ENSEMBLE_FORECAST", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 17) {
    update_station(5);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Land3D.update_mesh", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 18) {
    update_station(6);

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Earth3D.load_images", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 19) {
    Earth3D.load_images();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Tropo3D.load_images", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 20) {
    Tropo3D.load_images();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("build_SkySphere", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);
  } else if (frameCount == 21) {

    build_SkySphere(1); //1 - 3
    GlobalSolar_resize_array();
    VertexSolar_resize_array();

    stroke(0); fill(0); rect(MESSAGE.cX, MESSAGE.cY, MESSAGE.dX, MESSAGE.dY);

    stroke(255); fill(255); text("Please wait while integrating the models.", MESSAGE.cX + 0.5 * MESSAGE.dX, MESSAGE.cY + 0.5 * MESSAGE.dY);

    MESSAGE.dX = 2 * pixel_W;

    X_clicked = -1;
    Y_clicked = -1;

    UI_menuBar.revise();
    UI_toolBar.revise();
    UI_caseBar.revise();
    UI_consoleBar.revise();

    InitializationStep = frameCount;
    Last_initializationStep = frameCount;
  } else {
    return false;
  }
  return true;
}