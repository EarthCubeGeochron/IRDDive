#df <- full_nlp
#regex1 <- "[\\{,]([-]?[1]?[0-9]{1,2}?)(?:(?:,[°◦o],)|(?:[O])|(?:,`{2},))([1]?[0-9]{1,2}(?:.[0-9]*)),[′'`]?[,]?([[0-9]{0,2}]?)[\"]?[,]?([NESWnesw]?),"
#regex2 <-  ",(\\d+(?:[\\.\\s]\\d+){0,1}),ka,"
#vecDate <- match.regex(regex2,df)
#vecCoor <- match.regex(regex1,df)

match.dist <- function(vecDate, vecCoor, df){
  # Create an empty vector for the output
  dist <- vector()
  # create an empty vector for daughtor vectors of ages
  dist_each_coor <- list()
  # Go through the coordinate vector
  i=1
  while(i <= length(vecCoor)){
    # When the value of the coordinate vector at i is true
    if(isTRUE(vecCoor[i])){
      # initiate a counter for the inner loop of date vector
      j <- 1
      # Go through the date vector
      while (j <= length(vecDate)){
        # when the value of the date vector at j is true
        if(isTRUE(vecDate[j])){
          # Check if it is still in the same article of the ith sentence of the coor vector
          if(isTRUE(df$`_gddid`[j]==df$`_gddid`[i])){
            # Calculate the distance if in the same article and append it to the daughtor vector
            d <- abs(j-i)
            dist_each_coor <- c(dist_each_coor, d)
            # Update the counter
            j <- j + 1
          } else {
            # if it is no longer in the same article, end the inner loop
            j <- length(vecDate) + 1
            dist_each_coor <- 0
          }
        } else {
          # When the value of the date vector at j is false, check j+1
          j <- j + 1
          dist_each_coor <- 0
        }
        # Append the daughtor vector to the output vector
        dist[i] <- dist_each_coor
      }
    } else {
      dist[i] <- 0
    }
    i <- i+1
    j <- 1
  }
  return(dist)
}

# This function returns a vector composed by vectors. An inner vector will contain distances
# of ages from a coordinate pair if they are within the same article
