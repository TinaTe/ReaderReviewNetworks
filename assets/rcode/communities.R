library(knitr)
library(reactable)
library(reactablefmtr)
library(plotly)
library(ggalluvial)
library(Polychrome)
library(quanteda)
library(quanteda.textplots) 
library(ggplot2)
#data_5_genres <- read.csv("Input_Data/data_5_genres")

dfm_trimabs <- function(x, min) {
  maxvals <- sapply(
    split(community_1_sub@x, featnames(community_1_sub)[as(x, "dgTMatrix")@j + 1]),
    max
  )
  dfm_keep(x, names(maxvals)[maxvals > min])
}

communities <- data.frame() 
 for (c in unique(V(pruned)$community)) {
#for (c in c(1:13)) { #c(1:4,6)) {
  subgraph <- induced_subgraph(pruned, v = which(V(pruned)$community == c))
  communities <- communities %>% 
    bind_rows(tibble(
      community = c,
      genre = V(subgraph)$genre,
      doc_id = V(subgraph)$name,
      plotable_title = V(subgraph)$title,
      review = V(subgraph)$review
    ))
}


data_communities <- merge(communities, data_5_genres, by = c("review", "genre")) 
#data_com_tags <- merge(data_communities, data_net)
data_communities <- data_communities %>% 
  mutate(names = ifelse(community == 1, "01_Science_Fiction", NA),
         names = ifelse(community == 2, "02_Romance_S", names),
         names = ifelse(community == 3, "03_Outlier", names),
         names = ifelse(community == 4, "04_Mystery", names),
         names = ifelse(community == 5, "05_4thMonkey", names),
         names = ifelse(community == 6, "06_Outlier2", names),
         names = ifelse(community == 7, "07_Horror/Thriller", names),
         names = ifelse(community == 8, "08_Horror/Thriller/SciFi", names),
         names = ifelse(community == 9, "09_Mix", names),
         names = ifelse(community == 10, "10_Outlier3", names),
         names = ifelse(community == 11, "11_Romance1", names),
         names = ifelse(community == 12, "12_Romance2", names),
         names = ifelse(community == 13, "13_Outlier4", names)
  )



full_revs_comm <- communities %>% 
  select(community, review) %>% 
  merge(., data_5_genres, by = "review") %>% 
  select(community, genre, review, full_review, title) %>% 
  distinct() %>% 
  group_by(community) %>% 
  mutate(n_community = n()) %>% 
  arrange(desc(n_community))


genres <- communities %>% 
  group_by(community) %>% 
  summarise(
    nrevs = n(),
  #  Fantasy = sum(genre=="Fantasy")/n(),
    HorrorThriller = sum(genre=="Horror/ Thriller")/n(),
    Mystery = sum(genre=="Mystery")/n(),
    Romance = sum(genre=="Romance")/n(),
    ScienceFiction = sum(genre=="Science Fiction")/n()
  ) %>% 
  mutate(across(3:6, round, 3)) %>% #without Fantasy
  #mutate(across(3:7, round, 3)) %>% #with Fantasy
  arrange(desc(nrevs))

genre.t <- genres %>% 
  reactable(
    defaultPageSize = 4,
  columns = list(
    community = colDef("Cluster"),
    nrevs = colDef("Reviews (n)"),
    #Fantasy = colDef("Fantasy"),
    HorrorThriller = colDef("Horror/ Thriller"),
    Mystery = colDef("Mystery"),
    Romance = colDef("Romance"),
    ScienceFiction = colDef("Science Fiction"))
  #showSortable = T,
  #showPageSizeOptions = T
  ) %>% 
  add_title("Genre distribution in Clusters")

# tites.t <- communities %>% 
#   select(c(community, genre, plotable_title)) %>% 
#   filter(community == 4) %>% 
#   distinct() %>% 
#   reactable(
#     defaultPageSize = 15
#     ) %>% 
#   add_title("Books in Fantasy Cluster")

genres_density <- communities %>% 
  mutate(
    n_horror = sum(genre=="Horror/ Thriller"),
    nMystery = sum(genre=="Mystery"),
    nRomance = sum(genre=="Romance"),
    nScienceFiction = sum(genre=="Science Fiction")
  ) %>% 
  group_by(community) %>% 
  summarise(
    #  Fantasy = sum(genre=="Fantasy")/n(),
    nrevs = n(),
    HorrorThriller = sum(genre=="Horror/ Thriller")/n_horror,
    #horror = sum(genre=="Horror/ Thriller"),
    Mystery = sum(genre=="Mystery")/nMystery,
    Romance = sum(genre=="Romance")/nRomance,
    ScienceFiction = sum(genre=="Science Fiction")/nScienceFiction
  ) %>% 
  mutate(across(1:5, round, 3)) %>% #without Fantasy
  #mutate(across(3:7, round, 3)) %>% #with Fantasy
  arrange(desc(nrevs)) %>% 
  distinct()

