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

plumeRise <- function(df, imax = 1000, ermax = 1/1000, Hmax = T, verbose = T)
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
        a      <- ( Flu / U*Wd^2 )^(3/5)
        b      <- 2 * Hs
        x      <- Hs / 2
        i      <- 1
        err    <- Inf
        while(err > ermax & i <= imax){
          i      <- i + 1
          f      <- x^3 - a*(x^2) -2*a*b*x -a*(b^2)
          fl     <- 3*(x^2) -2*a*x -2*a*b
          old    <- x
          deltaH <- x - (f/fl)
          err    <- abs( (deltaH - old )/old )
          x      <- deltaH
          if(verbose){
            print(paste("Dh old=",old))
            print(paste("err=",err))
            print("=====================================================")
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
# !     ******************* PLUME RISE **********************
#
#   !      SUBROUTINE PRISE(L,Q,QEFF,ALT,WE,UR,AFOE,HF,AFO,DH,US,NE,NR,FBE,FB,ES,pkr,tss,tff,d,vs)
# SUBROUTINE PRISE(L,Q,QEFF,ALT,WE,UR,AFOE,AFO,DH,US,FBE,FB,ES,tss,tff,d,vs)
# IMPLICIT REAL*8 (A-Z)
# REAL*8 USTAR,ELLE,WSTAR,HMX,ES,tff,tss,d,vs	  !hf,
# REAL*8 HS,US,TS,AFO,FB,GRADT,DH,ESSE,QEFF,FBE !,AA,AJ,AL,GU,PU
# !INTEGER NE,NR,pkr
#
# d=9.
# FB=9.81*((D/2.)**2.)*VS*((Tss-Tff)/Tss)
# FBE=FB/(US*ALT*(WE**2.))
# !      FBE=FB/(US*ALT*(WE**2.))
# USTAR=UR
# WSTAR=WE
# HMX=ALT
# TS=300.
# !	ts=tff  !ts(temperatura ambiente),gradt(grad de temperatura)
# GRADT=0.01
# HS=AFO
# ELLE=L
# DHCONV1=10000.
# DHCONV2=10000.
# DHSTAB1=10000.
# DHSTAB2=10000.
# !     **************** NEUTRAL  CONDITIONS ****************
#   A=(1.3*(FB/(US*USTAR**2)))**0.6
# DHNEUT=HS
# 10 DHPRV=DHNEUT
# ZCALC=HS+DHNEUT
# DHNEUT=A*ZCALC**0.4
# IF (ABS(DHNEUT-DHPRV).GT.0.01*DHPRV) GOTO 10
# !     *************** CONVECTIVE CONDITIONS ***************
#   IF (ELLE.LT.0.) THEN
# !     ******************* BREAKUP MODEL *******************
#   DHCONV1=4.3*((FB/(US*WSTAR**2.))**0.6)*HMX**0.4
# !     ****************** TOUCHDOWN MODEL ******************
#   B=(FB/(US*0.16*WSTAR**2.)**0.33333)
# DHCONV2=HS
# 47 DHCPRV=DHCONV2
# YCALC=2.*HS+DHCONV2
# DHCONV2=B*YCALC**0.66666
# IF(ABS(DHCONV2-DHCPRV).GT.0.01*DHCPRV) GOTO 47
# IF(HS+DHCONV1.GT.HMX) DHCONV1=10000.
# IF(HS+DHCONV2.GT.HMX) DHCONV2=10000.
# !     ****************** STABLE CONDITIONS ****************
#   ELSE
# ESSE=(9.81/TS)*(GRADT+0.01)
# DHSTAB1=2.6*(FB/(US*ESSE))**0.3333
# DHSTAB2=5.*FB**(1./4.)/ESSE**(3./8.)
# ENDIF
# DH=MIN(DHNEUT,DHCONV1,DHCONV2,DHSTAB1,DHSTAB2)
# QEFF=Q
# !     ***************** PLUME PENETRATION *****************
#   IF(DH.GE.(0.62*(HMX-HS))) THEN
# DHT1=MIN(DHCONV1,DHCONV2,DHNEUT)
# HMX1=HMX-HS
# GRADT=0.01
# ESSE=(9.81/TS)*(GRADT+0.01)
# DHI=4.*FB**(1./4.)*ESSE**(-3./8.)
# A1=MAX(0.1,DHI)
# P=(HMX-HS)/A1
# IF (P.GE.1.5) PEN=0.
# IF (P.LE.0.5) PEN=1.
# IF (P.GT.0.5.AND.P.LT.1.5) PEN=1.5-HMX1/DHI
# IF (PEN.EQ.1) THEN
# QEFF=0.1
# DH=HMX1
# ELSE IF (PEN.EQ.0)THEN
# QEFF=Q
# DH=MIN(DHT1,0.62*HMX1)
# ELSE IF(PEN.GT.0.AND.PEN.LT.1.)THEN
# IF(DHT1.GE.(0.62*HMX1))THEN
# QEFF=Q*(1-PEN)
# DH=(0.62+0.38*PEN)*(HMX-HS)
# ELSE
# QEFF=Q
# DH=DHT1
# ENDIF
# ENDIF
# ENDIF
# IF(PEN.NE.0.) THEN
# ES=Q-QEFF
# ENDIF
# AFOE=AFO + DH
# RETURN
# END
