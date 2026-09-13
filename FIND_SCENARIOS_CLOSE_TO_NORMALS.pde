int SOLARCHVISION_FIND_SCENARIOS_CLOSE_TO_NORMALS (float[] _values, int l) {
  float[] _normals = SOLARCHVISION_NORMAL(_values);
  int n = _values.length;

  int out = -1;
  float _normal = _normals[l];

  if (is_defined(_normal)) {
    float _dist = FLOAT_undefined;

    for (int i = 0; i < n; i++) {
      float diff = abs(_normal - _values[i]);
      if (diff < _dist) {
        _dist = diff;
        out = i;
        if (diff == 0) break; // can't do better than an exact match
      }
    }
  }

  return out;
}
