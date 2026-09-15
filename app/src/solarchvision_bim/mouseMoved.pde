void mouseMoved () {

  if (frameCount > Last_initializationStep) {

    if (SOLARCHVISION_automated == 0) {

      if (UI_menuBar.selected_parent != -1) {

        if ((UI_X_moved != mouseX) || (UI_Y_moved != mouseY)) {

          UI_X_moved = mouseX;
          UI_Y_moved = mouseY;

          UI_menuBar.revise();

          redraw();
        }
      }
    }
  }
}
