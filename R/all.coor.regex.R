#' @title Find out whether a sentence contains a coordinate.
#' @param dms_regex The input regex for coordinates written in dms format
#' @param dd_regex The input regex for coordinates written in dd format
#' This script is specifically for the sentence.distribution.R file
#' 

all.coor.regex <- function (dms_regex, dd_regex){
  returnValue
  if (isTRUE(dms_regex) || isTRUE(dd_regex)){
    returnValue <- TRUE
  } else {
    returnValue <- FALSE
  }
  return(returnValue)
}