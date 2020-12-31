# Description
# You only need to modify and run this if you have a csv file with new query keywords. 
# Replaces mentions of specific states or cities in the queries with "[state]" 
# or "[city]". 

# Author: Julia Park
# Version: 2020-11-11

# Libraries
library(tidyverse)
library(readxl)


# Parameters
setwd("~/GitHub/Lab_Legal_Design/search_audit")

file_eviction <- "eviction.csv"
file_debt_collection <- "debt_collection.csv"
file_flood_contractor <- "flood_contractor.csv"
file_domestic_violence <- "domestic_violence.csv"

#===============================================================================

clean_csv_file <- function(filename) {
  filename %>% 
    read_csv(col_names = "query") %>% 
    mutate(
      query = str_to_lower(query)
    ) %>% 
    mutate(
      query = str_replace_all(query, "\\bcalifornia\\b", "[state]"), 
      query = str_replace_all(query, "\\billinois\\b", "[state]"), 
      query = str_replace_all(query, "\\bca\\b", "[state]"), 
      query = str_replace_all(query, "\\bsan francisco\\b", "[city]"), 
      query = str_replace_all(query, "\\bsf\\b", "[city]"), 
      query = str_replace_all(query, "\\bbay area\\b", "[city]")
    ) %>% 
    write_csv(filename, col_names = FALSE)
}

clean_csv_file(file_eviction)
clean_csv_file(file_debt_collection)
clean_csv_file(file_flood_contractor)
clean_csv_file(file_domestic_violence)
