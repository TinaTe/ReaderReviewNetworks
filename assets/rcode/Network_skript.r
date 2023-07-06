library(tidyverse)#
library(Matrix)
library(tidytext)
library(stringr) #
library(reshape2)
library(igraph) #
library(ggraph) #
library(networkD3)
#library(disparityfilter)
library(purrr)
#library(backbone) #
source("Code/GRutils.R")
library(quanteda) #
library(quanteda.textplots) 
library(quanteda.textstats)
library(viridis)
library(ggforce)
library(visNetwork)

cleaned_data <- read.csv("Input_Data/cleaned_data.csv") %>% 
  filter(token!="Drew") %>% 
  filter(token!="Ash") 

# Data basis after cleaning
corpus <- cleaned_data %>% 
  filter(genre !="Fantasy") %>% 
  ungroup() %>% 
  mutate(review = doc_id,
    doc_id = paste0(plotable_title, doc_id)) %>% 
  group_by(genre, plotable_title, review, doc_id) %>% 
  summarise(text = str_c(lemma, collapse = " "))

# use quanteda for new tokenization
corpus_obj <- corpus(corpus)
tokens <- tokens(corpus_obj, remove_punct = T, remove_numbers = T, remove_url = T, remove_symbols = T)
# tokens <- tokens_remove(tokens, c("the", "a", "an", "of", "or", "adam", "mary",
#                                   "breq", "paul", "anna", "NEVERWHERE", "ANNA", "Anna", 
#                                   "luke", "and",  "he", "his", "her", "she", "ll", "ve", 
#                                   "s", "n","d", "m", "to", "🌟", "✮", "sirius", "SIRIUS", "Sirius",
                                # "they", "them", "adam") )
tokens <- tokens_select(tokens, c("the", "a", "an", "of", "or", "adam", "mary",
                                  "breq", "paul", "anna", "NEVERWHERE", "ANNA", "Anna", 
                                  "luke", "and",  "he", "his", "her", "she", "ll", "ve", 
                                  "s", "n","d", "m", "to", "🌟", "✮", "sirius", "SIRIUS", "Sirius",
                                  "they", "them", "adam", "linqvist", "ancillary", "eve", "poseidon",
                                  "awn", "radch", "esk", "viral", "p.k.d", "snape"),
                        selection = "remove",
                        case_insensitive = T, verbose = T)
# get document feature matrix with tf-idf
dfm <- dfm(tokens, tolower = TRUE)
tf_idf <- dfm_tfidf(dfm, scheme_tf = "prop", scheme_df = "inverse")
#textplot_wordcloud(dfm, max_words = 100)
word_sim_matrix <- as.matrix(tf_idf)

head(sort(word_sim_matrix, decreasing = T))
## access similarity matrix by doc / token
#hi_va <- word_sim_matrix["1678365FourthMonkey",]
#hi_wo <- word_sim_matrix[, "breq"]
#head(sort(hi_wo, decreasing = T))
set.seed(2001)
sim <- textstat_simil(tf_idf, margin = "documents", method = "cosine") #cosine
alpha_thres <- .085
#louvain_cluster
#plot08 <- net_graph
#plot084 <- net_graph
#plot085 <- net_graph
#plot086 <- net_graph
#plot087 <- net_graph



##plot(hclust(as.dist(sim)))

sim_matrix <- as.matrix(sim)

text_network <- graph.adjacency(sim_matrix, mode="undirected", weighted = TRUE, diag = FALSE)
#plot(text_network)
#### adding genre info to network ---------
# get group id
group_id <- V(text_network)$name

# match genre info
V(text_network)$genre <- corpus$genre

# match title info
V(text_network)$title <- corpus$plotable_title

#match review nr
V(text_network)$review <- corpus$review

#"create" network backbone
## This code accesses the network backbone to make it possible to delete edges based on alpha

