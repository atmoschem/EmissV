#' Distribution of emissions by area
#'
#' @description Calculate the spatial distribution by a raster kasked by shape/model grid information.
#'
#' @param s input shape object
#' @param r input raster object
#' @param grid grid with the output format
#' @param name area name
#' @param as_frac return a fraction instead of a raster
#' @param verbose display additional data
#'
#' @format a raster
#'
#' @export
#'
#' @import raster sp
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
#' sp::spplot(SP,scales = list(draw=TRUE),ylab="Lat",xlab="Lon",
#'            main=list(label="Spatial Distribution by Lights for Sao Paulo - Brazil"),
#'            col.regions = c("#031638","#001E48","#002756","#003062",
#'                            "#003A6E","#004579","#005084","#005C8E",
#'                            "#006897","#0074A1","#0081AA","#008FB3",
#'                            "#009EBD","#00AFC8","#00C2D6","#00E3F0"))
#'}
#'
#'@source Data avaliable \url{http://www.ospo.noaa.gov/Operations/DMSP/index.html}
#'@details About the DMSP and example data \url{https://en.wikipedia.org/wiki/Defense_Meteorological_Satellite_Program}

areaSource <- function(s,r,grid = NA,name = "",as_frac=F,verbose = T){
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
      print(paste("fraction of ",name,"area inside the domain = ",sp_r, sep =""))
    if(as_frac) return(sp_r)
    return(sp)
  }
  if(as_frac) return(sp_r)
  return(sp)
}
