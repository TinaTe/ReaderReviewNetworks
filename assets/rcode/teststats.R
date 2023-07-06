library(tidyverse)
library(plotly)
library("writexl")
library(reactable)
library(reactablefmtr)
library(quanteda)



data <- read.csv("Output_Data/recurated_data_with_genre.csv", encoding = "UTF-8")


# exclude reviews with only AbsMention or Abs abs----------------------
data_filtered <- data %>%
  group_by(review) %>% 
  filter(any(mode == "Absorption" & presence == "Present")>0)


  


## Look at and filter specified genres-------------------
## Filter for relevant genres

# all genres present table-------------

all_genres <- data_filtered %>% 
  select(genre_1, title, SWAS_tag, review) %>% 
  group_by(genre_1) %>% 
  mutate(n_books = n_distinct(title),
         n_reviews = n_distinct(review),
         n_annotations = n()
        # ann_per_rev = round(n()/n_distinct(review), 1)
         ) %>% 
  select(!c(title, SWAS_tag, review)) %>% 
  distinct() %>% 
  # group_by(genre_1) %>% 
  # summarise(n_books = n()) %>% 
  reactable(defaultPageSize = 15,
            columns = list(
              genre_1 = colDef(name = "Genre"),
              n_books = colDef(name = "Books (n)"),
              n_reviews = colDef(name = "Reviews (n)"),
              n_annotations = colDef(name = "Annotations (n)")),
             # ann_per_rev = colDef(name = "Annotations per Review")),
            resizable = T,
            showSortIcon = F
  ) %>% 
  add_title("Overview: All genres")
# ----------------
data_genre <- data_filtered %>% 
  filter(genre_1 %in% c("Fantasy", "Romance", "Horror", "Thriller", 
                     "Mystery", "Science Fiction")) %>% 
  mutate(genre = if_else(genre_1 == "Thriller"|genre_1 == "Horror", 
                         paste0("Horror/ Thriller"), genre_1))


selected_genres <- data_genre %>% 
  select(genre, title, SWAS_tag, review) %>% 
  group_by(genre) %>% 
  mutate(n_books = n_distinct(title),
         n_reviews = n_distinct(review),
         n_annotations = n()) %>% 
  select(!c(title, SWAS_tag, review)) %>% 
  distinct() %>% 
  # group_by(genre_1) %>% 
  # summarise(n_books = n()) %>% 
  reactable(defaultPageSize = 15,
            columns = list(
              genre = colDef(name = "Genre"),
              n_books = colDef(name = "Books (n)"),
              n_reviews = colDef(name = "Reviews (n)"),
              n_annotations = colDef(name = "Annotations (n)")),
            resizable = T) %>% 
  add_title("Overview: Selected genres")

data %>% 
  filter(genre_1 %in% c("Horror", "Thriller")) %>% 
  ggplot(aes(SWAS_tag, fill = genre_1)) +
  geom_histogram(stat = "count")+
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))


# define subgenres for biggest categories
subgenres_fantasy <- c("Romance", "Horror", "Thriller",
                       "Mystery", "Science Fiction")
subgenres_romance <- c("Fantasy", "Horror", "Thriller", 
                       "Mystery", "Science Fiction")
subgenres_horror <- c("Fantasy", "Romance", 
                      "Mystery", "Science Fiction")
subgenres_mystery <- c("Fantasy", "Romance", "Horror", "Thriller", 
                       "Science Fiction")
subgenres_sciencefiction <- c("Fantasy", "Romance", "Horror", "Thriller", 
                              "Mystery")
# filter fantasy and romance for appearance of the other genres in g2 and g3
data_genre_filtered <- data_genre %>% 
  filter(! (genre == "Fantasy" & genre_2 %in% subgenres_fantasy)) %>% 
  filter(! (genre == "Fantasy" & genre_3 %in% subgenres_fantasy)) %>% 
  filter(! (genre == "Romance" & genre_2 %in% subgenres_romance)) %>% 
  filter(! (genre == "Romance" & genre_3 %in% subgenres_romance)) 
  # %>% 
  # filter(! (genre == "Horror/ Thriller" & genre_2 %in% subgenres_horror)) %>% 
  # filter(! (genre == "Horror/ Thriller" & genre_3 %in% subgenres_horror)) %>% 
  # filter(! (genre == "Mystery" & genre_2 %in% subgenres_mystery)) %>% 
  # filter(! (genre == "Mystery" & genre_3 %in% subgenres_mystery)) %>% 
  # filter(! (genre == "Science Fiction" & genre_2 %in% subgenres_sciencefiction)) %>% 
  # filter(! (genre == "Science Fiction" & genre_3 %in% subgenres_sciencefiction))


