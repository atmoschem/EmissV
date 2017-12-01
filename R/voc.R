#' Calculate VOCs emissions by fuel type
#'
#' @description cacule Volatile Organic Compounds (COVs) emited by the process of exaustao (through the exhaust pipe), liquid (carter and evaporative) and vapor (fuel transfer operations).
#'
#' Avaliable VOCs are: eth, hc3, hc5, hc8, ol2, olt, oli, iso, tol, xyl, ket, ch3oh and ald
#'
#' @format Return a list with the daily total emission by territory.
#'
#' @param v dataframe with the vehicle data
#' @param ef emission factors
#' @param pol pollutant name in ef
#' @param verbose display adicional information
#'
#' @note the same ef can be used to totalEmission and voc
#'
#' @seealso \code{\link{totalEmission}} and \code{\link{vehicle}}
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' veiculos <- vehicles(total_v = c(25141442, 5736428, 9147282, 6523727, 4312896),
#'                      territory_name = c("SP", "RJ", "MG", "PR", "SC"),
#'                      distribution = c( 0.4253, 0.0320, 0.3602, 0.0260, 0.0290, 0.0008, 0.1181, 0.0086),
#'                      category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5","CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
#'                      type = c("LDV", "LDV", "LDV","TRUCKS","BUS","BUS","MOTO", "MOTO"),
#'                      fuel = c("E25", "E100", "FLEX","B5","B5","B5","E25", "FLEX"),
#'                      vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol","Light Duty Vehicles Flex",
#'                                 "Diesel trucks","Diesel urban busses","Diesel intercity busses",
#'                                 "Gasohol motorcycles","Flex motorcycles"))
#'
#' voc = c("eth","hc3","hc5","hc8","ol2","olt","oli","iso","tol","xyl","ket","ch3oh","ald")
#'
#' EF_voc <- as.data.frame.matrix(matrix(NA,ncol = 9,nrow = 8,byrow = T),
#'                                row.names = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol","Light Duty Vehicles Flex",
#'                                              "Diesel trucks","Diesel urban busses","Diesel intercity busses",
#'                                              "Gasohol motorcycles","Flex motorcycles"),
#'                                names = c("voc_vap_g","voc_vap_e","voc_vap_d",
#'                                          "voc_liq_g","voc_liq_e","voc_liq_d",
#'                                          "voc_exa_g","voc_exa_e","voc_exa_d"))
#'
#' EF_voc["voc_vap_g"]  <- c(0.23, 0.00,0.12, 0.00,0.00,0.00,0.00,0.00)
#' EF_voc["voc_vap_e"]  <- c(0.00, 0.25,0.12, 0.00,0.00,0.00,0.00,0.00)
#' EF_voc["voc_vap_d"]  <- c(0.00, 0.00,0.00, 0.00,0.00,0.00,0.00,0.00)
#' EF_voc["voc_liq_g"]  <- c(2.00, 0.00,0.875,0.00,0.00,0.00,1.20,0.00)
#' EF_voc["voc_liq_e"]  <- c(0.00, 1.50,0.875,0.00,0.00,0.00,0.00,1.20)
#' EF_voc["voc_liq_d"]  <- c(0.00, 0.00,0.00, 0.00,0.00,0.00,0.00,0.00)
#' EF_voc["voc_exa_g"]  <- c(0.425,0.00,0.217,0.00,0.00,0.00,1.08,0.00)
#' EF_voc["voc_exa_e"]  <- c(0.00, 1.30,0.217,0.00,0.00,0.00,0.00,1.08)
#' EF_voc["voc_exa_d"]  <- c(0.00, 0.00,0.00, 2.05,0.00,0.00,0.00,0.00)
#'
#' VOC <- voc(veiculos,EF_voc,pol = voc[12])
#'}

