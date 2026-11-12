int[] getNow_inUTC () {

  int LocationTimeZone = getLocationTimeZone();

  return convert_LocalToUTC(LocationTimeZone, year(), month(), day(), hour());
}

// Pure local-time -> UTC conversion, split out of getNow_inUTC() so the
// day/month/year rollover logic below can be unit-tested directly against
// fixed inputs, without needing to fake Processing's own real-clock
// functions (year()/month()/day()/hour()) - getNow_inUTC() itself still
// calls those, then just delegates the rollover arithmetic here. Behavior
// is unchanged from before this split: same branches, same order, same
// results for the same (LocationTimeZone, year, month, day, hour) inputs.
int[] convert_LocalToUTC (int LocationTimeZone, int CurrentYear, int CurrentMonth, int CurrentDay, int CurrentHour) {

  // converting from local time to global time

  if (LocationTimeZone > 0) {
    CurrentHour -= LocationTimeZone;

    if (CurrentHour < 0) {
      CurrentHour += 24;
      CurrentDay -= 1;

      if (CurrentDay < 1) {

        CurrentMonth -= 1;

        if (CurrentMonth < 1) {
          CurrentMonth = 12;
          CurrentYear -= 1;
        }

        CurrentDay = TIME.lengthOfMonths[CurrentMonth - 1];
      }
    }
  }
  else if (LocationTimeZone < 0) {
    CurrentHour += abs(LocationTimeZone);

    if (CurrentHour > 23) {
      CurrentHour -= 24;
      CurrentDay += 1;

      if (CurrentDay > TIME.lengthOfMonths[CurrentMonth - 1]) {
        CurrentDay = 1;
        CurrentMonth += 1;

        if (CurrentMonth > 12) {
          CurrentMonth = 1;
          CurrentYear += 1;
        }
      }
    }
  }

  int[] return_array = {CurrentYear, CurrentMonth, CurrentDay, CurrentHour};

  return return_array;
}

int getLocationTimeZone () {
  return int(funcs.roundTo(STATION.getLongitude() / 15, 15));
}
