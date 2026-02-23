SOLARCHVISION-BIM is a desktop software application designed and
developed by [Mojtaba Samimi
(M.Arch)](https://www.linkedin.com/in/mojtaba-samimi-06178840) in the
[Processing](https://processing.org/) language. It is available for
`GNU/Linux`, `macOS`, and `Microsoft Windows`.

## Table of contents

-   [Clone using SSH](#clone-using-ssh)
-   [Clone using HTTPS](#clone-using-https)
-   [Requirements](#requirements)
-   [Before running the program](#before-running-the-program)
-   [Run using Processing IDE](#run-using-processing-ide)
-   [Run using command line](#run-using-command-line)
-   [Download EPW files](#download-epw-files)
-   [Download CWEEDS files](#download-cweeds-files)
-   [Copyright and license](#copyright-and-license)
-   [Graphical User Interface](#graphical-user-interface)
-   [User interface keyboard shortcuts](#user-interface-keyboard-shortcuts)
-   [Command line](#command-line)
-   [Additional resources](#additional-resources)

------------------------------------------------------------------------

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

## Before running the program

You should adjust the `BaseFolder` variable inside `solarchvision_bim.pde`.

``` java
String BaseFolder = "/home/solarch/org/solarchvision_bim";
```

Also to your screen resolution you may need to scale initial values of following
variables and the size() function:
``` java
int SOLARCHVISION_pixel_H = 400;
int SOLARCHVISION_pixel_W = 724;

float MessageSize = 16.0;
int SOLARCHVISION_pixel_A = 24; // menu bar
int SOLARCHVISION_pixel_B = 44; // 3D tool bar
int SOLARCHVISION_pixel_C = 72; // time bar
int SOLARCHVISION_pixel_D = 72; // command bar

size(1848, 1016, P2D);
```

## Run using Processing IDE

The `solarchvision_bim` sketch can be opened in the Processing IDE and
executed using the Play button.

## Run using command line

To compile and run the `solarchvision_bim` sketch, adjust
`<PATH-TO-PROCESSING>` in the following command as needed.

Please note that the command must be executed from the parent directory
containing the `solarchvision_bim` folder.

``` sh
<PATH-TO-PROCESSING>/processing-java --sketch=solarchvision_bim --run
```

## Download EPW files

To download EPW/TMY (Typical Meteorological Year) data for various
locations, a script is provided inside the `scripts` folder.

You need to adjust the `outFolder` variable in the `download_epw.js`
file to point to your installation directory.

In addition, [`node.js`](https://nodejs.org/en) is required to run the
script.

``` sh
node scripts/download_epw.js
```

## Download CWEEDS files

For locations in `Canada`, there is another database called `CWEEDS`,
which includes multi-year climate data under the Engineering Climate
Datasets (https://climate.weather.gc.ca/prods_servs/engineering_e.html).

The files for the region of interest can be extracted and placed inside
the `solarchvision_bim/input/climate/CWEEDS/` folder.

## Copyright and license

The code and documentation are released under the [GPL
v2](https://github.com/archmoj/solarchvision_bim/blob/master/LICENSE.md).

## Graphical User Interface

Once loaded the UI would look like this:

<p align="center">
    <img src="https://raw.githubusercontent.com/archmoj/solarchvision_bim/refs/heads/main//doc/images/InitialView.jpg">
</p>

Please note that in above example the `Setup | 3D-model 1` option is selected. A person and a tree is also added close to the camera.

## User interface keyboard shortcuts

When the command bar is disabled (default mode), you can use keyboard shortcuts to perform various tasks.

### General
-   `TAB`: Enable or disable the command bar
-   `Shift+TAB`: Switch between active and passive views inside the 3D viewport

------------------------------------------------------------------------

### Camera and viewport control
-   `` ` `` and `~`: Zoom in and out in the world viewport
-   `+` and `-`: Zoom in and out in the 3D viewport
-   `,` and `.`: Move the camera closer and farther
-   `2` and `8`: RRotate the camera up and down
-   `4` and `6`: Rotate the camera left and right
-   `1` and `3`: Move the camera left and right
-   `7` and `9`: Move the camera up and down
-   `5`: Rotate the camera to look at the origin
-   `0`: Move the camera closer
-   `/` and `*`: Move the camera toward and away from the selection
-   `UP`, `DOWN`, `LEFT` and `RIGHT`: Rotate the camera around the selection

------------------------------------------------------------------------

### Selection and scene interaction
-   `DELETE`: Delete selected item(s)
-   `c` and `C`: Switch the viewport to available cameras in the scene
-   `ENTER`: Rebuild global & vertex solar energy/impact data
-   `SPACE`: Record the frame

------------------------------------------------------------------------

### Time, weather, and impact visualization
-   `d` and `D`: Change the impact display day in the 3D viewport
-   `t` and `T`: Change the forecast hour used to display the troposphere

------------------------------------------------------------------------

### Layout and graph controls
-   `Ctrl+UP` and `Ctrl+DOWN`: Change the current weather layer displayed in the hourly graph (Layout 0 — default layout)
-   `Ctrl+LEFT` and `Ctrl+RIGHT`: Change the current impact layer displayed in the daily graph (Layout 0 — default layout)
-   `Ctrl+PAGE_UP` and `Ctrl+PAGE_DOWN`: Switch between layouts (enlarge the time viewport to view the full layout)
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
-   `OPEN`: Opens a saved project
-   `SAVE.AS`: Saves the project with a new name
-   `SAVE`: Saves the project
-   `HOLD`: Holds the scene
-   `FETCH`: Fetches the scene
-   `IMPORT`: Imports an OBJ file
-   `EXECUTE`: Executes a script file containing multiple SOLARCHVISION
    commands
-   `EXPORT.OBJ.TIMESERIES`: Exports the scene in OBJ format at
    different hours (multiple files)
-   `EXPORT.OBJ.DATESERIES`: Exports the scene in OBJ format at
    different days (multiple files)
-   `EXPORT.OBJ`: Exports the scene in OBJ format
-   `EXPORT.RAD`: Exports the scene in Radiance RAD format
-   `EXPORT.SCR`: Exports the scene in AutoCAD SCR format
-   `QUIT`: Exits the software

------------------------------------------------------------------------

### Location

-   `LONLAT`: Sets the longitude and latitude of the location

```
LonLat ? ?
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
2Dman m=? x=? y=? z=?
```

-   `TREE`: Creates a 2D tree using vertical and horizontal sections

```
2Dtree m=? x=? y=? z=? h=?
```

-   `FRACTALTREE`: Creates a parametric fractal tree in 3D
```
3Dtree m=? degree=? seed=? x=? y=? z=? h=? r=? tilt=? twist=? ratio=? base=? Tk=? Lf=?
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
-   `RENDER.VIEWPORT`: Renders the viewport
-   `PREBAKE.VIEWPORT`: Pre-bakes the viewport



## Additional resources
### [BIM6D Presentation](https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtabaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1)
### [Presentation at Ouranos](https://www.dropbox.com/scl/fo/5r66ns7r9j0rezprwa567/ADuKLQ_qQo98gDnlqDQMXVY?dl=0&e=2&preview=SOLARCHVISION_2015_12_09_Ouranos.pdf&rlkey=0x1wzfy5dll3bvx6j9ltw96v6)
### [TU-Berlin book: Intelligent Design using Solar-Climatic Vision (Energy and Comfort Improvement in Architecture and Urban Planning using SOLARCHVISION)](https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8)
