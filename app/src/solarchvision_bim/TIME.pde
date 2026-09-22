class TIME {

  final static String CLASS_STAMP = "TIME";

  int modelRun = 0; //12;

  int hour = this.modelRun; //hour();
  int year = year();
  int month = month(); //1;
  int day = day(); //21;

  int beginDay;
  float date;

  final int interval = 1; //dT


  final String[][] WORDS = {
    {
      "", ""
    }
    ,
    {
      "at hour", "à l'heure"
    }
    ,
    {
      "day", "jour"
    }
    ,
    {
      "month", "mois"
    }
    ,
    {
      "year", "année"
    }
    ,
    {
      "date", "date"
    }
  };


  final String[][] namesOfMonths = {
    {
      "January", "janvier"
    }
    ,
    {
      "February", "février"
    }
    ,
    {
      "March", "mars"
    }
    ,
    {
      "April", "avril"
    }
    ,
    {
      "May", "mai"
    }
    ,
    {
      "June", "juin"
    }
    ,
    {
      "July", "juillet"
    }
    ,
    {
      "August", "août"
    }
    ,
    {
      "September", "septembre"
    }
    ,
    {
      "October", "octobre"
    }
    ,
    {
      "November", "novembre"
    }
    ,
    {
      "December", "décembre"
    }
  };

  final int[] lengthOfMonths = {
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
  };

  int[] monthFromDate = new int [365];
  int[] dayFromDate = new int [365];
  String[] MM = new String [365];
  String[] MMDD = new String [365];
  String[][] dayOfYear = new String [365][numberOfLanguages];

  int safeDate(float date_IN) {
    return floor(0.001 + (365 + date_IN) % 365);
  }

  int getMonth_fromDate(float date_IN) {
     return this.monthFromDate[safeDate(date_IN)];
  }

  int getDay_fromDate(float date_IN) {
     return this.dayFromDate[safeDate(date_IN)];
  }

  String getDayText(float date_IN) {
    return this.dayOfYear[safeDate(date_IN)][Language_Active];
  }

  String getMMDD(float date_IN) {
    return this.MMDD[safeDate(date_IN)];
  }

  String getMM(float date_IN) {
    return this.MM[safeDate(date_IN)];
  }

  TIME () { // constructor
    this.createCalendar();
  }

  void createCalendar () {
    int k = 285;

    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < this.lengthOfMonths[i]; j++) {
        k += 1;
        if (k == 365) k = 0;

        this.monthFromDate[k] = i + 1;
        this.dayFromDate[k] = j + 1;

        this.MM[k] = nf(i + 1, 2);
        this.MMDD[k] = nf(i + 1, 2) + nf(j + 1, 2);

        for (int l = 0; l < numberOfLanguages; l++) {
          this.dayOfYear[k][l] = this.namesOfMonths[i][l] + " " + nf(j + 1, 0);
        }
      }
    }
  }

  int convert2Day (int Date_Angle) {
    int DAY = (Date_Angle + 360) % 360;
    if (DAY >=  31) DAY++;
    if (DAY >=  62) DAY++;
    if (DAY >=  93) DAY++;
    if (DAY >= 124) DAY++;
    if (DAY >= 155) DAY++;
    DAY = DAY % 365;
    return DAY;
  }

  int convert2Date (int month, int day) {
    int k = 0;
    for (int i = 0; i < (month - 1); i++) {
      for (int j = 0; j < this.lengthOfMonths[i]; j++) {
        k += 1;
        if (k == 365) k = 0;
      }
    }
    k += day - 1;

    k = k % 365;
    return k;
  }

  void updateDate () {
    this.month = this.getMonth_fromDate(this.date);
    this.day = this.getDay_fromDate(this.date);
    this.hour = int(24 * (this.date - int(this.date)));
  }


  public void to_XML (XML xml) {

    //printlnSaving(this.CLASS_STAMP);

    XML parent = xml.addChild(this.CLASS_STAMP);

    XML_setInt(parent, "modelRun", this.modelRun);
    XML_setInt(parent, "year", this.year);
    XML_setInt(parent, "month", this.month);
    XML_setInt(parent, "day", this.day);
    XML_setInt(parent, "hour", this.hour);
    XML_setInt(parent, "beginDay", this.beginDay);
    XML_setFloat(parent, "date", this.date);
  }


  public void from_XML (XML xml) {

    //println("Loading:" + this.CLASS_STAMP);

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.modelRun = XML_getInt(parent, "modelRun");
    this.year = XML_getInt(parent, "year");
    this.month = XML_getInt(parent, "month");
    this.day = XML_getInt(parent, "day");
    this.hour = XML_getInt(parent, "hour");
    this.beginDay = XML_getInt(parent, "beginDay");
    this.date = XML_getFloat(parent, "date");
  }

}
