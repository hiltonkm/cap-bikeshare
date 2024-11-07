## Template of file to house all file paths
## NOTE: Need to have box id to run

## Turning off summarize options in dplyr
options(dplyr.summarise.inform = FALSE)
## Turning off scientific notation
options(scipen = 999)

# LIBRARY ----------------------------------------------------------------------

## Packages
## (Note: you likely don't need all of these: tidyverse is generally
## the main one to start with, but all of these should cover most
## of the work at CIRCLE)
library(tidyverse)
# library(rvest)
# library(RSelenium)
library(tidycensus)
library(janitor)
library(rlang)
library(openxlsx)
library(readxl)
library(googlesheets4)
library(lubridate)
library(sf)
library(scales)
library(viridis)
library(bigrquery)
