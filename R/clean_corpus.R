#' @title Clean GDD Corpus using a set of boolean rules.
#' @description Uses a set of boolean based rules to clean the corpus of the GeoDeepDive NLP return.
#' @param x The GeoDeepDive corpus document
#' @param pubs The publications, linked using the \code{_gddid} field.
#' @return A \code{list} object with two elements, a pared nlp \code{data.frame} and information about the \code{data.frame}, the cut publications (\code{drop}) and the retained publications (\code{keep}).
#' @export
#' @import assertthat

clean_corpus <- function(x, pubs) {

  ## Assertions:
  # Expects the deep dive corpus:
  is_gdd <- assertthat::assert_that(x %has_name% '_gddid') & 
    assertthat::assert_that(x %has_name% 'word') & 
    assertthat::assert_that(x %has_name% 'sentence')
  
  if(!is_gdd) { stop('The parameter `x` is not a valid GeoDeepDive `data.frame`.') }
  
  # Expects the bibliographic information
  is_pub <- assertthat::see_if(pubs %has_name% '_gddid') & 
    assertthat::see_if(pubs %has_name% 'title')
  
  if(!is_pub) { stop('The parameter `x` is not a valid GeoDeepDive publication `data.frame`.') }
  
  ird_bird <- stringr::str_detect(x$word, "IRD")
  
  # Ensures (or tries to ensure) that the term IRD is on its own.
  ird_ice <- stringr::str_detect(x$word, "(ice).*(rafted).*(debris)")
  ird_word <- stringr::str_detect(x$word, "[,\\{/]IRD[,-/]")
  
  # Removes by French address line
  france <- stringr::str_detect(x$word, "([Cc]edex.*[Ff]rance)|(CNRS)|(www\\.ird\\.nc)|([Ff]rench).*(IRD)")
  
  #similar_words<- stringr::str_detect(x$word, "([Th]ird) | ([Bb]ird)")
  
  # Where IRD is only in the references:
  # Find IRD sentence by gddid, and find 'Reference' (or whatever) sentence.
  # If all IRD sentences are at a higher index then references, then FALSE
  # Or do we remove everything after the references?
  
  refs <- stringr::str_detect(x$word, "References")
  
  gd_sent <- data.frame(index = which(refs|ird_bird),
                        gddid = x$`_gddid`[refs|ird_bird],
                         sent = x$sentence[refs|ird_bird],
                          ref = refs[refs|ird_bird],
                         bird = ird_bird[refs|ird_bird],
                      drop_gd = NA,
                      stringsAsFactors = FALSE)
  
  # Go through each paper in the table:
  for(i in unique(gd_sent$gddid)) {

    if(any(gd_sent$gddid == i & gd_sent$ref == TRUE)){
      # This needs to be tested!
      ref_sent <- min(gd_sent$sent[gd_sent$gddid == i & gd_sent$ref == TRUE])
      
      nogood <- all(gd_sent$sent[gd_sent$gddid == i & gd_sent$bird == TRUE] >= ref_sent)
      
      if(nogood) {
        gd_sent$drop_gd[gd_sent$gddid == i] <- TRUE
      } else {
        gd_sent$drop_gd[gd_sent$gddid == i] <- FALSE
      }
    } else {
      gd_sent$drop_gd[gd_sent$gddid == i] <- FALSE
    }
  }
  
  reference_drops <- x$`_gddid` %in% unique(gd_sent$gddid[gd_sent$drop_gd])
  
  # gddid & (sent < ref_sent)
  
  # So, for each unique gddid, keep it if the ref sent is greater than all the bird sent?
  
  # Put together all the booleans now:
  #good_gddid <- which(ird_bird & ((ird_word | ird_ice) & !france) & !reference_drops)
  good_gddid <- which(ird_bird & ((ird_word | ird_ice)) & !france & !reference_drops)
  
  gddid_all <- unique(x$`_gddid`[good_gddid])
  
  return(list(nlp = x[x$`_gddid` %in% gddid_all,],
          gddlist = list(drop = pubs$`_gddid`[!pubs$`_gddid` %in% gddid_all],
                              keep = pubs$`_gddid`[pubs$`_gddid` %in% gddid_all])))
}

#compiles a list of cleaned up gddids, as well as the list of gddids it drops