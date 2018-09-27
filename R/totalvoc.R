#' Calculate Total VOCs emissions
#'
#'@description Calculate Volatile Organic Compounds (COVs) emited by the process of exhaust (through the exhaust pipe), liquid (carter and evaporative) and vapor (fuel transfer operations).
#'
#'  Avaliable COVs are: eth, hc3, hc5, hc8, ol2, olt, oli, iso, tol, xyl, ket, ch3oh and ald
#'
#'@format Return a list with the daily total emission by territory.
#'
#'@param v data frame with the vehicle data
#'@param ef emission factors
#'@param pol pollutant name in ef
#'@param verbose display additional information
#'
#'@note The same ef can be used to totalEmission and voc
#'
#'@seealso \code{\link{totalEmission}} and \code{\link{vehicles}}
#'
#'@export
#'
#'@import units
#'
#'@examples
#' veic <- vehicles(example = TRUE)
#'
#' COV = c("eth","hc3","hc5","hc8","ol2","olt","oli","iso","tol","xyl","ket","ch3oh","ald")
#' EF_COV <- as.data.frame(matrix(NA,ncol = 9,nrow = 8,byrow = TRUE),
#'                         row.names = row.names(veic))
#' names(EF_COV) <-  c("vap_g","vap_e","vap_d",
#'                     "liq_g","liq_e","liq_d",
#'                     "exa_g","exa_e","exa_d")
#'
#' EF_COV["vap_g"]  <- c(0.230,0.00,0.120,0.00,0.00,0.00,0.00,0.00)
#' EF_COV["vap_e"]  <- c(0.000,0.25,0.120,0.00,0.00,0.00,0.00,0.00)
#' EF_COV["vap_d"]  <- c(0.000,0.00,0.000,0.00,0.00,0.00,0.00,0.00)
#' EF_COV["liq_g"]  <- c(2.000,0.00,0.875,0.00,0.00,0.00,1.20,0.00)
#' EF_COV["liq_e"]  <- c(0.000,1.50,0.875,0.00,0.00,0.00,0.00,1.20)
#' EF_COV["liq_d"]  <- c(0.000,0.00,0.000,0.00,0.00,0.00,0.00,0.00)
#' EF_COV["exa_g"]  <- c(0.425,0.00,0.217,0.00,0.00,0.00,1.08,0.00)
#' EF_COV["exa_e"]  <- c(0.000,1.30,0.217,0.00,0.00,0.00,0.00,1.08)
#' EF_COV["exa_d"]  <- c(0.000,0.00,0.000,2.05,0.00,0.00,0.00,0.00)
#'
#' print(EF_COV)
#'
#' COV_total <- totalVOC(veic,EF_COV,pol = COV[10])

