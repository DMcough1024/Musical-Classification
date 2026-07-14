library(tidyverse)
library(cluster)
library(factoextra)
library(lubridate)
library(here)
library(httr)
library(jsonlite)

# Define Functions
header <- c("Playlist")
header <- c(header, "BPM-25", "BPM-M", "BPM-50", "BPM-75")
header <- c(header, "NRG-25", "NRG-M", "NRG-50", "NRG-75")
header <- c(header, "DNC-25", "DNC-M", "DNC-50", "DNC-75")
header <- c(header, "ACT-25", "ACT-M", "ACT-50", "ACT-75")
header <- c(header, "INS-25", "INS-M", "INS-50", "INS-75")
header <- c(header, "VAL-25", "VAL-M", "VAL-50", "VAL-75")
header <- c(header, "SPC-25", "SPC-M", "SPC-50", "SPC-75")
header <- c(header, "LIV-25", "LIV-M", "LIV-50", "LIV-75")
header <- c(header, "POP-25", "POP-M", "POP-50", "POP-75")
header <- c(header, "AGE-25", "AGE-M", "AGE-50", "AGE-75")

rvw_playlist <- function(df, summ, title) {
  # Summarize the current playlist when through
  title <- strsplit(title, ".")[1]
  summ <- c(title)
  # BPM
  summ <- c(summ, summary(df$BPM)[2:5])
  # Energy
  summ <- c(summ, summary(df$Energy)[2:5])
  # Dance
  summ <- c(summ, summary(df$Dance)[2:5])
  # Acoustic
  summ <- c(summ, summary(df$Acoustic)[2:5])
  # Instrumental
  summ <- c(summ, summary(df$Instrumental)[2:5])
  # Valence
  summ <- c(summ, summary(df$Valence)[2:5])
  # Speech
  summ <- c(summ, summary(df$Speech)[2:5])
  # Live
  summ <- c(summ, summary(df$Live)[2:5])
  # Popularity
  summ <- c(summ, summary(df$Popularity)[2:5])
  # Genre Counts
  genre_counts <- df %>%
    separate_rows(Genres, sep = ",") %>%
    mutate(Genres = str_trim(Genres)) %>%
    filter(Genres != "") %>%
    count(Genres, sort = TRUE)
  # Age
  df$age <- difftime(df$Albume.Date, "2040-01-01", units = "weeks")
  summ <- c(summ, summary(df$age)[2:5])
  
  return(summ)
}

# Set initial variables

getwd()
setwd(here("Playlists"))
playlists <- list.files()
songs <- data.frame()
playlist_summary <- data.frame(col.names=header)

for (playlist in playlists) { 
  df <- read.csv(here("playlists", playlist))
  df$old_list <- strsplit(playlist, ".", fixed = TRUE)[[1]][1]
  playlist_summary <- rbind(playlist_summary, rvw_playlist(df, playlist_summary, playlist))
  songs <- rbind(songs, df)
}
rm(playlist)

songs$tone <- sapply(strsplit(songs$Key, " ", fixed = TRUE), `[`, 2)
songs$key <- sapply(strsplit(songs$Key, " ", fixed = TRUE), `[`, 1)
songs$length <- as.integer(sapply(strsplit(songs$Duration, ":", fixed = TRUE), `[`, 1)) * 60 + as.integer(sapply(strsplit(songs$Duration, ":", fixed = TRUE), `[`, 2))
# songs$album_age <- # Get age of album
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

setwd(here())
write.csv(songs, here("songs-combined.csv"))


gower <- daisy(songs, metric = "gower")

set.seed(1024)
pam_fit <- pam(gower, diss = TRUE, k = 35)
# Get average 
# https://developer.spotify.com/documentation/web-api