filtered_by_subgenres <- data_genre_filtered %>% 
  
  select(genre, title, SWAS_tag, review) %>% 
  group_by(genre) %>% 
  mutate(n_books = n_distinct(title),
         n_reviews = n_distinct(review),
         n_annotations = n()) %>% 
  select(!c(title, SWAS_tag, review)) %>% 
  distinct() %>% 
  # group_by(genre_1) %>% 
  # summarise(n_books = n()) %>% 
  reactable(defaultPageSize = 15,
            columns = list(
              genre = colDef(name = "Genre"),
              n_books = colDef(name = "Books (n)"),
              n_reviews = colDef(name = "Reviews (n)"),
              n_annotations = colDef(name = "Annotations (n)")),
            resizable = T) %>% 
  add_title("Filtered by subgenres")



# add plotable titles
data_5_genres <- data_genre_filtered %>% 
  mutate(plotable_title = str_remove(title, "^The_|^A_|^the_|^a_")) %>% 
  mutate(plotable_title = stringr::str_to_title(plotable_title),
         plotable_title = gsub("(_\\w)","\\U\\1",plotable_title,perl=TRUE),
         plotable_title = str_remove_all(plotable_title, "_"),
         plotable_title = stringr::str_trunc(plotable_title, 14, ellipsis = ""))

corpus <- data_5_genres %>% 
  group_by(review) %>% 
  mutate(
    nr_ann = n()
  ) %>% 
  select(genre, title, review, full_review, nr_ann) %>% 
  distinct()

corpus.q <- corpus(
  corpus,
  text_field = "full_review",
  docid_field = "review",
  meta = c("genre", "title", "nr_ann")
)
tokeninfo <- summary(corpus.q, n = 199)

Overview_Corpora <- tokeninfo %>% 
  group_by(genre) %>% 
  summarize(sum_tokens = sum(Tokens),
            mean_tokens = round(mean(Tokens), 2),
            median_tokens = median(Tokens),
            min = min(Tokens),
            max = max(Tokens),
            nrevs = n()
            # n_ann = sum(nr_ann)
            ) %>% 
  reactable(
    columns = list(
      genre = colDef(name = "Genre"),
      mean_tokens = colDef("Tokens (mean)"),
      median_tokens = colDef("Tokens (median)"),
      sum_tokens = colDef("Tokens (n)"),
      min = colDef("Tokens (min)"),
      max = colDef("Tokens (max)"),
      # n_ann = colDef("Annotations (n)"),
      nrevs = colDef("Reviews (n)")
      ),
    resizable = T) %>% 
  add_title("Tokeninfo Genre Corpora")

cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#CC79A7", "#009E73",
                   "#F0E442", "#0072B2", "#D55E00")


# look for dispersion annotations per book
tags_per_book <- data_5_genres %>%
  ggplot(aes(plotable_title, fill = genre))+
  geom_histogram(stat = "count")+
  scale_fill_manual(values = cbp1)+
  facet_wrap(~ genre, scales = "free_x") +
  ggtitle("Annotations per Title") +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5),
        plot.margin = unit(c(0.5, 3, 3, 3), "cm"))
  
ggplotly(tags_per_book)



# look for dispersion reviews per book
reviews_per_title <- data_5_genres %>% 
  select(genre, plotable_title, review) %>% 
  distinct()
reviews_per_book <- ggplot(reviews_per_title, aes(plotable_title, fill = genre))+
  scale_fill_manual(values = cbp1)+
  geom_histogram(stat = "count")+
  ggtitle("Reviews per Title") +
  facet_wrap(~ genre, scales = "free_x") +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.6),
        plot.margin = unit(c(0.5, 3, 3, 3), "cm")) 
ggplotly(reviews_per_book)

fantasy_exclusion <- reviews_per_title %>% 
  filter(genre == "Fantasy") %>% 
  group_by(plotable_title) %>% 
  filter(n()==5) 

## Annotations per genre

annotations_per_genre <- data_5_genres %>% 
  ggplot(aes(genre, fill = genre))+
  scale_fill_manual(values = cbp1)+
  geom_histogram(stat = "count")+
  ggtitle("Annotations per Genre")+
  theme(axis.text.x = element_text(angle = 45))

