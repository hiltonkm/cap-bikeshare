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
## Goes through each filename in files, reads in as CSV, and binds together
## to create cap_bikeshare dataset
## NOTE: reading all columns as characters right now so bind will go smoothly
timestamp() ##------ Thu Nov  7 16:17:07 2024 ------##
files <- list.files(file.path(output_wd, 'unzipped'), pattern = "\\.csv")
cap_bikeshare <- map_df(files,
  function(x) 
    read_csv(file.path(output_wd, "unzipped", x), col_types = rep("c", 14)) %>% 
    mutate(file=x)
  )
timestamp()

# CLEAN DATA -------------------------------------------------------------------
length(unique(cap_bikeshare$file)) == length(files)
colnames(cap_bikeshare)
View(head(cap_bikeshare, 100))
length(unique(cap_bikeshare$ride_id)) == nrow(cap_bikeshare)
summary(cap_bikeshare)

cap_bikeshare <- cap_bikeshare %>%
  mutate(year = str_sub(file, 1, 4),
         month = month(started_at))
tabyl(cap_bikeshare, year)

# WRITE TO BQ -------year()# WRITE TO BQ ------------------------------------------------------------------
?bq_table_upload()

