clean_corpus <- function(x) {

  ird_bird <- stringr::str_detect(x$word, "IRD")
   ird_ice <- stringr::str_detect(x$word, "(ice).*(rafted).*(debris)")
  ird_word <- stringr::str_detect(x$word, "[,\\{/]IRD[,-/]")
  
  # Removes by French address line
    france <- stringr::str_detect(x$word, "([Cc]edex.*[Ff]rance)|(CNRS)")
  
  
  good_gddid <- which(ird_bird & (ird_word | ird_ice) & !france)
  
  gddid_all <- unique(x$`_gddid`[good_gddid])
  
  return(x[x$`_gddid` %in% gddid_all])
  
}
  
  
  gddid_all[which(!gddid_all %in% gddid_france)]
  
  return(cleaned)
}

