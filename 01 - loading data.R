## Summary: This script downloads all current files from capital bikeshare,
## saves it on your local machine, unzips the files, reads them into R,
## and creates one big table for all bike rides over time. 
## All individual raw files are uploaded into BQ as well as a sample
## from the bound file (both raw and clean) for future analysis/ exploration.
## The merged dataset is too large to do any real analysis on my local
## machine. Any cleaning to create a final, full dataset of all rides
## will likely need to be done in BQ.

## Sources used:
# Other ways to load into BQ to think about: https://medium.com/google-cloud/bigquery-explained-data-ingestion-cdc26a588d0
# Documentation: https://cloud.google.com/bigquery/docs/loading-data
# Stack Overflow post used: https://stackoverflow.com/questions/73722424/how-to-upload-table-data-frame-from-r-to-bigquery
# bigrquery documentation: https://bigrquery.r-dbi.org/

normalizePath(R.home())

# HEADER -----------------------------------------------------------------------
rm(list=ls())
gc()
git_wd <- 'C:/Users/khilto01/Documents/git/cap-bikeshare/'
output_wd <- "C:/Users/khilto01/Documents/cap-bikeshare/"
file_base <- "https://s3.amazonaws.com/capitalbikeshare-data/"
source(file.path(git_wd, '00 - standard packages + functions.R'))

# DOWNLOADING DATA -------------------------------------------------------------
## NOTE: downloaded from https://s3.amazonaws.com/capitalbikeshare-data/index.html
## Downloading each file by year/ month, saving locally
for (year in c(2010:2024)) {
  print(year)
  
  ## Years with 1 file in total
  if (year %in% c(2010:2017)) {
    file_url <- paste0(file_base, as.character(year), "-capitalbikeshare-tripdata.zip")
    download.file(file_url, destfile=paste0(output_wd, year, "-capitalbikeshare-tripdata.zip"))
    } 
  
  ## Years with 1 file per month
  if (year %in% c(2018:2023)) {
    ## NOTE: no file in April 2020
    for (month in c(1:12) ) {
      if (year == 2020 & month == 4) {
        next
      }
      month <- str_pad(month, 2, 'left', pad='0')
      file_url <- paste0(file_base, as.character(year),month, "-capitalbikeshare-tripdata.zip")
      download.file(file_url, destfile=paste0(output_wd, year, month,"-capitalbikeshare-tripdata.zip"))
    }
  }
  
  ## Current year (months 1-10)
  if (year == 2024) {
    for (month in c(1:10) ) {
      month <- str_pad(month, 2, 'left', pad='0')
      file_url <- paste0(file_base, as.character(year),month, "-capitalbikeshare-tripdata.zip")
      download.file(file_url, destfile=paste0(output_wd, year, month,"-capitalbikeshare-tripdata.zip"))
    }
  }
}
rm(year, month)

# UNZIPPING DATA ---------------------------------------------------------------
for (f in list.files(output_wd, full.names = T)) {
  print(f)
  if (str_detect(f, "unzipped")) { next }
  unzip(f, exdir = file.path(output_wd, "unzipped"))
}
rm(f)

# OPENING AND COMBINING DATA ---------------------------------------------------
## Goes through each filename in files:
# -reads in as CSV 
# -(and prints filename and number of columns)
# -uploads to BQ
# -binds all together to create cap_bikeshare dataset
## NOTE: reading all columns as characters right now so bind will go smoothly
timestamp()
files <- list.files(file.path(output_wd, 'unzipped'), pattern = "\\.csv")
cap_bikeshare <- map_df(files,
                        function(x) cap_bikeshare_function(x))
timestamp()
## NOTE: 25 GB's of R memory used to load this in (hence loading it to BQ)

