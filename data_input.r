
if (!require(stringr)) {install.packages("stringr")}
if (!require(rvest)) {install.packages("rvest")}
if (!require(tm)) {install.packages("tm")} # Si no funciona la instalaciÃƒÂ³n, probar instalando antes el paquete XML
if (!require(SnowballC)) {install.packages("SnowballC")}
if (!require(rlist)) {install.packages("rlist")}
#install.packages("hash")
if (!require(ngram)) {install.packages("ngram")}
if (!require(qdapDictionaries)) {install.packages("qdapDictionaries")}
if (!require(RCurl)) {install.packages("RCurl")}
if (!require(countrycode)) {install.packages("countrycode")}
if (!require(rvest)) {install.packages("rvest")}
if (!require(tidytext)) {install.packages("tidytext")}
if (!require(dplyr)) {install.packages("dplyr")}
if (!require(dplyr)) {install.packages("maps")}
if (!require(dplyr)) {install.packages("plyr")}
if (!require(dplyr)) {install.packages("data.table")}
if (!require(dplyr)) {install.packages("cluster")}
#################LIBRERIAS VISUALIZACION###################
if (!require(wordcloud)) {install.packages("wordcloud")}
if (!require(RColorBrewer)) {install.packages("RColorBrewer")}
if (!require(gridExtra)) {install.packages("gridExtra")}
if (!require(grid)) {install.packages("grid")}
if (!require(ggplot2)) {install.packages("ggplot2")}

##########################################################
library(maps)
library(cluster)
library(data.table)
library(plyr)
library(rvest)
library(countrycode)
library(RColorBrewer)
library(wordcloud)
library(tm)
#library(hash) #para crear y operar con estructuras hash
library(stringr)
library(stringi)
library(ngram)
library(qdapDictionaries)
library(RCurl)
library(gridExtra)
library(grid)
library(ggplot2)

###############################################################################################################################
##################################################DECLARACIÃN DE FUNCIONES#####################################################
#Comprobamos si la palabra estÃ¡ en el diccionario
is.word  <- function(x) x %in% GradyAugmented

get_existing_words <- function(x){ #Tarda mucho :(
  lyric <- list()
  all_words <- unlist(stri_extract_all_words(x))
  for (w in all_words) {
    if (is.word(w)){
      lyric <- c(lyric, w)
    }
  }
  return(unlist(lyric))
}

split_words <- function(f_list){
  return(f_list <- stri_extract_all_words(f_list)[[1]])
}

extract_country_es <- function(table, countries, world.cities){
  k <- FALSE
  for (i in 1:length(table)) {
    #encontramos la tabla que contiene la info requerida (si existe)
    if("Origen" %in% (table[i]%>%html_nodes("th")%>%html_text())|"Nacionalidad" %in% (table[i]%>%html_nodes("th")%>%html_text())|"Nacimiento" %in% (table[i]%>%html_nodes("th")%>%html_text())){      
      table <- table[i]
      k <- TRUE
      break
    }
  }
  if(k){
    #filtramos por nodos para hacer la busqueda mas eficiente
    table <- table %>% html_nodes("td") %>% html_nodes("a") %>% html_text()
    table <- table[1:10]
    if("Estadounidense" %in% table) return("Estados Unidos")
    if("Inglaterra" %in% table) return("Reino Unido")
    #buscamos el pais en la primera lista de paises
    country <- get_country1(countries, table)
    #si no, en la segunda
    if(is.null(country)){
      #para ello separamos las palabras y comprobamos una a una por ciudad
      table <- paste(table, collapse = " ")
      table <- split_words(table)
      n <- get_country2(world.cities, table)
      if(n > 0){
        #si n>0 hay al menos un pais con esa ciudad
        country <- world.cities$country.etc[n]
      }
    }
    return(country)
  }
  return(NULL)
}

