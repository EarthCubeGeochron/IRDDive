#' @title Match regular expressions and words and return a vector of T/F.
#' @param regEx The input regular expression
#' @param df The input data frame with a column named "word" that contains words from literatures
#'

#df = full_nlp
#regEx <- "[\\{,][-]?[1]?[0-9]{1,2}\\.[0-9]{1,}[,]?[NESWnesw],"
match.regex <- function(regEx, df){
  detectVector <- vector()
  for(i in 1:nrow(df)){
    detect <- str_detect(df$word[i], regEx)
    if(detect){
      detectVector <- c(detectVector, TRUE)
    } else {
      detectVector <- c(detectVector, FALSE)
    }
  }
  return(detectVector)
}
