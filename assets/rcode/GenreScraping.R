source("GRutils.R")
library(rvest)
library(tidyverse)
library(polite)
#library(RSelenium)


review_data_ex <- read_dir(PATH_EX)
review_data_all <- read_all(PATH_ALL)

# url <- "https://www.goodreads.com/book/show/29991718.royally-matched"
# shell('docker run -d -p 4445:4444 selenium/standalone-firefox')
# remDr <- remoteDriver(port = 4445L, browserName = "firefox")
# remDr$open()
# remDr$navigate(url)
# page_Content <- remDr$getPageSource()[[1]]
# read_html(page_Content) %>% html_elements(".bookPageGenreLink") %>% html_text()
# 
# 
# session <- bow("https://www.goodreads.com/book/show/175983.Memories_of_Ice",
#                delay = 5)
# ölkj <- paste0("https://www.goodreads.com/book/show/",link)
# 

# scrape_genre <- function(link) {
#   genres_html <- character(0)
#   url <- paste0("https://www.goodreads.com/book/show/",link)
#   host <- url
#   try <- 0
#   while (identical(genres_html, character(0))) {
#     try <- try+1
#     print(paste0(try, ": ", link))
#     session <- bow(host,
#                    delay = 5)
#     genres_html <- scrape(session) %>%
#       html_elements(".bookPageGenreLink") %>% 
#       html_text()
#   }
#   print("scraping success!!")
#   data <- data.frame(genres_html)
#   dataSplit <- data %>% 
#     mutate(
#       genres = ifelse((grepl("\\d", lead(genres))|grepl("\\d", genres)), 
#                       genres, paste0(genres, ": ", lead(genres))),
#       genres = ifelse(grepl(":", lag(genres)), "del", genres)) %>% 
#     subset(genres != "del") %>% 
#       mutate(
#         modulo = ifelse((row_number() %% 2)==1, "genre", "votes")
#         ) %>% 
#     pivot_wider(names_from = modulo, values_from = genres) %>% 
#     unnest(c(genre, votes)) %>%
#     mutate(
#       votes = ifelse(grepl(",", votes),
#                      str_remove(votes, ",") %>% str_extract("\\d+"),
#                      str_extract_all(votes, "\\d+")),
#       votes = as.integer(votes),
#       newCol1 = paste0(row_number())
#     ) %>%
#     slice(1:3) %>%
#     pivot_wider(names_from = newCol1, values_from = c(genre, votes)) %>%
#     mutate(
#       link = link) #str_split(url, "/")[[1]][[6]])
# }
review_data <- review_data_all
for (link in missing_links_test6) {
  print(link)
  genres <- character(0)
  url <- paste0('https://www.goodreads.com/book/show/',link)
  host <- url
  try <- 0
  while (identical(genres, character(0)) & (try < 10)) {
    try <- try+1
    print(paste0(try, ": ", link))
    session <- bow(host,
                   delay = 5)
    scraping <- scrape(session)
    genres <-  scraping %>%  html_elements(".bookPageGenreLink") %>% 
      html_text()
  }
  if(identical(genres, character(0))){
    print("Trying new css")
    genres <- scraping %>% 
      html_elements('.BookPageMetadataSection__genre') %>% 
      html_text()
    }
  if(identical(genres, character(0))){
    print("Scraping unsuccessfull.. :( ")
  }
  else{
    print("scraping success!!")
    data <- data.frame(genres)
    dataSplit <- data %>% 
      mutate(
        genres = ifelse(grepl(",", genres),
                        str_remove(genres, ","),
                        genres),
        genres = ifelse(grepl("(users)", genres),
                        str_remove(genres, "users"),
                        genres),
        ## if the following row has a digit or the current row has a digit, keep
        ## else, if it is followed by a row with a non-digit print the genre + : + following row
        genres = ifelse((grepl("\\d", lead(genres))|grepl("\\d", genres)),#  grepl("\\d+[a-z]", lead(genres))), 
                        genres, paste0(genres, ": ", lead(genres))),
        genres = ifelse(grepl("\\d+[a-z]+\\s+[a-z|A-Z]+", lead(genres)),
                        paste0(genres, ": ", lead(genres)),
                        genres),
        genres = ifelse(grepl(":", lag(genres)), "del", genres)) %>% 
      subset(genres != "del") %>% 
      mutate(
        modulo = ifelse((row_number() %% 2)==1, "genre", "votes")
      ) 
    dataSplit <- dataSplit %>% 
      pivot_wider(names_from = modulo, values_from = genres) %>% 
      unnest(c(genre, votes))
    dataSplit <- dataSplit %>%
      mutate(
        # votes = ifelse(grepl(",", votes),
        #                str_remove(votes, ",") %>% str_extract("\\d+"),
        #                str_extract_all(votes, "\\d+")),
        votes = as.integer(votes),
        newCol1 = paste0(row_number())
      ) 
    dataSplit <- dataSplit %>%
      slice(1:3) %>%
      pivot_wider(names_from = newCol1, values_from = c(genre, votes)) %>%
      mutate(
        link = link)
    print("Data Processing Success")
    
    review_data_genre_test7 <- left_join(review_data_genre_test7, dataSplit, by = c("link"))
     print("join success")
     review_data_genre_test7 <- review_data_genre_test7 %>% 
                           mutate(genre_1 = ifelse(is.na(genre_1.x), genre_1.y, genre_1.x),
                           genre_2 = ifelse(is.na(genre_2.x), genre_2.y, genre_2.x),
                           genre_3 = ifelse(is.na(genre_3.x), genre_3.y, genre_3.x)) %>%
                      select(-c(genre_1.x, genre_2.x, genre_3.x, genre_1.y, genre_2.y, genre_3.y)) %>% 
                      mutate(votes_1 = ifelse(is.na(votes_1.x), votes_1.y, votes_1.x),
                             votes_2 = ifelse(is.na(votes_2.x), votes_2.y, votes_2.x),
                             votes_3 = ifelse(is.na(votes_3.x), votes_3.y, votes_3.x)) %>%
                      select(-c(votes_1.x, votes_2.x, votes_3.x, votes_1.y, votes_2.y, votes_3.y))
     
  }
}
View(review_data_genre_test7)
View(review_data)
review_data %>% 
  write.csv("data-with-genre-20-09.csv")
