# PROGETTO TWITTER
## API, DOWNLOAD E DATA MINING
Sul sito twitter developer ho creato un project e ho mandato la richiesta per l'API (accettata).

Ho installato i vari pacchetti su R e ho scaricato 1000 tweets con hastag #climatechange

**NOTE:**
- che numerosità usare? 1000 mi sembra sufficiente per costruire un modello, ma anche 10mila ci starebbe (infatti poi ne ho usati 10mila)
- riguardo la lingua, io ho messo "en", però potrei non specificarla e poi usare come variabile esplicativa la lingua (da valutare con gli altri)!

## DATA PREPARATION
### Che variabili usare?
Il prof nel suo esempio aveva usato queste. Propongo di modificare/eliminare/aggiungere in questo modo:

***A LIVELLO DI TWEET:***
- **created_at**: non ha senso nel nostro modello, anche perchè i tweet sono tutti recenti sulle ultime 2 settimane
- **id_str**: forse utile solo per avere un riscontro mentre facciamo cose con i dati, ma a livello di modello non ci serve
- **full_text**: è il testo del tweet...in realtà noi non dobbiamo fare analisi testuale, quindi non ci interessa
- **display_text_range**: credo sia la lunghezza del testo. TUTTAVIA ho notato che contano anche cose tipo "\n", quindi bisogna valutare se fare un minimo di text cleaning o se lasciare così
- **retweet_count**: numero di retweet, ci serve
- **favorite_count**: dovrebbe essere il numero di likes, e ci serve
- **lang**: potrebbe essere utile da usare come variabile categoriale (però bisogna scaricare tweets senza specificare "en")

NOTA: n_replies però mette NA su tutti, quindi non la considero....

NOTA: diceva di fare una classificazione dei tweet anche manuale...era ragionevole facendo 100 tweet a testa, ma con 500 tweet viene un modello di merda. È impensabile classificare a mano 10000 tweet (anche perche poi non si sa bene che classificazione fare)

***A LIVELLO DI USER***:
- **name**: nome della persona/organizzazione che ha l'account (non lo ritengo utile per il modello, al massimo solo per capirci meglio noi)
- **screen_name**: nome twitter (stessa cosa del punto sopra)
- **followers_count**: numero di follower...ci serve? il dubbio che ho è questo: nella definizione di eng abbiamo diviso per il n° di follower in modo da rendere confrontabili tweet di persone diverse (però per la stessa ragione non dovrei usare retweet e likes....)
- **location**: io direi di NON considerarla, non tanto per i dati mancanti, ma perchè non è un'informazione significativa. Infatti alcuni mettono il nome della città, altri mettono la nazione (e già qui sarebbe molto difficile organizzare i dati) altri ancora potenzialmente cose strane (riga 185 mettono Moon)--->infatti io non credo sia una variabile sensata neanche dicotomizzandola!
- **description**: è una descrizione testuale. Secondo me non è utile in sè, ma potrebbe essere interessante dicotomizzarla dando TRUE se c'è una descrizione; FALSE se non c'è
- **verified**: consigliava di usarla (NB: sicuramente sarà correlata a followers_count)
- IO AGGIUNGEREI ANCHE **friends_count** (consigliavano di usarla come esplicativa)

NB: per info su BIO farei le stesse considerazioni di location! Inoltre, riguardo a location non penso sia sensato dicotomizzare come nel caso di description

Aggiungerei anche: url e default_user (dicotomizzate)

### Dataset con cui lavorare
Una volta estratte le info a livello di tweet e di user, ha senso compattare tutto in un unico dataframe, con cui poi lavoreremo

### Engagement
Twitter defines its engagement as the total number of times a user interacted with a Tweet, including Retweets, replies, follows, likes, links, cards, hashtags, embedded media, username, profile photo, or Tweet expansion. Engagement rate is the key to understand social media. In other words, this is the way to measure how people interact with the content you publish.
Engagement shows how people interacted, actively, with your content: through likes (or other reactions), comments, shares.

ENG_USER = [(likes+retweets)/tweets]/follower * 100

NB: questa definizione fa capire che è adatto fare questa misura a livello di account, in quanto mi dice quanto un profilo è in tendenza...io la riadatterei così:

ENG_TWEET =(likes+retweets)/follower * 100

NOTA: quando ho provato a calcolarlo sui dati ho notato alcuni problemi:

1) se follower=0 risulta eng=Inf. Ho visto che mediamente pochissimi dati avevano 0 follower, quindi l'idea migliore è non considerarli

2) distribuzione fortemente asimmetrica...media ha un valore molto estremo (sicuramente non la uso come soglia)

3) usare la mediana è sicuramente più sensato di usare la media, ma allo stesso tempo la mediana divide i dati in 2 parti =, e questo non mi convince

4) come soglia secondo me basta riflettere sul significato dell'engagement--->esso ci dice quanto le persone hanno interagito col nostro post....se n° interazioni > n°follower, allora posso dire che il tweet è andato in tendenza (perchè ha raggiunto più persone di quelle previste). L'idea migliore è quindi dire che se eng>1 il tweet è andato in tendenza, se <=1 no (quindi dicotomizzo secondo questa soglia). Magari posso provare a usare come soglia anche 2 (potenzialmente ogni follower può sia mettere like che retwittare)

## MODELLO LOGISTICO
All'inizio potrebbe essere interessante fare una matrice di correlazione per farci un'idea di come sono correlate le var tra loro
