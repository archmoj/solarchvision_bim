void draw_UI_layers () {
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
}