genre_dens.t <- genres_density %>% 
  reactable(
    defaultPageSize = 4,
    columns = list(
      community = colDef("Cluster"),
      nrevs = colDef("Reviews (n)"),
      #Fantasy = colDef("Fantasy"),
      HorrorThriller = colDef("Horror/ Thriller"),
      Mystery = colDef("Mystery"),
      Romance = colDef("Romance"),
      ScienceFiction = colDef("Science Fiction"))
    #showSortable = T,
    #showPageSizeOptions = T
  ) %>% 
  add_title("Percentage of Genre Representation in Clusters")

docvar_coms <- communities %>% 
  select(doc_id, community)

new_corpus = merge(docvar_coms, corpus)

# use quanteda for new tokenization
new_corpus_obj <- corpus(new_corpus)
new_tokens <- tokens(new_corpus_obj, remove_punct = T, remove_numbers = T, remove_url = T, remove_symbols = T)
new_tokens <- tokens_select(new_tokens, c("the", "a", "an", "of", "or", "adam", "mary",
                                    "breq", "paul", "anna", "NEVERWHERE", "ANNA", "Anna", 
                                    "luke", "and",  "he", "his", "her", "she", "ll", "ve", 
                                    "s", "n","d", "m", "to", "🌟", "✮", "sirius", "SIRIUS", "Sirius",
                                    "they", "them", "adam", "linqvist", "ancillary", "eve", "poseidon",
                                    "awn", "radch", "esk", "viral", "p.k.d", "snape","ash"),
                          selection = "remove",
                          case_insensitive = T, verbose = T)
new_tokens <- tokens_select(new_tokens, "Drew",
                        selection = "remove",
                        case_insensitive = F, verbose = T)
new_tokens <- tokens_select(new_tokens, c("ash"),
                        selection = "remove",
                        case_insensitive = T, verbose = T)

# get document feature matrix with tf-idf
new_dfm <- dfm(new_tokens, tolower = TRUE)
new_tf_idf <- dfm_tfidf(new_dfm)

community_1_sub <- dfm_subset(new_tf_idf, community == 2)
community_1_sub_trim <- dfm_trimabs(community_1_sub, 0)
commonwords <- topfeatures(new_tf_idf, n = 13, groups = community)
#write_lines(commonwords, "Output_Data/commonwords.csv")


#is_1 <- docvars(new_dfm)$genre == "Horror/ Thriller" c(1,4,7,8,11,12)
is_1 <- docvars(new_dfm)$community == 12

#ref <- docvars(new_dfm)$genre == "Fantasy"
#ts <- textstat_keyness(ref, is_1)
ts <- textstat_keyness(new_dfm, is_1, measure = "lr")
head(ts$feature, 30)    ## view first 20 results

key <- textplot_keyness(ts)+
  ggtitle("Keyness Romance Cluster (12)")
key

fulltext_corpus <- data_communities %>% 
  select(doc_id, community, full_review) %>% 
  rename(text = full_review) %>% 
  distinct()
fulltext_corpus.obj <- corpus(fulltext_corpus)
tokens_full <- tokens(fulltext_corpus.obj)
tokens_sub <- tokens_subset(tokens_full, community == 07, drop_docid = F)

kw_immig <- kwic(tokens_sub, pattern =  "world*", window = 10)

head(kw_immig, 10)
word_sim_df <- as.data.frame(word_sim_matrix) %>% 
  rownames_to_column(var = "review_title")
com_word_sim_df <- merge(communities, word_sim_df, by = "review_title") %>% 
  mutate(review.x = as.character(review.x)) %>% 
  filter(community.x == 1) %>% 
  select(where(~ any(. != 0)))
community_1_words <- word_sim_matrix[rownames(word_sim_matrix) %in% community_1,
                                     colSums(word_sim_matrix)>0]
colMeans(word_sim_matrix)>0



betweenness.sub <- as_tibble(betweenness(biggest_com.g), rownames = "doc_id") %>% 
  rename(betweenness = value)
  
betweenness.sub <- merge(data_communities, betweenness.sub, by = "doc_id")
betweenness.sub <- betweenness.sub %>% 
  select(doc_id, review, genre, community, betweenness, full_review) %>% 
  distinct()

