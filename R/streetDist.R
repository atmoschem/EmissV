#' Distribution by OpenStreetnMap street
#'
#' @description Distribute emissions by streets of OpenStreetMap
#'
#'
#' @param emission numeric of emissions
#' @param dist numeric vector with length 5. The order represents motorway,
#' trunk, primary, secondary and tertiary
#' @param grid grid of polygons class sf
#' @param osm streets of OpenStreetMaps class sf
#' @param epsg spatial code for projecting spatial data
#' @return grid of polygon
#' @export
#'
#' @importFrom data.table data.table
#' @import units
#' @importFrom sf st_sf st_dimension st_transform st_length st_cast st_intersection
#' @examples \dontrun{
#' # Do not run
#' library(sf)
#' # Download OSM streets
#' streets <- st_read("path")
#' streets <- streets[streets$highway != "residential", ]
#' # Grid
#' grid  <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
#' names(grid)
#' d3 <- data.frame(x = as.numeric(grid$Lon),
#'                  y = as.numeric(grid$Lat))
#' d3 <- st_as_sf(d3, coords = c("x","y"))
#' st_crs(d3) <- st_crs(4326)
#' library(vein)
#' g <- st_transform(st_as_sf(vein::make_grid(as(st_transform(d3, 31983),
#'                   "Spatial"),
#'                grid$DX*1000, grid$DX*1000, T)), 4326)
#' streets$id <- NULL
#' per <- c(1, 0, 0, 0, 0)
#' teste <- streetDist(emission = 1000000, dist = per, grid = g,
#'                     osm = streets, epsg = 31983)
#'}

# sf e data.table removidos das dependendencias
# ^R/streetDist.R

streetDist <- function(emission = NULL,
                       dist = NULL, # dist comprimento 5
                       grid = NULL, # grid sf
                       osm = NULL,  #streets OSM motorway trunk primary secondary tertiary
                       epsg = NULL){ #sem perfil por enquanto
  .SD = NULL
  id  = NULL
  dist <- dist/sum(dist)
  grido <- grid
  if(exists("epsg")){
    osm <- sf::st_transform(osm, epsg)
    grid <- sf::st_transform(grid, epsg)
    osm$LKM <- sf::st_length(osm)
    #motorway
    osm_m <- osm[osm$highway == "motorway" |
                   osm$highway == "motorway_link", ]
    osm_m$x <- emission*dist[1]*osm_m$LKM/sum(osm_m$LKM, na.rm = T)
    #trunk
    osm_t <- osm[osm$highway == "trunk" |
                   osm$highway == "trunk_link", ]
    osm_t$x <- emission*dist[2]*osm_t$LKM/sum(osm_t$LKM, na.rm = T)
    #primary
    osm_p <- osm[osm$highway == "primary" |
                   osm$highway == "primary_link", ]
    osm_p$x <- emission*dist[3]*osm_p$LKM/sum(osm_p$LKM, na.rm = T)
    #secondary
    osm_s <- osm[osm$highway == "secondary" |
                   osm$highway == "secondary_link", ]
    osm_s$x <- emission*dist[4]*osm_s$LKM/sum(osm_s$LKM, na.rm = T)
    #tertiary
    osm_te <- osm[osm$highway == "tertiary" |
                    osm$highway == "tertiary_link", ]
    osm_te$x <- emission*dist[5]*osm_te$LKM/sum(osm_te$LKM, na.rm = T)
    osm_all <- rbind(osm_m, osm_t, osm_p, osm_s, osm_te)
    osmgrid <- sf::st_intersection(osm_all, grid)
    osmgrid$LKM2 <- sf::st_length(sf::st_cast(osmgrid[sf::st_dimension(osmgrid) == 1,]))
    osmgridg <- data.table::data.table(osmgrid)
    osmgridg$x <- as.numeric(osmgridg$x) * as.numeric(osmgridg$LKM2/osmgridg$LKM)
    dfm <- osmgridg[, lapply(.SD, sum, na.rm=TRUE),
                    by = id,
                    .SDcols = "x" ]
    gx <- data.frame(id = grid$id)
    gx <- merge(gx, dfm, by="id", all.x = T)
    gx <- sf::st_transform(st_sf(gx, geometry = grid$geometry), sf::st_crs(grido))
  } else {
    osm$LKM <- sf::st_length(osm)
    #motorway
    osm_m <- osm[osm$highway == "motorway" |
                   osm$highway == "motorway_link", ]
    osm_m$x <- emission*dist[1]*osm_m$LKM/sum(osm_m$LKM, na.rm = T)
    #trunk
    osm_t <- osm[osm$highway == "trunk" |
                   osm$highway == "trunk_link", ]
    osm_t$x <- emission*dist[2]*osm_t$LKM/sum(osm_t$LKM, na.rm = T)
    #primary
    osm_p <- osm[osm$highway == "primary" |
                   osm$highway == "primary_link", ]
    osm_p$x <- emission*dist[3]*osm_p$LKM/sum(osm_p$LKM, na.rm = T)
    #secondary
    osm_s <- osm[osm$highway == "secondary" |
                   osm$highway == "secondary_link", ]
    osm_s$x <- emission*dist[4]*osm_s$LKM/sum(osm_s$LKM, na.rm = T)
    #tertiary
    osm_te <- osm[osm$highway == "tertiary" |
                    osm$highway == "tertiary_link", ]
    osm_te$x <- emission*dist[5]*osm_te$LKM/sum(osm_te$LKM, na.rm = T)

    osm_all <- rbind(osm_m, osm_t, osm_p, osm_s, osm_te)
    osmgrid <- st_intersection(osm_all, grid)
    osmgrid$LKM2 <- st_length(st_cast(osmgrid[st_dimension(osmgrid) == 1,]))
    osmgridg <- data.table::data.table(osmgrid)
    osmgridg$x <- as.numeric(osmgridg$x) * as.numeric(osmgridg$LKM2/osmgridg$LKM)
    dfm <- osmgridg[, lapply(.SD, sum, na.rm=TRUE),
                    by = id,
                    .SDcols = "x" ]
    gx <- data.frame(id = grid$id)
    gx <- merge(gx, dfm, by="id", all.x = T)
    gx <- sf::st_sf(gx, geometry = grid$geometry)
  }
  return(gx)
}