voc <- function(v,ef,pol,verbose=T){
  # data from ??
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
  cov_table <- as.data.frame(cov_table,row.names = c("eth","hc3","hc5","hc8","ol2","olt","oli","iso","tol","xyl","ket","ch3oh","ald"))
  names(cov_table) <- c("G. VAPORS","G. LIQUID","G. EXHAUST",
                        "A. VAPORS","A. LIQUID","A. EXHAUST",
                        "D. VAPORS","D. LIQUID","D. EXHAUST")

  TOTAL_veic <- as.matrix(v[5:ncol(v)])
  use        <- v$Use

  # total of VOCs by:
  # Vapors
  ef_vap  <- ef[,"voc_vap_g"]
  VOC_vap_g =  TOTAL_veic[1,] * use[1] * ef_vap[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_vap_g   = VOC_vap_g + TOTAL_veic[j,] * use[j] * ef_vap[j]
    }
  }
  ef_vap  <- ef[,"voc_vap_e"]
  VOC_vap_e =  TOTAL_veic[1,] * use[1] * ef_vap[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_vap_e   = VOC_vap_e + TOTAL_veic[j,] * use[j] * ef_vap[j]
    }
  }
  ef_vap  <- ef[,"voc_vap_d"]
  VOC_vap_d =  TOTAL_veic[1,] * use[1] * ef_vap[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_vap_d   = VOC_vap_d + TOTAL_veic[j,] * use[j] * ef_vap[j]
    }
  }
  # exaust
  ef_exa  <- ef[,"voc_exa_g"]
  VOC_exa_g =  TOTAL_veic[1,] * use[1] * ef_exa[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_exa_g   = VOC_exa_g + TOTAL_veic[j,] * use[j] * ef_exa[j]
    }
  }
  ef_exa  <- ef[,"voc_exa_e"]
  VOC_exa_e =  TOTAL_veic[1,] * use[1] * ef_exa[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_exa_e   = VOC_exa_e + TOTAL_veic[j,] * use[j] * ef_exa[j]
    }
  }
  ef_exa  <- ef[,"voc_exa_d"]
  VOC_exa_d =  TOTAL_veic[1,] * use[1] * ef_exa[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_exa_d   = VOC_exa_d + TOTAL_veic[j,] * use[j] * ef_exa[j]
    }
  }
  # liquid
  ef_liq  <- ef[,"voc_liq_g"]
  VOC_liq_g =  TOTAL_veic[1,] * use[1] * ef_liq[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_liq_g   = VOC_liq_g + TOTAL_veic[j,] * use[j] * ef_liq[j]
    }
  }
  ef_liq  <- ef[,"voc_liq_e"]
  VOC_liq_e =  TOTAL_veic[1,] * use[1] * ef_liq[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_liq_e   = VOC_liq_e + TOTAL_veic[j,] * use[j] * ef_liq[j]
    }
  }
  ef_liq  <- ef[,"voc_liq_d"]
  VOC_liq_d =  TOTAL_veic[1,] * use[1] * ef_liq[1]
  if(nrow(v) >= 2){
    for(j in 2:nrow(v)){
      VOC_liq_d   = VOC_liq_d + TOTAL_veic[j,] * use[j] * ef_liq[j]
    }
  }

  split_cov <- function(pol,verbose = T){
    if(verbose)
      print(paste("VOC split:",pol))

    COV <- VOC_vap_g * cov_table[pol,"G. VAPORS" ] +
           VOC_liq_g * cov_table[pol,"G. LIQUID" ] +
           VOC_exa_g * cov_table[pol,"G. EXHAUST"] +
           VOC_vap_e * cov_table[pol,"A. VAPORS" ] +
           VOC_liq_e * cov_table[pol,"A. LIQUID" ] +
           VOC_exa_e * cov_table[pol,"A. EXHAUST"] +
           VOC_vap_d * cov_table[pol,"D. VAPORS" ] +
           VOC_liq_d * cov_table[pol,"D. LIQUID" ] +
           VOC_exa_d * cov_table[pol,"D. EXHAUST"]

    return(COV)
  }

  poleunte <- pol
  return(split_cov(poleunte,verbose))
}


