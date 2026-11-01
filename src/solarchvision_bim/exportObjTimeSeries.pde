void exportObj_timeSeries () {

  int keep_STUDY_startHour = STUDY.startHour;

  for (int i = 0; i < 24; i++) {

    STUDY.startHour = i;

    find_which_bakings_to_regenerate();
    regenerate_desired_bakings();


    exportObj("_" + nf(i, 2));

  }

  STUDY.startHour = keep_STUDY_startHour;
}
