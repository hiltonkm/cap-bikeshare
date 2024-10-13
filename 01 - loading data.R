# HEADER -----------------------------------------------------------------------
rm(list=ls())
gc()
git_wd <- 'C:/Users/khilto01/Documents/git/cap-bikeshare/'
output_wd <- "C:/Users/khilto01/Documents/cap-bikeshare/"
file_base <- "https://s3.amazonaws.com/capitalbikeshare-data/"
source(file.path(git_wd, '00 - standard packages + functions.R'))

# LOADING DATA -----------------------------------------------------------------
## NOTE: downloaded from https://s3.amazonaws.com/capitalbikeshare-data/index.html
## Downloading each file by year/ month, saving locally
for (year in c(2010:2024)) {
  print(year)
  
  if (year %in% c(2010:2017)) {
    file_url <- paste0(file_base, as.character(year), "-capitalbikeshare-tripdata.zip")
    download.file(file_url, destfile=paste0(output_wd, year, "-capitalbikeshare-tripdata.zip"))
    } 
    
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
  
  if (year == 2024) {
    for (month in c(1:9) ) {
      month <- str_pad(month, 2, 'left', pad='0')
      file_url <- paste0(file_base, as.character(year),month, "-capitalbikeshare-tripdata.zip")
      download.file(file_url, destfile=paste0(output_wd, year, month,"-capitalbikeshare-tripdata.zip"))
    }
  }
}

# UNZIPPING DATA ---------------------------------------------------------------
for (f in list.files(output_wd, full.names = T)) {
  print(f)
  if (str_detect(f, "unzipped")) { next }
  unzip(f, exdir = file.path(output_wd, "unzipped"))
}