e <- cbind(igraph::as_data_frame(text_network)[, 1:2 ], weight = E(text_network)$weight)

# in
w_in <- graph.strength(text_network, mode = "in")
w_in <- data.frame(to = names(w_in), w_in, stringsAsFactors = FALSE)
k_in <- degree(text_network, mode = "in")
k_in <- data.frame(to = names(k_in), k_in, stringsAsFactors = FALSE)

e_in <- e %>%
  left_join(w_in, by = "to") %>%
  left_join(k_in, by = "to") %>%
  mutate(alpha_in = (1-(weight/w_in))^(k_in-1))

# out

w_out <- graph.strength(text_network, mode = "out")
w_out <- data.frame(from = names(w_out), w_out, stringsAsFactors = FALSE)
k_out <- degree(text_network, mode = "out")
k_out <- data.frame(from = names(k_out), k_out, stringsAsFactors = FALSE)

e_out <- e %>%
  left_join(w_out, by = "from") %>%
  left_join(k_out, by = "from") %>%
  mutate(alpha_out = (1-(weight/w_out))^(k_out-1))

e_full <- left_join(e_in, e_out, by = c("from", "to", "weight"))

e_full <- e_full %>%
  mutate(alpha = ifelse(alpha_in < alpha_out, alpha_in, alpha_out)) %>%
  select(from, to, alpha)

E(text_network)$alpha <- e_full$alpha

#### "Decluttering" the network with the tuning parameter alpha
## the default setting in textnets is .25 if network looks sparce, change to higher number

pruned <- delete.edges(text_network, which(E(text_network)$alpha >= alpha_thres))
pruned <- delete.vertices(pruned, which(degree(pruned) == 0))
#plot(pruned)
E(pruned)$weight
# make degree for labeling most popular nodes
V(pruned)$degree <- degree(pruned)

# remove isolates
isolates <- V(pruned)[degree(pruned)==0]
pruned <- delete.vertices(pruned, isolates)
#plot(pruned)
# calculate communities
set.seed(2001)
louvain_cluster <- cluster_louvain(pruned)
modularity(louvain_cluster)

# add community information to vertices
V(pruned)$community <- louvain_cluster$membership

#pruned <- delete.vertices(pruned, which(text_network$community %in% c(14, 5, 9,1, 12)))
# create new weights according to communitiy membership -> for nicer layout
#crossing returns a logical vector, with one value for each edge, ordered according to the 
#edge ids. The value is TRUE iff the edge connects two different communities, 
#according to the (best) membership vector, as returned by membership().
E(pruned)$louvain <- ifelse(crossing(louvain_cluster, pruned), 1, 100)

layout <- create_layout(pruned, weights = louvain, layout = "nicely")

# define modularity to color membership
#V(pruned)$modularity <- louvain$membership

#calculate betweenness for sizing nodes
## -> measure of influence or centrality; 
## the extent to which a given document or word is between clusters
#size <- 3 # if no betweenness wanted set to this
size <- betweenness(pruned)/100+3
size <- degree(pruned)+2
size <- closeness(pruned, mode = "all")
size<-size/100+3
#
size <- 3

# make visualization
## label_degree_cut specifies the degree or nr 
## of connections that nodes should have to get labeled
label_degree_cut <- 0
#cluster_louvain(pruned)
cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#CC79A7", "#009E73",
          "#F0E442", "#0072B2", "#D55E00")
cbp2 <- c("#E69F00", "#56B4E9", "#CC79A7", "#009E73",
          "#F0E442", "#0072B2", "#D55E00")

