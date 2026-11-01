// Computes 9 representative values from Values (any single climate
// variable's samples for one day/hour slot - temperature, wind speed,
// radiation, whatever layer is active; this function has no idea which).
// Six of them are standard: STAT_N_Min/Max are the extremes, STAT_N_Ave is
// the plain mean, and STAT_N_M25/M50/M75 are true order statistics (read
// straight off the sorted array below) - ordinary percentiles and the
// median, nothing novel about those.
//
// STAT_N_MidLow/Middle/MidHigh ("Leaning Low" / "Well-tempered" /
// "Leaning High" in STAT_N_Title, globals.pde) are SOLARCHVISION's own
// invention, and are NOT percentiles despite sitting next to M25/M50/M75
// in the stat list - they're rank-weighted means (an L-estimator, in
// statistics terms: a linear combination of every sorted value, not a
// single order statistic the way a percentile picks one spot and reads
// it off). Each gives every one of the NV sorted values a weight that's
// a straight-line function of its rank (i+1, 1-indexed) and sums
// Values[i] * weight, same denominator-normalized way STAT_N_Ave does
// above it, just with a non-uniform weight instead of a flat 1:
//
//   - STAT_N_Middle ("Well-tempered"): a triangular weight, peaking at
//     the center rank and falling off linearly toward both ends -
//     every value still counts, but the extremes count least. Named for
//     J.S. Bach's Well-Tempered Clavier: "well-tempered", not "even-
//     tempered", on purpose - the weighting is deliberately NOT flat/
//     uniform (an even-tempered scale divides the octave equally; this
//     doesn't divide the ranks equally), just balanced around the
//     center. It tracks the median's intuition (a robust, outlier-
//     damped central value) without being the median - on an even NV it
//     won't equal the median's average-of-the-two-middle-values, and
//     unlike the median, every value in the series still moves it a
//     little even from the far ends, just barely.
//   - STAT_N_MidHigh ("Leaning High"): weight = rank (i+1) - grows
//     linearly from 1 at the smallest value to NV at the largest, so
//     larger values pull proportionally harder. Lands somewhere between
//     STAT_N_Ave and STAT_N_Max - a day that's on the high side without
//     being the single most extreme one.
//   - STAT_N_MidLow ("Leaning Low"): the mirror of MidHigh - weight =
//     NV+1-i, so smaller values pull harder. Lands between STAT_N_Ave
//     and STAT_N_Min.
//
// The point of all three: FIND_SCENARIO_CLOSE_TO_DAILY_STAT.pde picks
// whichever real scenario in the ensemble sits closest to one of these
// computed values, to drive a full simulation from a single representative
// day - Min/Max/a percentile all have the usual problem of being exactly
// as noisy/extreme as whatever single ensemble member happens to land
// there, and these three are mid-way alternatives that are each still
// shaped by the WHOLE distribution (unlike a percentile, which only looks
// at the one value that happens to sit at that rank), while still landing
// in a different part of it - low, central-and-damped, or high - rather
// than everywhere just collapsing to STAT_N_Ave.
float[] NORMAL (float[] Values) {

  float[] weight_array = {
    0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  float[] return_array = {
    0, 0, 0, 0, 0, 0, 0, 0, 0
  };

  int NV = 0; // the number of values without counting undefined values
  float _weight = 0;

  Values = sort(Values);
  for (int i = 0; i < Values.length; i++) {
    if (is_defined(Values[i])) NV += 1;
  }

  if (NV > 0) {
    for (int i = 0; i < NV; i++) {
      if (is_defined(Values[i])) {
        _weight = 1;
        weight_array[STAT_N_Ave] += _weight;
        return_array[STAT_N_Ave] += Values[i];

        // triangular rank weight, peaks at the center rank - see this
        // function's own top comment ("Well-tempered")
        _weight = (0.5 * (NV + 1)) - abs((0.5 * (NV + 1)) - (i + 1));
        weight_array[STAT_N_Middle] += _weight;
        return_array[STAT_N_Middle] += Values[i] * _weight;

        // rank weight grows toward the largest value ("Leaning High")
        _weight = (i + 1);
        weight_array[STAT_N_MidHigh] += _weight;
        return_array[STAT_N_MidHigh] += Values[i] * _weight;

        // rank weight grows toward the smallest value ("Leaning Low")
        _weight = (NV + 1 - i);
        weight_array[STAT_N_MidLow] += _weight;
        return_array[STAT_N_MidLow] += Values[i] * _weight;
      }
    }

    return_array[STAT_N_Ave] /= weight_array[STAT_N_Ave];
    return_array[STAT_N_Middle] /= weight_array[STAT_N_Middle];
    return_array[STAT_N_MidHigh] /= weight_array[STAT_N_MidHigh];
    return_array[STAT_N_MidLow] /= weight_array[STAT_N_MidLow];

    return_array[STAT_N_Max] = Values[(NV - 1)];
    return_array[STAT_N_Min] = Values[0];

    if ((NV % 2) == 1) {

      return_array[STAT_N_M50] = Values[(floor(NV / 2))];
    } else {

      return_array[STAT_N_M50] = 0.5 * (Values[(floor(NV / 2))] + Values[(floor(NV / 2) - 1)]);
    }

    int q;

    q = int(funcs.roundTo((NV * 0.75), 1));
    if (q > NV - 1) q = NV - 1;
    return_array[STAT_N_M75] = Values[q];

    q = int(funcs.roundTo((NV * 0.25), 1));
    if (q < 0) q = 0;
    return_array[STAT_N_M25] = Values[q];
  } else {
    java.util.Arrays.fill(return_array, FLOAT_undefined);
  }

  return return_array;
}
