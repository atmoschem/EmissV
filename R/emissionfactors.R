#' Tool to set-up emission factors
#'
#' @description Return a data frame with vehicle information. Types argument defines the diary use:
#'
#' @format data frame
#'
#' @param ef list with emission factors
#' @param poluttant poluttant names
#' @param vnames name of each vehicle categoy (optional)
#' @param unit tring with unit from unit package, for default is "g/km"
#' @param example TRUE to diaplay a simple example
#' @param verbose display additional information
#'
#' @seealso \code{\link{areaSource}} and  \code{\link{totalEmission}}
#'
#' @export
#'
#' @import  units
#'
#' @examples
#' EF <- emissionFactor(example = TRUE)
#'
#' # or the code for the same result
#' EF <- emissionFactor(ef = list(CO = c(1.75,10.04,0.39,0.45,0.77,1.48,1.61,0.75),
#'                                PM = c(0.0013,0.0,0.0010,0.0612,0.1052,0.1693,0.0,0.0)),
#'                      vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
#'                                 "Light Duty Vehicles Flex","Diesel trucks","Diesel urban busses",
#'                                 "Diesel intercity busses","Gasohol motorcycles",
#'                                 "Flex motorcycles"))
#'

emissionFactor <- function(ef,poluttant = names(ef), vnames = NA,unit = "g/km",example = F,verbose = T){
  if(example == T){
    cat("using a example emission factor (values calculated from CETESB 2015):\n")
    EF <- as.data.frame.matrix(matrix(NA,ncol = 2,nrow = 8))
    rownames(EF) <- c("Light Duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
                      "Light Duty Vehicles Flex","Diesel Trucks","Diesel Urban Busses",
                      "Diesel Intercity Busses","Gasohol Motorcycles","Flex Motorcycles")
    names(EF) <- c("CO","PM")
    EF$CO <- units::as_units(c(1.75,10.04,0.39,0.45,0.77,1.48,1.61,0.75),"g/km")
    EF$PM <- units::as_units(c(0.0013,0.0,0.0010,0.0612,0.1052,0.1693,0.0,0.0),"g/km")

    if(verbose){
      print(EF)
    }
    return(EF)
  }

  EF <- as.data.frame.matrix(matrix(NA,ncol = length(poluttant),nrow = length(ef[[1]])))
  names(EF) <- poluttant

  for(i in 1:length(ef)){
    EF[i] <- units::as_units(ef[[i]],unit)
  }
  if(!is.na(vnames[1])){
    row.names(EF) <- vnames
  }
  if(verbose){
    cat("Emission factors:\n")
    print(EF)
  }
  return(EF)
}
