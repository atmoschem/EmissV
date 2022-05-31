#' Speciation of emissions in different compounds
#'
#' @description Distribute the total mass of estimated emissions into model species.
#'
#' @param total emissions from totalEmissions
#' @param spec numeric speciation vector of species
#' @param verbose display additional information
#'
#' @return  Return a list with the daily total emission by interest area (cityes, states, countries, etc).
#'
#' @export
#'
#' @seealso \code{\link{species}}
#'
#' @examples
#' veic <- vehicles(example = TRUE)
#' EmissionFactors <- emissionFactor(example = TRUE)
#' TOTAL <- totalEmission(veic,EmissionFactors,pol = "PM")
#' pm_iag <- c(E_PM25I = 0.0509200,
#'             E_PM25J = 0.1527600,
#'             E_ECI   = 0.1196620,
#'             E_ECJ   = 0.0076380,
#'             E_ORGI  = 0.0534660,
#'             E_ORGJ  = 0.2279340,
#'             E_SO4I  = 0.0063784,
#'             E_SO4J  = 0.0405216,
#'             E_NO3J  = 0.0024656,
#'             E_NO3I  = 0.0082544,
#'             E_PM10  = 0.3300000)
#' PM <- speciation(TOTAL,pm_iag)

speciation <- function(total,spec=NULL,verbose = TRUE){

  if(is.null((spec)))
    cat("need to suply a speciation vector") # nocov

  if(is.list(total))
    total <- total[[1]]                      # nocov

  SPEC <- list()
  for(i in 1:length(spec)){
    SPEC[[i]] <- total * spec[i]
  }
  names(SPEC) <- names(spec)

  return(SPEC)
}
