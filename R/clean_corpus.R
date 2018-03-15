clean_corpus <- function(x) {

  ird_bird <- stringr::str_detect(x$word, "IRD")
  
  # Ensures (or tries to ensure) that the term IRD is on its own.
   ird_ice <- stringr::str_detect(x$word, "(ice).*(rafted).*(debris)")
  ird_word <- stringr::str_detect(x$word, "[,\\{/]IRD[,-/]")
  
  # Removes by French address line
  france <- stringr::str_detect(x$word, "([Cc]edex.*[Ff]rance)|(CNRS)")
  
  # Where IRD is only in the references:
  # Find IRD sentence by gddid, and find 'Reference' (or whatever) sentence.
  # If all IRD sentences are at a higher index then references, then FALSE
  
  refs <- stringr::str_detect(x$word, "References")
  gd_sent <- data.frame(index = which(refs|ird_bird),
                        gddid = x$`_gddid`[refs|ird_bird],
                        sent  = x$sentence[refs|ird_bird],
                        ref   = refs[refs|ird_bird],
                        bird = ird_bird[refs|ird_bird])
  
  # So, for each unique gddid, keep it if the ref sent is greater than all the bird sent?
  
  # Put together all the booleans now:
  good_gddid <- which(ird_bird & (ird_word | ird_ice) & !france)
  
  gddid_all <- unique(x$`_gddid`[good_gddid])
  
  return(x[x$`_gddid` %in% gddid_all])
  
}