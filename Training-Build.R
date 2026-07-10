library(tidyverse)
library(cluster)
library(factoextra)
library(lubridate)
library(here)
library(httr)
library(jsonlite)

# Define Functions

rvw_playlist <- function(df, summ) {
  # Summarize the current playlist when through
  summary(df)
  return(summ)
}

# Set initial variables

getwd()
setwd(here("Playlists"))
playlists <- list.files()
songs <- data.frame()
playlist_summary <- data.frame()

for (playlist in playlists) { 
  df <- read.csv(here("playlists", playlist))
  df$old_list <- strsplit(playlist, ".", fixed = TRUE)[[1]][1]
  playlist_summary <- rvw_playlist(df, playlist_summary)
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