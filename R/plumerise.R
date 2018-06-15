#' Calculate plume rise height.
#'
#' @description Calculate the maximum height of rise based on Brigs (1975), the height is calculated using different formulations depending on stability and wind conditions.
#'
#' @format data.frame with the input, rise (m) and effective higt (m)
#'
#' @param df data.frame with micrometeorological and emission data
#' @param imax maximum number of iteractions
#' @param ermax maximum error
#' @param Hmax use weil limit for plume rise, see details
#' @param verbose display additional information
#'
#' @export
#'
#' @references The plume rise formulas are from Brigs (1975):"Brigs, G. A. Plume rise predictions, Lectures on Air Pollution and Environmental Impact Analyses. Amer. Meteor. Soc. p. 59-111, 1975." and Arya 1999: "Arya, S.P., 1999, Air Pollution Meteorology and Dispersion, Oxford University Press, New York, 310 p."
#'
#' The limits are from Weil (1979): "WEIL, J.C. Assessmet of plume rise and dispersion models using LIDAR data, PPSP-MP-24. Prepared by Environmental Center, Martin Marietta Corporation, for Maryland Department of Natural Resources. 1979."
#'
#' The example is data from a chimney of the Candiota thermoelectric powerplant from Arabage et al (2006) "Arabage, M. C.; Degrazia, G. A.; Moraes O. L. Simulação euleriana da dispersão local da pluma de poluente atmosférico de Candiota-RS. Revista Brasileira de Meteorologia, v.21, n.2, p. 153-160, 2006."
#'
#' @details The input data.frame must contains the folloging colluns:
#'
#' - z: height of the emission (m)
#'
#' - r: source raius (m)
#'
#' - Ve: emission velocity (m/s)
#'
#' - Te: emission temperature (K)
#'
#' - ws: wind speed (m/s)
#'
#' - Temp: ambient temperature (K)
#'
#' - h: height of the Atmospheric Boundary Layer-ABL (m)
#'
#' - L: Monin-Obuhkov Lench (m)
#'
#' - dtdz: lapse ration of potential temperature, used only for stable ABL (K/m)
#'
#' - Ustar: atriction velocity, used only for neutral ABL (m/s)
#'
#' - Wstar: scale of convectie velocity, used only for convective ABL (m/s)
#'
#' Addcitionaly some combination of ws, Wstar and Ustar can produce inacurate results, Weil (1979) propose a geometric limit of 0.62 * (h - Hs) for the rise value.
#'
#' @examples
#' candiota <- matrix(c(150,1,20,420,3.11,273.15 + 3.16,200,-34.86,3.11,0.33,
#'                      150,1,20,420,3.81,273.15 + 4.69,300,-34.83,3.81,0.40,
#'                      150,1,20,420,3.23,273.15 + 5.53,400,-24.43,3.23,0.48,
#'                      150,1,20,420,3.47,273.15 + 6.41,500,-15.15,3.48,0.52,
#'                      150,1,20,420,3.37,273.15 + 6.35,600, -8.85,3.37,2.30,
#'                      150,1,20,420,3.69,273.15 + 5.93,800,-10.08,3.69,2.80,
#'                      150,1,20,420,3.59,273.15 + 6.08,800, -7.23,3.49,1.57,
#'                      150,1,20,420,4.14,273.15 + 6.53,900,-28.12,4.14,0.97),
#'                      ncol = 10, byrow = TRUE)
#' candiota <- data.frame(candiota)
#' names(candiota) <- c("z","r","Ve","Te","ws","Temp","h","L","Ustar","Wstar")
#' row.names(candiota) <- c("08:00","09:00",paste(10:15,":00",sep=""))
#' candiota <- plumeRise(candiota,Hmax = TRUE)
#' print(candiota)
#'

