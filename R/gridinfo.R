#' Read grid information from a NetCDF file
#'
#' @description Return a list containing information of a regular grid / domain
#'
#' @param file file name/path to a wrfinput, wrfchemi or geog_em file
#' @param z TRUE for read wrfinput vertical coordinades
#' @param geo True for use geog_em files
#' @param verbose display additional information
#'
#' @note just WRF-Chem is suported by now
#'
#' @import ncdf4
#'
#' @export
#'
#' @examples
#' grid_d1 <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' \donttest{
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

gridInfo <- function(file = file.choose(),z=F,geo = F,verbose = T){
    if(verbose)
      cat(paste("Grid information from:",file,"\n"))
    wrf <- ncdf4::nc_open(file)
    if(geo){
      lat <- ncdf4::ncvar_get(wrf,varid = "XLAT_M")      # nocov
      lon <- ncdf4::ncvar_get(wrf,varid = "XLONG_M")     # nocov
    }else{
      lat <- ncdf4::ncvar_get(wrf,varid = "XLAT")
      lon <- ncdf4::ncvar_get(wrf,varid = "XLONG")
    }

    time<- ncdf4::ncvar_get(wrf,varid = "Times")
    dx  <- ncdf4::ncatt_get(wrf,varid = 0,attname = "DX")$value / 1000 # to km
    if(z){
      PHB <- ncdf4::ncvar_get(wrf,varid = "PHB")        # 3d
      PH  <- ncdf4::ncvar_get(wrf,varid = "PH")         # 3d
      HGT <- ncdf4::ncvar_get(wrf,varid = "HGT")        # 2d
      z   <- PH
      if(length(time) == 1){                            # just one time
        for(i in 1:dim(PH)[3]){
          z[,,i]   <- (PH[,,i] + PHB[,,i])/9.8 - HGT    # 9.81 return values < 0, ~10-5
        }                                               # this is for an alternative use
      }else{                                            # for multiple times (test version)
        for(i in 1:dim(PH)[3]){                         # nocov
          z[,,i,]   <- (PH[,,i,] + PHB[,,i,])/9.8 - HGT # nocov
        }
      }

    }else{
      z <- NA
    }
    ncdf4::nc_close(wrf)
    lx  <- range(lon)
    ly  <- range(lat)
    nxi <- dim(lat)[1]
    nxj <- dim(lat)[2]
    OUT <- list(File = file, Times = time, Lat = lat, Lon = lon, z = z,
                Horizontal = dim(lat), DX = dx, xlim = lx, ylim = ly,
                Box = list(x = c(lx[2],lx[1],lx[1],lx[2],lx[2]),
                           y = c(ly[2],ly[2],ly[1],ly[1],ly[2])),
                boundary = list(x = c(lon[1,],lon[,nxj],rev(lon[nxi,]),rev(lon[,1])),
                                y = c(lat[1,],lat[,nxj],rev(lat[nxi,]),rev(lat[,1]))))
    return(OUT)
}
