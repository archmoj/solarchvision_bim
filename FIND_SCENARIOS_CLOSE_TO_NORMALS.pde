int[] SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS (float[] _values) {

  float[] _normals = SOLARCHVISION_NORMAL(_values);

  int[] return_array = new int [9];

  for (int l = 0; l < 9; l++) {
    return_array[l] = -1;
    if (is_defined(_normals[l])) {

      float _dist = FLOAT_undefined;

      for (int i = 0; i < _values.length; i++) {
        if (_dist > abs(_normals[l] - _values[i])) {
          _dist = abs(_normals[l] - _values[i]);
          return_array[l] = i;
        }
      }
    } else return_array[l] = -1;
  }

  return return_array;
}
