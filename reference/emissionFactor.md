# Tool to set-up emission factors

Return a data frame for emission for multiple pollutants.

## Usage

``` r
emissionFactor(
  ef,
  poluttant = names(ef),
  vnames = NA,
  unit = "g/km",
  example = FALSE,
  verbose = TRUE
)
```

## Arguments

- ef:

  list with emission factors

- poluttant:

  poluttant names

- vnames:

  name of each vehicle categoy (optional)

- unit:

  tring with unit from unit package, for default is "g/km"

- example:

  TRUE to diaplay a simple example

- verbose:

  display additional information

## Value

a emission factor data frame

a emission factor data.frame for totalEmission function

## See also

[`areaSource`](https://atmoschem.github.io/EmissV/reference/areaSource.md)
and
[`totalEmission`](https://atmoschem.github.io/EmissV/reference/totalEmission.md)

## Examples

``` r
EF <- emissionFactor(example = TRUE)
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

# or the code for the same result
EF <- emissionFactor(ef = list(CO = c(1.75,10.04,0.39,0.45,0.77,1.48,1.61,0.75),
                               PM = c(0.0013,0.0,0.0010,0.0612,0.1052,0.1693,0.0,0.0)),
                     vnames = c("Light Duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
                                "Light Duty Vehicles Flex","Diesel Trucks","Diesel Urban Busses",
                                "Diesel Intercity Busses","Gasohol Motorcycles",
                                "Flex Motorcycles"))
#> Emission factors:
#>                                       CO            PM
#> Light Duty Vehicles Gasohol  1.75 [g/km] 0.0013 [g/km]
#> Light Duty Vehicles Ethanol 10.04 [g/km] 0.0000 [g/km]
#> Light Duty Vehicles Flex     0.39 [g/km] 0.0010 [g/km]
#> Diesel Trucks                0.45 [g/km] 0.0612 [g/km]
#> Diesel Urban Busses          0.77 [g/km] 0.1052 [g/km]
#> Diesel Intercity Busses      1.48 [g/km] 0.1693 [g/km]
#> Gasohol Motorcycles          1.61 [g/km] 0.0000 [g/km]
#> Flex Motorcycles             0.75 [g/km] 0.0000 [g/km]
```
