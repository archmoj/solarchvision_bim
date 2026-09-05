// ============================================================================
// Spatial-grid acceleration for SOLARCHVISION_isIntersected_Faces
//
// Idea: instead of testing every face for every ray (O(numFaces) per ray),
// bucket faces into a uniform 3D grid once when the geometry is built, then
// for each ray only test faces in the grid cells the ray actually passes
// through, walking cell-by-cell in order along the ray (Amanatides & Woo
// fast voxel traversal, 1987). The first hit found this way is also the
// *nearest* hit, which the original function did not guarantee.
//
// Usage:
//   Call SOLARCHVISION_buildFaceGrid() once after geometry is loaded or
//   whenever it changes (NOT per ray / per frame).
// ============================================================================

// ---------------------------- grid state -----------------------------------
IntList[] gridCells;                 // flattened numFaces-per-cell lists
int gridNx, gridNy, gridNz;
float gridMinX, gridMinY, gridMinZ;
float gridMaxX, gridMaxY, gridMaxZ;
float cellSizeX, cellSizeY, cellSizeZ;

int[] faceTestStamp;                 // per-face "tested in ray #N" marker
int currentRayStamp = 0;             // bumped once per ray cast

// ---------------------------- build (call ONCE per geometry) ---------------
void SOLARCHVISION_buildFaceGrid () {
  int numFaces = allFaces.nodes.length;

  int numPoints = allPoints.getLength();

  // 1) overall bounding box of the scene
  gridMinX = gridMinY = gridMinZ = FLOAT_huge;
  gridMaxX = gridMaxY = gridMaxZ = -FLOAT_huge;
  for (int p = 0; p < numPoints; p++) {
    float x = allPoints.getX(p);
    float y = allPoints.getY(p);
    float z = allPoints.getZ(p);
    if (x < gridMinX) gridMinX = x;
    if (x > gridMaxX) gridMaxX = x;
    if (y < gridMinY) gridMinY = y;
    if (y > gridMaxY) gridMaxY = y;
    if (z < gridMinZ) gridMinZ = z;
    if (z > gridMaxZ) gridMaxZ = z;
  }

  // small padding so faces exactly on the scene boundary aren't missed
  float pad = 0.001 * max(gridMaxX - gridMinX, max(gridMaxY - gridMinY, gridMaxZ - gridMinZ));
  if (pad <= 0) pad = 0.001; // degenerate/flat scene fallback
  gridMinX -= pad; gridMinY -= pad; gridMinZ -= pad;
  gridMaxX += pad; gridMaxY += pad; gridMaxZ += pad;

  // 2) choose grid resolution: aim for roughly cbrt(numFaces) cells per axis
  //    (a common starting heuristic -- tune if cells end up too empty or too
  //    crowded for your mesh density)
  int cellsPerAxis = max(1, int(pow(max(1, numFaces), 1.0 / 3.0)));
  gridNx = gridNy = gridNz = cellsPerAxis;
  cellSizeX = (gridMaxX - gridMinX) / gridNx;
  cellSizeY = (gridMaxY - gridMinY) / gridNy;
  cellSizeZ = (gridMaxZ - gridMinZ) / gridNz;

  gridCells = new IntList[gridNx * gridNy * gridNz];
  for (int i = 0; i < gridCells.length; i++) gridCells[i] = new IntList();

  faceTestStamp = new int[numFaces];

  // 3) insert each face into every cell its bounding box overlaps
  for (int f = 1; f < numFaces; f++) { // f==0 skipped, matches original convention
    int[] nodes = allFaces.nodes[f];
    if (nodes.length <= 2) continue;

    float fMinX = FLOAT_huge, fMinY = FLOAT_huge, fMinZ = FLOAT_huge;
    float fMaxX = -FLOAT_huge, fMaxY = -FLOAT_huge, fMaxZ = -FLOAT_huge;
    for (int j = 0; j < nodes.length; j++) {
      float x = allPoints.getX(nodes[j]);
      float y = allPoints.getY(nodes[j]);
      float z = allPoints.getZ(nodes[j]);
      if (x < fMinX) fMinX = x;
      if (x > fMaxX) fMaxX = x;
      if (y < fMinY) fMinY = y;
      if (y > fMaxY) fMaxY = y;
      if (z < fMinZ) fMinZ = z;
      if (z > fMaxZ) fMaxZ = z;
    }

    int ix0 = cellIndexX(fMinX), ix1 = cellIndexX(fMaxX);
    int iy0 = cellIndexY(fMinY), iy1 = cellIndexY(fMaxY);
    int iz0 = cellIndexZ(fMinZ), iz1 = cellIndexZ(fMaxZ);

    for (int ix = ix0; ix <= ix1; ix++) {
      for (int iy = iy0; iy <= iy1; iy++) {
        for (int iz = iz0; iz <= iz1; iz++) {
          gridCells[cellFlatIndex(ix, iy, iz)].append(f);
        }
      }
    }
  }
}

