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
-   `EXIT`: Exits command console
-   `QUIT`: Exits the software

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

```
SetLonLat <longitude> <latitude>
```

-   `SETLATLON`: Sets both at once - **latitude first, then longitude**

```
SetLatLon <latitude> <longitude>
```

All four also move the currently selected weather station to the new
location, the same as dragging the Location Latitude/Location Longitude spinners in the
Location panel.

------------------------------------------------------------------------

### Selection and editing

-   `SELECT`: Selects various categories
```
Select all/last/nothing/invert/groups/model2ds/model1ds/vertices/faces/solids/sections/cameras/terrainpoint
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

-   `RECTSELECT`: Selects everything inside a screen-space rectangle
    (`x1`/`y1`/`x2`/`y2` are viewport-local coordinates, relative to the
    active 3D viewport's own center)

```
RectSelect x1=? y1=? x2=? y2=?
```

-   `GETLENGTH`: Measures the distance between two world points and
    writes it into `User3D.creatorLength`/`Width`/`Height`, choosing
    which depending on the active Get dX/dY/dZ/dXYZ/dXY tool

```
GetLength x1=? y1=? z1=? x2=? y2=? z2=?
```

------------------------------------------------------------------------

### Object creation

-   `BEGINNEWGROUP`: Starts a new group at the given position/scale/
    rotation - the group that House1/2/3, Box, Cylinder and the other
    group-based shapes below add their first mesh or solid into

```
BeginNewGroup x=? y=? z=? sx=? sy=? sz=? rx=? ry=? rz=?
```

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

-   `CONE`: Creates a cone. `dx`/`dy` can differ for an
    elliptical (rather than circular) cross-section; `dz` is the
    height

```
Cone m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? deg=? r=?
```

-   `CYLINDER`: Creates a cylinder. `dx`/`dy` can differ for an
    elliptical (rather than circular) cross-section; `dz` is the
    height

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

-   `PARAMETRIC`: Creates a parametric surface. `n` selects which
    parametric formula to use

```
Parametric m=? tes=? lyr=? x=? y=? z=? dx=? dy=? dz=? n=? r=?
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

-   `MESH2` to `MESH6`: Creates meshes using 2 to 6 points (corners)

```
Mesh2 m=? tes=? lyr=? x1=? y1=? z1=? x2=? y2=? z2=?
```

-   `MESH`: Creates a mesh with an unspecified number of points.

