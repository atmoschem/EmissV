# EmissV
<!-- badges: start -->
[![windown Build](https://ci.appveyor.com/api/projects/status/guuaaklaw6uyn4lj?svg=true)](https://ci.appveyor.com/project/Schuch666/emissv) 
[![Coverage Status](https://img.shields.io/codecov/c/github/atmoschem/EmissV/master.svg)](https://codecov.io/github/atmoschem/EmissV?branch=master) 
[![R build status](https://github.com/atmoschem/EmissV/workflows/R-CMD-check/badge.svg)](https://github.com/atmoschem/EmissV/actions)
[![Licence:MIT](https://img.shields.io/github/license/hyperium/hyper.svg)](https://opensource.org/licenses/MIT) 
[![cran checks](https://badges.cranchecks.info/worst/EmissV.svg)](https://cran.r-project.org/web/checks/check_results_EmissV.html)
[![metacran downloads](https://cranlogs.r-pkg.org/badges/grand-total/EmissV)](https://cran.r-project.org/package=EmissV)
[![metacran downloads](https://cranlogs.r-pkg.org/badges/EmissV)](https://cran.r-project.org/package=EmissV)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1451027.svg)](https://doi.org/10.5281/zenodo.1451027) 
[![status](http://joss.theoj.org/papers/071d027997ac93d8992099cb5010a044/status.svg)](http://joss.theoj.org/papers/071d027997ac93d8992099cb5010a044)
<!-- badges: end -->  

This package provides tools to create emissions (with a focus on vehicular emissions) for use in numeric air quality models such as [WRF-Chem](https://ruc.noaa.gov/wrf/wrf-chem/).

## Installation

### System dependencies 

EmissV import functions from [ncdf4](http://cran.r-project.org/package=ncdf4) for reading model information, [raster](http://cran.r-project.org/package=raster) and [sf](https://cran.r-project.org/web/packages/sf/index.html) to process grinded/geographic information and [units](https://github.com/edzer/units/). These packages need some aditional libraries: 

### To Ubuntu
The following steps are required for installation on Ubuntu:
```bash
  sudo add-apt-repository ppa:ubuntugis/ubuntugis-unstable --yes
  sudo apt-get --yes --force-yes update -qq
  # netcdf dependencies:
  sudo apt-get install --yes libnetcdf-dev netcdf-bin
  # units/udunits2 dependency:
  sudo apt-get install --yes libudunits2-dev
  # sf dependencies (without libudunits2-dev):
  sudo apt-get install --yes libgdal-dev libgeos-dev libproj-dev
```

### To Fedora
The following steps are required for installation on Fedora:
```bash
  sudo dnf update
  # netcdf dependencies:
  sudo yum install netcdf-devel
  # units/udunits2 dependency:
  sudo yum install udunits2-devel
  # sf dependencies (without libudunits2-dev):
  sudo yum install gdal-devel proj-devel proj-epsg proj-nad geos-devel
```

### To Windows
No additional steps for windows installation.

Detailed instructions can be found at [netcdf](https://www.unidata.ucar.edu/software/netcdf/), [libudunits2-dev](https://r-quantities.github.io/units/) and [sf](https://r-spatial.github.io/sf/#installing) developers page.

### To [conda](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html) (miniconda / anaconda)

First create a new environment called rspatial *(or a better name)*:
```bash
  conda create -n rspatial -y
  conda activate rspatial
```

and to install some requisites:
```bash
  conda install -c conda-forge r-sf -y
  conda install -c conda-forge r-rgdal -y
  conda install -c conda-forge r-lwgeom -y
  conda install -c conda-forge r-raster -y
```

### Package installation
To install the *[CRAN](https://cran.r-project.org/package=EmissV) version (0.665.5.2)*:

```r
install.packages("EmissV")
```

To install the *development version (0.665.5.3)* using [remotes](https://CRAN.R-project.org/package=remotes):
```r
require("remotes")
remotes::install_github("atmoschem/EmissV")
```
or to install the *development version (0.665.5.3)* using [devtools](https://CRAN.R-project.org/package=devtools):
```r
require("devtools")
devtools::install_github("atmoschem/EmissV")
```

## Using `EmissV` with EDGAR 5.0 emissions

`EmissV` can be used to process emissions of [atmospheric pollutants](https://en.wikipedia.org/wiki/Air_pollution#Sources) and [green house gases](https://en.wikipedia.org/wiki/Greenhouse_gas) from inventories such as [EDGAR](https://data.europa.eu/doi/10.2904/JRC_DATASET_EDGAR), [RCP](https://tntcat.iiasa.ac.at/RcpDb/dsd?Action=htmlpage&page=welcome#), [GAINS](https://iiasa.ac.at/web/home/research/researchPrograms/air/GAINS.html) and other datasets in [NetCDF](https://www.unidata.ucar.edu/software/netcdf/) format, the [GEIA-ACCENT](http://accent.aero.jussieu.fr/database_table_inventories.php) and [ECCAD](https://eccad3.sedoo.fr/) emission data portal makes available some of these inventories. You can verify the supported format with:

```r
EmissV::read()
```

To generate a simple emission it's a straightforward process in 4 steps:

```r
library(EmissV)
### 1. download the EDGAR Netcdf using R or from 
### http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v50_AP/ 
# create the temporary directory to download the data
dir.create(file.path(tempdir(), "EDGARv432"))
folder <- setwd(file.path(tempdir(), "EDGARv432"))
# download the total emissions of NOx from EDGAR v50_AP for 2015
url <- "http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v432_AP/NOx"
file <- 'v432_NOx_2012.0.1x0.1.zip'
download.file(paste0(url,'/TOTALS/',file), file)
# unzip the file
unzip('v432_NOx_2012.0.1x0.1.zip')

### 2. read the emissions (using the spec argument to split NOx into NO and NO2)
NOx  <- read(file    = dir(pattern = '.nc'),
             version = 'EDGAR',
             spec    = c(E_NO  = 0.9 ,   # 90% of NOx is NO
                         E_NO2 = 0.1 ))  # 10% of NOx is NO2

### 3. get the information from a WRF grid from a initial conditions file (wrfinput)
g   <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))

### 4. calculate the emissions for grid g
NO  <- emission(grid = g, inventory = NOx$E_NO, pol = "NO", mm = 30.01,   plot = T)
NO2 <- emission(grid = g, inventory = NOx$E_NO2,pol = "NO2",mm = 46.0055, plot = T)
```
The next step is to save the emission in a emission file, the next example show how to save emissions using the [eixport](https://github.com/atmoschem/eixport) R-package:

```r
library(eixport)
### create a temporary folder for emissions
dir.create(file.path(tempdir(), "EMISSION"))

### create the emision file
wrf_create(wrfinput_dir = system.file("extdata", package = "EmissV"),
           wrfchemi_dir = file.path(tempdir(), "EMISSION"),
           domains      = 1)
           
### get the file path of the emission file
emis_file <- list.files(path = file.path(tempdir(), "EMISSION"),
                        pattern = "wrfchemi_d01",
                        full.names = TRUE)

### save the emission
wrf_put(NO,  file = emis_file, name = "E_NO",  verbose = TRUE)
wrf_put(NO2, file = emis_file, name = "E_NO2", verbose = TRUE)
```

Check the [wrf_create](https://atmoschem.github.io/eixport/reference/wrf_create.html), [wrf_put](https://atmoschem.github.io/eixport/reference/wrf_put.html) and [to_wrf](https://atmoschem.github.io/eixport/reference/to_wrf.html) to more information and customize for your application.

**NOTE**: The emission file must be compatible with the WRF-Chem options (many arguments are the same as the namelist.input from WRF) check the [eixport](https://atmoschem.github.io/eixport/reference/wrf_create.html) R-Package documentation and the [WRF-Chem manual](https://ruc.noaa.gov/wrf/wrf-chem/Users_guide.pdf) for more information.

Other R-packages are available to write netcdf such as [ncdf4](https://CRAN.R-project.org/package=ncdf4), [RNetCDF](https://CRAN.R-project.org/package=RNetCDF), [tidync](https://CRAN.R-project.org/package=tidync) are available on [CRAN](https://cran.r-project.org/). Other languages such as [NCL leanguage](https://www.ncl.ucar.edu/) and the Python package [wrf-python](https://wrf-python.readthedocs.io/en/latest/), and preprocessor [anthro_emiss](https://www2.acom.ucar.edu/wrf-chem/wrf-chem-tools-community) are aternative to write NetCDF files.

## Using `EmissV` to estimate vehicular emissions

In EmissV the vehicular emissions are estimated by a top-down approach, i.e. the emissions are calculated using the statistical description of the fleet at avaliable level (National, Estadual, City, etc).The following steps show an example workflow for calculating vehicular emissions, these emissions are initially temporally and spatially disaggregated, and then distributed spatially and temporally.

**I.** Total: emission of pollutants is estimated from the fleet, use and emission factors and for the interest area (cities, states, countries, etc).

``` r
library(EmissV)

fleet <- vehicles(example = T)
# using a example of vehicles (DETRAN 2016 data and SP vahicle distribution):
#                              Category   Type Fuel      Use       SP ...
# Light Duty Vehicles Gasohol   LDV_E25    LDV  E25  41 km/d 11624342 ...
# Light Duty Vehicles Ethanol  LDV_E100    LDV E100  41 km/d   874627 ...
# Light Duty Vehicles Flex        LDV_F    LDV FLEX  41 km/d  9845022 ...
# Diesel Trucks               TRUCKS_B5 TRUCKS   B5 110 km/d   710634 ...
# Diesel Urban Busses           CBUS_B5    BUS   B5 165 km/d   792630 ...
# Diesel Intercity Busses       MBUS_B5    BUS   B5 165 km/d    21865 ...
# Gasohol Motorcycles          MOTO_E25   MOTO  E25 140 km/d  3227921 ...
# Flex Motorcycles               MOTO_F   MOTO FLEX 140 km/d   235056 ...

fleet <- fleet[,c(-6,-8,-9)] # dropping RJ, PR and SC

EF     <- emissionFactor(example = T)
# using a example emission factor (values calculated from CETESB 2015):
#                                     CO          PM
# Light duty Vehicles Gasohol  1.75 g/km 0.0013 g/km
# Light Duty Vehicles Ethanol 10.04 g/km 0.0000 g/km
# Light Duty Vehicles Flex     0.39 g/km 0.0010 g/km
# Diesel trucks                0.45 g/km 0.0612 g/km
# Diesel urban busses          0.77 g/km 0.1052 g/km
# Diesel intercity busses      1.48 g/km 0.1693 g/km
# Gasohol motorcycles          1.61 g/km 0.0000 g/km
# Flex motorcycles             0.75 g/km 0.0000 g/km

TOTAL  <- totalEmission(fleet,EF,pol = c("CO"),verbose = T)
# Total of CO : 1128297.0993334 t year-1
```

**II.** Spatial distribution: The package has functions to read information from tables, georeferenced images (tiff), shapefiles (sh), OpenStreet maps (osm), global inventories in NetCDF format (nc) to calculate point, line and area sources.

``` r
raster <- raster::raster(paste(system.file("extdata", package = "EmissV"),
                         "/dmsp.tiff",sep=""))

grid   <- gridInfo(paste(system.file("extdata", package = "EmissV"),
                   "/wrfinput_d02",sep=""))
# Grid information from: .../EmissV/extdata/wrfinput_d02

shape  <- raster::shapefile(paste(system.file("extdata", package = "EmissV"),
                            "/BR.shp",sep=""),verbose = F)[12,1]
Minas_Gerais <- areaSource(shape,raster,grid,name = "Minas Gerais")
# processing Minas Gerais area ...
# fraction of Minas Gerais area inside the domain = 0.0145921494236101

shape  <- raster::shapefile(paste(system.file("extdata", package = "EmissV"),
                            "/BR.shp",sep=""),verbose = F)[22,1]
Sao_Paulo <- areaSource(shape,raster,grid,name = "Sao Paulo")
# processing Sao Paulo area ...
# fraction of Sao Paulo area inside the domain = 0.474658563750987

sp::spplot(raster::merge(drop_units(TOTAL$CO[[1]]) * Sao_Paulo, 
                         drop_units(TOTAL$CO[[2]]) * Minas_Gerais),
           scales = list(draw=TRUE),ylab="Lat",xlab="Lon",
           main=list(label="Emissions of CO [g/d]"),
           col.regions = c("#031638","#001E48","#002756","#003062",
                           "#003A6E","#004579","#005084","#005C8E",
                           "#006897","#0074A1","#0081AA","#008FB3",
                           "#009EBD","#00AFC8","#00C2D6","#00E3F0"))
```
![*Figure 1* - Emissions of CO using nocturnal lights.](https://raw.githubusercontent.com/atmoschem/EmissV/master/CO_all.png)

**III.** Emission calculation: calculate the final emission from all different sources and converts to model units and resolution.
``` r
CO_emissions <- emission(total = TOTAL,
                         pol   = "CO",
                         area  = list(SP = Sao_Paulo, MG = Minas_Gerais),
                         grid  = grid,
                         mm    = 28, 
                         plot  = T)
# calculating emissions for CO using molar mass = 28 ...
```
![*Figure 2* - CO emissions ready for use in air quality model.](https://raw.githubusercontent.com/atmoschem/EmissV/master/CO_final.png)

**IV.** Temporal distribution: the package has a set of hourly profiles that represent the mean activity for each day of the week calculated from traffic counts of toll stations located in São Paulo city.
``` r
data(perfil)
names(perfil)
```

The package has additional functions for read netcdf data, create line and point sources (with plume rise) and to estimate the total emissions of of volatile organic compounds from exhaust (through the exhaust pipe), liquid (carter and evaporative) and  vapor (fuel transfer operations).

Functions:

- [read](https://atmoschem.github.io/EmissV/reference/read.html): read global inventories in netcdf format
- [vehicles](https://atmoschem.github.io/EmissV/reference/vehicles.html): tool to set-up vehicle data.table
- [emissionFactor](https://atmoschem.github.io/EmissV/reference/emissionFactor.html): tool to set-up emission factors data.table
- [gridInfo](https://atmoschem.github.io/EmissV/reference/gridInfo.html): read grid information from a NetCDF file
- [pointSource](https://atmoschem.github.io/EmissV/reference/pointSource.html): emissions from point sources
- [plumeRise](https://atmoschem.github.io/EmissV/reference/plumeRise.html): calculate plume rise
- [rasterSource](https://atmoschem.github.io/EmissV/reference/rasterSource.html): distribution of emissions by a georeferenced image
- [lineSource](https://atmoschem.github.io/EmissV/reference/lineSource.html): distribution of emissions by line vectors
- [areaSource](https://atmoschem.github.io/EmissV/reference/areaSource.html): distribution of emissions by region
- [totalEmission](https://atmoschem.github.io/EmissV/reference/totalEmission.html): total emissions
- [emission](https://atmoschem.github.io/EmissV/reference/emission.html): Emissions to atmospheric models
- [speciation](https://atmoschem.github.io/EmissV/reference/speciation.html): Speciation of emissions in different compounds

Sample datasets:

- [Species](https://atmoschem.github.io/EmissV/reference/species.html): species mapping tables
- [Perfil](https://atmoschem.github.io/EmissV/reference/perfil.html): vehicle counting profile for vehicular activity
- Sample of an image of persistent lights of the Defense Meteorological Satellite Program (DMSP)
- CETESB 2015 emission factors as ```emissionFactor(example=T)```
- DETRAN 2016 data and SP vahicle distribution as ```vehicles(example=T)```
- Shapefiles for Brazil states


### Contributing

Bug reports, suggestions, and code contributions are all welcome. Please see [CONTRIBUTING.md](https://github.com/atmoschem/EmissV/blob/master/CONTRIBUTING.md) for details. Note that this project adopt the [Contributor Code of Conduct](https://github.com/atmoschem/EmissV/blob/master/CONDUCT.md) and by participating in this project you agree to abide by its terms.


### License

EmissV is published under the terms of the [MIT License](https://opensource.org/licenses/MIT). Copyright [(c)](https://raw.githubusercontent.com/atmoschem/emissv/master/LICENSE) 2018 Daniel Schuch.
