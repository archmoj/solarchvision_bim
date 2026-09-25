# Command line

The command line is a text console you can use instead of (or alongside)
the mouse: type a command and press `Enter` to run it.

Use `TAB` to show or hide the command line, or click inside/outside the
command line area (the dark region at the bottom).

Commands are **not** case-sensitive - `SETLAT 45.5`, `setlat 45.5` and
`SetLat 45.5` all do the same thing. A few commands contain a `.` or a
`/` as part of their name (e.g. `SAVE.AS`, `SHADE.WIRE`) - that's a
literal part of the name, not punctuation to skip.

You can also run a whole file of commands, one per line, with
`RUN.SCRIPT <file>`; a few example scripts are included in this folder
(`test.txt`, `test_houses.txt`, `test_primitives.txt`, ...).

This page has two parts:

1. **[Core commands](#core-commands)** - file operations, object creation,
   selection, editing, camera and viewport control. Most take their
   arguments as `key=value` pairs on the same line.
2. **[Spinner and toggle value commands](#spinner-and-toggle-value-commands)** -
   one command per numeric or on/off control in the user interface (dates,
   camera settings, palettes, latitude/longitude, and 233 more). Each
   takes a single value: `command_name value`.

------------------------------------------------------------------------

## Core commands

### File and session

-   `CLS`: Clears the command line screen
-   `NEW`: New project
-   `OPEN`: Opens a saved project
-   `SAVE.AS`: Saves the project with a new name
-   `SAVE`: Saves the project
-   `HOLD`: Holds the scene
-   `FETCH`: Fetches the scene
-   `IMPORT.OBJ`: Imports a `.obj` file
-   `EXPORT.OBJ.TIMESERIES`: Exports the scene in `.obj` format at
    different hours (multiple files)
-   `EXPORT.OBJ.DATESERIES`: Exports the scene in `.obj` format at
    different days (multiple files)
-   `EXPORT.OBJ`: Exports the scene in `.obj` format
-   `EXPORT.RAD`: Exports the scene in Radiance `.rad` format
-   `EXPORT.SCR`: Exports the scene in AutoCAD `.scr` format
-   `RUN.SCRIPT`: Executes a `.txt` script file containing multiple
    SOLARCHVISION commands
-   `REC.PNG`: Records the frame (screenshot) in `.png` format (filename is optional)
-   `REC.JPG`: Records the frame (screenshot) in `.jpg` format (filename is optional)
-   `REC.TIF`: Records the frame (screenshot) in `.tif` format (filename is optional)
-   `REC.BMP`: Records the frame (screenshot) in `.bmp` format (filename is optional)
-   `QUIT` or `EXIT`: Exits the software

Several of these are also reachable by their on-screen menu caption, if
you prefer that form: `Open...`, `Save As...`, `Import 3D-model...`,
`Import Command File...`, `Export 3D-model > OBJ` (and
`> OBJ (time-series)`, `> OBJ (date-series)`, `> HTML`, `> RAD`, `> SCR`).

------------------------------------------------------------------------

### Location

-   `SETLAT`: Sets the latitude of the project location

```
SetLat ?
```

-   `SETLON`: Sets the longitude of the project location

```
SetLon ?
```

-   `SETLONLAT`: Sets both at once - **longitude first, then latitude**
    (note the reversed order from typing them separately)

```
SetLonLat <longitude> <latitude>
```

All three also move the currently selected weather station to the new
location, the same as dragging the Latitude/Longitude spinners in the
Location panel.

------------------------------------------------------------------------

### Selection and editing

-   `SELECT`: Selects various categories
```
Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/landpoint
```

-   `DELETE`: Deletes the selection or various categories
```
Delete all/selection/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras
```

-   `COPY`: Copies the selection

```
Copy n=? dx=? dy=? dz=? rx=? ry=? rz=?
```

-   `MOVE`: Moves the selection

```
Move dx=? dy=? dz=?
```

-   `ROTATE` `ROTATEX` `ROTATEY` `ROTATEZ`: Rotates the selection

```
Rotate[X|Y|Z] r=? x=? y=? z=?
```

-   `SCALE`: Scales the selection

```
Scale s=? sx=? sy=? sz=? x=? y=? z=?
```

------------------------------------------------------------------------

### Object creation

-   `PERSON`: Creates a person

```
Person m=? x=? y=? z=?
```

-   `TREE2`: Creates a 2D tree using vertical and horizontal sections

```
Tree2 m=? x=? y=? z=? h=?
```

-   `TREE1`: Creates a parametric fractal tree in 3D
```
Tree1 m=? seed=? degree=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? trunk=? leaf=?
```

-   `BOX2P`: Creates a box using two corner points

```
Box2P m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?
```

-   `BOX`: Creates a box using center point, width, length, and height

```
Box m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?
```

-   `HOUSE1`: Creates a house-like structure with roof folded in all
    directions

```
House1 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?
```

-   `HOUSE2`: Creates a house-like structure with roof folded in one
    direction

```
House2 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?
```

-   `HOUSE3`: Creates a house-like structure with roof folded in the
    second direction

```
House3 m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? dh=? r=?
```

-   `CYLINDER`: Creates a cylinder

```
Cylinder m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?
```

-   `SPHERE`: Creates a sphere

```
Sphere m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?
```

-   `SUPERSPHERE`: Creates a supersphere (deforms from cube to star-like
    object)

```
SuperSphere m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? px=? py=? pz=? deg=? r=?
```

-   `CUSHION`: Creates a cushion-like object

```
Cushion m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?
```

-   `OCTAHEDRON`: Creates an octahedron

```
Octahedron m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? r=?
```

-   `ICOSAHEDRON`: Creates an icosahedron

```
Icosahedron m=? tes=? lyr=? x=? y=? z=? d=? r=?
```

-   `POLYGONMESH`: Creates an equilateral polygon mesh

```
PolygonMesh m=? tes=? lyr=? x=? y=? z=? d=? deg=? r=?
```

-   `POLYGONHYPER`: Creates a hyperbolic surface based on an equilateral
    polygon

```
PolygonHyper m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?
```

-   `POLYGONEXTRUDE`: Creates an extrusion from an equilateral polygon

```
PolygonExtrude m=? tes=? lyr=? x=? y=? z=? d=? h=? deg=? r=?
```

------------------------------------------------------------------------

### Mesh creation

-   `MESH2` to `MESH6`: Creates meshes using 2 to 6 points

```
Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?
```

------------------------------------------------------------------------

### Viewports

-   `ALLVIEWPORTS`: Displays all viewports
-   `ENLARGE3D`: Enlarges the 3D viewport
-   `Enlarge 3D Viewport`, `Enlarge Time Viewport`, `Enlarge Map Viewport`:
    enlarges the 3D, time-graph, or map viewport respectively

------------------------------------------------------------------------

### Camera control

Includes commands such as:

-   `PAN` `PANX` `PANY`
-   `LOOKORG` `LOOKDIR` `LOOKSEL`
-   `TRUCKX` `TRUCKY` `TRUCKZ`
-   `ORBIT` `ORBITZ` `ORBITXY`
-   `CAMERAROLL` `CAMERAROLLZ` `CAMERAROLLXY`
-   `TARGETROLL` `TARGETROLLZ` `TARGETROLLXY`
-   `DISTC` `DISTZ` `DISTXY` `DISTP`
-   `ZOOM` `NORMALZOOM`
-   `PERSPECTIVE` `ORTHOGRAPHIC`

------------------------------------------------------------------------

### Views

-   `TOP` `FRONT` `LEFT` `RIGHT` `BACK` `BOTTOM`
-   `S.W.` `S.E.` `N.E.` `N.W.`

------------------------------------------------------------------------

### Shading and rendering

-   `SHADE.WIRE`: Wireframe view
-   `SHADE.BASE`: Base shading
-   `SHADE.WHITE`: White shading
-   `SHADE.MATERIALS`: Material shading
-   `SHADE.GLOBAL`: Global solar values shading
-   `SHADE.REAL`: Per-vertex solar values shading
-   `SHADE.SOLID`: Solid parameter shading
-   `SHADE.ELEVATION`: Elevation shading
-   `SHADE.VIEWPORT`: Shades the viewport
-   `PREBAKE.VIEWPORT`: Pre-bakes the viewport (also reachable as
    `Prebake Viewport`)

------------------------------------------------------------------------

## Spinner and toggle value commands

Nearly every numeric or on/off spinner in the user interface has a
matching command - 233 of them. They all work the same way:

```
command_name value
```

For example, `begin_day 15` sets the calendar day to 15, and
`tmyepw_displaynear 1` turns that display option on (`0` turns it off).

A few things worth knowing:

-   **Naming**: a command's name is just its on-screen label, with any
    spaces replaced by underscores - so `Begin day` becomes `begin_day`,
    but you can also type it with the space instead (`begin day 15`)
    if you find that more readable; both work the same way.
-   **Out-of-range values are rejected**: if a value is outside the
    listed range, the field is left unchanged (nothing happens - no
    error, no value is applied).
-   **Values are rounded**: each field rounds to its own step size, the
    same way dragging the spinner does (e.g. hours round to whole
    numbers, latitude rounds to 0.01°).
-   Toggle ("on/off") fields accept `0` or `1`.

The tables below are grouped by what they affect, matching the panels in
the user interface.

### Date

| Command | What it sets | Range |
|---|---|---|
| `Begin day` | Day of the month for the study date | 1 to 31 |
| `Begin month` | Month for the study date | 1 to 12 |
| `Begin year` | Year for the study date | 1953 to 2100 |
| `Days past March equinox` | Study date expressed as days since the March equinox (an alternative to setting day/month/year separately) | 0 to 364 |

### Analysis window

| Command | What it sets | Range |
|---|---|---|
| `Start hour` | First hour of the day included in the analysis | 0 to 23 |
| `End hour` | Last hour of the day included in the analysis | 0 to 23 |
| `Join days` | Number of consecutive days grouped together per analysis step | 1 to 182 |
| `Number of days to plot` | Number of days included in the impact plot | 1 to 365 |
| `Day step` | Step size (in days) between plotted days | 1.0 to 182.5 |

### Sampling and forecast sources

| Command | What it sets | Range |
|---|---|---|
| `Start year` | First year of the sampled climate-record range | _(depends on loaded data)_ |
| `End year` | Last year of the sampled climate-record range | _(depends on loaded data)_ |
| `Start member` | First ensemble-forecast member included in the sample | _(depends on loaded data)_ |
| `End member` | Last ensemble-forecast member included in the sample | _(depends on loaded data)_ |
| `Start station` | First observed-weather station included in the sample | _(depends on loaded data)_ |
| `End station` | Last observed-weather station included in the sample | _(depends on loaded data)_ |
| `Climate based solar forecast` | 0 = off, 1 = use climate data for the solar forecast | 0 to 1 |
| `Climate based temperature forecast` | 0 = linear, 1 = average, 2 = sky-based air-temperature/humidity forecast | 0 to 2 |
| `Hourly/daily filter` | 0 = hourly, 1 = daily data filtering | 0 to 1 |
| `Forecast/Obs maxDays` | Maximum number of days considered for forecast/observed data | 0 to 31 |
| `Trend periodHours` | Length of the trend period, in hours | 1 to 384 |
| `Weighted equal trend` | -1/0/1 - how samples are weighted when computing the trend | -1 to 1 |

### Location

| Command | What it sets | Range |
|---|---|---|
| `Latitude` | Project location's latitude (also updates the selected weather station) | -85 to 85 |
| `Longitude` | Project location's longitude (also updates the selected weather station) | -180 to 180 |

### Weather-station display

| Command | What it sets | Range |
|---|---|---|
| `TMYEPW displayNear` | Toggle: highlight the nearest EPW/TMY station on the map | 0 or 1 |
| `CWEEDS displayNear` | Toggle: highlight the nearest CWEEDS station on the map | 0 or 1 |
| `CLMREC displayNear` | Toggle: highlight the nearest CLMREC station on the map | 0 or 1 |
| `NAEFS displayNear` | Toggle: highlight the nearest NAEFS forecast point on the map | 0 or 1 |
| `SWOB displayNear` | Toggle: highlight the nearest SWOB station on the map | 0 or 1 |
| `TMYEPW displayAll` | 0 = hide, 1 = show, 2 = show with labels - all EPW/TMY stations | 0 to 2 |
| `CWEEDS displayAll` | 0 = hide, 1 = show, 2 = show with labels - all CWEEDS stations | 0 to 2 |
| `CLMREC displayAll` | 0 = hide, 1 = show, 2 = show with labels - all CLMREC stations | 0 to 2 |
| `NAEFS displayAll` | 0 = hide, 1 = show, 2 = show with labels - all NAEFS points | 0 to 2 |
| `SWOB displayAll` | 0 = hide, 1 = show, 2 = show with labels - all SWOB stations | 0 to 2 |

### Camera

| Command | What it sets | Range |
|---|---|---|
| `Camera current` | Index of the active saved camera/viewport | _(depends on loaded data)_ |
| `Camera clipNear` | Near clipping distance for the active camera | 0.01 to 100 |
| `Camera clipFar` | Far clipping distance for the active camera | 1000 to 2000000000 |

### Selection tools (3D-select)

| Command | What it sets | Range |
|---|---|---|
| `Select3D alignX` | Selection's X alignment: -1 = min side, 0 = center, 1 = max side | -1 to 1 |
| `Select3D alignY` | Selection's Y alignment: -1 = min side, 0 = center, 1 = max side | -1 to 1 |
| `Select3D alignZ` | Selection's Z alignment: -1 = min side, 0 = center, 1 = max side | -1 to 1 |
| `Select3D posValue` | Move the selection along the current move axis by this offset (relative to its previous value, like dragging the spinner) | -50.0 to 50.0 |
| `Select3D posVector` | Move axis used by 3D-select.posValue: 0 = X, 1 = Y, 2 = Z, 3 = all | 0 to 3 |
| `Select3D rotValue` | Rotate the selection about the current rotate axis by this angle in degrees (relative to its previous value) | -180.0 to 180.0 |
| `Select3D rotVector` | Rotate axis used by 3D-select.rotValue: 0 = X, 1 = Y, 2 = Z | 0 to 2 |
| `Select3D scaleValue` | Scale the selection about the current scale axis (relative to its previous value; each unit change doubles/halves the size) | -8.0 to 8.0 |
| `Select3D scaleVector` | Scale axis used by 3D-select.scaleValue: 0 = X, 1 = Y, 2 = Z, 3 = all | 0 to 3 |
| `Select3D softPower` | Falloff power of soft (proportional) selection | 0.125 to 8.0 |
| `Select3D softRadius` | Radius of influence of soft (proportional) selection | 0.01 to 100 |
| `Select3D displayReferencePivot` | Toggle: show the reference pivot point | 0 or 1 |
| `Select3D groupDisplayPivot` | Toggle: show the selected group's pivot point | 0 or 1 |
| `Select3D groupDisplayBox` | Toggle: draw the selected group's bounding box | 0 or 1 |
| `Select3D groupDisplayEdges` | Toggle: draw the selected group's edges | 0 or 1 |
| `Select3D faceDisplayEdges` | Toggle: draw edges of selected faces | 0 or 1 |
| `Select3D faceDisplayVertexCount` | Toggle: label selected faces with their vertex count | 0 or 1 |
| `Select3D vertexDisplayVertices` | Toggle: draw selected vertices | 0 or 1 |
| `Select3D polylineDisplayVertices` | Toggle: draw vertices of selected polylines | 0 or 1 |
| `Select3D polylineDisplayVertexCount` | Toggle: label selected polylines with their vertex count | 0 or 1 |
| `Select3D solidDisplayEdges` | Toggle: draw edges of selected solids | 0 or 1 |
| `Select3D sectionDisplayEdges` | Toggle: draw edges of selected sections | 0 or 1 |
| `Select3D cameraDisplayEdges` | Toggle: draw camera outlines for the selection | 0 or 1 |
| `Select3D model1DDisplayEdges` | Toggle: draw edges of selected 1D models (trees, poles, etc.) | 0 or 1 |
| `Select3D model2DDisplayEdges` | Toggle: draw edges of selected 2D models | 0 or 1 |
| `Select3D landPointDisplayPoints` | Toggle: draw selected land points | 0 or 1 |
| `Create3D displayEdges` | Toggle: draw edges while creating new geometry | 0 or 1 |
| `Create3D displayVertices` | Toggle: draw vertices while creating new geometry | 0 or 1 |
| `Create3D displayNormals` | Toggle: draw normals while creating new geometry | 0 or 1 |

### New-object defaults (3D-create)

| Command | What it sets | Range |
|---|---|---|
| `Create3D layer` | Default layer assigned to new objects | 0 to 16 |
| `Create3D material` | Default material index for new objects (-1 = none) | -1 to 8 |
| `Create3D visibility` | Default visibility (-1/0/1) assigned to new faces | -1 to 1 |
| `Create3D weight` | Default weight/thickness assigned to new 1D model segments | -20 to 20 |
| `Create3D tessellation` | Default tessellation level applied to new faces | 0 to 6 |
| `Create3D displayTessellation` | Default tessellation-display mode for new faces | 0 to 4 |
| `Create3D snap` | Toggle: snap new objects to the land surface/grid while placing them | 0 to 1 |
| `Create3D orientation` | Default orientation angle (degrees) for new objects | 0 to 360 |
| `Create3D volume` | Default target volume for new objects that size themselves by volume | 0 to 1000000000 |
| `Create3D height` | Default height for new objects (a negative value randomizes it) | -100.0 to 1000.0 |
| `Create3D length` | Default length for new objects (a negative value randomizes it) | -100.0 to 1000.0 |
| `Create3D width` | Default width for new objects (a negative value randomizes it) | -100.0 to 1000.0 |
| `Create3D cylinderDegree` | Default number of sides for new cylinders | 3 to 36 |
| `Create3D sphereDegree` | Default subdivision level for new spheres | 0 to 5 |
| `Create3D polyDegree` | Default number of sides for new polygon-based objects | 3 to 36 |
| `Create3D powAll` | Default exponent applied to all three axes of new superellipsoid-style objects (cushions, superspheres, ...) | _(depends on loaded data)_ |
| `Create3D powX` | Default X-axis exponent for new superellipsoid-style objects | _(depends on loaded data)_ |
| `Create3D powY` | Default Y-axis exponent for new superellipsoid-style objects | _(depends on loaded data)_ |
| `Create3D powZ` | Default Z-axis exponent for new superellipsoid-style objects | _(depends on loaded data)_ |
| `Create3D type` | Default sub-type for the current creation tool | 0 to 0 |
| `Create3D parametricType` | Default parametric-object variant (1-6) used by the Parametric creation tools | 1 to 6 |
| `Create3D personType` | Default person model variant used when adding people | _(depends on loaded data)_ |
| `Create3D plantType` | Default tree/plant model variant used when adding 1D-trees | _(depends on loaded data)_ |
| `Create3D seed` | Default random seed for new fractal trees/materials (-1 = random each time) | -1 to 32767 |
| `Create3D branchRatio` | Default branch-length ratio for new fractal trees | 0.05 to 1 |
| `Create3D branchTilt` | Default branch tilt angle (degrees) for new fractal trees | 0 to 360 |
| `Create3D branchTwist` | Default branch twist angle (degrees) for new fractal trees | 0 to 360 |
| `Create3D degreeMax` | Default maximum branching degree for new fractal trees | 0 to 12 |
| `Create3D leafSize` | Default leaf size for new fractal trees | 0 to 1 |
| `Create3D treeBase` | Default trunk base radius for new fractal trees | 0 to 4 |
| `Create3D trunkSize` | Default trunk size for new fractal trees | 0 to 10 |
| `Create3D closed` | Default open/closed state (0/1) for new extruded/mesh geometry | 0 to 1 |

### Modify tools (3D-modify)

| Command | What it sets | Range |
|---|---|---|
| `Modify3D offsetAmount` | Distance used by the vertex-offset tools (above/below/expand/shrink) | 0 to 25 |
| `Modify3D openningArea` | Target area for newly inserted openings (windows/doors) | 0 to 1 |
| `Modify3D openningDepth` | Depth (inset/outset) of newly inserted openings | -10 to 10 |
| `Modify3D openningDeviation` | Allowed random deviation applied to inserted openings | 0 to 1 |
| `Modify3D tessellateRows` | Number of rows used by the row/column tessellation tool | 1 to 100 |
| `Modify3D tessellateColumns` | Number of columns used by the row/column tessellation tool | 1 to 100 |
| `Modify3D weldTreshold` | Maximum distance between vertices for the weld tools to merge them | 0 to 10 |

### Export defaults (3D-export)

| Command | What it sets | Range |
|---|---|---|
| `Export3D scale` | Uniform scale factor applied to exported geometry | .001 to 1000 |
| `Export3D backSides` | Toggle: include back-facing faces when exporting | 0 or 1 |
| `Export3D flipZYaxis` | Toggle: swap the Z and Y axes on export (for tools that use Y-up) | 0 to 1 |
| `Export3D polyToPoly` | Toggle: export polylines as connected poly-to-poly geometry | 0 to 1 |
| `Export3D materialLibrary` | Toggle: write a companion material-library file on export | 0 or 1 |
| `Export3D paletteResolution` | Number of colour steps used when exporting palette-based (impact/solar) shading | 32 to 2048 |
| `Export3D precisionVertex` | Number of decimal places kept for exported vertex coordinates | 0 to 6 |
| `Export3D precisionVtexture` | Number of decimal places kept for exported texture coordinates | 0 to 6 |

### Land

| Command | What it sets | Range |
|---|---|---|
| `Land3D displaySurface` | Toggle: show the land surface | 0 or 1 |
| `Land3D displayTexture` | Toggle: show the land texture (aerial imagery) | 0 or 1 |
| `Land3D displayPoints` | Toggle: show land survey points | 0 or 1 |
| `Land3D displayDepth` | Toggle: shade the land by elevation/depth | 0 or 1 |
| `Land3D displayTessellation` | Tessellation-display mode for the land surface | 0 to 4 |
| `Land3D loadMesh` | Toggle: (re)load the land mesh from its topography source | 0 or 1 |
| `Land3D loadTextures` | Toggle: (re)load the land texture images | 0 or 1 |
| `Land3D skipStart` | First row/column of the land grid to skip (for coarser previews) | _(depends on loaded data)_ |
| `Land3D skipEnd` | Last row/column of the land grid to skip | _(depends on loaded data)_ |
| `Land3D paletteClr` | Colour-scale index used for land elevation shading | _(depends on loaded data)_ |
| `Land3D paletteDir` | Colour-scale direction (-2..2) for land elevation shading | -2 to 2 |
| `Land3D paletteMlt` | Colour-scale multiplier for land elevation shading | 0.001 to 0.5 |

### Sky, sun, moon and atmosphere

| Command | What it sets | Range |
|---|---|---|
| `Sky status` | 1-4: sky rendering mode (clear/overcast/etc.) | 1 to 4 |
| `Sky3D scale` | Radius of the sky dome | 1 to 4000000 |
| `Sky3D displayTessellation` | Tessellation-display mode for the sky dome | 0 to 4 |
| `Sky3D displaySurface` | Toggle: show the sky dome surface | 0 or 1 |
| `Sun3D displaySurface` | Toggle: show the sun disc | 0 or 1 |
| `Sun3D displayTexture` | Toggle: show the sun texture | 0 or 1 |
| `Sun3D displayPath` | Toggle: show the sun's daily path | 0 or 1 |
| `Sun3D displayPattern` | Toggle: show the sun's annual pattern (analemma) | 0 or 1 |
| `Sun3D fitInSkyDome` | Toggle: scale the sun path/pattern to fit inside the sky dome | 0 or 1 |
| `Moon3D displaySurface` | Toggle: show the moon | 0 or 1 |
| `Moon3D displayTexture` | Toggle: show the moon texture | 0 or 1 |
| `Moon3D fitInSkyDome` | Toggle: scale the moon to fit inside the sky dome | 0 or 1 |
| `Tropo3D displaySurface` | Toggle: show the troposphere layer | 0 or 1 |
| `Tropo3D displayTexture` | Toggle: show the troposphere texture | 0 or 1 |
| `Earth3D displaySurface` | Toggle: show the Earth globe surface | 0 or 1 |
| `Earth3D displayTexture` | Toggle: show the Earth globe texture | 0 or 1 |
| `Earth3D levelOfDetail` | Level of detail (tile resolution) used for the Earth globe texture | 0.0625 to 16 |
| `Planetary magnification` | Visual size multiplier for the sun/moon/planets | 1 to 64 |

### Shading colour palettes

| Command | What it sets | Range |
|---|---|---|
| `Study activePaletteClr` | Colour-scale index for active-surface impact shading | _(depends on loaded data)_ |
| `Study activePaletteDir` | Colour-scale direction for active-surface impact shading | -2 to 2 |
| `Study activePaletteMlt` | Colour-scale multiplier for active-surface impact shading | 0.125 to 8 |
| `Study passivePaletteClr` | Colour-scale index for passive-surface impact shading | _(depends on loaded data)_ |
| `Study passivePaletteDir` | Colour-scale direction for passive-surface impact shading | -2 to 2 |
| `Study passivePaletteMlt` | Colour-scale multiplier for passive-surface impact shading | 0.125 to 8 |
| `Study sortPaletteClr` | Colour-scale index for sorted-value shading | _(depends on loaded data)_ |
| `Study sortPaletteDir` | Colour-scale direction for sorted-value shading | -2 to 2 |
| `Study sortPaletteMlt` | Colour-scale multiplier for sorted-value shading | 0.125 to 8 |
| `Study probPaletteClr` | Colour-scale index for probability shading | _(depends on loaded data)_ |
| `Study probPaletteDir` | Colour-scale direction for probability shading | -2 to 2 |
| `Study probPaletteMlt` | Colour-scale multiplier for probability shading | 0.125 to 8 |
| `Faces activePaletteClr` | Colour-scale index for face shading, active side | _(depends on loaded data)_ |
| `Faces activePaletteDir` | Colour-scale direction for face shading, active side | -2 to 2 |
| `Faces activePaletteMlt` | Colour-scale multiplier for face shading, active side | 0.125 to 8 |
| `Faces passivePaletteClr` | Colour-scale index for face shading, passive side | _(depends on loaded data)_ |
| `Faces passivePaletteDir` | Colour-scale direction for face shading, passive side | -2 to 2 |
| `Faces passivePaletteMlt` | Colour-scale multiplier for face shading, passive side | 0.125 to 8 |
| `Solids paletteClr` | Colour-scale index for solid shading | _(depends on loaded data)_ |
| `Solids paletteDir` | Colour-scale direction for solid shading | -2 to 2 |
| `Solids paletteMlt` | Colour-scale multiplier for solid shading | 0.0001 to 64 |
| `Sky3D activePaletteClr` | Colour-scale index for the sky dome, active-side shading | _(depends on loaded data)_ |
| `Sky3D activePaletteDir` | Colour-scale direction for the sky dome, active-side shading | -2 to 2 |
| `Sky3D activePaletteMlt` | Colour-scale multiplier for the sky dome, active-side shading | 0.125 to 8 |
| `Sky3D passivePaletteClr` | Colour-scale index for the sky dome, passive-side shading | _(depends on loaded data)_ |
| `Sky3D passivePaletteDir` | Colour-scale direction for the sky dome, passive-side shading | -2 to 2 |
| `Sky3D passivePaletteMlt` | Colour-scale multiplier for the sky dome, passive-side shading | 0.125 to 8 |
| `Sun3D activePaletteClr` | Colour-scale index for the sun path, active-side shading | _(depends on loaded data)_ |
| `Sun3D activePaletteDir` | Colour-scale direction for the sun path, active-side shading | -2 to 2 |
| `Sun3D activePaletteMlt` | Colour-scale multiplier for the sun path, active-side shading | 0.125 to 8 |
| `Sun3D passivePaletteClr` | Colour-scale index for the sun path, passive-side shading | _(depends on loaded data)_ |
| `Sun3D passivePaletteDir` | Colour-scale direction for the sun path, passive-side shading | -2 to 2 |
| `Sun3D passivePaletteMlt` | Colour-scale multiplier for the sun path, passive-side shading | 0.125 to 8 |
| `WindFlows paletteClr` | Colour-scale index for wind-flow shading | _(depends on loaded data)_ |
| `WindFlows paletteDir` | Colour-scale direction for wind-flow shading | -2 to 2 |
| `WindFlows paletteMlt` | Colour-scale multiplier for wind-flow shading | 0.01 to 1.0 |

### Solid and solar impact analysis

| Command | What it sets | Range |
|---|---|---|
| `Impact source` | Which loaded data source the impact analysis is computed from | _(depends on loaded data)_ |
| `Impact min 50 max` | Which impact statistic is shown: minimum, median, or maximum | 0 to 8 |
| `Impacts displayDay` | Which day (within the plotted range) is currently shown | _(depends on loaded data)_ |
| `SolidImpacts sectionType` | Which section cut (0-3) the solid-impact analysis uses | 0 to 3 |
| `SolarImpacts sectionType` | Which section cut (0-3) the solar-impact analysis uses | 0 to 3 |
| `SolidImpacts grade` | Ground slope/grade used for solid-impact analysis | 0.0001 to 64.0 |
| `SolidImpacts power` | Exponent applied when weighting solid-impact results | 0.0001 to 64.0 |
| `SolidImpacts processSubDivisions` | Number of subdivisions used when processing solid impacts | 0 to 3 |
| `SolidImpacts positionStep` | Step size used when stepping through impact-analysis positions | 5 to 80 |
| `SolidImpacts r` | Rotation of the current impact-analysis section | -360 to 360 |
| `SolidImpacts u` | U-axis scale of the current impact-analysis section | 0.125 to 3200 |
| `SolidImpacts v` | V-axis scale of the current impact-analysis section | 0.125 to 3200 |
| `SolidImpacts x` | X offset of the current impact-analysis section | -10000 to 10000 |
| `SolidImpacts y` | Y offset of the current impact-analysis section | -10000 to 10000 |
| `SolidImpacts z` | Z offset (elevation) of the current impact-analysis section | -1000 to 1000 |
| `SolidImpacts windSpeedMps` | Wind speed (m/s) used for wind-impact analysis | 1 to 16 |
| `SolidImpacts windDirection` | Wind direction (degrees) used for wind-impact analysis | 0 to 360 |
| `SolidImpacts displayPoints` | Toggle: show solid-impact analysis points | 0 or 1 |
| `SolidImpacts displayLines` | Toggle: show solid-impact analysis lines | 0 or 1 |
| `SolidImpacts displayImage` | Toggle: show the rendered solid-impact image | 0 or 1 |
| `SolarImpacts displayImage` | Toggle: show the rendered solar-impact image | 0 or 1 |
| `Probabilities interval` | Bucket size (hours) used when computing probability distributions | 1 to 24 |
| `Probabilities range` | Number of buckets used when computing probability distributions | 2 to 32 |
| `Draw data` | Toggle: include raw data in the plotted graph | 0 or 1 |
| `Draw probabilities` | Toggle: include probability curves in the plotted graph | 0 or 1 |
| `Draw sorted` | Toggle: include the sorted-value curve in the plotted graph | 0 or 1 |
| `Draw statistics` | Toggle: include summary statistics in the plotted graph | 0 or 1 |
| `Export ASCII data` | Toggle: also export the raw data as an ASCII text file | 0 or 1 |
| `Export ASCII probabilities` | Toggle: also export the probability data as an ASCII text file | 0 or 1 |
| `Export ASCII statistics` | Toggle: also export the summary statistics as an ASCII text file | 0 or 1 |
| `Record Solar Analysis in JPG` | Toggle: save each solar-analysis frame as a JPG | 0 to 1 |
| `Record SolidImpact in JPG` | Toggle: save each solid-impact frame as a JPG | 0 to 1 |
| `Record SolidImpact in PDF` | Toggle: save each solid-impact frame as a PDF | 0 to 1 |
| `Diagram setup` | Layout preset used for the multi-panel diagram view | -2 to 8 |

### Wind roses and wind flow

| Command | What it sets | Range |
|---|---|---|
| `WindRoses displayImage` | Toggle: show the rendered wind-rose image | 0 or 1 |
| `WindRoses scale` | Display scale of the wind-rose diagram | 50 to 3200 |
| `WindRoses resolution` | Pixel resolution used when rendering the wind-rose image | 200 to 600 |
| `WindRose opacityScale` | Opacity scale used when drawing the wind-rose diagram | 1 to 100 |
| `WindFlows displayAll` | Toggle: show all wind-flow lines | 0 or 1 |

### Other display toggles

| Command | What it sets | Range |
|---|---|---|
| `Faces displayAll` | Toggle: show all faces | 0 or 1 |
| `Solids displayAll` | Toggle: show all solids | 0 or 1 |
| `Model1Ds displayAll` | Toggle: show all 1D models (trees, poles, etc.) | 0 or 1 |
| `Model1Ds displayLeaves` | Toggle: show leaves on 1D tree models | 0 or 1 |
| `Model2Ds displayAll` | Toggle: show all 2D models | 0 or 1 |
| `Polylines displayAll` | Toggle: show all polylines | 0 or 1 |
| `Sections displayAll` | Toggle: show all sections | 0 or 1 |
| `Cameras displayAll` | Toggle: show all saved cameras | 0 or 1 |

### Miscellaneous

| Command | What it sets | Range |
|---|---|---|
| `Objects scale` | Overall display scale applied to placed objects | 0.0000001 to 1000000 |
| `Interpolation weight` | Weight applied when interpolating between data points | 0 to 5 |
| `Inclination angle` | Inclination angle (degrees) used for solid-impact analysis | 0 to 90 |
| `Orientation angle` | Orientation angle (degrees) used for solid-impact analysis | 0 to 360 |
| `Scale` | Selected solid's impact-analysis scale factor | 0.0001 to 10000 |
| `AddToLastGroup` | Toggle: add newly created objects to the most recently used group | 0 or 1 |

### Developer/debug

| Command | What it sets | Range |
|---|---|---|
| `Develop option` | (developer/debug option) | 0 to 11 |
| `Develop dayHour` | (developer/debug option) | 0 to 3 |

------------------------------------------------------------------------

## Other menu commands

These correspond to menu items and toolbar buttons rather than numeric
values - type the name shown (spaces are fine) and press `Enter`; none of
them take an argument.

### Switch to a click-to-create tool

Running one of these switches the active tool; you then click (and for
some, drag) in the 3D viewport to actually place the object, instead of
giving all its coordinates on the command line the way `BOX`, `SPHERE`
and the other [object creation](#object-creation) commands do.

`Point`, `Polyline`, `Surface`, `Plane`, `Pyramid`, `Polygon`, `Extrude`,
`Solid`, `Section`, `Camera`, `Parametric 1` through `Parametric 6`

### Object-property tools (Pick / Change / Assign)

These come in threes, one per editable property (`Pivot`, `Layer`,
`Visibility`, `Weight`, `Seed/Material`, `tessellation`,
`Model1DsProps`, and the fractal-tree properties `BranchRatio`,
`BranchTilt`, `BranchTwist`, `DegreeMax`, `LeafSize`, `TreeBase`,
`TrunkSize`):

-   `Pick <property>`: click an existing object to read its value
-   `Change <property>`: click and drag to interactively change it on
    the selection
-   `Assign <property>`: apply the current default (see the matching
    `3D-create.*`/`3D-modify.*` value command above) to the selection

There's also a plain `Pick Select` / `Pick Select+` / `Pick Select-`
trio that switches the click-to-select tool between replace, add, and
subtract modes.

### Selection

-   `Select All`, `Select All-Cameras`, `Select All-Faces`,
    `Select All-Groups`, `Select All-Model1Ds`, `Select All-Model2Ds`,
    `Select All-Polylines`, `Select All-Sections`, `Select All-Solids`,
    `Select All-Verices`
-   `Select Camera`, `Select Face`, `Select Group`, `Select LandPoint`,
    `Select Model1Ds`, `Select Model2Ds`, `Select Polyline`,
    `Select Section`, `Select Solid`, `Select Vertex`
-   `Deselect All`, `Invert Selection`, `Isolate Selection`
-   `Select Near Selected Vertices`, `Select Scene Isolated Vertices`
-   `Window Select`, `Window Select+`, `Window Select-`: draw a
    rectangle to replace, add to, or subtract from the selection
-   `Soft Selection`: enables falloff-based (proportional) selection -
    see `Select3D softPower`/`Select3D softRadius` above

### Groups

-   `Group Selection`, `Ungroup Selection`
-   `Attach to Last Group`, `Dettach from Groups Selection`
-   `Begin New Group at Origin`, `Begin New Group at Pivot`
-   `Faces >> Groups`, `Groups >> Faces`, `Groups >> Model1Ds`,
    `Groups >> Model2Ds`, `Groups >> Polylines`, `Groups >> Solids`,
    `Groups >> Vertices`, `Model1Ds >> Groups`, `Model2Ds >> Groups`,
    `Polylines >> Groups`, `Solids >> Groups`, `Vertices >> Groups`,
    `LandGap >> Group`, `LandMesh >> Group`: move objects of one
    category into/out of the current group

### Deleting

-   `Delete All`, `Delete All-Cameras`, `Delete All-Faces`,
    `Delete All-Groups`, `Delete All-Model1Ds`, `Delete All-Model2Ds`,
    `Delete All-Polylines`, `Delete All-Sections`, `Delete All-Solids`
-   `Delete Selection`, `Delete Selection Isolated Vertices`
-   `Delete Scene Empty Groups`, `Delete Scene Isolated Vertices`

### Show, hide and show/hide

Most viewable elements have up to three related commands: `Show <X>`
(make it visible), `Hide <X>` (make it invisible), and `Show/Hide <X>`
(toggle it). `<X>` is one of:

`Cameras`, `CLMREC nearest`, `CLMREC stations`, `CWEEDS nearest`,
`CWEEDS stations`, `Earth Surface`, `Edges`, `Faces`, `Land Depth`,
`Land Mesh`, `Land Points`, `Land Texture`, `Leaves`, `Model1Ds`,
`Model2Ds`, `Moon Surface`, `NAEFS nearest`, `NAEFS stations`, `Normals`,
`Polylines`, `Sections`, `Selected 1D Edges`, `Selected 2D Edges`,
`Selected Cameras`, `Selected Faces`, `Selected Faces Vertex Count`,
`Selected Group Box`, `Selected Group Edges`, `Selected Group Pivot`,
`Selected LandPoints`, `Selected Polylines`,
`Selected Polylines Vertex Count`, `Selected Ref Pivot`,
`Selected Sections`, `Selected Solids`, `Selected Vertices`, `Sky`,
`Solar Section`, `Solid Section`, `Solids`, `Sun Grid`, `Sun Path`,
`Sun Pattern`, `Sun Surface`, `SWOB nearest`, `SWOB stations`,
`TMYEPW nearest`, `TMYEPW stations`, `Troposphere`, `Vertices`,
`Wind Flow`

`Unhide All-Faces` and `Unhide Selected Faces` also exist as one-way
opposites of `Hide All-Faces`/`Hide Selected Faces`.

### Camera and view navigation

Additional aliases and variants beyond the [camera control](#camera-control)
and [views](#views) commands above - each switches to a mouse-drag tool
for that action:

-   `Pan`, `PanX`, `PanY`
-   `Orbit`, `OrbitXY`, `OrbitZ`, `LandOrbit`
-   `TruckX`, `TruckY`, `TruckZ`
-   `CameraRoll`, `CameraRollXY`, `CameraRollZ`
-   `TargetRoll`, `TargetRollXY`, `TargetRollZ`
-   `DistZ`, `DistMouseXY`, `CameraDistance`
-   `Zoom`, `Zoom as default`
-   `Perspective`, `Orthographic`
-   `Look at origin`, `Look at direction`, `Look at selection`
-   `3DModelSize`, `AllModelSize`, `SkydomeSize`: frame the camera to fit
    the model, the whole scene, or the sky dome
-   `Camera >> Viewport`, `Viewport >> Camera`: copy a saved camera's
    view into the active viewport, or save the active viewport as a
    camera
-   `Camera View`: applies the last-selected camera's saved view to the
    active viewport
-   `Display All Viewports`

### Move / rotate / scale by axis

Single-axis variants of the [`MOVE`](#selection-and-editing)/`ROTATE`/`SCALE`
commands, each switching to a mouse-drag tool for that one axis:

-   `Move`, `MoveX`, `MoveY`, `MoveZ`
-   `Rotate`, `RotateX`, `RotateY`, `RotateZ`
-   `Scale`, `ScaleX`, `ScaleY`, `ScaleZ`
-   `Power`, `PowerX`, `PowerY`, `PowerZ`: adjust the superellipsoid
    power exponent (see `Create3D powAll`/`Create3D powX`/`Create3D powY`/`Create3D powZ` above)
    on the current selection

### Screenshots and recording

-   `Screenshot`, `Screenshot+Click`, `Screenshot+Drag`
-   `REC. Screenshot`, `REC. Time Graph`, `REC. Location Graph`,
    `REC. Solid Graph`, `Stop REC.`
-   `JPG 3D Graph`, `JPG 3D Full-Period`, `JPG Time Graph`,
    `JPG Location Graph`
-   `PDF Time Graph`, `PDF Location Graph`

### Weather and climate data

-   `Download TMYEPW`, `Download CWEEDS`, `Download NAEFS`,
    `Download SWOB`, `Download CLMREC`, `Download Land Mesh`,
    `Download Land Texture`
-   `Update TMYEPW`, `Update CWEEDS`, `Update NAEFS`, `Update SWOB`,
    `Update CLMREC`, `Update Station`
-   `Load Land Mesh`, `Load Land Texture`, `Load Toroposphere`
-   `Use typical year (TMY)`, `Use long-term (CWEEDS)`,
    `Use long-term (CLMREC)`, `Use real-time observed (SWOB)`,
    `Use weather forecast (NAEFS)`: choose which data source feeds the
    current study

### Impact analysis

-   `Process Active Impact`, `Process Passive Impact`,
    `Process Solid Impact`
-   `Wind pattern (active)`, `Wind pattern (passive)`
-   `Urban solar potential (active)`, `Urban solar potential (passive)`
-   `Orientation potential (active)`, `Orientation potential (passive)`
-   `Hourly sun position (active)`, `Hourly sun position (passive)`
-   `Annual cycle sun path (active)`, `Annual cycle sun path (passive)`
-   `Active Shade`, `Passive Shade`
-   `Run wind 3D-model`
-   `Prebake Selected Sections`

### Shading

-   `Shade Surface Wire`, `Shade Surface Base`, `Shade Surface White`,
    `Shade Surface Materials`
-   `Shade Global Solar`, `Shade Vertex Solar`, `Shade Vertex Solid`,
    `Shade Vertex Elevation`
-   `Shade Viewport`

(these are equivalent to the `SHADE.*` commands under
[Shading and rendering](#shading-and-rendering) above)

### Geometry editing

-   `Offset(above) Vertices`, `Offset(below) Vertices`,
    `Offset(expand) Vertices`, `Offset(shrink) Vertices`
-   `Insert Corner Opennings`, `Insert Edge Opennings`,
    `Insert Parallel Opennings`, `Insert Rotated Opennings`
-   `Extrude Face Edges`
-   `Weld Objects Selected Vertices`, `Weld Scene Selected Vertices`,
    `Separate Selected Vertices`
-   `Reposition Selected Vertices`, `Flatten Selected LandPoints`
-   `Flip Normal`, `Set-In Normal`, `Set-Out Normal`,
    `Auto-Normal Selected Faces`
-   `Force Triangulate Selected Faces`, `Optimize Faces`,
    `Reverse Visibility of All-Faces`
-   `Tessellate Rectangular`, `Tessellate Triangular`,
    `Tessellate Rows & Columns`
-   `Faces >> Vertices`, `Vertices >> Faces`, `Polylines >> Vertices`,
    `Vertices >> Polylines`

### Cloning and placement

-   `Clone Selection (Identical)`, `Clone Selection (Variation)`
-   `Add People on Land`, `Add 1D-Trees on Land`, `Add 2D-Trees on Land`
-   `Drop on LandSurface`, `Drop on ModelSurface (Up)`,
    `Drop on ModelSurface (Down)`
-   `1D-Tree`, `2D-Tree`: shortcuts to the tree-creation tools

### Reference box and pivot

-   `Save Current ReferenceBox`, `Use Selection ReferenceBox`,
    `Use Origin ReferenceBox`, `Reset Saved ReferenceBox`
-   `Pivot`, `Assign Pivot`, `Pick Pivot`
-   `PivotX:Center`, `PivotX:Minimum`, `PivotX:Maximum`
-   `PivotY:Center`, `PivotY:Minimum`, `PivotY:Maximum`
-   `PivotZ:Center`, `PivotZ:Minimum`, `PivotZ:Maximum`
-   `Get FirstVertex`, `Get dX`, `Get dY`, `Get dZ`, `Get dXY`, `Get dXYZ`

### About

-   `SOLARCHVISION-BIM6D`, `Designed & developed by`, `Mojtaba Samimi`,
    `www.solarchvision.com`: open the corresponding link
