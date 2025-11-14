# Species mapping tables

Set of tables for speciation:

- voc_radm2_mic:

  Volatile organic compounds for RADM2

- voc_cbmz_mic:

  Volatile organic compounds for CBMZ

- voc_moz_mic:

  Volatile organic compounds for MOZART

- voc_saprc99_mic:

  volatile organic compounds for SAPRC99

- veicularvoc_radm2_iag:

  Vehicular volatile organic compounds for RADM2 (MOL)

- veicularvoc_cbmz_iag:

  Vehicular volatile organic compounds for CBMZ (MOL)

- veicularvoc_moz_iag:

  Vehicular volatile organic compounds for MOZART (MOL)

- veicularvoc_saprc99_iag:

  Vehicular volatile organic compounds for SAPRC99 (MOL)

- pm_madesorgan_iag:

  Particulate matter for made/sorgan

- pm25_madesorgan_iag:

  Fine particulate matter for made/sorgan

- nox_iag:

  Nox split Perez Martínez et al (2014)

- nox_bcom:

  Nox split usin Ntziachristos and Zamaras (2016)

- voc_radm2_edgar432:

  Volatile organic compounds species from EDGAR 4.3.2 for RADM2 (MOL)

- voc_moz_edgar432:

  Volatile organic compounds species from EDGAR 4.3.2 for MOZART (MOL)

\- Volatile organic compounds species map from 1 to 4 are from Li et al
(2014) taken into account several sources of pollutants.

\- Volatile organic compounds from vehicular activity species map 5 to 8
is a by fuel and emission process from USP-IAG tunel experiments (Rafee
et al., 2017) emited by the process of exhaust (through the exhaust
pipe), liquid (carter and evaporative) and vapor (fuel transfer
operations).

\- Particulate matter speciesmap for made/sorgan emissions 9 and 10.

\- Nox split using Perez Martínez et al (2014) data (11).

\- Nox split using mean of Ntziachristos and Zamaras (2016) data (12).

\- Volatile organic compounds species map 13 and 14 are the
corespondence from EDGAR 4.3.2 VOC specialization to RADM2 and MOZART.

## Usage

``` r
data(species)
```

## Format

List of numeric vectors with the 'names()' of the species and the values
of each species.

## Details

iag-voc: After estimating all the emissions of NMHC, it was used the
speciation presented in (RAFEE et al., 2017). This speciation is based
on tunnel measurements in São Paulo, depends on the type of fuel (E25,
E100 and B5) and provides the mass of each chemical compound as mol/g.
This speciation splits the NMHC from evaporative, liquid and exhaust
emissions of E25, E100 and B5, into minimum compounds required for the
Carbon Bond Mechanism (CBMZ) (ZAVERI; PETERS, 1999). Atmospheric
simulations using the same pollutants in Brazil have resulted in good
agreement with observations (ANDRADE et al., 2015).

iag-pm: data tunnel experiments at São Paulo in Perez Martínez et al
(2014)

iag-nox: common NOx split for São Paulo Metropolitan area.

bcom-nox: mean of Ntziachristos and Zamaras (2016) data.

mic: from Li et al (2014).

edgar: Edgar 4.3.2 emissions Crippa et al. (2018).

## Note

The units are mass ratio (mass/mass) or MOL (MOL), this last case do not
change the default 'mm' into 'emission()' function.

## References

Li, M., Zhang, Q., Streets, D. G., He, K. B., Cheng, Y. F., Emmons, L.
K., ... & Su, H. (2014). Mapping Asian anthropogenic emissions of
non-methane volatile organic compounds to multiple chemical mechanisms.
Atmos. Chem. Phys, 14(11), 5617-5638.

Huang, G., Brook, R., Crippa, M., Janssens-Maenhout, G., Schieberle, C.,
Dore, C., ... & Friedrich, R. (2017). Speciation of anthropogenic
emissions of non-methane volatile organic compounds: a global gridded
data set for 1970–2012. Atmospheric Chemistry and Physics, 17(12), 7683.

