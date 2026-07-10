library(httr)
library(httr2)
library(xml2)
library(dplyr)

# source <- "https://musicbrainz.org/ws/2/"
# field <- ""
# search_value <- ""
# url <- ""
# ua <- user_agent("Educational-Project/1.0 ( dmcough1024@gmail.com )")
# response <- GET(paste0(source, "artist"), query = list(query = "The Beatles"), ua)

#### Function for final files: ####

artist_lookup <- function(qry) {
  source <- "https://musicbrainz.org/ws/2/artist"
  ua <- user_agent("Educational-Project/1.0 ( dmcough1024@gmail.com )")
  response <- GET(source, query = list(query = qry), ua)
  
  if (status_code(response) != 200) {
    sys.sleep(1)
    response <- GET(source, query = list(query = qry), ua)
    if (status_code(response != 200)) {
      print(paste0(status_code(response),": Unsuccessful GET"))
      return(0)
    }
  } else {

    raw_text <- content(response, as = "text", encoding = "UTF-8")
    doc <- read_xml(charToRaw(raw_text))
    xml_ns_strip(doc)
    artists <- xml_find_all(doc, ".//artist")[1]
    
    artist_results <- tibble(
      id        = xml_attr(artists, "id"),
      type      = xml_attr(artists, "type"),
      name      = xml_text(xml_find_first(artists, ".//name")),
      tags       = sapply(artists, function(art_node) {
        tag_names <- xml_text(xml_find_all(art_node, ".//tag-list/tag/name"))
        if (length(tag_names) == 0) return(NA_character_)
        paste(tag_names, collapse = ", ")
      }),    
      genres       = sapply(artists, function(art_node) {
        genre_names <- xml_text(xml_find_all(art_node, ".//genre-list/genre/name"))
        if (length(genre_names) == 0) return(NA_character_)
        paste(genre_names, collapse = ", ")
      })
    )
    
    # View your extracted data
    print(artist_results)
  }
  
}
