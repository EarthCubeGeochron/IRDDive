
# The first chunk of empty-spaces file

library(geodiveR)

library(jsonlite)
library(readr)
library(dplyr)
library(stringr)
library(leaflet)
library(purrr)
library(DT)
library(assertthat)

sourcing <- list.files('R', full.names = TRUE) %>% 
  map(source, echo = FALSE, print = FALSE, verbose = FALSE)

publications <- fromJSON(txt = 'input/bibjson', flatten = TRUE)
full_nlp <- readr::read_tsv('input/sentences_nlp352', 
                            trim_ws = TRUE,
                            col_names = c('_gddid', 'sentence', 'wordIndex', 
                                          'word', 'partofspeech', 'specialclass', 
                                          'wordsAgain', 'wordtype', 'wordmodified'))

nlp_clean <- clean_corpus(x = full_nlp, pubs = publications) #uses the clean_corpus.R function

nlp<-nlp_clean$nlp

#Regexes that we have so far

age_range_regex <- "(\\d+(?:[.]\\d+)*),((?:-{1,2})|(?:to)),(\\d+(?:[.]\\d+)*),([a-zA-Z]+,BP),"

age_yr_regex <-  ",(\\d+(?:[\\.\\s]\\d+){0,1}),yr,"

age_yr2_regex <- ",(\\d+(?:[\\.\\s]\\d+){0,1}),.*?,yr,"

age_ka_regex <- ",(\\d+(?:[\\.\\s]\\d+){0,1}),ka,"

age_bp_regex <- ",(\\d+(?:[\\.\\s]\\d+){0,1}),BP,"

dms_regex <- "[\\{,]([-]?[1]?[0-9]{1,2}?)(?:(?:,[°◦o],)|(?:[O])|(?:,`{2},))([1]?[0-9]{1,2}(?:.[0-9]*)),[′'`]?[,]?([[0-9]{0,2}]?)[\"]?[,]?([NESWnesw]?),"

dd_regex <- "[\\{,][-]?[1]?[0-9]{1,2}\\.[0-9]{1,}[,]?[NESWnesw],"

# Test the sentence distribution function: 
# Generating a dataframe containing 1)gddid, 2)sentence id, 3)max sentence id in each paper, 4)relative distribution
# of the sentence, 5) if this sentence contains an age, and 6) if this sentence contains a coordinate

newFrame <- sentence.distribution(nlp, dms_regex, dd_regex, age_range_regex, age_yr_regex, age_yr2_regex, age_ka_regex, age_bp_regex)