totalVOC <- function(v,ef,pol,verbose=T){

  cat("function totalVOC will be discontinued in the next versions\n")

  suppressWarnings( units::install_symbolic_unit("MOL"))
  MOL <- units::as_units("MOL")

  voc_names <- c("eth","hc3","hc5","hc8","ol2",
                 "olt","oli","iso","tol","xyl",
                 "ket","ch3oh","ald")

  TOTAL_veic <- as.matrix(v[5:ncol(v)])
  use_inv    <- 1 * units::as_units("d km-1", mode = "standard")
  use        <- v$Use * use_inv

  if(!(pol %in% voc_names)){
    cat(paste0(pol," is not in suported COV speciation","\n"))
    cat("The specie list contains:\n")
    cat(c(voc_names,"\n"))
    total = units::set_units(NA * TOTAL_veic[1,],MOL/units::as_units("d"))
    return(total)
  }
  # data from LAPAT (IAG-USP)
  cov_table <- matrix(c(0.025000, 0.000000, 0.282625, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
                        0.240000, 0.213150, 0.435206, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.048995,
                        0.450000, 0.157299, 0.158620, 0.000000, 0.000000, 0.977799, 0.000000, 0.000000, 0.057741,
                        0.000000, 0.192629, 0.076538, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.296627,
                        0.038240, 0.000000, 0.341600, 0.000000, 0.000000, 0.948944, 0.000000, 0.000000, 0.318889,
                        0.200000, 0.082045, 0.143212, 0.000000, 0.000000, 0.076220, 0.000000, 0.000000, 0.385318,
                        0.460000, 0.179849, 0.161406, 0.000000, 0.000000, 0.076220, 0.000000, 0.000000, 0.000000,
                        0.000000, 0.001146, 0.004554, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000,
                        0.085000, 0.058353, 0.140506, 0.000000, 0.000000, 0.015079, 0.000000, 0.000000, 0.235115,
                        0.000000, 0.119330, 0.157456, 0.000000, 0.000000, 0.039490, 0.000000, 0.000000, 0.008360,
                        0.000000, 0.000000, 0.000083, 0.000066, 0.000066, 0.016767, 0.000000, 0.000000, 0.000012,
                        0.000000, 0.000000, 0.001841, 0.002200, 0.002200, 0.005539, 0.000000, 0.000000, 0.000003,
                        0.000000, 0.059507, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000, 0.000000),
                      ncol = 9, byrow = T)
  cov_table <- as.data.frame(cov_table,row.names = voc_names)
  names(cov_table) <- c("G. VAPORS","G. LIQUID","G. EXHAUST",
                        "A. VAPORS","A. LIQUID","A. EXHAUST",
                        "D. VAPORS","D. LIQUID","D. EXHAUST")

  # total of VOCs by:
  # Vapors
  ef_vap  <- ef[,"vap_g"]
  VOC_vap_g =  TOTAL_veic[1,] * use[1] * ef_vap[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_vap_g   = VOC_vap_g + TOTAL_veic[j,] * use[j] * ef_vap[j]
    }
  }
  ef_vap  <- ef[,"vap_e"]
  VOC_vap_e =  TOTAL_veic[1,] * use[1] * ef_vap[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_vap_e   = VOC_vap_e + TOTAL_veic[j,] * use[j] * ef_vap[j]
    }
  }
  ef_vap  <- ef[,"vap_d"]
  VOC_vap_d =  TOTAL_veic[1,] * use[1] * ef_vap[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_vap_d   = VOC_vap_d + TOTAL_veic[j,] * use[j] * ef_vap[j]
    }
  }
  # exhaust
  ef_exa  <- ef[,"exa_g"]
  VOC_exa_g =  TOTAL_veic[1,] * use[1] * ef_exa[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_exa_g   = VOC_exa_g + TOTAL_veic[j,] * use[j] * ef_exa[j]
    }
  }
  ef_exa  <- ef[,"exa_e"]
  VOC_exa_e =  TOTAL_veic[1,] * use[1] * ef_exa[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_exa_e   = VOC_exa_e + TOTAL_veic[j,] * use[j] * ef_exa[j]
    }
  }
  ef_exa  <- ef[,"exa_d"]
  VOC_exa_d =  TOTAL_veic[1,] * use[1] * ef_exa[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_exa_d   = VOC_exa_d + TOTAL_veic[j,] * use[j] * ef_exa[j]
    }
  }
  # liquid
  ef_liq  <- ef[,"liq_g"]
  VOC_liq_g =  TOTAL_veic[1,] * use[1] * ef_liq[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_liq_g   = VOC_liq_g + TOTAL_veic[j,] * use[j] * ef_liq[j]
    }
  }
  ef_liq  <- ef[,"liq_e"]
  VOC_liq_e =  TOTAL_veic[1,] * use[1] * ef_liq[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_liq_e   = VOC_liq_e + TOTAL_veic[j,] * use[j] * ef_liq[j]
    }
  }
  ef_liq  <- ef[,"liq_d"]
  VOC_liq_d =  TOTAL_veic[1,] * use[1] * ef_liq[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_liq_d   = VOC_liq_d + TOTAL_veic[j,] * use[j] * ef_liq[j]
    }
  }
  if(verbose){
    total <- VOC_vap_g + VOC_liq_g + VOC_exa_g + VOC_vap_e + VOC_liq_e +
      VOC_exa_e + VOC_vap_d + VOC_liq_d + VOC_exa_d
    uni2  <- units::set_units(1,"g d-1")
    total <- total * uni2

    total_t_y <- units::set_units(total, "t/year")
    cat(paste("Total COV:",sum(total_t_y),units::deparse_unit(total_t_y),"\n"))
  }

  split_cov <- function(pol,verb = verbose){

    COV <- VOC_vap_g * cov_table[pol,"G. VAPORS" ] +
           VOC_liq_g * cov_table[pol,"G. LIQUID" ] +
           VOC_exa_g * cov_table[pol,"G. EXHAUST"] +
           VOC_vap_e * cov_table[pol,"A. VAPORS" ] +
           VOC_liq_e * cov_table[pol,"A. LIQUID" ] +
           VOC_exa_e * cov_table[pol,"A. EXHAUST"] +
           VOC_vap_d * cov_table[pol,"D. VAPORS" ] +
           VOC_liq_d * cov_table[pol,"D. LIQUID" ] +
           VOC_exa_d * cov_table[pol,"D. EXHAUST"]

    uni   <- units::as_units(1,"MOL/d")
    COV   <- COV * uni
    if(verb){
      COV2 <- units::set_units(COV,"MOL/year",check_is_valid = F)
      cat(paste(pol,sum(COV2),units::deparse_unit(COV2),"\n"))
    }
    return(COV)
  }

  poleunte <- pol
  return(split_cov(poleunte,verbose))
}