```
Mesh m=? tes=? lyr=? x1,y1,z1 x2,y2,z2 etc.
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

For example, `day 15` sets the calendar day to 15, and
`climate_typical_year_display_near 1` turns that display option on (`0` turns it off).

A few things worth knowing:

-   **Naming**: a command's name is just its on-screen label, with any
    spaces replaced by underscores - so `Start Hour` becomes `start_hour`,
    but you can also type it with the space instead (`start hour 6`)
    if you find that more readable; both work the same way.
-   **Out-of-range values are rejected**: if a value is outside the
    listed range, the field is left unchanged (nothing happens - no
    error, no value is applied).
-   **Values are rounded**: each field rounds to its own step size, the
    same way dragging the spinner does (e.g. hours round to whole
    numbers, latitude rounds to 0.00001°).
-   Toggle ("on/off") fields accept `0` or `1`.

The tables below are grouped by what they affect, matching the panels in
the user interface.

### Date

| Command | What it sets | Range |
|---|---|---|
| `Day` | Day of the month for the study date | 1 to 31 |
| `Month` | Month for the study date | 1 to 12 |
| `Year` | Year for the study date | 1953 to 2100 |
| `Date` | Study date expressed as days since the March equinox (an alternative to setting day/month/year separately) | 0 to 364 |

### Analysis window

| Command | What it sets | Range |
|---|---|---|
| `Start Hour` | First hour of the day included in the analysis | 0 to 23 |
| `End Hour` | Last hour of the day included in the analysis | 0 to 23 |
| `Days Merged Count` | Number of consecutive days grouped together per analysis step | 1 to 182 |
| `End Day` | Number of days included in the impact plot | 1 to 365 |
| `Day Increment` | Step size (in days) between plotted days | 1.0 to 182.5 |

### Sampling and forecast sources

| Command | What it sets | Range |
|---|---|---|
| `Sample Year Start` | First year of the sampled climate-record range | _(depends on loaded data)_ |
| `Sample Year End` | Last year of the sampled climate-record range | _(depends on loaded data)_ |
| `Sample Member Start` | First ensemble-forecast member included in the sample | _(depends on loaded data)_ |
| `Sample Member End` | Last ensemble-forecast member included in the sample | _(depends on loaded data)_ |
| `Sample Station Start` | First observed-weather station included in the sample | _(depends on loaded data)_ |
| `Sample Station End` | Last observed-weather station included in the sample | _(depends on loaded data)_ |
| `Climate Based Solar Forecast` | 0 = off, 1 = use climate data for the solar forecast | 0 to 1 |
| `Climate Based Weather Forecast` | 0 = linear, 1 = average, 2 = sky-based air-temperature/humidity forecast | 0 to 2 |
| `Temporal Filter Setting` | 0 = hourly, 1 = daily data filtering | 0 to 1 |
| `Ensemble Observation Max Days` | Maximum number of days considered for forecast/observed data | 0 to 31 |
| `Trend periodHours` | Length of the trend period, in hours | 1 to 384 |
| `Weighted equal trend` | -1/0/1 - how samples are weighted when computing the trend | -1 to 1 |

### Location

| Command | What it sets | Range |
|---|---|---|
| `Location Latitude` | Project location's latitude (also updates the selected weather station) | -85 to 85 |
| `Location Longitude` | Project location's longitude (also updates the selected weather station) | -180 to 180 |

### Weather-station display

| Command | What it sets | Range |
|---|---|---|
| `Climate Typical Year Display Near` | Toggle: highlight the nearest EPW/TMY station on the map | 0 or 1 |
| `Climate Engineering Display Near` | Toggle: highlight the nearest Climate Engineering station on the map | 0 or 1 |
| `CLMREC Display Near` | Toggle: highlight the nearest Climate Archive station on the map | 0 or 1 |
| `NAEFS Display Near` | Toggle: highlight the nearest Ensemble Forecast forecast point on the map | 0 or 1 |
| `SWOB Display Near` | Toggle: highlight the nearest Ensemble Observation station on the map | 0 or 1 |
| `Climate Typical Year Display All` | 0 = hide, 1 = show, 2 = show with labels - all EPW/TMY stations | 0 to 2 |
| `Climate Engineering Display All` | 0 = hide, 1 = show, 2 = show with labels - all Climate Engineering stations | 0 to 2 |
| `CLMREC Display All` | 0 = hide, 1 = show, 2 = show with labels - all Climate Archive stations | 0 to 2 |
| `NAEFS Display All` | 0 = hide, 1 = show, 2 = show with labels - all Ensemble Forecast points | 0 to 2 |
| `SWOB Display All` | 0 = hide, 1 = show, 2 = show with labels - all Ensemble Observation stations | 0 to 2 |

### Camera

| Command | What it sets | Range |
|---|---|---|
| `Current Camera Index` | Index of the active saved camera/viewport | _(depends on loaded data)_ |
| `Camera Clip Near` | Near clipping distance for the active camera | 0.01 to 100 |
| `Camera Clip Far` | Far clipping distance for the active camera | 1000 to 2000000000 |

### Selection tools (3D-select)

| Command | What it sets | Range |
|---|---|---|
| `Pivot Alignment X` | Selection's X alignment: -1 = min side, 0 = center, 1 = max side | -1 to 1 |
| `Pivot Alignment Y` | Selection's Y alignment: -1 = min side, 0 = center, 1 = max side | -1 to 1 |
| `Pivot Alignment Z` | Selection's Z alignment: -1 = min side, 0 = center, 1 = max side | -1 to 1 |
| `Position Selection` | Move the selection along the current move axis by this offset (relative to its previous value, like dragging the spinner) | -50.0 to 50.0 |
| `Position Vector Index` | Move axis used by 3D-select.position: 0 = X, 1 = Y, 2 = Z, 3 = all | 0 to 3 |
| `Rotation Selection` | Rotate the selection about the current rotate axis by this angle in degrees (relative to its previous value) | -180.0 to 180.0 |
| `Rotation Vector Index` | Rotate axis used by 3D-select.rotation: 0 = X, 1 = Y, 2 = Z | 0 to 2 |
| `Scale Selection` | Scale the selection about the current scale axis (relative to its previous value; each unit change doubles/halves the size) | -8.0 to 8.0 |
| `Scale Vector Index` | Scale axis used by 3D-select.scale: 0 = X, 1 = Y, 2 = Z, 3 = all | 0 to 3 |
| `Soft Selection Falloff Power` | Falloff power of soft (proportional) selection | 0.125 to 8.0 |
| `Soft Selection Falloff Radius` | Radius of influence of soft (proportional) selection | 0.01 to 100 |
| `Pivot Display Reference` | Toggle: show the reference pivot point | 0 or 1 |
| `Group Display Pivot` | Toggle: show the selected group's pivot point | 0 or 1 |
| `Group Display Box` | Toggle: draw the selected group's bounding box | 0 or 1 |
| `Group Display Edges` | Toggle: draw the selected group's edges | 0 or 1 |
| `Face Display Edges` | Toggle: draw edges of selected faces | 0 or 1 |
| `Face Display Vertex Selection` | Toggle: label selected faces with their vertex count | 0 or 1 |
| `Vertex Display Markers` | Toggle: draw selected vertices | 0 or 1 |
| `Polyline Display Vertices` | Toggle: draw vertices of selected polylines | 0 or 1 |
| `Polyline Display Vertex Selection` | Toggle: label selected polylines with their vertex count | 0 or 1 |
| `Solid Display Edges` | Toggle: draw edges of selected solids | 0 or 1 |
| `Section Display Edges` | Toggle: draw edges of selected sections | 0 or 1 |
| `Camera Display Frustum` | Toggle: draw camera outlines for the selection | 0 or 1 |
| `Model1DDisplay Bounds` | Toggle: draw edges of selected 1D models (trees, poles, etc.) | 0 or 1 |
| `Model2DDisplay Bounds` | Toggle: draw edges of selected 2D models | 0 or 1 |
| `Terrain Display Vertices` | Toggle: draw selected land points | 0 or 1 |
| `Create3D Display Edges` | Toggle: draw edges while creating new geometry | 0 or 1 |
| `Create3D Display Vertices` | Toggle: draw vertices while creating new geometry | 0 or 1 |
| `Create3D Display Normals` | Toggle: draw normals while creating new geometry | 0 or 1 |

### New-object defaults (3D-create)

| Command | What it sets | Range |
|---|---|---|
| `Default Layer` | Default layer assigned to new objects | 0 to 16 |
| `Default Material` | Default material index for new objects (-1 = none) | -1 to 8 |
| `Default Visibility` | Default visibility (-1/0/1) assigned to new faces | -1 to 1 |
| `Creator Weight` | Default weight/thickness assigned to new 1D model segments | -20 to 20 |
| `Default Tessellation` | Default tessellation level applied to new faces | 0 to 6 |
| `Create3D Display Tessellation` | Default tessellation-display mode for new faces | 0 to 4 |
| `Creator Snap Mode Index` | Toggle: snap new objects to the land surface/grid while placing them | 0 to 1 |
| `Creator Orientation` | Default orientation angle (degrees) for new objects | 0 to 360 |
| `Creator Volume` | Default target volume for new objects that size themselves by volume | 0 to 1000000000 |
| `Creator Height` | Default height for new objects (a negative value randomizes it) | -100.0 to 1000.0 |
| `Creator Length` | Default length for new objects (a negative value randomizes it) | -100.0 to 1000.0 |
| `Creator Width` | Default width for new objects (a negative value randomizes it) | -100.0 to 1000.0 |
| `Creator Cone Degree` | Default number of sides for new cones | 3 to 36 |
| `Creator Cylinder Degree` | Default number of sides for new cylinders | 3 to 36 |
| `Creator Sphere Degree` | Default subdivision level for new spheres | 0 to 5 |
| `Creator Polygon Degree` | Default number of sides for new polygon-based objects | 3 to 36 |
| `Creator Uniform Superellipsoid Power` | Default exponent applied to all three axes of new superellipsoid-style objects (cushions, superspheres, ...) | _(depends on loaded data)_ |
| `Creator Superellipsoid Power X` | Default X-axis exponent for new superellipsoid-style objects | _(depends on loaded data)_ |
| `Creator Superellipsoid Power Y` | Default Y-axis exponent for new superellipsoid-style objects | _(depends on loaded data)_ |
| `Creator Superellipsoid Power Z` | Default Z-axis exponent for new superellipsoid-style objects | _(depends on loaded data)_ |
| `Creator Model1D Type Index` | Default sub-type for the current creation tool | 0 to 0 |
| `Creator Parametric Type Index` | Default parametric-object variant (1-6) used by the Parametric creation tools | 1 to 6 |
| `Creator Person Type Index` | Default person model variant used when adding people | _(depends on loaded data)_ |
| `Creator Plant Type Index` | Default tree/plant model variant used when adding 1D-trees | _(depends on loaded data)_ |
| `Creator Model1D Seed` | Default random seed for new fractal trees/materials (-1 = random each time) | -1 to 32767 |
| `Creator Model1D Branch Ratio` | Default branch-length ratio for new fractal trees | 0.05 to 1 |
| `Creator Model1D Branch Tilt` | Default branch tilt angle (degrees) for new fractal trees | 0 to 360 |
| `Creator Model1D Branch Twist` | Default branch twist angle (degrees) for new fractal trees | 0 to 360 |
| `Creator Model1D Degree Max` | Default maximum branching degree for new fractal trees | 0 to 12 |
| `Creator Model1D Leaf Size` | Default leaf size for new fractal trees | 0 to 1 |
| `Creator Model1D Tree Base` | Default trunk base radius for new fractal trees | 0 to 4 |
| `Creator Model1D Trunk Size` | Default trunk size for new fractal trees | 0 to 10 |
| `Creator Closed` | Default open/closed state (0/1) for new extruded/mesh geometry | 0 to 1 |

### Modify tools (3D-modify)

| Command | What it sets | Range |
|---|---|---|
| `Modifier Offset Amount` | Distance used by the vertex-offset tools (above/below/expand/shrink) | 0 to 25 |
| `Modifier Opening Area` | Target area for newly inserted openings (windows/doors) | 0 to 1 |
| `Modifier Opening Depth` | Depth (inset/outset) of newly inserted openings | -10 to 10 |
| `Modifier Opening Deviation` | Allowed random deviation applied to inserted openings | 0 to 1 |
| `Modifier Tessellate Rows` | Number of rows used by the row/column tessellation tool | 1 to 100 |
| `Modifier Tessellate Columns` | Number of columns used by the row/column tessellation tool | 1 to 100 |
| `Modifier Weld Threshold` | Maximum distance between vertices for the weld tools to merge them | 0 to 10 |

### Export defaults (3D-export)

| Command | What it sets | Range |
|---|---|---|
| `Exporter Scale` | Uniform scale factor applied to exported geometry | .001 to 1000 |
| `Exporter Double Sided` | Toggle: include back-facing faces when exporting | 0 or 1 |
| `Exporter Yaxis Up` | Toggle: swap the Z and Y axes on export (for tools that use Y-up) | 0 to 1 |
| `Exporter Maintain Polygons` | Toggle: export polylines as connected poly-to-poly geometry | 0 to 1 |
| `Exporter Material Library` | Toggle: write a companion material-library file on export | 0 or 1 |
| `Exporter Colorscale Resolution` | Number of colour steps used when exporting palette-based (impact/solar) shading | 32 to 2048 |
| `Exporter Precision Vertex` | Number of decimal places kept for exported vertex coordinates | 0 to 6 |
| `Exporter Precision Vertex Texture` | Number of decimal places kept for exported texture coordinates | 0 to 6 |

### Land

| Command | What it sets | Range |
|---|---|---|
| `Terrain Display Surface` | Toggle: show the land surface | 0 or 1 |
| `Terrain Display Texture` | Toggle: show the land texture (aerial imagery) | 0 or 1 |
| `Terrain Display Points` | Toggle: show land survey points | 0 or 1 |
| `Display Depth` | Toggle: shade the land by elevation/depth | 0 or 1 |
| `Terrain Display Tessellation` | Tessellation-display mode for the land surface | 0 to 4 |
| `Terrain Load Mesh` | Toggle: (re)load the land mesh from its topography source | 0 or 1 |
| `Terrain Load Textures` | Toggle: (re)load the land texture images | 0 or 1 |
| `Terrain Skip Start` | First row/column of the land grid to skip (for coarser previews) | _(depends on loaded data)_ |
| `Terrain Skip End` | Last row/column of the land grid to skip | _(depends on loaded data)_ |
| `Terrain Colorscale Index` | Colour-scale index used for land elevation shading | _(depends on loaded data)_ |
| `Terrain Colorscale Direction` | Colour-scale direction (-2..2) for land elevation shading | -2 to 2 |
| `Terrain Colorscale Factor` | Colour-scale multiplier for land elevation shading | 0.001 to 0.5 |

### Sky, sun, moon and atmosphere

| Command | What it sets | Range |
|---|---|---|
| `Sky Scenario Setting` | 1-4: sky rendering mode (clear/overcast/etc.) | 1 to 4 |
| `Sky3D Radius` | Radius of the sky dome | 1 to 4000000 |
| `Sky3D Display Tessellation` | Tessellation-display mode for the sky dome | 0 to 4 |
| `Sky3D Display Surface` | Toggle: show the sky dome surface | 0 or 1 |
| `Sun3D Display Surface` | Toggle: show the sun disc | 0 or 1 |
| `Sun3D Display Texture` | Toggle: show the sun texture | 0 or 1 |
| `Sun3D Display Path` | Toggle: show the sun's daily path | 0 or 1 |
| `Sun3D Display Pattern` | Toggle: show the sun's annual pattern (analemma) | 0 or 1 |
| `Sun3D fitInSkyDome` | Toggle: scale the sun path/pattern to fit inside the sky dome | 0 or 1 |
| `Moon3D Display Surface` | Toggle: show the moon | 0 or 1 |
| `Moon3D Display Texture` | Toggle: show the moon texture | 0 or 1 |
| `Moon3D fitInSkyDome` | Toggle: scale the moon to fit inside the sky dome | 0 or 1 |
| `Tropo3D Display Surface` | Toggle: show the troposphere layer | 0 or 1 |
| `Tropo3D Display Texture` | Toggle: show the troposphere texture | 0 or 1 |
| `Earth3D Display Surface` | Toggle: show the Earth globe surface | 0 or 1 |
| `Earth3D Display Texture` | Toggle: show the Earth globe texture | 0 or 1 |
| `Earth3D Level Of Detail` | Level of detail (tile resolution) used for the Earth globe texture | 0.0625 to 16 |
| `Celestial Magnification` | Visual size multiplier for the sun/moon/planets | 1 to 64 |

### Shading colour palettes

| Command | What it sets | Range |
|---|---|---|
| `Study Active Colorscale Index` | Colour-scale index for active-surface impact shading | _(depends on loaded data)_ |
| `Study Active Colorscale Direction` | Colour-scale direction for active-surface impact shading | -2 to 2 |
| `Study Active Colorscale Factor` | Colour-scale multiplier for active-surface impact shading | 0.125 to 8 |
| `Study Passive Colorscale Index` | Colour-scale index for passive-surface impact shading | _(depends on loaded data)_ |
| `Study Passive Colorscale Direction` | Colour-scale direction for passive-surface impact shading | -2 to 2 |
| `Study Passive Colorscale Factor` | Colour-scale multiplier for passive-surface impact shading | 0.125 to 8 |
| `Statistical Ranges Colorscale Index` | Colour-scale index for sorted-value shading | _(depends on loaded data)_ |
| `Statistical Ranges Colorscale Direction` | Colour-scale direction for sorted-value shading | -2 to 2 |
| `Statistical Ranges Colorscale Factor` | Colour-scale multiplier for sorted-value shading | 0.125 to 8 |
| `Probabilities Colorscale Index` | Colour-scale index for probability shading | _(depends on loaded data)_ |
| `Probabilities Colorscale Direction` | Colour-scale direction for probability shading | -2 to 2 |
| `Probabilities Colorscale Factor` | Colour-scale multiplier for probability shading | 0.125 to 8 |
| `Faces Active Colorscale Index` | Colour-scale index for face shading, active side | _(depends on loaded data)_ |
| `Faces Active Colorscale Direction` | Colour-scale direction for face shading, active side | -2 to 2 |
| `Faces Active Colorscale Factor` | Colour-scale multiplier for face shading, active side | 0.125 to 8 |
| `Faces Passive Colorscale Index` | Colour-scale index for face shading, passive side | _(depends on loaded data)_ |
| `Faces Passive Colorscale Direction` | Colour-scale direction for face shading, passive side | -2 to 2 |
| `Faces Passive Colorscale Factor` | Colour-scale multiplier for face shading, passive side | 0.125 to 8 |
| `Solids Colorscale Index` | Colour-scale index for solid shading | _(depends on loaded data)_ |
| `Solids Colorscale Direction` | Colour-scale direction for solid shading | -2 to 2 |
| `Solids Colorscale Factor` | Colour-scale multiplier for solid shading | 0.0001 to 64 |
| `Sky3D Active Colorscale Index` | Colour-scale index for the sky dome, active-side shading | _(depends on loaded data)_ |
| `Sky3D Active Colorscale Direction` | Colour-scale direction for the sky dome, active-side shading | -2 to 2 |
| `Sky3D Active Colorscale Factor` | Colour-scale multiplier for the sky dome, active-side shading | 0.125 to 8 |
| `Sky3D Passive Colorscale Index` | Colour-scale index for the sky dome, passive-side shading | _(depends on loaded data)_ |
| `Sky3D Passive Colorscale Direction` | Colour-scale direction for the sky dome, passive-side shading | -2 to 2 |
| `Sky3D Passive Colorscale Factor` | Colour-scale multiplier for the sky dome, passive-side shading | 0.125 to 8 |
| `Sun3D Active Colorscale Index` | Colour-scale index for the sun path, active-side shading | _(depends on loaded data)_ |
| `Sun3D Active Colorscale Direction` | Colour-scale direction for the sun path, active-side shading | -2 to 2 |
| `Sun3D Active Colorscale Factor` | Colour-scale multiplier for the sun path, active-side shading | 0.125 to 8 |
| `Sun3D Passive Colorscale Index` | Colour-scale index for the sun path, passive-side shading | _(depends on loaded data)_ |
| `Sun3D Passive Colorscale Direction` | Colour-scale direction for the sun path, passive-side shading | -2 to 2 |
| `Sun3D Passive Colorscale Factor` | Colour-scale multiplier for the sun path, passive-side shading | 0.125 to 8 |
| `WindFlows Colorscale Index` | Colour-scale index for wind-flow shading | _(depends on loaded data)_ |
| `WindFlows Colorscale Direction` | Colour-scale direction for wind-flow shading | -2 to 2 |
| `WindFlows Colorscale Factor` | Colour-scale multiplier for wind-flow shading | 0.01 to 1.0 |

### Solid and solar impact analysis

| Command | What it sets | Range |
|---|---|---|
| `Current Data Source` | Which loaded data source the impact analysis is computed from | _(depends on loaded data)_ |
| `Impact Layer Index` | Which impact statistic is shown: minimum, median, or maximum | 0 to 8 |
| `Impact Display Day` | Which day (within the plotted range) is currently shown | _(depends on loaded data)_ |
| `SolidImpacts sectionType` | Which section cut (0-3) the solid-impact analysis uses | 0 to 3 |
| `SolarImpacts sectionType` | Which section cut (0-3) the solar-impact analysis uses | 0 to 3 |
| `Solid Impacts Grade` | Ground slope/grade used for solid-impact analysis | 0.0001 to 64.0 |
| `Solid Impacts Power` | Exponent applied when weighting solid-impact results | 0.0001 to 64.0 |
| `Solid Impacts Process Sub Divisions` | Number of subdivisions used when processing solid impacts | 0 to 3 |
| `Solid Impacts Position Step` | Step size used when stepping through impact-analysis positions | 5 to 80 |
| `Solid Impacts R` | Rotation of the current impact-analysis section | -360 to 360 |
| `Solid Impacts U` | U-axis scale of the current impact-analysis section | 0.125 to 3200 |
| `Solid Impacts V` | V-axis scale of the current impact-analysis section | 0.125 to 3200 |
| `Solid Impacts X` | X offset of the current impact-analysis section | -10000 to 10000 |
| `Solid Impacts Y` | Y offset of the current impact-analysis section | -10000 to 10000 |
| `Solid Impacts Z` | Z offset (elevation) of the current impact-analysis section | -1000 to 1000 |
| `Solid Impacts Wind Speed` | Wind speed (m/s) used for wind-impact analysis | 1 to 16 |
| `Solid Impacts Wind Direction` | Wind direction (degrees) used for wind-impact analysis | 0 to 360 |
| `SolidImpacts Display Points` | Toggle: show solid-impact analysis points | 0 or 1 |
| `Solid Impacts Display Lines` | Toggle: show solid-impact analysis lines | 0 or 1 |
| `SolidImpacts Display Image` | Toggle: show the rendered solid-impact image | 0 or 1 |
| `SolarImpacts Display Image` | Toggle: show the rendered solar-impact image | 0 or 1 |
| `Probability Width Interval` | Bucket size (hours) used when computing probability distributions | 1 to 24 |
| `Probability Height Interval` | Number of buckets used when computing probability distributions | 2 to 32 |
| `Show Raw Lines` | Toggle: include raw data in the plotted graph | 0 or 1 |
| `Show Probabilities` | Toggle: include probability curves in the plotted graph | 0 or 1 |
| `Show Statistical Ranges` | Toggle: include the sorted-value curve in the plotted graph | 0 or 1 |
| `Show Statistics` | Toggle: include summary statistics in the plotted graph | 0 or 1 |
| `Raw Lines Exporter` | Toggle: also export the raw data as an ASCII text file | 0 or 1 |
| `Probabilities Exporter` | Toggle: also export the probability data as an ASCII text file | 0 or 1 |
| `Normal Lines Exporter` | Toggle: also export the summary statistics as an ASCII text file | 0 or 1 |
| `Record Solar Analysis in JPG` | Toggle: save each solar-analysis frame as a JPG | 0 to 1 |
| `Record SolidImpact in JPG` | Toggle: save each solid-impact frame as a JPG | 0 to 1 |
| `Record Solid Impact In PDF` | Toggle: save each solid-impact frame as a PDF | 0 to 1 |
| `Plot Layout Index` | Layout preset used for the multi-panel diagram view | -2 to 8 |

### Wind roses and wind flow

| Command | What it sets | Range |
|---|---|---|
| `WindRoses Display Image` | Toggle: show the rendered wind-rose image | 0 or 1 |
| `Wind Roses Plane Size` | Display scale of the wind-rose diagram | 50 to 3200 |
| `Wind Roses Image Resolution` | Pixel resolution used when rendering the wind-rose image | 200 to 600 |
| `Opacity Percentage` | Opacity scale used when drawing the wind-rose diagram | 1 to 100 |
| `WindFlows Display All` | Toggle: show all wind-flow lines | 0 or 1 |

### Other Display  toggles

| Command | What it sets | Range |
|---|---|---|
| `Faces Display All` | Toggle: show all faces | 0 or 1 |
| `Solids Display All` | Toggle: show all solids | 0 or 1 |
| `Model1Ds Display All` | Toggle: show all 1D models (trees, poles, etc.) | 0 or 1 |
| `Model1Ds Display Leaves` | Toggle: show leaves on 1D tree models | 0 or 1 |
| `Model2Ds Display All` | Toggle: show all 2D models | 0 or 1 |
| `Polylines Display All` | Toggle: show all polylines | 0 or 1 |
| `Sections Display All` | Toggle: show all sections | 0 or 1 |
| `Cameras Display All` | Toggle: show all saved cameras | 0 or 1 |

### Miscellaneous

| Command | What it sets | Range |
|---|---|---|
| `Overall Scale` | Overall display scale applied to placed objects | 0.0000001 to 1000000 |
| `Interpolation Weight` | Weight applied when interpolating between data points | 0 to 5 |
| `Develop Layer Angle Inclination` | Inclination angle (degrees) used for solid-impact analysis | 0 to 90 |
| `Develop Layer Angle Orientation` | Orientation angle (degrees) used for solid-impact analysis | 0 to 360 |
| `Vertical Unit Scale` | Selected solid's impact-analysis scale factor | 0.0001 to 10000 |
| `Add To Last Group` | Toggle: add newly created objects to the most recently used group | 0 or 1 |

### Developer/debug

| Command | What it sets | Range |
|---|---|---|
| `Develop Layer Option` | (developer/debug option) | 0 to 11 |
| `Develop Layer Interval` | (developer/debug option) | 0 to 3 |

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
-   `Select Camera`, `Select Face`, `Select Group`, `Select TerrainVertex`,
    `Select Model1Ds`, `Select Model2Ds`, `Select Polyline`,
    `Select Section`, `Select Solid`, `Select Vertex`
-   `Deselect All`, `Invert Selection`, `Isolate Selection`
-   `Select Near Selected Vertices`, `Select Scene Isolated Vertices`
-   `Window Select`, `Window Select+`, `Window Select-`: draw a
    rectangle to replace, add to, or subtract from the selection
-   `Soft Selection`: enables falloff-based (proportional) selection -
    see `Soft Selection Falloff Power`/`Soft Selection Falloff Radius` above

### Groups

-   `Group Selection`, `Ungroup Selection`
-   `Attach to Last Group`, `Dettach from Groups Selection`
-   `Begin New Group at Origin`, `Begin New Group at Pivot`
-   `Faces >> Groups`, `Groups >> Faces`, `Groups >> Model1Ds`,
    `Groups >> Model2Ds`, `Groups >> Polylines`, `Groups >> Solids`,
    `Groups >> Vertices`, `Model1Ds >> Groups`, `Model2Ds >> Groups`,
    `Polylines >> Groups`, `Solids >> Groups`, `Vertices >> Groups`,
    `LandGap >> Group`, `TerrainMesh >> Group`: move objects of one
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

`Cameras`, `CLMREC nearest`, `CLMREC stations`, `Climate Engineering nearest`,
`Climate Engineering stations`, `Earth Surface`, `Edges`, `Faces`, `Terrain Depth`,
`Terrain Mesh`, `Terrain Vertices`, `Terrain Texture`, `Leaves`, `Model1Ds`,
`Model2Ds`, `Moon Surface`, `NAEFS nearest`, `NAEFS stations`, `Normals`,
`Polylines`, `Sections`, `Selected 1D Edges`, `Selected 2D Edges`,
`Selected Cameras`, `Selected Faces Edges`, `Selected Faces Vertex Count`,
`Selected Group Box`, `Selected Group Edges`, `Selected Group Pivot`,
`Selected Terrain Vertices`, `Selected Polylines`,
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
-   `Orbit`, `OrbitXY`, `OrbitZ`, `TerrainOrbit`
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
-   `Next Camera`, `Previous Camera`: cycle `WIN3D`'s current camera
-   `Zoom In`, `Zoom Out`: adjust the viewport's zoom/dolly directly
    (distinct from `Narrow Field of View`/`Widen Field of View` below,
    which adjust the field of view angle instead)
-   `Narrow Field of View`, `Widen Field of View`
-   `Turn View Left`, `Turn View Right`, `Turn View Up`,
    `Turn View Down`: rotate the viewport's own orientation
-   `Pan Left`, `Pan Right`, `Pan Forward`, `Pan Backward`
-   `Dolly Toward Selection`, `Dolly Away From Selection`: move the
    viewport a fixed step toward/away from the current selection
-   `Nudge Closer to Selection`, `Nudge Away from Selection`: a finer,
    mouse-wheel-style version of the dolly pair above
-   `Orbit Up Around Selection`, `Orbit Down Around Selection`,
    `Orbit Left Around Selection`, `Orbit Right Around Selection`

### Drag-based view navigation

`+`-prefixed, the same convention [mouse-wheel commands](#mouse-wheel-commands)
below use and for the same reason: these mirror the viewport-navigation
actions further above, but take a `dx`/`dy` delta instead of firing once
per keystroke - mouseDragged.pde calls one of these on every mouse-move
event during a drag, so each fires many times in quick succession rather
than once. `dx`/`dy` are typically small (a fraction of a pixel's worth
of screen movement), not whole units. Single-value ones (`dx` only or
`dy` only) take that value bare rather than as a named `dx=?`/`dy=?`
pair, the same simplification the single-value mouse-wheel commands
below use.

```ruby
+PanView dx=? dy=?
+PanViewX ?
+PanViewY ?
+TurnTarget dx=? dy=?
+TurnTargetZ ?
+TurnTargetX ?
+OrbitSelectionXY ?
+OrbitSelectionZ ?
+OrbitSelection dx=? dy=?
+OrbitLand ?
+TurnView dx=? dy=?
+TurnViewX ?
+TurnViewZ ?
```

### Map navigation

-   `Map Zoom In`, `Map Zoom Out`: step the location map's zoom level

### Move / rotate / scale by axis

Single-axis variants of the [`MOVE`](#selection-and-editing)/`ROTATE`/`SCALE`
commands, each switching to a mouse-drag tool for that one axis:

-   `Move`, `MoveX`, `MoveY`, `MoveZ`
-   `Rotate`, `RotateX`, `RotateY`, `RotateZ`
-   `Vertical Unit Scale`, `ScaleX`, `ScaleY`, `ScaleZ`
-   `Power`, `PowerX`, `PowerY`, `PowerZ`: adjust the superellipsoid
    power exponent (see `Creator Uniform Superellipsoid Power`/`Creator Superellipsoid Power X`/`Creator Superellipsoid Power Y`/`Creator Superellipsoid Power Z` above)
    on the current selection
-   `Increase Tool Parameter`, `Decrease Tool Parameter`: nudge the
    current selection via whichever of Rotate/Scale/Move/Edit the
    active tool is

### Mouse-wheel commands

`+`-prefixed, the mouse-wheel counterpart of the `Drag*` commands above:
mouseWheel.pde calls one of these on every wheel notch, each taking a
single bare value (a typical wheel notch is `1` or `-1`) rather than a
named `dx=?`/`dy=?` pair - e.g. `+Days 1`, not `+Days wheelValue=1`.
`+RotateSelection` and `+ScaleSelection` are the two exceptions, since
each also needs the pivot point (`x0`/`y0`/`z0`) to rotate or scale
around.

-   `+Hours`, `+Days`: shift the analysis window's hour/day range,
    scrolled over the case bar
-   `+Scenario`: shifts whichever sample range (climate-engineering
    year, climate-archive year, ensemble-forecast member, or
    ensemble-observation station) matches the current data source
-   `+MapZoom`: steps the location map's zoom level
-   `+RotateSelection v=? x0=? y0=? z0=?`, `+ScaleSelection v=? x0=? y0=? z0=?`:
    rotate/scale the selection around the given pivot - the wheel
    counterpart of `ROTATE`/`SCALE` above, scrolled while that tool is
    active
-   `+EditSelection`: adjusts a face/model/camera/solid/section/group
    property on the selection, meaning depends on the current tool and
    selection category
-   `+Zoom`: dollies (perspective) or scales (orthographic) the
    viewport
-   `+Elevation`: adjusts the viewport's field-of-view angle
-   `+ScaleObjects`, `+ScaleSkydome`, `+ScaleAllModel`: scale the
    model, the skydome, or both together
-   `+TargetRollXYZ`, `+CameraRollXYZ`: rotate the target or the
    camera around whichever axis (X or Z) is currently selected
-   `+MoveTowardsSelection`, `+MoveTowardsMouse`: dolly the viewport
    toward the current selection or the mouse position
-   `+PositionX`, `+PositionY`: pan the viewport
-   `+RotationX`, `+RotationZ`: rotate the viewport directly (no
    reverseTransform, unlike `+TargetRollXYZ`)

### Screenshots and recording

-   `Screenshot`, `Screenshot+Click`, `Screenshot+Drag`
-   `REC. Screenshot`, `REC. Time Graph`, `REC. Location Graph`,
    `REC. Solid Graph`, `Stop REC.`
-   `JPG 3D Graph`, `JPG 3D Full-Period`, `JPG Time Graph`,
    `JPG Location Graph`
-   `PDF Time Graph`, `PDF Location Graph`

### Weather and climate data

-   `Download Climate Typical Year`, `Download Climate Engineering`, `Download Ensemble Forecast`,
    `Download Ensemble Observation`, `Download Climate Archive`, `Download Terrain Mesh`,
    `Download Terrain Texture`
-   `Update Climate Typical Year`, `Update Climate Engineering`, `Update Ensemble Forecast`, `Update Ensemble Observation`,
    `Update Climate Archive`, `Update Station`
-   `Load Terrain Mesh`, `Load Terrain Texture`, `Load Toroposphere`
-   `Use Climate Typical Year`, `Use Climate Engineering`,
    `Use Climate Archive`, `Use Ensemble Observation`,
    `Use Ensemble Forecast`: choose which data source feeds the
    current study
-   `Advance Troposphere Time`, `Rewind Troposphere Time`: step the
    troposphere map's displayed hour forward/backward

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
-   `Toggle Impact Type`: switches between the impact-type variations
    shown on the active shading mode
-   `Next Impact Day`, `Previous Impact Day`
-   `Recalculate Solar Impact`: flags the Global/Vertex solar arrays for
    a rebuild

### Analysis graph navigation

Navigating and adjusting the analysis-chart display, rather than
triggering a computation:

-   `Next Layer`, `Previous Layer`
-   `Next Graph Index`, `Previous Graph Index`
-   `Next Plot Layout`, `Previous Plot Layout`
-   `Next Sky Scenario`, `Previous Sky Scenario`
-   `Toggle Impact Summary`
-   `Increase Vertical Scale`, `Decrease Vertical Scale`
-   `Widen Join Window`, `Narrow Join Window`
-   `Extend Date Range`, `Shrink Date Range`
-   `Toggle Raw Lines`, `Toggle Statistical Ranges`,
    `Toggle Study Normal Lines`, `Toggle Probabilities`
-   `Increase Probability Height Step`, `Decrease Probability Height Step`
-   `Increase Sum Interval`, `Decrease Sum Interval`

### Shading

-   `Shade Surface Wire`, `Shade Surface Base`, `Shade Surface White`,
    `Shade Surface Materials`
-   `Shade Global Solar`, `Shade Vertex Solar`, `Shade Vertex Solid`,
    `Shade Vertex Elevation`
-   `Shade Viewport`
-   `Shade Time +1 Hour`, `Shade Time -1 Hour`, `Shade Time +1 Day`,
    `Shade Time -1 Day`

(these are equivalent to the `SHADE.*` commands under
[Shading and rendering](#shading-and-rendering) above)

### Geometry editing

-   `Offset(above) Vertices`, `Offset(below) Vertices`,
    `Offset(expand) Vertices`, `Offset(shrink) Vertices`
-   `Insert Corner Openings`, `Insert Edge Openings`,
    `Insert Parallel Openings`, `Insert Rotated Openings`
-   `Extrude Face Edges`
-   `Weld Objects Selected Vertices`, `Weld Scene Selected Vertices`,
    `Separate Selected Vertices`
-   `Reposition Selected Vertices`, `Flatten Selected Terrain Vertices`
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

-   `SOLARCHVISION-BIM6D`, `Mojtaba Samimi`,
    `www.solarchvision.com`: open the corresponding link
