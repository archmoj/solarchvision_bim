void mouseMoved () {

  // See mouseClicked()'s own identical guard for why. Mouseover state
  // (menu hover, mainly, in this function) is lower-risk than a click/
  // drag that actually edits geometry, but still reads things like
  // UI_menuBar's own selection state that a concurrent import has no
  // business racing against either - same guard, for consistency with
  // every other interaction entry point.
  if (isInProgress()) return;

  if (frameCount > Last_initializationStep) {

    if (control == USER_GUI) {

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