int cellIndexX(float x) { return constrain(int((x - gridMinX) / cellSizeX), 0, gridNx - 1); }
int cellIndexY(float y) { return constrain(int((y - gridMinY) / cellSizeY), 0, gridNy - 1); }
int cellIndexZ(float z) { return constrain(int((z - gridMinZ) / cellSizeZ), 0, gridNz - 1); }
int cellFlatIndex(int ix, int iy, int iz) { return (ix * gridNy + iy) * gridNz + iz; }

// ---------------------------- per-face plane/poly test ----------------------
// Same math as the optimized isIntersected_Faces, factored out so both the
// grid traversal and (if you want) a plain fallback can share it.
// Returns dist2intersect (t along the ray) if the ray hits this face's
// polygon at t > FLOAT_tiny, otherwise FLOAT_huge. Fills P[0..2] on hit.
float SOLARCHVISION_testFaceHit(int f, float[] ray_pnt, float[] ray_dir, float[] P) {
  int vsb = allFaces.getVisibility(f);
  if (vsb <= 0) return FLOAT_huge;

  int[] faceNodes = allFaces.nodes[f];
  int n = faceNodes.length;
  if (n <= 2) return FLOAT_huge;

  if (n < 5) {
    float[] A = allPoints.getPosition(faceNodes[0]);
    float[] B = allPoints.getPosition(faceNodes[1]);
    float[] C = allPoints.getPosition(faceNodes[n - 2]);
    float[] D = allPoints.getPosition(faceNodes[n - 1]);

    float ACx = A[0] - C[0], ACy = A[1] - C[1], ACz = A[2] - C[2];
    float BDx = B[0] - D[0], BDy = B[1] - D[1], BDz = B[2] - D[2];
    float nx = ACy * BDz - ACz * BDy;
    float ny = ACz * BDx - ACx * BDz;
    float nz = ACx * BDy - ACy * BDx;

    float R = -(ray_dir[0] * nx + ray_dir[1] * ny + ray_dir[2] * nz);
    if (R < FLOAT_tiny && R > -FLOAT_tiny) return FLOAT_huge; // parallel to plane

    float face_offset = 0.25 * ((A[0] + B[0] + C[0] + D[0]) * nx +
                                (A[1] + B[1] + C[1] + D[1]) * ny +
                                (A[2] + B[2] + C[2] + D[2]) * nz);
    float numer = (ray_pnt[0] * nx + ray_pnt[1] * ny + ray_pnt[2] * nz) - face_offset;
    float dist2intersect = numer / R;
    if (dist2intersect <= FLOAT_tiny) return FLOAT_huge;

    P[0] = dist2intersect * ray_dir[0] + ray_pnt[0];
    P[1] = dist2intersect * ray_dir[1] + ray_pnt[1];
    P[2] = dist2intersect * ray_dir[2] + ray_pnt[2];

    boolean InPoly = (n == 4)
      ? funcs.isInside_Quadrangle(P, A, B, C, D)
      : funcs.isInside_Triangle(P, A, B, D); // D is last vertex, C==B here

    return InPoly ? dist2intersect : FLOAT_huge;
  }
  else {
    float Gx = 0, Gy = 0, Gz = 0;
    for (int j = 0; j < n; j++) {
      int idx = faceNodes[j];
      Gx += allPoints.getX(idx);
      Gy += allPoints.getY(idx);
      Gz += allPoints.getZ(idx);
    }
    float invN = 1.0 / n;
    Gx *= invN; Gy *= invN; Gz *= invN;

    for (int j = 0; j < n; j++) {
      int j_next = (j + 1 == n) ? 0 : j + 1;
      int ai = faceNodes[j];
      int bi = faceNodes[j_next];

      float Ax = allPoints.getX(ai), Ay = allPoints.getY(ai), Az = allPoints.getZ(ai);
      float Bx = allPoints.getX(bi), By = allPoints.getY(bi), Bz = allPoints.getZ(bi);

      float AGx = Ax - Gx, AGy = Ay - Gy, AGz = Az - Gz;
      float BGx = Bx - Gx, BGy = By - Gy, BGz = Bz - Gz;

      float nx = AGy * BGz - AGz * BGy;
      float ny = AGz * BGx - AGx * BGz;
      float nz = AGx * BGy - AGy * BGx;

      float R = -(ray_dir[0] * nx + ray_dir[1] * ny + ray_dir[2] * nz);
      if (R < FLOAT_tiny && R > -FLOAT_tiny) continue; // parallel, try next edge

      float face_offset = (1.0 / 3.0) * ((Ax + Bx + Gx) * nx +
                                         (Ay + By + Gy) * ny +
                                         (Az + Bz + Gz) * nz);
      float numer = (ray_pnt[0] * nx + ray_pnt[1] * ny + ray_pnt[2] * nz) - face_offset;
      float dist2intersect = numer / R;
      if (dist2intersect <= FLOAT_tiny) continue;

      P[0] = dist2intersect * ray_dir[0] + ray_pnt[0];
      P[1] = dist2intersect * ray_dir[1] + ray_pnt[1];
      P[2] = dist2intersect * ray_dir[2] + ray_pnt[2];

      float[] A = {Ax, Ay, Az};
      float[] B = {Bx, By, Bz};
      float[] G = {Gx, Gy, Gz};
      if (funcs.isInside_Triangle(P, A, B, G)) return dist2intersect;
    }
    return FLOAT_huge;
  }
}

