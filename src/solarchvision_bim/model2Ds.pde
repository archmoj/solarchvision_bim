class Model2Ds {

  final static String CLASS_STAMP = "model2D";

  Model2Ds () { // constructor
    makeEmpty(0);
  }

  boolean displayAll = true;

  // How many camera-facing vertical shading quads addToFaceGrid() builds
  // per tree (see its own comment) - only 1, 2 and 4 are meaningful:
  //   1: just the camera-facing quad itself (angles[0], t0).
  //   2: that quad plus the one perpendicular to it (t0 + 90 degrees).
  //   4: both of those plus the two diagonals, t0 +45/+135 degrees - the
  //      full cross this already built before this constant existed.
  // Defaults to 2 rather than 4: the two canopy-cap quads already catch
  // a straight-overhead sun that the vertical quads alone would miss, so
  // the diagonal pair's own benefit (a closer-to-face-on quad for a sun
  // angle well off the camera-facing one) is a real but smaller
  // improvement, not something every shading study needs at the extra
  // cost of twice as many quads to ray-test against.
  int verticalShadingSections = 2;

  // Whether addToFaceGrid() (below) also contributes people, so they show
  // up in the shaded viewport at all. Unlike trees, a person only ever
  // gets a single camera-facing quad - no canopy cap, and
  // verticalShadingSections above doesn't apply to them - and that quad
  // is flagged non-shadow-casting (entireFaceCastsShadow in
  // isIntersectedFaces.pde), so a person is visible to and can be
  // darkened by other things' shadows without ever casting one themselves.
  boolean showPeopleInShade = true;

  // How a person is actually painted once showPeopleInShade above has let
  // them into the grid at all - see shadeViewport3D.pde's own use of this.
  // true (the default): pasted with their own real photo colors, exactly
  // like a tree - no radiance computation needed for them at all, same
  // reasoning as a tree's own raw paste.
  // false: the same flat grayscale radiance fill as any opaque surface
  // (wall, roof, ...), shaped by their own texture's alpha instead of a
  // rectangle - so a person reads as just another shaded surface rather
  // than a recognizable photo, consistent with everything else in the
  // study, at the cost of losing their own color entirely.
  boolean peopleUseExactTexture = true;

  int num;
  float[][] XYZS;

  void makeEmpty (int n) {
    beginScene3DChange();

    this.num = n;
    this.XYZS = new float [n][4];
    this.Kind = new Model2DKind [n];
    this.FileIndex = new int [n];
    this.Mirror = new boolean [n];

    if (allGroups != null) {
      for (int q = 0; q < allGroups.num; q++) {
        allGroups.Model2Ds[q][0] = 0;
        allGroups.Model2Ds[q][1] = -1;
      }
    }

    if (Select3D != null) {
      Select3D.deselect_Groups();
      Select3D.deselect_Model2Ds();
    }

    endScene3DChange();
  }

  // `t` ("PEOPLE"/"TREES") picks the kind; `m`'s magnitude is now always
  // a LOCAL index within that kind's own file list - 0 meaning "pick a
  // random variant", otherwise clamped to [1, kind.fileCount] (both
  // ends: unlike the old flat-index scheme, trees are no longer able to
  // silently run past the end of the array, since there's no second
  // kind's worth of entries sharing the same number space to run into).
  // `m`'s sign still picks left/right mirroring, same as before.
  //
  // Note for callers building a Tree2/Person script command string
  // (see mouseClicked.pde's click-to-create handling): `m` no longer
  // needs peopleFileCount added to it first - a tree-local index is
  // passed through exactly as-is now, regardless of how many PEOPLE
  // files happen to exist.
  void create (String t, int m, float x, float y, float z, float s) {

    Model2DKind kind = model2DKindByTag(t);

    int n = abs(m);

    if (n == 0) {
      n = (kind.fileCount > 0) ? int(random(1, 1 + kind.fileCount)) : 0;
    } else if (n > kind.fileCount) {
      n = kind.fileCount;
    }

    boolean mirror =
      m > 0 ? false :
      m < 0 ? true :
      int(random(2)) == 0;

    this.Kind = (Model2DKind[]) append(this.Kind, kind);
    this.FileIndex = (int[]) append(this.FileIndex, n);
    this.Mirror = (boolean[]) append(this.Mirror, mirror);

    float[][] Temp_XYZS = {
      {
        x, y, z, s
      }
    };
    this.XYZS = (float[][]) concat(this.XYZS, Temp_XYZS);

    this.num += 1;

    if (kind.isTree()) {

      if (User3D.creatorMeshOrSolidMode != 0) {

        float x0 = x;
        float y0 = y;
        float z0 = 0.5 * s + z;
        float r0 = 0.4 * s; // <<<<<<< approximate

        allSolids.create(x0, y0, z0, 2, 2, 2, r0, r0, r0, 0, 0, 0, User3D.creatorMeshOrSolidMode);
      }
    }

    if (allGroups.num > 0) allGroups.Model2Ds[allGroups.num - 1][1] = this.num - 1;
  }


  float getX (int n) {
    return this.XYZS[n][0];
  }

  float getY (int n) {
    return this.XYZS[n][1];
  }

  float getZ (int n) {
    return this.XYZS[n][2];
  }

  float getS (int n) {
    return this.XYZS[n][3];
  }

  void setX (int n, float f) {
    this.XYZS[n][0] = f;
  }

  void setY (int n, float f) {
    this.XYZS[n][1] = f;
  }

  void setZ (int n, float f) {
    this.XYZS[n][2] = f;
  }

  void setS (int n, float f) {
    this.XYZS[n][3] = f;
  }

  void move (int n, float dx, float dy, float dz) {
    this.XYZS[n][0] += dx;
    this.XYZS[n][1] += dy;
    this.XYZS[n][2] += dz;
  }

  void magS (int n, float f) {
    this.XYZS[n][3] *= f;
  }

  // Per-instance identity: which kind (PEOPLE_KIND/TREES_KIND), which
  // local index within that kind's own Images/ImagePath/ImageRatios
  // array, and whether it's mirrored left/right. Replaces the old
  // single `int[] MAP` (a signed, flat-array position that silently
  // meant something different whenever either folder's file count
  // changed - see model2DKind.pde's own comment).
  Model2DKind[] Kind = new Model2DKind[0];
  int[] FileIndex = new int[0];
  boolean[] Mirror = new boolean[0];

  int num_visualFaces = 3; // internal - number of faces: Vertical, Horizontal Front, Horizontal Back

  float[][] Vertices;
  int[][] Faces;

  // f is an INSTANCE index (0..num-1), not a texture index - e.g.
  // `allModel2Ds.isTree(f)`, not a lookup against some flat image
  // array position.
  boolean isTree (int f) {
    return this.Kind[f].isTree();
  }

  boolean isScalable (int f) {
    return this.Kind[f].isScalable();
  }

  void load_images () {
    for (Model2DKind kind : ALL_MODEL2D_KINDS) {
      kind.loadImages();
    }
  }

  // --- Shared billboard sizing / canopy-cap math ------------------------
  //
  // `s` (Model2Ds.XYZS[*][3], read via getS()) is always the instance's
  // real-world HEIGHT - that meaning doesn't change here. rh (half-height)
  // stays 0.5*s, same as before and independent of the image's own aspect
  // ratio; every quad's vertical extent (2*rh) is still just the tree's
  // or person's own size `s`.
  //
  // rw (half-width) is the one thing that used to differ by caller: draw()
  // already multiplied rh by ImageRatios[n] to get the right *rendered*
  // width for both people and trees, but addToFaceGrid() and
  // castShadows() each kept their own older copy that assumed a tree's
  // image was square (rw == rh) and only used ImageRatios[n] for a
  // person. halfWidthFromHalfHeight() is that one multiplication, now
  // shared by all three, so a tree's shading quads, its shadow mask and
  // its WIN3D billboard all agree on the same half-width for the same
  // image - no more square-only special case for trees.
  float halfWidthFromHalfHeight (float rh, float imageRatio) {
    return rh * imageRatio;
  }

  // Where the flat tree "canopy cap" plane sits, as a fraction of the
  // tree's own full height (2*rh) above its base - replaces the
  // unconditional `ratio = 0.5` constant addToFaceGrid(), draw() and
  // castShadows() each used to hard-code for this (see addToFaceGrid()'s
  // own "canopy cap" comment below for what the cap itself represents).
  //
  // The cap's footprint is a square whose side is the tree's own width
  // (2*rw = 2*rh*imageRatio - see halfWidthFromHalfHeight() above and
  // addToFaceGrid()'s two-wing canopy-cap comment for why). For a square
  // image (imageRatio 1) the formula below comes out to the previous
  // constant, 0.5. For a narrower image - say imageRatio 0.5, i.e. width
  // = 0.5 * height, like a tall narrow conifer - it comes out higher,
  // 0.75: fraction = 1 - imageRatio / 2. A wider image (imageRatio > 1)
  // sits correspondingly lower. constrain() keeps an extreme aspect
  // ratio from pushing the cap below the tree's base (fraction < 0,
  // imageRatio > 2) or above its own top (fraction > 1, imageRatio < 0,
  // which can't happen, but keeps the formula honest either way).
  float canopyCapHeightFraction (float imageRatio) {
    return constrain(1.0 - imageRatio / 2.0, 0.0, 1.0);
  }

  // How much of the texture's own vertical extent (measured down from
  // its top row) the canopy cap samples - addToFaceGrid()'s own "canopy
  // cap" comment explains the two wings this gets used for, each
  // capWidthLen x capHeightLen = (2*rw) x rw. Previously every caller
  // just reused the same `ratio` as canopyCapHeightFraction() above for
  // this too (fine only because both happened to be the hardcoded 0.5),
  // which stretched or squashed the cropped region to fit a fixed half
  // of the image regardless of its actual shape. This keeps that crop's
  // own pixel aspect ratio matched to the wing's physical width:height
  // (2:1) instead - a narrower image reaches the wing's width in fewer
  // of its own rows, so fewer rows are sampled; a wider one needs more.
  // fraction = imageRatio / 2, constrained to [0, 1] (a wing can never
  // sample more than the whole image, texH*1).
  //
  // This comes out to exactly 1 - canopyCapHeightFraction(imageRatio)
  // (both fall out of the same underlying relationship), but is kept as
  // its own function rather than inlined as "1 - ratio" at each call
  // site, so each caller states outright which of the two quantities -
  // a world-space position or a texture crop - it actually means.
  float canopyCapTextureFraction (float imageRatio) {
    return constrain(imageRatio / 2.0, 0.0, 1.0);
  }


  // Called by buildFaceGrid() (isIntersectedFaces.pde) to feed trees into
  // the raycasting grid used for shading, the same way allFaces.
  // addToFaceGrid()/allModel1Ds.addToFaceGrid() already feed faces and
  // branches. Each tree contributes several vertical quads crossed through
  // its trunk's center line, plus two flat "canopy cap" quads (see below) -
  // this is Option 2 from the investigation (an imaginary canopy solid,
  // e.g. an icosahedron, would shade identically regardless of species;
  // this reuses the tree's own texture instead). Each quad is
  // geometrically just a flat rectangle, so isIntersectedFaces.pde's
  // testFaceHit() also samples that texture's alpha channel at the hit
  // point (entireFaceAlphaTexture/entireFaceUVBasis, populated per quad
  // below) and treats a transparent pixel - outside the foliage silhouette
  // - as no hit, instead of letting the quad's full bounding rectangle
  // block the ray.
  //
  // The first quad (angles[0] below) is built camera-facing, exactly like
  // draw()'s own WIN3D billboard (same `t` formula - WIN3D.rotationZ in
  // orthographic, atan2() against WIN3D.cameraX/Y in perspective, and the
  // same MAP[f]<0 flip trick), and the two canopy-cap quads are built off
  // that same orientation rather than a fixed one. buildFaceGrid() only
  // ever runs outside the normal per-frame draw() cycle (ShadeViewport()/
  // preBakeViewport()/calculate_VertexSolar_array() - see model1Ds.pde's
  // own addToFaceGrid() comment on that), so "the camera" here means
  // whatever WIN3D's camera fields hold at the moment the grid is built,
  // same as this.draw(TypeWindow.WIN3D) would use if called right then -
  // this is NOT re-evaluated per ray or per sun angle. The point:
  // shadeViewport3D.pde now samples this tree's own texture color directly
  // at the ray hit, so for THAT sampled color to match what the WIN3D
  // render actually shows from the current camera, the quad primary
  // camera rays are most likely to land on needs to be the same quad, at
  // the same orientation, draw(TypeWindow.WIN3D) would have drawn.
  //
  // People get a much simpler treatment, gated by showPeopleInShade above:
  // a single camera-facing quad (same t0, no extra angles, no canopy cap -
  // verticalShadingSections above only applies to trees), and flagged
  // non-shadow-casting (entireFaceCastsShadow.add(false), see
  // isIntersectedFaces.pde's own declaration) rather than left out
  // entirely like before - see showPeopleInShade's own comment for why.
  //
  // More than one vertical quad (see verticalShadingSections above): a
  // sun ray coming in from well off the camera-facing quad's own angle
  // (e.g. from the southeast while the camera faces north) grazes it at a
  // shallow, near edge-on angle - exactly where a flat billboard's
  // silhouette is thinnest and least representative of a real canopy's
  // actual cross-section from that direction. Each extra quad, offset
  // +90/+45/+135 degrees from the camera-facing one, gives some sun angle
  // away from the camera a quad closer to face-on instead, the same
  // benefit a real canopy's roughly round footprint would give for free -
  // this part is unchanged by rotating the whole set to track the camera,
  // since it's the quads' spacing *relative to each other* that matters
  // here, not which compass direction angles[0] happens to point at any
  // given moment.
  //
  // A tree's image no longer has to be square: rh (half-height) and rw
  // (half-width) are computed the same way draw()'s own billboard already
  // does - see halfWidthFromHalfHeight() above - so a narrow or wide
  // image's shading quads keep its real proportions instead of being
  // stretched into a square the tree's own size `s`. Only rh (the tree's
  // real-world height) is shared by every quad below; rw now varies per
  // image via its ImageRatios entry.
  void addToFaceGrid () {

    if (!this.displayAll) return; // hidden entirely - keep hasShadingContribution() above honest

    for (int f = 0; f < this.num; f++) {

      Model2DKind kind = this.Kind[f];
      int n = this.FileIndex[f];
      boolean isTree = kind.isTree();
      if (!isTree && !this.showPeopleInShade) continue; // a person, and showPeopleInShade says to leave them out

      float x = this.getX(f);
      float y = this.getY(f);
      float z = this.getZ(f);
      float s = this.getS(f);

      float rh = 0.5 * s; // half-height - real-world height, independent of the image's aspect ratio
      float rw = this.halfWidthFromHalfHeight(rh, kind.imageRatio(n)); // half-width - follows the image's own aspect ratio, same formula draw() uses for its billboard
      PImage tex = kind.Images[n];
      int texW = tex.width;
      int texH = tex.height;

      // Same camera-facing formula as the WIN3D branch below - note it
      // needs x/y in that branch's own (overallScale-multiplied) units to
      // compare against WIN3D.cameraX/Y, even though every point this
      // method actually emits stays in this method's own raw/unscaled
      // units (matching allFaces/allModel1Ds's own grid convention).
      float xScaled = x * overallScale;
      float yScaled = y * overallScale;
      float t0 = PI + WIN3D.rotationZ * PI / 180.0;
      if (WIN3D.projectionTypeIndex == 1) t0 = atan2(yScaled - WIN3D.cameraY, xScaled - WIN3D.cameraX) + 0.5 * PI;
      if (this.Mirror[f]) t0 += PI;

      if (!isTree) {
        // A person: exactly one camera-facing quad, full height, no cap,
        // no extra angles - see showPeopleInShade's own comment above.
        // rw (computed above via halfWidthFromHalfHeight()) already
        // follows this person's own ImageRatios entry, same as draw()'s
        // own billboard.
        float dx = rw * cos(t0);
        float dy = rw * sin(t0);

        float x1 = x - dx, y1 = y - dy;
        float x2 = x + dx, y2 = y + dy;
        float zBottom = z;
        float zTop = z + 2 * rh;

        int i0 = entirePointsX.size();
        entirePointsX.add(x1); entirePointsY.add(y1); entirePointsZ.add(zBottom);
        entirePointsX.add(x2); entirePointsY.add(y2); entirePointsZ.add(zBottom);
        entirePointsX.add(x2); entirePointsY.add(y2); entirePointsZ.add(zTop);
        entirePointsX.add(x1); entirePointsY.add(y1); entirePointsZ.add(zTop);

        entireFaces.add(new int[] { i0, i0 + 1, i0 + 2, i0 + 3 });

        entireFaceAlphaTexture.add(tex);
        entireFaceCastsShadow.add(false); // the whole point - see showPeopleInShade's own comment

        float widthLen = 2 * rw;
        float widthDirX = (widthLen > FLOAT_tiny) ? (x2 - x1) / widthLen : 1;
        float widthDirY = (widthLen > FLOAT_tiny) ? (y2 - y1) / widthLen : 0;
        entireFaceUVBasis.add(new float[] {
          x1, y1, zBottom, widthDirX, widthDirY, widthLen, 0, 0, 1, 2 * rh, texH, 0
        });

        continue; // no cap, no extra angles for a person
      }

      // See verticalShadingSections's own declaration above for what each
      // value means; angles beyond whatever it's set to are simply never
      // built, rather than this array always being the full set of 4 and
      // something downstream filtering it back down.
      float[] angles;
      if (this.verticalShadingSections <= 1) {
        angles = new float[] { t0 };
      } else if (this.verticalShadingSections == 2) {
        angles = new float[] { t0, t0 + HALF_PI };
      } else {
        angles = new float[] { t0, t0 + HALF_PI, t0 + QUARTER_PI, t0 + HALF_PI + QUARTER_PI };
      }

      for (int a = 0; a < angles.length; a++) {
        float t = angles[a];

        float dx = rw * cos(t);
        float dy = rw * sin(t);

        float x1 = x - dx, y1 = y - dy;
        float x2 = x + dx, y2 = y + dy;
        float zBottom = z;
        float zTop = z + 2 * rh;

        int i0 = entirePointsX.size();
        entirePointsX.add(x1); entirePointsY.add(y1); entirePointsZ.add(zBottom);
        entirePointsX.add(x2); entirePointsY.add(y2); entirePointsZ.add(zBottom);
        entirePointsX.add(x2); entirePointsY.add(y2); entirePointsZ.add(zTop);
        entirePointsX.add(x1); entirePointsY.add(y1); entirePointsZ.add(zTop);

        entireFaces.add(new int[] { i0, i0 + 1, i0 + 2, i0 + 3 });

        entireFaceAlphaTexture.add(tex);
        entireFaceCastsShadow.add(true); // a tree - shades others normally

        float widthLen = 2 * rw;
        float widthDirX = (widthLen > FLOAT_tiny) ? (x2 - x1) / widthLen : 1;
        float widthDirY = (widthLen > FLOAT_tiny) ? (y2 - y1) / widthLen : 0;
        // Full image height in play here (bottom row at heightFrac=0, top
        // row at heightFrac=1) - these are the vertical billboards, where
        // the whole texture (trunk included) is legitimately on screen.
        entireFaceUVBasis.add(new float[] {
          x1, y1, zBottom, widthDirX, widthDirY, widthLen, 0, 0, 1, 2 * rh, texH, 0
        });
      }

      // Two flat "canopy cap" quads, so a sun directly overhead still
      // casts a shadow: the four vertical quads above are all vertical,
      // so a ray straight down the +-Z axis runs parallel to every one of
      // them (testFaceHit()'s own parallel-ray check rejects it outright)
      // and would otherwise pass clean through the tree. Mirrors the
      // WIN3D "horizontal mask" quads in draw() above (same x1/x2/x3/x4
      // and z + 2*rh*ratio math, same canopyCapHeightFraction() call),
      // built off t0 - the same camera-facing orientation as the first
      // vertical quad above, rather than a fixed direction - so they sit
      // flush against that quad's own base edge instead of an arbitrary
      // other one. The two wings (back_front = -1, +1) sit on opposite
      // sides of the x1-x2 edge and together tile into one full square
      // footprint whose side is the tree's own WIDTH (2*rw), not
      // necessarily its height `s` any more - see halfWidthFromHalfHeight()
      // for how rw now follows the image's own aspect ratio instead of
      // always equalling rh.
      //
      // ratio (from canopyCapHeightFraction()) also decides how high that
      // footprint sits: 0.5 - the tree's own mid-height - for a square
      // image, higher for a narrower one (and lower for a wider one) -
      // see canopyCapHeightFraction()'s own comment.
      //
      // Only the texture's own top portion is sampled (vPixelNear =
      // texH*texRatio down to vPixelFar = 0, i.e. the top row range sized
      // by canopyCapTextureFraction() above) rather than the full height
      // used by the vertical quads above: the lower part of a tree
      // texture is trunk, and a trunk cross-section doesn't belong in a
      // flat overhead cap - that would read as the canopy being solid
      // near the trunk and only thinning out near its edge, which has
      // nothing to do with where the trunk pixels actually sit in the
      // image. texRatio (not ratio) sizes this crop specifically so it
      // keeps the image's own aspect ratio once stretched across the
      // wing - see canopyCapTextureFraction()'s own comment.
      if (kind.hasCanopyCap()) {
        float ratio = this.canopyCapHeightFraction(kind.imageRatio(n));
        float texRatio = this.canopyCapTextureFraction(kind.imageRatio(n)); // how much of the texture's own height the cap samples - see that method's own comment for why this differs from `ratio` above
        float capZ = z + 2 * rh * ratio;

        float capDX = rw * cos(t0);
        float capDY = rw * sin(t0);
        float capX1 = x - capDX, capY1 = y - capDY; // t0, matching the first vertical quad above
        float capX2 = x + capDX, capY2 = y + capDY;

        for (int back_front = -1; back_front <= 1; back_front += 2) {

          float rot = back_front * HALF_PI + t0;
          float wdx = rw * cos(rot);
          float wdy = rw * sin(rot);

          float capX3 = capX2 + wdx, capY3 = capY2 + wdy;
          float capX4 = capX1 + wdx, capY4 = capY1 + wdy;

          int i0 = entirePointsX.size();
          entirePointsX.add(capX1); entirePointsY.add(capY1); entirePointsZ.add(capZ);
          entirePointsX.add(capX2); entirePointsY.add(capY2); entirePointsZ.add(capZ);
          entirePointsX.add(capX3); entirePointsY.add(capY3); entirePointsZ.add(capZ);
          entirePointsX.add(capX4); entirePointsY.add(capY4); entirePointsZ.add(capZ);

          entireFaces.add(new int[] { i0, i0 + 1, i0 + 2, i0 + 3 });

          entireFaceAlphaTexture.add(tex);
          entireFaceCastsShadow.add(true); // a tree's canopy cap - shades others normally

          float capWidthLen = 2 * rw; // capX1 -> capX2
          float capWidthDirX = (capWidthLen > FLOAT_tiny) ? (capX2 - capX1) / capWidthLen : 1;
          float capWidthDirY = (capWidthLen > FLOAT_tiny) ? (capY2 - capY1) / capWidthLen : 0;
          float capHeightLen = rw; // capX1/capX2 -> capX4/capX3 (the wing's own reach)
          float capHeightDirX = (capHeightLen > FLOAT_tiny) ? wdx / capHeightLen : 0;
          float capHeightDirY = (capHeightLen > FLOAT_tiny) ? wdy / capHeightLen : 0;

          entireFaceUVBasis.add(new float[] {
            capX1, capY1, capZ, capWidthDirX, capWidthDirY, capWidthLen, capHeightDirX, capHeightDirY, 0, capHeightLen, texH * texRatio, 0
          });
        }
      }
    }
  }

  // Whether addToFaceGrid() above would actually add anything to the
  // raycasting grid right now - a tree always would, a person only if
  // showPeopleInShade. shadeViewport3D.pde/preBakeViewport3D.pde use this to
  // decide whether forcing a full grid rebuild on every bake (see their
  // own comments on why camera-facing billboards need that at all) is
  // worth paying for - an empty scene, or one with only trees and no
  // people (or vice versa with showPeopleInShade off), shouldn't pay for
  // a forced rebuild just because this class exists. O(this.num), and
  // short-circuits on the first contributing entry, so it stays cheap
  // even called once per bake.
  boolean hasShadingContribution () {
    if (!this.displayAll) return false; // hidden entirely - addToFaceGrid() has nothing to add either way

    for (int f = 0; f < this.num; f++) {
      if (this.Kind[f].isTree()) return true;
      if (this.showPeopleInShade) return true;
    }
    return false;
  }

  void draw (int target_window) {

    this.Faces = new int [this.num * this.num_visualFaces][4];
    this.Vertices = new float [4 * this.num * this.num_visualFaces][5]; // note we are keeping u & v at 3rd and 4th members

    boolean proceed = true;

    if (this.displayAll == false) {
      proceed = false;
    }

    if ((target_window == TypeWindow.STUDY) ||
        (target_window == TypeWindow.WORLD)) {

      proceed = false;
    }

    if (proceed) {

      if (User3D.exporterMaterialLibrary) {

        if ((target_window == TypeWindow.HTML) ||
            (target_window == TypeWindow.OBJ3D)) {

          // One used[] tally per kind now (each kind owns its own local
          // index space) rather than one flat array shared by both -
          // see model2DKind.pde's own comment on why a single shared
          // space was the actual bug.
          for (Model2DKind kind : ALL_MODEL2D_KINDS) {

            int[] ImageUsed = new int [kind.fileCount + 1];

            for (int f = 0; f < this.num; f++) {
              if (this.Kind[f] == kind) {
                ImageUsed[this.FileIndex[f]] += 1;
              }
            }

            for (int i = 1; i <= kind.fileCount; i++) {

              if (ImageUsed[i] != 0) {

                String old_Texture_path = kind.ImagePath[i];

                String new_Texture_path = "";

                String opacity_Texture_path = "";

                String the_filename = "";

                if (kind.ImagePath[i].equals("")) {
                } else {

                  the_filename = old_Texture_path.substring(old_Texture_path.lastIndexOf("/") + 1); // image name

                  new_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + the_filename;
                  opacity_Texture_path = Folder_Export3D + "/" + Subfolder_exportMaps + "opacity_" + the_filename;

                  println("Copying texture:", old_Texture_path, ">", new_Texture_path);
                  saveBytes(new_Texture_path, loadBytes(old_Texture_path));

                  println("Making opacity texture:", new_Texture_path);

                  int RES1 = kind.Images[i].width;
                  int RES2 = kind.Images[i].height;

                  PImage Opacity_Texture = createImage(RES1, RES2, ARGB);

                  Opacity_Texture.loadPixels();

                  for (int np = 0; np < (RES1 * RES2); np++) {
                    int Image_X = np % RES1;
                    int Image_Y = np / RES1;

                    color COL = kind.Images[i].get(Image_X, Image_Y);
                    //alpha: COL >> 24 & 0xFF; red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;

                    float COL_V = (COL >> 24 & 0xFF);

                    Opacity_Texture.pixels[np] = color(COL_V, COL_V, COL_V, COL_V);
                  }

                  Opacity_Texture.updatePixels();

                  Opacity_Texture.save(opacity_Texture_path);

                  if (target_window == TypeWindow.HTML) {
                    htmlOutput.println("\t\t\t\t<Appearance DEF='this." + the_filename + "'>");
                    htmlOutput.println("\t\t\t\t\t<ImageTexture url='"+ Subfolder_exportMaps + the_filename + "'><ImageTexture/>");
                    htmlOutput.println("\t\t\t\t</Appearance>");
                  }

                  if (target_window == TypeWindow.OBJ3D) {

                    mtlOutput.println("newmtl " + CLASS_STAMP + the_filename);
                    mtlOutput.println("\tilum 2"); // 0:Color on and Ambient off, 1:Color on and Ambient on, 2:Highlight on, etc.
                    mtlOutput.println("\tKa 1.000 1.000 1.000"); // ambient
                    mtlOutput.println("\tKd 1.000 1.000 1.000"); // diffuse
                    mtlOutput.println("\tKs 0.000 0.000 0.000"); // specular
                    mtlOutput.println("\tNs 10.00"); // 0-1000 specular exponent
                    mtlOutput.println("\tNi 1.500"); // 0.001-10 (glass:1.5) optical_density (index of refraction)

                    mtlOutput.println("\td 1.000"); //  0-1 transparency  d = Tr, or maybe d = 1 - Tr
                    mtlOutput.println("\tTr 1.000"); //  0-1 transparency
                    mtlOutput.println("\tTf 1.000 1.000 1.000"); //  transmission filter

                    //mtlOutput.println("\tmap_Ka " + Subfolder_exportMaps + the_filename); // ambient map
                    mtlOutput.println("\tmap_Kd " + Subfolder_exportMaps + the_filename); // diffuse map
                    mtlOutput.println("\tmap_d " + Subfolder_exportMaps + "opacity_" + the_filename); // diffuse map
                  }
                }
              }
            }
          }
        }
      }





      float[] DistZ = new float [this.num];

      for (int f = 0; f < this.num; f++) {
        float x = this.getX(f) * overallScale;
        float y = this.getY(f) * overallScale;
        float z = this.getZ(f) * overallScale;

        DistZ[f] = dist(x, y, z, WIN3D.cameraX, WIN3D.cameraY, WIN3D.cameraZ);
      }

      for (int g = 0; g < this.num; g++) {

        int f = -1;
        float max_dist = -1;

        for (int q = 0; q < this.num; q++) {
          if (max_dist < DistZ[q]) {
            max_dist = DistZ[q];
            f = q;
          }
        }

        DistZ[f] = -1;



        if (f != -1) {

          Model2DKind kind = this.Kind[f];
          int n = this.FileIndex[f];

          int w = kind.Images[n].width;
          int h = kind.Images[n].height;

          float x = this.getX(f) * overallScale;
          float y = this.getY(f) * overallScale;
          float z = this.getZ(f) * overallScale;

          float rh = this.getS(f) * 0.5 * overallScale;
          float rw = this.halfWidthFromHalfHeight(rh, kind.imageRatio(n));

          float t = PI + WIN3D.rotationZ * PI / 180.0;
          if (WIN3D.projectionTypeIndex == 1) t = atan2(y - WIN3D.cameraY, x - WIN3D.cameraX) + 0.5 * PI;

          if ((target_window == TypeWindow.HTML) ||
              (target_window == TypeWindow.OBJ3D)) {

            t = 0;
          }

          if (this.Mirror[f]) t += PI;


          float dx = rw * cos(t);
          float dy = rw * sin(t);

          float x1 = x - dx;
          float y1 = y - dy;

          float x2 = x + dx;
          float y2 = y + dy;

          if (target_window == TypeWindow.OBJ3D) {

            if (User3D.exporterMaintainPolygons == 1) {
              obj_lastGroupNumber += 1;
              // kind.tag included (not just n) - n is now local to each
              // kind, so without the tag a person and a tree could share
              // the same local index and collide into the same group name.
              objOutput.println("g this." + nf(f, 0) + "_type" + kind.tag + nf(n, 0));
            }

            if (User3D.exporterMaterialLibrary) {
              objOutput.println("usemtl this." + kind.ImagePath[n].substring(kind.ImagePath[n].lastIndexOf("/") + 1).replace('.', '_'));
            }
          }

          num_vertices_added = 0;

          int end_turn = 1;
          if (target_window == TypeWindow.OBJ3D) end_turn = 3;
          for (int _turn = 1; _turn <= end_turn; _turn++) {
            for (int back_front = -1; back_front <= 1; back_front++) {
              if (back_front == 0) {

                if (target_window == TypeWindow.WIN3D) {

                  WIN3D.graphics.beginShape();

                  WIN3D.graphics.texture(kind.Images[n]);
                  WIN3D.graphics.stroke(255, 255, 255, 0);
                  WIN3D.graphics.fill(255, 255, 255, 0);

                  WIN3D.graphics.vertex(x1 * WIN3D.scale, -y1 * WIN3D.scale, z * WIN3D.scale, 0, h);
                  WIN3D.graphics.vertex(x2 * WIN3D.scale, -y2 * WIN3D.scale, z * WIN3D.scale, w, h);
                  WIN3D.graphics.vertex(x2 * WIN3D.scale, -y2 * WIN3D.scale, (z + 2 * rh) * WIN3D.scale, w, 0);
                  WIN3D.graphics.vertex(x1 * WIN3D.scale, -y1 * WIN3D.scale, (z + 2 * rh) * WIN3D.scale, 0, 0);

                  WIN3D.graphics.endShape(CLOSE);
                }

                if (target_window == TypeWindow.OBJ3D) {

                  if (_turn == 1) {

                    OBJprintVertex(x1, y1, z);
                    OBJprintVertex(x2, y2, z);
                    OBJprintVertex(x2, y2, (z + 2 * rh));
                    OBJprintVertex(x1, y1, (z + 2 * rh));

                    num_vertices_added += 4;

                  }

                  if (_turn == 2) {
                      OBJprintVtexture(1, 0, 0);
                      OBJprintVtexture(0, 0, 0);
                      OBJprintVtexture(0, 1, 0);
                      OBJprintVtexture(1, 1, 0);
                  }

                  if (_turn == 3) {
                    obj_lastVertexNumber += num_vertices_added;
                    obj_lastVtextureNumber += num_vertices_added;

                    String n1_txt = nf(obj_lastVertexNumber - num_vertices_added + 1, 0);
                    String n2_txt = nf(obj_lastVertexNumber - num_vertices_added + 2, 0);
                    String n3_txt = nf(obj_lastVertexNumber - num_vertices_added + 3, 0);
                    String n4_txt = nf(obj_lastVertexNumber - num_vertices_added + 4, 0);

                    String m1_txt = nf(obj_lastVtextureNumber - num_vertices_added + 1, 0);
                    String m2_txt = nf(obj_lastVtextureNumber - num_vertices_added + 2, 0);
                    String m3_txt = nf(obj_lastVtextureNumber - num_vertices_added + 3, 0);
                    String m4_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4, 0);

                    if (User3D.exporterMaintainPolygons == 0) {
                      obj_lastGroupNumber += 1;
                      objOutput.println("g this." + nf(f, 0) + "_ver");
                    }

                    obj_lastFaceNumber += 1;
                    objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
                    if (User3D.exporterDoubleSided) {
                      obj_lastFaceNumber += 1;
                      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
                    }
                  }
                }


                if (target_window == TypeWindow.HTML) {

                  htmlOutput.println("\t\t\t\t<shape>");

                  htmlOutput.println("\t\t\t\t\t<Appearance USE='this." + kind.ImagePath[n].substring(kind.ImagePath[n].lastIndexOf("/") + 1) + "'></Appearance>");

                  htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>"); // force two-sided

                  htmlOutput.print  ("\t\t\t\t\t\t<Coordinate point='");
                  htmlOutput.print  (      nf(x1, 0, User3D.exporterPrecisionVertex) + " " + nf(y1, 0, User3D.exporterPrecisionVertex) + " " + nf(z, 0, User3D.exporterPrecisionVertex));
                  htmlOutput.print  ("," + nf(x2, 0, User3D.exporterPrecisionVertex) + " " + nf(y2, 0, User3D.exporterPrecisionVertex) + " " + nf(z, 0, User3D.exporterPrecisionVertex));
                  htmlOutput.print  ("," + nf(x2, 0, User3D.exporterPrecisionVertex) + " " + nf(y2, 0, User3D.exporterPrecisionVertex) + " " + nf((z + 2 * rh), 0, User3D.exporterPrecisionVertex));
                  htmlOutput.print  ("," + nf(x1, 0, User3D.exporterPrecisionVertex) + " " + nf(y1, 0, User3D.exporterPrecisionVertex) + " " + nf((z + 2 * rh), 0, User3D.exporterPrecisionVertex));
                  htmlOutput.println("'></Coordinate>");

                  htmlOutput.println("\t\t\t\t\t\t<TextureCoordinate point='1 0,0 0,0 1,1 1'></TextureCoordinate>");

                  htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");

                  htmlOutput.println("\t\t\t\t</shape>");
                }

                int nv = f * this.num_visualFaces * 4;
                int nf = f * this.num_visualFaces;

                this.Vertices[nv + 0][0] = x1 / overallScale;
                this.Vertices[nv + 0][1] = y1 / overallScale;
                this.Vertices[nv + 0][2] = (z) / overallScale;
                this.Vertices[nv + 0][3] = 0;
                this.Vertices[nv + 0][4] = 1;

                this.Vertices[nv + 1][0] = x2 / overallScale;
                this.Vertices[nv + 1][1] = y2 / overallScale;
                this.Vertices[nv + 1][2] = (z) / overallScale;
                this.Vertices[nv + 1][3] = 1;
                this.Vertices[nv + 1][4] = 1;

                this.Vertices[nv + 2][0] = x2 / overallScale;
                this.Vertices[nv + 2][1] = y2 / overallScale;
                this.Vertices[nv + 2][2] = (z + 2 * rh) / overallScale;
                this.Vertices[nv + 2][3] = 1;
                this.Vertices[nv + 2][4] = 0;

                this.Vertices[nv + 3][0] = x1 / overallScale;
                this.Vertices[nv + 3][1] = y1 / overallScale;
                this.Vertices[nv + 3][2] = (z + 2 * rh) / overallScale;
                this.Vertices[nv + 3][3] = 0;
                this.Vertices[nv + 3][4] = 0;

                this.Faces[nf][0] = nv + 0;
                this.Faces[nf][1] = nv + 1;
                this.Faces[nf][2] = nv + 2;
                this.Faces[nf][3] = nv + 3;
              }
              else {

                int nv = f * this.num_visualFaces * 4;
                int nf = f * this.num_visualFaces;

                if (back_front == -1) {
                  nv += 4;
                  nf += 1;
                }
                else {
                  nv += 8;
                  nf += 2;
                }

                if (kind.isTree()) { // case: trees

                  float ratio = this.canopyCapHeightFraction(kind.imageRatio(n));
                  float texRatio = this.canopyCapTextureFraction(kind.imageRatio(n)); // how much of the texture's own height the cap samples - see that method's own comment for why this differs from `ratio` above

                  float rot = back_front * PI / 2 + t;

                  dx = rw * cos(rot);
                  dy = rw * sin(rot);

                  float x3 = x2 + dx;
                  float y3 = y2 + dy;

                  float x4 = x1 + dx;
                  float y4 = y1 + dy;

                  if (target_window == TypeWindow.WIN3D) {
                    float angleWithCamera = funcs.computeAngleWithXYPlane(
                      new float[] {WIN3D.cameraX, WIN3D.cameraY, WIN3D.cameraZ},
                      new float[] {x, y, z + rh * ratio}
                    );

                    if(Math.abs(angleWithCamera) > 45) {
                      WIN3D.graphics.beginShape();

                      WIN3D.graphics.texture(kind.Images[n]);
                      WIN3D.graphics.stroke(255, 255, 255, 0);
                      WIN3D.graphics.fill(255, 255, 255, 0);

                      WIN3D.graphics.vertex(x1 * WIN3D.scale, -y1 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, 0, h * texRatio);
                      WIN3D.graphics.vertex(x2 * WIN3D.scale, -y2 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, w, h * texRatio);
                      WIN3D.graphics.vertex(x3 * WIN3D.scale, -y3 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, w, 0);
                      WIN3D.graphics.vertex(x4 * WIN3D.scale, -y4 * WIN3D.scale, (z + 2 * rh * ratio) * WIN3D.scale, 0, 0);

                      WIN3D.graphics.endShape(CLOSE);
                    }
                  }

                  if (target_window == TypeWindow.OBJ3D) {
                    if (_turn == 1) {

                      OBJprintVertex(x1, y1, (z + 2 * rh * ratio));
                      OBJprintVertex(x2, y2, (z + 2 * rh * ratio));
                      OBJprintVertex(x3, y3, (z + 2 * rh * ratio));
                      OBJprintVertex(x4, y4, (z + 2 * rh * ratio));

                      num_vertices_added += 4;
                    }

                    if (_turn == 2) {

                      OBJprintVtexture(1, 1 - texRatio, 0);
                      OBJprintVtexture(0, 1 - texRatio, 0);
                      OBJprintVtexture(0, 1, 0);
                      OBJprintVtexture(1, 1, 0);
                    }

                    if (_turn == 3) {

                      int q = (back_front + 1) / 2;

                      String n1_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 1, 0);
                      String n2_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 2, 0);
                      String n3_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 3, 0);
                      String n4_txt = nf(obj_lastVertexNumber - num_vertices_added + 4 * (q + 1) + 4, 0);

                      String m1_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 1, 0);
                      String m2_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 2, 0);
                      String m3_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 3, 0);
                      String m4_txt = nf(obj_lastVtextureNumber - num_vertices_added + 4 * (q + 1) + 4, 0);

                      if (User3D.exporterMaintainPolygons == 0) {
                        obj_lastGroupNumber += 1;
                        objOutput.println("g this." + nf(f, 0) + "_hor" + nf(q, 0));
                      }

                      obj_lastFaceNumber += 1;
                      objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n2_txt + "/" + m2_txt + " " + n3_txt + "/" + m3_txt + " " + n4_txt + "/" + m4_txt);
                      if (User3D.exporterDoubleSided) {
                        obj_lastFaceNumber += 1;
                        objOutput.println("f " + n1_txt + "/" + m1_txt + " " + n4_txt + "/" + m4_txt + " " + n3_txt + "/" + m3_txt + " " + n2_txt + "/" + m2_txt);
                      }
                    }
                  }

                  if (target_window == TypeWindow.HTML) {

                    htmlOutput.println("\t\t\t\t<shape>");

                    htmlOutput.println("\t\t\t\t\t<Appearance USE='this." + kind.ImagePath[n].substring(kind.ImagePath[n].lastIndexOf("/") + 1) + "'></Appearance>");

                    htmlOutput.println("\t\t\t\t\t<IndexedFaceSet solid='false' coordIndex='0 1 2 3 -1'>"); // force two-sided

                    htmlOutput.print  ("\t\t\t\t\t\t<Coordinate point='");
                    htmlOutput.print  (      nf(x1, 0, User3D.exporterPrecisionVertex) + " " + nf(y1, 0, User3D.exporterPrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.exporterPrecisionVertex));
                    htmlOutput.print  ("," + nf(x2, 0, User3D.exporterPrecisionVertex) + " " + nf(y2, 0, User3D.exporterPrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.exporterPrecisionVertex));
                    htmlOutput.print  ("," + nf(x3, 0, User3D.exporterPrecisionVertex) + " " + nf(y3, 0, User3D.exporterPrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.exporterPrecisionVertex));
                    htmlOutput.print  ("," + nf(x4, 0, User3D.exporterPrecisionVertex) + " " + nf(y4, 0, User3D.exporterPrecisionVertex) + " " + nf((z + 2 * rh * ratio), 0, User3D.exporterPrecisionVertex));
                    htmlOutput.println("'></Coordinate>");

                    htmlOutput.print ("\t\t\t\t\t\t<TextureCoordinate point='");

                    HTMLprintVtexture(1, 1 - texRatio);
                    htmlOutput.print (",");
                    HTMLprintVtexture(0, 1 - texRatio);
                    htmlOutput.print (",");
                    HTMLprintVtexture(0, 1);
                    htmlOutput.print (",");
                    HTMLprintVtexture(1, 1);
                    htmlOutput.println("'></TextureCoordinate>");

                    htmlOutput.println("\t\t\t\t\t</IndexedFaceSet>");

                    htmlOutput.println("\t\t\t\t</shape>");
                  }

                  this.Vertices[nv + 0][0] = x1 / overallScale;
                  this.Vertices[nv + 0][1] = y1 / overallScale;
                  this.Vertices[nv + 0][2] = (z + 2 * rh * ratio) / overallScale;
                  this.Vertices[nv + 0][3] = 0;
                  this.Vertices[nv + 0][4] = texRatio;

                  this.Vertices[nv + 1][0] = x2 / overallScale;
                  this.Vertices[nv + 1][1] = y2 / overallScale;
                  this.Vertices[nv + 1][2] = (z + 2 * rh * ratio) / overallScale;
                  this.Vertices[nv + 1][3] = 1;
                  this.Vertices[nv + 1][4] = texRatio;

                  this.Vertices[nv + 2][0] = x3 / overallScale;
                  this.Vertices[nv + 2][1] = y3 / overallScale;
                  this.Vertices[nv + 2][2] = (z + 2 * rh * ratio) / overallScale;
                  this.Vertices[nv + 2][3] = 1;
                  this.Vertices[nv + 2][4] = 0;

                  this.Vertices[nv + 3][0] = x4 / overallScale;
                  this.Vertices[nv + 3][1] = y4 / overallScale;
                  this.Vertices[nv + 3][2] = (z + 2 * rh * ratio) / overallScale;
                  this.Vertices[nv + 3][3] = 0;
                  this.Vertices[nv + 3][4] = 0;

                  this.Faces[nf][0] = nv + 0;
                  this.Faces[nf][1] = nv + 1;
                  this.Faces[nf][2] = nv + 2;
                  this.Faces[nf][3] = nv + 3;
                }
                else { // case: people
                  this.Vertices[nv + 0][0] = x1 / overallScale;
                  this.Vertices[nv + 0][1] = y1 / overallScale;
                  this.Vertices[nv + 0][2] = (z) / overallScale;
                  this.Vertices[nv + 0][3] = 0;
                  this.Vertices[nv + 0][4] = 1;

                  this.Vertices[nv + 1][0] = x2 / overallScale;
                  this.Vertices[nv + 1][1] = y2 / overallScale;
                  this.Vertices[nv + 1][2] = (z) / overallScale;
                  this.Vertices[nv + 1][3] = 1;
                  this.Vertices[nv + 1][4] = 1;

                  this.Vertices[nv + 2][0] = x2 / overallScale;
                  this.Vertices[nv + 2][1] = y2 / overallScale;
                  this.Vertices[nv + 2][2] = (z + 2 * rh) / overallScale;
                  this.Vertices[nv + 2][3] = 1;
                  this.Vertices[nv + 2][4] = 0;

                  this.Vertices[nv + 3][0] = x1 / overallScale;
                  this.Vertices[nv + 3][1] = y1 / overallScale;
                  this.Vertices[nv + 3][2] = (z + 2 * rh) / overallScale;
                  this.Vertices[nv + 3][3] = 0;
                  this.Vertices[nv + 3][4] = 0;

                  this.Faces[nf][0] = nv + 0;
                  this.Faces[nf][1] = nv + 1;
                  this.Faces[nf][2] = nv + 2;
                  this.Faces[nf][3] = nv + 3;
                }
              }
            }
          }
        }
      }
    }
  }


  float[] intersect (float[] ray_pnt, float[] ray_dir) {

    float[] ray_normal = funcs.vec3_unit(ray_dir);

    float[][] hitPoint = new float [this.Faces.length][6];

    for (int f = 0; f < this.Faces.length; f++) {
      java.util.Arrays.fill(hitPoint[f], FLOAT_undefined);
    }

    for (int f = 0; f < this.Faces.length; f++) {

      int n = this.Faces[f].length;

      float X_intersect = FLOAT_undefined;
      float Y_intersect = FLOAT_undefined;
      float Z_intersect = FLOAT_undefined;
      float dist2intersect = FLOAT_undefined;

      //boolean InPoly = false;
      float[] UV = {FLOAT_undefined, FLOAT_undefined};

      float[] A = this.Vertices[this.Faces[f][0]];
      float[] B = this.Vertices[this.Faces[f][1]];
      float[] C = this.Vertices[this.Faces[f][n - 2]];
      float[] D = this.Vertices[this.Faces[f][n - 1]];

      float[] AC = funcs.vec3_diff(A, C);
      float[] BD = funcs.vec3_diff(B, D);

      float[] face_norm = funcs.vec3_cross(AC, BD);

      float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * face_norm[0] + (A[1] + B[1] + C[1] + D[1]) * face_norm[1] + (A[2] + B[2] + C[2] + D[2]) * face_norm[2]);

      float R = -funcs.vec3_dot(ray_dir, face_norm);

      if ((R < FLOAT_tiny) && (R > -FLOAT_tiny)) { // the ray is parallel to the plane
        dist2intersect = FLOAT_huge;
      }
      else {
        dist2intersect = (funcs.vec3_dot(ray_pnt, face_norm) - face_offset) / R;

        //if (dist2intersect > 0) {
        if (dist2intersect > FLOAT_tiny) {

          X_intersect = dist2intersect * ray_dir[0] + ray_pnt[0];
          Y_intersect = dist2intersect * ray_dir[1] + ray_pnt[1];
          Z_intersect = dist2intersect * ray_dir[2] + ray_pnt[2];

          float[] P = {X_intersect, Y_intersect, Z_intersect};

          UV = funcs.uvInside_Rectangle(P, A, B, C);
        }
      }

      float u = UV[0];
      float v = UV[1];

      if ((u >= 0) && (v >= 0) && (u <= 1) && (v <= 1)) {

        hitPoint[f][0] = X_intersect;
        hitPoint[f][1] = Y_intersect;
        hitPoint[f][2] = Z_intersect;
        hitPoint[f][3] = dist2intersect;
        // converting rom face UV to image UV
        hitPoint[f][4] = (1 - u) * B[3] + u * A[3];
        hitPoint[f][5] = (1 - v) * B[4] + v * C[4];

      }
    }


    float[] return_point = {-1, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined, FLOAT_undefined};

    float pre_dist = FLOAT_undefined;

    for (int f = 0; f < this.Faces.length; f++) {

      int OBJ_ID = f / this.num_visualFaces;

      if (pre_dist > hitPoint[f][3]) {

        float u = hitPoint[f][4];
        float v = hitPoint[f][5];

        Model2DKind kind = this.Kind[OBJ_ID];
        int n = this.FileIndex[OBJ_ID];

        int RES1 = kind.Images[n].width;
        int RES2 = kind.Images[n].height;

        kind.Images[n].loadPixels();

        // (the original had an "if (n < 0) u = 1 - u;" here, but n was
        // already abs()'d above, so that branch could never fire - the
        // mirror flag never affected this particular alpha sample)

        int Image_X = int(u * RES1);
        int Image_Y = int(v * RES2);

        color COL = kind.Images[n].get(Image_X, Image_Y);
        //alpha: COL >> 24 & 0xFF; red: COL >> 16 & 0xFF; green: COL >>8 & 0xFF; blue: COL & 0xFF;

        float COL_V = (COL >> 24 & 0xFF);

        if (COL_V > 0) {

          pre_dist = hitPoint[f][3];

          return_point[0] = OBJ_ID;
          return_point[1] = hitPoint[f][0];
          return_point[2] = hitPoint[f][1];
          return_point[3] = hitPoint[f][2];
          return_point[4] = hitPoint[f][3];
        }
      }

    }

    return return_point;
  }









  void castShadows (float[] SunR) {

    for (int f = 0; f < this.num; f++) {

      Model2DKind kind = this.Kind[f];
      int n = this.FileIndex[f];

      int w = kind.Images[n].width;
      int h = kind.Images[n].height;

      float rh = this.getS(f) * 0.5; // half-height - real-world height, independent of the image's aspect ratio
      float rw = this.halfWidthFromHalfHeight(rh, kind.imageRatio(n)); // half-width - follows the image's own aspect ratio, same as addToFaceGrid()/draw()

      float t = atan2(SunR[2], SunR[1]) + 0.5 * PI;

      if (this.Mirror[f]) t += PI;

      // Was "if (r > 2.5)" - a size heuristic standing in for "is this a
      // tree", since trees are normally bigger than people. kind.isTree()
      // is the real check now, so a tiny tree or an oversized person no
      // longer gets the wrong shadow-mask treatment. (That old `r` is
      // rh above - rw didn't exist yet, since this method still assumed
      // every tree image was square.)
      if (kind.isTree()) {

        float x = this.getX(f);
        float y = this.getY(f);
        float z = this.getZ(f);

        { // Vertical mask
          TREES_graphics.beginShape();

          TREES_graphics.texture(kind.Images[n]);

          x = this.getX(f);
          y = this.getY(f);
          z = this.getZ(f);

          float[] TX = {
            0, 0, 0, 0
          };
          float[] TY = {
            0, 0, 0, 0
          };
          float[] TZ = {
            0, 0, 0, 0
          };
          float[] TU = {
            0, 0, 0, 0
          };
          float[] TV = {
            0, 0, 0, 0
          };

          TX[0] = x - rw * cos(t);
          TY[0] = y - rw * sin(t);
          TZ[0] = z;
          TX[1] = x + rw * cos(t);
          TY[1] = y + rw * sin(t);
          TZ[1] = z;
          TX[2] = x + rw * cos(t);
          TY[2] = y + rw * sin(t);
          TZ[2] = z + 2 * rh;
          TX[3] = x - rw * cos(t);
          TY[3] = y - rw * sin(t);
          TZ[3] = z + 2 * rh;

          TU[0] = 0;
          TV[0] = h;
          TU[1] = w;
          TV[1] = h;
          TU[2] = w;
          TV[2] = 0;
          TU[3] = 0;
          TV[3] = 0;

          // See faces.pde's own castShadows() for why this is allSolarImpacts.Z
          // directly for types 1/2/3 but needs converting for a type-0
          // (arbitrary) section.
          float depthOffset = (allSolarImpacts.sectionType == 0)
            ? arbitrarySection_rotateWorldToLocal(allSolarImpacts.X, allSolarImpacts.Y, allSolarImpacts.Z, allSolarImpacts.R, allSolarImpacts.rotY, allSolarImpacts.rotZ)[2]
            : allSolarImpacts.Z;

          if (allSolarImpacts.sectionType == 2) {
            {
              for (int q = 0; q < 4; q++) {
                float a = TX[q];
                float b = -TY[q];
                float c = TZ[q];

                TX[q] = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
                TY[q] = c;
                TZ[q] = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);
              }
            }
            { // now that we rotated 2D we could rotate x,y,z
              float a = x;
              float b = -y;
              float c = z;

              x = a * funcs.cos_ang(-allSolarImpacts.R) - b * funcs.sin_ang(-allSolarImpacts.R);
              y = c;
              z = a * funcs.sin_ang(-allSolarImpacts.R) + b * funcs.cos_ang(-allSolarImpacts.R);
            }
          } else if (allSolarImpacts.sectionType == 3) {
          } else if (allSolarImpacts.sectionType == 0) {
            for (int q = 0; q < 4; q++) {
              float[] local = arbitrarySection_rotateWorldToLocal(TX[q], TY[q], TZ[q], allSolarImpacts.R, allSolarImpacts.rotY, allSolarImpacts.rotZ);

              TX[q] = local[0];
              TY[q] = local[1];
              TZ[q] = local[2];
            }
          }

          if ((TZ[0] < depthOffset) && (depthOffset < TZ[2])) {

            float ratio = (depthOffset - TZ[0]) / (TZ[2] - TZ[0]);

            TZ[0] = (TZ[0] * (1 - ratio) + TZ[2] * ratio);
            TZ[1] = (TZ[1] * (1 - ratio) + TZ[3] * ratio);

            if (allSolarImpacts.sectionType == 1) {

              TV[0] = (TV[0] * (1 - ratio) + TV[2] * ratio);
              TV[1] = (TV[1] * (1 - ratio) + TV[3] * ratio);
            } else if (allSolarImpacts.sectionType == 2) {

              TU[1] = (TU[1] * (1 - ratio) + TU[3] * ratio);
              TU[2] = (TU[2] * (1 - ratio) + TU[0] * ratio);
            } else if (allSolarImpacts.sectionType == 3) {
            }
          }

          if (TZ[2] > depthOffset) {

            for (int q = 0; q < 4; q++) {

              TZ[q] = TZ[q] - depthOffset;
              TX[q] = (TX[q] - TZ[q] * SunR_Rotated[1] / SunR_Rotated[3]);
              TY[q] = (TY[q] - TZ[q] * SunR_Rotated[2] / SunR_Rotated[3]);

              if (allSolarImpacts.sectionType == 1) {
                float px = TX[q];
                float py = TY[q];

                TX[q] = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
                TY[q] = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
              }

              TREES_graphics.vertex((TX[q] - Shades_offsetX) * Shades_scaleX, -(TY[q] - Shades_offsetY) * Shades_scaleY, TU[q], TV[q]);
            }
          }

          TREES_graphics.endShape(CLOSE);
        }

        { // Horizontal mask
          float ratio = this.canopyCapHeightFraction(kind.imageRatio(n)); // see that method's own comment - 0.5 (the tree's mid-height) for a square image, higher for a narrower one
          float texRatio = this.canopyCapTextureFraction(kind.imageRatio(n)); // how much of the texture's own height the mask samples - see that method's own comment for why this differs from `ratio` above

          for (int back_front = -1; back_front <= 1; back_front += 2) {

            float rot = back_front * PI / 2 + t;

            TREES_graphics.beginShape();

            TREES_graphics.texture(kind.Images[n]);

            float[] TX = {
              0, 0, 0, 0
            };
            float[] TY = {
              0, 0, 0, 0
            };
            float[] TZ = {
              0, 0, 0, 0
            };
            float[] TU = {
              0, 0, 0, 0
            };
            float[] TV = {
              0, 0, 0, 0
            };

            TX[0] = x - rw * cos(t);
            TY[0] = y - rw * sin(t);
            TZ[0] = z + 2 * rh * ratio;
            TX[1] = x + rw * cos(t);
            TY[1] = y + rw * sin(t);
            TZ[1] = z + 2 * rh * ratio;
            TX[2] = x + rw * cos(t) + rw * cos(rot);
            TY[2] = y + rw * sin(t) + rw * sin(rot);
            TZ[2] = z + 2 * rh * ratio;
            TX[3] = x - rw * cos(t) + rw * cos(rot);
            TY[3] = y - rw * sin(t) + rw * sin(rot);
            TZ[3] = z + 2 * rh * ratio;

            TU[0] = 0;
            TV[0] = h * texRatio;
            TU[1] = w;
            TV[1] = h * texRatio;
            TU[2] = w;
            TV[2] = 0;
            TU[3] = 0;
            TV[3] = 0;

            if (allSolarImpacts.sectionType == 1) {
              if (z + 2 * rh * ratio > allSolarImpacts.Z) {

                for (int q = 0; q < 4; q++) {

                  TZ[q] = TZ[q] - allSolarImpacts.Z;
                  TX[q] = (TX[q] - TZ[q] * SunR_Rotated[1] / SunR_Rotated[3]);
                  TY[q] = (TY[q] - TZ[q] * SunR_Rotated[2] / SunR_Rotated[3]);

                  if (allSolarImpacts.sectionType == 1) {
                    float px = TX[q];
                    float py = TY[q];

                    TX[q] = px * funcs.cos_ang(-allSolarImpacts.R) - py * funcs.sin_ang(-allSolarImpacts.R);
                    TY[q] = px * funcs.sin_ang(-allSolarImpacts.R) + py * funcs.cos_ang(-allSolarImpacts.R);
                  }

                  TREES_graphics.vertex((TX[q] - Shades_offsetX) * Shades_scaleX, -(TY[q] - Shades_offsetY) * Shades_scaleY, TU[q], TV[q]);
                }
              }
            }

            TREES_graphics.endShape(CLOSE);
          }
        }
      }
    }
  }




  // Identity is now written out as (kind tag, filename, mirror flag)
  // instead of a single recomputed flat-array position - a project
  // saved this way stays correct no matter how either input/images
  // folder's contents change later, since "PEOPLE,woman_03.png,0" never
  // depends on how many files happen to be in input/images/trees (or
  // even input/images/people itself) when the project is re-opened.
  public void to_XML (XML xml) {

    {
      XML parent = xml.addChild(this.CLASS_STAMP);

      int ni = this.num;
      XML_setInt(parent, "ni", ni);
      for (int i = 0; i < ni; i++) {
        XML child = parent.addChild("item");
        XML_setInt(child, "id", i);
        String txt = "";
        txt += nf(this.getX(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getY(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getZ(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += nf(this.getS(i), 0, 4).replace(",", "."); // <<<<
        txt += ",";
        txt += this.Kind[i].tag;
        txt += ",";
        txt += this.Kind[i].filenameOf(this.FileIndex[i]);
        txt += ",";
        txt += (this.Mirror[i] ? "1" : "0");

        XML_setContent(child, txt);
      }

      XML_setBoolean(parent, "displayAll", this.displayAll);
    }
  }


  public void from_XML (XML xml) {

    {
      XML parent = xml.getChild(this.CLASS_STAMP);

      int ni = XML_getInt(parent, "ni");

      this.makeEmpty(ni);

      XML[] children = parent.getChildren("item");
      for (int i = 0; i < ni; i++) {
        String txt = XML_getContent(children[i]);
        String[] parts = split(txt, ",");
        this.setX(i, float(parts[0]));
        this.setY(i, float(parts[1]));
        this.setZ(i, float(parts[2]));
        this.setS(i, float(parts[3]));

        Model2DKind kind = model2DKindByTag(parts[4]);
        String filename = parts[5];

        int localIndex = kind.indexOfFile(filename);
        if (localIndex == 0) {
          // The saved file no longer exists under this kind's folder -
          // renamed or deleted since this project was last saved. Fall
          // back to that kind's first available file (if any) instead
          // of crashing or silently drifting into a different kind -
          // the one failure mode left once identity no longer depends
          // on folder file counts is "the exact file is simply gone".
          println("Model2Ds.from_XML: texture file not found, falling back:", kind.tag, filename);
          localIndex = (kind.fileCount > 0) ? 1 : 0;
        }

        this.Kind[i] = kind;
        this.FileIndex[i] = localIndex;
        this.Mirror[i] = (parts.length > 6) && parts[6].equals("1");
      }

      this.displayAll = XML_getBoolean(parent, "displayAll");
    }
  }
}