extract_country_en <- function(table, countries, world.cities){
  k <- FALSE
  for (i in 1:length(table)) {
    #encontramos la tabla que contiene la info requerida (si existe)
    if("Origin" %in% (table[i]%>%html_nodes("th")%>%html_text())|"Born" %in% (table[i]%>%html_nodes("th")%>%html_text())){
      table <- table[i]
      k <- TRUE
      break
    }
  }
  if(k){
    #filtramos por nodos para hacer la busqueda mas eficiente
    table <- table %>% html_nodes("td") %>% html_nodes("a") %>% html_text()
    table <- table[1:10]
    #buscamos el pais en la primera lista de paises
    country <- get_country1(countries, table)
    #si no, en la segunda
    if(is.null(country)){
      #para ello separamos las palabras y comprobamos una a una por ciudad
      table <- paste(table, collapse = " ")
      table <- split_words(table)
      n <- get_country2(world.cities, table)     
      if(n > 0){
        #si n>0 hay al menos un pais con esa ciudad
        country <- world.cities$country.etc[n]
      }
    }
    return(country)
  }
  return(NULL)
}

get_country1 <- function(country_list, origin){
  #busqueda en las listas de paises de countrycode
  for (k in 1:length(origin)) {
    if(origin[k] %in% country_list){
      return(origin[k])
    }
  }
}

get_country2 <- function(cities, origin){
  #busqueda en la base de datos de world.cities
  for (k in 1:length(origin)) {
    n <- which(origin[k] == cities$name)
    if(length(n) >= 1) {return(n[1])}
  }
  return(0)
}

firstup <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  return(x)
}

url_exists <- function(x) url.exists(as.character(x))

#' Translate with R
#'
#' Translate Keywords or/and text with the Google Translate API
#' The Functions allows to translate keywords or sentences using the Google Translate API.
#' To use this function you need to get a API-Key for the Google Translate API <https://cloud.google.com/translate/docs/?hl=en>.
#' @param text The keyword/sentence/text you want to translate
#' @param API_Key Your API Key. You get the API Key here: <https://cloud.google.com/translate/docs/?hl=en>
#' @param target The Language target your text translated to. For German 'de'. 
#' @param source The Language your given text/keyword is. For example 'en' - english 
#' translate()
#' @examples
#' \dontrun{
#' translate(text = "R is cool", API_Key = "XXXXXXXXXXX", target = "de", source = "en")
#' }


translate <- function(text, API_Key, target = "en", source = "es") {
  b <- paste0('{"q": ["',text,'"],"target": "',target,'","source": "',source,'","format": "text"}')
  url <- paste0("https://translation.googleapis.com/language/translate/v2?key=", API_Key)
  x <- httr::POST(url, body = b)
  x <- jsonlite::fromJSON(rawToChar(x$content))
  x <- x$data$translations
  return(x$translatedText[1])
}
##############################################################################################################################
#################################################  EXTRACTION AND DATA STRUCTURE  ########################################################
#primer dataset: songdata.csv
ASCL <- read.csv(paste(getwd(), "/Data/songlyrics/songdata.csv", sep = ""), header = TRUE, sep = ",", nrows = 5000, colClasses = c(NA, NA, "NULL", NA))
#la tercera columna son las letras
names(ASCL)[3] <- "lyrics"
#segundo dataset: lyrics.csv
aux <- read.csv(paste(getwd(), "/Data/songlyrics/lyrics.csv", sep = ""), header = TRUE, sep = ",", nrows = 5000, colClasses = c("NULL", NA, "NULL", NA, "NULL", NA))
aux <- aux[,c(2, 1, 3)]#mismo orden de columas que aux
ASCL<- rbind(ASCL, aux)#concatenar los data frames
rm(aux)
ASCL <- data.frame(ASCL)
# Convertimos a minÃºsculas cada palabra, no solo de la letra de las canciones, sino del tÃ­tulo de la canciÃ³n
#Problema -> Al hacer apply devuelve una lista en vez de un data.frame, asÃ­ que volvemos a convertirlo a data.frame
# la funciÃ³n t() devuelve la matriz transpuesta, ya que por alguna razÃ³n apply devuelve las columnas como filas y al revÃ©s

