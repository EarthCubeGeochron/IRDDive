#' @title Find paper ID based on vectors.
#' @param vec The input vector of T/F returned from match.regex
#' @param df The input data frame with a column named "_gddid", the id of the article
#'

#df = full_nlp
#vec <- detectVector
in.paper <- function(vec, df){
  paperIds <- vector()
  for(i in 1:nrow(df)){
    if(vec[i]){
      paperIds <- c(paperIds, df$`_gddid`[i])
    }
  }
  return(paperIds)
}
