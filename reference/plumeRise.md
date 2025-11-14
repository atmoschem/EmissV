# Calculate plume rise height.

Calculate the maximum height of rise based on Brigs (1975), the height
is calculated using different formulations depending on stability and
wind conditions.

## Usage

``` r
plumeRise(df, imax = 10, ermax = 1/100, Hmax = TRUE, verbose = TRUE)
```

## Format

data.frame with the input, rise (m) and effective higt (m)

## Arguments

- df:

  data.frame with micrometeorological and emission data

- imax:

  maximum number of iteractions

- ermax:

  maximum error

- Hmax:

  use weil limit for plume rise, see details

- verbose:

  display additional information

## Value

a data.frame with effective height of emissions for pointSource function

## Details

The input data.frame must contains the folloging colluns:

\- z: height of the emission (m)

\- r: source raius (m)

\- Ve: emission velocity (m/s)

\- Te: emission temperature (K)

\- ws: wind speed (m/s)

\- Temp: ambient temperature (K)

\- h: height of the Atmospheric Boundary Layer-ABL (m)

\- L: Monin-Obuhkov Lench (m)

\- dtdz: lapse ration of potential temperature, used only for stable ABL
(K/m)

\- Ustar: atriction velocity, used only for neutral ABL (m/s)

\- Wstar: scale of convectie velocity, used only for convective ABL
(m/s)

Addcitionaly some combination of ws, Wstar and Ustar can produce
inacurate results, Weil (1979) propose a geometric limit of 0.62 \* (h -
Hs) for the rise value.

## References

The plume rise formulas are from Brigs (1975):"Brigs, G. A. Plume rise
predictions, Lectures on Air Pollution and Environmental Impact
Analyses. Amer. Meteor. Soc. p. 59-111, 1975." and Arya 1999: "Arya,
S.P., 1999, Air Pollution Meteorology and Dispersion, Oxford University
Press, New York, 310 p."

The limits are from Weil (1979): "WEIL, J.C. Assessmet of plume rise and
dispersion models using LIDAR data, PPSP-MP-24. Prepared by
Environmental Center, Martin Marietta Corporation, for Maryland
Department of Natural Resources. 1979."

The example is data from a chimney of the Candiota thermoelectric
powerplant from Arabage et al (2006) "Arabage, M. C.; Degrazia, G. A.;
Moraes O. L. Simulação euleriana da dispersão local da pluma de poluente
atmosférico de Candiota-RS. Revista Brasileira de Meteorologia, v.21,
n.2, p. 153-160, 2006."

## Examples

``` r
candiota <- matrix(c(150,1,20,420,3.11,273.15 + 3.16,200,-34.86,3.11,0.33,
                     150,1,20,420,3.81,273.15 + 4.69,300,-34.83,3.81,0.40,
                     150,1,20,420,3.23,273.15 + 5.53,400,-24.43,3.23,0.48,
                     150,1,20,420,3.47,273.15 + 6.41,500,-15.15,3.48,0.52,
                     150,1,20,420,3.37,273.15 + 6.35,600, -8.85,3.37,2.30,
                     150,1,20,420,3.69,273.15 + 5.93,800,-10.08,3.69,2.80,
                     150,1,20,420,3.59,273.15 + 6.08,800, -7.23,3.49,1.57,
                     150,1,20,420,4.14,273.15 + 6.53,900,-28.12,4.14,0.97),
                     ncol = 10, byrow = TRUE)
candiota <- data.frame(candiota)
names(candiota) <- c("z","r","Ve","Te","ws","Temp","h","L","Ustar","Wstar")
row.names(candiota) <- c("08:00","09:00",paste(10:15,":00",sep=""))
candiota <- plumeRise(candiota,Hmax = TRUE)
#> convective, h/L = -5.7372346528973 
#> using weil max= 31 
#> convective, h/L = -8.61326442721792 
#> strong convective, h/L = -16.3733115022513 
#> using weil max= 155 
#> strong convective, h/L = -33.003300330033 
#> using weil max= 217 
#> strong convective, h/L = -67.7966101694915 
#> strong convective, h/L = -79.3650793650794 
#> strong convective, h/L = -110.650069156293 
#> strong convective, h/L = -32.0056899004267 
print(candiota)
#>         z r Ve  Te   ws   Temp   h      L Ustar Wstar     rise       He
#> 08:00 150 1 20 420 3.11 276.31 200 -34.86  3.11  0.33  31.0000 181.0000
#> 09:00 150 1 20 420 3.81 277.84 300 -34.83  3.81  0.40  41.5831 191.5831
#> 10:00 150 1 20 420 3.23 278.68 400 -24.43  3.23  0.48 155.0000 305.0000
#> 11:00 150 1 20 420 3.47 279.56 500 -15.15  3.48  0.52 217.0000 367.0000
#> 12:00 150 1 20 420 3.37 279.50 600  -8.85  3.37  2.30 121.4376 271.4376
#> 13:00 150 1 20 420 3.69 279.08 800 -10.08  3.69  2.80 102.0828 252.0828
#> 14:00 150 1 20 420 3.59 279.23 800  -7.23  3.49  1.57 207.6558 357.6558
#> 15:00 150 1 20 420 4.14 279.68 900 -28.12  4.14  0.97 355.4518 505.4518
```