#for(i in 1:length(ASCL))
#  ASCL[i] <- lapply(ASCL[i],toupper) #pasar el dataframe a mayusc

################################################################################################################################
############################################  DATA CLEANING  ###################################################################
#DATAFRAME CONTAINING ALL INFO 
ASCL <- setNames(ASCL <- data.frame(ASCL[[1]],apply(ASCL[2:3], 2, tolower)), c("artist","song","lyrics")) #no transformamos la columna de artistas
ASCL[,3] <- removeWords(as.character(ASCL[,3]), words = c(stopwords("english"), "oh", "ah", "eh", "uh", "ma"))  #stopwords estan en minuscula
ASCL[,3] <- stripWhitespace(ASCL[,3])
ASCL[,3] <- removePunctuation(ASCL[,3])
ASCL[,3] <- removeNumbers(ASCL[,3]) # Por si acaso

#ARTIST INFO CLEANING 
artists <- cbind(as.data.frame(table(ASCL$artist), stringsAsFactors = FALSE), NA) #aquÃ­ van los artistas con su frecuencia en el dataframe
#separamos las palabras que componen el nombre del artista por espacios
artists[,1] <- str_replace_all(artists[,1],"-"," ")
artists[,1] <- str_replace_all(artists[,1],"_"," ")
#Pasamos a mayus la primera letra de cada palabra y unimos con '_' para busqueda en la web
for (i in 1:length(artists$Var1)) {
  artists[i, 1] <- paste(unlist(firstup(split_words(artists[i, 1]))), collapse = "_")  
}
#pasamos los articulos que mas aparecen a minuscula
artists[,1] <- str_replace_all(artists[,1],"Of","of") #queda pulir los artÃ­culos de los artistas
artists[,1] <- str_replace_all(artists[,1],"This","of") #queda pulir los artÃ­culos de los artistas
artists[,1] <- str_replace_all(artists[,1],"With","of") #queda pulir los artÃ­culos de los artistas
artists[,1] <- str_replace_all(artists[,1]," ","_") #en las url los espacios se sustituyen por '_'
#cambaimos el nombre de las columnas
colnames(artists) <- c("Artist", "Freq","Country")

##########################################################################################################################
#################################### DATA INTERPRETATION ##############################################

#Get words from a certain band
songs <- ASCL[ASCL[1] == "Dolly Parton",,]
songs <- data.frame(songs[2],songs[3]) #We don't need the band name
for(s in 1:nrow(songs)){ #Veremos las palabras mÃ¡s utilizadas en cada canciÃ³n
  song <- songs[s,,]
  print(song$song)
  song_lyric <- get_existing_words(song$lyrics)
  words.freq <- table(song_lyric)
  words_data <- cbind.data.frame(names(words.freq),as.integer(words.freq))
  names(words_data) <- c("word", "repetitions")
  words_data <- words_data[order(words_data$repetitions, decreasing = TRUE)[1:10], ] #Cogemos las 10 palabras con mÃ¡s apariciones
  fname <- paste("/home/paulamlago/Documents/Uni/MIN/Analisis-de-letras-de-canciones/", str_replace_all(song$song, " ",""), ".png", sep="")
  png(filename = fname)
  barplot(words_data$repetitions, 
          names.arg = words_data$word,
          xlab = "Words",
          ylab = "Repetitions",
          main =song$song,
          las = 2)
  dev.off()
}

############EXTRACCIÃN DEL SENTIMIENTO DE LAS CANCIONES#####################

words_sentiments <- get_sentiments(lexicon = "nrc") #Data frame palabra,sentimiento
#Nos desacemos del titulo de las canciones
AL <- ASCL[-c(2)] #data frame of dataframes
AL <- split(AL, AL$artist) #split doesn't work as it doesn't show some artists

