void SOLARCHVISION_export_objects_OBJ_dateSeries () {

  int keep_IMPACTS_displayDay = IMPACTS_displayDay;

  for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {

    IMPACTS_displayDay = j;

    SOLARCHVISION_export_objects_OBJ("_" + nf(j, 3));

  }

  IMPACTS_displayDay = keep_IMPACTS_displayDay;
}
