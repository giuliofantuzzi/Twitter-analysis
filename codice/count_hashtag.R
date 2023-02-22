count_hashtags <- function(tweet) {
    library(stringr)
    hashtags <- str_extract_all(tweet, "#\\w+")
    return(length(hashtags[[1]]))
}
