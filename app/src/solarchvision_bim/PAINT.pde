class solarchvision_PAINT {

  private final static String CLASS_STAMP = "PAINT";


  int getOpacity (float O_scale) {
    int k = int(O_scale * 0.01 * 256);
    if (k > 255) k = 255;
    if (k < 0) k = 0;

    return k;
  }

  float[] WBGRW (float _variable) {
    _variable *= 600.0;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };

    if (_variable < 0) {
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255;
    } else if (_variable < 100) {
      v = ((_variable) * 2.55);
      COL[1] = (255 - v);
      COL[2] = (255 - v);
      COL[3] = 255;
    } else if (_variable < 200) {
      v = ((_variable - 100) * 2.55);
      COL[1] = 0;
      COL[2] = v;
      COL[3] = 255;
    } else if (_variable < 300) {
      v = ((_variable - 200) * 2.55);
      COL[1] = 0;
      COL[2] = 255;
      COL[3] = (255 - v);
    } else if (_variable < 400) {
      v = ((_variable - 300) * 2.55);
      COL[1] = v;
      COL[2] = 255;
      COL[3] = 0;
    } else if (_variable < 500) {
      v = ((_variable - 400) * 2.55);
      COL[1] = 255;
      COL[2] = (255 - v);
      COL[3] = 0;
    } else if (_variable < 600) {
      v = ((_variable - 500) * 2.55);
      COL[1] = 255;
      COL[2] = v;
      COL[3] = v;
    } else {
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255;
    }

    return COL;
  }

  float[] BGR (float _variable) {
    _variable *= 400.0;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };

    if (_variable < 0) {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 255;
    } else if (_variable < 100) {
      v = ((_variable) * 2.55);
      COL[1] = 0;
      COL[2] = v;
      COL[3] = 255;
    } else if (_variable < 200) {
      v = ((_variable - 100) * 2.55);
      COL[1] = 0;
      COL[2] = 255;
      COL[3] = (255 - v);
    } else if (_variable < 300) {
      v = ((_variable - 200) * 2.55);
      COL[1] = v;
      COL[2] = 255;
      COL[3] = 0;
    } else if (_variable < 400) {
      v = ((_variable - 300) * 2.55);
      COL[1] = 255;
      COL[2] = (255 - v);
      COL[3] = 0;
    } else {
      COL[1] = 255;
      COL[2] = 0;
      COL[3] = 0;
    }

    return COL;
  }

  float[] DBGR (float _variable) {
    _variable *= 500.0;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable < 0) {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < 100) {
      v = ((_variable) * 2.55);
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = v;
    } else if (_variable < 200) {
      v = ((_variable - 100) * 2.55);
      COL[1] = 0;
      COL[2] = v;
      COL[3] = 255;
    } else if (_variable < 300) {
      v = ((_variable - 200) * 2.55);
      COL[1] = 0;
      COL[2] = 255;
      COL[3] = (255 - v);
    } else if (_variable < 400) {
      v = ((_variable - 300) * 2.55);
      COL[1] = v;
      COL[2] = 255;
      COL[3] = 0;
    } else if (_variable < 500) {
      v = ((_variable - 400) * 2.55);
      COL[1] = 255;
      COL[2] = (255 - v);
      COL[3] = 0;
    } else {
      COL[1] = 255;
      COL[2] = 0;
      COL[3] = 0;
    }

    return COL;
  }

  float[] DWBGR (float _variable) {
    _variable *= 600.0;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable < 0) {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < 100) {
      v = ((_variable) * 2.55);
      COL[1] = v;
      COL[2] = v;
      COL[3] = v;
    } else if (_variable < 200) {
      v = ((_variable - 100) * 2.55);
      COL[1] = (255 - v);
      COL[2] = (255 - v);
      COL[3] = 255;
    } else if (_variable < 300) {
      v = ((_variable - 200) * 2.55);
      COL[1] = 0;
      COL[2] = v;
      COL[3] = 255;
    } else if (_variable < 400) {
      v = ((_variable - 300) * 2.55);
      COL[1] = 0;
      COL[2] = 255;
      COL[3] = (255 - v);
    } else if (_variable < 500) {
      v = ((_variable - 400) * 2.55);
      COL[1] = v;
      COL[2] = 255;
      COL[3] = 0;
    } else if (_variable < 600) {
      v = ((_variable - 500) * 2.55);
      COL[1] = 255;
      COL[2] = (255 - v);
      COL[3] = 0;
    } else {
      COL[1] = 255;
      COL[2] = 0;
      COL[3] = 0;
    }

    return COL;
  }

  float[] DWYR (float _variable) {
    _variable *= 400.0;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable < 0) {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < 100) {
      v = ((_variable) * 2.55);
      COL[1] = v;
      COL[2] = v;
      COL[3] = v;
    } else if (_variable < 200) {
      v = ((_variable - 100) * 2.55);
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = (255 - v);
    } else if (_variable < 300) {
      v = ((_variable - 200) * 2.55);
      COL[1] = 255;
      COL[2] = (255 - v);
      COL[3] = 0;
    } else if (_variable < 400) {
      v = ((_variable - 300) * 2.55);
      COL[1] = 255 - 0.5 * v;
      COL[2] = 0;
      COL[3] = 0;
    } else {
      COL[1] = 127;
      COL[2] = 0;
      COL[3] = 0;
    }

    return COL;
  }


  float[] VDWBGR (float _variable) {
    _variable *= 700.0;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable < 0) {
      COL[1] = 255;
      COL[2] = 0;
      COL[3] = 255;
    } else if (_variable < 100) {
      v = ((_variable - 0) * 2.55);
      COL[1] = (255 - v);
      COL[2] = 0;
      COL[3] = (255 - v);
    } else if (_variable < 200) {
      v = ((_variable - 100) * 2.55);
      COL[1] = v;
      COL[2] = v;
      COL[3] = v;
    } else if (_variable < 300) {
      v = ((_variable - 200) * 2.55);
      COL[1] = (255 - v);
      COL[2] = (255 - v);
      COL[3] = 255;
    } else if (_variable < 400) {
      v = ((_variable - 300) * 2.55);
      COL[1] = 0;
      COL[2] = v;
      COL[3] = 255;
    } else if (_variable < 500) {
      v = ((_variable - 400) * 2.55);
      COL[1] = 0;
      COL[2] = 255;
      COL[3] = (255 - v);
    } else if (_variable < 600) {
      v = ((_variable - 500) * 2.55);
      COL[1] = v;
      COL[2] = 255;
      COL[3] = 0;
    } else if (_variable < 700) {
      v = ((_variable - 600) * 2.55);
      COL[1] = 255;
      COL[2] = (255 - v);
      COL[3] = 0;
    } else {
      COL[1] = 255;
      COL[2] = 0;
      COL[3] = 0;
    }

    return COL;
  }

  float[] DRYWCBD (float _variable) {

    _variable *= 1.5;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable <= -2.75) {
      COL[1] = 63;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -2) {
      v = (-(_variable + 2) * 255);
      COL[1] = 255 - v;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -1) {
      v = (-(_variable + 1) * 255);
      COL[1] = 255;
      COL[2] = 255 - v;
      COL[3] = 0;
    } else if (_variable < 0) {
      v = (-_variable * 255);
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255 - v;
    } else if (_variable < 1) {
      v = (_variable * 255);
      COL[1] = 255 - v;
      COL[2] = 255;
      COL[3] = 255;
    } else if (_variable < 2) {
      v = ((_variable - 1) * 255);
      COL[1] = 0;
      COL[2] = 255 - v;
      COL[3] = 255;
    } else if (_variable < 2.75) {
      v = ((_variable - 2) * 255);
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 255 - v;
    } else {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 63;
    }

    return COL;
  }


  float[] DBCW (float _variable) {
    _variable = 1 - _variable;
    _variable *= -3;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable < -3) {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -2) {
      v = (-(_variable + 2) * 255);
      COL[1] = 255 - v;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -1) {
      v = (-(_variable + 1) * 255);
      COL[1] = 255;
      COL[2] = 255 - v;
      COL[3] = 0;
    } else if (_variable < 0) {
      v = (-_variable * 255);
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255 - v;
    } else {
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255;
    }

    float r, g, b;
    r = COL[3];
    g = COL[2];
    b = COL[1];
    COL[1] = r;
    COL[2] = g;
    COL[3] = b;

    return COL;
  }

  float[] DRYW (float _variable) {
    _variable = 1 - _variable;
    _variable *= -3;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable < -3) {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -2) {
      v = (-(_variable + 2) * 255);
      COL[1] = 255 - v;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -1) {
      v = (-(_variable + 1) * 255);
      COL[1] = 255;
      COL[2] = 255 - v;
      COL[3] = 0;
    } else if (_variable < 0) {
      v = (-_variable * 255);
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255 - v;
    } else {
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255;
    }

    return COL;
  }

  float[] WYRD (float _variable) {
    _variable *= -3;

    float v;
    float[] COL = {
      255, 0, 0, 0
    };
    if (_variable < -3) {
      COL[1] = 0;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -2) {
      v = (-(_variable + 2) * 255);
      COL[1] = 255 - v;
      COL[2] = 0;
      COL[3] = 0;
    } else if (_variable < -1) {
      v = (-(_variable + 1) * 255);
      COL[1] = 255;
      COL[2] = 255 - v;
      COL[3] = 0;
    } else if (_variable < 0) {
      v = (-_variable * 255);
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255 - v;
    } else {
      COL[1] = 255;
      COL[2] = 255;
      COL[3] = 255;
    }

    return COL;
  }


  float[] getColorStyle (int COLOR_STYLE_Current, float j) {
    float[] c = {
      255, 0, 0, 0
    };

    if (COLOR_STYLE_Current == 0) {
      c[0] = PAINT.getOpacity(STUDY.O_scale);
      c[1] = 0;
      c[2] = 0;
      c[3] = 0;
    } else if (COLOR_STYLE_Current == 19) {
      float[] COL = this.DWYR(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 18) {
      float[] COL = this.DRYWCBD(2.0 * (j - 0.5));
      c[0] = 255;
      c[1] = COL[3];
      c[2] = COL[2];
      c[3] = COL[1];
    } else if (COLOR_STYLE_Current == 17) {
      float[] COL = this.DRYWCBD(2.0 * (j - 0.5));
      c[0] = 255;
      c[1] = 255 - COL[3];
      c[2] = 255 - COL[2];
      c[3] = 255 - COL[1];
    } else if (COLOR_STYLE_Current == 16) {
      float[] COL = this.DBCW(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 15) {
      float[] COL = this.DRYW(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 14) {
      float[] COL = this.DBGR(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 13) {
      float[] COL = this.DWBGR(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 12) {
      float[] COL = this.BGR(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 11) {
      float[] COL = this.BGR(j);
      c[0] = 127;
      c[1] = 255 - 0.5 * COL[1];
      c[2] = 255 - 0.5 * COL[2];
      c[3] = 255 - 0.5 * COL[3];
    } else if (COLOR_STYLE_Current == 10) {
      float[] COL = this.BGR(j);
      c[0] = 255;
      c[1] = 255 - COL[1];
      c[2] = 255 - COL[2];
      c[3] = 255 - COL[3];
    } else if (COLOR_STYLE_Current == 9) {
      float[] COL = this.WBGRW(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 8) {
      float[] COL = this.BGR(j);
      c[0] = 255;
      c[1] = 255 - COL[1];
      c[2] = 255 - COL[2];
      c[3] = 255 - COL[3];
    } else if (COLOR_STYLE_Current == 7) {
      float[] COL = this.WBGRW(j);
      c[0] = 255;
      c[1] = 255 - COL[1];
      c[2] = 255 - COL[2];
      c[3] = 255 - COL[3];
    } else if (COLOR_STYLE_Current == 6) {
      float[] COL = this.BGR(j);
      c[0] = 255;
      c[1] = COL[3];
      c[2] = COL[2];
      c[3] = COL[1];
    } else if (COLOR_STYLE_Current == 4) {
      float[] COL = this.VDWBGR(j);
      c[0] = STUDY.O_scale;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 3) {
      float[] COL = this.VDWBGR(j);
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 2) {
      float[] COL = this.DRYWCBD(2.0 * (j - 0.5));
      c[0] = STUDY.O_scale;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 1) {
      float[] COL = this.DRYWCBD(2.0 * (j - 0.5));
      c[0] = 255;
      c[1] = COL[1];
      c[2] = COL[2];
      c[3] = COL[3];
    } else if (COLOR_STYLE_Current == 5) {
      c[0] = 255;
      c[1] = 0;
      c[2] = 0;
      c[3] = 0;
    } else if (COLOR_STYLE_Current == -1) {
      float[] COL = this.DRYWCBD(2.0 * (j - 0.5));
      c[0] = 255;
      c[1] = 255 - COL[3];
      c[2] = 255 - COL[2];
      c[3] = 255 - COL[1];
    }


    return c;
  }
}
