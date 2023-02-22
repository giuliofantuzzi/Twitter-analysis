#-------------------------------------------------------------------------------
#Importiamo il dataset ottenuto con Data Preparation
eng_data<- read.csv("../datasets/dataset_pulito_CC.csv", header=T)
eng_data <- eng_data[,-which(colnames(eng_data)=="X")]

# Dicotomizziamo la variabile risposta (si veda il report per la soglia)
eng_data$eng_rate<- as.integer(eng_data$eng_rate > 200)

#SERVE FATTORIZZARE LE VARIABILI DICOTOMICHE!!!
eng_data$en_tweet = factor(eng_data$en_tweet)
eng_data$url = factor(eng_data$url)
eng_data$description = factor(eng_data$description)
eng_data$verified = factor(eng_data$verified)

#anche la var risposta?! Indifferente...funziona in entrambi i casi dando gli stessi risultati :)
eng_data$eng_rate = factor(eng_data$eng_rate)

#-------------------------------------------------------------------------------
#1)MODELLO CON TUTTE LE VARIABILI
modello1= glm(eng_rate ~., data=eng_data,
              family = binomial(link = logit))
#Avvertimento:fitted probabilities numerically 0 or 1 occurred
#Come mai dà questo errore? includere friends count da problemi poichè distribuzione MOLTO asimmetrica
#-------------------------------------------------------------------------------
#3) potrei stabilizzare asimmetria con logaritmo? NO, xke ci sono dei friends_count=0
#Però potrei usare una trasformazione box-cox--->es: uso la semplice radice
modello3= glm(eng_rate ~ tweet_length +n_hashtags + sqrt(friends_count)+en_tweet+ description+ url + verified, data=eng_data,
              family = binomial(link = logit))
summary(modello3)
#ancora messaggio di avvertimento...in effetti la radice non corregge molto la simmetria
#In effetti:
hist(eng_data$friends_count, col="indianred1",breaks=100,xlim=c(0,4e+04),
     ylim=c(0,8000),main="Friends Count", xlab="friends count")

#2) MODELLO SENZA FRIENDS_COUNT
modello2= glm(eng_rate ~tweet_length+ n_hashtags +en_tweet+ 
              description+ url + verified, data=eng_data,
              family = binomial(link = logit))

summary(modello2)
+#problema risolto? nessun avvertimento, ma AIC di questo modello è maggiore
#Però ci sono dei coef non significativi: verified e l'intercetta
#L'intercetta non deve intendersi come nel modello lineare, ma è la probabilità quando le esplicative sono nulle/false--->e ha senso che sia coef nullo, poichè se tutto è nullo il tweet non può avere successo
#verified in realtà ci stupisce un po...si pensava che avere il profilo ver fosse molto correlato a eng
#però effettivamente se facciamo un check si vede che i tweet con eng>200

#Quanti tweets hanno avuto successo?
sum(eng_data$eng_rate==1) #1567
#Quanti tweets sono di account verificati?
sum(eng_data$verified==TRUE) #309
#Quanti tweets di account verificati hanno avuto successo?
sum(eng_data$eng_rate==1 & eng_data$verified==TRUE) #0
#--->in effetti nei nostri dati nessun verificato ha avuto successo!

modello3<- glm(eng_rate ~tweet_length+ n_hashtags 
               +en_tweet+ description+ url , data=eng_data,
               family = binomial(link = logit))

summary(modello3)


#4) MAGARI c'è BRUTTO EFFETTO DI VAR CORRELATE TRA LORO E POCO CORRELATE ALLA y?

#Proviamo a togliere length e/o n_hashtags
modello2= glm(eng_rate ~ n_hashtags + sqrt(friends_count)+en_tweet+ description+ url + verified, data=eng_data,
              family = binomial(link = logit))
summary(modello4)
modello4= glm(eng_rate ~tweet_length + sqrt(friends_count)+en_tweet+ description+ url + verified, data=eng_data,
              family = binomial(link = logit))
summary(modello4)
modello4= glm(eng_rate ~  sqrt(friends_count)+en_tweet+ description+ url + verified, data=eng_data,
              family = binomial(link = logit))
summary(modello4)