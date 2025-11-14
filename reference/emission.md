# Emissions in the format for atmospheric models

Combine area sources and total emissions to model output

## Usage

``` r
emission(
  inventory = NULL,
  grid,
  mm = 1,
  aerosol = FALSE,
  check = TRUE,
  total,
  pol,
  area,
  plot = FALSE,
  verbose = TRUE
)
```

## Format

matrix of emission

## Arguments

- inventory:

  a inventory raster from read

- grid:

  grid information

- mm:

  pollutant molar mass

- aerosol:

  TRUE for aerosols and FALSE (defoult) for gazes

- check:

  TRUE (defoult) to check negative and NA values and replace it for zero

- total:

  list of total emission

- pol:

  pollutant name

- area:

  list of area sources or matrix with a spatial distribution

- plot:

  TRUE for plot the final emissions

- verbose:

  display additional information

## Value

a vector of emissions in MOL / mk2 h for gases and ug / m2 s for
aerosols.

## Note

if Inventory is provided, the firsts tree arguments are not be used by
the function.

Is a good practice use the set_units(fe,your_unity), where fe is your
emission factory and your_unity is usually g/km on your emission factory

the list of area must be in the same order as defined in vehicles and
total emission.

just WRF-Chem is suported by now

## See also

[`totalEmission`](https://atmoschem.github.io/EmissV/reference/totalEmission.md)
and
[`areaSource`](https://atmoschem.github.io/EmissV/reference/areaSource.md)

## Examples

``` r
fleet  <- vehicles(example = TRUE)
#> using a example of vehicles (DETRAN 2016 data and SP vahicle distribution):
#>                              Category   Type Fuel        Use       SP      RJ
#> Light Duty Vehicles Gasohol   LDV_E25    LDV  E25  41 [km/d] 11624342 2712343
#> Light Duty Vehicles Ethanol  LDV_E100    LDV E100  41 [km/d]   874627  204079
#> Light Duty Vehicles Flex        LDV_F    LDV FLEX  41 [km/d]  9845022 2297169
#> Diesel Trucks               TRUCKS_B5 TRUCKS   B5 110 [km/d]   710634  165814
#> Diesel Urban Busses           CBUS_B5    BUS   B5 165 [km/d]   792630  184947
#> Diesel Intercity Busses       MBUS_B5    BUS   B5 165 [km/d]    21865    5101
#> Gasohol Motorcycles          MOTO_E25   MOTO  E25 140 [km/d]  3227921  753180
#> Flex Motorcycles               MOTO_F   MOTO FLEX 140 [km/d]   235056   54846
#>                                  MG      PR      SC
#> Light Duty Vehicles Gasohol 4371228 3036828 2029599
#> Light Duty Vehicles Ethanol  328895  228494  152709
#> Light Duty Vehicles Flex    3702131 2571986 1718932
#> Diesel Trucks                267227  185651  124076
#> Diesel Urban Busses          298061  207072  138392
#> Diesel Intercity Busses        8222    5712    3817
#> Gasohol Motorcycles         1213830  843285  563592
#> Flex Motorcycles              88390   61407   41040

EmissionFactors <- emissionFactor(example = TRUE)
#> using a example emission factor (values calculated from CETESB 2015):
#>                                       CO            PM
#> Light Duty Vehicles Gasohol  1.75 [g/km] 0.0013 [g/km]
#> Light Duty Vehicles Ethanol 10.04 [g/km] 0.0000 [g/km]
#> Light Duty Vehicles Flex     0.39 [g/km] 0.0010 [g/km]
#> Diesel Trucks                0.45 [g/km] 0.0612 [g/km]
#> Diesel Urban Busses          0.77 [g/km] 0.1052 [g/km]
#> Diesel Intercity Busses      1.48 [g/km] 0.1693 [g/km]
#> Gasohol Motorcycles          1.61 [g/km] 0.0000 [g/km]
#> Flex Motorcycles             0.75 [g/km] 0.0000 [g/km]

TOTAL  <- totalEmission(fleet,EmissionFactors,pol = c("CO"),verbose = TRUE)
#> Total of CO : 1676996.43578795 t year-1 

grid   <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
#> Grid information from: /home/runner/work/_temp/Library/EmissV/extdata/wrfinput_d01 
shape  <- raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))
raster <- raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff"))

SP     <- areaSource(shape[22,1],raster,grid,name = "SP")
#> processing SP area ... 
#> fraction of SP area inside the domain = 0.944981686036935
RJ     <- areaSource(shape[17,1],raster,grid,name = "RJ")
#> processing RJ area ... 
#> fraction of RJ area inside the domain = 0.734040064556526

e_CO   <- emission(total = TOTAL,
                   pol = "CO",
                   area = list(SP = SP, RJ = RJ),
                   grid = grid,
                   mm = 28)
#> calculating emissions for CO using molar mass = 28 ...
```
