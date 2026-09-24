SOLARCHVISION-BIM is a desktop software application designed and
developed by [Mojtaba Samimi
(M.Arch)](https://www.linkedin.com/in/mojtaba-samimi-06178840) in the
[Processing](https://processing.org/) language. It is available for
`GNU/Linux`, `macOS`, and `Microsoft Windows`.

# Table of contents

-   [Copyright and license](#copyright-and-license)
-   [SOLARCHVISION method and studies](#solarchvision-method-and-studies)
-   [Recent changes](#recent-changes)
-   [Installation](#installation)
    -   [Clone using SSH](#clone-using-ssh)
    -   [Clone using HTTPS](#clone-using-https)
    -   [Requirements](#requirements)
    -   [Run using Processing IDE](#run-using-processing-ide)
    -   [Run using command line](#run-using-command-line)
    -   [Download CWEEDS files](#download-cweeds-files)
-   [Graphical User Interface](#graphical-user-interface)
    -   [Adding an object to the scene](#adding-an-object-to-the-scene)
    -   [Selecting objects](#selecting-objects)
    -   [Altering objects](#altering-objects)
    -   [Modifying objects](#modifying-objects)
    -   [Matching and aligning objects](#matching-and-aligning-objects)
    -   [Quick layout and 3D setup](#quick-layout-and-3d-setup)
    -   [Climatic studies](#climatic-studies)
    -   [Weather layers](#weather-layers)
    -   [Location menu](#location-menu)
        -   [Picking a station on the map](#picking-a-station-on-the-map)
    -   [Case bar](#case-bar)
        -   [Range Sliders](#range-sliders)
        -   [Statistical Options](#statistical-options)
    -   [User interface keyboard shortcuts](#user-interface-keyboard-shortcuts)
        -   [General](#general)
        -   [Camera and viewport control](#camera-and-viewport-control)
        -   [Selection and scene interaction](#selection-and-scene-interaction)
        -   [Time, weather, and impact visualization](#time-weather-and-impact-visualization)
        -   [Layout and graph controls](#layout-and-graph-controls)
        -   [Graph scaling and display options](#graph-scaling-and-display-options)
        -   [Graph visualization modes](#graph-visualization-modes)
    -   [Command line](#command-line)
        -   [Location](#location)
        -   [Selection and editing](#selection-and-editing)
        -   [Object creation](#object-creation)
        -   [Mesh creation](#mesh-creation)
        -   [Viewports](#viewports)
        -   [Camera control](#camera-control)
        -   [Views](#views)
        -   [Shading and rendering](#shading-and-rendering)
        -   [Additional commands](#additional-commands)
-   [SOLARCHVISION-BIM — Technical Overview](#solarchvision-bim--technical-overview)
    -   [Overview](#overview)
    -   [Major Technical Subsystems](#major-technical-subsystems)
        -   [1. 3D Modeling and Geometry Engine](#1-3d-modeling-and-geometry-engine)
        -   [2. Interactive CAD-Style Modeling](#2-interactive-cad-style-modeling)
        -   [3. Parametric and Procedural Objects](#3-parametric-and-procedural-objects)
        -   [4. 3D Rendering and Visualization](#4-3d-rendering-and-visualization)
        -   [5. Solar Position and Radiation Analysis](#5-solar-position-and-radiation-analysis)
        -   [6. Surface-Level Solar Analysis](#6-surface-level-solar-analysis)
        -   [7. Shadow and Occlusion Analysis](#7-shadow-and-occlusion-analysis)
        -   [8. Environmental Impact Fields](#8-environmental-impact-fields)
        -   [9. Wind Visualization and Analysis](#9-wind-visualization-and-analysis)
        -   [10. Weather and Climate Data Integration](#10-weather-and-climate-data-integration)
        -   [11. Ensemble and Scenario Analysis](#11-ensemble-and-scenario-analysis)
        -   [12. Statistical Study Engine](#12-statistical-study-engine)
        -   [13. Cloud and Atmospheric Scenario Analysis](#13-cloud-and-atmospheric-scenario-analysis)
        -   [14. Geographic and Earth Modeling](#14-geographic-and-earth-modeling)
        -   [15. Meteorological Station System](#15-meteorological-station-system)
        -   [16. Sun, Moon, Sky, and Atmospheric Visualization](#16-sun-moon-sky-and-atmospheric-visualization)
        -   [17. Time-Dependent Simulation](#17-time-dependent-simulation)
        -   [18. Multi-Viewport Architecture](#18-multi-viewport-architecture)
        -   [19. Command-Line and Scripting System](#19-command-line-and-scripting-system)
        -   [20. Project Persistence](#20-project-persistence)
        -   [21. Layer and Material Systems](#21-layer-and-material-systems)
        -   [22. Import and Export](#22-import-and-export)
    -   [Architecture at a Glance](#architecture-at-a-glance)
    -   [Technical Character](#technical-character)

------------------------------------------------------------------------

# Copyright and license

The code and documentation are released under the [GPL
v2](https://github.com/archmoj/solarchvision_bim/blob/master/LICENSE.md).

# SOLARCHVISION method and studies
## [TU-Berlin book: Intelligent Design using Solar-Climatic Vision (Energy and Comfort Improvement in Architecture and Urban Planning using SOLARCHVISION)](https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8)
## [Presentation at Ouranos](https://www.dropbox.com/scl/fo/5r66ns7r9j0rezprwa567/ADuKLQ_qQo98gDnlqDQMXVY?dl=0&e=2&preview=SOLARCHVISION_2015_12_09_Ouranos.pdf&rlkey=0x1wzfy5dll3bvx6j9ltw96v6)
## [BIM6D Presentation](https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtabaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1)

# Recent changes

A high-level summary of what's changed:

-   **Earth model overhaul** — The 3D Earth globe now composites
    high-resolution local world-map tiles for its surface texture, rendering
    only the area around the project's location for performance, with a
    lat/lon grid overlay and elevation-based terrain relief
-   **World and location views** — The world map view gained panning,
    additional zoom levels, and image caching for smoother transitions; the
    station and EPW file pickers were improved with multi-file support,
    scrollbars, cancel support, and clearer titles; several weather data
    sources (EPW/TMY, NAEFS and SWOB) received download upgrades.
-   **Rendering and shadows** — Added shadow casting for trees, render
    preview support, and various shading-quality and viewport-shading
    improvements.
-   **Editable spinners** — Numeric spinner controls throughout the UI can
    now be edited directly by clicking and typing, with familiar text-entry
    controls (cursor movement, selection-free editing, Escape to cancel),
    in addition to the existing drag/click adjustment.
-   **Selection overlays** — A dedicated overlay system now draws
    selection highlights (bounding boxes, edges, pivots) separately from
    the model geometry, with camera clipping and styling fixes.
-   **Performance improvements** — Wide-ranging optimizations across
    geometry and intersection algorithms, array/memory handling, shading
    calculations, and the rendering and selection pipelines.
-   **Cross-platform reliability** — Replaced a shell/7z dependency with a
    pure-Java decompression path for better cross-platform support;
    weather-data API keys are now read from a `.env` file.
-   **Project structure and internal cleanup** — Source files were
    reorganized under `app/src/solarchvision_bim`, alongside broad internal
    refactoring for maintainability.

# Installation

## Clone using SSH

``` sh
git clone git@github.com:archmoj/solarchvision_bim.git
```

or

``` sh
git clone git@github.com:archmoj/solarchvision_bim.git --depth 1
```

## Clone using HTTPS

``` sh
git clone https://github.com/archmoj/solarchvision_bim.git
```

or

``` sh
git clone https://github.com/archmoj/solarchvision_bim.git --depth 1
```

## Requirements

[Processing v4](https://processing.org/download) must be installed, as
SOLARCHVISION-BIM is a Processing sketch.

## Run using Processing IDE

The `solarchvision_bim` sketch can be opened in the Processing IDE and
executed using the Play button.

## Run using command line

To compile and run the `solarchvision_bim` sketch, adjust
`<PATH-TO-PROCESSING>` in the following command as needed.

Please note that the command must be executed from the parent directory
containing the `solarchvision_bim` folder.

``` sh
<PATH-TO-PROCESSING>/processing-java --sketch=app/src/solarchvision_bim --run
```


## Download CWEEDS files

For locations in `Canada`, there is a database called `CWEEDS`,
which includes multi-year climate data under the Engineering Climate
Datasets (https://climate.weather.gc.ca/prods_servs/engineering_e.html).

The files for the region of interest can be extracted and placed inside
the `solarchvision_bim/input/climate/CWEEDS/` folder.


# Graphical User Interface

Once loaded the UI would look like this:

<p align="center">
    <img src="https://raw.githubusercontent.com/archmoj/solarchvision_bim/refs/heads/main//doc/images/InitialView.jpg">
</p>

Please note that in above example the `Setup | 3D-model 7` option is selected. Also the rendering is set to `Shade Global Solar` option via `3D-shade` menu.

## Adding an object to the scene

You can choose a desired object such as Houses, Parametric Surfaces,
`Box`, `Cushion`, `Cylinder`, `Sphere`, `Octahedron`, `Icosahedron`,
`Pyramid`, `Hyper`, `Plane`, `Polygon`, `Extrude`, `Surface`, `Polyline`,
`Point`, `1D-Tree`, `2D-Tree`, `Person`, and `Camera` from the
`3D-create` menu.

After selecting the desired object, you can use either right-click or
left-click on a surface in the 3D viewport to add it to the scene:

-   **Right-click** adds the object to the land surface.
-   **Left-click** adds the object to the surface of existing 3D models.

The default parameters used for creating new objects can be found under
`Geometries & Space` → `Create`.

Alternatively, you can use the command line to generate new objects. For
example, the following command adds a section with width and height of
100 units at a distance of 0.1 units above the origin:

    section u=100 v=100 z=0.1

See the Command line section for more information.

------------------------------------------------------------------------

## Selecting objects

You can use the `3D-select` menu to select objects of different types,
including `Land`, `1D`, `2D`, `Group`, `Face`, `Vertex`, `Soft`,
`Solid`, `Section`, `Camera`, and `Polyline`.

You can also use the following selection methods:

-   `Pick` and `Window` selection modes to select or deselect objects
-   Add objects to or remove objects from the current selection
-   `Select all` and `Deselect all` options

It is also possible to convert one selection type to another. For
example:

-   `Groups >> Faces` selects all faces belonging to the selected
    group(s)
-   `Faces >> Groups` selects all groups associated with the selected
    face(s)

------------------------------------------------------------------------

## Altering objects

You can use the `3D-alter` menu to modify properties of existing
objects.

After selecting a modification option, use the mouse wheel to adjust the
object properties interactively.

------------------------------------------------------------------------

## Modifying objects

The `3D-modify` menu provides several modifiers for editing 3D surfaces.

For example, the `Insert Corner Openings` modifier inserts an opening
base parallel to the edges of the selected surface(s).

------------------------------------------------------------------------

## Matching and aligning objects

You can match and align objects using the `3D-match` menu.

------------------------------------------------------------------------

## Quick layout and 3D setup

The `Setup` menu provides quick access to predefined:

-   Time viewport `layouts`
-   3D viewport `models`

You can enlarge the time viewport to expand and view complete layout
graphs.

------------------------------------------------------------------------

## Climatic studies

General studies such as:

-   `Wind pattern (active)`
-   `Wind pattern (passive)`
-   `Orientation potential (active)`
-   `Orientation potential (passive)`
-   `Hourly sun position (active)`
-   `Hourly sun position (passive)`
-   `Annual cycle sun path (active)`
-   `Annual cycle sun path (passive)`

can be accessed from the `Analysis` menu. These studies are displayed in
the time viewport.

For studies related to the 3D model, such as:

-   `Urban solar potential (active)`
-   `Urban solar potential (passive)`

you must pre-bake the selected `Section` or `Camera` using:

-   `PreBake Viewport`, or
-   `Pre-bake Selected Sections`

before running the analysis.

------------------------------------------------------------------------

## Weather layers

Two types of weather layers are defined:

1.  **General layers**
    -   Available directly from weather data files
    -   Missing values may be filled using post-processing techniques
2.  **Developed layers**
    -   Not available in the original weather files
    -   Generated through software post-processing

------------------------------------------------------------------------

## Location menu

You can use the `Location` menu to select a project location and
download or load weather and geographic data.

By default, the software uses EPW/TMY (Typical Meteorological Year)
data.

Additional supported datasets include:

-   Climate files containing multiple years of data (e.g., CWEEDS)
-   Ensemble forecast datasets (e.g., NAEFS) for visualization and
    simulation
-   Observation datasets (e.g., SWOB records)

Additional features include:

-   `Land Mesh` and `Land Texture` require an API key
-   `Troposphere` allows loading WMS forecast data to visualize hourly
    cloud formations using datasets such as HRDPS (High Resolution Deterministic Prediction System) or
    GDPS (Global Deterministic Prediction System)

### Picking a station on the map

Clicking inside the world viewport assigns the nearest station of the
*currently active* dataset (`TMYEPW`, `CWEEDS`, `CLMREC`, `NAEFS`, or
`SWOB`) to the project.

Left-clicking also zooms the world viewport in to the most detailed
level, to confirm exactly where the click landed. Right-click picks a
station the same way but keeps the current zoom level, which is handy
for comparing several rough locations across a wider area without the
view zooming in on every click.

If one or more stations of that dataset fall
within its own search radius of the click, a scrollable picker list
appears instead of guessing automatically:


| Dataset  | Search radius |
|----------|----------------|
| `TMYEPW` | 10 km          |
| `CLMREC` | 25 km          |
| `CWEEDS` | 50 km          |
| `NAEFS`  | 50 km          |
| `SWOB`   | 25 km          |

While the picker is showing:

-   Click a row to select that station.
-   Click anywhere else in the world viewport, or press `ESC`, to
    cancel without changing the current selection.
-   If the list is longer than fits on screen, scroll it with the
    mouse wheel, drag the scrollbar thumb, or click the scrollbar
    track to page up/down.

------------------------------------------------------------------------

## Case bar

The **Case Bar** is located above the Command Bar. It consists of three range sliders on the left and nine statistical options on the right.

### Range Sliders

The range sliders allow users to select the desired:
- `Hours`
- `Days`
- Forecast `Scenarios` (or `Years` when using long-term input data)

To define a range:
- Use **left-click** to set the start of the range.
- Use **right-click** to set the end of the range.

### Statistical Options

The statistical options determine which scenario close to the selected data aggregation is used to run simulations in the viewports. Available options include:

- `Minimum`
- `Average`
- `Maximum`
- `25th Percentile`
- `50th Percentile (Median)`
- `75th Percentile`
- `Middle`
- `Mid-High`
- `Mid-Low`

The first six options compute standard statistical measures based on the selected data range.

The `Middle`, `Mid-High`, and `Mid-Low` options are built-in methods that apply weighted selection criteria to sorted data records.


## User interface keyboard shortcuts

When the command bar is disabled (default mode), you can use keyboard shortcuts to perform various tasks.

### General
-   `TAB`: Enable or disable the command bar
-   `Shift+TAB`: Switch between active and passive impact views inside the 3D viewport

------------------------------------------------------------------------

### Camera and viewport control
-   `` ` `` and `~`: Cycle backward/forward through the world
    viewport's zoom levels
-   `+` and `-`: Zoom in and out in the 3D viewport
-   `Ctrl+,` and `Ctrl+.`: Move the camera closer and farther to the selection
-   `,` and `.`: Move the camera closer and farther
-   `2` and `8`: Rotate the camera up and down
-   `4` and `6`: Rotate the camera left and right
-   `1` and `3`: Move the camera left and right
-   `7` and `9`: Move the camera up and down
-   `5`: Rotate the camera to look at the current selection (or the origin if nothing is selected)
-   `0`: Move the camera closer
-   `/` and `*`: Move the camera toward and away from the selection
-   `UP`, `DOWN`, `LEFT` and `RIGHT`: Rotate the camera around the selection

------------------------------------------------------------------------

### Selection and scene interaction
-   `DELETE`: Delete selected item(s)
-   `Shift+UP`, `Shift+DOWN`: Move/rotate/scale (or change properties of) the selection
-   `c` and `C`: Switch the viewport to available cameras in the scene
-   `ENTER`: Rebuild global & vertex solar energy/impact data
-   `SPACE`: Move time forward & shade viewport
-   `BACKSPACE`: Move time backward & shade viewport

------------------------------------------------------------------------

### Time, weather, and impact visualization
-   `d` and `D`: Change the impact display day in the 3D viewport
-   `t` and `T`: Change the forecast hour used to display the troposphere

------------------------------------------------------------------------

### Layout and graph controls
The shortcuts in this section, as well as in "Graph scaling and display options" and "Graph visualization modes" below, act on the time viewport.

-   `Ctrl+UP` and `Ctrl+DOWN`: Change the current weather layer displayed in the hourly graph
-   `Ctrl+LEFT` and `Ctrl+RIGHT`: Change the current impact layer displayed in the daily graph
-   `Ctrl+PAGE_UP` and `Ctrl+PAGE_DOWN`: Switch between the numbered diagram `Layout`s available from the `Setup` menu (enlarge the time viewport, i.e. the `graph` View Layout, to view the full layout)
-   `Ctrl+;`: Show or hide the impact summary

------------------------------------------------------------------------

### Graph scaling and display options
-   `Ctrl+'` and `Ctrl+"`: Adjust the vertical scale factor of the hourly time graph
-   `<` and `>`: Increase or decrease the number of joined days (30 days by default for monthly graphs)
-   `(` and `)`: Increase or decrease the number of displayed days
-   `[` and `]`: Increase or decrease the horizontal interval used for the probabilities graph
-   `{` and `}`: Increase or decrease the vertical interval used for the probabilities graph

------------------------------------------------------------------------

### Graph visualization modes
-   `s` and `S`: Change the sky scenario ("All data", "Sunny", "Partly Cloudy", or "Cloudy")
-   `v` and `V`: Show or hide raw values on the hourly time graph
-   `b` and `B`: Show or hide probabilities on the hourly time graph
-   `n` and `N`: Show or hide statistics on the hourly time graph
-   `m` and `M`: Show or hide sorted values on the hourly time graph



## Command line

Use `TAB` to enable or disable the command line, or click inside/outside
the command line area (the dark region at the bottom).

Below is a list of available commands. Both lowercase and uppercase
variants are accepted.

------------------------------------------------------------------------

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
-   `RUN.SCRIPT`: Executes a `.txt` script file containing multiple SOLARCHVISION
    commands
-   `REC.PNG`: Records the frame (screenshot) in `.png` format
-   `REC.JPG`: Records the frame (screenshot) in `.jpg` format
-   `REC.TIF`: Records the frame (screenshot) in `.tif` format
-   `REC.BMP`: Records the frame (screenshot) in `.bmp` format
-   `QUIT` or `EXIT`: Exits the software

------------------------------------------------------------------------

### Location

-   `SETLONLAT`: Sets the longitude and latitude of the location

```
SetLonLat ? ?
```

-   `SETLON`: Sets the longitude of the location

```
SetLon ?
```

-   `SETLAT`: Sets the latitude of the location

```
SetLat ?
```

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

-   `ROTATE`, `ROTATEX`, `ROTATEY`, `ROTATEZ`: Rotates the selection

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

------------------------------------------------------------------------

### Camera control

Includes commands such as:

-   `PAN`, `PANX`, `PANY`
-   `LOOKORG`, `LOOKDIR`, `LOOKSEL`
-   `TRUCKX`, `TRUCKY`, `TRUCKZ`
-   `ORBIT`, `ORBITZ`, `ORBITXY`
-   `CAMERAROLL`, `CAMERAROLLZ`, `CAMERAROLLXY`
-   `TARGETROLL`, `TARGETROLLZ`, `TARGETROLLXY`
-   `DISTC`, `DISTZ`, `DISTXY`, `DISTP`
-   `ZOOM`, `NORMALZOOM`
-   `PERSPECTIVE`, `ORTHOGRAPHIC`

------------------------------------------------------------------------

### Views

-   `TOP`, `FRONT`, `LEFT`, `RIGHT`, `BACK`, `BOTTOM`
-   `S.W.`, `S.E.`, `N.E.`, `N.W.`

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
-   `PREBAKE.VIEWPORT`: Pre-bakes the viewport

### Additional commands
-   `1d-tree`,
-   `2d-tree`,
-   `3d-model 1`,
-   `3d-model 10`,
-   `3d-model 11`,
-   `3d-model 2`,
-   `3d-model 3`,
-   `3d-model 4`,
-   `3d-model 5`,
-   `3d-model 6`,
-   `3d-model 7`,
-   `3d-model 8`,
-   `3d-model 9`,
-   `3dmodelsize`,
-   `active shade`,
-   `add 1d-trees on land`,
-   `add 2d-trees on land`,
-   `add people on land`,
-   `allmodelsize`,
-   `annual cycle sun path (active)`,
-   `annual cycle sun path (passive)`,
-   `assign branchratio`,
-   `assign branchtilt`,
-   `assign branchtwist`,
-   `assign degreemax`,
-   `assign layer`,
-   `assign leafsize`,
-   `assign model1dsprops`,
-   `assign pivot`,
-   `assign seed/material`,
-   `assign tessellation`,
-   `assign treebase`,
-   `assign trunksize`,
-   `assign visibility`,
-   `assign weight`,
-   `attach to last group`,
-   `auto-normal selected faces`,
-   `back`,
-   `begin new group at origin`,
-   `begin new group at pivot`,
-   `bottom`,
-   `box`,
-   `camera`,
-   `camera >> viewport`,
-   `camera view`,
-   `cameradistance`,
-   `cameraroll`,
-   `camerarollxy`,
-   `camerarollz`,
-   `change branchratio`,
-   `change branchtilt`,
-   `change branchtwist`,
-   `change degreemax`,
-   `change layer`,
-   `change leafsize`,
-   `change seed/material`,
-   `change tessellation`,
-   `change treebase`,
-   `change trunksize`,
-   `change visibility`,
-   `change weight`,
-   `clone selection (identical)`,
-   `clone selection (variation)`,
-   `cushion`,
-   `cylinder`,
-   `delete all`,
-   `delete all cameras`,
-   `delete all faces`,
-   `delete all groups`,
-   `delete all model1ds`,
-   `delete all model2ds`,
-   `delete all polylines`,
-   `delete all sections`,
-   `delete all solids`,
-   `delete scene empty groups`,
-   `delete scene isolated vertices`,
-   `delete selection`,
-   `delete selection isolated vertices`,
-   `deselect all`,
-   `designed & developed by`,
-   `dettach from groups selection`,
-   `display all viewports`,
-   `distmousexy`,
-   `distz`,
-   `download clmrec`,
-   `download land mesh`,
-   `download land texture`,
-   `download naefs`,
-   `download swob`,
-   `download tmyepw`,
-   `drop on landsurface`,
-   `drop on modelsurface (down)`,
-   `drop on modelsurface (up)`,
-   `enlarge 3d viewport`,
-   `enlarge map viewport`,
-   `enlarge time viewport`,
-   `export 3d-model > html`,
-   `export 3d-model > obj`,
-   `export 3d-model > obj (date-series)`,
-   `export 3d-model > obj (time-series)`,
-   `export 3d-model > rad`,
-   `export 3d-model > scr`,
-   `extrude`,
-   `extrude face edges`,
-   `faces >> groups`,
-   `faces >> vertices`,
-   `fetch`,
-   `flatten selected landpoints`,
-   `flip normal`,
-   `force triangulate selected faces`,
-   `front`,
-   `get dx`,
-   `get dxy`,
-   `get dxyz`,
-   `get dy`,
-   `get dz`,
-   `get firstvertex`,
-   `group selection`,
-   `groups >> faces`,
-   `groups >> model1ds`,
-   `groups >> model2ds`,
-   `groups >> polylines`,
-   `groups >> solids`,
-   `groups >> vertices`,
-   `hide all faces`,
-   `hide cameras`,
-   `hide clmrec nearest`,
-   `hide clmrec stations`,
-   `hide cweeds nearest`,
-   `hide cweeds stations`,
-   `hide earth surface`,
-   `hide edges`,
-   `hide faces`,
-   `hide land depth`,
-   `hide land mesh`,
-   `hide land points`,
-   `hide land texture`,
-   `hide leaves`,
-   `hide model1ds`,
-   `hide model2ds`,
-   `hide moon surface`,
-   `hide naefs nearest`,
-   `hide naefs stations`,
-   `hide normals`,
-   `hide polylines`,
-   `hide sections`,
-   `hide selected 1d edges`,
-   `hide selected 2d edges`,
-   `hide selected cameras`,
-   `hide selected faces`,
-   `hide selected faces vertex count`,
-   `hide selected group box`,
-   `hide selected group edges`,
-   `hide selected group pivot`,
-   `hide selected landpoints`,
-   `hide selected polylines`,
-   `hide selected polylines vertex count`,
-   `hide selected ref pivot`,
-   `hide selected sections`,
-   `hide selected solids`,
-   `hide selected vertices`,
-   `hide sky`,
-   `hide solar section`,
-   `hide solid section`,
-   `hide solids`,
-   `hide sun grid`,
-   `hide sun path`,
-   `hide sun pattern`,
-   `hide sun surface`,
-   `hide swob nearest`,
-   `hide swob stations`,
-   `hide tmyepw nearest`,
-   `hide tmyepw stations`,
-   `hide troposphere`,
-   `hide vertices`,
-   `hide wind flow`,
-   `hold`,
-   `hourly sun position (active)`,
-   `hourly sun position (passive)`,
-   `house1`,
-   `house2`,
-   `house3`,
-   `hyper`,
-   `icosahedron`,
-   `import 3d-model...`,
-   `import command file...`,
-   `insert corner opennings`,
-   `insert edge opennings`,
-   `insert parallel opennings`,
-   `insert rotated opennings`,
-   `invert selection`,
-   `isolate selection`,
-   `jpg 3d full-period`,
-   `jpg 3d graph`,
-   `jpg location graph`,
-   `jpg time graph`,
-   `landgap >> group`,
-   `landmesh >> group`,
-   `landorbit`,
-   `layout -1`,
-   `layout -2`,
-   `layout 0`,
-   `layout 1`,
-   `layout 2`,
-   `layout 3`,
-   `layout 4`,
-   `layout 5`,
-   `layout 6`,
-   `layout 7`,
-   `layout 8`,
-   `left`,
-   `load land mesh`,
-   `load land texture`,
-   `load toroposphere`,
-   `look at direction`,
-   `look at origin`,
-   `look at selection`,
-   `model1ds >> groups`,
-   `model1dsprops`,
-   `model2ds >> groups`,
-   `mojtaba samimi`,
-   `move`,
-   `movex`,
-   `movey`,
-   `movez`,
-   `n.e.`,
-   `n.w.`,
-   `new`,
-   `octahedron`,
-   `offset(above) vertices`,
-   `offset(below) vertices`,
-   `offset(expand) vertices`,
-   `offset(shrink) vertices`,
-   `open...`,
-   `optimize faces`,
-   `orbit`,
-   `orbitxy`,
-   `orbitz`,
-   `orientation potential (active)`,
-   `orientation potential (passive)`,
-   `orthographic`,
-   `pan`,
-   `panx`,
-   `pany`,
-   `parametric 1`,
-   `parametric 2`,
-   `parametric 3`,
-   `parametric 4`,
-   `parametric 5`,
-   `parametric 6`,
-   `passive shade`,
-   `pdf location graph`,
-   `pdf time graph`,
-   `person`,
-   `perspective`,
-   `pick branchratio`,
-   `pick branchtilt`,
-   `pick branchtwist`,
-   `pick degreemax`,
-   `pick layer`,
-   `pick leafsize`,
-   `pick model1dsprops`,
-   `pick pivot`,
-   `pick seed/material`,
-   `pick select`,
-   `pick select+`,
-   `pick select-`,
-   `pick tessellation`,
-   `pick treebase`,
-   `pick trunksize`,
-   `pick visibility`,
-   `pick weight`,
-   `pivot`,
-   `pivotx:center`,
-   `pivotx:maximum`,
-   `pivotx:minimum`,
-   `pivoty:center`,
-   `pivoty:maximum`,
-   `pivoty:minimum`,
-   `pivotz:center`,
-   `pivotz:maximum`,
-   `pivotz:minimum`,
-   `plane`,
-   `point`,
-   `polygon`,
-   `polyline`,
-   `polylines >> groups`,
-   `polylines >> vertices`,
-   `power`,
-   `powerx`,
-   `powery`,
-   `powerz`,
-   `prebake selected sections`,
-   `prebake viewport`,
-   `process active impact`,
-   `process passive impact`,
-   `process solid impact`,
-   `pyramid`,
-   `quit`,
-   `rec. location graph`,
-   `rec. screenshot`,
-   `rec. solid graph`,
-   `rec. time graph`,
-   `reposition selected vertices`,
-   `reset saved referencebox`,
-   `reverse visibility of all faces`,
-   `right`,
-   `rotate`,
-   `rotatex`,
-   `rotatey`,
-   `rotatez`,
-   `run wind 3d-model`,
-   `s.e.`,
-   `s.w.`,
-   `save`,
-   `save as...`,
-   `save current referencebox`,
-   `scale`,
-   `scalex`,
-   `scaley`,
-   `scalez`,
-   `screenshot`,
-   `screenshot+click`,
-   `screenshot+drag`,
-   `section`,
-   `select all`,
-   `select all cameras`,
-   `select all faces`,
-   `select all groups`,
-   `select all model1ds`,
-   `select all model2ds`,
-   `select all polylines`,
-   `select all sections`,
-   `select all solids`,
-   `select all verices`,
-   `select camera`,
-   `select face`,
-   `select group`,
-   `select landpoint`,
-   `select model1ds`,
-   `select model2ds`,
-   `select near selected vertices`,
-   `select polyline`,
-   `select scene isolated vertices`,
-   `select section`,
-   `select solid`,
-   `select vertex`,
-   `separate selected vertices`,
-   `set-in normal`,
-   `set-out normal`,
-   `shade global solar`,
-   `shade surface base`,
-   `shade surface materials`,
-   `shade surface white`,
-   `shade surface wire`,
-   `shade vertex elevation`,
-   `shade vertex solar`,
-   `shade vertex solid`,
-   `shade viewport`,
-   `show cameras`,
-   `show clmrec nearest`,
-   `show clmrec stations`,
-   `show cweeds nearest`,
-   `show cweeds stations`,
-   `show earth surface`,
-   `show edges`,
-   `show faces`,
-   `show land depth`,
-   `show land mesh`,
-   `show land points`,
-   `show land texture`,
-   `show leaves`,
-   `show model1ds`,
-   `show model2ds`,
-   `show moon surface`,
-   `show naefs nearest`,
-   `show naefs stations`,
-   `show normals`,
-   `show polylines`,
-   `show sections`,
-   `show selected 1d edges`,
-   `show selected 2d edges`,
-   `show selected cameras`,
-   `show selected faces`,
-   `show selected faces vertex count`,
-   `show selected group box`,
-   `show selected group edges`,
-   `show selected group pivot`,
-   `show selected landpoints`,
-   `show selected polylines`,
-   `show selected polylines vertex count`,
-   `show selected ref pivot`,
-   `show selected sections`,
-   `show selected solids`,
-   `show selected vertices`,
-   `show sky`,
-   `show solar section`,
-   `show solid section`,
-   `show solids`,
-   `show sun grid`,
-   `show sun path`,
-   `show sun pattern`,
-   `show sun surface`,
-   `show swob nearest`,
-   `show swob stations`,
-   `show tmyepw nearest`,
-   `show tmyepw stations`,
-   `show troposphere`,
-   `show vertices`,
-   `show wind flow`,
-   `show/hide cameras`,
-   `show/hide clmrec nearest`,
-   `show/hide clmrec stations`,
-   `show/hide cweeds nearest`,
-   `show/hide cweeds stations`,
-   `show/hide earth surface`,
-   `show/hide edges`,
-   `show/hide faces`,
-   `show/hide land depth`,
-   `show/hide land mesh`,
-   `show/hide land points`,
-   `show/hide land texture`,
-   `show/hide leaves`,
-   `show/hide model1ds`,
-   `show/hide model2ds`,
-   `show/hide moon surface`,
-   `show/hide naefs nearest`,
-   `show/hide naefs stations`,
-   `show/hide normals`,
-   `show/hide polylines`,
-   `show/hide sections`,
-   `show/hide selected 1d edges`,
-   `show/hide selected 2d edges`,
-   `show/hide selected cameras`,
-   `show/hide selected faces`,
-   `show/hide selected faces vertex count`,
-   `show/hide selected group box`,
-   `show/hide selected group edges`,
-   `show/hide selected group pivot`,
-   `show/hide selected landpoints`,
-   `show/hide selected polylines`,
-   `show/hide selected polylines vertex count`,
-   `show/hide selected ref pivot`,
-   `show/hide selected sections`,
-   `show/hide selected solids`,
-   `show/hide selected vertices`,
-   `show/hide sky`,
-   `show/hide solar section`,
-   `show/hide solid section`,
-   `show/hide solids`,
-   `show/hide sun grid`,
-   `show/hide sun path`,
-   `show/hide sun pattern`,
-   `show/hide sun surface`,
-   `show/hide swob nearest`,
-   `show/hide swob stations`,
-   `show/hide tmyepw nearest`,
-   `show/hide tmyepw stations`,
-   `show/hide troposphere`,
-   `show/hide vertices`,
-   `show/hide wind flow`,
-   `skydomesize`,
-   `soft selection`,
-   `solarchvision-bim6d`,
-   `solid`,
-   `solids >> groups`,
-   `sphere`,
-   `stop rec.`,
-   `surface`,
-   `targetroll`,
-   `targetrollxy`,
-   `targetrollz`,
-   `tessellate rectangular`,
-   `tessellate rows & columns`,
-   `tessellate triangular`,
-   `top`,
-   `truckx`,
-   `trucky`,
-   `truckz`,
-   `ungroup selection`,
-   `unhide all faces`,
-   `unhide selected faces`,
-   `update clmrec`,
-   `update cweeds`,
-   `update naefs`,
-   `update station`,
-   `update swob`,
-   `update tmyepw`,
-   `urban solar potential (active)`,
-   `urban solar potential (passive)`,
-   `use long-term (clmrec)`,
-   `use long-term (cweeds)`,
-   `use origin referencebox`,
-   `use real-time observed (swob)`,
-   `use selection referencebox`,
-   `use typical year (tmy)`,
-   `use weather forecast (naefs)`,
-   `vertices >> faces`,
-   `vertices >> groups`,
-   `vertices >> polylines`,
-   `viewport >> camera`,
-   `weld objects selected vertices`,
-   `weld scene selected vertices`,
-   `wind pattern (active)`,
-   `wind pattern (passive)`,
-   `window select`,
-   `window select+`,
-   `window select-`,
-   `www.solarchvision.com`,
-   `zoom`,
-   `zoom as default`

command                                       field                                         caption
----------------------------------------------------------------------------------------------------------------------------------
3_d_create_branch_ratio                       User3D.create_Model1D_BranchRatio             3D-create.BranchRatio
3_d_create_branch_tilt                        User3D.create_Model1D_BranchTilt              3D-create.BranchTilt
3_d_create_branch_twist                       User3D.create_Model1D_BranchTwist             3D-create.BranchTwist
3_d_create_closed                             User3D.default_Closed                         3D-create.Closed
3_d_create_cylinder_degree                    User3D.create_CylinderDegree                  3D-create.CylinderDegree
3_d_create_degree_max                         User3D.create_Model1D_DegreeMax               3D-create.DegreeMax
3_d_create_display_tessellation               allFaces.displayTessellation                  3D-create.displayTessellation
3_d_create_height_rand_negative               User3D.create_Height                          3D-create.Height (rand negative)
3_d_create_layer                              User3D.default_Layer                          3D-create.Layer
3_d_create_leaf_size                          User3D.create_Model1D_LeafSize                3D-create.LeafSize
3_d_create_length_rand_negative               User3D.create_Length                          3D-create.Length (rand negative)
3_d_create_material                           User3D.default_Material                       3D-create.Material
3_d_create_orientation                        User3D.create_Orientation                     3D-create.Orientation
3_d_create_parametric_type                    User3D.create_Parametric_Type                 3D-create.Parametric_Type
3_d_create_person_type                        User3D.create_Person_Type                     3D-create.Person_Type
3_d_create_plant_type                         User3D.create_Plant_Type                      3D-create.Plant_Type
3_d_create_poly_degree                        User3D.create_PolyDegree                      3D-create.PolyDegree
3_d_create_pow_all                            User3D.create_powAll                          3D-create.powAll
3_d_create_pow_x                              User3D.create_powX                            3D-create.powX
3_d_create_pow_y                              User3D.create_powY                            3D-create.powY
3_d_create_pow_z                              User3D.create_powZ                            3D-create.powZ
3_d_create_seed                               User3D.create_Model1D_Seed                    3D-create.Seed
3_d_create_snap                               User3D.create_Snap                            3D-create.Snap
3_d_create_sphere_degree                      User3D.create_SphereDegree                    3D-create.SphereDegree
3_d_create_tessellation                       User3D.default_Tessellation                   3D-create.Tessellation
3_d_create_tree_base                          User3D.create_Model1D_TreeBase                3D-create.TreeBase
3_d_create_trunk_size                         User3D.create_Model1D_TrunkSize               3D-create.TrunkSize
3_d_create_type                               User3D.create_Model1D_Type                    3D-create.Type
3_d_create_visibility                         User3D.default_Visibility                     3D-create.Visibility
3_d_create_volume                             User3D.create_Volume                          3D-create.Volume
3_d_create_weight                             User3D.default_Weight                         3D-create.Weight
3_d_create_width_rand_negative                User3D.create_Width                           3D-create.Width (rand negative)
3_d_export_back_sides                         User3D.export_BackSides                       3D-export.BackSides
3_d_export_flip_zyaxis                        User3D.export_FlipZYaxis                      3D-export.FlipZYaxis
3_d_export_material_library                   User3D.export_MaterialLibrary                 3D-export.MaterialLibrary
3_d_export_palette_resolution                 User3D.export_PaletteResolution               3D-export.PaletteResolution
3_d_export_poly_to_poly                       User3D.export_PolyToPoly                      3D-export.PolyToPoly
3_d_export_precision_vertex                   User3D.export_PrecisionVertex                 3D-export.PrecisionVertex
3_d_export_precision_vtexture                 User3D.export_PrecisionVtexture               3D-export.PrecisionVtexture
3_d_export_scale                              User3D.export_Scale                           3D-export.Scale
3_d_modify_offset_amount                      User3D.modify_OffsetAmount                    3D-modify.OffsetAmount
3_d_modify_openning_area                      User3D.modify_OpenningArea                    3D-modify.OpenningArea
3_d_modify_openning_depth                     User3D.modify_OpenningDepth                   3D-modify.OpenningDepth
3_d_modify_openning_deviation                 User3D.modify_OpenningDeviation               3D-modify.OpenningDeviation
3_d_modify_tessellate_columns                 User3D.modify_TessellateColumns               3D-modify.TessellateColumns
3_d_modify_tessellate_rows                    User3D.modify_TessellateRows                  3D-modify.TessellateRows
3_d_modify_weld_treshold                      User3D.modify_WeldTreshold                    3D-modify.WeldTreshold
3_d_select_align_x                            Select3D.alignX                               3D-select.alignX
3_d_select_align_y                            Select3D.alignY                               3D-select.alignY
3_d_select_align_z                            Select3D.alignZ                               3D-select.alignZ
3_d_select_camera_display_edges               Select3D.Camera_displayEdges                  3D-select.Camera_displayEdges
3_d_select_display_reference_pivot            Select3D.displayReferencePivot                3D-select.displayReferencePivot
3_d_select_face_display_edges                 Select3D.Face_displayEdges                    3D-select.Face_displayEdges
3_d_select_face_display_vertex_count          Select3D.Face_displayVertexCount              3D-select.Face_displayVertexCount
3_d_select_group_display_box                  Select3D.Group_displayBox                     3D-select.Group_displayBox
3_d_select_group_display_edges                Select3D.Group_displayEdges                   3D-select.Group_displayEdges
3_d_select_group_display_pivot                Select3D.Group_displayPivot                   3D-select.Group_displayPivot
3_d_select_land_point_display_points          Select3D.LandPoint_displayPoints              3D-select.LandPoint_displayPoints
3_d_select_model1_d_display_edges             Select3D.Model1D_displayEdges                 3D-select.Model1D_displayEdges
3_d_select_model2_d_display_edges             Select3D.Model2D_displayEdges                 3D-select.Model2D_displayEdges
3_d_select_polyline_display_vertex_count      Select3D.Polyline_displayVertexCount          3D-select.Polyline_displayVertexCount
3_d_select_polyline_display_vertices          Select3D.Polyline_displayVertices             3D-select.Polyline_displayVertices
3_d_select_pos_value                          Select3D.posValue                             3D-select.posValue
3_d_select_pos_vector                         Select3D.posVector                            3D-select.posVector
3_d_select_rot_value                          Select3D.rotValue                             3D-select.rotValue
3_d_select_rot_vector                         Select3D.rotVector                            3D-select.rotVector
3_d_select_scale_value                        Select3D.scaleValue                           3D-select.scaleValue
3_d_select_scale_vector                       Select3D.scaleVector                          3D-select.scaleVector
3_d_select_section_display_edges              Select3D.Section_displayEdges                 3D-select.Section_displayEdges
3_d_select_soft_power                         Select3D.softPower                            3D-select.softPower
3_d_select_soft_radius                        Select3D.softRadius                           3D-select.softRadius
3_d_select_solid_display_edges                Select3D.Solid_displayEdges                   3D-select.Solid_displayEdges
3_d_select_vertex_display_vertices            Select3D.Vertex_displayVertices               3D-select.Vertex_displayVertices
add_to_last_group                             addToLastGroup                                addToLastGroup
camera_clip_far                               WIN3D.CAM_clipFar                             Camera_clipFar
camera_clip_near                              WIN3D.CAM_clipNear                            Camera_clipNear
cameras_display_all                           allCameras.displayAll                         cameras.displayAll
climate_based_solar_forecast                  CLIMATIC_SolarForecast                        Climate-based solar forecast
climate_based_temperature_forecast            CLIMATIC_WeatherForecast                      Climate-based temperature forecast
create3_d_display_edges                       allFaces.displayEdges                         Create3D.displayEdges
create3_d_display_normals                     allFaces.displayNormals                       Create3D.displayNormals
create3_d_display_vertices                    allPoints.displayAll                          Create3D.displayVertices
current_camera                                WIN3D.currentCamera                           currentCamera
day_step                                      STUDY.perDays                                 Day step
days_past_march_equinox                       TIME.date                                     Days past March equinox
develop_day_hour                              Develop_DayHour                               Develop_DayHour
develop_option                                Develop_Option                                Develop_Option
diagram_setup                                 STUDY.plotSetup                               Diagram setup
display_all_clmrec                            WORLD.displayAll_CLMREC                       displayAll_CLMREC
display_all_cweeds                            WORLD.displayAll_CWEEDS                       displayAll_CWEEDS
display_all_naefs                             WORLD.displayAll_NAEFS                        displayAll_NAEFS
display_all_swob                              WORLD.displayAll_SWOB                         displayAll_SWOB
display_all_tmyepw                            WORLD.displayAll_TMYEPW                       displayAll_TMYEPW
display_near_clmrec                           WORLD.displayNear_CLMREC                      displayNear_CLMREC
display_near_cweeds                           WORLD.displayNear_CWEEDS                      displayNear_CWEEDS
display_near_naefs                            WORLD.displayNear_NAEFS                       displayNear_NAEFS
display_near_swob                             WORLD.displayNear_SWOB                        displayNear_SWOB
display_near_tmyepw                           WORLD.displayNear_TMYEPW                      displayNear_TMYEPW
draw_data                                     STUDY.displayRaws                             Draw data
draw_probabilities                            STUDY.displayProbs                            Draw probabilities
draw_sorted                                   STUDY.displaySorted                           Draw sorted
draw_statistics                               STUDY.displayNormals                          Draw statistics
earth3_d_display_surface                      Earth3D.displaySurface                        Earth3D.displaySurface
earth3_d_display_texture                      Earth3D.displayTexture                        Earth3D.displayTexture
earth3_d_level_of_detail                      Earth3D.levelOfDetail                         Earth3D.levelOfDetail
end_hour                                      STUDY.i_End                                   End hour
end_member                                    SampleMember_End                              End member
end_station                                   SampleStation_End                             End station
end_year                                      SampleYear_End                                End year
export_ascii_data                             STUDY.export_info_node                        Export ASCII data
export_ascii_probabilities                    STUDY.export_info_prob                        Export ASCII probabilities
export_ascii_statistics                       STUDY.export_info_norm                        Export ASCII statistics
faces_active_palette_clr                      allFaces.ACTIVE_palette_CLR                   faces.ACTIVE_palette_CLR
faces_active_palette_dir                      allFaces.ACTIVE_palette_DIR                   faces.ACTIVE_palette_DIR
faces_active_palette_mlt                      allFaces.ACTIVE_palette_MLT                   faces.ACTIVE_palette_MLT
faces_display_all                             allFaces.displayAll                           faces.displayAll
faces_passive_palette_clr                     allFaces.PASSIVE_palette_CLR                  faces.PASSIVE_palette_CLR
faces_passive_palette_dir                     allFaces.PASSIVE_palette_DIR                  faces.PASSIVE_palette_DIR
faces_passive_palette_mlt                     allFaces.PASSIVE_palette_MLT                  faces.PASSIVE_palette_MLT
forecast_obs_max_days                         ENSEMBLE_OBSERVED_maxDays                     Forecast/Obs_maxDays
hourly_daily_filter                           STUDY.filter                                  Hourly/daily filter
impact_min_50_max                             STUDY.ImpactLayer                             Impact Min/50%/Max
impact_source                                 CurrentDataSource                             Impact Source
impacts_display_day                           IMPACTS_displayDay                            IMPACTS_displayDay
inclination_angle                             Develop_AngleInclination                      Inclination angle
interpolation_weight                          Interpolation_Weight                          Interpolation_Weight
join_days                                     STUDY.joinDays                                Join days
land3_d_display_depth                         Land3D.displayDepth                           Land3D.displayDepth
land3_d_display_points                        Land3D.displayPoints                          Land3D.displayPoints
land3_d_display_surface                       Land3D.displaySurface                         Land3D.displaySurface
land3_d_display_texture                       Land3D.displayTexture                         Land3D.displayTexture
land3_d_load_mesh                             Land3D.loadMesh                               Land3D.loadMesh
land3_d_load_textures                         Land3D.loadTextures                           Land3D.loadTextures
land3_d_palette_clr                           Land3D.palette_CLR                            Land3D.palette_CLR
land3_d_palette_dir                           Land3D.palette_DIR                            Land3D.palette_DIR
land3_d_palette_mlt                           Land3D.palette_MLT                            Land3D.palette_MLT
land3_d_skip_end                              Land3D.skipEnd                                Land3D.skipEnd
land3_d_skip_start                            Land3D.skipStart                              Land3D.skipStart
land_display_tessellation                     Land3D.displayTessellation                    Land.displayTessellation
latitude                                      LocationLAT                                   Latitude
longitude                                     LocationLON                                   Longitude
model1_ds_display_all                         allModel1Ds.displayAll                        model1Ds.displayAll
model1_ds_display_leaves                      allModel1Ds.displayLeaves                     model1Ds.displayLeaves
model2_ds_display_all                         allModel2Ds.displayAll                        model2Ds.displayAll
moon3_d_display_surface                       Moon3D.displaySurface                         Moon3D.displaySurface
moon3_d_display_texture                       Moon3D.displayTexture                         Moon3D.displayTexture
moon3_d_fit_in_sky_dome                       Moon3D.fitInSkyDome                           Moon3D.fitInSkyDome
number_of_days_to_plot                        STUDY.j_End                                   Number of days to plot
objects_scale                                 OBJECTS_scale                                 Objects_scale
orientation_angle                             Develop_AngleOrientation                      Orientation angle
planetary_magnification                       Planetary_Magnification                       Planetary_Magnification
polylines_display_all                         allPolylines.displayAll                       polylines.displayAll
probabilities_interval                        STUDY.sumInterval                             Probabilities interval
probabilities_range                           STUDY.LevelPix                                Probabilities range
record_solar_analysis_in_jpg                  allSolarImpacts.record_IMG                    Record Solar Analysis in JPG
record_solid_impact_in_jpg                    allSolidImpacts.record_IMG                    Record SolidImpact in JPG
record_solid_impact_in_pdf                    allSolidImpacts.record_PDF                    Record SolidImpact in PDF
sample_year_start                             SampleYear_Start                              Start year
scale                                         STUDY.V_scale                                 Scale (
sections_display_all                          allSections.displayAll                        sections.displayAll
sky3_d_active_palette_clr                     Sky3D.ACTIVE_palette_CLR                      Sky3D.ACTIVE_palette_CLR
sky3_d_active_palette_dir                     Sky3D.ACTIVE_palette_DIR                      Sky3D.ACTIVE_palette_DIR
sky3_d_active_palette_mlt                     Sky3D.ACTIVE_palette_MLT                      Sky3D.ACTIVE_palette_MLT
sky3_d_display_surface                        Sky3D.displaySurface                          Sky3D.displaySurface
sky3_d_passive_palette_clr                    Sky3D.PASSIVE_palette_CLR                     Sky3D.PASSIVE_palette_CLR
sky3_d_passive_palette_dir                    Sky3D.PASSIVE_palette_DIR                     Sky3D.PASSIVE_palette_DIR
sky3_d_passive_palette_mlt                    Sky3D.PASSIVE_palette_MLT                     Sky3D.PASSIVE_palette_MLT
sky_display_tessellation                      Sky3D.displayTessellation                     Sky.displayTessellation
sky_scale                                     Sky3D.radius                                  Sky.scale
sky_status                                    STUDY.skyScenario                             Sky status
solar_impacts_display_image                   allSolarImpacts.displayImage                  solarImpacts.displayImage
solar_impacts_section_type                    allSolarImpacts.sectionType                   solarImpacts.sectionType
solid_impacts_display_image                   allSolidImpacts.displayImage                  solidImpacts.displayImage
solid_impacts_display_lines                   allSolidImpacts.displayLines                  solidImpacts.displayLines
solid_impacts_display_points                  allSolidImpacts.displayPoints                 solidImpacts.displayPoints
solid_impacts_grade                           allSolidImpacts.Grade                         solidImpacts.Grade
solid_impacts_position_step                   allSolidImpacts.positionStep                  solidImpacts.positionStep
solid_impacts_power                           allSolidImpacts.Power                         solidImpacts.Power
solid_impacts_process_sub_divisions           allSolidImpacts.Process_subDivisions          solidImpacts.Process_subDivisions
solid_impacts_r                               allSolidImpacts.R[allSolidImpacts.sectionType] solidImpacts.R[
solid_impacts_section_type                    allSolidImpacts.sectionType                   solidImpacts.sectionType
solid_impacts_u                               allSolidImpacts.U[allSolidImpacts.sectionType] solidImpacts.U[
solid_impacts_v                               allSolidImpacts.V[allSolidImpacts.sectionType] solidImpacts.V[
solid_impacts_wind_direction                  allSolidImpacts.WindDirection                 solidImpacts.WindDirection
solid_impacts_wind_speed_m_s                  allSolidImpacts.WindSpeed                     solidImpacts.WindSpeed (m/s)
solid_impacts_x                               allSolidImpacts.X[allSolidImpacts.sectionType] solidImpacts.X[
solid_impacts_y                               allSolidImpacts.Y[allSolidImpacts.sectionType] solidImpacts.Y[
solid_impacts_z                               allSolidImpacts.Z[allSolidImpacts.sectionType] solidImpacts.Z[
solids_display_all                            allSolids.displayAll                          solids.displayAll
solids_palette_clr                            allSolids.palette_CLR                         solids.palette_CLR
solids_palette_dir                            allSolids.palette_DIR                         solids.palette_DIR
solids_palette_mlt                            allSolids.palette_MLT                         solids.palette_MLT
start_day                                     TIME.day                                      Start day
start_hour                                    STUDY.i_Start                                 Start hour
start_member                                  SampleMember_Start                            Start member
start_month                                   TIME.month                                    Start month
start_station                                 SampleStation_Start                           Start station
start_year                                    TIME.year                                     Start year
study_active_palette_clr                      STUDY.ACTIVE_palette_CLR                      STUDY.ACTIVE_palette_CLR
study_active_palette_dir                      STUDY.ACTIVE_palette_DIR                      STUDY.ACTIVE_palette_DIR
study_active_palette_mlt                      STUDY.ACTIVE_palette_MLT                      STUDY.ACTIVE_palette_MLT
study_passive_palette_clr                     STUDY.PASSIVE_palette_CLR                     STUDY.PASSIVE_palette_CLR
study_passive_palette_dir                     STUDY.PASSIVE_palette_DIR                     STUDY.PASSIVE_palette_DIR
study_passive_palette_mlt                     STUDY.PASSIVE_palette_MLT                     STUDY.PASSIVE_palette_MLT
study_prob_palette_clr                        STUDY.PROB_palette_CLR                        STUDY.PROB_palette_CLR
study_prob_palette_dir                        STUDY.PROB_palette_DIR                        STUDY.PROB_palette_DIR
study_prob_palette_mlt                        STUDY.PROB_palette_MLT                        STUDY.PROB_palette_MLT
study_sort_palette_clr                        STUDY.SORT_palette_CLR                        STUDY.SORT_palette_CLR
study_sort_palette_dir                        STUDY.SORT_palette_DIR                        STUDY.SORT_palette_DIR
study_sort_palette_mlt                        STUDY.SORT_palette_MLT                        STUDY.SORT_palette_MLT
sun3_d_active_palette_clr                     Sun3D.ACTIVE_palette_CLR                      Sun3D.ACTIVE_palette_CLR
sun3_d_active_palette_dir                     Sun3D.ACTIVE_palette_DIR                      Sun3D.ACTIVE_palette_DIR
sun3_d_active_palette_mlt                     Sun3D.ACTIVE_palette_MLT                      Sun3D.ACTIVE_palette_MLT
sun3_d_display_path                           Sun3D.displayPath                             Sun3D.displayPath
sun3_d_display_pattern                        Sun3D.displayPattern                          Sun3D.displayPattern
sun3_d_display_surface                        Sun3D.displaySurface                          Sun3D.displaySurface
sun3_d_display_texture                        Sun3D.displayTexture                          Sun3D.displayTexture
sun3_d_fit_in_sky_dome                        Sun3D.fitInSkyDome                            Sun3D.fitInSkyDome
sun3_d_passive_palette_clr                    Sun3D.PASSIVE_palette_CLR                     Sun3D.PASSIVE_palette_CLR
sun3_d_passive_palette_dir                    Sun3D.PASSIVE_palette_DIR                     Sun3D.PASSIVE_palette_DIR
sun3_d_passive_palette_mlt                    Sun3D.PASSIVE_palette_MLT                     Sun3D.PASSIVE_palette_MLT
trend_period_hours                            STUDY.TrendJoinHours                          Trend period hours
tropo3_d_display_surface                      Tropo3D.displaySurface                        Tropo3D.displaySurface
tropo3_d_display_texture                      Tropo3D.displayTexture                        Tropo3D.displayTexture
weighted_equal_trend                          STUDY.TrendJoinType                           Weighted/equal trend
wind_flows_display_all                        allWindFlows.displayAll                       windFlows.displayAll
wind_flows_palette_clr                        allWindFlows.palette_CLR                      windFlows.palette_CLR
wind_flows_palette_dir                        allWindFlows.palette_DIR                      windFlows.palette_DIR
wind_flows_palette_mlt                        allWindFlows.palette_MLT                      windFlows.palette_MLT
wind_roses_display_image                      allWindRoses.displayImage                     windRoses.displayImage
wind_roses_scale                              allWindRoses.scale                            windRoses.scale
windose_opacity_scale                         STUDY.O_scale                                 Windose opacity scale


# SOLARCHVISION-BIM — Technical Overview

## Overview

**SOLARCHVISION-BIM** is an open-source Processing/Java-based 3D BIM and environmental simulation platform that integrates building and site geometry with geographic, meteorological, climate, solar, and environmental datasets.

The application combines a custom 3D modeling and geometry engine, interactive CAD-style editing, geospatial visualization, time-dependent solar radiation and shadow analysis, wind-flow visualization, scenario and statistical analysis, and export/persistence workflows in a unified desktop environment.

A central characteristic of the platform is the integration of:

```text
3D / BIM Geometry
       +
Geographic Context
       +
Weather / Climate Data
       +
Time & Scenarios
       +
Environmental Analysis
       +
3D Scientific Visualization
```

This allows building and urban-environment models to be analyzed using time-dependent environmental and meteorological information rather than being limited to static geometric visualization.

## Major Technical Subsystems

### 1. 3D Modeling and Geometry Engine

SOLARCHVISION-BIM implements its own lightweight geometric modeling system rather than functioning only as a viewer.

Core geometry components include:

- Points
- Faces
- Solids
- Groups
- Polylines
- Materials
- 1D models
- 2D models

The geometry system supports vertex and face management, surface normals, tessellation, transformations, rotation, scaling, translation, geometric intersections, surface operations, object grouping, material assignment, visibility, and layer management.

This geometry layer provides the foundation for both visualization and environmental calculations.

### 2. Interactive CAD-Style Modeling

The application contains dedicated modules for interactive 3D operations, including:

- Create
- Select
- Move
- Rotate
- Scale
- Modify
- Clone
- Delete
- Drop
- Edit

Users can create and manipulate objects directly within the 3D environment. The interaction system includes 3D picking, screen-to-world coordinate operations, object and face selection, mouse-based navigation, and CAD-style viewport interaction.

### 3. Parametric and Procedural Objects

The modeling system supports generated objects and procedural 1D/2D representations.

The procedural vegetation system includes parameters such as species/type, random seed, branching degree, scale, rotation, branch tilt, branch twist, branch ratio, trunk dimensions, and leaf dimensions.

This allows vegetation and environmental context to be represented as computational objects rather than only imported static models.

### 4. 3D Rendering and Visualization

The application uses Processing's `P2D` and `P3D` rendering systems and maintains multiple rendering surfaces for different views.

Major visualization areas include:

- 3D modeling viewport
- Geographic/world viewport
- Environmental study viewport
- Analytical overlays

The rendering system supports perspective and orthographic views, camera transformations, zooming, rotation, directional views, object-centered navigation, 3D overlays, surface and edge rendering, tessellation control, and analytical visualization.

The rendering architecture includes batching, clipping, caching, and selective geographic rendering to improve interactive performance.

### 5. Solar Position and Radiation Analysis

Solar analysis is one of the core environmental capabilities.

The system calculates solar position using project geographic coordinates and time information, including latitude, longitude, date, and hour.

Solar calculations incorporate:

- Direct radiation
- Diffuse radiation
- Effective direct radiation
- Effective diffuse radiation
- Solar direction vectors
- Surface geometry
- Shading/obstruction effects

A simplified workflow is:

```text
Geographic Location
        ↓
Date / Time
        ↓
Solar Position
        ↓
Weather / Climate Radiation
        ↓
3D Geometry
        ↓
Shadow / Occlusion Analysis
        ↓
Surface Solar Impact
        ↓
Visualization / Statistical Study
```

### 6. Surface-Level Solar Analysis

The solar analysis engine can process radiation at a spatially detailed level rather than assigning a single value to an entire building.

The implementation maintains time-dependent arrays for sun direction, unit sun direction, direct radiation, diffuse radiation, effective direct radiation, and effective diffuse radiation.

Solar calculations are combined with geometric surfaces and sub-surface processing to estimate spatially varying environmental impacts.

### 7. Shadow and Occlusion Analysis

The project contains dedicated shadow-casting and geometric intersection functionality.

Shadow calculations use solar direction, 3D geometry, surface geometry, ray/face intersections, and spatial sections.

This accounts for the effect of surrounding geometry on solar exposure and distinguishes theoretical incoming radiation from radiation affected by the modeled environment.

### 8. Environmental Impact Fields

The environmental analysis architecture is not limited to object-level results.

The system can calculate impact values at arbitrary 3D positions `(x, y, z)` and generate spatial fields for environmental quantities.

Impact visualization can include:

- Points
- Lines
- Contours
- Raster/image-based representations
- 3D visualization

This provides a bridge between numerical environmental analysis and spatial scientific visualization.

### 9. Wind Visualization and Analysis

The project contains a dedicated wind-analysis subsystem.

Components include wind-flow visualization, wind-rose visualization, wind speed, wind direction, and environmental impact calculations.

The system can represent wind as a spatial/vector field around modeled solids and visualize resulting flow or impact patterns in 3D.

### 10. Weather and Climate Data Integration

SOLARCHVISION-BIM contains dedicated data-ingestion and processing workflows for environmental datasets.

Supported data workflows include:

- EPW / TMY
- CWEEDS
- CLMREC
- Ensemble forecast data
- Ensemble observed data
- Meteorological station data

The architecture separates data acquisition/loading from post-processing and analysis:

```text
Download / Load
      ↓
Data Validation / Processing
      ↓
Post-Processing
      ↓
Environmental Variables
      ↓
Analysis
      ↓
Visualization
```

### 11. Ensemble and Scenario Analysis

The project includes dedicated modules for ensemble forecast and observed data.

The analysis engine recognizes ensemble forecast and observation datasets and incorporates them into temporal and statistical study workflows.

The study system supports scenario-oriented analysis, allowing environmental results to be examined across multiple possible weather or climate conditions.

### 12. Statistical Study Engine

The study engine manages:

- Analysis periods
- Hours
- Days
- Scenarios
- Filters
- Statistical layers
- Probability
- Percentiles
- Sorted data
- Normalized data
- Trends
- Impact summaries

Statistical analysis includes minimum, average, maximum, percentile analysis, probability-based visualization, scenario selection, and statistical filtering.

The system can also identify scenarios that are close to specified daily statistical conditions.

### 13. Cloud and Atmospheric Scenario Analysis

The study engine can distinguish different atmospheric/cloud conditions, including scenario groups based on total cloud cover.

This provides a mechanism for examining how atmospheric conditions influence solar and environmental results.

### 14. Geographic and Earth Modeling

The application contains a geographic visualization subsystem centered around an Earth/world model.

Capabilities include:

- Latitude/longitude positioning
- Geographic projections
- World maps
- Map tiles
- Geographic boundaries
- Station locations
- Zoom levels
- Terrain/land visualization
- Project-location-based map rendering

Map imagery can be cached and geographically limited to the relevant project/view region to reduce unnecessary processing and improve performance.

### 15. Meteorological Station System

The station subsystem connects geographic locations with environmental datasets.

Station information can include:

- Station code
- City
- Province
- Country
- Elevation
- Latitude
- Longitude
- Time longitude
- Dataset filenames

Supported station-related datasets include NAEFS, CWEEDS, TMY/EPW, CLMREC, and observational datasets.

This creates a direct relationship between:

```text
Project Location
      ↓
Meteorological Station
      ↓
Environmental Dataset
      ↓
Environmental Analysis
```

### 16. Sun, Moon, Sky, and Atmospheric Visualization

The 3D environment includes dedicated representations of the Sun, Moon, Sky, and Troposphere.

The sun model is connected to solar-position calculations, making the celestial visualization consistent with analysis time and geographic location.

The atmospheric visualization subsystem supports time-dependent imagery and geographically bounded image layers.

### 17. Time-Dependent Simulation

Time is a fundamental component of the platform.

The application maintains temporal state including year, month, day, hour, day-of-year, and analysis period.

Environmental calculations can therefore be evaluated across:

- Hours
- Days
- Seasons
- Annual periods
- Forecast periods
- Multiple scenarios

### 18. Multi-Viewport Architecture

The application separates visualization into several functional views.

**3D View** — modeling, camera navigation, object manipulation, and environmental visualization.

**World View** — geographic context, map visualization, station locations, and geographic data.

**Study View** — statistical analysis, environmental results, scenario analysis, and time-series visualization.

### 19. Command-Line and Scripting System

SOLARCHVISION-BIM includes an internal command-line system.

Commands can be entered interactively and can also be executed from scripts/text files. The command system supports parameterized commands using key/value-style arguments.

This provides an additional automation and reproducibility mechanism alongside the graphical interface.

### 20. Project Persistence

The application contains project save/load functionality using structured XML data.

Project information can include:

- Model geometry
- Layers
- Materials
- Station information
- Time state
- Study configuration
- Analysis settings
- Object properties

### 21. Layer and Material Systems

The layer system provides a common abstraction for environmental and visualization variables.

Layers can include ID, unit, name, descriptions, scale, offset, and display thresholds.

The material system associates materials with geometric faces and supports consistent rendering and object representation.

### 22. Import and Export

The application provides multiple export workflows, including:

- OBJ geometry
- Time-series OBJ
- Date-series OBJ
- RAD
- SCR
- HTML

The OBJ time/date-series export is useful for transferring time-dependent model states or analytical geometry into external workflows.

## Architecture at a Glance

```text
                       SOLARCHVISION-BIM
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   3D/BIM Model         Climate / Weather      Geospatial
        │                     │                     │
   ┌────┼────┐          ┌─────┼─────┐          ┌────┼────┐
   │    │    │          │     │     │          │    │    │
 Points Faces Solids   EPW  CWEEDS Ensemble   Earth Maps Stations
   │    │    │          │     │     │          │    │    │
   └────┼────┘          └─────┼─────┘          └────┼────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                     Time / Scenario Engine
                              │
                 ┌────────────┼────────────┐
                 │            │            │
               Solar        Shadow        Wind
              Analysis     Analysis     Analysis
                 │            │            │
                 └────────────┼────────────┘
                              │
                     Statistical Studies
                              │
                 ┌────────────┼────────────┐
                 │            │            │
             3D View      Study View    World View
                 │            │            │
                 └────────────┼────────────┘
                              │
                    Export / Persistence
```

## Technical Character

SOLARCHVISION-BIM combines:

- 3D computer graphics
- Computational geometry
- BIM / CAD modeling
- Scientific computing
- Environmental simulation
- Solar-energy analysis
- Meteorological data processing
- Climate-data analysis
- GIS/geospatial visualization
- Statistical/scenario analysis
- Interactive visualization
- Data import/export
- Scriptable workflows

The most significant architectural characteristic is the integration of **geometric modeling and environmental data**.

A conventional BIM workflow primarily represents buildings and their relationships. A conventional scientific-visualization workflow primarily represents datasets. SOLARCHVISION-BIM connects the two:

```text
Building / Urban Geometry
          +
Geographic Location
          +
Weather / Climate Data
          +
Time / Scenarios
          ↓
Environmental Simulation
          ↓
Spatial Impacts
          ↓
Interactive 3D Visualization
          ↓
Statistical Study / Export
```

This makes the platform suitable for environmental and climatic analysis of buildings and urban environments.
