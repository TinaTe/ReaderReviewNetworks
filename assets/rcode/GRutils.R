library(stringr)
library(readr)
library(tidyr)
library(dplyr)
library(tidyverse)
## (cur03 ist übrigens weird)
PATH_ALL <- "../goodreads_basel/imported_annotations"
PATH_EX <- "../goodreads_basel/imported_annotations/curated_07_round/" 
PATH_EX_REV <- "Input_Data/review_txts/07_round_annotations"
PATH_ALL_REV <- "Input_Data/review_txts"
##### Daten einlesen --------

## read.csv + informations from filename as columns
read_plus <- function(csvName){
  print(csvName)
  table <- read.csv(csvName, sep = "\t", encoding = "UTF-8", header = F) %>% 
    mutate(
      link = str_extract(csvName, "\\d+_\\w+[\\.]") %>%
        str_remove("\\.") %>% 
        str_replace_all("_", "-"),
      round = str_extract(csvName, "(?<=[_])\\d+?(?=[_])"),
      title = str_extract(csvName, "\\d+_\\w+[\\.]") %>% 
        str_extract("(?<=[_]).+?(?=[.])"),
      review = str_extract(csvName, "(?<=[.])\\d+(?=[.])")) %>% 
    separate(V1, c("V1", "onset", "offset"), sep = " ") %>% 
    group_by(V1) %>% 
    mutate(V1 = ifelse((grepl("Mention", V1)), paste0("Absorption", V1), paste0("Absorption_", V1)),
           V1 = ifelse((grepl("Present|Absent", V1)), V1, paste0(V1, "_recheck"))) %>% 
    mutate(mode = str_split(V1, "_") [[1]][[1]],
           main = str_split(V1, "_") [[1]][[2]],
           presence = str_split(V1, "_") [[1]][[4]],
           tag = str_split(V1, "_") [[1]][[3]],
           statement = V2
           ) %>% 
    ungroup()
}

# read review txts
read_rev_txts <- function(path) {
  review <- c()
  full_review <- c()
  link <- c()
  title <- c()
  round <- c()
    for (folder in list.files(path, full.names = T)) {
      for (file in list.files(folder, full.names = T)) {
        print(file)
        review <- c(review, str_extract(file, "(?<=[.])\\d+(?=[.])"))
        full_review <- c(full_review, c(read_lines(file)))
        round = c(round, str_extract(folder, "\\d+"))
        link = c(link, str_extract(file, "\\d+_\\w+[\\.]") %>% 
                   str_remove("[.]") %>% 
                   str_replace_all("_", "-"))
        title = c(title, str_extract(file, "\\d+_\\w+[\\.]") %>% 
          str_extract("(?<=[_]).+?(?=[.])"))
      }
    }
  reviews_full <- data.frame(link, review, full_review, title, round) %>%
    mutate(round = if_else(round == "08", "0809", round),
           round = if_else(round == "09", "0809", round),
           round = if_else(round == "13", "1314", round),
           round = if_else(round == "14", "1314", round))
}

## list.files mit überprüfung ob files nich leer
list_full_files <- function(path) {
  list <- list.files(path, full.names = T)
  list[sapply(list, file.size) > 0]
}

# alle dateien eines ordners zu df
read_dir <- function(path) {
  files <- list_full_files(path) %>% 
    map_dfr(~read_plus(.)) %>% 
    select(link, round, title, review, mode, main, presence, tag, statement, onset, offset)
} 
# alle dateien der curated ordner zu df
## dir_pattern falls mehrere dirs im Ordner sind (curated_08_round; und recurated_08_round bspw.)
read_all <- function(path, dir_pattern = NULL) {
  dirs <- list.files(path, pattern = dir_pattern, 
                     full.names = T, recursive = F) %>% 
    map_dfr(~read_dir(.))
}

