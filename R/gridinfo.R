#' Read grid information from a NetCDF file
#'
#' @description Return a list containing information of a regular grid / domain
#'
#' @param file file name/path to a wrfinput of wrfchemi file
#' @param z TRUE for read wrfinput vertical coordinades
#' @param verbose display additional information
#'
#' @note just WRF-Chem is suported by now
#'
#' @import ncdf4
#'
#' @export
#'
#' @examples
#' # Do not run
#' grid_d1 <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' \dontrun{
#' grid_d2 <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' grid_d3 <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d03",sep=""))
#' names(grid_d1)
#' # for plot the shapes
#' library(sp)
#' shape   <- raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))
#' plot(shape,xlim = c(-55,-40),ylim = c(-30,-15), main="3 nested domains")
#' axis(1); axis(2); box(); grid()
#' lines(grid_d1$Box, col = "red")
#' text(grid_d1$xlim[2],grid_d1$Ylim[1],"d1",pos=4, offset = 0.5)
#' lines(grid_d2$Box, col = "red")
#' text(grid_d2$xlim[2],grid_d2$Ylim[1],"d2",pos=4, offset = 0.5)
#' lines(grid_d3$Box, col = "red")
#' text(grid_d3$xlim[1],grid_d3$Ylim[2],"d3",pos=2, offset = 0.0)
#'}

gridInfo <- function(file = file.choose(),z=F,verbose = T){
    if(verbose)
      print(paste("Grid information from:",file))
    wrf <- ncdf4::nc_open(file)
    lat <- ncdf4::ncvar_get(wrf,varid = "XLAT")
    lon <- ncdf4::ncvar_get(wrf,varid = "XLONG")
    time<- ncdf4::ncvar_get(wrf,varid = "Times")
    dx  <- ncdf4::ncatt_get(wrf,varid = 0,attname = "DX")$value / 1000 # km
    if(z){
      PHB <- ncdf4::ncvar_get(wrf,varid = "PHB") # 3d
      PH  <- ncdf4::ncvar_get(wrf,varid = "PH")  # 3d
      HGT <- ncdf4::ncvar_get(wrf,varid = "HGT") # 2d
      z   <- PH
      for(i in 1:dim(PH)[3]){
        z[,,i]   <- (PH[,,i] + PHB[,,i])/9.8 - HGT # 9.81 return values < 0, ~10-5
      }
    }else{
      z <- NA
    }
    ncdf4::nc_close(wrf)
    lx  <- range(lon)
    ly  <- range(lat)
    OUT <- list(Times = time, Lat = lat, Lon = lon, Horizontal = dim(lat),
                Levels = levels, DX = dx,xlim = lx, Ylim = ly, File = file,
                Box = list(x = c(lx[2],lx[1],lx[1],lx[2],lx[2]),
                           y = c(ly[2],ly[2],ly[1],ly[1],ly[2])),z = z)
    return(OUT)
}
