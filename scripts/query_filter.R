# Description
# Deletes all queries with [state] and [city]
# Used because the search audit for FL/HI audit in January replaced [state] and [city] incorrectly. 

# Author: Julia Park
# Version: 2020-11-23

# Libraries
library(tidyverse)
library(readxl)


# Parameters
setwd("~/GitHub/Lab_Legal_Design/search_audit")

file_eviction <- "eviction"
file_debt_collection <- "debt_collection"
file_flood_contractor <- "flood_contractor"
file_domestic_violence <- "domestic_violence"




#===============================================================================

clean_csv_file <- function(type) {
  str_glue(type, ".csv") %>% 
    read_csv(col_names = "query") %>% 
    filter(!str_detect(query, "\\[state\\]")) %>% 
    filter(!str_detect(query, "\\[city\\]")) %>% 
    write_csv(str_glue(type, "_filtered.csv"), col_names = FALSE)
}

clean_csv_file(file_eviction)
clean_csv_file(file_debt_collection)
clean_csv_file(file_flood_contractor)
clean_csv_file(file_domestic_violence)
