#' Calculate plume rise from Brigs (1975) formulation.
#'
#' @description Return plume rise height
#'
#' @format numeric value in (units) meters
#'
#' @param df data.frame with micrometeorological and source data
#' @param verbose display additional information
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#'
#'}

plumeRise <- function(df, verbose = T)
{
  g    <- 9.81      # m / s2

  # micrometeorological data
  h    <- df$h      # altura da camada limite planetária
  L    <- abs(df$L) # comp monin-obukov
  U    <- df$ws     # vel média do vento
  Wstar<- df$Wstar  # w*
  Ustar<- df$Ustar  # u*
  Ta   <- df$Temp   # temperatura

  # source parameters
  Hs   <- df$z      # altura da fonte
  r    <- df$r      # raio da fonte
  Vi   <- df$ve     # velocidade de exaustão
  Ti   <- df$Te     # temperatura de exaustão
s
  # termo de flutuabilidade
  Flu    <- g * Vi * r^2 * (Ti - Ta)/Ti

  # convecção forte
  if(h/L > 10){
    deltaH <- 4.3 * (Flu / (U * Wstar)) * h^(2/5)
  }
  # moderadamente convectivas
  if(h/L <= 10){
    Wd     <- 0.4 * Wstar # downdrafts mean speed
    deltaH <- ( Flu / U*Wd^2 )^(3/5) * (1 + 2*Hs/deltaH)^2
    # resolver iterativamente
  }
  # neutra
  if(h/L >= 0){
    deltaH <- 1.3 * (Flu / (U * Ustar^2)) * (1 + Hs/DeltaH)^(2/3)
    # resolver iterativamente
  }
  # criterio de Weil (1979)
  weil  <- 0.62 * (h - Hs)
  rise  <- min(deltaH,weil)
  df$He <- Hs + rise # altura efetiva

  return(df)
}
