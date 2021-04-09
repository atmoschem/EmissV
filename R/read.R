#' Read NetCDF data from global inventories
#'
#' @description Read data from global inventories. Several files can be read to produce one
#' emission output and/or can be splitted into several species
#'
#' @return Matrix or raster
#'
#' @param file file name or names (variables are summed)
#' @param version Character; One of  of the following:
#' \tabular{lllll}{
#'   \strong{argument}\tab \strong{tested}\tab \strong{region}\tab \strong{resolution}\tab \strong{projection}\cr
#'   EDGAR\tab 4.32 and 5.0 \tab Global \tab 0.1 x 0.1 ° \tab  longlat\cr
#'   EDGAR_HTAPv2\tab 2.2 \tab Global \tab 0.1 x 0.1 °  \tab  longlat\cr
#'   GAINS\tab v5a \tab Global \tab 0.5 x 0.5 ° \tab  longlat\cr
#'   RCP\tab RCP3PD Glb \tab Global \tab 0.5 x 0.5 °  \tab  longlat\cr
#'   MACCITY\tab 2010 \tab Global \tab 0.5 x 0.5 °  \tab  longlat\cr
#'   FFDAS\tab 2.2 \tab Global \tab 0.1 x 0.1 ° \tab  longlat\cr
#'   ODIAC\tab 2020 \tab Global \tab 1 x 1 ° \tab  longlat\cr
#'   VULCAN\tab 3.0 \tab US \tab 1 x 1 Km \tab  lcc\cr
#'   ACES\tab 2020 \tab NE US \tab 1 x 1 km \tab  lcc\cr
#'}
#' @param coef coefficients to merge different sources (file) into one emission
#' @param spec numeric speciation vector to split emission into different species
#' @param hour hour of the emission (only for ACES)
#' @param month the desired month of the inventory (MACCITY and ODIAC)
#' @param year scenario index (only for GAINS)
#' @param categories considered categories (for MACCITY/GAINS variable names), empty for use all
#' @param as_raster return a raster (default) or matrix (with units)
#' @param skip_missing return a zero emission and a warning for missing files/variables
#' @param verbose display additional information
#'
#' @note for EDGAR (all versions), GAINS, RCP and MACCTITY, please use flux (kg m-2 s-1) NetCDF file.
#'
#' @seealso \code{\link{rasterSource}} and \code{\link{gridInfo}}
#'
#' @export
#'
#' @import raster
#' @import ncdf4
#' @importFrom units as_units set_units
#'
#' @seealso \code{\link{species}}
#'
#' @source Read abbout EDGAR at http://edgar.jrc.ec.europa.eu and MACCITY at
#' http://accent.aero.jussieu.fr/MACC_metadata.php
#'
#' @references
#' Janssens-Maenhout, G., Dentener, F., Van Aardenne, J., Monni, S., Pagliari, V., Orlandini,
#' L., ... & Wankmüller, R. (2012). EDGAR-HTAP: a harmonized gridded air pollution emission dataset
#' based on national inventories. European Commission Joint Research Centre Institute for
#' Environment and Sustainability. JRC 68434 UR 25229 EUR 25229, ISBN 978-92-79-23123-0.
#'
#' Lamarque, J.-F., Bond, T. C., Eyring, V., Granier, C., Heil, A., Klimont, Z., Lee, D., Liousse,
#' C., Mieville, A., Owen, B., Schultz, M. G., Shindell, D., Smith, S. J., Stehfest, E.,
#' Van Aardenne, J., Cooper, O. R., Kainuma, M., Mahowald, N., McConnell, J. R., Naik, V.,
#' Riahi, K., and van Vuuren, D. P.: Historical (1850-2000) gridded anthropogenic and biomass
#' burning emissions of reactive gases and aerosols: methodology and application,
#' Atmos. Chem. Phys., 10, 7017-7039, doi:10.5194/acp-10-7017-2010, 2010.
#'
#' Z Klimont, S. J. Smith and J Cofala The last decade of global anthropogenic sulfur dioxide:
#' 2000–2011 emissions Environmental Research Letters 8, 014003, 2013
#'
#' Gurney, Kevin R., Jianming Liang, Risa Patarasuk, Yang Song, Jianhua Huang, and
#' Geoffrey Roest (2019) The Vulcan Version 3.0 High-Resolution Fossil Fuel CO2 Emissions
#' for the United States. Nature Scientific Data.
#'
#' @examples \donttest{
#' dir.create(file.path(tempdir(), "EDGARv432"))
#' folder <- setwd(file.path(tempdir(), "EDGARv432"))
#'
#' url <- "http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v432_AP/NOx"
#' file <- 'v432_NOx_2012.0.1x0.1.zip'
#'
#' download.file(paste0(url,'/TOTALS/',file), file)
#'
#' unzip('v432_NOx_2012.0.1x0.1.zip')
#'
#' nox  <- read(file    = dir(pattern = '.nc'),
#'              version = 'EDGAR',
#'              spec    = c(E_NO  = 0.9 ,   # 90% of NOx is NO
#'                          E_NO2 = 0.1 ))  # 10% of NOx is NO2
#' setwd(folder)
#'
#' sp::spplot(nox$E_NO, scales = list(draw=TRUE),
#'            xlab="Lat", ylab="Lon",
#'            main="NO emissions from EDGAR (in g / m2 s)")
#'
#' d1  <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
#' NO  <- emission(grid = d1, inventory = nox$E_NO, pol = "NO", mm = 30.01, plot = TRUE)
#'}

