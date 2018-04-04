#' @title Extract column text from GeoDeepDive text
#' @description Given a set of column headings in a document find the text strings that contain each column.
#' @param sentence A character string from the NLP \code{sentence} field that likely contains a table.
#' @param colheaders sdfs
#' @example 


#rise <- nlp %>% filter(`_gddid` == "54b43279e138239d868524dc")
#rise <- rise[which(regexpr('Core,inventory', rise$word) > 0),]

get_ddtabs <- function(sentence, colheaders) {
  # I think we need to figure out the locations of the column headers, 
  # then pass over and figure out how many words there are between each set of columns.
  
  positions <- str_locate_all(sentence, colheaders)
  
  for (i in 1:length(positions)) {
    
    if (nrow(positions[[i]]) > 1 & !i == length(positions)) {
      # This eliminates any word positions that occur after the sudsequent column header.
      positions[[i]] <- positions[[i]][positions[[i]][,'start'] < positions[[i + 1]][,'start'], ]
    }
    
    if (nrow(positions[[i]]) > 1) {
      # We assume that the column header is the last occurrence of the searched term.
      positions[[i]] <- positions[[i]][which.max(positions[[i]][,1]), ]
    }
  }
  
  positions <- do.call(rbind, positions) %>% as_data_frame
  positions$columns <- colheaders
  
  commas <- str_locate_all(sentence, ",")[[1]] %>% as_data_frame

  ends <- c(findInterval(positions$end, commas$end), length(commas$end)) + 1
  starts <- c(findInterval(positions$start, commas$end), length(commas$end)) + 1
  
  column_lengths <- ends[-1] - starts[-length(starts)]
  
  words <- strsplit(sentence, ',')[[1]]
  
  positions$line <- NA
  
  for (i in 1:nrow(positions)) {

    positions$line[i] <- paste0(words[(ends[i] + 1):(starts[i+1] - 1)], collapse = ',')
    
  }
  
  return(positions)
}

