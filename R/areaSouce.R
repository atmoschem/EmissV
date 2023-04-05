#' Distribution of emissions by area
#'
#' @description Calculate the spatial distribution by a raster masked by shape/model grid information.
#'
#' @param s input shape object
#' @param r input raster object
#' @param grid grid with the output format
#' @param name area name
#' @param as_frac return a fraction instead of the raster value
#' @param verbose display additional data
#'
#' @return a raster object containing the spatial distribution of emissions
#'
#' @export
#'
#' @import raster sf
#'
#' @examples
#' shape  <- raster::shapefile(paste(system.file("extdata", package = "EmissV"),
#'                             "/BR.shp",sep=""),verbose = FALSE)
#' shape  <- shape[22,1] # subset for Sao Paulo - BR
#' raster <- raster::raster(paste(system.file("extdata", package = "EmissV"),
#'                          "/dmsp.tiff",sep=""))
#' grid   <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' SP     <- areaSource(shape,raster,grid,name = "SPMA")
#' \donttest{
#' raster::plot(SP,ylab="Lat",xlab="Lon",
#'              main ="Spatial Distribution by Lights for Sao Paulo - Brazil")
#'}
#'
#'@source Data avaliable \url{https://www.ospo.noaa.gov/Operations/DMSP/index.html}
#'@details About the DMSP and example data \url{https://en.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program}

areaSource <- function(s,r,grid = NA,name = "",as_frac=FALSE,verbose = TRUE){
  if(verbose){
    if(name != "") name = paste0(name," ")
    cat(paste("processing ",name,"area ... \n",sep = ""))
  }

  sp <- suppressWarnings( raster::mask(r,sf::st_transform(sf::st_as_sf(s),crs = raster::crs(r,asText=TRUE))))

  if(!is.na(grid[1])){
    if(grid$map_proj %in% c(1,2,3,6)){
      dx    <- grid$DX*1000  # using meters
      dy    <- grid$DX*1000
      ncols <- grid$Horizontal[1]
      nrows <- grid$Horizontal[2]

      pontos     <- sf::st_multipoint(x = grid$coords, dim = "XY")
      coords     <- sf::st_sfc(x = pontos, crs = "+proj=longlat")
      transform  <- sf::st_transform(x = coords, crs = grid$geogrd.proj)
      projcoords <- sf::st_coordinates(transform)[,1:2]

      xmn <- projcoords[1,1] - dx/2.0  # Left border
      ymx <- projcoords[1,2] + dy/2.0  # upper border
      xmx <- xmn + ncols*dx            # Right border
      ymn <- ymx - nrows*dy            # Bottom border
      # Create a raster
      box <- suppressWarnings(
        raster::raster(resolution = dx,
                       xmn = xmn,
                       xmx = xmx,
                       ymn = ymn,
                       ymx = ymx,
                       crs = grid$geogrd.proj))
    }else{
      col   <- grid$Horizontal[1]
      rol   <- grid$Horizontal[2]
      r.lat <- range(grid$Lat)
      r.lon <- range(grid$Lon)
      box   <- raster::raster(nrows=rol,ncols=col,
                              xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                              crs='+proj=longlat')
    }

    sp      <- suppressWarnings(raster::projectRaster(sp,crs = raster::crs(box))) # to the new projection
    sp_soma <- raster::cellStats(sp,"sum")
    sp      <- raster::crop(sp,box)
    sp_r    <- raster::cellStats(sp,"sum") / sp_soma
    sp      <- raster::resample(sp,box,method = "bilinear")
    sp      <- sp_r * sp / raster::cellStats(sp,"sum")
    if(verbose)
      cat(paste("fraction of ",name,"area inside the domain = ",sp_r,"\n", sep =""))
    if(as_frac)
      return(sp_r)
    return(sp)
  }
  return(sp)
}