annotations_per_cluster <- data_communities %>% 
  group_by(names) %>% 
  
  filter(community %in% c(1,4,7,8,11,12)) %>%
  ggplot(aes(names)) +
  geom_histogram()

## which categories are there in each genre
categories_per_community <- data_communities %>% 
  filter(community %in% c(1,4,7,8,11,12)) %>% # c(11, 12, 8,7, 4)) %>% #
  ggplot(aes(SWAS_category, fill = genre))+
  scale_fill_manual(values = cbp2)+
  geom_histogram(stat = "count", position = "stack")+
  facet_wrap(vars(names))+
  ggtitle("Categories per Community")+
  theme(axis.text.x = element_text(angle = 45))
ggplotly(categories_per_community)
colorBlindBlack8  <- c("#D55E00", "#0072B2", "#009E73", 
                       "#E69F00", "#56B4E9", "#F0E442", "#CC79A7")
tags_per_community <- data_communities %>% 
  filter(community %in% c(1,4,7,8,11,12)) %>% # c(11, 12, 8,7, 4)) %>% #
  #filter(community %in% c(11, 12, 8,7, 4)) %>%#c(1 : 4, 6)) %>% 
  ggplot(aes(SWAS_tag, fill = factor(genre)))+
  geom_histogram(stat = "count")+#, position = "dodge")+
  scale_fill_manual(values = cbp2)+
  facet_wrap(vars(names))+
  ggtitle("Tags per Community")+
  theme(axis.text.x = element_text(angle = 45))
test <-   ggplotly(tags_per_community)
saveWidget(as_widget(test), "C:/Users/User/Documents/GitHub/jubilant-octo-doodle/tags_per_cluster.html")  

cbp2 <- c("#E69F00", "#009E73", "#999999",  "#56B4E9", "#CC79A7",
                 "#F0E442", "#0072B2", "#D55E00")


tags_per_community_freq <- data_communities %>% 
  #filter(!community %in% c(3,13)) %>% 
  #filter(community %in% c(11, 12, 8,7, 4)) %>%# c(1 : 4, 6)) %>%
  #filter(SWAS_tag != "IM3 Anticipation_BookSeries") %>% 
  group_by(names, SWAS_category) %>% 
  summarise(n = n()) %>% 
  mutate(freq = n / sum(n)) %>% 
  # mutate(n_all = n()) %>% 
  # group_by(SWAS_tag) %>% 
  # mutate(n_tag = n()) %>% 
  # ungroup() %>% 
  # #filter(genre == "Fantasy") %>% 
  # group_by(community, SWAS_tag) %>% 
  # mutate(n_tags = n(), 
  #        freq = n() / n_all) %>% 
  #filter(grepl("([EE])\\d", SWAS_tag)) %>% 
  ggplot(aes(SWAS_category, freq, fill = factor(names)))+
  scale_fill_manual(values = P36)+
  geom_col(position = "dodge")+
  #facet_wrap(vars(community))+
  theme(axis.text.x = element_text(angle = 45))+
  ggtitle("SWAS-Dimensions in different Clusters")
ggplotly(tags_per_community_freq) 

# data_communities <- data_communities %>% 
#   mutate(names = ifelse(community == 1, "Romance_Cluster", NA),
#          names = ifelse(community == 2, "Mix", names),
#          names = ifelse(community == 3, "Mystery", names),
#          names = ifelse(community == 4, "Fantasy/H/SF", names),
#          names = ifelse(community == 6, "Fantasy/SF", names),
#   )

alluvium <- data_communities %>% 
  filter(community %in% c(11, 12, 8,7, 4, 1)) %>%#c(1 : 4, 6)) %>% 
  # filter(genre == "Fantasy") %>% 
 filter(genre == "Mystery") %>% #"Science Fiction"  "Horror/ Thriller" "Mystery" "Romance"   
ggplot(aes(v = factor(SWAS_category), axis2 = SWAS_tag, axis3 = names)) +
  geom_flow(aes(fill = factor(SWAS_category)), show.legend = T, aes.bind=T) +
  labs(fill = "SWAS Dimension")+ 
  geom_stratum()+
  ggrepel::geom_text_repel(aes(label = ifelse(after_stat(x) == 1, as.character(after_stat(stratum)), NA) ),
    stat = "stratum",
                           size = 5, direction = "y", nudge_x = -.4
  ) +
  ggrepel::geom_text_repel(aes(label = ifelse(after_stat(x) == 2, as.character(after_stat(stratum)), NA) ),
                           stat = "stratum",
                           size = 5, direction = "y", nudge_x = 0) +
  scale_fill_manual(values = P36)+
  theme(panel.background = element_rect(fill = "white", colour="white"), legend.text = element_text(size = 13))
