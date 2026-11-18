void draw_UI_layers () {
  if (isInProgress()) return;

  if(updateBars) {
    updateBars = false;
    UI_menuBar.revise();
    UI_toolBar.revise();
    UI_caseBar.revise();
    UI_consoleBar.revise();
  }

  if (UI_menuBar.update) UI_menuBar.draw();
  if (UI_toolBar.update) UI_toolBar.draw();
  if (UI_caseBar.update) UI_caseBar.draw();
  if (UI_consoleBar.update) UI_consoleBar.draw();

  // Drawn last (on top of everything else here, including the menu bar)
  // and unconditionally on every frame it's open - not gated by an
  // .update flag like the others above - since the hover text under the
  // mouse needs to track mouseX/mouseY continuously, not just on the
  // frames something else happened to flag a redraw.
  if (UI_keyboardMap.visible) UI_keyboardMap.draw();
  if (UI_mouseGuide.visible) UI_mouseGuide.draw();
}
