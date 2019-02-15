#' @title Find out whether a sentence contains an age.
#' age_range, age_yr1, age_yr2, age_ka, age_bp are input regexes for different formats of ages
#' This script is specifically for the sentence.distribution.R file
#' 

all.age.regex <- function (age_range, age_yr1, age_yr2, age_ka, age_bp){
  returnValue
  if (isTRUE(age_range) || isTRUE(age_yr1) || isTRUE(age_yr2) || isTRUE(age_ka) || isTRUE(age_bp) ){
    returnValue <- TRUE
  } else {
    returnValue <- FALSE
  }
  return(returnValue)
}