net_graph <- ggraph(layout = layout) +
  #stat_ellipse(aes(x,y, group = factor(pruned$community),# fill = factor(pruned$community),
               #     label = pruned$community), 
               # geom = "polygon", alpha = 0.3)+
  geom_mark_ellipse(aes(x,y, group = factor(V(pruned)$community),# fill = factor(V(pruned)$community),
                   label = V(pruned)$community),  alpha = 0.3)+
  #scale_color_viridis()+
  #geom_node_point(color = V(pruned)$modularity, size = size) +
  geom_node_point(size = size, aes(color = genre)) +
  scale_color_manual(values =  cbp2)+
  geom_edge_link(aes(edge_alpha = weight)
  )+#, show.legend = F)+
  #new_scale_colour() +
  #geom_polygon(aes(x = x, y = y, fill = factor(pruned$community)), alpha = 0.2, size = 1000, lineend = "round") + 
  #geom_path(aes(x = x, y = y, group = factor(pruned$community)), color = "black", size = 1)+
  geom_node_text(aes(label = name), 
                 repel = TRUE, size=3) +
  theme_void()
set.seed(2001)
biggest_com.g <- induced_subgraph(pruned, v = which(V(pruned)$community %in% c(1, 4, 7, 8, 9, 11, 12)))
sublayout  <- create_layout(biggest_com.g, weights = louvain, layout = "nicely")

per_cluster <- induced_subgraph(pruned, v = which(V(pruned)$community %in% c(4)))
most_important <- betweenness(per_cluster, directed = F)/3+3

ggraph(per_cluster)+ 
  geom_node_point(size = most_important, aes(color = genre))+
  scale_color_manual(values =  cbp2)+
  geom_edge_link(aes(edge_alpha = E(per_cluster)$weight)
  )+
  geom_node_text(aes(label = name), 
                 repel = TRUE, size=3) +
  theme_void()

size <- betweenness(biggest_com.g, directed = F)/100+3
size <- degree(biggest_com.g)
size <- closeness(biggest_com.g, mode = "all")*250
size<-size/100+3
#size <- 3

new_graph <- ggraph(layout = sublayout) +
  geom_mark_ellipse(aes(x,y, group = factor(V(biggest_com.g)$community), #fill = factor(V(biggest_com.g)$community),
                        label = V(biggest_com.g)$community),  alpha = 0.3)+
  #scale_color_viridis()+
  #geom_node_point(color = V(pruned)$modularity, size = size) +
  geom_node_point(size = size, aes(color = genre)) +
  scale_color_manual(values =  cbp2)+
  geom_edge_link(aes(edge_alpha = E(biggest_com.g)$weight)
  )+
  labs(edge_alpha = "weight")+ 
  #new_scale_colour() +
  #geom_polygon(aes(x = x, y = y, fill = factor(pruned$community)), alpha = 0.2, size = 1000, lineend = "round") + 
  #geom_path(aes(x = x, y = y, group = factor(pruned$community)), color = "black", size = 1)+
  geom_node_text(aes(label = name), 
                 repel = TRUE, size=3) +
  theme_void()

new_graph

# test <- pruned
# E(test)$weight <- louvain
# vis <-visIgraph(test)

#Convert to object suitable for networkD3
net_d3 <- igraph_to_networkD3(pruned, group = as.factor(V(pruned)$genre))

# Create force directed network plot
forceNetwork(Links = net_d3$links, Nodes = net_d3$nodes,
             Source = 'source', Target = 'target', NodeID = 'name',
             Group = 'group')# , Value = 'name')
ggraph(layout = sublayout) +
  #geom_node_point(color = V(pruned)$modularity, size = size) +
  geom_node_point(size = size, aes(color = genre)) +
  geom_edge_link(aes(edge_alpha = weight) , edge_color = 'gray34'
  )+#, show.legend = F)+
  geom_node_text(aes(label = name, filter=degree>label_degree_cut, color = genre),
                 repel = TRUE, size=3) +
  scale_color_manual( values =  cbp2)+
  theme_void()+
  theme(plot.background = element_rect(fill = "black"),
        text = element_text(color = 'white'), 
        plot.margin = margin(t = 0, r = 15, b = 15, l = 15, unit = "pt"))
  
