class solarchvision_Materials {

  int Number = 11; //256; // 0, 1, 2, ... , 10

  int Selection = 1; //2; // yellow

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
}
