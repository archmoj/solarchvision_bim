int[] SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS (float[] _values) {
  float[] _normals = SOLARCHVISION_NORMAL(_values);
  int[] return_array = new int[9];
  int n = _values.length;

  for (int l = 0; l < 9; l++) {
    return_array[l] = -1;
    float _normal = _normals[l];

    if (is_defined(_normal)) {
      float _dist = FLOAT_undefined;

      for (int i = 0; i < n; i++) {
        float diff = abs(_normal - _values[i]);
        if (diff < _dist) {
          _dist = diff;
          return_array[l] = i;
          if (diff == 0) break; // can't do better than an exact match
        }
      }
    }
  }

  return return_array;
}
