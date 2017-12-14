# EmissV

## Top-down methods to create vehicular emissions.

Collection of methods for create veicular emissions (by a top-down approach) for air quality models like [WRF-Chem](https://ruc.noaa.gov/wrf/wrf-chem/).

functions:

- vehicles: tool to set-up vehicle
- newGrid: grid set-up based on a NetCDF file
- pointsToGrid: Transform points to a grinded output
- rasterToGrid: Transform a raster into a grinded output
- shapeToGrid: Transform a shape into a grinded output
- streetDist: Distribution by OpenStreetnMap streets
- territory: Subset a raster with a shape (and grid)
- totalEmission: total emissions
- totalVOC: total VOCs emission
- emission:	Emissions to atmospheric models

# to install

```{r eval=F}
install.packages("devtools")
library(devtools)
devtools::install_github("Schuch666/EmissV")
library(EmissV)
```