ggplotly(annotations_per_genre)

## which categories are there in each genre
percentages_cat <- data_5_genres %>% 
  #filter(presence == "Present") %>% 
  #filter(mode == "AbsorptionMention") %>% 
  #filter(SWAS_tag != "IM3 Anticipation_BookSeries") %>% 
  group_by(genre, SWAS_category) %>% 
  summarise(n = n()) %>% 
  mutate(freq = n / sum(n),
         sum_n = sum(n)) %>% 
  ggplot(aes(SWAS_category, freq, fill = genre))+
  scale_fill_manual(values = cbp1)+
  geom_col(position = "dodge")+
  ggtitle("SWAS-Dimensions in different Genres")+
  theme(plot.margin = unit(c(0.5, 3, 3, 3), "cm"))
  #theme(axis.text.x = element_text(angle = 45))
ggplotly(percentages_cat)
## absence!!!!!!!!!!!

percentages_tag <- data_5_genres %>% 
  #filter(presence == "Present") %>% 
  mutate(SWAS_tag = gsub("_", "\n", SWAS_tag)) %>% 
  mutate(SWAS_tag = gsub(" ", "\n", SWAS_tag)) %>% 
 # filter(SWAS_category == "Attention") %>% 
  group_by(genre, SWAS_tag) %>% 
  summarise(n = n()) %>% 
  mutate(freq = n / sum(n)) %>% 
 filter(grepl("([S])\\d", SWAS_tag)) %>% 
  ggplot(aes(SWAS_tag, freq, fill = genre))+
  #facet_wrap(~genre)+
  scale_fill_manual(values = cbp1)+
  geom_col(position = "dodge")+
  ggtitle("Mental Imagery")+
  theme(plot.margin = unit(c(0.5, 3, 3, 3), "cm")) #+
  #theme(axis.text.x = element_text(angle = 45))

ggplotly(percentages_tag)

categories_per_genre <- data_5_genres %>% 
  ggplot(aes(SWAS_category, fill = genre))+
  scale_fill_manual(values = cbp1)+
  geom_histogram(stat = "count", position = "dodge")+
#  facet_wrap(vars(genre))+
  ggtitle("Categories per Genre")#+
  #theme(axis.text.x = element_text(angle = 45))

categories_per_genre <- data_5_genres %>% 
  ggplot(aes(SWAS_category, fill = genre))+
  scale_fill_manual(values = cbp1)+
  geom_histogram(stat = "count", position = "dodge")+
  #facet_wrap(vars(genre))+
  ggtitle("Categories per Genre")
 # theme(axis.text.x = element_text(angle = 45))

ggplotly(categories_per_genre)


subcat_per_genre <- data_5_genres %>% 
  #mutate(SWAS_tag = gsub("_", "\n", SWAS_tag)) %>% 
  #mutate(SWAS_tag = gsub(" ", "\n", SWAS_tag)) %>% 
  mutate(n_all = n()) %>% 
  group_by(SWAS_tag) %>% 
  mutate(n_tag = n()) %>% 
  ungroup() %>% 
  group_by(genre, SWAS_tag) %>% 
  mutate(n_tags = n(), 
         freq = n() / n_tag) %>% 
  ggplot(aes(SWAS_tag, freq, fill = genre))+
  scale_fill_manual(values = cbp1)+
  geom_col(position = "dodge")+
  #facet_wrap(vars(SWAS_category), scales = "free")+
  ggtitle("Subcategories per Genre")+
  theme(axis.text.x = element_text(angle = 45))
ggplotly(subcat_per_genre)

romance_genres <- data_5_genres %>% filter(genre == "Romance") %>% 
  ggplot(aes(genre_3)) +
  geom_histogram(stat = "count")
ggplotly(romance_genres)

#save data 
#data_5_genres %>% write_csv("Input_Data/data_5_genres")

# save network data
#data_5_genres_1 %>% write.csv("network_data.csv")

