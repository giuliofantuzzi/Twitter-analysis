#------------------------------------------------
#importo i dati (10mila tweets)
data<- read.csv("../datasets/dataset_CC.csv")
data<- data[,-which(colnames(data)=="X")]
#importo la funzione per calcolo engagement
source("tweet_engagement.R")
#------------------------------------------------
#PRE ANALISI SU VALORI N.A o vuoti
missing_values= vector(mode="numeric", length=dim(data)[2])
empty_values= vector(mode="numeric", length=dim(data)[2])
for (i in 1: dim(data)[2]){
    missing_values[i]= sum(is.na(data[,i]))
    empty_values[i]= sum(data[,i] =="", na.rm=T)
}
missing_values!=0 && empty_values!=0
#0, allora 
barplot(missing_values~colnames(data), horiz=F, xlab="", ylab="",las=1, cex.names=0.7, col=3,
        main= "N.A./ Missing values")
barplot(empty_values~colnames(data), horiz=F, xlab="",ylab="", las=1, cex.names=0.7,col=4, add=T)
legend("topleft",c("N.A.", "Empty"), col=c(3,4),fill=c(3,4))


#Se 0 follower, risulterebbe un engagement infinito
#Quante volte c'è sto problema?
sum(data[,"followers_count"]==0) #39 (vorrei ancora meno se possibile)
#Qui si aprono alcune strade:
#1) non divido per n° follower (ma così sarebbe come se avesse 1 follower...mhhhh)
#2) assegno a tutti questi il valore max tra gli altri(ma non ha senso dare eng_rate = se ho un numeratore diverso)
#3) nella funzione del prof in realtà non c'era follower...però ha senso considerarli (in internet lo dicono dappertutto e ha senso)
#   i follower vanno tenuti, sennò è ovvio che chi ha + follower ha n°interazioni maggiori--->vogliamo togliere questo "effetto influencer"
#4) elimino i record in cui n° follower = 0 (visto che sono solo il 0.39% del tot)
#----->io direi l'opzione (4), anche perchè se no avere valori infiniti di eng non ci permetterebbe di farne statistiche tipo media ecc

#Decidiamo di togliere questi record:
data<- subset(data,data$followers_count >0 )
engagement<- eng_tweet(data)
#Intanto può essere utile plottare la distribuzione:
hist(engagement, freq=T, main="tweets engagement")
summary(engagement)
#---->dati molto brutti

###############################################################
#-->vediamo che è asimmetrica, forse utile passare ai log?
#NB: però se l'engagement è 0,non posso calcolare il log
sum(engagement==0)#--->1427
#Posso ragionare come prima e dire di togliere i dati? NO, toglierei troppi dati
#Inoltre teniamo presente che passare ai logaritmi renderebbe interpretazione coefficienti MOLTO meno intuitiva (a modelli ci hanno detto di farle con parsimonia)

#-----------------------------
# Trasformazione di variabili
#-----------------------------

# (1) Lingue dei tweet
lingue<- data[,"lang"]
table(lingue)
barplot(table(lingue))
#--->9082 sono inglesi...le altre hanno freq troppo più basse: dicotomizzo inglese o non inglese
colnames(data)[which(colnames(data)=="lang")]<- "en_tweet"
data[,"en_tweet"]<- data[,"en_tweet"]=="en"
barplot(table(data[,"en_tweet"]), col=4, main="English tweet?")

# DESCRIPTION
#Assegno true se c'è descrizione; false se campo vuoto
data[,"description"]<- data[,"description"]!=""
barplot(table(data[,"description"]), col=4, main="Description?")
# URL
#Assegno true se c'è un url; false se dato N.A.
data[,"url"]<- !is.na(data[,"url"])
barplot(table(data[,"url"]), col=4, main="Url?")

# (4) aggiungo colonna engagement
data[,"eng_rate"]<- engagement

# (5) mancherebbe il discorso sul n° di hastag 
source("count_hashtag.R")

library(stringr)
n_hashtags<- vector(mode="numeric", length = length(data[,1]))
for(i in 1: length(data[,1])){
    n_hashtags[i]= count_hashtags(data[i,"full_text"])
}


sum(n_hashtags==0)
barplot(table(n_hashtags))

#aggiungo numero hashtag
data[,"n_hashtags"]<-  n_hashtags

# (7) calcolo la VERA lunghezza del tweet
tweet_length<- nchar(data$full_text)
#e la aggiungo
data[,"tweet_length"] <- tweet_length


# (8) Elimino le variabili che non serviranno più
data <- data[,-which(colnames(data)=="full_text")]
data <- data[,-which(colnames(data)=="retweet_count")]
data <- data[,-which(colnames(data)=="favorite_count")]
data <- data[,-which(colnames(data)=="followers_count")]
data <- data[,-which(colnames(data)=="display_text_range")]


#-----------------------------
#Data preparation finita: salvo il dataset pulito
write.csv(data, file = "../datasets/dataset_pulito_CC.csv")
#-----------------------------