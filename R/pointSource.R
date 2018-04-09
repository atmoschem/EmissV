#' Emissions from point sources
#'
#' @description Transform a set of points into a grinded output
#'
#' @param emissions list of points
#' @param grid grid object with the grid information
#' @param verbose display additional information
#'
#' @return a raster
#'
#' @import sp raster
#'
#' @export
#'
#' @examples
#' # Do not run
#' d1 <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#'
#' p = data.frame(lat      = c(-22,-22,-23.5),
#'                lon      = c(-46,-48,-47  ),
#'                z        = c(0  ,  0,  0  ),
#'                emission = c(666,444,111  ) )
#'
#' p_emissions <- pointSource(emissions = p, grid = d1)
#' \dontrun{
#' sp::spplot(p_emissions,scales = list(draw=TRUE), ylab="Lat", xlab="Lon",
#'            main = "3 point sources for domain d1")
#'}
#'
#' @note just emissions at surface level for a while
#'
#' @seealso \code{\link{gridInfo}} and \code{\link{rasterSource}}
#'
pointSource <- function(emissions, grid, verbose=T){
  if(is.na(grid$z)){
    col    <- grid$Horizontal[1]
    rol    <- grid$Horizontal[2]
    r.lat  <- range(grid$Lat)
    r.lon  <- range(grid$Lon)
    emis   <- raster::raster(nrows=rol,ncols=col,
                             xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2]
                             ,crs="+proj=longlat +ellps=GRS80 +no_defs")
    values(emis) <- rep(0,ncell(emis))

    for(i in 1:length(emissions[[1]])){
      id.cell <- extract(emis,SpatialPoints(cbind(emissions$lon[i],emissions$lat[i])),
                         cellnumbers=TRUE)[1]
      emis[id.cell] <- emissions$e[i]
    }
  }else{
    col    <- grid$Horizontal[1]
    rol    <- grid$Horizontal[2]
    r.lat  <- range(grid$Lat)
    r.lon  <- range(grid$Lon)
    z      <- grid$z
    emis   <- raster::brick(nrows=rol,ncols=col,nl = dim(z)[3],
                             xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2]
                             ,crs="+proj=longlat +ellps=GRS80 +no_defs")
    values(emis) <- rep(0,ncell(emis))

    for(i in 1:length(emissions[[1]])){
      id.cell <- extract(emis,SpatialPoints(cbind(emissions$lon[i],emissions$lat[i])),
                         cellnumbers=TRUE)[1]
      # em qual layer colocar?
      emis[id.cell] <- emissions$e[i]
    }
  }

  return(emis)
}
