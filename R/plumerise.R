#' Calculate plume rise from Brigs (1975) formulation.
#'
#' @description Return plume rise height
#'
#' @format numeric value in (units) meters
#'
#' @param df data.frame with micrometeorological and source data
#' @param imax maximum number of iteractions
#' @param ermax maximum error
#' @param Hmax use weil limit for plume rise, see details
#' @param verbose display additional information
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' chimney <- matrix(c(20,0.5,12,400,4,280,100,1,3.6,2.8),ncol = 10, byrow = T)
#' chimney<- data.frame(chimney)
#' names(chimney) <- c("z","r","Ve","Te","ws","Temp","h","L","Ustar","Wstar")
#'
#' chimay <- plumeRise(chimney)
#'
#'}

plumeRise <- function(df, imax = 1000, ermax = 1/100, Hmax = T, verbose = T)
{
  g      <- 9.81      # m / s2
  rise   <- rep(0,nrow(df))
  He     <- rep(0,nrow(df))

  for(j in 1:nrow(df)){
    # source parameters
    Hs   <- df$z[j]      # altura da fonte
    r    <- df$r[j]      # raio da fonte
    Vi   <- df$Ve[j]     # velocidade de exaustão
    Ti   <- df$Te[j]     # temperatura de exaustão

    # micrometeorological data
    U    <- df$ws[j]     # vel média do vento
    Ta   <- df$Temp[j]   # temperatura
    h    <- df$h[j]      # altura da camada limite planetária
    L    <- abs(df$L[j]) # comp monin-obukov
    Wstar<- df$Wstar[j]  # w*
    Ustar<- df$Ustar[j]  # u*

    # termo de flutuabilidade
    Flu  <- g * Vi * r^2 * (Ti - Ta)/Ti

    # convecção forte
    if(h/L > 10){
      if(verbose)
        print(paste("strong convective, h/L =",h/L))
      deltaH <- 4.3 * (Flu / (U * Wstar^2))^(3/5) * h^(2/5)
    }else
      # moderadamente convectivas
      if(h/L <= 10 & h/L > 1){
        if(verbose)
          print(paste("convective, h/L =",h/L))
        Wd     <- 0.4 * Wstar # downdrafts mean speed
        deltaH <- Flu / U*Wd^2
        for(i in 1:imax){
          old <- deltaH
          deltaH <- ( Flu / U*Wd^2 )^(3/5) * (1 + 2*Hs/deltaH)^2
          err    <- (deltaH - old )/old
          if(err <= ermax){
            # print(paste(i,"iterações"))
            i = imax
          }
        }
      }else
        # neutral
        if(h/L <= 1 & h/L > 0.001){
          if(verbose)
            print(paste("neutral, h/L =",h/L))
          deltaH <- (1.3 * Flu / (U * Ustar^2))^0.6
          for(i in 1:imax){
            old    <- deltaH
            deltaH <- 1.3 * (Flu / (U * Ustar^2)) * (1 + Hs/deltaH)^(2/3)
            err    <- (deltaH - old )/old
            if(err <= ermax){
              # print(paste(i,"iterações"))
              i = imax
            }
          }
        }else
          # stable
          if(h/L <=  0.001){
            if(verbose)
              print(paste("stable, h/L =",h/L))
            deltaH <- 0
          }
    # criterio de Weil (1979)
    if(Hmax){
      weil    <- 0.62 * (h - Hs)
      if(verbose)
        print(paste("weil max=",weil))
      rise[j] = min(deltaH,weil)
    }else{
      rise[j] = deltaH
    }
    He[j]   <- rise[j] + Hs
  }
  df <- cbind(df,rise)
  df <- cbind(df,He)
  return(df)
}
