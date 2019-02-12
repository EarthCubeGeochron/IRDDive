---
title: "Ice-Rafted Debris Site Locations over the Pliocene with GeoDeepDive"
author: "Simon Goring and Jeremiah Marsicek"
output:
  html_document:
    code_folding: show
    highlight: pygment
    keep_md: yes
    number_sections: no
    css: style/common.css
  pdf_document:
    latex_engine: xelatex
always_allow_html: yes
---



## Managing GeoDeepDive Workflows: Understanding Dark Data Recovery in the Geosciences

* Powerful new technological tools provide an opportunity to use software tools to directly interrogate the publication record.

* Widespread adoption requires the provision of the applications and resources and also documentation.

* What is GeoDeepDive (Shannan)

* Here we show how a workflow within one domain can be developed to generate new understanding of the distribution of records in space and time.

### Workflow Overview

GeoDeepDive contains X records at present.  These documents contain over XXX sentences and XXXX unique words.  The process of working with these records is itterative, since the time required to process and manupilate data is time consuming.

GeoDeepDive manages data within a Postgres Database, with a data model that uses sentences as the atomic unit.  Each sentence within a paper is identified by a unique document id (`gddid`) and a unique sentence number within the paper.  A separate table related `gddid`s to publication data (title, journal, authors, etc.).  In this way, we can think of our individual steps as happening at two separate levels, the sentence level and at the document level.  Because GDD also maintains relationships between sentences and journals there is the possibility of having secondary and tertiary hierarchies, but for this article we will focus on "sentence" and "document" level properties.

To understand the process we will undertake an example workflow to extract space and time coordinates for evidence of Ice Rafted Debris in the Pleistocene.

WHY IS THIS INTERESTING? (Shaun?)

#### Subsetting and Cleaning

Beginning with an initial subset of data, using one or few keywords will pare down the total set of documents.  To obtain a training data set keyword detection operates at the sentence level, but returns a list of $n$ documents for which any sentence contains a match to the keyword, where $n$ is pre-defined, and often much smaller than the actual total match set, depending on the term of interest.

By subsetting we can go from the total XXX documents within the GDD Corpus to a subset of YYY documents, of which we develop on a further subset of 150 records.

<!-- Figure here: GDD Corpus vs some possible domain term searches and IRD -->

Given that we are using text matching to subset the documents (mention other "stacks of pubs?") it is possible that not all of the papers reflect our intention.  For example, searching for `IRD` as a keyword brings up articles that use `IRD` as an acronym for Ice Rafted Debris, but also the French Research Institute IRD.  Throughout this paper we will refer to *rules*, generally these are statements that can resolve to a boolean (TRUE/FALSE) output.  So for example, within our subset we could search for all occurrences of `IRD` and `CNRS`:


```r
sentence <- "this,is,a,IRD,and,CNRS,sentence,you,didny,want,."
stringr::str_detect(sentence, "IRD") & !stringr::str_detect(sentence, "CNRS")
```

This statement will evaluate to `TRUE` if `IRD` appears in a sentence without `CNRS`.  If we apply this sentence level test at the document level (`any(test == TRUE)`) we can know which papers have the right `IRD` for our purposes. This then further reduces the number of papers (and sentences) we need to test.

### Extracting Data

From the cleaning stage we enter an itterative stage, where we develop tests and workflows to extract information we want to find.  In many cases this will require further text matching, and packages in R such as `stringr` will be very useful.  Additional support can come from the Natural Language Processing output that can be generated for the data.

In all of these cases, we generate clear rules to be tested, and then apply them to the document.

Because understanding ice rafted debris distributions and timing in the Pliocene requires understanding both space and time, we need to find spatial coordinates and ages within a paper.  As with the cleaning earlier, any paper that contains neither, or one but not the other is not of interest for this application.

But just knowing space and time are part of the paper isn't sufficient.  We need to be able to distinguish between a reported age and an age related to the event we are interested in, and so again we must develop general rules that allow us to distinguish all ages from ages of interest, and all spatial locations from spatial locations of interest.

<!-- Figure, where are ages and spatial coordinates reported in GDD documents in general (sentence number of X sentences) -->

### Exploratory Itteration

There are a number of reasons to continue to refine the rules you use to discover data in this workflow.  First, regular expressions are complicated and OCR is not always accurate.  Second, different disciplines and journals use different standards for reporting.  For example, if we were interested in paleoecological information we would need to know that `paleoecology` and `palaeoecology` refer to similar concepts.  Similarly, `ice rafted debris` may also be refered to as `terriginous` deposits in the marine context (?).

