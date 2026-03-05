class solarchvision_Materials {

  int Number = 11; //256; // 0, 1, 2, ... , 10

  int Selection = 1; //2; // yellow

  float[][][] DirectArea_Data = new float [this.Number][24][365];
  int[][] DirectArea_Flags = new int [24][365];

  float[][][] DiffuseArea_Data = new float [this.Number][24][365];
  int[][] DiffuseArea_Flags = new int [24][365];

  int[][] Color = new int [this.Number][4]; // ARGB
  {
    {
      int[] COL = {
        255, 255, 127, 0
      };
      this.Color[0] = COL;
    }
    {
      int[] COL = {
        255, 255, 0, 0
      };
      this.Color[1] = COL;
    }
    {
      int[] COL = {
        255, 255, 255, 0
      };
      this.Color[2] = COL;
    }
    {
      int[] COL = {
        255, 0, 255, 0
      };
      this.Color[3] = COL;
    }
    {
      int[] COL = {
        255, 0, 255, 255
      };
      this.Color[4] = COL;
    }
    {
      int[] COL = {
        255, 0, 0, 255
      };
      this.Color[5] = COL;
    }
    {
      int[] COL = {
        255, 255, 0, 255
      };
      this.Color[6] = COL;
    }
    {
      int[] COL = {
        255, 255, 255, 255
      };
      this.Color[7] = COL;
    }
    {
      //int[] COL = {255, 63, 63, 63};
      int[] COL = {
        63, 63, 63, 63
      };
      this.Color[8] = COL;
    }
    {
      //int[] COL = {255, 127, 127, 127};
      int[] COL = {
        127, 127, 127, 127
      };
      this.Color[9] = COL;
    }
    {
      //int[] COL = {255, 191, 191, 191};
      int[] COL = {
        191, 191, 191, 191
      };
      this.Color[10] = COL;
    }

    {
      for (int mt = 11; mt < this.Number; mt++) {
        int[] COL = {
          255, int(random(256)), int(random(256)), int(random(256))
        };
        this.Color[mt] = COL;
      }
    }
  }

  void empty_DirectArea () {

    for (int mt = 0; mt < this.Number; mt++) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 365; j++) {
          this.DirectArea_Data[mt][i][j] = FLOAT_undefined;
          this.DirectArea_Flags[i][j] = -1;
        }
      }
    }
  }

  void empty_DiffuseArea () {

    for (int mt = 0; mt < this.Number; mt++) {
      for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 365; j++) {
          this.DiffuseArea_Data[mt][i][j] = FLOAT_undefined;
          this.DiffuseArea_Flags[i][j] = -1;
        }
      }
    }
  }

}