#create a data frame containing artist - list of words
Artist_lyrics <- data.frame()
Artist_sentiments <- data.frame()
for (i in 1:length(AL)){
  artist_words <- unlist(str_split(AL[i][[1]][,2], " "))
  print(i)
  if (length(artist_words) > 0){
    Artist_lyrics <- rbind(Artist_lyrics, data.frame(AL[i][[1]][1,1], artist_words)) #dataframe Artist -word
    sentiment_list <- list()
    sentiment_list <- sentiment_extractor(artist_words) #returns a list of lists of sentiments
    print(length(sentiment_list)) #estas son las palabras que tienen asociados sentimientos en el diccionario
    Artist_sentiments <- rbind(Artist_sentiments, data.frame(AL[i][[1]][1,1], unlist(sentiment_list))) # dataframe Artist - sentiment
  }
}
rm(artist_words, sentiment_list, i, AL)

Artist_sentiments.freq <- table(Artist_sentiments)
tg = gridExtra::tableGrob(Artist_sentiments.freq)
h = grid::convertHeight(sum(tg$heights), "in", TRUE)
w = grid::convertWidth(sum(tg$widths), "in", TRUE)
ggplot2::ggsave("sentimentsForEachArtist.pdf", tg, width=w, height=h, limitsize = FALSE)
#hacemos agrupaciones por artista y cogemos los sentimientos mÃ¡s presentes de cada uno
Artist_most_used_sentiment <- data.frame(rownames(Artist_sentiments.freq), colnames(Artist_sentiments.freq)[apply(Artist_sentiments.freq, 1, which.max)])
names(Artist_most_used_sentiment) <- c("Artists", "Sentiments")
plot(Artist_most_used_sentiment$Sentiments, col = "ligblue")
names(Artist_sentiments) <- c("Artist", "sentiment")
#################################################################################################################
#################################################################################################################
################### OBTENCIÃN DEL PAIS DE CADA AUTOR #######################
#Todos los paÃ­ses en castellano e ingles, para comprobar con las string que obtengamos
existing_countries_es <- countrycode::codelist$cldr.name.es 
existing_countries_en <- countrycode::codelist$cldr.name.en 
#dataset con ciudades vinculadas a paises
data(world.cities)
#La intenciÃ³n es recorrer los artistas, crear la url de Wikipedia y encontrar la tabla que contenga la info que necesitamos

#ejecutamos diferentes loops para buscar el paÃ­s de procedencia del artista teniendo en cuenta que pueden faltar detalles como
# poner despuÃ©s del artista (banda) para que sea reconocible por wikipedia
for(i in 1:length(artists$Artist)){
  pwebs <- c(paste("https://es.wikipedia.org/wiki/", artists[i, 1], sep=""),
             paste("https://es.wikipedia.org/wiki/", artists[i, 1], "_(banda)", sep=""),
             paste("https://es.wikipedia.org/wiki/", artists[i, 1], "_(cantante)", sep=""),
             paste("https://en.wikipedia.org/wiki/", artists[i, 1], sep=""),
             paste("https://en.wikipedia.org/wiki/", artists[i, 1], "_(singer)", sep=""),
             paste("https://en.wikipedia.org/wiki/", artists[i, 1], "_(band)", sep="")) #Todas las posibilidades
  exists <- sapply(pwebs, url_exists)
  if (any(exists) == TRUE){
    index <- which(exists == TRUE)[1] #En el caso de que existan varias, cogemos la primera
    print(i)
    page <- read_html(pwebs[index])
    a <- page %>% html_nodes("table")
    country <- extract_country_es(a, existing_countries_es, world.cities)
    if(is.null(country)){
      country <- extract_country_en(a, existing_countries_en, world.cities)
      if(is.null(country)){
        #Borramos la fila del dataframe
        artists <- artists[-c(i), ]
      }
    } else { artists[i,3] <- country }
  } else {
    print(paste(i, " doesn't exists"))
    artists <- artists[c(-i), ] #Si no estÃ¡ en ninguna de las pwebs -> borramos la fila
  }
}

