# EmissV

## Top-down methods to create vehicular emissions.

Collection of methods for create veicular emissions to air quality models like [WRF-Chem](https://ruc.noaa.gov/wrf/wrf-chem/).

functions:

- emission:	Emissions to atmospheric models
- newGrid: Create a grid set-up based on a NetCDF file
- rasterToGrid: Transform a raster into a grinded outpu
- shapeToGrid: Transform a shape into a grinded output
- territory: Process georeferenced and geopolitical information
- totalEmission: total emissions by territory
- vehicles: tool to define vehicle information
- voc: total VOCs emission

# to install

```{r eval=F}
install.packages("devtools")
library(devtools)
devtools::install_github("Schuch666/EmissV")
library(EmissV)
```
