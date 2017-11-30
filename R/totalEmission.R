#' Calculate total emissions by territory (city, state, country, etc) by pollutant
#'
#' @description caculate the total emission with:
#'
#'   Emission = sum( No_vehicles(n) * Km_day_use(n) * Emission_Factory(n,pollutant) (*Deterioration_Factors(n)) )
#'
#' where n is the type of the veicle
#'
#' @format Return the total emission (or a list) with the total emission (by day)
#'
#' @param v dataframe with the vehicle data
#' @param ef emission factors
#' @param pol pollutant name in ef
#' @param verbose display adicional information
#'
#' @note its works with some wrf files (inicial condictions and emission) for now.
#'
#' @seealso \code{\link{territory}}
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' # FAZER !!
#'
#'}

totalEmission <- function(v,ef,pol = "CO",df=NA,verbose = T){

  if(!is.na(df)){
    ef <- ef * fd
  }

  v  <- 1:5
  ef <- 1:5

  total <- sum( v * v$int * ef )

  if(verbose)
    print(paste("Total of",pol,":",total))
  return(total)
}
#

# TOTAL_EMIS <- list(
#
#   CO =  veh[1, 5:9] * veh$int[1] * weighted.mean( FE$leves_g[,4] , as.numeric( FROTA[1,10:43] ))
#   + veh[2, 5:9] * veh$int[2] * weighted.mean( FE$leves_e[,4] , as.numeric( FROTA[2,10:34] ))
#   + veh[3, 5:9] * veh$int[3] * weighted.mean( FE$leves_fg[,4], as.numeric( FROTA[3,31:43] )) * g_flex_leves
#   + veh[3, 5:9] * veh$int[3] * weighted.mean( FE$leves_fe[,4], as.numeric( FROTA[3,31:43] )) * (1 - g_flex_leves)
#   + veh[4, 5:9] * veh$int[4] * weighted.mean( agrup(unlist(FE$trucks[5])) , as.numeric( FROTA[18,27:43] ))
#   + veh[5, 5:9] * veh$int[5] * weighted.mean( agrup(unlist(FE$onibus_r[,5])), as.numeric( FROTA[13,27:43] ))
#   + veh[6, 5:9] * veh$int[6] * weighted.mean( agrup(unlist(FE$onibus_u[,5])), as.numeric( FROTA[14,27:43] ))
#   + veh[7, 5:9] * veh$int[7] * weighted.mean( FE$moto_g[,5], as.numeric( FROTA[16,31:43] ))
#   + veh[8, 5:9] * veh$int[8] * weighted.mean( FE$moto_fg[,5],  as.numeric( FROTA[17,38:43] )) * g_flex_motos
#   + veh[8, 5:9] * veh$int[8] * weighted.mean( FE$moto_fe[,5],  as.numeric( FROTA[17,38:43] )) * (1 - g_flex_motos),
#
#   HC =  veh[1, 5:9] * veh$int[1] * weighted.mean( FE$leves_g[,5] , as.numeric( FROTA[1,10:43] ))
#   + veh[2, 5:9] * veh$int[2] * weighted.mean( FE$leves_e[,5] , as.numeric( FROTA[2,10:34] ))
#   + veh[3, 5:9] * veh$int[3] * weighted.mean( FE$leves_fg[,5], as.numeric( FROTA[3,31:43] )) * g_flex_leves
#   + veh[3, 5:9] * veh$int[3] * weighted.mean( FE$leves_fe[,5], as.numeric( FROTA[3,31:43] )) * (1 - g_flex_leves)
#   + veh[4, 5:9] * veh$int[4] * weighted.mean( agrup(unlist(FE$trucks[6])), as.numeric( FROTA[18,27:43] ))
#   + veh[5, 5:9] * veh$int[5] * weighted.mean( agrup(unlist(FE$onibus_r[,6])), as.numeric( FROTA[13,27:43] ))
#   + veh[6, 5:9] * veh$int[6] * weighted.mean( agrup(unlist(FE$onibus_u[,6])), as.numeric( FROTA[14,27:43] ))
#   + veh[7, 5:9] * veh$int[7] * weighted.mean( FE$moto_g[,6], as.numeric( FROTA[16,31:43] ))
#   + veh[8, 5:9] * veh$int[8] * weighted.mean( FE$moto_fg[,6],  as.numeric( FROTA[17,38:43] )) * g_flex_motos
#   + veh[8, 5:9] * veh$int[8] * weighted.mean( FE$moto_fe[,6],  as.numeric( FROTA[17,38:43] )) * (1 - g_flex_motos))