read <- function(file = file.choose(), version = NA, coef = rep(1,length(file)),
                 spec = NULL, year = 1,month = 1, hour = 1, categories,
                 as_raster = TRUE, skip_missing = FALSE, verbose = TRUE){

  if(is.na(version)){                 # nocov start
    cat('versions supported:\n')
    cat(' - EDGAR\n')
    cat(' - EDGAR_HTAPv2\n')
    cat(' - GAINS\n')
    cat(' - RCP\n')
    cat(' - MACCITY\n')
    cat(' - FFDAS\n')
    cat(' - ODIAC\n')
    cat(' - VULCAN\n')
    cat(' - ACES\n')
    stop('check version argument')    # nocov end
  }

  raster_to_ncdf <- function(r,na_value = 0){      # nocov start
    N_times <- dim(r)[3]
    a       <- array(na_value,c(dim(r)[2],dim(r)[1],N_times))
    for(i in 1:N_times){
      a[,,i] <- as.matrix(t(raster::flip(r[[i]],2)))
    }
    return(a)
  }                                                # nocov end

  if(length(coef) != length(file)){ # nocov start
    cat('file and coef has different length, check the read arguments!\n')
    cat('file:\n ')
    cat(paste0(1:length(file),' ',file,'\n'))
    cat('coef:\n ')
    cat(paste0(1:length(coef),' ',coef,'\n'))
  }                                 # nocov end

  if(is.list(coef))
    coef <- as.numeric(as.character(unlist(coef))) #nocov
  if(is.list(spec))
    spec <- as.numeric(as.character(unlist(spec))) #nocov

  if(!missing(categories) && skip_missing == TRUE){   #nocov start
    ed   <- ncdf4::nc_open(file[1])
    if(!(categories %in% names(ed$var))){
      cat('category',categories,'is missing, returning zero emission grid!\n')
      version = "ZEROS"
      # warning(categories,' is missing on file: ',file,' using zero emission!\n')
      varall    <- matrix(NA, ncol = 360, nrow = 720)
      if(as_raster){
        rz <- raster::raster(0.0 * varall,xmn=0,xmx=360,ymn=-90,ymx=90)
        values(rz) <- rep(0,ncell(rz))
        raster::crs(rz) <- "+proj=longlat"
      }

      # if(as_raster){
      #   r      <- raster::raster(x = matrix(0,nrow = 360,ncol = 720),xmn=0,xmx=360,ymn=-90,ymx=90)
      #   raster::crs(r) <- "+proj=longlat +ellps=GRS80 +no_defs"
      #   rz     <- r
      #   # return(r)
      # }else{
      #   # return(matrix(0,nrow = 720,ncol = 360))
      #   varall <- matrix(0,nrow = 720,ncol = 360)
      # }
    }
  }                                                # nocov end

  if(version == "GAINS"){                          # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('date',             name, invert = TRUE, value = TRUE)
    name <- grep('crs',              name, invert = TRUE, value = TRUE)
    name <- grep('gridcell_area',    name, invert = TRUE, value = TRUE)
    name <- grep('emis_all',         name, invert = TRUE, value = TRUE)
    name <- grep('emiss_sum',        name, invert = TRUE, value = TRUE)
    name <- grep('molecular_weight', name, invert = TRUE, value = TRUE)

    if(verbose)
      cat(paste0("reading",
                 " ",version,
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))

    data <- as.Date('1850-01-01')   # units is days since 1850-01-01 00:00
    data <- data + ncdf4::ncvar_get(ed,'time')[year]
    if(verbose)
      cat(paste0("scenario: year ",format(data,"%Y"),"\n"))

    var    <- ncdf4::ncvar_get(ed,name[1])
    var    <- var[,,year]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    r      <- raster::raster(x = var,xmn=-180,xmx=180,ymn=-90,ymx=90)
    raster::crs(r) <- "+proj=longlat"
    # area   <- raster::area(r)
    # area   <- raster::flip(area,2)
    # area   <- raster::t(area)
    # area   <- raster::as.matrix(area)
    # area   <- units::as_units(area,"km2")
    if(as_raster){
      rz <- raster::raster(0.0 * var, xmn=-180,xmx=180,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
        name <- grep('date',             name, invert = TRUE, value = TRUE)
        name <- grep('crs',              name, invert = TRUE, value = TRUE)
        name <- grep('gridcell_area',    name, invert = TRUE, value = TRUE)
        name <- grep('emis_all',         name, invert = TRUE, value = TRUE)
        name <- grep('molecular_weight', name, invert = TRUE, value = TRUE)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        if(verbose)
          cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,year]
        var_a  <- units::as_units(1000 * var_a,"g m-2 s-1")
        # var_a  <- var_a / area
        # var_a  <- units::set_units(var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = var,xmn=-180,xmx=180,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        varall <- varall + var * coef[i]
      }
    }
  }                                              # nocov end

  if(version == "RCP"){                          # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('date',             name, invert = TRUE, value = TRUE)
    name <- grep('crs',              name, invert = TRUE, value = TRUE)
    name <- grep('gridcell_area',    name, invert = TRUE, value = TRUE)
    name <- grep('emis_all',         name, invert = TRUE, value = TRUE)
    name <- grep('emiss_sum',        name, invert = TRUE, value = TRUE)
    name <- grep('molecular_weight', name, invert = TRUE, value = TRUE)

    if(verbose)
      cat(paste0("reading",
                 " ",version,
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))

    data <- as.Date('1850-01-01')   # units is days since 1850-01-01 00:00
    data <- data + ncdf4::ncvar_get(ed,'time')[year]
    if(verbose)
      cat(paste0("scenario: year ",format(data,"%Y"),"\n"))

    var    <- ncdf4::ncvar_get(ed,name[1])
    var    <- var[,,year]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    r      <- raster::raster(x = var,xmn=0,xmx=360,ymn=-90,ymx=90)
    raster::crs(r) <- "+proj=longlat"
    if(as_raster){
      rz <- raster::raster(0.0 * var, xmn=-0,xmx=360,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      if(verbose)
        cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
        name <- grep('date',             name, invert = TRUE, value = TRUE)
        name <- grep('crs',              name, invert = TRUE, value = TRUE)
        name <- grep('gridcell_area',    name, invert = TRUE, value = TRUE)
        name <- grep('emis_all',         name, invert = TRUE, value = TRUE)
        name <- grep('molecular_weight', name, invert = TRUE, value = TRUE)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        if(verbose)
          cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,year]
        var_a  <- units::as_units(1000 * var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        varall <- varall + var * coef[i]
      }
    }
  }                                                # nocov end

  if(version == "MACCITY"){                        # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    if(verbose)
      cat(paste0("reading",
                 " ",version,
                 " emissions for ",
                 format(ISOdate(1996,month,1),"%B"),
                 ", output unit is g m-2 s-1 ...\n"))
    var  <- ncdf4::ncvar_get(ed,name[1])
    var  <- var[,,month]
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var  <- apply(0.0 * var,1,rev)
    if(as_raster){
      r  <- raster::raster(x = 0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      if(verbose)
        cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
      }else{
        name <- categories
      }
      for(j in 1:length(name)){
        cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])[,,month]
        var_a  <- units::as_units(var_a,"g m-2 s-1")
        var_a  <- apply(var_a,1,rev)
        var    <- var + var_a
      }
      if(as_raster){
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  }                                                # nocov end

  if(version == "EDGAR" || version == "EDGAR_v432"){
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    if(verbose)
      cat(paste0("reading",
                 " ",version,
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))
    var    <- ncdf4::ncvar_get(ed,name)
    varall <- units::as_units(0.0 * var,"g m-2 s-1")
    var    <- apply(0.0 * var,1,rev)
    if(as_raster){
      r  <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
      raster::values(rz) <- rep(0,ncell(rz))
      raster::crs(rz) <- "+proj=longlat"
    }

    for(i in 1:length(file)){
      ed   <- ncdf4::nc_open(file[i])
      name <- names(ed$var)
      if(verbose)
        cat(paste0("from ",file[i]),name[1],"x",sprintf("%02.6f",coef[i]),"\n")
      var  <- ncdf4::ncvar_get(ed,name)
      if(as_raster){
        var <- apply(var,1,rev)
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  }

  if(version == "EDGAR_HTAPv2"){  # nocov start
    if(verbose)
      cat(paste0("reading",
                 " ",version,
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))
    ed   <- ncdf4::nc_open(file[1])
    for(i in 1:length(file)){
      if(verbose)
        cat(paste0("from ",file[i]),"x",sprintf("%02.6f",coef[i]),"\n")
      ed   <- ncdf4::nc_open(file[i])
      if(missing(categories)){
        name <- names(ed$var)
        name <- grep('date',         name, invert = TRUE, value = TRUE)
        name <- grep('crs',          name, invert = TRUE, value = TRUE)
        name <- grep('gridcell_area',name, invert = TRUE, value = TRUE)
        name <- grep('emis_all',     name, invert = TRUE, value = TRUE)
        name <- grep('emiss_sum',    name, invert = TRUE, value = TRUE)
      }else{
        name <- categories
      }
      var  <- ncdf4::ncvar_get(ed,name[1])
      var  <- apply(var,1,rev)
      if(as_raster){
        r  <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        rz <- raster::raster(0.0 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        values(rz) <- rep(0,ncell(rz))
        raster::crs(rz) <- "+proj=longlat"
      }
      var_a  <- units::as_units(0.0 * var,"g m-2 s-1")
      varall <- units::as_units(0.0 * var,"g m-2 s-1")
      var    <- units::as_units(0.0 * var,"g m-2 s-1")
      for(j in 1:length(name)){
        if(verbose)
          cat(paste0("using ",name[j]),"\n")
        var_a  <- ncdf4::ncvar_get(ed,name[j])
        var_a  <- apply(var_a,1,rev)
        var_a  <- units::as_units(1000 * var_a,"g m-2 s-1")
        var    <- var + var_a
      }
      if(as_raster){
        var    <- ncdf4::ncvar_get(ed,name[1])
        var    <- apply(var,1,rev)
        r   <- raster::raster(x = 1000 * var,xmn=0,xmx=360,ymn=-90,ymx=90)
        raster::crs(r) <- "+proj=longlat"
        names(r) <- name[1]
        rz       <- rz + r * coef[i]
      }else{
        var    <- units::set_units(1000 * var,"g m-2 s-1")
        varall <- varall + var * coef[i]
      }
    }
  } # nocov end

  if(version == "VULCAN"){                   # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('time_bnds',name, invert = TRUE, value = TRUE)
    name <- grep('crs',      name, invert = TRUE, value = TRUE)
    name <- grep('lat',      name, invert = TRUE, value = TRUE)
    name <- grep('lon',      name, invert = TRUE, value = TRUE)

    var   <- raster::stack(file[1])            # WARNINGS
    times <- ncdf4::ncvar_get(ed,'time_bnds')
    inicial  <- as.POSIXct('2010-01-01 00:00:00',tz = 'GMT')

    time_start <- inicial + 60*60*24* times[1,]
    time_end   <- inicial + 60*60*24* times[2,]

    if(year > length(time_end)){
      stop('wrong armument value, year must be lesser than ',length(time_end),'\n  for ', file)
    }

    # Mg km-2 year-1
    # unidades <- ncdf4::ncatt_get(ed,name[1],'units')$value
    ncdf4::nc_close(ed)

    var               <- var[[year]]
    var[is.na(var[])] <- 0

    # UNIT conversion
    # initial == units: Mg km-2 year-1
    # final   == units: g m-2 s-1

    # 'MgC km-2 year-1' to 'Mg km-2 year-1'
    var = 12.0107 * var

    # 'Mg km-2 year-1' to 'g km-2 year-1'
    # var = 1000000 * var                 # x10**6
    # 'g km-2 year-1' to 'g km-2 s-1'
    var = var / (365 * 24 * 60 * 60)
    # 'g km-2 s-1' to 'g m-2 s-1'
    # var = var / (1000 * 1000)           # /10**6

    if(verbose)
      cat(' var:',  name[1],                       '\n',
          'units:', 'g m-2 s-1',                   '\n',
          'year:',  format(time_start[year], "%Y"),'\n')

    if(as_raster){
      return(var)
    }else{
      a <- raster_to_ncdf(var)
      if(dim(a)[3] == 1) a <- a[,,1,drop = TRUE]
      return(a)
    }
  }                                                        # nocov end

  if(version == "FFDAS"){                       # nocov start
    name  <- 'flux'
    ed    <- ncdf4::nc_open(file[1])
    var   <- raster::stack(file[1])             # WARNINGS
    # kgC m-2 year-1
    # unidades <- ncdf4::ncatt_get(ed,name[1],'units')$value
    ncdf4::nc_close(ed)
    var[is.na(var[])] <- 0

    # UNIT conversion
    # initial == units: kgC m-2 year-1
    # final   == units: g m-2 s-1

    # 'kgC m-2 year-1' to 'g m-2 year-1'
    var = (1000 * 12.0107) * var

    # 'g m-2 year-1' to 'g m-2 s-1'
    var = var / (365 * 24 * 60 * 60)

    if(verbose)
      cat(paste0("reading",
                 " ",version," ",
                 " emissions",
                 ", output unit is g m-2 s-1 ...\n"))

    if(as_raster){
      return(var)
    }else{
      a <- raster_to_ncdf(var)
      if(dim(a)[3] == 1) a <- a[,,1,drop = TRUE]
      return(a)
    }
  }

  if(version == "ODIAC"){                       # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('time_bnds',name, invert = TRUE, value = TRUE)
    name <- grep('crs',      name, invert = TRUE, value = TRUE)
    name <- grep('lat',      name, invert = TRUE, value = TRUE)
    name <- grep('lon',      name, invert = TRUE, value = TRUE)

    var   <- raster::stack(file[1],varname='land')
    var2  <- raster::stack(file[1],varname='intl_bunker')
    var   <- var[[month]] + var2[[month]]
    var[is.na(var[])] <- 0

    # unidades <- ncdf4::ncatt_get(ed,name[1],'units')$value
    ncdf4::nc_close(ed)
    # UNIT conversion
    # initial == units: gC m-2 d-1
    # final   == units: g  m-2 s-1

    # 'gC m-2 d-1' to 'g m-2 d-1'
    var = 12.0107 * var
    # 'g m-2 d-1' to 'g m-2 s-1'
    var = var / (24 * 60 * 60)

    if(verbose)
      cat(paste0("reading",
                 " ",version,
                 " emissions for ",month.name[month],
                 ", output unit is g m-2 s-1 ...\n"))

    if(as_raster){
      return(var)
    }else{
      a <- raster_to_ncdf(var)
      if(dim(a)[3] == 1) a <- a[,,1,drop = TRUE]
      return(a)
    }
  }

  if(version == "ACES"){                       # nocov start
    ed   <- ncdf4::nc_open(file[1])
    name <- names(ed$var)
    name <- grep('time_bnds',name, invert = TRUE, value = TRUE)
    name <- grep('crs',      name, invert = TRUE, value = TRUE)
    name <- grep('lat',      name, invert = TRUE, value = TRUE)
    name <- grep('lon',      name, invert = TRUE, value = TRUE)

    times    <- ncdf4::ncvar_get(ed,'time_bnds')
    inicial  <- as.POSIXct('2013-01-01 00:00:00',tz = 'GMT')

    time_start <- inicial + 60*60* times[1,]
    time_end   <- inicial + 60*60* times[2,]

    if(hour > length(time_end)){
      stop('wrong armument value, month must be lesser than ',length(time_end),'\n  for ', file)
    }

    if(verbose)
      cat(' reading',name[1],
          'from ACES dataset, output units: g m-2 s-1\n',
          'time (',hour,'of',length(time_start),'):',
          format(time_start[hour], "%Y-%m-%d %H:%M"),'\n')

    var   <- raster::stack(file[1],varname=name) # warnings
    var   <- var[[hour]]
    var[is.na(var[])] <- 0

    # unidades <- ncdf4::ncatt_get(ed,name[1],'units')$value
    ncdf4::nc_close(ed)
    # UNIT conversion
    # initial == units: kg km-2 h-1
    # final   == units: g  m-2 s-1

    # 'kg km-2 h-1' to 'g km-2 h-1'
    var = 1000 * var
    # 'g km-2 h-1' to 'g km-2 s-1'
    var = var / (60 * 60)
    # 'g km-2 h-1' to 'g m-2 s-1'
    var = 1000 * 1000 * var

    if(as_raster){
      return(var)
    }else{
      a <- raster_to_ncdf(var)
      if(dim(a)[3] == 1) a <- a[,,1,drop = TRUE]
      return(a)
    }
  }

  if(as_raster){
    if(is.null(spec)){
      if(version == 'GAINS'){
        return(rz)                                          #nocov
      }else{
        return(raster::rotate(rz))
      }
    }else{
      if(verbose)  cat("using the following speciation:\n") # nocov start
      rz_spec <- list()
      for(i in 1:length(spec)){
        if(verbose) cat(paste0(names(spec)[i]," = ",spec[i],"\n"))
        if(version == 'GAINS'){
          rz_spec[[i]] <- rz * spec[i]
        }else{
          rz_spec[[i]] <- raster::rotate(rz * spec[i])
        }
      }
      names(rz_spec) <- names(spec)
      return(rz_spec)                                      # nocov end
    }
  }else{
    if(is.null(spec)){
      return(varall)
    }else{
      if(verbose)  cat("using the following speciation:\n") # nocov start
      var_spec <- list()
      for(i in 1:length(spec)){
        if(verbose) cat(paste0(names(spec)[i]," = ",spec[i],"\n"))
        var_spec[[i]] <- varall * spec[i]
      }
      names(var_spec) <- names(spec)
      return(var_spec)                                     # nocov end
    }
  }
}
