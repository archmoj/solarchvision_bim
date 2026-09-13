class solarchvision_Materials {

  int Number = 11; //256;
  int Selection = 1;

  int[][] Color = new int [this.Number][4]; // ARGB

  {
    int[][] fixed = {
      {255, 255, 127,   0}, // 0
      {255, 255,   0,   0}, // 1
      {255, 255, 255,   0}, // 2
      {255,   0, 255,   0}, // 3
      {255,   0, 255, 255}, // 4
      {255,   0,   0, 255}, // 5
      {255, 255,   0, 255}, // 6
      {255, 255, 255, 255}, // 7
      { 63,  63,  63,  63}, // 8
      {127, 127, 127, 127}, // 9
      {191, 191, 191, 191}  // 10
    };

    int fixedCount = min(fixed.length, this.Number);
    for (int mt = 0; mt < fixedCount; mt++) {
      this.Color[mt] = fixed[mt];
    }

    for (int mt = fixedCount; mt < this.Number; mt++) {
      this.Color[mt] = new int[] {255, int(random(256)), int(random(256)), int(random(256))};
    }
  }
}
