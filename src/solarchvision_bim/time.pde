class TIME {

  final static String CLASS_STAMP = "time";

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

  // Feb is fixed at 29, not a real-year-aware 28/29 - this is a single
  // generic 366-day calendar used for every real year alike (leap or
  // not), not a per-year Gregorian one. A Feb-29 slot that a given real
  // (non-leap) year's source data never fills in simply stays
  // undefined/empty for that year - see e.g. load_climateArchive() -
  // rather than colliding with and silently overwriting Mar 1's slot,
  // which is what a 365-slot calendar did before this.
  final int[] lengthOfMonths = {
    31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
  };

  int[] monthFromDate = new int [366];
  int[] dayFromDate = new int [366];
  String[] MM = new String [366];
  String[] MMDD = new String [366];
  String[][] dayOfYear = new String [366][numberOfLanguages];

  int safeDate(float date_IN) {
    return floor(0.001 + (366 + date_IN) % 366);
  }

  // Step 4a of the real-Gregorian-year plan: this.year already exists
  // (see the field above and its spinner in valueModifier.pde / XML
  // round-trip below) but today it is purely a decorative/lookup-key
  // tag - it is passed to the ensemble-observation/forecast fetch
  // functions and used in saved-image/file names, and nothing checks
  // it for validity or ties it to this.month/this.day, which are
  // instead derived from the generic 366-day calendar via updateDate()
  // and never consult this.year at all. isLeapYear() is pure groundwork
  // for that gap: the standard Gregorian rule, with no side effects and
  // no callers yet, so it changes no existing behavior. Real-year leap
  // arithmetic (deriving an actual real-year day-of-year/weekday from
  // it, and validating e.g. a Feb 29 pick against it) is step 4b; the
  // conversion between this and the generic 366-slot index is step 4c.
  boolean isLeapYear (int year_IN) {
    return (year_IN % 4 == 0 && year_IN % 100 != 0) || (year_IN % 400 == 0);
  }

  // Step 4b of the real-Gregorian-year plan, building on isLeapYear
  // (4a). These are still pure and still have no callers in the app
  // yet - the generic<->real conversion layer (4c) and decoupling
  // solar geometry (4d) are what will actually call them. They are
  // deliberately kept independent of this.lengthOfMonths (the generic
  // calendar's fixed Feb=29 table): a *real* year's February is 28 or
  // 29 days depending on isLeapYear(year), never a fixed 29.

  // Real (non-generic) month length: every month matches the generic
  // lengthOfMonths table except February, which is real-year-aware
  // (28 in a common year, 29 in a leap year) rather than the generic
  // calendar's fixed 29.
  int lengthOfMonthInRealYear (int year_IN, int month_IN) {
    if (month_IN == 2) return this.isLeapYear(year_IN) ? 29 : 28;
    return this.lengthOfMonths[month_IN - 1];
  }

  // A real calendar date is valid exactly when month is 1..12 and day
  // is 1..lengthOfMonthInRealYear(year, month) for that specific real
  // year - this is the "Feb 29 validation" from the plan: it falls
  // directly out of this general check (true only in a leap year)
  // rather than needing its own separate special case.
  boolean isValidRealDate (int year_IN, int month_IN, int day_IN) {
    if (month_IN < 1 || month_IN > 12) return false;
    return day_IN >= 1 && day_IN <= this.lengthOfMonthInRealYear(year_IN, month_IN);
  }

  // 1-based real day-of-year (1..365, or 1..366 in a leap year) for a
  // *valid* real calendar date - callers are expected to have checked
  // isValidRealDate first; behavior for an invalid (year, month, day)
  // is not defined here.
  int dayOfYearInRealYear (int year_IN, int month_IN, int day_IN) {
    int total = day_IN;
    for (int i = 0; i < month_IN - 1; i++) {
      total += this.lengthOfMonthInRealYear(year_IN, i + 1);
    }
    return total;
  }

  // Days since the 1970-01-01 civil (Unix) epoch for a proleptic
  // Gregorian date, via Howard Hinnant's widely-used days_from_civil
  // algorithm (see http://howardhinnant.github.io/date_algorithms.html)
  // - correct for every year this app's real-year field can hold,
  // including the 100/400-year leap exceptions. Deliberately a fully
  // independent derivation of the same leap structure (not composed
  // from lengthOfMonthInRealYear above), used as the base for the
  // weekday arithmetic below.
  long daysFromRealCivilEpoch (int year_IN, int month_IN, int day_IN) {
    int y = year_IN - (month_IN <= 2 ? 1 : 0);
    long era = (y >= 0 ? y : y - 399) / 400;
    long yoe = y - era * 400;                                                     // [0, 399]
    long doy = (153 * (month_IN + (month_IN > 2 ? -3 : 9)) + 2) / 5 + day_IN - 1;  // [0, 365]
    long doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;                             // [0, 146096]
    return era * 146097L + doe - 719468L;
  }

  // 0=Sunday .. 6=Saturday, derived from daysFromRealCivilEpoch above:
  // 1970-01-01 (epoch day 0) was a Thursday, i.e. weekday index 4, so
  // adding 4 and wrapping into 0..6 (Java's % keeps the dividend's
  // sign, hence the extra "+ 7" before the final "% 7" so a date
  // before 1970 still wraps forward rather than coming out negative)
  // gives every other date's weekday.
  int weekdayFromRealDate (int year_IN, int month_IN, int day_IN) {
    long days = this.daysFromRealCivilEpoch(year_IN, month_IN, day_IN);
    return (int) (((days + 4) % 7 + 7) % 7);
  }

  int getMonth_fromDate(float date_IN) {
     return this.monthFromDate[safeDate(date_IN)];
  }

  int getDay_fromDate(float date_IN) {
     return this.dayFromDate[safeDate(date_IN)];
  }

  String getDayText(float date_IN) {
    return this.dayOfYear[safeDate(date_IN)][activeLanguage];
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

  // k starts at 285 so the first assignment below (Jan 1) lands at table
  // index 286, which is also lengthOfMonths-independent (it's always
  // "days from Mar 21 to Dec 31 inclusive", 306 - 20 = 286, with
  // February's own length appearing on both sides of that subtraction
  // and cancelling out) - so table index 0 always lands on Mar 21
  // (the generic-calendar equinox reference every DATE_ANGLE site in
  // this app is built from) whether lengthOfMonths[1] is 28 or 29.
  void createCalendar () {
    int k = 285;

    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < this.lengthOfMonths[i]; j++) {
        k += 1;
        if (k == 366) k = 0;

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

  // NOTE: not called anywhere in this app (confirmed by grep - only
  // its own test exercises it) and NOT updated for the 365->366 change
  // below, so its own "% 365" and its 5 inserted-day thresholds (a
  // degrees-to-days approximation for the old 365-day generic year)
  // are now stale relative to the rest of this class. Left alone
  // rather than guessing new thresholds for dead code; revisit
  // (recalibrate for 366, or remove) if something ever actually calls
  // this.
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
        if (k == 366) k = 0;
      }
    }
    k += day - 1;

    k = k % 366;
    return k;
  }

  // Step 4c of the real-Gregorian-year plan: the explicit, tested
  // conversion layer between a specific real calendar year (built on
  // isLeapYear/isValidRealDate, 4a/4b above) and the generic 0..365,
  // Jan-1-is-0 day-of-year index that convert2Date() above already
  // produces - this is NOT a new index space. convert2Date() is
  // already exactly how the rest of this app keys climate/ensemble
  // storage off a (month, day) pair (see its own callers in
  // loadClimateArchive.pde, loadClimateEngineering.pde,
  // loadClimateTypicalYear.pde, loadEnsembleObservation.pde,
  // loadEnsembleForecast.pde, updateEnsembleObservation.pde,
  // updateStation.pde, react.pde, solarchvision_bim.pde and
  // tropo3D.pde), it just has no year parameter and performs no
  // validation today - so e.g. convert2Date(2, 29) always silently
  // succeeds, in every real year alike, because the generic calendar
  // always has a Feb 29 slot (lengthOfMonths[1] == 29, see above).
  // These two functions are what make that gap explicit and checkable.

  // Inverse of convert2Date(): given a generic 0..365 Jan-1-is-0
  // day-of-year index, returns the {month, day} it corresponds to.
  // Walks the exact same lengthOfMonths table in the exact same order
  // as convert2Date()'s own forward loop (rather than a separately
  // maintained formula), so the two stay in lock-step by construction.
  // Routed through safeDate() first for the same out-of-range wrap
  // behavior as getMonth_fromDate/getDay_fromDate above.
  int[] monthDayFromGenericIndex (int genericIndex_IN) {
    int remaining = this.safeDate(genericIndex_IN);
    for (int i = 0; i < 12; i++) {
      if (remaining < this.lengthOfMonths[i]) {
        return new int[] { i + 1, remaining + 1 };
      }
      remaining -= this.lengthOfMonths[i];
    }
    // unreachable: lengthOfMonths sums to exactly 366 and remaining
    // (from safeDate) is already in [0, 366)
    return new int[] { 12, 31 };
  }

  // Plain data holder for the generic-index -> real-date direction,
  // mirroring Tropo3D.DateTimeUTC's style: a generic index does not
  // always correspond to a real date in a given real year (the Feb 29
  // slot has no real counterpart in a non-leap year - the "undefined/
  // empty for that year" case named in the lengthOfMonths comment
  // above), so this carries an explicit valid flag rather than
  // returning a silently-wrong (year, month, day).
  class RealDate {
    int year, month, day;
    boolean valid;
  }

  // real (year, month, day) -> generic index, with the year-aware
  // validation convert2Date() alone does not do. Every *valid* real
  // date already has a slot in the generic table (the generic
  // calendar's month lengths equal the real ones for every month
  // except February, where the generic table's fixed 29 is a superset
  // of a real Feb's 28 or 29), so once isValidRealDate (4b) passes,
  // this simply delegates to the existing convert2Date(). Returns -1
  // for an invalid real date (most notably Feb 29 in a non-leap year)
  // instead of the silent wrong answer convert2Date() alone would give.
  int genericIndexFromRealDate (int year_IN, int month_IN, int day_IN) {
    if (!this.isValidRealDate(year_IN, month_IN, day_IN)) return -1;
    return this.convert2Date(month_IN, day_IN);
  }

  // generic index -> real (year, month, day) for a specific target
  // real year. See RealDate above for why this can come back invalid.
  RealDate realDateFromGenericIndex (int genericIndex_IN, int year_IN) {
    int[] monthDay = this.monthDayFromGenericIndex(genericIndex_IN);
    RealDate result = new RealDate();
    result.year = year_IN;
    result.month = monthDay[0];
    result.day = monthDay[1];
    result.valid = this.isValidRealDate(year_IN, result.month, result.day);
    return result;
  }

  // Step 4d of the real-Gregorian-year plan: the actual Kepler/
  // eccentricity accuracy fix. Replaces this function's first version
  // (a linear days-from-equinox/real-year-length interpolation) with
  // a second, deliberately non-uniform one, after discussing the
  // physics behind this app's own DATE_ANGLE convention: the Sun sits
  // at one focus of Earth's elliptical orbit, not at its center, so
  // by Kepler's second law (equal areas swept in equal times) Earth
  // moves faster near perihelion (~early Jan) and slower near
  // aphelion (~early Jul) - the Sun's true ecliptic longitude does
  // NOT advance uniformly with calendar time. The traditional Persian
  // (Solar Hijri) calendar compensates for exactly this by giving the
  // slow half of the year longer (31-day) months and the fast half
  // shorter (29/30-day) months, so each calendar month is
  // (approximately) an equal 30 degree step in the Sun's true
  // position despite covering a different number of real days -
  // which is the whole reason every DATE_ANGLE site in this app
  // (sync_SHADE_DATE_ANGLE() in shadeViewport3D.pde, and the many
  // "(360 * ((286 + j) % 366) / 366.0)" sites in
  // calculateGlobalSolarArray.pde, calculateVertexSolarArray.pde,
  // postProcessClimaticSolarForecast.pde, postProcessSolarsUsingCloud.pde,
  // postProcessDevelopData.pde and sun3D.pde) is anchored at the Mar
  // 21 equinox in the first place - that anchor is the one piece of
  // the Persian-calendar design already present. The month-length
  // asymmetry that was supposed to go with it was not: lengthOfMonths
  // above (Table A) is the ordinary Gregorian pattern, re-walked from
  // Mar 21 rather than Jan 1, which is why every existing DATE_ANGLE
  // site still only has the linear, uniform approximation.
  //
  // persianMonthLength (Table B) below is a second, independent
  // month-length table existing deliberately alongside Table A rather
  // than replacing it: Table A keeps doing exactly what it already
  // does (real-date validation in lengthOfMonthInRealYear/
  // isValidRealDate above, and every climate-mode DATE_ANGLE site,
  // which aggregates over the whole generic 366-slot statistical year
  // and has no one real year to anchor a Persian conversion to
  // anyway). Table B exists purely to drive this one function, for
  // "planning mode" (a single selected real date) once it is wired
  // in - still a separate, open decision (see below), not resolved by
  // adding Table B itself.

  // Table B: Persian/Solar-Hijri-pattern month lengths, walked from
  // the Mar-21 equinox (position 0), NOT indexed by Gregorian month
  // like lengthOfMonths (Table A) above. Six 31-day positions (the
  // slow, aphelion half: Mar..Aug), five 30-day positions (the fast,
  // perihelion half: Sep..Jan), and one flexible last position (the
  // Esfand-equivalent, immediately before the next Nowruz) sized
  // isLeapYear(year) ? 30 : 29 - the same real-Gregorian leap rule
  // isValidRealDate/lengthOfMonthInRealYear already apply to real
  // Feb's own 28/29 split above, just +1 day on both sides, so the 12
  // positions sum to exactly this real year's own true length (365 or
  // 366) in every case, by construction.
  int persianMonthLength (int positionFromEquinox_IN, int year_IN) {
    if (positionFromEquinox_IN < 6) return 31;   // Mar..Aug: the slow (aphelion) half
    if (positionFromEquinox_IN < 11) return 30;  // Sep..Jan: the fast (perihelion) half
    return this.isLeapYear(year_IN) ? 30 : 29;   // the 12th/last position - the one flexible slot
  }

  // Computes DATE_ANGLE for a real (year, month, day) by walking
  // persianMonthLength (Table B) above, crediting a full 30 degrees
  // for each complete Persian-pattern position already passed since
  // the real Mar-21 equinox of this real year, and interpolating
  // linearly only *within* the current, correctly (unevenly) sized
  // position - rather than this function's first version, which
  // divided the whole year uniformly and so could not represent the
  // Sun's non-uniform apparent motion at all. The result lands on an
  // exact multiple of 30 degrees at every Persian-pattern month
  // boundary (verified in TIMETest.java for both a leap and a common
  // equinox-year), with a visibly different (slower) degrees-per-day
  // rate across the six 31-day positions than across the 30-and-29/30-
  // day ones - the actual Kepler/eccentricity effect this whole step
  // exists to approximate.
  //
  // realDaysFromEquinox below is still computed exactly as this
  // function's first version did, via dayOfYearInRealYear/isLeapYear
  // (4a/4b) and Table A - that part was already a correct count of
  // true elapsed real days and needed no change; only what is done
  // with that count (uniform division vs. walking Table B's uneven
  // positions) has changed.
  //
  // Still deliberately not wired into any existing call site: the
  // open question from this function's first version is unchanged by
  // this rewrite - SHADE_DATE_ANGLE's own now_j (impactDayToDayOfYear()
  // in shadeViewport3D.pde) steps across potentially many days using
  // generic-calendar wraparound (% 366) with no year attached at all,
  // so wiring even just that one planning-mode site still needs an
  // answer for how/whether an impactDisplayDay step that crosses a
  // real Dec31->Jan1 boundary should advance TIME.year, and what a
  // step landing on a generic Feb-29 slot should do in a non-leap
  // target real year.
  float dateAngleFromRealDate (int year_IN, int month_IN, int day_IN) {
    int realYearLength = this.isLeapYear(year_IN) ? 366 : 365;

    int dayOfYear = this.dayOfYearInRealYear(year_IN, month_IN, day_IN);
    int equinoxDayOfYear = this.dayOfYearInRealYear(year_IN, 3, 21); // same fixed Mar-21 anchor every existing DATE_ANGLE site uses - not the true astronomical equinox

    int realDaysFromEquinox = ((dayOfYear - equinoxDayOfYear) % realYearLength + realYearLength) % realYearLength;

    int remaining = realDaysFromEquinox;
    for (int position = 0; position < 12; position++) {
      int positionLength = this.persianMonthLength(position, year_IN);
      if (remaining < positionLength) {
        return 30.0 * position + 30.0 * remaining / positionLength;
      }
      remaining -= positionLength;
    }
    // unreachable: the 12 Table B positions sum to exactly
    // realYearLength (see persianMonthLength's own comment above), and
    // remaining (from the modulo above) is already < realYearLength
    return 330.0;
  }

  void updateDate () {
    this.month = this.getMonth_fromDate(this.date);
    this.day = this.getDay_fromDate(this.date);
    this.hour = int(24 * (this.date - int(this.date)));
  }


  public void to_XML (XML xml) {

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

    XML parent = xml.getChild(this.CLASS_STAMP);

    this.modelRun = XML_getInt(parent, "modelRun");
    this.year = XML_getInt(parent, "year");
    this.month = XML_getInt(parent, "month");
    this.day = XML_getInt(parent, "day");
    this.hour = XML_getInt(parent, "hour");
    this.beginDay = XML_getInt(parent, "beginDay");
    this.date = XML_getFloat(parent, "date");

    sync_SHADE_DATE_ANGLE();
  }

}
