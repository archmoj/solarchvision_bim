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

        _weight = (0.5 * (NV + 1)) - abs((0.5 * (NV + 1)) - (i + 1));
        weight_array[STAT_N_Middle] += _weight;
        return_array[STAT_N_Middle] += Values[i] * _weight;

        _weight = (i + 1);
        weight_array[STAT_N_MidHigh] += _weight;
        return_array[STAT_N_MidHigh] += Values[i] * _weight;

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
