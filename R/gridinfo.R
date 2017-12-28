#' read grid information from a NetCDF file
#'
#' @description Return a list contains information of a regular grid / domain
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
#' grid  <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' grid
#'}

gridInfo <- function(file,levels = 1,verbose = T){
  if(!is.na(file)){
    if(verbose)
      print(paste("Grid information from:",file))
    wrf <- ncdf4::nc_open(file)
    lat <- ncdf4::ncvar_get(wrf,varid = "XLAT")
    lon <- ncdf4::ncvar_get(wrf,varid = "XLONG")
    time<- ncdf4::ncvar_get(wrf,varid = "Times")
    dx  <- ncdf4::ncatt_get(wrf,varid = 0,attname = "DX")$value / 1000 # km
    ncdf4::nc_close(wrf)
    lx  <- range(lon)
    ly  <- range(lat)
    OUT <- list(Times = time, Lat = lat, Lon = lon, Horizontal = dim(lat), Levels = levels, DX = dx,
                xlim = lx, Ylim = ly)
    return(OUT)
  }
  print("em desenvolvimento!")
}