# DATA CHECKS ------------------------------------------------------------------
## NOTE: There is no April 2020 file on website, when you download
## the folder of April 2024 the dates in the file say 2024 BUT the file
## is labeled 2020
nrow(cap_bikeshare)
length(unique(cap_bikeshare$file)) == length(list.files(file.path(output_wd, 'unzipped'), pattern = "\\.csv"))
View(head(cap_bikeshare, 100))
summary(cap_bikeshare)
colnames(cap_bikeshare)

## Unique ID?
length(unique(cap_bikeshare$ride_id)) == nrow(cap_bikeshare)
length(unique(cap_bikeshare$ride_id)) == nrow(filter(cap_bikeshare, !is.na(ride_id)))
length(unique(cap_bikeshare$`Bike number`)) == nrow(filter(cap_bikeshare, !is.na(`Bike number`)))
length(unique(cap_bikeshare$ride_id)) == nrow(filter(cap_bikeshare, !is.na(started_at)))
length(unique(cap_bikeshare$`Bike number`)) == nrow(filter(cap_bikeshare, is.na(started_at)))

## NOTE: may need to create a unique ID by ride

# CREATING SMALLER SAMPLE TO CLEAN/ TAKE A CLOSER LOOK -------------------------
## Getting a sample to look at closer- keeping top 5 observations from each file
sample <- cap_bikeshare %>%
  group_by(file) %>%
  mutate(row = row_number()) %>%
  ungroup() %>%
  filter(row <= 5)
  
## Put variables of the same name side by side
sample <- sample %>%
  mutate(year = year(`Start date`),
         month = month(`Start date`)) %>%
  select(ride_id, year, month,
         `Bike number`,rideable_type,
         `Member type`,member_casual,
         `Start date`, started_at,
         `End date`, ended_at,
         Duration,
         `Start station number`, start_station_id,
         `Start station`,start_station_name,
         `End station`, end_station_name,
         `End station number`, end_station_id,
         start_lat, start_lng, end_lat, end_lng,
         file)
View(sample)
unique(sample$member_casual)
unique(sample$`Member type`)
## Variable names seem to change April 2020 (explains why there is
## no data for that month, must have been doing some sort of shift)

## NOTE: Will base all dates off of start dates (if passed midnight, will default to
## start time/ day)
## Sample cleaning code
sample_clean <- sample %>%
  mutate(start_date_kh = ifelse(is.na(`Start date`), started_at,  `Start date`),
         year = lubridate::year(start_date_kh),
         month = lubridate::month(start_date_kh),
         year_month = format(as.Date(start_date_kh), "%Y-%m"),
         end_date_kh = ifelse(year_month > '2020-04', ended_at,  `End date`),
         member_type_kh = str_to_lower(ifelse(year_month > '2020-04', member_casual, `Member type`)),
         id_kh = ifelse(year_month > '2020-04', ride_id, `Bike number`),
         duration_kh = as.numeric(difftime(end_date_kh,start_date_kh, units="mins")),
         start_station_id_kh = ifelse(year_month > '2020-04', start_station_id, `Start station number`),
         start_station_name_kh =  ifelse(year_month > '2020-04', start_station_name, `Start station`),
         end_station_id_kh =  ifelse(year_month > '2020-04',end_station_id , `End station number`),
         end_station_name_kh =  ifelse(year_month > '2020-04', end_station_name, `End station`)) %>%
  select(id_kh, ride_id, bike_number=`Bike number`, 
         year, month, year_month, 
         rideable_type,
         ends_with("_kh"),
         start_lat, start_lng, end_lat, end_lng,
         file)

# UPLOADING SAMPLE TO BQ -------------------------------------------------------
bq_table_create("cap-bikeshare-441121.sample_bikeshare_data.sample_data_raw", as_bq_fields(sample))
bq_table_upload("cap-bikeshare-441121.sample_bikeshare_data.sample_data_raw", sample)

bq_table_create("cap-bikeshare-441121.sample_bikeshare_data.sample_data", as_bq_fields(sample_clean))
bq_table_upload("cap-bikeshare-441121.sample_bikeshare_data.sample_data", sample_clean)

rm(sample, sample_clean)
gc()
