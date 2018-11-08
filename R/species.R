#' Species mapping tables
#'
#' @description set of tables for speciation.
#'
#' specie map from 1 to 4 are from Li et al, 2014 taken into account several sources of pollutants.
#' specie map 5 to 8 is a list of veicular voc speciation by fuel and emission process from USP-IAG
#' tunel experiments (ref2) emited by the process of exhaust (through the exhaust pipe),
#' liquid (carter and evaporative) and vapor (fuel transfer operations)
#'
#' @format A list of numeric vectors.
#'
#' #' @seealso \code{\link{speciation} and \code{\link{read}}
#'
#' @references
#' Li, M., Zhang, Q., Streets, D. G., He, K. B., Cheng, Y. F., Emmons, L. K., ... & Su, H. (2014).
#' Mapping Asian anthropogenic emissions of non-methane volatile organic compounds to multiple
#' chemical mechanisms. Atmos. Chem. Phys, 14(11), 5617-5638.
#'
#' @examples
#' # load the mapping tables
#' data(species)
#' # names of eath mapping tables
#' names(species)
#' # name of a specific (first) mapping table
#' names(species[1])
#' # names of species contained in the (first) mapping table
#' names(species[[1]])
#' @usage data(species)
#' @docType data
"species"