plumeRise <- function(df, imax = 10, ermax = 1/100, Hmax = T, verbose = T)
{
  if(imax < 2) imax = 2
  g      <- 9.81      # m / s2
  rise   <- rep(0,nrow(df))
  He     <- rep(0,nrow(df))

  for(j in 1:nrow(df)){
    # source parameters
    Hs   <- df$z[j]      # source height
    r    <- df$r[j]      # source radius
    Vi   <- df$Ve[j]     # exhaust velocity
    Ti   <- df$Te[j]     # exhaust temperature

    # micrometeorological data
    U    <- df$ws[j]     # mean wind speed
    Ta   <- df$Temp[j]   # temperature
    h    <- df$h[j]      # atmospheric boundary layer height
    L    <- df$L[j]      # monin-obukov length

    # boyance term
    Flu  <- g * Vi * r^2 * abs(Ti - Ta)/Ti
    i    <- 1

    # strong convection
    if(h/abs(L) > 10 & L < 0){
      if(verbose)
        print(paste("strong convective, h/L =",h/L))
      Wstar<- df$Wstar[j]  # w*
      deltaH <- 4.3 * (Flu / (U * Wstar^2))^(3/5) * h^(2/5)
    }else
      # slytly convective
      if(h/abs(L) <= 10 & h/abs(L) > 1 & L < 0){
        if(verbose)
          print(paste("convective, h/L =",h/L))
        Wstar<- df$Wstar[j]   # w*
        Wd     <- 0.4 * Wstar # downdrafts mean speed
        a      <- ( Flu / U*Wd^2 )^(3/5)
        b      <- 2 * Hs
        x      <- Hs / 2
        err    <- Inf
        while(err > ermax & i < imax){
          i      <- i+1
          f      <- x^3 - a*(x^2) -2*a*b*x -a*(b^2)
          fl     <- 3*(x^2) -2*a*x -2*a*b
          old    <- x
          deltaH <- x - (f/fl)
          err    <- abs( (deltaH - old )/old )
          x      <- deltaH
          # if(verbose){
          #   print(paste("Dh old=",old))
          #   print(paste("err=",err))
          #   print("=====================================================")
          # }
        }
      }else
        # neutral
        if(abs(h/L) <= 1.0 & abs(h/L) >= 0.0){ #  & L < 0.0
          if(verbose)
            print(paste("neutral, h/L =",h/L))
          Ustar<- df$Ustar[j]  # u*
          a   <- ((1.3 * Flu) /(U * Ustar))^(3)
          x   <- Hs / 4
          err <- Inf
          while(err > ermax & i< imax){
            i      <- i+1
            f      <- x^5 -a*x^2 -2*a*x*Hs -2*a*Hs^2
            fl     <- 5*x^4 -2*a*x -2*a*Hs
            old    <- x
            deltaH <- x - (f/fl)
            err    <- abs( (deltaH - old )/old )
            x      <- deltaH
            # if(verbose){
            #   print(paste("Dh old=",old))
            #   print(paste("err=",err))
            #   print("=====================================================")
            # }
          }
        }else
          # stable
          if(h/L > 1.0){
            dtdz <- df$dtdz[j]   # temperature vertical gradient
            s <- (g/Ta) * dtdz
            if(U <= 1){
              if(verbose)
                print(paste("stable, h/L =",h/L,"- calm,","U=",U,"m/s"))
              deltaH <- 5 * Flu^(1/4) * s^(3/5)
            }else{
              if(verbose)
                print(paste("stable, h/L =",h/L,"- windy,","U=",U,"m/s"))
              deltaH <- 2.6 * (Flu/(U*s))^(1/3)
            }
          }
    if(i == imax)
      print("* max iterations reached!")
    # Weil (1979) limit for plume rises
    if(Hmax){
      weil    <- 0.62 * (h - Hs)
      rise[j] = min(deltaH,weil)
      if(verbose & weil < deltaH)
        print(paste("using weil max=",weil))
    }else{
      rise[j] = deltaH
    }
    He[j]   <- rise[j] + Hs
  }
  df <- cbind(df,rise)
  df <- cbind(df,He)
  return(df)
}
