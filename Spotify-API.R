library(spotifyr)
library(tidyverse)

library(httr)
library(httr2)
library(xml2)
library(dplyr)

Sys.setenv(SPOTIFY_CLIENT_ID = '48f2251bb3044e63bb3ec187d04d7f4e')
Sys.setenv(SPOTIFY_CLIENT_SECRET = '09dd5106f5be4616959de5d548655a31')
Sys.setenv(SPOTIFY_REDIRECT_URI = 'http://127.0.0.1:1410/')

access_token <- get_spotify_access_token()

get_user_playlists(user_id = 'e9e44b26f1e849bb', limit = 2, include_meta_info = TRUE)
get_user_playlists(user_id = 'dannyboy1024-96', limit = 2, include_meta_info = TRUE)

map_these <- get_playlist_tracks('1NWh4ZssHn3sDfGSwQ1uAZ', authorization = access_token, include_meta_info = TRUE)