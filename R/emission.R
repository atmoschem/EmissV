#' Emissions to atmospheric models
#'
#' @description Merge terrytory data with emissions to model output
#'
#' @format a matrix of emission
#'
#' @param emis list of total emission
#' @param pol pollutant name
#' @param mm molar mass
#' @param territorys list of territory outputs
#' @param grid grid information
#' @param aerosol TRUE for aerosols and FALSE (defoult) for gazes
#' @param verbose display adicional information
#'
#' @seealso \code{\link{totalEmission}} and \code{\link{territory}}
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#'}

emission <- function(emis,pol,territorys,grid, mm = 1, aerosol = F, verbose = T){

  if(verbose)
    print(paste("calculating emissions for ",pol," ...",sep=""))

  n <- which(names(emis) == pol)
  if(length(n) == 0){
    print(paste(pol,"not found in emis!"))
    stop()
  }
  var   <- unlist(emis[n])
  lista <- list(territorys$SP * var[1],
                territorys$RJ * var[2],
                territorys$MG * var[3],
                territorys$PR * var[4],
                territorys$SC * var[5] )
  VAR_e  <- do.call(merge,lista)
  VAR_e[is.na(VAR_e)]     <- 0

  dx <- grid$dx # in Km

  if(aerosol){
    ##  ug m^-2 s^-1
    VAR_e = 10^6 * VAR_e / ( (dx * 1000)^2 * 60*60)
  }
  else{
    #  mol km^-2 hr^-1
    VAR_e   =  VAR_e / (mm * dx^2) # mm = massa molar do poluente
  }

  return(VAR_e)
}
