#' @title Group the NLP file every x sentences in the same article.
#' @param x how many sentences to be grouped together
#' @param file the NLP data frame to be grouped
#' 

groupNLP <- function(file, number_of_sentence){
  #number_of_sentence <- 5
  #file <- nlp_test
  # Copy the input NLP data.frame to a temporary data.frame
  group_nlp = NULL
  group_nlp <- file
  
  # Build an empty data frame with 2 columns: _gddid and group_id
  df = NULL
  df <- data.frame(matrix(vector(), nrow=nrow(group_nlp) ,ncol=3))
  colnames(df) <-c("_gddid","sentence","group_id")
  
  # Copy the _gddid from file to df
  df$`_gddid` <- group_nlp$`_gddid`
  df$sentence <- group_nlp$sentence

  
  # add values to the counter column and they will be keys for aggregation later
  counter <- 2
  placement <- 1
  group_id <- 1
 
  df$group_id[1] <- group_id
  placement <- placement + 1
  while (counter < nrow(group_nlp) +1){
    if (isTRUE(df$`_gddid`[counter] == df$`_gddid`[counter - 1]) & placement <= number_of_sentence) {
        df$group_id[counter] <- group_id
        counter <- counter + 1
        placement <- placement + 1
    } 
    else if (isTRUE(df$`_gddid`[counter] == df$`_gddid`[counter - 1]) & placement > number_of_sentence) {
      placement <-1
      group_id <- group_id + 1
      df$group_id[counter] <- group_id
      counter <- counter + 1
      placement <- placement + 1
    }
    else {
      group_id <- group_id + 1
      df$group_id[counter] <- group_id
      placement <- 1
      counter <- counter + 1
    }
  }
  
  # Merge df to group_nlp (key = _gddid and sentence) 
  dt_new <- merge(df,group_nlp,by=c("_gddid","sentence"))
  
  # Aggregate by "group_id"
  output_df <-  aggregate(.~group_id, dt_new, paste, collapse = ",")

  # clear up of potential extra rows
  for (i in 1:nrow(output_df)){
    output_df$`_gddid`[i] <- gsub(",.*", "", output_df$`_gddid`[i])
  }
  
  # return output
  return(output_df)
  
}