Repeatedly reviewing matches at the sentence level and at the document level (Why did this match?  Why didn't this paper return a match?) is critical to developing a clear workflow.

Some potential pitfalls include
  * OCR matching - commonly mistaken letters (O, Q, o)
  * Age reporting variety
  * GDD sentence construction

In many cases, beginning with very broad tests and slowly paring down to more precise tests is an approprite pattern.  In this case, tools like RMarkdown documents are very helpful since existing packages like `DT` and `leaflet` provide powerful support for interactive data exploration.  We can look at the distribution of age-like elements within a paper and see if they match with our expectations ("Why does *Debris fields in the Miocene* contain Holocene-aged matches?", "Why does this paper about Korea report locations in Belize?").  From there we can continue to revise our tests.

Section on `word2vec`

### Reproducible and Validated Workflows

As the workflow develops we can begin to report on patterns and findings.  Some of these may be semi-qualitative ("We find the majority of sites are dated to the LGM"), some may involve statistical analysis ("The presence of IRD declines linearly with decreasing latitude ($p$ < $0.05$)").  In an analysis where the underlying dataset is static it is reasonable to develop a paper and report these findings as-is.

The GeoDeepDive infrastructure leverages a process of publication ingest that adds up to XXXX papers a day.  Given this, it is likely that some patterns may change over time as more information is brought to bear.  Those with strong physical underpinnings may be reinforced, but some that may result, in part, from artifacts within the publication record, may change.  For this reason the use of assertions within the workflow become critically important.

Test-driven development is common in software development.  As developers develop new features they often develop tests for the features as a first step.  The analogy in our scientific workflow is that findings are features, and as we report on them we want to be assured that those findings are valid.  In R the `assertthat` package provides a tool for testing statements, and providing robust feedback.


```r
howmany_dates <- all_sentences %>% 
  mutate(hasAge = stringr::str_detect(words, "regular expression for dates")) %>% 
  group_by(gddid) %>% 
  summarise(age_sentences = any(hasAge),
            n = n())

# We initially find that less than 10% of papers have dates in them, and we are going to report that as an important finding in the paper.

percent_ages <- sum(howmany_dates$age_sentences) / nrow(howmany_dates)

assertthat::assert_that(percent_ages < 0.1, msg = "More than 10% of papers have ages.")
```

#### Workflow Summary

With these elements we now have an itterative process that is also responsive to the underlying data.  We have mapped out the general overview of our reported findings and developed clear tests under which our findings are valid.  We can create a document that combines our code and text in an integrated manner, supporting FAIR Principles, and making the most out of the new technilogy.

In the following section we will run through this workflow in detail.

### Ice Rafted Debris Case Study: 

#### Finding Spatial Matches

To begin, we want to load the packages we will be using, and then import the data:


```r
#devtools::install_github('EarthCubeGeochron/geodiveR')

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
```

From this we get an output object that includes a key for the publication (`_gddid`, linking to the `publications` variable), the sentence number of the parsed text, and then both the parsed text and some results from natural language processing. We also get a list of gddids to keep or drop given the regular expressions we used to find instances of IRD in the affiliations or references sections of the papers. This leaves us with 82 documents:

<!--html_preserve--><div id="htmlwidget-ff7d94e703f7fd1e2052" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-ff7d94e703f7fd1e2052">{"x":{"filter":"none","data":[["_gddid","sentence","wordIndex","word","partofspeech","specialclass","wordsAgain","wordtype","wordmodified"],["550578e8e1382326932d8d3a","1","<code>{1,2,3,4,5,6,7,8,9,10,11,12,13 ... }<\/code>","<code>{ARTICLE,IN,PRESS,Quaternary,S ... }<\/code>","<code>{NN,IN,NNP,NNP,NNP,NNP,CD,(,CD ... }<\/code>","<code>{O,O,O,O,O,O,NUMBER,O,DATE,O,D ... }<\/code>","<code>{article,in,PRESS,Quaternary,S ... }<\/code>","<code>{nsubj,case,compound,compound, ... }<\/code>","<code>{90,6,6,6,6,1,6,0,6,0,13,0,1,1 ... }<\/code>"],["Unique article identifier","Unique sentence identifier within article","Index of words within sentence","Verbatim OCR word","Parts of speech, based on <a href='https://www.ling.upenn.edu/courses/Fall_2003/ling001/penn_treebank_pos.html'>Penn State TreeView<\/a>","Special classes (numbers, dates, &cetera)","Words again","Word types, based on <a href='http://universaldependencies.org/introduction.html'>universal dependencies<\/a>.","The word that the <code>wordtype<\/code> is modifying."]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>value<\/th>\n      <th>description<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"dom":"t","order":[],"autoWidth":false,"orderClasses":false,"columnDefs":[{"orderable":false,"targets":0}]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

We're interested in trying to use GDD to obtain site coordinates for sites that contain IRD data over the last 5 million years.  This would help researchers searching for relevant sites for use in meta-analysis, or in comparing their results to results in similar geographic locations by providing relevant geocoded publications and links to the publications using DOIs. 

## Getting Coordinates

To obtain coordinates from the paper we must consider that there are several potential issues.  The first is that not all coordinates will neccessarily refer to an actual ocean core.  We may also, inadvertantly, find numeric objects that appear to be coordinates, but are in fact simply numbers.  We then must identify what exactly we think coordinates might look like and build a regular expression (or set of regular expressions) to accurately extract these values.  Since we will be processing DMS coordinates differently than DD coordinates we generate two regular expressions:


```r
dms_regex <- "[\\{,]([-]?[1]?[0-9]{1,2}?)(?:(?:,[°◦o],)|(?:[O])|(?:,`{2},))([1]?[0-9]{1,2}(?:.[0-9]*)),[′'`]?[,]?([[0-9]{0,2}]?)[\"]?[,]?([NESWnesw]?),"

 dd_regex <- "[\\{,][-]?[1]?[0-9]{1,2}\\.[0-9]{1,}[,]?[NESWnesw],"
#dd_regex <- "[\\{,][-]?[1]?[0-9]{1,2}\\.[0-9]{1,}[,]?[NESWnesw],"
#dms_regex <- "[\\{,]([-]?[1]?[0-9]{1,2}?)(?:(?:,[°◦oºø],)|(?:[O])|(?:,`{2},))([1]?[0-9]{1,3}(?:.[0-9]*)),[´′'`]?[,]?([[0-9]{0,2}]?)[\"]?[,]?([NESWnesw]?),"
```

These regular expressions allow for negative or positive coordinate systems, that may start with a `1`, and then are followed by one or two digits (`{1,2}`).  From there we see differences in the structure, reflecting the need to capture the degree symbols, or, in the case of decimal degrees, the decimal component of the coordinates.  We are more rigorous here for the decimal degrees because there are too many other options when there are only decimal numbers.

The regex commands were constructed using capture (and non-capture) groups to work with the `stringr` package, so that we obtain five elements from any match.  The full match, the degrees, the minutes and the seconds (which may be an empty string).  It also returns the quadrant (NESW).


```r
degmin <- str_match_all(nlp$word, dms_regex)
decdeg <- str_match_all(nlp$word, dd_regex)
```

Since the documents are broken up into sentences we should expect that all coordinates are reported as pairs, and so we might be most interested in finding all the records that show up with pairs of coordinates.  Let's start by matching up the publications with sentences that have coordinate pairs:

<!--html_preserve--><div id="htmlwidget-c57e41e8ddde57fe6393" style="width:100%;height:auto;" class="datatables html-widget"></div>
<script type="application/json" data-for="htmlwidget-c57e41e8ddde57fe6393">{"x":{"filter":"none","data":[["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28"],["{To address the stability and duration of the last interglaciation in continental Asia , the advanced hydraulic piston cores BDP96-2 ( 53 ◦ 41 48 N , 108 ◦ 21 06 E ) and BDP-98 ( 53 ◦ 44 48 N , 108 ◦ 24 34 E ) of the Baikal Drilling Project ( BDP-Members , 1997 , 2000 ) were sampled at 1 cm ( ca. 250 yr ) and 2 cm ( 350 -- 400 yr ) , respectively .}","{Location , lithology , and chronology Location and sedimentary environment Core PC-013 was collected from the Greenland rise , north of the Eirik Ridge on the northern flank of a subsidiary ridge ( 58 `` 13 ` N , 48 `` 22 ` W ) , at a water depth of 3380 m ( Fig. 1 ) .}","{Site 1101 ( latitude 64 ° 22.3 ′ S , longitude 70 ° 15.6 ′ W , 3280 m ) is located on Drift 4 , one in a series of eight drift deposits that occur along the northwest ﬂank of the Antarctic Peninsula continental rise ( Fig. 1 ; Barker et al. , 1999 ; Uenzelmann-Neben , 2006 ) .}","{On Table 1 Core inventory Core 9404468 9404469 9404470 9404471 9404472 9404473 9404474 9404475 9404476 13/01-U -02 13/01-U -02 Latitude WGS84 57 ° 45.078 ′ 57 ° 45.281 ′ 57 ° 45.357 ′ 57 ° 45.540 ′ 57 ° 45.982 ′ 58 ° 16.084 ′ 58 ° 15.511 ′ 58 ° 14.772 ′ 58 ° 13.728 ′ 57 ° 59.085 ′ 57 ° 59.085 ′ Longitude WGS84 8 ° 35.133 ′ 8 ° 35.170 ′ 8 ° 35.191 ′ 8 ° 35.171 ′ 8 ° 35.219 ′ 5 ° 51.608 ′ 5 ° 50.763 ′ 5 ° 49.588 ′ 5 ° 47.939 ′ 8 ° 22.008 ′ 8 ° 22.008 ′ Water depth ( m ) 279 290 292 300 340 339 343 348 339 505 505 Core type Gravity Gravity Gravity Gravity Gravity Gravity Gravity Gravity Gravity Borehole Borehole Core length / interval ( m ) 2.70 4.00 3.00 3.30 4.05 2.55 2.95 3.40 2.50 90.0 -- 90.5 110.0 -- 110.3 boomer records , reﬂections are more variable in character , and subunits appear to vary in thickness over short distances ( Fig. 6 ) .}","{Site 963 -LSB- 4 -RSB- Sedimentary material of Ocean Drilling Program ( ODP ) Hole 963D ( longitude 37 ° 02.1480 N , latitude 13 ° 10.6860 E ) was recovered in the Sicily Strait between the Adventure Bank and the Gela basin , at 469.1 m below sea level ( Figure 1 ) .}","{-LSB- 26 -RSB- During the Vicomed I cruise , carried out from September to October 1986 , 32.5 % of F. profunda was found in water samples at station SIC ( 37 ° 27.30 N ; 11 ° 32.70 E ) , which is only a few kilometers away from ODP Site 963 , when the base of the summer thermocline was located at about 55 m depth .}","{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S , 76 ◦ 58.7 W 65 ◦ 42 S , 73 ◦ 38 W 65 ◦ 08.8 S , 70 ◦ 35.3 W 64 ◦ 19 S , 70 ◦ 26.2 W 63 ◦ 27.3 S , 68 ◦ 58 W 63 ◦ 10.0 S , 42 ◦ 43.5 W 62 ◦ 04.0 S , 40 ◦ 35.0 W 59 ◦ 22.2 S , 42 ◦ 43.5 W 56 ◦ 45.0 S , 43 ◦ 16.9 W 53 ◦ 52.1 S , 48 ◦ 20.3 W 53 ◦ 21.0 S , 54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}","{Cores 1 2 3 4 5 6 7 8 SU92-03 PE109-13 KC24-19 MD03-2697 MD99-2331 MD95-2040 MD95-2042 MD99-2339 Latitude N 43 ° 11.750 42 ° 34.32 ′ 42 ° 08.98 ′ 42 ° 09 ′ 59 N 42 ° 09 ′ 00 N 40 ° 34.91 ′ 37 ° 47.99 ′ 35 ° 14.76 ′ Longitude W 10 ° 6.780 9 ° 41.4 ′ 10 ° 29.96 ′ 9 ° 42 ′ 10 W 09 ° 40 ′ 90 W 9 ° 51 .}","{MD04-2820CQ MD04-2820CQ was retrieved from the Goban Spur area ( 49 05.290 N ; 13 25.900 W ; Fig. 1 ) and is a reoccupation of the OMEX-2K core site ( see Hall and McCave , 1998a , b ; Scourse et al. , 2000 ; Haapaniemi et al. , 2010 ) .}","{A gravity core , GH95 -- 1208 ( lat 43 ° 46 ′ N , long 138 ° 50 ′ E , water depth 3435 m ) , was collected during the GH 95 cruise of the R/V Hakurei-Maru of the Geological Survey of Japan from the eastern margin of the Japan Basin in the northeastern Japan Sea .}","{A piston core , MD01 -- 2407 ( lat 37 ° 11 ′ N , long 134 ° 11 ′ E , water depth 930 m ) , was collected during the IMAGES-WEPAMA cruise of the R/V Marion Dufresne from a small depression on the Oki Ridge in the southwestern Japan Sea .}","{Lithological Data The 16 m long Calypso core ( giant piston core ) GS10-163-3PC ( 68 ° 05.0978 ′ N , 09 ° 52.1969 ′ E , 1178 m water depth ) was retrieved with R/V G.O. Sars in June 2010 ( Figures 2 and 3 ) .}","{Map showing sampling location of core PC-2 ( latitude : 50 ° 23.70 N , longitude : 148 ° 19.40 E , water depth : 1258 m , core length : 10.23 m ) in the Sea of Okhotsk .}","{MeanHoloceneBenthicForaminiferafli13CandCd/Ca , WaterColumnCdandPhosporuCsoncentrationasn , dCalculated Foraminiferal Water Column Cd Partition Coefficients Core SectionAge , Water Samples / • 13C , Cd/Ca , Cdwater , P , Dtt kyr Depmth , Rel • licaat % esP0DB -LSB- • mmolol-l -LSB- lnmko • - l • -RSB- gmko • ` l • thisstudBy oy -LSB- l1e992 -RSB- SO75-26KL SO82-05 M16004 M23414 Hol ( 3.0-8 .5 ) Hol ( 0-9 ) Hol ( 0.6-9 .6 ) Hol ( 3.0-8 .9 ) 1099 1416 1512 2196 8/14 4/8 4/8 10/24 1.015 1.347 1.030 1.120 0.047 0.103 0.036 0.081 0.17 b 0.24 d 0.17 b 0.24 d 0.86 n.a. 1.21 n.a. 3.1 c 4.3 e 2.1 c 3.3 e 1.3 1.5 1.6 2.2 a Numberof sampledepths/numboefranalyses .}","{Environmental setting The studied core MD04-2861 is located in the Arabian Sea , off the tectonically-active Makran margin ( 24.13 N ; 63.91 E ; 2049 m depth ) ( Bourget et al. , 2011 ; Ellouz-Zimmermann et al. , 2007 ; Kukowski et al. , 2001 ; Fig. 1A ) .}","{Core ID VC03 VC04 VC05 VC06 VC07 VC08 VC09 VC10 VC11 VC12 VC13 VC14 Latitude 69 10.810 N 69 09.970 N 69 09.600 N 69 08.940 N 69 08.620 N 69 08.350 N 69 05.790 N 69 05.950 N 69 06.900 N 69 53.120 N 69 58.460 N 69 56.970 N Longitude 51 11.610 W 51 10.150 W 51 31.630 W 52 04.140 W 52 18.880 W 52 38.240 W 51 23.650 W 51 31.220 W 52 25.600 W 51 53.150 W 51 44.470 W 51 40.350 W Area Disko Disko Disko Disko Disko Disko Disko Disko Disko Vaigat Vaigat Vaigat Depth -LSB- m -RSB- 545 263 389 439 439 429 294 351 410 616 341 386 Length -LSB- m -RSB- 1.57 1.10 5.87 4.94 5.46 3.91 5.98 4.86 3.25 3.66 3.40 4.66 cores should be treated as estimates .}","{DOI : 10.1002 / jqs .1503 Late Holocene environmental conditions in Coronation Gulf , southwestern Canadian Arctic Archipelago : evidence from dinoﬂagellate cysts , other non-pollen palynomorphs , and pollen ANNA J. PIEN ´ KOWSKI \" 1, \" * , y PETA J. MUDIE \" 2\" JOHN H. ENGLAND \" 1\" JOHN N. SMITH3 and MARK F. A. FURZE4 1Department of Earth and Atmospheric Sciences , University of Alberta , Edmonton , Alberta , Canada 2Geological Survey of Canada -- Atlantic , Dartmouth , Nova Scotia , Canada 3Department of Fisheries and Oceans , Bedford Institute of Oceanography , Dartmouth , Nova Scotia , Canada 4Earth and Planetary Science Division , Department of Physical Sciences , Grant MacEwan University , Edmonton , Alberta , Canada Received 19 November 2010 ; Revised 22 February 2011 ; Accepted 27 February 2011 ABSTRACT : Boxcore 99LSSL-001 ( 68.0958 N , 114.1868 W ; 211 m water depth ) from Coronation Gulf represents the ﬁrst decadalscale marine palynology and late Holocene sediment record for the southwestern part of the Northwest Passage .}","{Materials and methods Core materials Boxcore 99LSSL-001 was retrieved from southwestern Coronation Gulf ( 68.0958 N , 114.1868 W ; Tundra Northwest research cruise , CCGS Louis S. St-Laurent , 1999 ) in a small , deep ( 211 m ) basin 48 km NE of the Coppermine River mouth ( Fig. 1b ) .}","{( f ) Percentage of N. pachyderma ( s. ) from core DAPC2 ( 58 58.100 N , 09 36.750 W , 1709 m water depth ) ( Knutz et al. , 2007 ) .}","{( g ) Ice-rafted debris ﬂux from core DAPC2 ( 58 58.100 N , 09 36.750 W , 1709 m water depth ) ( Knutz et al. , 2007 ) .}","{( h ) Records of ice-rafted debris from core P-013 ( 58 12.59 N , 47 22.40 W , 3380 m water depth ) ( powder blue ﬁll ) ( Hillaire-Marcel and Bilodeau , 2000 ) and core SU8118 ( 37 460N , 10 110W , 3135 m depth ) ( light blue ) ( Bard et al. , 2000 ) showing Heinrich events 0e2 .}","{307 hole U1317E samples ( drilled at 51 22.80 N , 11 43.10 W ; 792.2 m water depth ) .}","{Core location and oceanography Marine sediment core CD154 17-17K ( 33 ◦ 19.2 S ; 29 ◦ 28.2 E ; 3333 m water depth ) was recovered from the Natal Valley , south west Indian Ocean during the RRS Charles Darwin Cruise 154 ( Hall and Zahn , 2004 ) .}","{Lithic fragments ( &gt; 150 μm fraction ) were counted in marine sediment core MD02-2588 , ( 41 ◦ 19.9 S ; 25 ◦ 49.4 E ; 2907 m water depth ) every 2 cm between Marine Isotope Stages ( MIS ) 1 -- 5 .}","{However , a recently published high-resolution record from the Ag - ulhas Bank , South Atlantic ( Marino et al. , 2013 ) ( sediment core MD96-2080 , 36 ◦ 19.2 S , 19 ◦ 28.2 E , 2488 m water depth , Fig. 1 ) spanning MIS 5 -- 8 offers the opportunity to compare both loca - tions on millennial-scale basis , as both records overlap during the period between 76 -- 98 kyr .}","{In the present study , to provide further information about the origin of the Heinrich layers ( HL ) and the effect of the HE on oceanographic conditions , we have examined the distributions of selected types of biomarkers ( C37alkenones , tetrapyrrole pigments and aromatic hydrocarbons ) in the core BOFS 5K ( East Thulean Rise ; 50 ° 41.3 N , 21 ° 51.9 ` W , 3547m water depth ; Fig. 1 ; McCave , 1989 ) , in which the HL ( I-IV ) were located from the relative abundance of coarse fraction lithic debris ( ice rafted debris , IRD ) and whole core magnetic susceptibility ( Fig. 2a , b Maslin , 1993 ; Maslin et al. , 1995 ) .}","{Site U1386 Integrated Ocean Drilling Program ( IODP ) Site U1386 was drilled during Expedition 339 in November to January 2011/2012 and is located southeast of the Portuguese Margin mounded on the Faro Drift along the Alvarez Cabral Moat at 36 ° 49.68 ′ N ; − 7 ° 45.32 ′ W in 561 m water depth ( Fig. 1B and C ) .}","{Lon 7 ° 45.32 W 9 ° 43.97 E 7 ° 31.80 W 2 ° 37.26 E Water depth ( m ) 561 501 1170 1841 Water mass Upper MOW1 LIW2 Lower MOW3 WMDW4 Table 2 Age control points used for the construction of the chronology at Site U1386 based on alignment of the normalized Br counts at Site U1386 to the planktic δ18O Record of the Iberian Margin core MD01-2444 ( Barker et al. , 2011 ; Hodell et al. , 2013 ) ( Fig. 2A and B ) .}"],["2002","1994","2009","2008","2008","2008","2001","2015","2016","2007","2007","2014","2005","2000","2011","2017","2011","2011","2012","2012","2012","2012","2013","2013","2013","1997","2015","2015"],["The Stability and the Abrupt Ending of the Last Interglaciation in Southeastern Siberia","High-resolution rock magnetic study of a Late Pleistocene core from the Labrador Sea","Mid-Pliocene to Recent abyssal current flow along the Antarctic Peninsula: Results from ODP Leg 178, Site 1101","Postglacial depositional environments and sedimentation rates in the Norwegian Channel off southern Norway","Holocene millennial-scale productivity variations in the Sicily Channel (Mediterranean Sea)","Holocene millennial-scale productivity variations in the Sicily Channel (Mediterranean Sea)","Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas","Atlantic sea surface temperatures estimated from planktonic foraminifera off the Iberian Margin over the last 40Ka BP","Last glacial period cryptotephra deposits in an eastern North Atlantic marine sequence: Exploring linkages to the Greenland ice-cores","Millennial-scale fluctuations in seasonal sea-ice and deep-water formation in the Japan Sea during the late Quaternary","Millennial-scale fluctuations in seasonal sea-ice and deep-water formation in the Japan Sea during the late Quaternary","Origin of shallow submarine mass movements and their glide planes-Sedimentological and geotechnical analyses from the continental slope off northern Norway","Decreased surface salinity in the Sea of Okhotsk during the last glacial period estimated from alkenones","Upper ocean circulation in the glacial North Atlantic from benthic foraminiferal isotope and trace element fingerprinting","New Arabian Sea records help decipher orbital timing of Indo-Asian monsoon","Seafloor geomorphology and glacimarine sedimentation associated with fast-flowing ice sheet outlet glaciers in Disko Bay, West Greenland","Late Holocene environmental conditions in Coronation Gulf, southwestern Canadian Arctic Archipelago: evidence from dinoflagellate cysts, other non-pollen palynomorphs, and pollen","Late Holocene environmental conditions in Coronation Gulf, southwestern Canadian Arctic Archipelago: evidence from dinoflagellate cysts, other non-pollen palynomorphs, and pollen","Response of the Irish Ice Sheet to abrupt climate change during the last deglaciation","Response of the Irish Ice Sheet to abrupt climate change during the last deglaciation","Response of the Irish Ice Sheet to abrupt climate change during the last deglaciation","Ice-rafting from the British–Irish ice sheet since the earliest Pleistocene (2.6 million years ago): implications for long-term mid-latitudinal ice-sheet growth in the North Atlantic region","Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway","Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway","Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway","Biomarker evidence for “Heinrich” events","New insights into upper MOW variability over the last 150kyr from IODP 339 Site U1386 in the Gulf of Cadiz","New insights into upper MOW variability over the last 150kyr from IODP 339 Site U1386 in the Gulf of Cadiz"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th> <\/th>\n      <th>word<\/th>\n      <th>year<\/th>\n      <th>title<\/th>\n    <\/tr>\n  <\/thead>\n<\/table>","options":{"order":[],"autoWidth":false,"orderClasses":false,"columnDefs":[{"orderable":false,"targets":0}]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

So even here, we can see that many of these matches work, but that some of the matches are incomplete.  There appears to be a much lower proportion of sites returned than we might otherwise expect.  Given that there are 81 articles in the NLP dataset, it's surprising that only 20 appear to support regex matches to coordinate pairs.

In reality, this is likely to be, in part, an issue with the OCR/regex processing. We need to go over the potential matches more thoroughly to find all the alternative methods of indicating the coordinate systems before we can commit to a full analysis.

## Converting Coordinates

So, given the coordinate strings, we need to be able to transform them to reliable lat/long pairs with sufficient trust to actually map the records.  These two functions will convert the GeoDeepDive (GDD) word elements pulled out by the regular expression searches into decimal degrees that can account for reported locations.


```r
convert_dec <- function(x, i) {

  drop_comma <- gsub(',', '', x) %>% 
    substr(., c(1,1), nchar(.) - 1) %>% 
    as.numeric %>% 
    unlist

  domain <- (str_detect(x, 'N') * 1 +
    str_detect(x, 'E') * 1 +
    str_detect(x, 'W') * -1 +
    str_detect(x, 'S') * -1) *
    drop_comma

  publ <- match(nlp$`_gddid`[i], publications$`_gddid`)
  
  point_pairs <- data.frame(sentence = nlp$word[i],
                            lat = domain[str_detect(x, 'N') | str_detect(x, 'S')],
                            lng = domain[str_detect(x, 'E') | str_detect(x, 'W')],
                            publications[publ,],
                            stringsAsFactors = FALSE)
  
  return(point_pairs)  
}

convert_dm <- function(x, i) {

  # We use the `i` index so that we can keep the coordinate outputs from the 
  #  regex in a smaller list.
  dms <- data.frame(deg = as.numeric(x[,2]), 
                    min = as.numeric(x[,3]) / 60,
                    sec = as.numeric(x[,4]) / 60 ^ 2, 
                    stringsAsFactors = FALSE)
  
  dms <- rowSums(dms, na.rm = TRUE)

  domain <- (str_detect(x[,5], 'N') * 1 +
    str_detect(x[,5], 'E') * 1 +
    str_detect(x[,5], 'W') * -1 +
    str_detect(x[,5], 'S') * -1) *
    dms
  
  publ <- match(nlp$`_gddid`[i], publications$`_gddid`)
  
  point_pairs <- data.frame(sentence = nlp$word[i],
                            lat = domain[x[,5] %in% c('N', 'S')],
                            lng = domain[x[,5] %in% c('E', 'W')],
                            publications[publ,],
                            stringsAsFactors = FALSE)
  
  return(point_pairs)  
}
```

Then, once we've done that, we need to apply those functions to the set of records we've pulled to build a composite table:


```r
coordinates <- list()
coord_idx <- 1

for(i in 1:length(decdeg)) {
  if((length(decdeg[[i]]) %% 2 == 0 | 
      length(degmin[[i]]) %% 2 == 0) & length(degmin[[i]]) > 0) {
    
    if(any(str_detect(decdeg[[i]], '[NS]')) & 
       sum(str_detect(decdeg[[i]], '[EW]')) == sum(str_detect(decdeg[[i]], '[NS]'))) {
      coordinates[[coord_idx]] <- convert_dec(decdeg[[i]], i)
      coord_idx <- coord_idx + 1
    }
    if(any(str_detect(degmin[[i]], '[NS]')) & 
       sum(str_detect(degmin[[i]], '[EW]')) == sum(str_detect(degmin[[i]], '[NS]'))) {
      coordinates[[coord_idx]] <- convert_dm(degmin[[i]], i)
      coord_idx <- coord_idx + 1
    }
  }
}

coordinates_df <- coordinates %>% bind_rows %>% 
  mutate(sentence = gsub(',', ' ', sentence)) %>% 
  mutate(sentence = str_replace_all(sentence, '-LRB-', '(')) %>% 
  mutate(sentence = str_replace_all(sentence, '-RRB-', ')')) %>% 
  mutate(sentence = str_replace_all(sentence, '" "', ','))

coordinates_df$doi <- coordinates_df$identifier %>% map(function(x) x$id) %>% unlist

leaflet(coordinates_df) %>% 
  addProviderTiles(providers$CartoDB.Positron) %>% 
  addCircleMarkers(popup = paste0('<b>', coordinates_df$title, '</b><br>',
                                  '<a href=https://doi.org/',
                                  coordinates_df$doi,'>Publication Link</a><br>',
                                  '<b>Sentence:</b><br>',
                                  '<small>',gsub(',', ' ', coordinates_df$sentence),
                                  '</small>'))
```

<!--html_preserve--><div id="htmlwidget-9d25b03122ee5063cb3a" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-9d25b03122ee5063cb3a">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["CartoDB.Positron",null,null,{"errorTileUrl":"","noWrap":false,"detectRetina":false}]},{"method":"addCircleMarkers","args":[[53,53,58.2166666666667,-64.3716666666667,2.148,37.0358,27.3,37.455,-18.8,-8.8,-27.3,-10,-4,-22.2,-45,-52.1,-21,43.7666666666667,37.1833333333333,68.0849633333333,23.7,50.395,-19.2,-33.32,-19.9,-41.3316666666667,-19.2,-36.32,50.6883333333333,36.828],[108,108,-48.3666666666667,-70.26,10.686,13.1781,32.7,11.545,-58.7,-35.3,-26.2,-43.5,-35,-43.5,-16.9,-20.3,-41,138.833333333333,134.183333333333,9.86994833333333,19.4,148.323333333333,28.2,29.47,49.4,25.8233333333333,28.2,19.47,-21.865,-7.75533333333333],10,null,null,{"interactive":true,"className":"","stroke":true,"color":"#03F","weight":5,"opacity":0.5,"fill":true,"fillColor":"#03F","fillOpacity":0.2},null,null,["<b>The Stability and the Abrupt Ending of the Last Interglaciation in Southeastern Siberia<\/b><br><a href=https://doi.org/10.1006/qres.2002.2329>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{To address the stability and duration of the last interglaciation in continental Asia   the advanced hydraulic piston cores BDP96-2 ( 53 ◦ 41 48 N   108 ◦ 21 06 E ) and BDP-98 ( 53 ◦ 44 48 N   108 ◦ 24 34 E ) of the Baikal Drilling Project ( BDP-Members   1997   2000 ) were sampled at 1 cm ( ca. 250 yr ) and 2 cm ( 350 -- 400 yr )   respectively .}<\/small>","<b>The Stability and the Abrupt Ending of the Last Interglaciation in Southeastern Siberia<\/b><br><a href=https://doi.org/10.1006/qres.2002.2329>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{To address the stability and duration of the last interglaciation in continental Asia   the advanced hydraulic piston cores BDP96-2 ( 53 ◦ 41 48 N   108 ◦ 21 06 E ) and BDP-98 ( 53 ◦ 44 48 N   108 ◦ 24 34 E ) of the Baikal Drilling Project ( BDP-Members   1997   2000 ) were sampled at 1 cm ( ca. 250 yr ) and 2 cm ( 350 -- 400 yr )   respectively .}<\/small>","<b>High-resolution rock magnetic study of a Late Pleistocene core from the Labrador Sea<\/b><br><a href=https://doi.org/10.1139/e94-009>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Location   lithology   and chronology Location and sedimentary environment Core PC-013 was collected from the Greenland rise   north of the Eirik Ridge on the northern flank of a subsidiary ridge ( 58 `` 13 ` N   48 `` 22 ` W )   at a water depth of 3380 m ( Fig. 1 ) .}<\/small>","<b>Mid-Pliocene to Recent abyssal current flow along the Antarctic Peninsula: Results from ODP Leg 178, Site 1101<\/b><br><a href=https://doi.org/10.1016/j.palaeo.2009.09.011>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Site 1101 ( latitude 64 ° 22.3 ′ S   longitude 70 ° 15.6 ′ W   3280 m ) is located on Drift 4   one in a series of eight drift deposits that occur along the northwest ﬂank of the Antarctic Peninsula continental rise ( Fig. 1 ; Barker et al.   1999 ; Uenzelmann-Neben   2006 ) .}<\/small>","<b>Holocene millennial-scale productivity variations in the Sicily Channel (Mediterranean Sea)<\/b><br><a href=https://doi.org/10.1029/2007PA001581>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Site 963 -LSB- 4 -RSB- Sedimentary material of Ocean Drilling Program ( ODP ) Hole 963D ( longitude 37 ° 02.1480 N   latitude 13 ° 10.6860 E ) was recovered in the Sicily Strait between the Adventure Bank and the Gela basin   at 469.1 m below sea level ( Figure 1 ) .}<\/small>","<b>Holocene millennial-scale productivity variations in the Sicily Channel (Mediterranean Sea)<\/b><br><a href=https://doi.org/10.1029/2007PA001581>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Site 963 -LSB- 4 -RSB- Sedimentary material of Ocean Drilling Program ( ODP ) Hole 963D ( longitude 37 ° 02.1480 N   latitude 13 ° 10.6860 E ) was recovered in the Sicily Strait between the Adventure Bank and the Gela basin   at 469.1 m below sea level ( Figure 1 ) .}<\/small>","<b>Holocene millennial-scale productivity variations in the Sicily Channel (Mediterranean Sea)<\/b><br><a href=https://doi.org/10.1029/2007PA001581>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{-LSB- 26 -RSB- During the Vicomed I cruise   carried out from September to October 1986   32.5 % of F. profunda was found in water samples at station SIC ( 37 ° 27.30 N ; 11 ° 32.70 E )   which is only a few kilometers away from ODP Site 963   when the base of the summer thermocline was located at about 55 m depth .}<\/small>","<b>Holocene millennial-scale productivity variations in the Sicily Channel (Mediterranean Sea)<\/b><br><a href=https://doi.org/10.1029/2007PA001581>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{-LSB- 26 -RSB- During the Vicomed I cruise   carried out from September to October 1986   32.5 % of F. profunda was found in water samples at station SIC ( 37 ° 27.30 N ; 11 ° 32.70 E )   which is only a few kilometers away from ODP Site 963   when the base of the summer thermocline was located at about 55 m depth .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Late Quaternary Iceberg Rafting along the Antarctic Peninsula Continental Rise and in the Weddell and Scotia Seas<\/b><br><a href=https://doi.org/10.1006/qres.2001.2267>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{CORE STRATIGRAPHY The cores were dated using a combination of biostratigraphy ( diatoms and radiolaria ) and chemical ( barium ) and isotope TABLE 1 Site Information on Sediment Cores Discussed in This Paper from the Continental Rise of the Antarctic Peninsula and the Weddell and Scotia Seas1 Core number Location Water depth Recovery ( m ) ( m ) Antarctic Peninsula Weddell and Scotia Seas PC106 PC108 PC110 PC111 PC113 PC038 PC041 KC083 PC079 KC064 KC097 66 ◦ 18.8 S   76 ◦ 58.7 W 65 ◦ 42 S   73 ◦ 38 W 65 ◦ 08.8 S   70 ◦ 35.3 W 64 ◦ 19 S   70 ◦ 26.2 W 63 ◦ 27.3 S   68 ◦ 58 W 63 ◦ 10.0 S   42 ◦ 43.5 W 62 ◦ 04.0 S   40 ◦ 35.0 W 59 ◦ 22.2 S   42 ◦ 43.5 W 56 ◦ 45.0 S   43 ◦ 16.9 W 53 ◦ 52.1 S   48 ◦ 20.3 W 53 ◦ 21.0 S   54 ◦ 41.0 W 3662 3601 3025 3357 3552 3802 3310 3900 3733 4304 3058 9.27 9.15 7.55 10.93 10.80 5.96 9.35 2.3 8.0 3.2 2.82 1 Core locations are shown in Figures 1 and 2 .}<\/small>","<b>Millennial-scale fluctuations in seasonal sea-ice and deep-water formation in the Japan Sea during the late Quaternary<\/b><br><a href=https://doi.org/10.1016/j.palaeo.2006.11.026>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{A gravity core   GH95 -- 1208 ( lat 43 ° 46 ′ N   long 138 ° 50 ′ E   water depth 3435 m )   was collected during the GH 95 cruise of the R/V Hakurei-Maru of the Geological Survey of Japan from the eastern margin of the Japan Basin in the northeastern Japan Sea .}<\/small>","<b>Millennial-scale fluctuations in seasonal sea-ice and deep-water formation in the Japan Sea during the late Quaternary<\/b><br><a href=https://doi.org/10.1016/j.palaeo.2006.11.026>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{A piston core   MD01 -- 2407 ( lat 37 ° 11 ′ N   long 134 ° 11 ′ E   water depth 930 m )   was collected during the IMAGES-WEPAMA cruise of the R/V Marion Dufresne from a small depression on the Oki Ridge in the southwestern Japan Sea .}<\/small>","<b>Origin of shallow submarine mass movements and their glide planes-Sedimentological and geotechnical analyses from the continental slope off northern Norway<\/b><br><a href=https://doi.org/10.1002/2013JF003068>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Lithological Data The 16 m long Calypso core ( giant piston core ) GS10-163-3PC ( 68 ° 05.0978 ′ N   09 ° 52.1969 ′ E   1178 m water depth ) was retrieved with R/V G.O. Sars in June 2010 ( Figures 2 and 3 ) .}<\/small>","<b>Decreased surface salinity in the Sea of Okhotsk during the last glacial period estimated from alkenones<\/b><br><a href=https://doi.org/10.1029/2004GL022177>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Map showing sampling location of core PC-2 ( latitude : 50 ° 23.70 N   longitude : 148 ° 19.40 E   water depth : 1258 m   core length : 10.23 m ) in the Sea of Okhotsk .}<\/small>","<b>Decreased surface salinity in the Sea of Okhotsk during the last glacial period estimated from alkenones<\/b><br><a href=https://doi.org/10.1029/2004GL022177>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Map showing sampling location of core PC-2 ( latitude : 50 ° 23.70 N   longitude : 148 ° 19.40 E   water depth : 1258 m   core length : 10.23 m ) in the Sea of Okhotsk .}<\/small>","<b>Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway<\/b><br><a href=https://doi.org/10.1016/j.epsl.2013.09.035>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Core location and oceanography Marine sediment core CD154 17-17K ( 33 ◦ 19.2 S ; 29 ◦ 28.2 E ; 3333 m water depth ) was recovered from the Natal Valley   south west Indian Ocean during the RRS Charles Darwin Cruise 154 ( Hall and Zahn   2004 ) .}<\/small>","<b>Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway<\/b><br><a href=https://doi.org/10.1016/j.epsl.2013.09.035>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Core location and oceanography Marine sediment core CD154 17-17K ( 33 ◦ 19.2 S ; 29 ◦ 28.2 E ; 3333 m water depth ) was recovered from the Natal Valley   south west Indian Ocean during the RRS Charles Darwin Cruise 154 ( Hall and Zahn   2004 ) .}<\/small>","<b>Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway<\/b><br><a href=https://doi.org/10.1016/j.epsl.2013.09.035>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Lithic fragments ( > 150 μm fraction ) were counted in marine sediment core MD02-2588   ( 41 ◦ 19.9 S ; 25 ◦ 49.4 E ; 2907 m water depth ) every 2 cm between Marine Isotope Stages ( MIS ) 1 -- 5 .}<\/small>","<b>Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway<\/b><br><a href=https://doi.org/10.1016/j.epsl.2013.09.035>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Lithic fragments ( > 150 μm fraction ) were counted in marine sediment core MD02-2588   ( 41 ◦ 19.9 S ; 25 ◦ 49.4 E ; 2907 m water depth ) every 2 cm between Marine Isotope Stages ( MIS ) 1 -- 5 .}<\/small>","<b>Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway<\/b><br><a href=https://doi.org/10.1016/j.epsl.2013.09.035>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{However   a recently published high-resolution record from the Ag - ulhas Bank   South Atlantic ( Marino et al.   2013 ) ( sediment core MD96-2080   36 ◦ 19.2 S   19 ◦ 28.2 E   2488 m water depth   Fig. 1 ) spanning MIS 5 -- 8 offers the opportunity to compare both loca - tions on millennial-scale basis   as both records overlap during the period between 76 -- 98 kyr .}<\/small>","<b>Millennial-scale Agulhas Current variability and its implications for salt-leakage through the Indian–Atlantic Ocean Gateway<\/b><br><a href=https://doi.org/10.1016/j.epsl.2013.09.035>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{However   a recently published high-resolution record from the Ag - ulhas Bank   South Atlantic ( Marino et al.   2013 ) ( sediment core MD96-2080   36 ◦ 19.2 S   19 ◦ 28.2 E   2488 m water depth   Fig. 1 ) spanning MIS 5 -- 8 offers the opportunity to compare both loca - tions on millennial-scale basis   as both records overlap during the period between 76 -- 98 kyr .}<\/small>","<b>Biomarker evidence for “Heinrich” events<\/b><br><a href=https://doi.org/10.1016/S0016-7037(97)00046-X>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{In the present study   to provide further information about the origin of the Heinrich layers ( HL ) and the effect of the HE on oceanographic conditions   we have examined the distributions of selected types of biomarkers ( C37alkenones   tetrapyrrole pigments and aromatic hydrocarbons ) in the core BOFS 5K ( East Thulean Rise ; 50 ° 41.3 N   21 ° 51.9 ` W   3547m water depth ; Fig. 1 ; McCave   1989 )   in which the HL ( I-IV ) were located from the relative abundance of coarse fraction lithic debris ( ice rafted debris   IRD ) and whole core magnetic susceptibility ( Fig. 2a   b Maslin   1993 ; Maslin et al.   1995 ) .}<\/small>","<b>New insights into upper MOW variability over the last 150kyr from IODP 339 Site U1386 in the Gulf of Cadiz<\/b><br><a href=https://doi.org/10.1016/j.margeo.2015.08.014>Publication Link<\/a><br><b>Sentence:<\/b><br><small>{Site U1386 Integrated Ocean Drilling Program ( IODP ) Site U1386 was drilled during Expedition 339 in November to January 2011/2012 and is located southeast of the Portuguese Margin mounded on the Faro Drift along the Alvarez Cabral Moat at 36 ° 49.68 ′ N ; − 7 ° 45.32 ′ W in 561 m water depth ( Fig. 1B and C ) .}<\/small>"],null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-64.3716666666667,68.0849633333333],"lng":[-70.26,148.323333333333]}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

After cleaning the corpus, here are the sites that we pull out from GeoDeepDive. We find 11 papers with 30 coordinate pairs out of 150 documents in the IRDDive test dump. We still have limitations to the current methods.  First, it appears we are finding papers where IRD is simply mentioned, and it is not core data. To circumvent this issue, we need to know where in these papers IRD is being referred to. Perhaps we can target certain parts of the paper, like the Methods, to ensure we are getting coordinates for IRD data. While we are finding papers with IRD and core data, we are finding papers with IRD and no core data, so it is an important next step to evaluate whether these papers actually contain coordinate information. Additionally, some papers mention IRD in the core data for continental cores (see Central Asia location). Perhaps by stripping documents that mention 'continental (place name)' we can clean this further. Another option is to cross-reference it with polygons of the continents and remove coordinate pairs that fall within the continental boundaries. One last step is to to obtain documents that mention IRD, but as 'IRD-rich layers' by using a regex. Once these last few issues are sorted out, we can begin to pull dates and provenance information from the documents.  

## Pulling ages and age ranges

One of the next steps once the corpus of doucments is cleaned and coordinates obtained and cross-referenced to a database of ODP cores is pull ages and age ranges associated with IRD events. This will require building regex's that pull dates with many different naming conventions. For example, we will need to consider: 

| Age reference |
| -----------   |
| years BP      |
| kyr BP        |
| ka BP         |
| a BP          |
| etc.          |

For this, we can use the `browse()` function to look for the different naming conventions and then start pulling ages and age ranges associated with them. 


```r
<<<<<<< Updated upstream

is_date <- str_detect(full_nlp$word, "BP")

x$word[is_date&ird_word][4]

date_range <- str_detect(full_nlp$word, 
                         "(\\d+(?:[.]\\d+)*),((?:-{1,2})|(?:to)),(\\d+(?:[.]\\d+)*),([a-zA-Z]+,BP),")

date_match <- str_match(full_nlp$word, 
                         "(\\d+(?:[.]\\d+)*),((?:-{1,2})|(?:to)),(\\d+(?:[.]\\d+)*),([a-zA-Z]+,BP),") %>% na.omit()

browse(x = data.frame(gddid = x$`_gddid`[ird_word&!france], 
                      words = x$word[ird_word&!france]), 
       pubs = publications)

number <- str_detect(full_nlp$word, 
                         ",(\\d+(?:[\\.\\s]\\d+){0,1}),.*?,yr,")
```

## Output from pulling and cleaning dates using regex:

| Age ranges             |         
| -----------            |
| "76,to,62,kyr,BP,"     |
| "6,--,6.4,kyr,BP,"     |
| "6,to,3,kyr,BP,"       |
| "11,--,10,kyr,BP,"     |
| "6.0,--,6.7,kyr,BP,"   |

| Age captures     |
| -----------      |
| "76"  "to" "62"  | 
| "6"   "--" "6.4" |
| "6"   "to" "3"   |
| "11"  "--" "10"  |
| "6.0" "--" "6.7" |

| Date Label  |
| ----------- |
| "kyr,BP"    |
| "kyr,BP"    |
| "kyr,BP"    |
| "kyr,BP"    |
| "kyr,BP"    |

We are successfully identifying instances of dates in the papers where there are references to IRD. Now we need to match the dates to specific units, etc. 