rm(i, country, pweb, pwebs, page, a)
#traducimos al castellano los paises obtenidos mediante el algoritmo
for(i in 1:length(artists$Country)){
  if(artists$Country[i]%in%existing_countries_en){
    artists$Country[i] <- countrycode(artists$Country[i], "country.name", "cldr.name.es")
  }
  else if(artists$Country[i]=="UK"|artists$Country[i]=="USA"){
    artists$Country[i] <- countrycode(artists$Country[i], "country.name", "cldr.name.es")
  }
}

artists[,1] <- str_replace_all(artists[,1], "_", " ")
artists[,1] <- toupper(artists[,1])
Artist_most_used_sentiment[,1] <- toupper(Artist_most_used_sentiment[,1])
Artist_most_used_sentiment <- Artist_most_used_sentiment[-c(1),]
Country_sentiment <- data.frame()
for (a in 2:nrow(artists)){
  artist <- artists[a,]
  if (!is.na(artist$Country) && any(Artist_most_used_sentiment$Artists == artist$Artist)){
    index <- which(Artist_most_used_sentiment$Artists == artist$Artist)
    Country_sentiment <- rbind(Country_sentiment, data.frame(artist$Country, Artist_most_used_sentiment[index, 2]))
  }
}
names(Country_sentiment) <- c("Country", "sentiment")
rm(a, artist)
artists <- artists[-c(which(is.na(artists$Country))),]
tg = gridExtra::tableGrob(Country_sentiment)
h = grid::convertHeight(sum(tg$heights), "in", TRUE)
w = grid::convertWidth(sum(tg$widths), "in", TRUE)
ggplot2::ggsave("country_sentimentsFrequency.pdf", tg, width=w, height=h, limitsize = FALSE)
cs <- split(Country_sentiment, Country_sentiment$Country)

t1 <- table(Country_sentiment)
df <- data.frame(Country=character(), Sentiment=character())
names(df) <- c("Country", "Sentiment")
for (i in 1:nrow(t1)) {
  df <- add_row(df, Country=rownames(t1)[i], Sentiment=names(which.max(t1[i,])))
}
df2 <- data.frame(Sent=integer())
k <- table(df)
for (i in 1:ncol(k)) {
  df2 <- add_row(df2, Sent=sum(k[,i]))
}
row.names(df2) <- c("anger", "positive", "negative")
t2 <- t(t1)
df3 <- data.frame(rbind(t2))
########################################################################################################################
##############################VISUALIZACION DE DATOS######################
plot(auths_count) #visualizacion de los datos antes de agrupar
wordcloud(words_data[,1], freq = words_data[,2],min.freq = 1, random.order = FALSE,color= brewer.pal(8, "Dark2"), max.words = 500)

#VisualizaciÃ³n 10 palabras mÃ¡s utilizadas
pal <- colorRampPalette(colors = c("blue", "lightblue"))(length(words_data[[1]]))
barplot(words_data$repetitions, 
        names.arg = words_data$word,
        col = pal,
        xlab = "Words",
        ylab = "Repetitions")

#Visualize the most used words from that band
songs_most_used_words <- get_existing_words(songs$lyrics)
words.freq <- table(songs_most_used_words)
words_data <- cbind.data.frame(names(words.freq),as.integer(words.freq))
names(words_data) <- c("word", "repetitions")
pal <- colorRampPalette(colors = c("orange", "white"))(length(words_data[[1]]))
words_data <- words_data[order(words_data$repetitions, decreasing = TRUE)[1:15], ] #Cogemos las 15 palabras con mÃ¡s apariciones
barplot(words_data$repetitions, 
        names.arg = words_data$word,
        col = pal,
        xlab = "Words",
        ylab = "Repetitions",
        las = 2)

Dolly_sentiments <- Artist_sentiments[which(Artist_sentiments$Artist == "Dolly Parton"), 2]
ds <- table(Dolly_sentiments)
ds <- cbind.data.frame(names(ds), as.integer(ds))
names(ds) <- c("sentiment", "Frequency")
barplot(ds$Frequency,
        names.arg = ds$sentiment,
        xlab = "Words",
        ylab = "Repetitions",
        las = 1)
dev.off()