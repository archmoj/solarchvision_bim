void exportObj_timeSeries () {

  int keep_STUDY_i_Start = STUDY.i_Start;

  for (int i = 0; i < 24; i++) {

    STUDY.i_Start = i;

    find_which_bakings_to_regenerate();
    regenerate_desired_bakings();


    exportObj("_" + nf(i, 2));

  }

  STUDY.i_Start = keep_STUDY_i_Start;
}