// ---------------------------- ray/box entry test -----------------------------
// Standard slab test. Returns true and sets tEnterOut[0] if the ray hits the
// grid's overall bounding box at t >= 0; false if it misses entirely.
boolean rayHitsGridBounds(float[] ray_pnt, float[] ray_dir, float[] tEnterOut) {
  float tmin = -FLOAT_huge, tmax = FLOAT_huge;

  float[] boxMin = {gridMinX, gridMinY, gridMinZ};
  float[] boxMax = {gridMaxX, gridMaxY, gridMaxZ};

  for (int axis = 0; axis < 3; axis++) {
    float d = ray_dir[axis];
    if (d < -FLOAT_tiny || d > FLOAT_tiny) {
      float t1 = (boxMin[axis] - ray_pnt[axis]) / d;
      float t2 = (boxMax[axis] - ray_pnt[axis]) / d;
      if (t1 > t2) { float tmp = t1; t1 = t2; t2 = tmp; }
      if (t1 > tmin) tmin = t1;
      if (t2 < tmax) tmax = t2;
      if (tmin > tmax) return false;
    } else {
      // ray parallel to this axis' slab -- must already be within it
      if (ray_pnt[axis] < boxMin[axis] || ray_pnt[axis] > boxMax[axis]) return false;
    }
  }

  if (tmax < 0) return false; // box is entirely behind the ray
  tEnterOut[0] = max(tmin, 0);
  return true;
}

