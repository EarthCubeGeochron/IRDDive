# IRDDive
Mining documents with IRD data over the last 5 millions years.

By: Jeremiah Marsicek

Date: 02/07/2018

## Purpose:
To get information about the spatiotemporal extent of IRD events over the last 5 million. The ultimate goal could be to make a series of maps with the publication date, publication, and latitude/longitude and timing of IRD events.

## Main Resources:

We will use R and RStudio to do the data processing, GeoDeepDive to retreive documents of interest via string matching and to generate a subset of the output (for testing) as NLP output.

## What are some example publications?
1. Ice-rafted debris associated with binge/purge oscillations of the Laurentide Ice Sheet (http://onlinelibrary.wiley.com/doi/10.1029/94PA01008/full)

2. Catastrophic ice shelf breakup as the source of Heinrich event icebergs (http://onlinelibrary.wiley.com/doi/10.1029/2003PA000890/full)

3. The sources of the glacial IRD in the NW Iberian Continental Margin over the last 40 ka (https://doi.org/10.1016/j.quaint.2013.08.026)

Using these example publications I have found the these terms appear the most:

  Terms for IRD: iceberg rafting, IRD, ice-rafted debris, Heinrich events
  
  These papers talk about IRD in the following locations: North Atlantic, Ruddiman Belt, Hudson Bay, Antarctic
  
  Most common time frames: last glaciation, Pleistocene, Holocene, year subsets
  
## Targets with NLP output from GDD team:

  Extract latitude and longitudes using Simon's code as a template (which uses regular expressions to get lat/long).  
  
  Place names using “Who’s on First” (a large Postgres database of place names with associated polygons).
  
  Extract time periods using regular expressions and queries for stratigraphic names and regular expressions.
  
## Accessing the RMarkdown document as an html: 

http://htmlpreview.github.io/?https://github.com/EarthCubeGeochron/IRDDive/blob/master/empty-spaces.html
