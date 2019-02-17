#' @title Match regular expressions and words and return a logical parameter of T/F.
#' @param regEx The input regular expression
#' @param df The input data frame with a column named "word" that contains words from literatures
#' @param i The input index regarding the row in the database that is currently processing
#' This script is specifically for the sentence.distribution.R file
#' 

regex.matching <- function(regEx, df, i){
  returnLogic <- FALSE
  detect <- str_detect(df$word[i], regEx)
  if(detect){
      returnLogic <- TRUE
    } 
  return(returnLogic)
}
