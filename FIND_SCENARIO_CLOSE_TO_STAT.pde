int SOLARCHVISION_FIND_SCENARIO_CLOSE_TO_STAT (float[] values, int l) {
  float normal = SOLARCHVISION_NORMAL(values)[l];
  int n = values.length;

  int out = -1;

  if (is_defined(normal)) {
    float dist = FLOAT_undefined;

    for (int i = 0; i < n; i++) {
      float diff = abs(normal - values[i]);
      if (diff < dist) {
        dist = diff;
        out = i;
        if (diff == 0) break; // can't do better than an exact match
      }
    }
  }

  return out;
}
