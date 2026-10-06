class Moon3D {

  final static String CLASS_STAMP = "Moon3D";

  final static float LONGITUDE_SPAN = 360.0;
  final static float LATITUDE_SPAN  = 180.0;
  final static float MOON_RADIUS = 1737000.0;
  final static float EARTH_MOON_DISTANCE = 384400000.0;

  // Real moon phases: a point on the Moon is lit only when it faces the
  // Sun, regardless of which side currently faces the station - these two
  // constants shape that darkening, not the astronomy itself (see
  // computeFrame()'s own comment on where the Sun direction comes from).
  final static float DARK_SIDE_AMBIENT = 0.12; // faint earthshine-like floor
                                                // for the unlit side - not
                                                // true black.
  final static float TERMINATOR_SOFTNESS = 0.15; // half-width, in dot-
                                                   // product units, of the
                                                   // lit/dark transition
                                                   // band - a hard cutoff
                                                   // at 0 would alias
                                                   // visibly at this
                                                   // sphere's tessellation
                                                   // (lat_step/lon_step).

  float lat_step = 5; //in degrees
  float lon_step  = 5; //in degrees

  boolean displaySurface = true;
  boolean displayTexture = true;
  boolean displayShadow = true; // real moon phases (see buildSubFace's own
                                 // comment) - off shows the Moon fully lit,
                                 // same as before that was added.
  boolean displayNightSide = false; // off hides faces in total darkness
                                     // outright (see draw()'s own comment),
                                     // rather than just dimming them to
                                     // DARK_SIDE_AMBIENT.

  boolean fitInSkyDome = true;

  String Filename = BaseFolder + "/input/images/moon/Moon.jpg";
  PImage Map;

  class FaceVertex {
    float x, y, z;
    float u, v;
    float brightness; // 0..1 - see DARK_SIDE_AMBIENT/TERMINATOR_SOFTNESS
    float facing; // dot(this point's own outward normal, frame.F) - >0
                  // faces the station, <=0 faces away; see draw()'s own
                  // comment on why this always matters now, not just when
                  // displayNightSide hides anything.
  }

  void load_images () {
    this.Map = loadImage(this.Filename);
  }

  // Everything buildSubFace used to recompute from scratch on every one of
  // its calls (1296 per draw() at the default lat_step=5/lon_step=10 - 36
  // x 36 - and some of it 4x again per call, once per vertex) that doesn't
  // actually depend on that call's own (Alpha, Beta): the station tilt,
  // tA/tB from MoonPosition(), and the tidal-locking (forward, up, right)
  // frame. None of it changes within one draw() call, so it's computed
  // once there instead and passed in - same refactor as Sun3D.pde.
  class SkyFrame {
    float ta;
    float tA, tB;
    // F ("forward"): direction from the sphere toward the station. Used
    // for the translation step below (equivalent to -d*F, see its own
    // comment) regardless of displayTexture, and additionally as the
    // tidal-locking frame's forward axis when displayTexture is on.
    float Fx, Fy, Fz;
    // Rup/Rright: only meaningful (and only computed) when displayTexture
    // is on - see buildSubFace's own comment on why locking F alone isn't
    // enough.
    float Rupx, Rupy, Rupz;
    float Rrightx, Rrighty, Rrightz;
    // Direction from the station toward the Sun, in this SAME frame -
    // used for phase shading (see buildSubFace's own comment). The real
    // Moon is lit by the Sun regardless of which side currently faces
    // Earth, which is exactly what makes it show phases in the first
    // place - station-to-Sun stands in for Moon-to-Sun here, the same
    // simplification already implicit in reusing the Sun's own real
    // position (see funcs.SunPosition) rather than computing a separate,
    // Moon-centered one: the Earth-Moon distance is negligible next to
    // the Earth-Sun one, so the Sun's direction barely changes between
    // the two vantage points.
    float Sx, Sy, Sz;
  }

  SkyFrame computeFrame () {
    SkyFrame f = new SkyFrame();

    float stationLat = STATION.getLatitude();
    f.ta = 90 - stationLat;

    // Real position tracking, same architecture as Sun3D.pde: MoonR/tA/tB
    // move the sphere's POSITION across the sky via the translation step
    // in buildSubFace, using the exact same SHADE_DATE_ANGLE/
    // SHADE_HOUR_ANGLE this app already drives the Sun with (see
    // funcs.MoonPosition's own comment for what this simplified model
    // does and doesn't capture).
    float[] MoonR = funcs.MoonPosition(stationLat, SHADE_DATE_ANGLE, SHADE_HOUR_ANGLE);
    f.tA = funcs.asin_ang(MoonR[3]);
    f.tB = funcs.atan2_ang(MoonR[2], MoonR[1]);

    f.Fx = -funcs.cos_ang(f.tB) * funcs.cos_ang(f.tA);
    f.Fy = -funcs.sin_ang(f.tB) * funcs.cos_ang(f.tA);
    f.Fz = -funcs.sin_ang(f.tA);

    // Sun direction for phase shading - needed regardless of
    // displayTexture (an untextured Moon should still show phases via
    // plain fill() shading - see writeFaceWIN3D), but not at all when
    // displayShadow is off (buildSubFace skips using it then - see its
    // own comment), same as Rup/Rright below being skipped when
    // !displayTexture. SunPosition() returns a unit vector already in
    // this exact frame (confirmed by hand: this is the same relationship
    // Sun3D.pde's own Fx/Fy/Fz have to its own tA/tB, just not negated
    // here since Fx/Fy/Fz above are themselves the negation of
    // SunPosition's raw output).
    if (this.displayShadow) {
      float[] SunR = funcs.SunPosition(stationLat, SHADE_DATE_ANGLE, SHADE_HOUR_ANGLE);
      f.Sx = SunR[1];
      f.Sy = SunR[2];
      f.Sz = SunR[3];
    }

    // Tidal locking, same (forward, up, right) construction as Sun3D.pde -
    // a plain (lat, lon) shift only locks WHICH POINT faces the station,
    // not the texture's roll around that point (checked by hand, same
    // conclusion as Sun3D.pde: it isn't enough on its own). F is "which
    // point faces the station"; pole is the celestial pole's direction in
    // this same frame (Declination = 90 in MoonPosition's underlying
    // formula - hour angle drops out entirely there, as it should).
    if (this.displayTexture) {
      float poleX = 0;
      float poleY = -funcs.cos_ang(stationLat);
      float poleZ = -funcs.sin_ang(stationLat);

      // right = pole x F
      f.Rrightx = poleY * f.Fz - poleZ * f.Fy;
      f.Rrighty = poleZ * f.Fx - poleX * f.Fz;
      f.Rrightz = poleX * f.Fy - poleY * f.Fx;
      float rightLen = sqrt(f.Rrightx * f.Rrightx + f.Rrighty * f.Rrighty + f.Rrightz * f.Rrightz);
      if (rightLen < 0.0001) {
        // Degenerate only if the Moon sits exactly at the celestial pole
        // itself (not physically possible here - Declination maxes out
        // at 23.45 - but guarded for safety rather than risking a NaN).
        f.Rrightx = 1;
        f.Rrighty = 0;
        f.Rrightz = 0;
        rightLen = 1;
      }
      f.Rrightx /= rightLen;
      f.Rrighty /= rightLen;
      f.Rrightz /= rightLen;

      // up = F x right
      f.Rupx = f.Fy * f.Rrightz - f.Fz * f.Rrighty;
      f.Rupy = f.Fz * f.Rrightx - f.Fx * f.Rrightz;
      f.Rupz = f.Fx * f.Rrighty - f.Fy * f.Rrightx;
    }

    return f;
  }

  void draw () {
    if (!this.displaySurface) return;

    WIN3D.graphics.strokeWeight(1);

    float ScaleX  = 1;
    float ScaleY  = 1;
    float CEN_lon = 0;
    float CEN_lat = 0;

    float r = MOON_RADIUS * celestialMagnification;
    float d = EARTH_MOON_DISTANCE - FLOAT_r_Earth;

    if(this.fitInSkyDome) {
      // fit the moon inside the sky sphere
      // bring it closer and resize it
      r *= Sky3D.radius / d;
      d = Sky3D.radius;
    }

    SkyFrame frame = computeFrame();

    // One-sided rendering, unconditionally - not just when
    // displayNightSide hides something: today, with the full sphere
    // always drawn solid, the far hemisphere (back-facing relative to
    // the station - see FaceVertex's own "facing" comment) is already
    // invisible, occluded by the near hemisphere in front of it, so
    // culling it outright changes nothing on screen. But a sphere is
    // convex - a given viewing ray that exits through a near-side point
    // generally re-enters and exits again through a far-side one - so
    // the moment displayNightSide actually skips a near-side face
    // (opening a real hole, not just an occluded one), that same ray
    // would otherwise carry straight through to whatever far-side face
    // sits behind it, showing the sphere's own far wall through the gap
    // instead of empty space/sky. Culling the far hemisphere outright is
    // what keeps that gap genuinely empty.
    for (float Alpha = 90; Alpha > -90; Alpha -= this.lat_step) {
      for (float Beta = 180; Beta > -180; Beta -= this.lon_step) {
        FaceVertex[] subFace = buildSubFace(Alpha, Beta, r, d, CEN_lon, CEN_lat, ScaleX, ScaleY, frame);
        if (shouldDrawSubFace(subFace)) {
          writeFaceWIN3D(subFace);
        }
      }
    }

    // tint()/fill() (see writeFaceWIN3D's own per-vertex phase darkening)
    // are PGraphics-wide state, not scoped to the shape that set them -
    // left at whatever the Moon's own last-drawn vertex happened to be,
    // they'd otherwise leak into every draw call after this one, this
    // frame (Earth3D.draw() runs right after Moon3D.draw() - see
    // WIN3D.pde) and, since nothing resets this state at the start of a
    // frame either, into next frame's Sun3D.draw() too, which runs
    // first. castShadows_CurrentSection.pde already pairs its own
    // tint()/noTint() calls the same way for the same reason.
    WIN3D.graphics.noTint();
    WIN3D.graphics.fill(255);
  }

  boolean shouldDrawSubFace (FaceVertex[] subFace) {
    float avgFacing = 0;
    float avgBrightness = 0;
    for (int s = 0; s < subFace.length; s++) {
      avgFacing += subFace[s].facing;
      avgBrightness += subFace[s].brightness;
    }
    avgFacing /= subFace.length;
    avgBrightness /= subFace.length;

    // One-sided: never the far hemisphere - see draw()'s own comment.
    if (avgFacing <= 0) return false;

    // Night side: skip faces in total darkness outright, rather than
    // just dimming them down to DARK_SIDE_AMBIENT, when it's off.
    if (!this.displayNightSide && avgBrightness <= DARK_SIDE_AMBIENT + 0.001) return false;

    return true;
  }

  FaceVertex[] buildSubFace (float Alpha, float Beta,
                                      float r, float d, float CEN_lon, float CEN_lat, float ScaleX, float ScaleY, SkyFrame frame) {
    FaceVertex[] subFace = new FaceVertex[4];

    float tb = 0;
    float ta = frame.ta;

    for (int s = 0; s < 4; s++) {
      FaceVertex vtx = new FaceVertex();

      float a = Alpha;
      float b = Beta;
      if (s == 2 || s == 3) a -= this.lat_step;
      if (s == 1 || s == 2) b -= this.lon_step;

      // corner position on the moon sphere
      float x0 = r * funcs.cos_ang(b - 90) * funcs.cos_ang(a);
      float y0 = r * funcs.sin_ang(b - 90) * funcs.cos_ang(a);
      float z0 = r * funcs.sin_ang(a);

      // This vertex's own direction (unit sphere, tb/ta applied, no
      // translation) - same transform as x1/y1/z1/x2/y2/z2 below, just
      // computed early and unscaled (divide out r). Needed unconditionally
      // now (not just when displayTexture, as it used to be): phase
      // shading below depends on it the same way the tidal-locking lookup
      // already did, and an untextured Moon should still show phases.
      float ux0 = x0 / r;
      float uy0 = y0 / r;
      float uz0 = z0 / r;

      float ux1 = ux0 * funcs.cos_ang(tb) - uy0 * funcs.sin_ang(tb);
      float uy1 = ux0 * funcs.sin_ang(tb) + uy0 * funcs.cos_ang(tb);
      float uz1 = uz0;

      float ux2 = ux1;
      float uy2 = uz1 * funcs.sin_ang(ta) + uy1 * funcs.cos_ang(ta);
      float uz2 = uz1 * funcs.cos_ang(ta) - uy1 * funcs.sin_ang(ta);

      // dot(this point's own outward normal, frame.F) - already needed by
      // the texture lookup below as its own "forward" axis component, and
      // now also by draw()'s one-sided culling (see its own comment), so
      // computed here unconditionally instead of only when displayTexture.
      float compForward = ux2 * frame.Fx + uy2 * frame.Fy + uz2 * frame.Fz;
      vtx.facing = compForward;

      if (this.displayTexture) {
        // Decomposed against frame's (forward, up, right) axes.
        float compUp = ux2 * frame.Rupx + uy2 * frame.Rupy + uz2 * frame.Rupz;
        float compRight = ux2 * frame.Rrightx + uy2 * frame.Rrighty + uz2 * frame.Rrightz;

        float lat = funcs.asin_ang(constrain(compUp, -1, 1)) - CEN_lat;
        float lon = Earth3D.unwrapLon(funcs.atan2_ang(-compForward, compRight) + 90 - CEN_lon, 0);
        vtx.u = (lon / ScaleX / LONGITUDE_SPAN + 0.5);
        vtx.v = (-lat / ScaleY / LATITUDE_SPAN + 0.5);
      }

      if (this.displayShadow) {
        // (ux2,uy2,uz2) is this point's own outward surface normal (a
        // sphere's normal is just the direction from its center), in the
        // same frame frame.Sx/Sy/Sz already is - so their dot product is
        // exactly the Lambertian "how directly does this patch face the
        // Sun" term. constrain()+the softness band (rather than a hard
        // >0/<=0 split) avoids a visibly faceted terminator edge at this
        // sphere's own tessellation (lat_step/lon_step).
        float sunDot = ux2 * frame.Sx + uy2 * frame.Sy + uz2 * frame.Sz;
        float litAmount = constrain((sunDot + TERMINATOR_SOFTNESS) / (2 * TERMINATOR_SOFTNESS), 0, 1);
        vtx.brightness = DARK_SIDE_AMBIENT + (1 - DARK_SIDE_AMBIENT) * litAmount;
      } else {
        vtx.brightness = 1; // fully lit - same as before phase shading existed
      }

      // rotate to location coordinates
      float x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
      float y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
      float z1 = z0;

      float x2 = x1;
      float y2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
      float z2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);

      // move out to lunar distance, in the moon's real current sky
      // direction - exactly -d*frame.F (F is defined as the direction
      // FROM the sphere TOWARD the station, so the sphere's own center,
      // relative to the station, sits at -F); reusing the already-computed
      // frame.Fx/Fy/Fz instead of recomputing cos(tB)*cos(tA) etc. here.
      x2 += -d * frame.Fx;
      y2 += -d * frame.Fy;
      z2 += -d * frame.Fz;

      vtx.x = x2;
      vtx.y = y2;
      vtx.z = z2;

      subFace[s] = vtx;
    }

    return subFace;
  }

  void writeFaceWIN3D (FaceVertex[] subFace) {
    WIN3D.graphics.beginShape();
    WIN3D.graphics.noStroke();
    if (this.displayTexture) {
      WIN3D.graphics.texture(this.Map);
    }

    for (int s = 0; s < subFace.length; s++) {
      // Per-vertex phase darkening: tint() modulates the bound texture's
      // own colors (what fill() would do for an untextured shape - see
      // Faces.pde's own SHADE.vertexRender_*() + fill() pattern, the same
      // "set it right before this vertex()" technique, just texture-aware
      // here since the Moon always has one bound when displayTexture).
      int gray = round(255 * subFace[s].brightness);
      if (this.displayTexture) {
        WIN3D.graphics.tint(gray);
      } else {
        WIN3D.graphics.fill(gray);
      }

      WIN3D.graphics.vertex(
        subFace[s].x * overallScale * WIN3D.scale,
        -subFace[s].y * overallScale * WIN3D.scale,
        subFace[s].z * overallScale * WIN3D.scale,
        subFace[s].u * this.Map.width,
        subFace[s].v * this.Map.height
      );
    }

    WIN3D.graphics.endShape(CLOSE);
  }


  public void to_XML (XML xml) {    XML parent = xml.addChild(this.CLASS_STAMP);
    XML_setBoolean(parent, "displaySurface", this.displaySurface);
    XML_setBoolean(parent, "displayTexture", this.displayTexture);
    XML_setBoolean(parent, "fitInSkyDome", this.fitInSkyDome);
  }

  public void from_XML (XML xml) {    XML parent = xml.getChild(this.CLASS_STAMP);
    this.displaySurface = XML_getBoolean(parent, "displaySurface");
    this.displayTexture = XML_getBoolean(parent, "displayTexture");
    this.fitInSkyDome = XML_getBoolean(parent, "fitInSkyDome");
  }
}
