#-----------------------------------------------
#ENGAGEMENT A LIVELLO DI TWEET
#------------------------------------------------
#su internet dicono che la formula è [(likes+retweets)/n°tweets]/n°follower *100
#però così avrei una misura sullo user, se vogliamo una misura a livello di tweet
#---->[likes + retweets]/ n° follower * 100
#NB: ha senso dividere per follower in modo da "standardizzare"
eng_tweet<- function(data){
    likes<- data$favorite_count
    retweets<- data$retweet_count
    followers<- data$followers_count
    #replies non sono dati disponibili! (sennò avrei sommato anche quelli)
    rate<- ((likes+retweets)/followers) *100
    return(rate)
}