#  facet_wrap(~genre, scales = "free")
alluvium

data_communities %>% filter(community %in% c(11, 12, 8,7, 4, 1)) %>% 
  filter(grepl("([EE])\\d", SWAS_tag)) %>% 
  #filter(genre == "Science Fiction") %>% 
  #ggplot(aes(axis1 = genre, axis2 = SWAS_tag, axis3 = factor(community))) +
  ggplot(aes(v = factor(SWAS_tag), axis2 =genre, axis3 = names)) +
  geom_flow(aes(fill = factor(SWAS_tag)), show.legend = T, aes.bind = T) +
  geom_stratum()+
  scale_fill_manual(values = P36)+
  facet_wrap(~genre, scales = "free")+
  geom_label(stat = "stratum", aes(label = after_stat(stratum)))

data_communities %>% filter(community %in% c(11, 12, 8,7, 4, 1) ) %>% 
ggplot(aes(axis1 = genre, axis2 = SWAS_tag, axis3 = factor(community))) +
#ggplot(aes(v = SWAS_tag, axis1 = genre, axis3 = factor(community))) +
  geom_alluvium(aes(fill = SWAS_category), show.legend = T) +
  geom_stratum()+
  scale_fill_manual(values = P36)+
  geom_label(stat = "stratum", aes(label = after_stat(stratum)))

data_communities %>% filter(community %in% c(1 : 4, 6) & genre == "Fantasy") %>% 
  ggplot(aes(axis2 = SWAS_tag, axis3 = genre, axis1 = factor(community))) +
  #ggplot(aes(v = SWAS_tag, axis1 = genre, axis3 = factor(community))) +
  geom_alluvium(aes(fill = SWAS_tag), show.legend = F, cement.alluvia = T) +
  geom_stratum()+
  scale_fill_manual(values = P36)+
  geom_label(stat = "stratum", aes(label = after_stat(stratum))) 


P36 <- c("#FBB926", "#CA2A0D", "#8CCE22", "#582EA8", "#16A3FB",
         "#1C00F7", "#FC001C", "#FB0DDF", "#00FCF3", "#F4E50D","#22FB22", 
         "#F08216", "#2A5381", "#32731C", "#FBC9CC", "#D58FFF", "#842268", "#9C7500", 
         "#C1E2FF", "#1CEA99", "#55473B", "#D9E9A7", "#D10DFF",
          "#CC6C6A", "#26867F", "#FE85E0", "#CA2A0D", "#A2ABF4", "#B68EBF",
         "#16D5FD",  "#ABEFD6","#FE22B5" ,"#A2ABF4", "#B20DB3", "#FF2277"  
         )
# swatch(P36)
# 
# 
# chi <- data_communities %>% 
#   select(community, SWAS_tag, statement, review) %>% 
#   filter(community %in% c(1:4, 6)) %>% 
#   pivot_wider(names_from = community, values_from = SWAS_tag, values_fill = NA) 
# chi <- chi %>% 
#   select(!c(statement, review))
# 
# chisq.test(chi)

#  for (i in unique(pruned$community)) { 
#   # create subgraphs for each community 
#   subgraph <- induced_subgraph(pruned, v = which(pruned$community == i)) 
#   # get size of each subgraph 
#   size <- igraph::gorder(subgraph) 
#   # get betweenness centrality 
#   btwn <- igraph::betweenness(subgraph) 
#   communities <- communities %>% 
#     dplyr::bind_rows(data.frame(
#       community = i, 
#       n_titles = size, 
#       most_important = names(which(btwn == max(btwn))) 
#     ) 
#     ) 
# } 
# knitr::kable(
#   communities %>% 
#     dplyr::select(community, n_titles, most_important)
# )
# 
# 
# 
# top_five <- data.frame() 
# for (i in unique(pruned$community)) { 
#   # create subgraphs for each community 
#   subgraph <- induced_subgraph(pruned, v =  which(pruned$community == i)) 
#   # for larger communities 
#   if (igraph::gorder(subgraph) > 20) { 
#     # get degree 
#     degree <- igraph::degree(subgraph) 
#     # get top five degrees 
#     top <- names(head(sort(degree, decreasing = TRUE), 5)) 
#     result <- data.frame(community = i, rank = 1:5, character = top) 
#   } else { 
#     result <- data.frame(community = NULL, rank = NULL, character = NULL) 
#   } 
#   top_five <- top_five %>% 
#     dplyr::bind_rows(result) 
# } 
# knitr::kable(
#   top_five %>% 
#     tidyr::pivot_wider(names_from = rank, values_from = character) 
# )
# 
# 
