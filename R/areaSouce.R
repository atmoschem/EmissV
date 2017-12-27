#' distribution of emissions by region
#'
#' @description Create the spetial distribution by a raster kasked by shape/model grid information.
#'
#' @param s input shape object
#' @param r input raster object
#' @param grid grid with the output format
#' @param name display name
#' @param verbose display adicional data
#'
#' @format a raster
#'
#' @export
#'
#' @examples \dontrun{
#' # Do not run
#'
#' shape  <- readOGR(paste(system.file("extdata", package = "EmissV"),"/BR.shp",sep=""),verbose = F)
#' shape  <- shape[22,1] # subset for Sao Paulo - BR
#' raster <- raster(paste(system.file("extdata", package = "EmissV"),"/sample.tiff",sep=""))
#' grid   <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' SP     <- areaSource(shape,raster,grid)
#' spplot(SP, scales = list(draw=TRUE), xlab="Lat", ylab="Lon",main="Sao Paulo Metropolitan Area")
#'
#'}

areaSource <- function(s,r,grid = NA,name = "",verbose = T){
  if(verbose){
    if(name != "") name = paste0(name," ")
    print(paste("processing ",name,"area ... ",sep = ""))
  }

  sp       <- raster::mask(r,sp::spTransform(s,sp::CRS(sp::proj4string(r))))
  sp_soma  <- raster::cellStats(sp,"sum")
  if(!is.na(grid[1])){
    col    <- grid$Horizontal[1]
    rol    <- grid$Horizontal[2]
    r.lat  <- range(grid$Lat)
    r.lon  <- range(grid$Lon)
    box    <- raster::raster(nrows=rol,ncols=col,
                             xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                             crs=sp::CRS(sp::proj4string(r)))
    sp     <- raster::crop(sp / sp_soma ,box)
    sp_r   <- raster::cellStats(sp,"sum")
    if(verbose)
      print(paste("fraction of area inside the domain =",sp_r))
    return(sp)
  }
  return(sp)
}