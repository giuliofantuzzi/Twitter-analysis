#------------------------------------------------
#importo i dati (10mila tweets)
data<- read.csv("../datasets/dataset_multilang2.csv")
#importo la funzione per calcolo engagement
source("tweet_engagement.R")
#------------------------------------------------
#Se 0 follower, risulterebbe un engagement infinito
#Quante volte c'è sto problema?
sum(data[,"followers_count"]==0) #39 (vorrei ancora meno se possibile)
#Qui si aprono alcune strade:
#1) non divido per n° follower (ma così sarebbe come se avesse 1 follower...mhhhh)
#2) assegno a tutti questi il valore max tra gli altri(ma non ha senso dare eng_rate = se ho un numeratore diverso)
#3) nella funzione del prof in realtà non c'era follower...però ha senso considerarli (in internet lo dicono dappertutto e ha senso)
#   i follower vanno tenuti, sennò è ovvio che chi ha + follower ha n°interazioni maggiori--->vogliamo togliere questo "effetto influencer"
#4) elimino i record in cui n° follower = 0 (visto che sono solo il 0.27% del tot)
#----->io direi l'opzione (1), anche perchè se no avere valori infiniti di eng non ci permetterebbe di farne statistiche tipo media ecc

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
###############################################################


#Una volta scelto cosa fare bisogna dicotomizzare sta variabile di engagement
#Come scelgo la soglia?
#1) media? assolutamente no, perchè è influenzata dal valore estremo e non è significativa per la distribuzione
#2) mediana? già meglio, ma così (circa) metà avrebbero la caratteristica e mhhh
#3) 1 è il valore più sensato se pensiamo al significato di engagement
#4) anche 2 è sensato

#-----------------------------
# Trasformazione di variabili
#-----------------------------

# (1) Lingue dei tweet
lingue<- data[,"lang"]
table(lingue)
barplot(table(lingue))
#--->9082 sono inglesi...le altre hanno freq troppo più basse: dicotomizzo inglese o non inglese
colnames(data)[which(colnames(data)=="lang")]<- "eng_tweet"
data[,"eng_tweet"]<- data[,"eng_tweet"]=="en"
barplot(table(data[,"eng_tweet"]), col=4, main="Eng tweet?")

# (2) Descrizione
#preliminare: vediamo se ci sono valori NA
sum(is.na(data[,"description"]))#=0--->allora nessun na
sum(data[,"description"]=="")#-->1246 vuoti
#Assegno true se c'è descrizione; false se campo vuoto
data[,"description"]<- data[,"description"]!=""

# (3) URL
#Ragiono come su descrizione
#i dati in sto caso o sono un url o sono NA
#Assegno true se c'è url; false se campo vuoto
data[,"url"]<- !is.na(data[,"url"])

# (4) rimuoviamo la location
data = data[,-which(colnames(data)=="location")]

# (5) aggiungo colonna engagement
data[,"tweet_eng"]<- engagement

# (6) mancherebbe il discorso sul n° di hastag 

# (7) poi posso eliminare full_text (e eventualmente anche retweet,likes e follower)

#-----------------------------
#Data preparation finita: salvo il dataset pulito
#write.csv(data, file = "../datasets/dataset_pulito.csv")
#-----------------------------