review_data_genre_test7 %>% 
  write.csv("data-with-genre-full.csv")
review_data_genre_test1 <- review_data
missing_titles_test1 <- review_data_genre_test1 %>% 
  filter(is.na(genre_1)) 
missing_titles_test2 <- review_data_genre_test2 %>% 
  filter(is.na(genre_1)) 
missing_titles_test3 <- review_data_genre_test3 %>% 
  filter(is.na(genre_1)) 
missing_titles_test4 <- review_data_genre_test4 %>% 
  filter(is.na(genre_1))
missing_titles_test5 <- review_data_genre_test5 %>% 
  filter(is.na(genre_1))
missing_titles_test6 <- review_data_genre_test6 %>% 
  filter(is.na(genre_1))
missing_titles_test7 <- review_data_genre_test7 %>% 
  filter(is.na(genre_1))


missing_links_test1 <- unique(missing_titles_test1$link)
missing_links_test2 <- unique(missing_titles_test2$link)
missing_links_test3 <- unique(missing_titles_test3$link)
missing_links_test4 <- unique(missing_titles_test4$link)
missing_links_test5 <- unique(missing_titles_test5$link)
missing_links_test6 <- unique(missing_titles_test6$link)
missing_links_test7 <- unique(missing_titles_test7$link)

length(missing_links_test7)
review_data_genre_test2 <- review_data_genre_test1
review_data_genre_test3 <- review_data_genre_test2
review_data_genre_test4 <- review_data_genre_test3
review_data_genre_test5 <- review_data_genre_test4
review_data_genre_test6 <- review_data_genre_test5
review_data_genre_test7 <- review_data_genre_test6

missing_links_test4 <- unique(missing_titles_test4$link)
test <- scrape_genre(link)
review_data_all <- review_data_all %>% 
  mutate(
    genre_1 = NA,
    genre_2 = NA,
    genre_3 = NA,
    votes_1 = NA,
    votes_2 = NA,
    votes_3 = NA,
  )
data.frame(missing_links_test1)
