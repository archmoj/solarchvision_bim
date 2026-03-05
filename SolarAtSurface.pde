float SOLARCHVISION_SolarAtSurface (float SunR1, float SunR2, float SunR3, float SunR4, float SunR5, float Alpha, float Beta, float THE_ALBEDO) {

  float return_value = FLOAT_undefined;

  if (is_defined(SunR1) &&
      is_defined(SunR2) &&
      is_defined(SunR3) &&
      is_defined(SunR4) &&
      is_defined(SunR5)) {

    float[] VECT = {
      0, 0, 0
    };

    if (abs(Alpha) > 89.99) {
      VECT[0] = 0;
      VECT[1] = 0;
      VECT[2] = 1;
    } else if (Alpha < -89.99) {
      VECT[0] = 0;
      VECT[1] = 0;
      VECT[2] = -1;
    } else {
      VECT[0] = funcs.sin_ang(Beta);
      VECT[1] = -funcs.cos_ang(Beta);
      VECT[2] = funcs.tan_ang(Alpha);
    }

    VECT = funcs.vec3_unit(VECT);


    float[] SunV = {
      SunR1, SunR2, SunR3
    };

    float SunMask = funcs.vec_dot(funcs.vec3_unit(SunV), funcs.vec3_unit(VECT));
    if (SunMask <= 0) SunMask = 0; // removes backing faces

    float SkyMask = (0.5 * (1.0 + (Alpha / 90.0)));

    return_value = (SunR4 * SunMask) + (SunR5 * SkyMask);


    /*
    float[] REF_SunV = {SunR1, SunR2, -SunR3};

     float REF_SunMask = funcs.vec_dot(funcs.vec3_unit(REF_SunV), funcs.vec3_unit(VECT));
     if (REF_SunMask <= 0) REF_SunMask = 0; // removes backing faces

     float REF_SkyMask = 1 - (0.5 * (1.0 + (Alpha / 90.0)));

     return_value +=  (0.01 * THE_ALBEDO) * ((SunR4 * REF_SunMask) + (SunR5 * REF_SkyMask));
     */
  }

  return (return_value);
}
