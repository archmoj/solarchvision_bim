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
  boolean illuminateDaySide = true; // see buildSubFace's own comment on
                                     // what this actually brightens, and
                                     // why only a narrow band near the
                                     // terminator is ever affected.

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

  // An orthonormal (right, up) pair perpendicular to the given forward
  // vector, using the celestial pole as a stable "roughly up" reference -
  // shared by the Earth-facing texture lock (forward = F) and the
  // Sun-facing grid reorientation (forward = S) below, since both need
  // the exact same construction, just with a different forward vector.
  // Returns {rightX, rightY, rightZ, upX, upY, upZ}.
  float[] buildRightUp (float forwardX, float forwardY, float forwardZ, float stationLat) {
    // This is the NORTH celestial pole, not the south one - confirmed by
    // hand against the real compiled app: dot this against funcs.
    // SunPosition()'s own output at a genuinely high (northern) vs. low
    // (southern) declination and the north one comes out positive here,
    // the south one negative. (Earlier derivations in this file assumed
    // the negated version - substituting Declination=90 into
    // SunPosition()'s formula - was already north, which is what put the
    // real Moon's north pole visibly at the bottom of its own texture:
    // the "up" built from the south pole ends up pointing south.)
    float poleX = 0;
    float poleY = funcs.cos_ang(stationLat);
    float poleZ = funcs.sin_ang(stationLat);

    // right = pole x forward
    float rightX = poleY * forwardZ - poleZ * forwardY;
    float rightY = poleZ * forwardX - poleX * forwardZ;
    float rightZ = poleX * forwardY - poleY * forwardX;
    float rightLen = sqrt(rightX * rightX + rightY * rightY + rightZ * rightZ);
    if (rightLen < 0.0001) {
      // Degenerate only if forward sits exactly on the celestial pole
      // itself (not physically possible for F or S here - Declination
      // maxes out at 23.45 - but guarded for safety rather than risking
      // a NaN).
      rightX = 1;
      rightY = 0;
      rightZ = 0;
      rightLen = 1;
    }
    rightX /= rightLen;
    rightY /= rightLen;
    rightZ /= rightLen;

    // up = forward x right
    float upX = forwardY * rightZ - forwardZ * rightY;
    float upY = forwardZ * rightX - forwardX * rightZ;
    float upZ = forwardX * rightY - forwardY * rightX;

    return new float[]{rightX, rightY, rightZ, upX, upY, upZ};
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
    // (Gright, Gup, S) is the grid's own basis - the mesh (buildSubFace's
    // own Alpha/Beta loop) is built directly in this basis instead of the
    // old body-frame/celestial-pole one, so the grid's own "latitude"
    // lines become circles of constant angle from the Sun - exactly what
    // the terminator (brightness's own lit/dark boundary) already is.
    // That's what keeps displayNightSide's cutoff following an actual
    // grid line/mesh boundary instead of slicing diagonally across faces
    // at this sphere's tessellation (see buildSubFace's own comment) -
    // only computed, and only used, when displayShadow is on; the
    // texture's own lock to F/Rup/Rright below is entirely unaffected by
    // this - the grid defines where the mesh's faces/edges fall, the
    // texture lock defines what's painted on them, independently.
    float Grightx, Grighty, Grightz;
    float Gupx, Gupy, Gupz;
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

      // Grid basis (see SkyFrame's own comment on Gright/Gup) - same
      // construction as F/Rup/Rright below, just built from S instead.
      float[] gridRightUp = buildRightUp(f.Sx, f.Sy, f.Sz, stationLat);
      f.Grightx = gridRightUp[0];
      f.Grighty = gridRightUp[1];
      f.Grightz = gridRightUp[2];
      f.Gupx = gridRightUp[3];
      f.Gupy = gridRightUp[4];
      f.Gupz = gridRightUp[5];
    }

    // Tidal locking, same (forward, up, right) construction as Sun3D.pde -
    // a plain (lat, lon) shift only locks WHICH POINT faces the station,
    // not the texture's roll around that point (checked by hand, same
    // conclusion as Sun3D.pde: it isn't enough on its own). F is "which
    // point faces the station"; the pole reference used here is the
    // NORTH celestial pole (see buildRightUp()'s own comment on how
    // that's confirmed, and the real bug it caused when it was backwards).
    if (this.displayTexture) {
      float[] textureRightUp = buildRightUp(f.Fx, f.Fy, f.Fz, stationLat);
      f.Rrightx = textureRightUp[0];
      f.Rrighty = textureRightUp[1];
      f.Rrightz = textureRightUp[2];
      f.Rupx = textureRightUp[3];
      f.Rupy = textureRightUp[4];
      f.Rupz = textureRightUp[5];
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
      // Night side, at the row level - see rowIsEntirelyDark()'s own
      // comment.
      if (this.displayShadow && !this.displayNightSide && rowIsEntirelyDark(Alpha)) continue;

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

  // Whether every face in the Alpha row starting at this Alpha (down to
  // Alpha - lat_step) is wholly inside the dark floor, so draw() can skip
  // the whole row without building any of its faces just to throw them
  // away. Only meaningful (and only ever called) when displayShadow is
  // on - a point's sunDot reduces to exactly sin(Alpha) for this grid,
  // independent of Beta (see buildSubFace's own comment on why - its
  // basis is literally built from S), so an entire row is either wholly
  // dark or isn't. Alpha itself (not Alpha - lat_step) is this row's own
  // least-dark edge - sin() is increasing on this range, so if even that
  // edge is already at the floor, the rest of the row, being more
  // negative still, certainly is too. Confirmed by hand against the real
  // compiled app to make exactly the same skip/draw calls, row for row,
  // as the old per-face, post-hoc brightness check did.
  //
  // This checks the same RAW litAmount buildSubFace() starts from, before
  // illuminateDaySide's own sqrt() boost (see its own comment) - that
  // boost still maps 0 to 0, so it never turns a row this considers
  // entirely dark into a visibly lit one. It could, in principle, turn a
  // row with a tiny but nonzero raw litAmount (one this already judges
  // "dark enough to skip") into one whose boosted brightness is a little
  // more than imperceptible - confirmed by hand not to actually happen at
  // this sphere's current lat_step: every discrete Alpha value here lands
  // either exactly on the dark floor or comfortably past 1% litAmount,
  // nothing in between. A much finer lat_step could someday change that.
  boolean rowIsEntirelyDark (float Alpha) {
    float topLitAmount = constrain((funcs.sin_ang(Alpha) + TERMINATOR_SOFTNESS) / (2 * TERMINATOR_SOFTNESS), 0, 1);
    return topLitAmount <= 0.001;
  }

  // One-sided rendering: never the far hemisphere - see draw()'s own
  // comment on why this matters once some faces get skipped outright.
  // Unlike the night-side skip above, this can't be hoisted to the row
  // level: facing depends on F (the station direction), not S, and this
  // grid's own axes are built from S - so, unlike sunDot, a point's
  // facing value genuinely depends on both Alpha and Beta here, not
  // Alpha alone.
  boolean shouldDrawSubFace (FaceVertex[] subFace) {
    float avgFacing = 0;
    for (int s = 0; s < subFace.length; s++) {
      avgFacing += subFace[s].facing;
    }
    avgFacing /= subFace.length;

    return avgFacing > 0;
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

      // This vertex's own outward unit normal, in world/station frame -
      // everything else below (position, facing, texture, brightness) is
      // derived from this one direction, regardless of which basis built
      // it.
      float ux2, uy2, uz2;

      if (this.displayShadow) {
        // Grid built directly in the Sun-facing (Gright, Gup, S) basis
        // (see SkyFrame's own comment) - Alpha/Beta here parameterize
        // this basis exactly the way the old body-frame pipeline below
        // parameterizes (right, up, forward) = (X axis, Z axis, Y axis)
        // via tb/ta, just aimed at S instead of the celestial pole.
        float gx = funcs.cos_ang(b - 90) * funcs.cos_ang(a);
        float gy = funcs.sin_ang(b - 90) * funcs.cos_ang(a);
        float gz = funcs.sin_ang(a);
        ux2 = gx * frame.Grightx + gy * frame.Gupx + gz * frame.Sx;
        uy2 = gx * frame.Grighty + gy * frame.Gupy + gz * frame.Sy;
        uz2 = gx * frame.Grightz + gy * frame.Gupz + gz * frame.Sz;
      } else {
        // No Sun-relative terminator to align a grid with when phase
        // shading itself is off (displayNightSide never hides anything
        // in that case either - see shouldDrawSubFace()), so this is the
        // original body-frame grid, tilted by station latitude alone
        // (tb/ta) - entirely unaffected by any of the above.
        float x0 = funcs.cos_ang(b - 90) * funcs.cos_ang(a);
        float y0 = funcs.sin_ang(b - 90) * funcs.cos_ang(a);
        float z0 = funcs.sin_ang(a);

        float x1 = x0 * funcs.cos_ang(tb) - y0 * funcs.sin_ang(tb);
        float y1 = x0 * funcs.sin_ang(tb) + y0 * funcs.cos_ang(tb);
        float z1 = z0;

        ux2 = x1;
        uy2 = z1 * funcs.sin_ang(ta) + y1 * funcs.cos_ang(ta);
        uz2 = z1 * funcs.cos_ang(ta) - y1 * funcs.sin_ang(ta);
      }

      // dot(this point's own outward normal, frame.F) - needed by the
      // texture lookup below as its own "forward" axis component, and
      // also by draw()'s one-sided culling (see its own comment) -
      // computed unconditionally either way.
      float compForward = ux2 * frame.Fx + uy2 * frame.Fy + uz2 * frame.Fz;
      vtx.facing = compForward;

      if (this.displayTexture) {
        // Decomposed against frame's (forward, up, right) axes - entirely
        // independent of which basis produced (ux2, uy2, uz2) above: the
        // texture is still locked to F (Earth), never to S (Sun), however
        // the mesh itself is now built.
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
        // >0/<=0 split) avoids a visibly faceted terminator edge within a
        // single grid cell - the grid basis above is what keeps the
        // terminator from cutting diagonally *across* cells in the first
        // place, this is what keeps it smooth *within* one.
        float sunDot = ux2 * frame.Sx + uy2 * frame.Sy + uz2 * frame.Sz;
        float litAmount = constrain((sunDot + TERMINATOR_SOFTNESS) / (2 * TERMINATOR_SOFTNESS), 0, 1);

        if (this.illuminateDaySide) {
          // Brightness is already fully saturated (1.0) everywhere beyond
          // this narrow TERMINATOR_SOFTNESS band - confirmed by hand
          // against the real compiled app: from about 8.6deg past the
          // terminator all the way to the sub-solar point itself, nothing
          // left here to brighten. This is the one place that still can
          // be: a square-root curve leaves litAmount's own two endpoints
          // (0 at the dark edge, 1 at the lit edge) exactly where they
          // were, but lifts everything in between noticeably closer to
          // fully lit (e.g. 0.25 -> 0.5) - a flatter, less steeply-shaded
          // transition. That's also a closer match to how the real
          // Moon's rough, light-scattering surface actually looks from
          // Earth than smooth Lambertian shading does: notably flatter/
          // brighter across its whole visible disk than a plain cosine
          // falloff would suggest, not just right at the sub-solar point.
          litAmount = sqrt(litAmount);
        }

        vtx.brightness = DARK_SIDE_AMBIENT + (1 - DARK_SIDE_AMBIENT) * litAmount;
      } else {
        vtx.brightness = 1; // fully lit - same as before phase shading existed
      }

      // Scale back out to the sphere's real radius, then move out to
      // lunar distance, in the moon's real current sky direction -
      // exactly -d*frame.F (F is defined as the direction FROM the
      // sphere TOWARD the station, so the sphere's own center, relative
      // to the station, sits at -F).
      vtx.x = r * ux2 - d * frame.Fx;
      vtx.y = r * uy2 - d * frame.Fy;
      vtx.z = r * uz2 - d * frame.Fz;

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
