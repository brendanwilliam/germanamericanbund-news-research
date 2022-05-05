# Date: May 5th, 2022
# Author: Brendan Keane
# Purpose: Combine all newspaper data with "Kuhn" and "Nazi" encoding and 
#          convert dates and publishers into usable formats

# Libraries
library(dplyr)
library(lubridate)
library(rjson)

# Loading all data
ga_full_raw <- read.csv('germanamerican-newsdata.csv')
ga_kuhn_raw <- read.csv('germanamericanANDkuhn-newsdata.csv')
ga_nazi_raw <- read.csv('germanamericanANDnazi-newsdata.csv')

# Marking Kuhn and Nazi data
ga_kuhn <- ga_kuhn_raw %>%
  mutate(isKuhn = TRUE)

ga_nazi <- ga_nazi_raw %>%
  mutate(isNazi = TRUE)

# Wrangling all data into usable format and saving as a .csv
ga_full <- full_join(ga_full_raw, ga_kuhn) %>%  # Merging Kuhn data
  full_join(ga_nazi) %>%  # Merging Nazi data
  replace(is.na(.), FALSE) %>%
  mutate(date = as.Date(pubdate, '%b %d, %Y')) %>%  # Reformatting dates
  mutate(weekday = format(date, '%a')) %>%
  mutate(month = format(date, '%b')) %>%
  mutate(pubtitle = gsub("\\s*\\([^\\)]+\\)", "", pubtitle)) %>%  # Eliminating years from newspaper titles
  select(Title, Abstract, isKuhn, isNazi, date, year, month, weekday, StoreId, 
         issn, startPage, placeOfPublication, pubtitle, DocumentURL, 
         FindACopy) %>%
  arrange(ymd(date))

ga_full_json = toJSON(ga_full)
write(ga_full_json, 'germanamerican-newsdata-full.json')
write.csv(ga_full, 'germanamerican-newsdata-full.csv')
