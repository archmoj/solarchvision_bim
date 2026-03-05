float[] SOLARCHVISION_NORMAL (float[] _values) {

  float[] weight_array = {
    0, 0, 0, 0, 0, 0, 0, 0, 0
  };
  float[] return_array = {
    0, 0, 0, 0, 0, 0, 0, 0, 0
  };

  int NV = 0; // the number of values without counting undefined values
  float _weight = 0;

  _values = sort(_values);
  for (int i = 0; i < _values.length; i++) {
    if (is_defined(_values[i])) NV += 1;
  }

  if (NV > 0) {
    for (int i = 0; i < NV; i++) {
      if (is_defined(_values[i])) {
        _weight = 1;
        weight_array[STAT_N_Ave] += _weight;
        return_array[STAT_N_Ave] += _values[i];

        _weight = (0.5 * (NV + 1)) - abs((0.5 * (NV + 1)) - (i + 1));
        weight_array[STAT_N_Middle] += _weight;
        return_array[STAT_N_Middle] += _values[i] * _weight;

        _weight = (i + 1);
        weight_array[STAT_N_MidHigh] += _weight;
        return_array[STAT_N_MidHigh] += _values[i] * _weight;

        _weight = (NV + 1 - i);
        weight_array[STAT_N_MidLow] += _weight;
        return_array[STAT_N_MidLow] += _values[i] * _weight;
      }
    }

    return_array[STAT_N_Ave] /= weight_array[STAT_N_Ave];
    return_array[STAT_N_Middle] /= weight_array[STAT_N_Middle];
    return_array[STAT_N_MidHigh] /= weight_array[STAT_N_MidHigh];
    return_array[STAT_N_MidLow] /= weight_array[STAT_N_MidLow];

    return_array[STAT_N_Max] = _values[(NV - 1)];
    return_array[STAT_N_Min] = _values[0];

    if ((NV % 2) == 1) {

      return_array[STAT_N_M50] = _values[(floor(NV / 2))];
    } else {

      return_array[STAT_N_M50] = 0.5 * (_values[(floor(NV / 2))] + _values[(floor(NV / 2) - 1)]);
    }

    int q;

    q = int(funcs.roundTo((NV * 0.75), 1));
    if (q > NV - 1) q = NV - 1;
    return_array[STAT_N_M75] = _values[q];

    q = int(funcs.roundTo((NV * 0.25), 1));
    if (q < 0) q = 0;
    return_array[STAT_N_M25] = _values[q];
  } else {
    for (int i = 0; i < return_array.length; i++) {
      return_array[i] = FLOAT_undefined;
    }
  }

  return return_array;
}
