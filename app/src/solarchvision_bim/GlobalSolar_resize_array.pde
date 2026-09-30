void GlobalSolar_resize_array () {

  Sky3D.inclinationStep = Sky3D.calculatedResolution;
  Sky3D.orientationStep = Sky3D.calculatedResolution;

  Sky3D.inclinationCount = int(funcs.roundTo(180.0 / (1.0 * Sky3D.inclinationStep), 1)) + 1;
  Sky3D.orientationCount = int(funcs.roundTo(360.0 / (1.0 * Sky3D.orientationStep), 1));

  int jCount = 1 + STUDY.endDay - STUDY.startDay;

  GlobalSolar = new float [2][jCount][Sky3D.inclinationCount][Sky3D.orientationCount];

  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < jCount; j++) {
      for (int a = 0; a < Sky3D.inclinationCount; a++) {
        java.util.Arrays.fill(GlobalSolar[i][j][a], FLOAT_undefined);
      }
    }
  }

  GlobalSolar_rebuild_array = false;
}
