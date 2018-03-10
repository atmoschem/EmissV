#' Calculate plume rise from Brigs (1975) formulation.
#'
#' @description Return plume rise height
#'
#' @format numeric value in (units) meters
#'
#' @param df data.frame with micrometeorological and source data
#' @param imax number of maximum interations
#' @param errmax maximum error
#' @param verbose display additional information
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' chimney <- matrix(c(1,1,1,1,1,1,1,1,1,1),ncol = 10, byrow = T)
#' chimney<- data.frame(chimney)
#' names(chimney) <- c("z","r","Ve","Te","h","ws","Temp","Ustar","Wstar","L")
#'
#' chimay <- plumeRise(chimney)
#'
#'}

plumeRise <- function(df, imax = 100, errmax = 0.1, verbose = T)
{
  g    <- 9.81      # m / s2

  # source parameters
  Hs   <- df$z      # altura da fonte
  r    <- df$r      # raio da fonte
  Vi   <- df$ve     # velocidade de exaustão
  Ti   <- df$Te     # temperatura de exaustão

  # micrometeorological data
  h    <- df$h      # altura da camada limite planetária
  L    <- abs(df$L) # comp monin-obukov
  U    <- df$ws     # vel média do vento
  Wstar<- df$Wstar  # w*
  Ustar<- df$Ustar  # u*
  Ta   <- df$Temp   # temperatura

  # termo de flutuabilidade
  Flu  <- g * Vi * r^2 * (Ti - Ta)/Ti

  # convecção forte
  if(h/L > 10){
    deltaH <- 4.3 * (Flu / (U * Wstar^2))^(3/5) * h^(2/5)
  }else
  # moderadamente convectivas
  if(h/L <= 10){
    Wd     <- 0.4 * Wstar # downdrafts mean speed
    deltaH <- Flu / U*Wd^2
    for(i in 1:imax){
      old <- deltaH
      deltaH <- ( Flu / U*Wd^2 )^(3/5) * (1 + 2*Hs/deltaH)^2
      err    <- (deltaH - old )/old
      if(err <= errmax)
        i = imax
    }
  }else
  # neutral
  if(h/L <= 1){
    deltaH <- (1.3 * Flu / (U * Ustar^2))^0.6
    for(i in 1:imax){
      old    <- deltaH
      deltaH <- 1.3 * (Flu / (U * Ustar^2)) * (1 + Hs/deltaH)^(2/3)
      err    <- (deltaH - old )/old
      if(err <= errmax)
        i = imax
    }
  }else
  # stable
  if(h/L <=  0.001){
    deltaH <- 0
  }
  # criterio de Weil (1979)
  weil    <- 0.62 * (h - Hs)
  rise    <- min(deltaH,weil)
  df$rise <- rise
  df$He   <- Hs + rise # altura efetiva // nova variavel no df

  return(df)
}