# data_stats <- data_filtered %>% 
#   group_by(mode, main, tag, presence) %>% 
#   summarise(n_tag_pres = n()) %>% 
#   group_by(mode,main,tag) %>% 
#   mutate(n_tag = sum(n_tag_pres)) %>% 
#   ungroup %>% 
#   group_by(mode, main) %>% 
#   mutate(n_main = sum(n_tag)) %>% 
#   ungroup() %>% 
#   group_by(mode) %>% 
#   mutate(n_mode = sum(n_main)) %>% 
#   select(c(mode, n_mode, main, n_main, tag, n_tag, presence, n_tag_pres))
# 
# genre_stats_1 <- data_filtered %>% 
#   group_by(genre_1, mode, main, tag, presence) %>% 
#   summarise(n_tag_pres = n()) %>% 
#   group_by(genre_1, mode,main,tag) %>% 
#   mutate(n_tag = sum(n_tag_pres)) %>% 
#   ungroup %>% 
#   group_by(genre_1, mode, main) %>% 
#   mutate(n_main = sum(n_tag)) %>% 
#   ungroup() %>% 
#   group_by(genre_1, mode) %>% 
#   mutate(n_mode = sum(n_main)) %>% 
#   ungroup() %>% 
#   group_by(genre_1) %>% 
#   mutate(n_genre = sum(n_mode)) %>% 
#   select(c(genre_1, n_genre, mode, n_mode, main, n_main, tag, n_tag, presence, n_tag_pres))
# 
# genre_stats_2 <- data_filtered %>% 
#   group_by(genre_2, mode, main, tag, presence) %>% 
#   summarise(n_tag_pres = n()) %>% 
#   group_by(genre_2, mode,main,tag) %>% 
#   mutate(n_tag = sum(n_tag_pres)) %>% 
#   ungroup %>% 
#   group_by(genre_2, mode, main) %>% 
#   mutate(n_main = sum(n_tag)) %>% 
#   ungroup() %>% 
#   group_by(genre_2, mode) %>% 
#   mutate(n_mode = sum(n_main)) %>% 
#   ungroup() %>% 
#   group_by(genre_2) %>% 
#   mutate(n_genre = sum(n_mode)) %>% 
#   select(c(genre_2, n_genre, mode, n_mode, main, n_main, tag, n_tag, presence, n_tag_pres))
# 
# genre_stats_3 <- data_filtered %>% 
#   group_by(genre_3, mode, main, tag, presence) %>% 
#   summarise(n_tag_pres = n()) %>% 
#   group_by(genre_3, mode,main,tag) %>% 
#   mutate(n_tag = sum(n_tag_pres)) %>% 
#   ungroup %>% 
#   group_by(genre_3, mode, main) %>% 
#   mutate(n_main = sum(n_tag)) %>% 
#   
#   ungroup() %>% 
#   group_by(genre_3, mode) %>% 
#   mutate(n_mode = sum(n_main)) %>% 
#   ungroup() %>% 
#   group_by(genre_3) %>% 
#   mutate(n_genre = sum(n_mode)) %>% 
#   select(c(genre_3, n_genre, mode, n_mode, main, n_main, tag, n_tag, presence, n_tag_pres))
# 
# genre_1_n <- genre_stats_1 %>% 
#   select(genre_1, n_genre) %>% 
#   unique() %>% 
#   ungroup() %>% 
#   mutate(ID = row_number())
# 
# genre_2_n <- genre_stats_2 %>% 
#   select(genre_2, n_genre) %>% 
#   unique() %>%
#   ungroup() %>%
#   mutate(ID = row_number())
# 
# genre_3_n <- genre_stats_3 %>% 
#   select(genre_3, n_genre) %>% 
#   unique() %>% 
#   ungroup() %>%
#   mutate(ID = row_number())
# genre_n <- left_join(genre_3_n, genre_2_n, by = "ID") %>% 
#   left_join(genre_1_n, by = "ID")
# 
# entries_genre_1 <- data_filtered %>% 
#   group_by(genre_1) %>% 
#   summarise(n = n()) %>% 
#   mutate(genre = genre_1) %>% 
#   select(c(genre,n))
# entries_genre_2 <- data_filtered %>% 
#   group_by(genre_2) %>% 
#   summarise(n = n()) %>% 
#   mutate(genre = genre_2) %>% 
#   select(c(genre,n))
# entries_genre_3 <- data_filtered %>% 
#   group_by(genre_3) %>% 
#   summarise(n = n()) %>% 
#   mutate(genre = genre_3) %>% 
#   select(c(genre,n))
# 
# entries_genre <- bind_rows(entries_genre_1, entries_genre_2, entries_genre_3) %>% 
#   group_by(genre) %>% 
#   summarise(n_tries = sum(n))
# 
# data_filtered %>% 
#   ggplot()
# 
# 
# unique(data_org$genre_3)
