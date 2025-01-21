# This is a little script for parsing the JSON that can be exported from the 
# table of submitted abstracts in Indico, e.g., 
# https://dynamicsevolution.org/event/5/manage/abstracts/list/
# Note this requires admin privileges to access.

require(jsonlite)
json <- read_json("~/Downloads/abstracts.json", simplifyVector = T)
abstracts <- json$abstracts

# extract fields from abstracts table 
temp <- abstracts[c('friendly_id', 'title', 'state', 'submission_comment')]
temp$sub.type <- abstracts$submitted_contrib_type$name  # Oral, Poster, Either
temp$sub.tracks <- sapply(abstracts$submitted_for_tracks, function(x) {
  paste(x$title, collapse=" / ")  # some abstracts request multiple tracks
})
temp$authors <- sapply(abstracts$persons, function(x) {
  paste(paste(x$first_name, x$last_name), collapse=", ")
})

write.csv(temp, file="~/Downloads/abstracts.csv", quote=T)
