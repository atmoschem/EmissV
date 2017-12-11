#' Transform a shape into a grinded output
#'
#' @description under development (test)
#'
#' @param s input shape object
#' @param grid grid object with the grid information
#' @param verbose display adicional information
#'
#' @export
#'
#' @seealso \code{\link{newGrid}} and \code{\link{rasterToGrid}}
#'
#'
#' @examples \dontrun{
#' # Do not run
#' grid  <- newGrid(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' d3 <- data.frame(x = as.numeric(grid$Lon),y = as.numeric(grid$Lat))
#' d3 <- st_as_sf(d3, coords = c("x","y"))
#' st_crs(d3) <- st_crs(4326)
#'
#' streets <- readRDS("D:/Downloads/streets.rds")
#' streets <- streets[streets$highway != "residential", ]
#'
#' shapeToGrid(streets,d3)
#'
#' }
shapeToGrid <- function(s,grid,verbose = T){
  s        <- st_transform(s, crs = st_crs(grid))
  # le       <- as.numeric( sf::st_length(s) )
  # grid_L   <- st_intersection(Len, grid)

  test <- raster::raster(raster::extent(s), crs=st_crs(s)) # usar : nrows=180, ncols=360,
  test.poly <- rasterToPolygons(test)
  rp <- rgeos::gIntersection(s, test.poly, byid=TRUE)
  rp <- SpatialLinesDataFrame(rp, data.frame(row.names=sapply(slot(rp, "lines"),function(x) slot(x, "ID")), ID=1:length(rp),
                                             length=SpatialLinesLengths(rp)/1000) )
  # Rasterize using sum of intersected lines
  rd <- rasterize(rp, rrst, field="length", fun="sum")

  return(rd)
}

# # fonte: https://gis.stackexchange.com/questions/119993/convert-line-shapefile-to-raster-value-total-length-of-lines-within-cell
# require(rgdal)
# require(raster)
# require(sp)
# require(rgeos)
#
# setwd("D:/TEST/RDSUM")
# roads <- readOGR(getwd(), "TZA_roads")
# roads <- spTransform(roads, CRS("+init=epsg:21037"))
# rrst  <- raster(extent(roads), crs=projection(roads))
#
# # Intersect lines with raster "polygons" and add length to new lines segments
# rrst.poly <- rasterToPolygons(rrst)
# rp <- gIntersection(roads, rrst.poly, byid=TRUE)
# rp <- SpatialLinesDataFrame(rp, data.frame(row.names=sapply(slot(rp, "lines"),
#                                                             function(x) slot(x, "ID")), ID=1:length(rp),
#                                            length=SpatialLinesLengths(rp)/1000) )
#
# # Rasterize using sum of intersected lines
# rd.rst <- rasterize(rp, rrst, field="length", fun="sum")
#
# # Plot results
# require(RColorBrewer)
# spplot(rd.rst, scales = list(draw=TRUE), xlab="x", ylab="y",
#        col.regions=colorRampPalette(brewer.pal(9, "YlOrRd")),
#        sp.layout=list("sp.lines", rp),
#        par.settings=list(fontsize=list(text=15)), at=seq(0, 1800, 200))
# olhar emis_grid do vein :
# emis_grid <- function(spobj, g, sr){
#     net <- spobj
#     for( i in 1:ncol(net@data) ){
#       net@data[,i] <- as.numeric(net@data[,i])
#     }
#     net$lkm <-  rgeos::gLength(sp::spTransform(net,CRS(sr)),byid = T)/1000
#     netg <- raster::intersect(net,g)
#     netg$lkm2 <-  rgeos::gLength(sp::spTransform(netg,CRS(sr)),byid = T)/1000
#     netg@data[,1:(ncol(netg@data)-3)] <-  netg@data[,1:(ncol(netg@data)-3)] * netg$lkm2/netg$lkm
#     dfm <- stats::aggregate(cbind(netg@data[,1:(ncol(netg@data)-3)]),
#                             by=list(netg$id), sum, na.rm=TRUE)
#     colnames(dfm)[1] <- "id"
#     gg <- merge(g, dfm, by="id")
#     # for(i in 2:ncol(gg)){
#     #   gg@data[,i] <- gg@data[,i] * units::parse_unit("g h-1")
#     # } # spplot does not work with units
#     return(gg)
#}
