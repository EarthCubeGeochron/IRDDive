#' @title Generate a dataframe containing information that can be used to analyze the relative distribution of ages and coordinates in a paper.
#' @param df The input dataframe (the NLP file)
#' @param dms_regex The input regex for coordinates written in dms format
#' @param dd_regex The input regex for coordinates written in dd format
#' @param age_range The input regex for age ranges
#' @param age_yr1 The input regex for ages written in one of the two common xxx yr formats
#' @param age_yr2 The input regex for ages written in one of the two common xxx yr formats
#' @param age_ka The input regex for ages written in xxx ka format
#' @param age_bp The input regex for ages written in xxx bp format
#' This script is specifically for the sentence.distribution.R file
#' 


sentence.distribution <- function (df, dms, dd, age_range, age_yr1, age_yr2, age_ka, age_bp){
  #initializing the data frame that will return
  return_df <- data.frame(
    gddid = character(),
    sentenceID = integer(),
    maxSentenceID = integer(),
    distribution = double(),
    ifAge = logical(),
    ifCoor = logical(),
    stringsAsFactors=FALSE
  ) 
  #loop through all sentences:
  for(i in 1:nrow(df)){
    # get the gddid
    gddid_i <- df$`_gddid`[i]
    # get the sentenceID
    sentenceID_i <- df$sentence[i]
    # get the maxSentenceID
    maxSentence_i <- max.sentences(df, i)
    # get the relative distribution
    dist_i <- sentenceID_i/maxSentence_i
    # check if it has an age
    age_logical_i <- all.age.regex(regex.matching(age_range, df, i), 
                           regex.matching(age_yr1, df, i), regex.matching(age_yr2, df, i), 
                           regex.matching(age_ka, df, i), regex.matching(age_bp, df, i))
    # check if it has a location
    coor_logical_i <- all.coor.regex(regex.matching(dms, df, i), regex.matching(dd, df, i))
    
    #constructing the return data frame
    return_df[i, ] <- c(gddid_i, sentenceID_i, maxSentence_i, dist_i, age_logical_i, coor_logical_i)
    
    #progress marker
    cat("sentence distribution for age looping at row", i, '\n')
  }
  return(return_df)
}