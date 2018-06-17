#' Calculate total emissions
#'
#'@description Caculate the total emission with:
#'
#'   Emission(pollutant) = sum( Vehicles(n) * Km_day_use(n) * Emission_Factor(n,pollutant) )
#'
#' where n is the type of the veicle
#'
#'@format Return a list with the daily total emission by interest area (cityes, states, countries, etc).
#'
#'@param v dataframe with the vehicle data
#'@param ef emission factor
#'@param pol pollutant name in ef
#'@param verbose display additional information
#'
#'@note the units (set_units("value",unit) where the recomended unit is g/d) must be used to make the ef data.frame
#'
#'@seealso \code{\link{rasterSource}}, \code{\link{lineSource}} and \code{\link{emission}}
#'
#'@export
#'
#'@import units
#'
#'@examples
#' veic <- vehicles(example = TRUE)
#'
#' EmissionFactors <- emissionFactor(example = TRUE)
#'
#' TOTAL <- totalEmission(veic,EmissionFactors,pol = c("CO","PM"))

totalEmission <- function(v,ef,pol,verbose = T){

  TOTAL_veic <- as.matrix(v[5:ncol(v)])
  use        <- v$Use
  ef_names   <- names(ef)

  for(i in 1:length(pol)){
    if(!is.element(pol[i], ef_names)){
      cat(paste0(pol[i]," not found in emission factor!\n"))
      cat("The emissions factors contains:\n")
      cat(paste0(ef_names,"\n"))
      total = units::set_units(0,"g/d")
      assign(pol[i],total)
    }
    else{
      fe_p       <- ef[,pol[i]]

      total =  TOTAL_veic[1,] * use[1] * fe_p[1]
      if(nrow(v) >= 2){
        for(j in 2:nrow(v)){
          total   = total + TOTAL_veic[j,] * use[j] * fe_p[j]
        }
      }

      if(verbose){
        # if (utils::packageVersion("units") <= "0.5-1")
        #   units::install_conversion_constant("g/d", "t/year", 365/1000000 )
        total_t_y <- units::set_units(total,"t/year")
        cat(paste("Total of",pol[i],":",sum(total_t_y),units::deparse_unit(total_t_y),"\n"))
      }
      assign(pol[i],total)
    }
  }
  TOTAL <- mget(pol)

  return(TOTAL)
}
