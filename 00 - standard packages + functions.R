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
library(DBI)

# FUNCTIONS --------------------------------------------------------------------
## NOTE: This is the function that will be used to bind all the individual 
## bikeshare data sets together AND upload those individual datasets to BQ
cap_bikeshare_function <- function(x) {
  ## Print filename
  print(x)
  ## Read in CSV
  df <- read_csv(file.path(output_wd, "unzipped", x), col_types = "cccccccccccccc") %>% 
    mutate(file=x)
  ## Print # of columns
  print(ncol(df))
  ## Create a tablename without -'s and .csv
  table_name <- str_replace_all(x, "-", "_")
  table_name <- str_replace(table_name, "_tripdata.csv", "")
  ## Upload raw csv's as tables read in above to raw bikeshare dataset in Bq
  bq_table_create(paste0("cap-bikeshare-441121.raw_bikeshare_data.",table_name), as_bq_fields(df))
  bq_table_upload(paste0("cap-bikeshare-441121.raw_bikeshare_data.",table_name), df)
  gc()
  ## Return final df to be bound together with other files
  return(df)
}
