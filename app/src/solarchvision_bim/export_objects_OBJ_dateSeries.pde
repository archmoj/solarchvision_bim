void exportObj_dateSeries () {

  int keep_impactDisplayDay = impactDisplayDay;

  for (int j = STUDY.j_Start; j <= STUDY.j_End; j++) {

    impactDisplayDay = j;

    exportObj("_" + nf(j, 3));

  }

  impactDisplayDay = keep_impactDisplayDay;
}
