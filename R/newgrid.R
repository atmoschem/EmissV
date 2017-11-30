#' Create a grid set-up based on a NetCDF file
#'
#' @description Return a list contains information of a regular grid
#'
#' @param file file name/path to a wrfinput of wrfchemi file
#' @param levels number of levels
#' @param verbose display adicional information
#'
#' @note its works with some wrf files (inicial condictions and emission) for now.
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#' grid  <- newGrid(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' grid
#'}

newGrid <- function(file,levels = 1,verbose = T){
  if(!is.na(file)){
    if(verbose)
      print(paste("New grid from:",file))
    wrf <- nc_open(file)
    lat <- ncvar_get(wrf,varid = "XLAT")
    lon <- ncvar_get(wrf,varid = "XLONG")
    time<- ncvar_get(wrf,varid = "Times")
    dx  <- ncatt_get(wrf,varid = 0,attname = "DX")$value / 1000 # km
    nc_close(wrf)
    OUT <- list(Times = time, Lat = lat, Lon = lon, Horizontal = dim(lat), Levels = levels, DX = dx)
    return(OUT)
  }
  print("em desenvolvimento!")
}
