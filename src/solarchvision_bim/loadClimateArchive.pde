void load_climateArchive (String FileName) {

  String[] FileALL = loadStrings(FileName);

  String lineSTR;
  String[] input;

  println("lines = ", FileALL.length);

  for (int f = 18; f < FileALL.length; f++) {

    lineSTR = FileALL[f];

    if (lineSTR.trim().length() == 0) continue; // skip blank lines (e.g. a trailing empty line at EOF)

    lineSTR = lineSTR.replace("\"", "");
    String[] parts = split(lineSTR, ",");

    // 9 is the real minimum width a row needs for this function to read
    // anything at all now (Time (LST), index 8) - a genuine, common row
    // shape in practice (the archive's own most recent hours, before
    // real sensor readings have arrived - see this function's own
    // further comment below), not just a malformed-line guard.
    if (parts.length < 9) continue; // not a well-formed data row - skip it

    // Real ECCC column layout (2001+ files; confirmed directly against
    // real downloaded rows, not assumed): "Longitude (x)","Latitude (y)",
    // "Station Name","Climate ID","Date/Time (LST)","Year","Month","Day",
    // "Time (LST)","Flag","Temp (°C)","Temp Flag","Dew Point Temp (°C)",
    // "Dew Point Temp Flag","Rel Hum (%)","Rel Hum Flag","Precip. Amount
    // (mm)","Precip. Amount Flag","Wind Dir (10s deg)","Wind Dir Flag",
    // "Wind Spd (km/h)","Wind Spd Flag","Visibility (km)","Visibility
    // Flag","Stn Press (kPa)","Stn Press Flag","Hmdx","Hmdx Flag","Wind
    // Chill","Wind Chill Flag","Weather" - indices 5/6/7/8 for Year/Month/
    // Day/Time, not 1/2/3/4 as before (those are Latitude/Station Name/
    // Climate ID/Date-Time instead). A row with no real sensor readings
    // yet (common for the most recent hours the archive has) comes back
    // with just the first 9 columns - "parts.length < 5" above already
    // skips anything even shorter than that, and the "parts.length > 30"
    // guard below (not the old, too-low ">24") skips those too, since
    // real data never arrives without the full 31-column row.

    int CLIMATE_YEAR = int(parts[5]);
    int CLIMATE_MONTH = int(parts[6]);
    int CLIMATE_DAY = int(parts[7]);
    int CLIMATE_HOUR = int(parts[8].substring(0, 2));

    int i = int(CLIMATE_HOUR);
    int j = TIME.convert2Date(CLIMATE_MONTH, CLIMATE_DAY);
    int k = (CLIMATE_YEAR - climateArchiveStart);

    if (parts.length > 30) {

      String str = "";

      // Weather (index 30) - its own text can itself contain a comma
      // (e.g. "Rain,Fog"), splitting it across parts[30]/parts[31+] -
      // harmless here since every other field this function reads sits
      // at a lower index, unaffected by anything split off the end.
      str = parts[30];

      if (str.equals("NA")) climateArchiveValues[i][j][LAYER_cloudcover.id][k] = FLOAT_undefined;
      else if (str.equals("Clear")) climateArchiveValues[i][j][LAYER_cloudcover.id][k] = 0;
      else if (str.equals("Mainly Clear")) climateArchiveValues[i][j][LAYER_cloudcover.id][k] = 2.5;
      else if (str.equals("Mostly Cloudy")) climateArchiveValues[i][j][LAYER_cloudcover.id][k] = 5;
      else if (str.equals("Cloudy")) climateArchiveValues[i][j][LAYER_cloudcover.id][k] = 7.5;
      else climateArchiveValues[i][j][LAYER_cloudcover.id][k] = 10;

      str = parts[10]; // Temp (°C)
      if (!str.equals("")) climateArchiveValues[i][j][LAYER_drybulb.id][k] = float(str); // °C

      str = parts[14]; // Rel Hum (%)
      if (!str.equals("")) climateArchiveValues[i][j][LAYER_relhum.id][k] = float(str); // %

      str = parts[18]; // Wind Dir (10s deg)
      if (!str.equals("")) climateArchiveValues[i][j][LAYER_winddir.id][k] = float(str) * 10; // °

      str = parts[20]; // Wind Spd (km/h)
      if (!str.equals("")) climateArchiveValues[i][j][LAYER_windspd.id][k] = float(str); // km/h

      str = parts[24]; // Stn Press (kPa)
      if (!str.equals("")) climateArchiveValues[i][j][LAYER_pressure.id][k] = float(str) * 10; // hPa


    }
  }

}
