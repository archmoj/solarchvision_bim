void GlobalSolar_resize_array () {

  Sky3D.stp_slp = Sky3D.calculatedResolution;
  Sky3D.stp_dir = Sky3D.calculatedResolution;
  Sky3D.num_slp = int(funcs.roundTo(180.0 / (1.0 * Sky3D.stp_slp), 1)) + 1;
  Sky3D.num_dir = int(funcs.roundTo(360.0 / (1.0 * Sky3D.stp_dir), 1));

  GlobalSolar = new float [2][(1 + STUDY.j_End - STUDY.j_Start)][Sky3D.num_slp][Sky3D.num_dir];

  for (int i = 0; i < GlobalSolar.length; i++) {
    for (int j = 0; j < GlobalSolar[i].length; j++) {

      for (int a = 0; a < Sky3D.num_slp; a++) {
        for (int b = 0; b < Sky3D.num_dir; b++) {
          GlobalSolar[i][j][a][b] = FLOAT_undefined;
        }
      }
    }
  }

  GlobalSolar_rebuild_array = false;
}
