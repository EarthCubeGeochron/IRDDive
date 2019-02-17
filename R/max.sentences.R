#' @title Find out the max sentence id in an article.
#' @param df The input data frame with a column named "sentence" that contains sentence ids of the literature
#' @param i The input index regarding the row in the database that is currently processing
#' This script is specifically for the sentence.distribution.R file
#' 

max.sentences <- function(df, i){
  returnValue <- df$sentence[i]
  while((df$`_gddid`[i+1] ==df$`_gddid`[i]) && (i < nrow(df))){
    returnValue <- returnValue + 1
    i <- i+1
  }
  return(returnValue)
}