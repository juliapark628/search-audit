# Description
# Processes raw query data for Florida/Hawaii
# Creates separate complete query list and filtered list (non-location-specific). 
# But only the FL_HI_audit_Jan_2020 has incorrect location queries. 

# Author: Julia Park
# Version: 2020-12-30

# Libraries
library(tidyverse)
library(readxl)


# Parameters
setwd("~/GitHub/Lab_Legal_Design/search_audit")

which_audit <- "FL_HI_audit_Nov_2020" # format "FL_HI_audit_[month]_[year], must exist as a folder in data/ and processed_data/

dir_files <- str_glue("data/", which_audit)

remove_queries <- 
  c(
    "couple's counseling bay area", 
    "emergency phone number", 
    "peacekeeper solutions", 
    "Places I can stay", 
    "how to make good relationship with partner", 
    "relationship advice and coaching", 
    "local police department", 
    "defusing a situation", 
    "ptsd", 
    "How to run away", 
    "Spouse/husband said he would hurt me", 
    "escaping relationship", 
    "911", 
    "police number", 
    "paranoia", 
    "Places that are safe", 
    "Best methods for good marriage life", 
    "where to go for advice with a troublesome relationship", 
    "I need help", 
    "support group locations", 
    "insecurity and anger", 
    "How to contact the police", 
    "Problems and solutions with wife",
    "bad roofing company",
    "free legal aid",
    "husband",
    "lawsuit help"
  )


#===============================================================================

# get directory of all files
files <- fs::dir_ls(dir_files)

# read in all data into one large table
all_tables <- 
  files %>%
  map_dfr(read_csv, .id = "legal_type") %>% 
  mutate(
    # get legal_type from file name
    legal_type = str_extract(legal_type, pattern = "(?<=result_).*") %>% str_remove("_all"), # my files don't have .csv, but if they do add (?=\\.csv) after asterisks in pattern
    place = str_extract(location, pattern = "[^,]+") %>% str_to_title(),
    place = case_when( # rename zip code into cities
      place %in% "96813" ~ "Honolulu",
      place %in% "96792" ~ "Rural Oahu",
      TRUE ~ place
    ),
    state = case_when( # get State information
      place %in% c("Honolulu", "Maui", "Rural Oahu", "Rural Hilo") ~ "Hawaii", 
      place %in% c("Jacksonville", "Pensacola", "Tallahassee") ~ "Florida",
      TRUE ~ NA_character_
    ),
    full_url = str_c(urldomain, ".", urlsuffix)
  ) %>% 
  distinct() %>% 
  filter(!(qry %in% remove_queries))


# save complete query information
all_tables %>% 
  filter(!is.na(full_url)) %>% 
  count(full_url, sort = TRUE) %>% 
  write_csv(str_glue("processed_data/", which_audit, "/most_common_urls_complete.csv"))

all_tables %>% 
  filter(!is.na(url)) %>% 
  count(url, sort = TRUE) %>% 
  write_csv(str_glue("processed_data/", which_audit, "/most_common_links_complete.csv"))

all_tables %>% 
  write_csv(str_glue("processed_data/", which_audit, "/all_queries_complete.csv"))


# filter location specific queries
all_tables <- all_tables %>% 
  filter(!str_detect(qry, "Hawaii")) %>% 
  filter(!str_detect(qry, "Florida")) %>% 
  filter(!str_detect(qry, "Honolulu")) %>% 
  filter(!str_detect(qry, "Oahu")) %>% 
  filter(!str_detect(qry, "Jacksonville")) %>% 
  filter(!str_detect(qry, "Pensacola")) %>% 
  filter(!str_detect(qry, "Tallahassee"))


# save filtered query information
all_tables %>% 
  filter(!is.na(full_url)) %>% 
  count(full_url, sort = TRUE) %>% 
  write_csv(str_glue("processed_data/", which_audit, "/most_common_urls_filtered.csv"))

all_tables %>% 
  filter(!is.na(url)) %>% 
  count(url, sort = TRUE) %>% 
  write_csv(str_glue("processed_data/", which_audit, "/most_common_links_filtered.csv"))

all_tables %>% 
  write_csv(str_glue("processed_data/", which_audit, "/all_queries_filtered.csv"))

