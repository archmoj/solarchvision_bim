void exportObj_dateSeries () {

  int keep_impactDisplayDay = impactDisplayDay;

  for (int j = STUDY.startDay; j <= STUDY.endDay; j++) {

    impactDisplayDay = j;

    exportObj("_" + nf(j, 3));

  }

  impactDisplayDay = keep_impactDisplayDay;
}
