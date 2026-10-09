# SOLARCHVISION-BIM

**Explore how buildings, landscapes, and urban spaces interact with the sun, weather, and climate.**

SOLARCHVISION-BIM is an open-source desktop application for 3D modeling and environmental analysis. It brings together building and site geometry, geographic context, weather and climate data, and time-dependent visualization to help architects, urban planners, and landscape architects investigate environmental conditions during design.

Use it to explore solar access and shading, compare site and building configurations, visualize weather and atmospheric conditions, and examine how environmental impacts change by hour, day, season, or scenario. The application combines an interactive 3D workspace with geographic and time-series views.

- **For:** Architects, urban and landscape planners, designers, researchers, and technically minded users interested in environmental design.
- **Platforms:** GNU/Linux, macOS, and Microsoft Windows.
- **License:** GNU General Public License v2 (GPL-2.0).
- **Repository:** [archmoj/solarchvision_bim](https://github.com/archmoj/solarchvision_bim)

> **Important:** SOLARCHVISION-BIM is a design exploration and analysis tool. Results depend on the quality and suitability of the model, location, and input data. They should not be treated as certified engineering calculations or a substitute for professional review.

## The SOLARCHVISION approach

SOLARCHVISION is based on **solar-climatic vision**: looking at architectural and urban design from the perspective of the sun and the local climate, then using that understanding to develop and compare design alternatives.

Rather than treating solar analysis as a check performed after a design is complete, this approach brings environmental performance into the design process. It considers how the sun's path and radiation interact with temperature, wind, clouds, building geometry, façade elements, vegetation, and surrounding urban form. The goal is to understand both beneficial and undesirable conditions and use that knowledge to inform design decisions.

### From climate understanding to design decisions

The approach connects several questions that are often considered separately:

- **Where and when does the sun reach a place?** Consider geographic location, orientation, solar path, time of day, and season.
- **How does the built and natural environment change solar access?** Explore the effects of building massing, façade geometry, overhangs, shading devices, trees, and surrounding structures.
- **What are the local climatic conditions?** Interpret solar radiation alongside available temperature, wind, cloud, and other meteorological information.
- **How might alternatives perform?** Compare forms, orientations, shading strategies, and site arrangements across relevant times and weather conditions.
- **How can environmental performance inform architectural quality?** Consider energy use, daylight, indoor and outdoor comfort, and the quality of public and private spaces together rather than optimizing a single variable in isolation.

### Think across scales and time

Solar-climatic design can be considered at different scales, from the arrangement of buildings and open spaces in an urban area to the orientation, shape, and details of an individual building or façade. It also has a time dimension: a solution that is beneficial at one hour or season may create unwanted shade or heat at another.

SOLARCHVISION-BIM supports this way of thinking by combining 3D geometry, geographic context, weather and climate data, time-dependent visualization, and scenario or statistical comparisons in one workspace. Designers can use these views to investigate alternatives and identify questions that merit more detailed study.

This is a **design-support methodology**, not a guarantee that one configuration is universally optimal. Outcomes depend on climate, site context, building use, the accuracy of the model, and the assumptions behind the selected data and study.

The approach is described in the coauthored book [*Intelligent Design using Solar-Climatic Vision: Energy and Comfort Improvement in Architecture and Urban Planning using SOLARCHVISION*](https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8) (Mojtaba Samimi and Farshad Nasrollahi, 2014).

## What can I use it for?

### Architecture and building design

- Create and edit 3D geometry to explore building form and site relationships.
- Investigate solar position, surface exposure, and shading from surrounding geometry.
- Compare environmental conditions across different times and weather scenarios.
- Visualize modeled buildings with time-dependent solar and environmental layers.

### Urban planning and public space

- Explore relationships among building massing, open space, and surrounding context.
- Examine solar access and shadow patterns at different times of day and year.
- Use geographic context and weather information to inform early-stage comparisons.
- Visualize wind-related patterns and other spatial environmental fields where supported by the model and data.

### Landscape architecture

- Represent terrain, trees, and site elements in a 3D scene.
- Explore the effects of vegetation and surrounding objects on shade and solar exposure.
- Review site conditions in their geographic and seasonal context.

### Climate and environmental studies

- Work with supported weather, climate, observation, and ensemble forecast datasets.
- Inspect time-dependent variables and compare selected hours, days, years, or forecast scenarios.
- Use statistical summaries such as minimum, average, maximum, and percentiles to explore variability.
- Export geometry or selected model states for use in other workflows.

The available analyses depend on the selected study, input dataset, location, and model setup.

## Getting started

### 1. Get the application

The simplest route is to use a pre-built application from the repository:

1. Open the [SOLARCHVISION-BIM repository](https://github.com/archmoj/solarchvision_bim).
2. Download the repository as a ZIP file or clone it using Git.
3. Open the `dist` directory.
4. Run the executable intended for your operating system.

If you prefer Git, use one of the following commands:

**HTTPS**

```sh
git clone https://github.com/archmoj/solarchvision_bim.git
```

For a smaller, shallow clone:

```sh
git clone https://github.com/archmoj/solarchvision_bim.git --depth 1
```

**SSH** (requires an SSH key configured with GitHub)

```sh
git clone git@github.com:archmoj/solarchvision_bim.git
```

The pre-built files and their launch requirements may vary by release. If the application does not start, check the repository instructions and the files supplied in `dist` for your platform.

### 2. Understand the main workspace

The interface combines several views:

- **3D view:** Create, select, edit, and inspect buildings, surfaces, terrain, trees, and other objects. This is also where many environmental effects are visualized.
- **World view:** Explore geographic context, choose a project location, and work with available map, station, and terrain information.
- **Study/time view:** Inspect time-series graphs, environmental studies, and statistical or scenario results.
- **Case bar:** Choose the hours, days, and scenarios or years to include in a study, and select a statistical summary where available.
- **Command bar:** An optional text-based interface for entering commands. Most users can begin with the menus and view controls; commands are useful for precise settings or repeatable workflows.

The initial layout can vary depending on the selected setup. Use the `Setup` menu to switch among available 3D models and time-view layouts.

### 3. Choose a location and weather data

Use the `Location` menu to select the project location and load or download supported weather and geographic data. The application uses EPW/TMY data by default when available. Other supported sources include:

- **CWEEDS:** Multi-year engineering climate data for Canadian locations.
- **CLMREC:** Supported climate-record data.
- **NAEFS:** Ensemble forecast data for exploring a range of forecast scenarios.
- **SWOB:** Meteorological observations.
- **HRDPS/GDPS forecast imagery:** Available through the atmospheric visualization workflow where configured.

Dataset availability and coverage vary by location. Some geographic features, including terrain mesh and terrain texture, require an API key. For Canadian CWEEDS data, see the [Engineering Climate Datasets](https://climate.weather.gc.ca/prods_servs/engineering_e.html) page. Place downloaded files in the folder described by the repository's data layout; CWEEDS files are expected under `input/climate/CWEEDS/`.

### 4. Build or prepare a scene

Use the `3D-create` menu to add supported objects. Available object types include houses, parametric surfaces, boxes, cones, cushions, cylinders, spheres, planes, polygons, extrusions, surfaces, polylines, points, trees, people, and cameras.

After choosing an object type, click in the 3D view to place it:

- **Right-click:** Place the object on the land surface.
- **Left-click:** Place the object on the surface of an existing 3D model.

Default creation parameters are available under `Geometries & Space` → `Create`. Use the `3D-select`, `3D-alter`, `3D-modify`, and `3D-match` menus to select, adjust, modify, and align objects. The application supports importing `.obj` 3D files as well as its own scene geometry.

### 5. Explore solar and environmental conditions

Start with an available study in the `Analysis` menu. General studies include wind patterns, orientation potential, hourly sun position, and annual sun paths, with active and passive variants where offered.

For model-based studies such as `Urban solar potential (active)` and `Urban solar potential (passive)`, the README's current workflow requires preparing a selected `Section` or `Camera` first using `PreBake Viewport` or `Pre-bake Selected Sections`.

Use the `3D-shade` menu to change the visualization, including options such as `Shade Global Solar` where available. Move through time to see how the display changes. Interpret colors and values according to the selected layer and its units; different layers may represent different environmental quantities.

### 6. Compare times and scenarios

The **Case Bar** sits above the command bar. Its range controls let you select:

- **Hours** within the data period.
- **Days** to include in the study.
- **Scenarios** for ensemble forecasts, or **Years** for multi-year climate input.

Use a left-click to set the start of a range and a right-click to set its end. Statistical choices include minimum, average, maximum, 25th, 50th (median), and 75th percentiles, as well as the built-in `Middle`, `Mid-High`, and `Mid-Low` selections. These choices are not interchangeable: choose the statistic or scenario selection that best matches the question you are investigating.

### 7. Save or export your work

Use the application's project save/load functions to retain supported scene and study information. Available export workflows include OBJ geometry, time-series or date-series OBJ, RAD, SCR, and HTML. These formats serve different purposes.

## Common tasks

### Select a weather station on the map

Click in the world view to select the nearest station from the currently active dataset. A left-click zooms in to the most detailed map level; a right-click keeps the current zoom, which can help when comparing several locations. When multiple stations are within the dataset's search radius, a list appears so you can choose the intended station.

### Work with weather layers

Weather layers fall into two broad categories:

- **General layers:** Values available directly from the source weather data; missing values may be filled through post-processing.
- **Developed layers:** Variables generated by processing the source data rather than supplied directly in the original file.

Check the layer name, units, time range, and data source before comparing results.

### Change the view layout

Use the `Setup` menu to select a predefined 3D model or time-view layout. Enlarge the time view when a graph or study layout is too small to read in the current arrangement.

## Keyboard shortcuts

When the command bar is hidden (the default mode), these shortcuts can help you navigate and explore. The application may interpret keys differently when a text field or command bar has focus.

### General

| Shortcut | Action |
| --- | --- |
| `TAB` | Show or hide the command bar |
| `Shift+TAB` | Switch between active and passive impact views in the 3D view |

### Camera and view navigation

| Shortcut | Action |
| --- | --- |
| `` ` `` / `~` | Cycle through world-view zoom levels |
| `+` / `-` | Zoom the 3D view in or out |
| `Ctrl+,` / `Ctrl+.` | Move the camera closer to or farther from the selection |
| `,` / `.` | Move the camera closer or farther |
| `2` / `8` | Rotate the camera up or down |
| `4` / `6` | Rotate the camera left or right |
| `1` / `3` | Move the camera left or right |
| `7` / `9` | Move the camera up or down |
| `5` | Aim the camera at the selection, or the origin if nothing is selected |
| `0` | Move the camera closer |
| `/` / `*` | Move the camera toward or away from the selection |
| Arrow keys | Rotate the camera around the selection |

### Selection, model, and time

| Shortcut | Action |
| --- | --- |
| `DELETE` | Delete selected items |
| `Shift+UP` / `Shift+DOWN` | Move, rotate, scale, or adjust properties of the selection, depending on the active control |
| `c` / `C` | Switch to available cameras in the scene |
| `ENTER` | Rebuild global and vertex solar-energy/impact data |
| `SPACE` | Advance time and shade the view |
| `BACKSPACE` | Move time backward and shade the view |
| `d` / `D` | Change the impact-display day in the 3D view |
| `t` / `T` | Change the forecast hour used for atmospheric visualization |

### Time graphs and layouts

These shortcuts act on the time/study view.

| Shortcut | Action |
| --- | --- |
| `Ctrl+UP` / `Ctrl+DOWN` | Change the weather layer in the hourly graph |
| `Ctrl+LEFT` / `Ctrl+RIGHT` | Change the impact layer in the daily graph |
| `Ctrl+PAGE_UP` / `Ctrl+PAGE_DOWN` | Switch among numbered layouts available in `Setup` |
| `Ctrl+;` | Show or hide the impact summary |
| `Ctrl+'` / `Ctrl+"` | Adjust the hourly graph's vertical scale factor |
| `<` / `>` | Change the number of joined days |
| `(` / `)` | Change the number of displayed days |
| `[` / `]` | Change the horizontal interval of the probability graph |
| `{` / `}` | Change the vertical interval of the probability graph |
| `s` / `S` | Change the sky scenario: all data, sunny, partly cloudy, or cloudy |
| `v` / `V` | Show or hide raw values on the hourly graph |
| `b` / `B` | Show or hide probabilities on the hourly graph |
| `n` / `N` | Show or hide statistics on the hourly graph |
| `m` / `M` | Show or hide sorted values on the hourly graph |

## Command bar and advanced workflows

The command bar is optional. It is useful for setting a value precisely, repeating a series of operations, or running commands from scripts. Press `TAB` to show or hide it, or click inside the dark command area at the bottom of the interface.

See the [command reference](command/README.md) for available commands covering project files, object creation and editing, camera and view controls, dates, palettes, latitude/longitude, numeric controls, and on/off settings. For example, `day 15` sets the day value through the command interface.

## SOLARCHVISION method and publications

- [TU Berlin book: *Intelligent Design using Solar-Climatic Vision* — Energy and Comfort Improvement in Architecture and Urban Planning using SOLARCHVISION](https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8)
- [Presentation at Ouranos](https://www.dropbox.com/scl/fo/5r66ns7r9j0rezprwa567/ADuKLQ_qQo98gDnlqDQMXVY?dl=0&e=2&preview=SOLARCHVISION_2015_12_09_Ouranos.pdf&rlkey=0x1wzfy5dll3bvx6j9ltw96v6)
- [BIM6D presentation](https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtibaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1)

## Technical overview

This section summarizes the main capabilities for readers who want a more detailed understanding of the application. Most users can begin with **Getting started**, **Common tasks**, and **Keyboard shortcuts** without reading this section first.

### Modeling and visualization

SOLARCHVISION-BIM includes a 3D geometry system for points, faces, solids, groups, polylines, materials, and 1D/2D models. It supports object creation, selection, transformation, grouping, visibility, layers, and material assignment. Procedural vegetation and parametric objects can be used to represent aspects of the built and natural environment.

The interface provides 3D, world/geographic, and study/time views. Rendering supports perspective and orthographic cameras, surface and edge display, analytical overlays, and cached or clipped rendering for interactive performance.

### Solar, shade, and environmental analysis

Solar calculations use the project's geographic location and time, together with weather or climate radiation data and modeled geometry. The application includes direct and diffuse radiation handling, solar direction, shadow/occlusion calculations, and surface-level impact visualization. The model's surrounding geometry can affect estimated exposure and shade.

Other environmental features include wind visualization, wind-rose views, environmental impact fields, contours and raster-like representations, and atmospheric/cloud visualization. The exact outputs depend on the selected study and available input data.

### Weather, climate, and scenario data

Supported workflows include EPW/TMY, CWEEDS, CLMREC, ensemble forecast and observation data, and meteorological station data. The application separates loading, processing, and analysis so source values can be prepared into variables and visual layers. Ensemble and multi-year data can be explored across hours, days, scenarios, and years, with statistical summaries and percentile-based views.

### Geographic context and time

The geographic subsystem supports latitude/longitude positioning, map projections, map tiles, station locations, zoom levels, and terrain visualization. The Earth model can display map imagery around the project location with geographic grid and terrain context. Time-dependent studies can be explored by hour, day, season, annual period, forecast period, or scenario, depending on the dataset.

### Projects, commands, and exchange

Project persistence uses structured XML data for supported model geometry, layers, materials, station information, time state, study configuration, analysis settings, and object properties. The command system supports interactive entry and scripts/text files for repeatable operations. Export options include OBJ, time-series/date-series OBJ, RAD, SCR, and HTML.

### Main workflow at a glance

```text
Building / Site Model + Geographic Location
                    ↓
             Weather / Climate Data
                    ↓
          Choose Time and Scenarios
                    ↓
       Solar / Shade / Environmental Study
                    ↓
       Explore 3D Views and Study Graphs
                    ↓
             Save or Export Results
```

## License

The source code and documentation are released under the [GNU General Public License v2](LICENSE.md).
