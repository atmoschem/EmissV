# Distribution of emissions by a georeferenced image

Calculate the spatial distribution by a raster

## Usage

``` r
rasterSource(r, grid, nlevels = "all", conservative = TRUE, verbose = TRUE)
```

## Source

Exemple data is a low resolution cutting from image of persistent lights
of the Defense Meteorological Satellite Program (DMSP)
<https://pt.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program>

Data avaliable
<https://www.nesdis.noaa.gov/current-satellite-missions/currently-flying/defense-meteorological-satellite-program>

## Arguments

- r:

  input raster object

- grid:

  grid object with the grid information

- nlevels:

  number of vertical levels off the emission array

- conservative:

  TRUE (default) to conserve total mass, FALSE to conserve flux

- verbose:

  display additional information

## Value

Returns a matrix

## Details

About the DMSP and example data
<https://en.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program>

## See also

[`gridInfo`](https://atmoschem.github.io/EmissV/reference/gridInfo.md)
and
[`lineSource`](https://atmoschem.github.io/EmissV/reference/lineSource.md)

## Examples

``` r
grid  <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#> Grid information from: /home/runner/work/_temp/Library/EmissV/extdata/wrfinput_d01 
x     <- raster::raster(paste(system.file("extdata", package = "EmissV"),"/dmsp.tiff",sep=""))
test  <- rasterSource(x, grid)
#> Grid output: 99 columns 93 rows
image(test, axe = FALSE, main = "Spatial distribution by Persistent Nocturnal Lights from DMSP")

```
