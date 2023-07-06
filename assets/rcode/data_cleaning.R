library(dplyr)
#library(spacyr)
library(uchardet)
library(tidyr)
library(readr)

# full_revs <- data_5_genres %>% 
#   select(doc_id = review, text = full_review) %>% 
#   distinct()
# spacy_initialize()
# parsed_revs <- spacy_parse(full_revs, pos = F, tag = F, lemma = T, encoding = "ASCII") 
# entities <- parsed_revs %>%
#   filter(entity != "")
#   

# View(entities %>% filter(entity=="WORK_OF_ART_I") %>% 
#   select(lemma, doc_id) %>% 
  # distinct())

## deselect misidentified or irrelevant entities, filter entities
  
curated_ents <- parsed_revs %>%
  mutate(entity = ifelse(entity=="WORK_OF_ART_B" & lemma %in% c("2", "2010", "3", "3/6/17", 
                                                                "A", "A+", "Addict", "Badass", "Book", 
                                                                "darlin", "Daydreamer", "do", "F*CK", 
                                                                "Guide", "HELL", "HOLY", "I", "List", 
                                                                "MAZING", "Mischief", "MYSTERY", "rambling",
                                                                "Readers", "review", "Rn2", "THE", "what"), 
                         paste0(""), entity)) %>% 
  mutate(entity = ifelse(entity=="WORK_OF_ART_I" & lemma %in% c("2", "2010", "3", "3/6/17", 
                                                                "A", "A+", "Addict", "Badass", "Book", 
                                                                "darlin", "Daydreamer", "do", "F*CK", 
                                                                "Guide", "HELL", "HOLY", "I", "List", 
                                                                "MAZING", "Mischief", "MYSTERY", "rambling",
                                                                "Readers", "review", "Rn2", "THE", "what", "Managed"), 
                         paste0(""), entity)) %>% 
  mutate(entity = ifelse(entity=="PERSON_I" & lemma %in% c("@ingesbooks", "5", "and", "Books", 
                                                           "Century", "daydreamer", "Ding", "Fantasy", "Kiss", "Paperback", 
                                                           "PERFECT", "Policemen", "read", "Review", "Sighhhhh", "Thoughts",
                                                           "TOO", "Touch", "Tribal", "wear"), 
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="PERSON_B" & lemma %in% c("15th", "Amazon", "Common", "Ding", "Fantasy",
                                                           "First", "giveaway", "gore", "Hotness", "Idk", "love",
                                                           "Mind", "pinkie", "Quaterback", "read", "romance", "shall",
                                                           "slang", "Sorry", "Superb", "Yaaaas", "Yep", "YOU'RE", "yang"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="GPE_B" & lemma %in% c("fuckin", "POV", "c’m", "Horror", "YA"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="ORG_B" & lemma %in% c("ADORABLE", "AHA", "AI", "Amazon", "ARC",
                                                        "AWESOME", "B+", "bestseller", "BitCoin", "BLONDE",
                                                        "claustrophobia", "dark", "date", "DEAD", "ebook",
                                                        "EPIC", "Fiction", "Genre", "Goodreads", "greatnes",
                                                        "he", "HEA", "Initial", "iPhones", "jargon", "la",
                                                        "LibraryThing", "lol", "LOL", "love", "Mature", "meh",
                                                        "MINE", "NA", "Naïve", "Naïve", "need", "NEVER",
                                                        "Noir", "NOPE", "nuts", "ORIGINALLY", "POV",
                                                        "Renaissance", "review", "romance", "sassy", "SAT",
                                                        "Scholastic", "sci", "Science", "SciFi", "SEXY",
                                                        "Shit", "smart", "SO", "sorta", "Sourcebooks", "superb",
                                                        "Tumblr", "UGH", "waaaaah", "WAHHHH", "who", "wow", "WOW",
                                                        "WTF", "www.areadingmachine.com", "xD", "xoxo", "YA"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="ORG_I" & lemma %in% c("through", "Steam", "Roll", "Reviewer", "Review",
                                                        "reader", "POV", "only", "n", "Life",
                                                        "Impressions", "Fiction", "fi", "eeeep", "Edition",
                                                        "Children", "category", "Caffeinated", "Book", "Adult", "4.5",
                                                        "1998", "12/21/16"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="PRODUCT_B" & lemma %in% c("Voodoo", "Tall", "a+", "Aly", "A+", "ya", "YA"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="PRODUCT_I" & lemma %in% c("Poppy", "Syndrome", "@bookishaly", "Aly", "A+", "ya", "YA"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="LAW_I" & !lemma %in% c("Witch", "of", "the", "Waste", "dillion"),
                         "", entity)) %>%  ## was easier to do it the other way around
  mutate(entity = ifelse(entity=="GPE_I" & lemma %in% c("-"), "", entity)) %>% 
  mutate(entity = ifelse(entity=="FAC_B" & lemma %in% c("National", "Escape"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="FAC_I" & lemma %in% c("Children", "Costa", "Park", "Pod"),
                         "", entity)) %>% 
  mutate(entity = ifelse(entity=="MONEY_B" & !lemma %in% c("4mk"),
                         "", entity)) %>%  ## was easier to do it the other way around
  mutate(entity = ifelse(entity=="MONEY_I" & !lemma %in% c("ISK"),
                         "", entity)) %>%  ## was easier to do it the other way around
  mutate(entity = ifelse(entity == "ORG_B" & doc_id == 12792980 & lemma == "Rock", "", entity)) %>% 
  mutate(entity = ifelse(entity == "PERSON_B" & doc_id == 10434339 & lemma == "Lady", "", entity)) %>% 
  mutate(entity = ifelse(entity=="WORK_OF_ART_B" | entity=="WORK_OF_ART_I" & doc_id == 1608828 | doc_id == 12934387 & lemma == "in", "", entity)) %>% 
  mutate(entity = ifelse(entity=="WORK_OF_ART_B" | entity=="WORK_OF_ART_I" & doc_id == 781140 & lemma == "love", "", entity)) %>% 
  mutate(entity = ifelse(!entity %in% c("PERSON_B", "PERSON_I", "WORK_OF_ART_B", "WORK_OF_ART_I", "GPE_B", "LOC_B", "LOC_I", "ORG_B", 
                         "ORG_I", "GPE_I", "NORP_B", "PRODUCT_B", "PRODUCT_I", "LAW_I", "FAC_B", "FAC_I", "MONEY_B", 
                         "MONEY_I"), NA, entity ))

review_info <- data_5_genres %>% 
  select(doc_id = review, genre, plotable_title) %>% 
  mutate(doc_id = as.integer(doc_id)) %>% 
  distinct()

joined_data <- curated_ents %>% 
  mutate(doc_id = as.integer(doc_id)) %>% 
  left_join(review_info)

missing_ents <- joined_data %>%
  mutate(lemma = tolower(lemma)) %>% ## to lower to catch most cases
  group_by(plotable_title, lemma) %>%
  fill(entity, .direction = "downup")
  
entities <- missing_ents %>% 
  filter(entity != "") %>% 
  select(c("lemma")) %>% 
  distinct()
non_ents <- missing_ents %>% 
  ungroup() %>% 
  filter(is.na(entity)) %>% 
  select(c("lemma")) %>% 
  distinct()
title_words <- data_5_genres %>% 
  mutate(title_words_lower = str_split(tolower(title), "_")) %>% 
  mutate(title_words = stringr::str_to_title(str_split(title, "_"))) %>% 
  select(title_words,title_words_lower, plotable_title) %>% 
  distinct()

filtered_ents <- missing_ents %>% 
  filter(!entity %in% c("PERSON_B", "PERSON_I", "WORK_OF_ART_B", "WORK_OF_ART_I", "GPE_B", "LOC_B", "LOC_I", "ORG_B", 
                        "ORG_I", "GPE_I", "NORP_B", "PRODUCT_B", "PRODUCT_I", "LAW_I", "FAC_B", "FAC_I", "MONEY_B", 
                        "MONEY_I")) %>% 
  filter(!lemma %in% c("the", "a", "an", "of", "or", "adam", "mary",
                       "breq", "paul", "anna", "NEVERWHERE", "ANNA", "Anna", 
                       "luke", "and",  "he", "his", "her", "she", "ll", "ve", 
                       "s", "n","d", "m", "to", "🌟", "✮", "sirius", "SIRIUS", "Sirius",
                       "they", "them", "adam")) %>% 
  filter(!token %in% c("the", "a", "an", "of", "or", "adam", "mary",
                       "breq", "paul", "anna", "NEVERWHERE", "ANNA", "Anna", 
                       "luke", "and",  "he", "his", "her", "she", "ll", "ve", 
                       "s", "n","d", "m", "to", "🌟", "✮", "sirius", "SIRIUS", "Sirius",
                       "they", "them", "adam"))
title_words_data <- merge(title_words, filtered_ents, by="plotable_title")
filtered_revs <- title_words_data %>% 
  rowwise() %>% 
  filter(!token %in% title_words) %>% 
  filter(!lemma %in% title_words) %>% 
  filter(!token %in% title_words_lower) %>% 
  filter(!lemma %in% title_words_lower) %>% 
  select(!c(title_words, title_words_lower)) %>% 
  mutate(token = if_else(plotable_title == "MadShip" & tolower(token) == "mad" |
                           plotable_title == "MadShip" & tolower(token) == "ship",
                         "DEL!", token),
         lemma = if_else(plotable_title == "MadShip" & tolower(lemma) == "mad" |
                           plotable_title == "MadShip" & tolower(lemma) == "ship",
                         "DEL!", lemma)) %>% 
  filter(!token == "DEL!") %>% 
  filter(!lemma == "DEL!")


filtered_words <- filtered_revs %>% 
  select(c("lemma")) %>% 
  distinct()

#write.csv(filtered_revs, "Input_Data/cleaned_data.csv")

# # read handcurated stopword list
# stopwords_cur <- read_csv("stop_words_cur.txt", col_names = F)
# stopwords <- entities %>%
#  add_row(token = stopwords_cur$X1) %>% 
#   distinct()
# 
# write_csv(stopwords, "stopwords.csv")
# 
