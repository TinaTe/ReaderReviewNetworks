source("Code/GRutils.R")
#read annotation
data <- read_all("Input_Data", dir_pattern = "recurated")
data_Swas <- convertSWAS(data)
#read full reviews
review_txts <- read_rev_txts("Input_Data/review_txts")

genre_data <- read_csv("Output_Data/Genre/data-with-genre-full.csv") %>% 
  select(c("link", "genre_1", "genre_2", "genre_3", "votes_1", "votes_2", "votes_3")) %>% 
  unique()

## merge genre with annotation data
data_SwasGenre <- merge(data_Swas, genre_data, by="link")

## merge with full reviews
full_data_abs <- left_join(data_SwasGenre, review_txts)

## filter full reviews for already merged data
nonAnnRevs <- review_txts %>% 
  filter(!review %in% full_data_abs$review)

## add non annotated full reviews to data
full_data <- bind_rows(full_data_abs, nonAnnRevs) %>% 
  group_by(title) %>% 
  # fill up genre information (if there) for non annotated reviews
  fill(c(genre_1, genre_2, genre_3, votes_1, votes_2, votes_3), .direction = "downup")

doubleTable_onset <- full_data %>% 
  group_by(review, onset, SWAS_tag) %>% 
  filter(n()>1) %>% 
  mutate(comment = "double")

doubleTable_offset <- full_data %>% 
  group_by(review, offset, SWAS_tag) %>% 
  filter(n()>1) %>% 
  ungroup() %>% 
  group_by(review, onset, SWAS_tag) %>% 
  filter(n()==1) %>% 
  mutate(comment = "double")

doubleTable_length <- full_data %>% 
  group_by(review, offset, SWAS_tag) %>% 
  filter(n()==1) %>% 
  ungroup() %>% 
  group_by(review, onset, SWAS_tag) %>% 
  filter(n()==1) %>% 
  ungroup() %>% 
  group_by(review, SWAS_tag) %>% 
  filter(n()>1) %>% 
  ungroup() %>% 
  mutate(diffTag = 1:n()) %>% 
  mutate(
    double = ifelse((SWAS_tag != lead(SWAS_tag)), diffTag, NA)
  ) %>%
  fill(double, .direction = "up")  %>% 
  mutate(
    double = ifelse((is.na(double)), 0, double)
  ) %>% 
  group_by(review, double) %>% 
  filter(n()>1) %>% 
  mutate(
    doubletrouble = ifelse(lead(as.integer(onset), default = 2000000)<as.integer(offset), NA, diffTag)
  ) %>% 
  fill(doubletrouble, .direction = "up") %>% 
  group_by(doubletrouble) %>% 
  filter(n()>1) %>% 
  ungroup() %>% 
  select(-c(diffTag, double, doubletrouble)) %>% 
  mutate(comment = "double")

doubles <- full_join(doubleTable_onset, doubleTable_offset) %>% 
  full_join(doubleTable_length)

no_doubles <- anti_join(full_data, doubles, by = "statement")
  
write_csv(no_doubles, "Output_Data/recurated_data_with_genre.csv")
write_xlsx(full_data, "Output_Data/Full_Data.xlsx")  
