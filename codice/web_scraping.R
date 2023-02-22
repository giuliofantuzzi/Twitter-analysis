
#LIBRARIES
library(rtweet)
library(httpuv)
library(ROAuth)
library(httr)
library(twitteR)
library(graphTweets)
library(igraph)
library(tidyverse)
#API AUTENTICATION
auth_setup_default()
#1) Tweets download
multilang_tweets<- search_tweets("#climatechange", n=10000)
#2) Users data
dati_utenti<- users_data(multilang_tweets)


TweetsSubset <- c("full_text","display_text_range","retweet_count", "favorite_count","lang")
UsersSubset <- c("followers_count","friends_count","url","description","verified") 
Tweets <- data.frame(multilang_tweets[TweetsSubset])
Users <- data.frame(dati_utenti[UsersSubset])
#Creo ed esporto un dataframe con le sole variabili selezionate
dataset_CC<- data.frame(Tweets, Users)
write.csv(dataset_CC, file = "../datasets/dataset_CC.csv")
#------------------------------------------------