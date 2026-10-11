# SOLARCHVISION-BIM

**Design with the sun, the site, and the climate in view.**

SOLARCHVISION-BIM is an open-source desktop application for **3D
modeling and solar-climatic analysis**. Bring building and site geometry
together with geographic context, supported weather and climate data,
and time-dependent visualization to explore how sunlight, shade, and
environmental conditions interact.

Use it to investigate design alternatives, understand seasonal
trade-offs, and communicate findings---from early architectural concepts
to urban spaces, landscapes, and renewable-energy studies.

-   **Platforms:** GNU/Linux, macOS, and Microsoft Windows
-   **License:** GNU General Public License v2 (GPL-2.0)
-   **Repository:**
    [archmoj/solarchvision_bim](https://github.com/archmoj/solarchvision_bim)
-   **Documentation:** [Command reference](command/README.md)

> **Important:** SOLARCHVISION-BIM supports design exploration and
> analysis. Results depend on the model, location, input data, and
> selected workflow. They are not certified engineering calculations and
> do not replace professional review or specialist simulation where
> required.

## Why SOLARCHVISION-BIM?

Many design questions are spatial and time-dependent: When does a façade
receive direct sun? How do nearby buildings and trees change a site's
shade? How might a design behave across seasons or different weather
scenarios?

SOLARCHVISION-BIM brings several parts of that investigation into one
workspace:

-   **Model the place:** Create and edit 3D buildings, surfaces,
    terrain, trees, and other site elements.
-   **Understand solar exposure:** Explore sun position, solar
    radiation, shading, and the effects of surrounding geometry.
-   **Connect design to location:** Use geographic views, map imagery,
    station locations, and terrain context where available.
-   **Explore time and variability:** Compare hours, days, years, and
    supported forecast scenarios; inspect statistical summaries and
    percentiles where available.
-   **Visualize environmental data:** Explore supported weather layers
    and other spatial environmental fields.
-   **Build repeatable workflows:** Use the graphical interface, command
    bar, scripts, and supported export formats.
-   **Use and extend open-source software:** Inspect the code, report
    issues, and adapt the application to your needs.

The available analyses depend on the selected study, model setup,
location, and dataset.

## Get started

### 1. Get the application

1.  Open the [SOLARCHVISION-BIM GitHub
    repository](https://github.com/archmoj/solarchvision_bim).
2.  Download the repository as a ZIP file or clone it with Git.
3.  Open the `dist` directory.
4.  Run the executable intended for your operating system, following any
    release-specific instructions.

Clone the repository with HTTPS:

``` sh
git clone https://github.com/archmoj/solarchvision_bim.git
```

For a smaller, shallow clone:

``` sh
git clone https://github.com/archmoj/solarchvision_bim.git --depth 1
```

Or use SSH if your GitHub account has an SSH key configured:

``` sh
git clone git@github.com:archmoj/solarchvision_bim.git
```

Pre-built files and launch requirements can vary by release. If the
application does not start, check the repository instructions and the
files supplied in `dist` for your platform.

### 2. Try a first study

A useful first session is to investigate one clear question---for
example, how the shade on a building or outdoor space changes throughout
the day.

1.  **Choose a location.** Use the `Location` menu to set the project
    location.
2.  **Load suitable data.** Load an available weather or climate dataset
    for the location.
3.  **Create a simple scene.** Use `3D-create` to add geometry, or
    import a supported `.obj` model.
4.  **Choose a study.** Open the `Analysis` menu and select an available
    solar or environmental study.
5.  **Inspect the result.** Use the 3D view and available study graphs
    to explore the result.
6.  **Move through time.** Use the Case Bar to select hours, days,
    years, or forecast scenarios supported by the dataset.
7.  **Save or export.** Save your project or use an available export
    workflow.

For model-based studies such as `Urban solar potential (active)` and
`Urban solar potential (passive)`, prepare a selected `Section` or
`Camera` using `PreBake Viewport` or `Pre-bake Selected Sections` where
required by the workflow.

### 3. Get familiar with the workspace

-   **3D view:** Create, select, edit, and inspect buildings, surfaces,
    terrain, trees, and other objects. Environmental effects are
    visualized here for supported studies.
-   **World view:** Explore geographic context, select a project
    location, and work with available map, station, and terrain
    information.
-   **Study/time view:** Inspect time-series graphs, environmental
    studies, and statistical or scenario results.
-   **Case Bar:** Choose the hours, days, and scenarios or years
    included in a study, and select a statistical summary where
    available.
-   **Command bar:** Enter commands for precise settings and repeatable
    workflows. Press `TAB` to show or hide it.

The initial layout can vary. Use the `Setup` menu to switch among
available 3D models and time-view layouts.

## What can you explore?

### Architecture and building design

-   Compare building form, orientation, surface exposure, and shading.
-   Investigate how surrounding geometry affects solar access.
-   Explore changes in solar exposure across hours, seasons, and
    supported weather scenarios.
-   Consider trade-offs between useful solar gains and unwanted
    exposure.

### Urban planning and public space

-   Examine relationships among building massing, open space, and
    surrounding context.
-   Explore solar access and shadow patterns in streets, courtyards,
    parks, and other public spaces.
-   Investigate the influence of neighboring buildings, trees, and
    shading structures.
-   Use geographic and weather context to inform early-stage
    comparisons.

### Landscape architecture

-   Represent terrain, trees, and site elements in a 3D scene.
-   Explore how vegetation and structures affect shade and solar
    exposure.
-   Compare landscape alternatives across seasons.

### Climate and environmental studies

-   Work with supported weather, climate, observation, and ensemble
    forecast datasets.
-   Compare selected hours, days, years, and forecast scenarios.
-   Inspect statistical summaries such as minimum, average, maximum, and
    percentiles where supported.
-   Visualize selected environmental fields and export geometry or model
    states for other workflows.

These analyses can inform design decisions, but they do not replace
detailed daylight, whole-building energy, or other specialist
simulations when those are required.

## Weather, climate, and geographic data

Use the `Location` menu to select a project location and load or
download supported weather and geographic data. EPW/TMY data are used by
default when available. Other supported sources and workflows include:

-   **CWEEDS:** Multi-year engineering climate data for Canadian
    locations.
-   **CLMREC:** Supported climate-record data.
-   **NAEFS:** Ensemble forecast data for exploring a range of forecast
    scenarios.
-   **SWOB:** Meteorological observations.
-   **HRDPS/GDPS forecast imagery:** Available through the atmospheric
    visualization workflow where configured.

Coverage and availability vary by location and workflow. Some geographic
features, including terrain mesh and terrain texture, require an API
key. For Canadian CWEEDS data, consult [Engineering Climate
Datasets](https://climate.weather.gc.ca/prods_servs/engineering_e.html).
CWEEDS files are expected under `input/climate/CWEEDS/`.

**Check data before interpreting results.** Confirm the source,
geographic representativeness, time coverage, units, missing values, and
processing assumptions. Typical weather years, historical records,
recent observations, deterministic forecasts, and ensemble forecasts
describe different aspects of environmental conditions; they should not
be treated as interchangeable.

## Modeling and analysis workflow

### Create or import a scene

Use the `3D-create` menu to add supported objects, including houses,
parametric surfaces, boxes, cones, cushions, cylinders, spheres, planes,
polygons, extrusions, surfaces, polylines, points, trees, people, and
cameras.

After choosing an object type, click in the 3D view to place it:

-   **Right-click:** Place the object on the land surface.
-   **Left-click:** Place the object on the surface of an existing 3D
    model.

Default creation parameters are available under `Geometries & Space` →
`Create`. Use `3D-select`, `3D-alter`, `3D-modify`, and `3D-match` to
select, adjust, modify, and align objects. The application supports
importing `.obj` files as well as its own scene geometry.

### Choose and interpret a study

Start with an available study in the `Analysis` menu. General studies
include wind patterns, orientation potential, hourly sun position, and
annual sun paths, with active and passive variants where offered.

Use the `3D-shade` menu to change the visualization, including options
such as `Shade Global Solar` where available. Move through time to see
how the display changes. Always interpret colors and values according to
the selected layer and its units; different layers can represent
different environmental quantities.

### Compare hours, days, years, and scenarios

The **Case Bar** sits above the command bar. Its range controls let you
select:

-   **Hours** within the available data period.
-   **Days** to include in the study.
-   **Scenarios** for ensemble forecasts, or **Years** for multi-year
    climate input.

Use a left-click to set the start of a range and a right-click to set
its end. Available statistical choices include minimum, average,
maximum, the 25th, 50th (median), and 75th percentiles, plus built-in
`Middle`, `Mid-High`, and `Mid-Low` selections. These options are not
interchangeable: choose the statistic or scenario selection that matches
the question being investigated.

### Save and export

Use the application's project save/load functions to retain supported
scene and study information. Available export workflows include OBJ
geometry, time-series or date-series OBJ, RAD, SCR, and HTML. Formats
serve different purposes; check the target application's documentation
before relying on an export for downstream production work.

## Keyboard shortcuts

Shortcuts may behave differently when a text field or the command bar
has focus.

### General

  -----------------------------------------------------------------------
  Shortcut                            Action
  ----------------------------------- -----------------------------------
  `TAB`                               Show or hide the command bar

  `Shift+TAB`                         Switch between active and passive
                                      impact views in the 3D view
  -----------------------------------------------------------------------

### Camera and view navigation

  -----------------------------------------------------------------------
  Shortcut                            Action
  ----------------------------------- -----------------------------------
  `` ` `` / `~`                       Cycle through world-view zoom
                                      levels

  `+` / `-`                           Zoom the 3D view in or out

  `Ctrl+,` / `Ctrl+.`                 Move the camera closer to or
                                      farther from the selection

  `,` / `.`                           Move the camera closer or farther

  `2` / `8`                           Rotate the camera up or down

  `4` / `6`                           Rotate the camera left or right

  `1` / `3`                           Move the camera left or right

  `7` / `9`                           Move the camera up or down

  `5`                                 Aim the camera at the selection, or
                                      the origin if nothing is selected

  `0`                                 Move the camera closer

  `/` / `*`                           Move the camera toward or away from
                                      the selection

  Arrow keys                          Rotate the camera around the
                                      selection
  -----------------------------------------------------------------------

### Selection, model, and time

  -----------------------------------------------------------------------
  Shortcut                            Action
  ----------------------------------- -----------------------------------
  `DELETE`                            Delete selected items

  `Shift+UP` / `Shift+DOWN`           Move, rotate, scale, or adjust
                                      selection properties, depending on
                                      the active control

  `c` / `C`                           Switch to available cameras in the
                                      scene

  `ENTER`                             Rebuild global and vertex
                                      solar-energy/impact data

  `SPACE`                             Advance time and shade the view

  `BACKSPACE`                         Move time backward and shade the
                                      view

  `d` / `D`                           Change the impact-display day in
                                      the 3D view

  `t` / `T`                           Change the forecast hour used for
                                      atmospheric visualization
  -----------------------------------------------------------------------

### Time graphs and layouts

  -----------------------------------------------------------------------
  Shortcut                            Action
  ----------------------------------- -----------------------------------
  `Ctrl+UP` / `Ctrl+DOWN`             Change the weather layer in the
                                      hourly graph

  `Ctrl+LEFT` / `Ctrl+RIGHT`          Change the impact layer in the
                                      daily graph

  `Ctrl+PAGE_UP` / `Ctrl+PAGE_DOWN`   Switch among numbered layouts
                                      available in `Setup`

  `Ctrl+;`                            Show or hide the impact summary

  `Ctrl+'` / `Ctrl+"`                 Adjust the hourly graph's vertical
                                      scale factor

  `<` / `>`                           Change the number of joined days

  `(` / `)`                           Change the number of displayed days

  `[` / `]`                           Change the horizontal interval of
                                      the probability graph

  `{` / `}`                           Change the vertical interval of the
                                      probability graph

  `s` / `S`                           Change the sky scenario: all data,
                                      sunny, partly cloudy, or cloudy

  `v` / `V`                           Show or hide raw values on the
                                      hourly graph

  `b` / `B`                           Show or hide probabilities on the
                                      hourly graph

  `n` / `N`                           Show or hide statistics on the
                                      hourly graph

  `m` / `M`                           Show or hide sorted values on the
                                      hourly graph
  -----------------------------------------------------------------------

## Command bar and automation

The command bar is optional. It is useful for setting values precisely,
repeating operations, or running commands from scripts. Press `TAB` to
show or hide it, or click inside the dark command area at the bottom of
the interface.

See the [command reference](command/README.md) for commands covering
project files, object creation and editing, camera and view controls,
dates, palettes, latitude/longitude, numeric controls, and on/off
settings. For example, `day 15` sets the day value through the command
interface.

## The SOLARCHVISION approach

SOLARCHVISION is built around **solar-climatic vision**: rather than
looking only *toward* the sun, look at a building, landscape, or urban
space **from the sun's perspective**. Investigate where solar radiation
reaches the site and its surfaces, when it arrives, and how local
climate and surrounding geometry influence its effects.

This is broader than adding photovoltaic panels or solar collectors to a
completed design. It treats solar exposure, architectural form, the
building skin, outdoor space, urban context, and indoor--outdoor
relationships as connected design considerations.

### Active and passive analysis

-   **Active analysis** examines the amount and distribution of solar
    radiation received by surfaces or spaces, helping reveal
    solar-energy potential.
-   **Passive analysis** examines beneficial and undesirable effects of
    solar exposure on buildings and surrounding spaces over selected
    periods, such as heating, cooling, or the annual cycle.

Together, these perspectives help designers investigate both the
radiation available at a location and whether its effects support the
intended use of a building or outdoor space. The precise studies
available depend on the selected analysis, model, and input data.

### A practical design loop

1.  **Understand the site:** Establish location, orientation,
    topography, surrounding geometry, intended use, and data
    reliability.
2.  **Choose meaningful periods:** Study relevant hours and seasons,
    including heating and cooling periods and locally important extremes
    where suitable data are available.
3.  **Analyze the proposal:** Use available studies to identify
    desirable and undesirable conditions on the building skin and in
    outdoor spaces.
4.  **Develop alternatives:** Test changes to massing, orientation,
    windows, shading, vegetation, and site arrangement where relevant.
5.  **Compare trade-offs:** Check effects across orientations, spaces,
    seasons, and neighboring areas rather than relying on a single
    image.
6.  **Repeat:** Refine the proposal and rerun the study. Use results to
    inform---not replace---architectural judgment and specialist
    calculations.

## Method and publications

The solar-climatic vision approach is discussed in the following
publications:

-   Samimi, Mojtaba. ["Weather Data and Solar
    Orientations."](https://doi.org/10.1007/978-3-319-15030-7_12) In
    *Future City: Architecture for Optimal Living*, edited by Stamatina
    Th. Rassia and Panos M. Pardalos, Springer, 2015, pp. 221--240.
-   Samimi, Mojtaba, and Farshad Nasrollahi. [*Intelligent Design using
    Solar-Climatic Vision: Energy and Comfort Improvement in
    Architecture and Urban Planning using
    SOLARCHVISION*](https://depositonce.tu-berlin.de/items/c091139a-09cf-44c3-99a9-6adf59f7eaf8).
    Young Cities Research Paper Series, Volume 09, 2014.
-   [SOLARCHVISION presentation at
    Ouranos](https://www.dropbox.com/scl/fo/5r66ns7r9j0rezprwa567/ADuKLQ_qQo98gDnlqDQMXVY?dl=0&e=2&preview=SOLARCHVISION_2015_12_09_Ouranos.pdf&rlkey=0x1wzfy5dll3bvx6j9ltw96v6)
-   [BIM6D
    presentation](https://www.dropbox.com/scl/fi/vyfqllzj7hnb3rhvpnwus/BatimentDurable_MojtibaSamimi_20171123.pdf?rlkey=lzpoqyu59vp8wb4qidqtradaw&e=1)

The chapter "Weather Data and Solar Orientations" emphasizes matching
data to the question, comparing orientations over time, understanding
the limits of typical weather years, and checking data provenance and
assumptions. Its historical examples should not be read as a guarantee
that every illustrated capability is available in the current
application.

## Technical overview

For readers interested in the underlying workflow, the application
combines:

-   **Modeling and visualization:** 3D geometry for points, faces,
    solids, groups, polylines, materials, and 1D/2D models; object
    creation and editing; procedural vegetation; and perspective or
    orthographic views.
-   **Solar and environmental analysis:** Solar position, direct and
    diffuse radiation handling, shadow and occlusion calculations,
    surface-level impact visualization, and other environmental fields
    where supported.
-   **Weather and scenario data:** Supported climate, observation, and
    forecast workflows, with data processing and visualization across
    time ranges, years, and scenarios.
-   **Geographic context:** Latitude/longitude positioning, map
    projections and tiles, station locations, zoom levels, and terrain
    visualization.
-   **Projects and exchange:** Structured XML project persistence,
    command entry and scripts, and supported OBJ,
    time-series/date-series OBJ, RAD, SCR, and HTML export workflows.

A typical workflow is:

``` text
Building or Site Model + Geographic Location
                    ↓
          Weather / Climate Data
                    ↓
         Select Time and Scenarios
                    ↓
      Solar / Shade / Environmental Study
                    ↓
       Explore 3D Views and Study Graphs
                    ↓
              Save or Export
```

For exact commands and additional workflows, consult the [command
reference](command/README.md).

## Contribute and follow the project

SOLARCHVISION-BIM is open source. If it is useful to your work:

-   **Star the repository** to help others discover it.
-   **Follow the project** for updates.
-   **Try it and report issues** through the [GitHub
    repository](https://github.com/archmoj/solarchvision_bim).
-   **Explore the code and contribute** improvements, documentation, or
    bug reports.

When reporting an issue, include your operating system, the steps to
reproduce the problem, the relevant dataset or workflow, and any error
message that may help diagnose it.

## License

The source code and documentation are released under the [GNU General
Public License v2](LICENSE.md).
