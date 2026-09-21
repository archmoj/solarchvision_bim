void SOLARCHVISION_exportObj_timeSeries () {

  int keep_STUDY_i_Start = STUDY.i_Start;

  for (int i = 0; i < 24; i++) {

    STUDY.i_Start = i;

    SOLARCHVISION_find_which_bakings_to_regenerate();
    SOLARCHVISION_regenerate_desired_bakings();


    SOLARCHVISION_exportObj("_" + nf(i, 2));

  }

  STUDY.i_Start = keep_STUDY_i_Start;
}