Abou Rafee, S. A., Martins, L. D., Kawashima, A. B., Almeida, D. S.,
Morais, M. V. B., Souza, R. V. A., Oliveira, M. B. L., Souza, R. A. F.,
Medeiros, A. S. S., Urbina, V., Freitas, E. D., Martin, S. T., and
Martins, J. A.: Contributions of mobile, stationary and biogenic sources
to air pollution in the Amazon rainforest: a numerical study with the
WRF-Chem model, Atmos. Chem. Phys., 17, 7977-7995,
https://doi.org/10.5194/acp-17-7977-2017, 2017.

Martins, L. D., Andrade, M. F. D., Freitas, E., Pretto, A., Gatti, L.
V., Junior, O. M. A., et al. (2006). Emission factors for gas-powered
vehicles traveling through road tunnels in Sao Paulo, Brazil. Environ.
Sci. Technol. 40, 6722–6729. doi: 10.1021/es052441u

Pérez-Martínez, P. J., Miranda, R. M., Nogueira, T., Guardani, M. L.,
Fornaro, A., Ynoue, R., & Andrade, M. F. (2014). Emission factors of air
pollutants from vehicles measured inside road tunnels in São Paulo: case
study comparison. International Journal of Environmental Science and
Technology, 11(8), 2155-2168.

ANDRADE, M. d. F. et al. Air quality forecasting system for southeastern
brazil. Frontiers in Environmental Science, Frontiers, v. 3, p. 1–12,
2015.

Crippa, M., Guizzardi, D., Muntean, M., Schaaf, E., Dentener, F.,
Aardenne, J. A. V., ... & Janssens-Maenhout, G. (2018). Gridded
emissions of air pollutants for the period 1970–2012 within EDGAR
v4.3.2. Earth System Science Data, 10(4), 1987-2013.

## See also

[`speciation`](https://atmoschem.github.io/EmissV/reference/speciation.md)
and [`read`](https://atmoschem.github.io/EmissV/reference/read.md)

## Examples

``` r
# load the mapping tables
data(species)
# names of eath mapping tables
for(i in 1:length(names(species)))
    cat(paste0("specie map ",i," ",names(species)[i],"\n"))
#> specie map 1 voc_radm2_mic
#> specie map 2 voc_cbmz_mic
#> specie map 3 voc_moz_mic
#> specie map 4 voc_saprc99_mic
#> specie map 5 veicularvoc_radm2_iag
#> specie map 6 veicularvoc_cbmz_iag
#> specie map 7 veicularvoc_cb05_iag
#> specie map 8 veicularvoc_moz_iag
#> specie map 9 pm_madesorgan_iag
#> specie map 10 pm25_madesorgan_iag
#> specie map 11 nox_iag
#> specie map 12 nox_bcom
#> specie map 13 voc_radm2_edgar432
#> specie map 14 voc_moze_dgar432
# names of species contained in the (first) mapping table
names(species[[1]])
#>  [1] "E_ALD"    "E_KET"    "E_TOL"    "E_XYL"    "E_OLT"    "E_OLI"   
#>  [7] "E_OL2"    "E_HCHO"   "E_ETH"    "E_CH3OH"  "E_C2H5OH" "E_HC3"   
#> [13] "E_HC5"   
# The first mapping table / species and values
species[1]
#> $voc_radm2_mic
#>       E_ALD       E_KET       E_TOL       E_XYL       E_OLT       E_OLI 
#> 0.014285714 0.011038961 0.102272727 0.102272727 0.024675325 0.024675325 
#>       E_OL2      E_HCHO       E_ETH     E_CH3OH    E_C2H5OH       E_HC3 
#> 0.047402597 0.007142857 0.050649351 0.002597403 0.035064935 0.074025974 
#>       E_HC5 
#> 0.503896104 
#> 
```
