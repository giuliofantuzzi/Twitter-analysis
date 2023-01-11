#------------------------------------------------
#LIBRARIES
library(rtweet)
library(httpuv)
library(ROAuth)
library(httr)
library(twitteR)
library(graphTweets)
library(igraph)
library(tidyverse)
#------------------------------------------------
#API AUTENTICATION
auth_setup_default()
#------------------------------------------------
#DATA MINING
#1) scarico i tweet
#tweets<- search_tweets("#climatechange", lang = "en", n=10)
multilang_tweets<- search_tweets("#climatechange", n=10000)

#2) dati sugli utenti
dati_utenti<- users_data(multilang_tweets)

TweetsSubset <- c("full_text",
                  "display_text_range", #posso interpretarlo come lunghezza? occhio che ci son cose oltre al testo però!
                  "retweet_count",  #n° retweet
                  "favorite_count", #n° likes
                  "lang")
UsersSubset <- c("followers_count", #n°follower
                 "friends_count", #ho aggiunto questo (era consigliata come variabile esplicativa)
                 "url",
                 "location", #secondo me NON considerarla
                 "description", #questa posso dicotomizzarla con T/F facendo controllo vettore == ""
                 "verified", #già dicotomizzata
                 "default_profile")  #default_profile potrebbe essere utile
            
Tweets <- data.frame(multilang_tweets[TweetsSubset])
Users <- data.frame(dati_utenti[UsersSubset])

#Ora creo un dataframe con le sole variabili scelte
dataset_finale<- data.frame(Tweets, Users)
#Esporto il dataframe come file.csv (così da averlo sempre a disposizione)
write.csv(dataset_finale, file = "../datasets/dataset_multilang2.csv")
#------------------------------------------------