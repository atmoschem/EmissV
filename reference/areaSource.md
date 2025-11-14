# Distribution of emissions by area

Calculate the spatial distribution by a raster masked by shape/model
grid information.

## Usage

``` r
areaSource(s, r, grid = NA, name = "", as_frac = FALSE, verbose = TRUE)
```

## Source

Data avaliable
<https://www.nesdis.noaa.gov/current-satellite-missions/currently-flying/defense-meteorological-satellite-program>

## Arguments

- s:

  input shape object

- r:

  input raster object

- grid:

  grid with the output format

- name:

  area name

- as_frac:

  return a fraction instead of the raster value

- verbose:

  display additional data

## Value

a raster object containing the spatial distribution of emissions

## Details

About the DMSP and example data
<https://en.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program>

## Examples

``` r
shape  <- raster::shapefile(paste(system.file("extdata", package = "EmissV"),
                            "/BR.shp",sep=""),verbose = FALSE)
shape  <- shape[22,1] # subset for Sao Paulo - BR
raster <- raster::raster(paste(system.file("extdata", package = "EmissV"),
                         "/dmsp.tiff",sep=""))
grid   <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#> Grid information from: /home/runner/work/_temp/Library/EmissV/extdata/wrfinput_d02 
SP     <- areaSource(shape,raster,grid,name = "SPMA")
#> processing SPMA area ... 
#> fraction of SPMA area inside the domain = 0.473725382341265
# \donttest{
raster::plot(SP,ylab="Lat",xlab="Lon",
             main ="Spatial Distribution by Lights for Sao Paulo - Brazil")

# }
```