convertSWAS <- function(oldData) {
  newData <- oldData %>% 
      mutate(SWAS_category = case_when(
        main == "SWASSpecific" & grepl("A", tag) ~ "Attention",
        main == "SWASSpecific" & grepl("EE", tag) ~ "Emotional_Engagement",
        main == "SWASSpecific" & grepl("MS", tag) ~ "Mental_Imagery",
        main == "SWASSpecific" & grepl("T", tag) ~ "Transportation",
        main == "SWASSpecific" & grepl("I", tag) ~ "Impact",
        tag %in% c("Anticipation", "InabilitytoStopReading") ~ "Attention",
        tag %in% c("EffortlessEngagement", "WishtoReread", "Anticipation(BookSeries)", 
                   "Addiction", "LingeringStoryFeelings") ~ "Impact",
        tag %in% c("WishfulIdentification", "EmotionalUnderstanding", 
                   "ParasocialResponse", "ParticipatoryResponse") ~ "Emotional_Engagement",
        tag == "Realness" ~ "Mental_Imagery"
      ),
      SWAS_tag = case_when(
        #Attention
        tag == "A1" ~ paste0(tag, " Altered_sense_of_time"),
        tag == "A2" ~ paste0(tag, " Concentration"),
        tag == "A3" ~ paste0(tag, " General_sense_of_absorption"),
        tag == "A4" ~ paste0(tag, " No_distractions"),
        tag == "A5" ~ paste0(tag, " Forgetting_Surroundings"),
        tag == "A6" ~ paste0("A3", " General_sense_of_absorption"),
        tag == "Anticipation" ~ paste0("A6 ", tag),
        tag == "InabilitytoStopReading" ~ paste0("A7 ", "Inability_to_Stop_Reading"),
        #Emotional Engagement
        tag == "EE1" ~ paste0(tag, " Perspective_taking"),
        tag == "EE2" ~ paste0(tag, " Sympathy"),
        tag == "EE3" ~ paste0(tag, " Emotional_connection"),
        tag == "EE4" ~ paste0(tag, " Empathy"),
        tag == "EE5" ~ paste0(tag, " Compassion_for_story_events"),
        tag == "EE6" ~ paste0(tag, " Anger"),
        tag == "EE7" ~ paste0(tag, " Fear"),
        tag == "EE8" ~ paste0(tag, " Knowing_Characters"),
        tag == "WishfulIdentification" ~ paste0("EE9", " Wishful_Identification"),
        tag == "EmotionalUnderstanding" ~ paste0("EE10", " Emotional_Understanding"),
        tag == "ParasocialResponse" ~ paste0("EE11", " Parasocial_Response"),
        tag == "ParticipatoryResponse" ~ paste0("EE12", " Participatory_Response"),
        #Mental Imagery
        tag == "MS1" ~ paste0(tag, " Imagery_of_character"),
        tag == "MS2" ~ paste0(tag, " Imagery_of_story_events"),
        tag == "MS3" ~ paste0(tag, " Imagery_of_story_world"),
        tag == "Realness" ~ paste0("MS4", " Realness"),
        #Transportation
        tag == "T1" ~ paste0(tag, " Presence"),
        tag == "T2" ~ paste0(tag, " Merge_of_fiction_in_Reality"),
        tag == "T3" ~ paste0(tag, " Proximity_of_story_world"),
        tag == "T4" ~ paste0(tag, " Deictic_shift"),
        tag == "T5" ~ paste0(tag, " Part_of_the_story_world"),
        tag == "T6" ~ paste0(tag, " Return_deictic_shift"),
        tag == "T7" ~ paste0(tag, " Travel_in_story_world"),
        #Impact
        tag == "EffortlessEngagement" ~ paste0("IM1", " Effortless_Engagement"),
        tag == "WishtoReread" ~ paste0("IM2", " Wish_to_reread"),
        tag == "Anticipation(BookSeries)" ~ paste0("IM3", " Anticipation_BookSeries"),
        tag == "Addiction" ~ paste0("IM4", " Addiction"),
        tag == "LingeringStoryFeelings" ~ paste0("IM5", " Lingering_Story_Feelings")
      )
      )%>% 
    relocate(c(SWAS_category, SWAS_tag), .after = presence) %>% 
    select(-c(main, tag))
}

##### Dopplungen und fehlende Daten entfernen --------
clean_data <- function(data) {
  data <- data %>% 
    filter(presence != "recheck") %>% 
    filter(tag != "NA") %>% 
    group_by(review, onset, tag) %>% 
    filter(n()==1) %>% 
    ungroup() %>% 
    group_by(review, offset, tag) %>% 
    filter(n()==1) %>% 
    ungroup() #%>%
    # group_by(review, tag) %>%
    # mutate(diffTag = 1:n()) %>%
    #  mutate(
    #    double = ifelse((tag != lead(tag)), diffTag, NA)
    #  ) %>%
    #  fill(double, .direction = "up") # %>% 
    #  mutate(
    #    double = ifelse((is.na(double)), 0, double)
    #  ) %>% 
    #  ungroup() %>% 
    # # group_by(review, double) %>% 
    # mutate(
    #   doubletrouble = ifelse(lead(as.integer(onset), default = 2000000)<as.integer(offset), NA, diffTag)
    # ) %>% 
    # fill(doubletrouble, .direction = "up") %>% 
    # group_by(doubletrouble) %>% 
    # filter(n()==1) %>% 
    # ungroup() %>% 
    #   select(-c(diffTag, double, doubletrouble))
}
