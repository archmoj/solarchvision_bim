solarchvision_LAYER LAYER_ceilingsky = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "m",
  "Ceiling height",
  "Hauteur sous plafond",
  ""
);

solarchvision_LAYER LAYER_cloudcover = new solarchvision_LAYER(
  10.0,
  0,
  0,
  "tenth",
  "Total Cloud Cover",
  "Couvert nuageux total",
  "TCDC"
);

solarchvision_LAYER LAYER_winddir = new solarchvision_LAYER(
  100.0 / 360.0,
  0,
  0,
  "°",
  "Surface Wind Direction",
  "Direction du vent à la surface",
  "WDIR-SFC"
);

solarchvision_LAYER LAYER_windspd = new solarchvision_LAYER(
  2.5,
  0,
  0,
  "km/h",
  "Surface Wind Speed",
  "Vitesse du vent à la surface",
  "WIND-SFC"
);

solarchvision_LAYER LAYER_pressure = new solarchvision_LAYER(
  2.0,
  -1000,
  1,
  "hPa",
  "Mean Sea level Pressure",
  "Pression moyenne au niveau de la mer",
  "MSLP"
);

solarchvision_LAYER LAYER_drybulb = new solarchvision_LAYER(
  2.5,
  0,
  1,
  "°C",
  "Surface Air Temperature",
  "Température de l'air à la surface",
  "TMP-SFC"
);

solarchvision_LAYER LAYER_relhum = new solarchvision_LAYER(
  1.0,
  0,
  0,
  "%",
  "Surface Relative Humidity",
  "Humidité relative à la surface",
  "RELH-SFC"
);

solarchvision_LAYER LAYER_dirnorrad = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Direct normal radiation",
  "Rayonnement direct normal",
  ""
);

solarchvision_LAYER LAYER_difhorrad = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Diffuse horizontal radiation",
  "Diffus rayonnement horizontal",
  ""
);

solarchvision_LAYER LAYER_glohorrad = new solarchvision_LAYER(
  0.1,
  0,
  0,
  "W/m²",
  "Global horizontal radiation",
  "Rayonnement global horizontal",
  ""
);

solarchvision_LAYER LAYER_direffect = new solarchvision_LAYER(
  0.0025,
  0,
  1,
  "W°C/m²",
  "Direct normal effect <18°C<",
  "Effet direct normal <18°C<",
  ""
);

solarchvision_LAYER LAYER_difeffect = new solarchvision_LAYER(
  0.0025,
  0,
  1,
  "W°C/m²",
  "Diffuse normal effect <18°C<",
  "Effet diffus normal <18°C<",
  ""
);

solarchvision_LAYER LAYER_precipitation = new solarchvision_LAYER(
  4.0,
  0,
  0,
  "mm",
  "Surface Accumulated Precipitation",
  "Précipitations accumulées à la surface",
  "APCP-SFC"
);

solarchvision_LAYER LAYER_developed = new solarchvision_LAYER(
  1,
  0,
  0,
  "",
  "",
  "",
  ""
);

solarchvision_LAYER[] allLayers = {
  LAYER_ceilingsky,
  LAYER_cloudcover,
  LAYER_winddir,
  LAYER_windspd,
  LAYER_pressure,
  LAYER_drybulb,
  LAYER_relhum,
  LAYER_dirnorrad,
  LAYER_difhorrad,
  LAYER_glohorrad,
  LAYER_direffect,
  LAYER_difeffect,
  LAYER_precipitation,
  LAYER_developed
};

int DevelopLayer_id = 0;
int CurrentLayer_id = 0;
String CurrentLayer_unit = allLayers[0].unit;
String CurrentLayer_name = allLayers[0].name;
String[] CurrentLayer_descriptions = {
  allLayers[0].descriptions[Language_EN],
  allLayers[0].descriptions[Language_FR]
};

void changeCurrentLayerTo (int new_id) {

  STUDY.V_scale = allLayers[new_id].V_scale;
  STUDY.V_offset = allLayers[new_id].V_offset;
  STUDY.V_belowLine = allLayers[new_id].V_belowLine;

  DevelopLayer_id = new_id;
  CurrentLayer_id = new_id;

  CurrentLayer_unit = allLayers[new_id].unit;
  CurrentLayer_name = allLayers[new_id].name;
  CurrentLayer_descriptions[Language_EN] = allLayers[new_id].descriptions[Language_EN];
  CurrentLayer_descriptions[Language_FR] = allLayers[new_id].descriptions[Language_FR];

}