// ---------------------------- main grid-accelerated query --------------------
// firstGuess is kept for API compatibility and used as a cheap fast-path:
// if you're casting many coherent rays that tend to hit the same face repeatedly
// (e.g. a static sun angle scanning across a flat roof), testing it first can
// shortcut the grid walk entirely.
int SOLARCHVISION_isIntersected_Faces (float[] ray_pnt, float[] ray_dir, int firstGuess) {
  float[] P = new float[3];

  // fast path: try the previous hit first
  if (firstGuess > 0) {
    float d = SOLARCHVISION_testFaceHit(firstGuess, ray_pnt, ray_dir, P);
    if (d < FLOAT_huge) return firstGuess;
  }

  float[] tEnterBox = new float[1];
  if (!rayHitsGridBounds(ray_pnt, ray_dir, tEnterBox)) return 0;
  float tEnter = tEnterBox[0];

  float px = ray_pnt[0] + tEnter * ray_dir[0];
  float py = ray_pnt[1] + tEnter * ray_dir[1];
  float pz = ray_pnt[2] + tEnter * ray_dir[2];

  int ix = cellIndexX(px), iy = cellIndexY(py), iz = cellIndexZ(pz);

  int stepX = (ray_dir[0] > FLOAT_tiny) ? 1 : (ray_dir[0] < -FLOAT_tiny ? -1 : 0);
  int stepY = (ray_dir[1] > FLOAT_tiny) ? 1 : (ray_dir[1] < -FLOAT_tiny ? -1 : 0);
  int stepZ = (ray_dir[2] > FLOAT_tiny) ? 1 : (ray_dir[2] < -FLOAT_tiny ? -1 : 0);

  float tMaxX = FLOAT_huge, tMaxY = FLOAT_huge, tMaxZ = FLOAT_huge;
  float tDeltaX = FLOAT_huge, tDeltaY = FLOAT_huge, tDeltaZ = FLOAT_huge;

  if (stepX != 0) {
    float nextBoundaryX = gridMinX + (ix + (stepX > 0 ? 1 : 0)) * cellSizeX;
    tMaxX = tEnter + (nextBoundaryX - px) / ray_dir[0];
    tDeltaX = cellSizeX / abs(ray_dir[0]);
  }
  if (stepY != 0) {
    float nextBoundaryY = gridMinY + (iy + (stepY > 0 ? 1 : 0)) * cellSizeY;
    tMaxY = tEnter + (nextBoundaryY - py) / ray_dir[1];
    tDeltaY = cellSizeY / abs(ray_dir[1]);
  }
  if (stepZ != 0) {
    float nextBoundaryZ = gridMinZ + (iz + (stepZ > 0 ? 1 : 0)) * cellSizeZ;
    tMaxZ = tEnter + (nextBoundaryZ - pz) / ray_dir[2];
    tDeltaZ = cellSizeZ / abs(ray_dir[2]);
  }

  currentRayStamp++;
  if (firstGuess > 0) faceTestStamp[firstGuess] = currentRayStamp; // don't retest it

  int safetyCounter = gridNx + gridNy + gridNz + 4; // traversal can't exceed this many steps

  while (safetyCounter-- > 0) {
    if (ix < 0 || ix >= gridNx || iy < 0 || iy >= gridNy || iz < 0 || iz >= gridNz) {
      return 0; // walked out of the grid without a hit
    }

    IntList cellFaces = gridCells[cellFlatIndex(ix, iy, iz)];
    int bestFace = 0;
    float bestDist = FLOAT_huge;

    for (int k = 0; k < cellFaces.size(); k++) {
      int f = cellFaces.get(k);
      if (faceTestStamp[f] == currentRayStamp) continue; // already tested this ray
      faceTestStamp[f] = currentRayStamp;

      float dist = SOLARCHVISION_testFaceHit(f, ray_pnt, ray_dir, P);
      if (dist < bestDist) { bestDist = dist; bestFace = f; }
    }

    float cellExitT = min(tMaxX, min(tMaxY, tMaxZ));
    if (bestFace != 0 && bestDist <= cellExitT) {
      return bestFace; // closest hit found is within this cell -> it's the true nearest hit
    }

    // advance to whichever neighboring cell boundary is reached first
    if (tMaxX < tMaxY) {
      if (tMaxX < tMaxZ) { ix += stepX; tMaxX += tDeltaX; }
      else { iz += stepZ; tMaxZ += tDeltaZ; }
    } else {
      if (tMaxY < tMaxZ) { iy += stepY; tMaxY += tDeltaY; }
      else { iz += stepZ; tMaxZ += tDeltaZ; }
    }
  }

  return 0; // safety fallback, shouldn't normally be reached
}
