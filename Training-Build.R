library(tidyverse)
library(cluster)
library(factoextra)
library(lubridate)

setwd("C:/Users/Daniel Myerscough/Documents/Music-Project/Playlists")
playlists <- list.files()
songs <- data.frame()

for (playlist in playlists) { 
  df <- read.csv(playlist)
  df$old_list <- strsplit(playlist, ".", fixed = TRUE)[[1]][1]
  songs <- rbind(songs, df)
}

songs$tone <- sapply(strsplit(songs$Key, " ", fixed = TRUE), `[`, 2)
songs$key <- sapply(strsplit(songs$Key, " ", fixed = TRUE), `[`, 1)
songs$length <- as.integer(sapply(strsplit(songs$Duration, ":", fixed = TRUE), `[`, 1)) * 60 + as.integer(sapply(strsplit(songs$Duration, ":", fixed = TRUE), `[`, 2))
songs$album_age <- # Get age of album
songs <- subset(songs, select = -c(old_list, Key, X., Added.At, Album, Spotify.Track.Id, Explicit, ISRC, Duration))

songs <- songs %>% 
  mutate(
    Song = as.factor(Song),
    Artist = as.factor(Artist),
    Camelot = as.factor(Camelot),
    Album.Date = as.Date.factor(Album.Date),
    tone = as.factor(tone),
    key = as.factor(key),
    length = as.integer(length)
  )

setwd("C:/Users/Daniel Myerscough/Documents/Music-Project")
write.csv(songs_feed, "songs-combined.csv")

gower <- daisy(songs, metric = "gower")

set.seed(1024)
pam_fit <- pam(gower, diss = TRUE, k = 35)
# Get average 
# https://developer.spotify.com/documentation/web-api