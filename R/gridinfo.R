#' Read grid information from a NetCDF file
#'
#' @description Return a list containing information of a regular grid / domain
#'
#' @param file file name/path to a wrfinput, wrfchemi or geog_em file
#' @param z TRUE for read wrfinput vertical coordinades
#' @param verbose display additional information
#'
#' @return a list with grid information from air quality model
#'
#' @note just WRF-Chem is suported by now
#'
#' @import ncdf4 sp
#'
#' @export
#'
#' @examples
#' grid_d1 <- gridInfo(paste(system.file("extdata", package = "EmissV"),
#'                                       "/wrfinput_d01",sep=""))
#' \donttest{grid_d2 <- gridInfo(paste(system.file("extdata", package = "EmissV"),
#'                                       "/wrfinput_d02",sep=""))
#' grid_d3 <- gridInfo(paste(system.file("extdata", package = "EmissV"),
#'                                       "/wrfinput_d03",sep=""))
#' names(grid_d1)
#' # for plot the shapes
#' library(sp)
#' shape   <- raster::shapefile(paste0(system.file("extdata", package = "EmissV"),
#'                                                 "/BR.shp"))
#' plot(shape,xlim = c(-55,-40),ylim = c(-30,-15), main="3 nested domains")
#' axis(1); axis(2); box(); grid()
#' lines(grid_d1$Box, col = "red")
#' text(grid_d1$xlim[2],grid_d1$Ylim[1],"d1",pos=4, offset = 0.5)
#' lines(grid_d2$Box, col = "red")
#' text(grid_d2$xlim[2],grid_d2$Ylim[1],"d2",pos=4, offset = 0.5)
#' lines(grid_d3$Box, col = "red")
#' text(grid_d3$xlim[1],grid_d3$Ylim[2],"d3",pos=2, offset = 0.0)
#'}

gridInfo <- function(file = file.choose(),z = FALSE,verbose = TRUE){
    if(verbose)
      cat(paste("Grid information from:",file,"\n"))

     wrf <- ncdf4::nc_open(file)

     coordNC <- tryCatch(suppressWarnings(ncdf4::nc_open(file)),
                         error=function(cond) {message(cond); return(NA)}) # nocov

     coordvarList = names(coordNC[['var']])
     if ("XLONG_M" %in% coordvarList & "XLAT_M" %in% coordvarList) {
       inNCLon <- ncdf4::ncvar_get(coordNC, "XLONG_M")  # nocov
       inNCLat <- ncdf4::ncvar_get(coordNC, "XLAT_M")   # nocov
     } else if ("XLONG" %in% coordvarList & "XLAT" %in% coordvarList) {
       inNCLon <- ncdf4::ncvar_get(coordNC, "XLONG")
       inNCLat <- ncdf4::ncvar_get(coordNC, "XLAT")
     } else if ("lon" %in% coordvarList & "lat" %in% coordvarList) { # nocov
       inNCLon <- ncdf4::ncvar_get(coordNC, "lon")      # nocov
       inNCLat <- ncdf4::ncvar_get(coordNC, "lat")      # nocov
     } else {
       stop('Error: Latitude and longitude fields not found (tried: XLAT_M/XLONG_M, XLAT/XLONG, lat/lon') # nocov
     }

     nrows <- dim(inNCLon)[2]
     ncols <- dim(inNCLon)[1]

     # Reverse column order to get UL in UL
     x <- as.vector(inNCLon[,ncol(inNCLon):1])
     y <- as.vector(inNCLat[,ncol(inNCLat):1])

     coords <- as.matrix(cbind(x, y))

     # Get geogrid and projection info
     map_proj <- ncdf4::ncatt_get(coordNC, varid=0, attname="MAP_PROJ")$value
     cen_lat  <- ncdf4::ncatt_get(coordNC, varid=0, attname="CEN_LAT")$value
     cen_lon  <- ncdf4::ncatt_get(coordNC, varid=0, attname="CEN_LON")$value
     truelat1 <- ncdf4::ncatt_get(coordNC, varid=0, attname="TRUELAT1")$value
     truelat2 <- ncdf4::ncatt_get(coordNC, varid=0, attname="TRUELAT2")$value
     ref_lon  <- ncdf4::ncatt_get(coordNC, varid=0, attname="STAND_LON")$value

     if(map_proj == 1){
       geogrd.proj <- paste0("+proj=lcc +lat_1=", truelat1,
                             " +lat_2=", truelat2,
                             " +lat_0=", cen_lat,
                             " +lon_0=", ref_lon,
                             " +x_0=0 +y_0=0 +a=6370000 +b=6370000 +units=m +no_defs")
     } else if(map_proj == 2){                              # nocov
       if(cen_lat > 0){                                     # nocov
         hemis = 90                                         # nocov
       }else{                                               # nocov
         hemis = -90                                        # nocov
       }
       geogrd.proj <- paste0("+proj=stere +lat_0=",hemis,   # nocov
                             " +lon_0=",ref_lon,            # nocov
                             " +lat_ts=",truelat1,          # nocov
                             " +x_0=0 +y_0=0",              # nocov
                             " +a=6370000 +b=6370000",      # nocov
                             " +units=m +no_defs")          # nocov
     } else if(map_proj == 3){                              # nocov
       geogrd.proj <-paste0("+proj=merc +lat_ts=",truelat1, # nocov
                            " +lon_0=",ref_lon,             # nocov
                            " +a=6370000 +b=6370000",       # nocov
                            " +datum=WGS84")                # nocov
     } else if(map_proj == 6){                              # nocov
       geogrd.proj <- paste0("+proj=eqc +lat_ts=",0,        # nocov
                             " +lat_0=",cen_lat,            # nocov
                             " +lon_0=",ref_lon,            # nocov
                             " +x_0=",0," +y_0=",0,         # nocov
                             " +ellps=WGS84 +units=m")      # nocov
     } else {
       stop('Error: Projection type not supported (currently Lambert Conformal, Cylindrical Equidistant, Polar and lat-lon WRF grids are suported).') # nocov
     }

     dx <- ncdf4::ncatt_get(coordNC, varid=0, attname="DX")$value
     dy <- ncdf4::ncatt_get(coordNC, varid=0, attname="DY")$value
     if ( dx != dy ) {
       stop(paste0('Error: Asymmetric grid cells not supported. DX=', dx, ', DY=', dy))  # nocov
     }

     dx <- ncdf4::ncatt_get(coordNC, varid=0, attname="DX")$value
     dy <- ncdf4::ncatt_get(coordNC, varid=0, attname="DY")$value
     if ( dx != dy ) {
       stop(paste0('Error: Asymmetric grid cells not supported. DX=', dx, ', DY=', dy)) # nocov
     }

     lat <- inNCLat
     lon <- inNCLon

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
                                 y = c(lat[1,],lat[,nxj],rev(lat[nxi,]),rev(lat[,1]))),
                 poligon = sp::Polygon(matrix(c( c(lon[1,],lon[,nxj],rev(lon[nxi,]),rev(lon[,1])),
                                                 c(lat[1,],lat[,nxj],rev(lat[nxi,]),rev(lat[,1]))),
                                              ncol = 2)),
                 map_proj    = map_proj,
                 coords      = coords,
                 geogrd.proj = geogrd.proj)
     return(OUT)
}
