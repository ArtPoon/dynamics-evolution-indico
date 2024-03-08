require(jsonlite)

#dne <- read_json("~/Desktop/final-abstracts.json")
dne <- read_json("~/Desktop/dynamics2024/abstracts.json", 
                 simplifyVector = T)
abstracts <- dne$abstracts

tracks <- sapply(abstracts$reviewed_for_tracks, function(x) x$title[1])

boxplot(split(abstracts$score, tracks), cex.axis=1.2)

require(beeswarm)
pdf(file="~/Desktop/test.pdf", width=5, height=5)
par(mar=c(3, 12, 1, 1), cex=1)
beeswarm(split(abstracts$score, tracks), spacing=0.5, pch=19, cex=0.8, las=2,
         horizontal=T, cex.axis=1.2)
dev.off()

# exclude withdrawn abstracts
#is.withdrawn <- sapply(abstracts, function(x) x$state=="withdrawn")
abstracts <- abstracts[abstracts$state!="withdrawn", ]

reviews <- abstracts$reviews[[1]]
for (i in 2:nrow(abstracts)) {
  reviews <- rbind(reviews, abstracts$reviews[[i]])
}

# get review data
reviews <- data.frame(
  id = sapply(abstracts, function(x) x$friendly_id),
  title = sapply(abstracts, function(x) x$title),
  track = sapply(abstracts, function(x) x$reviewed_for_tracks[[1]]$title),
  score = sapply(abstracts, function(x) x$score)
)

reviews$r1.act <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 0) {
    x$reviews[[1]]$proposed_action
    } else { NA }})
reviews$r1.score <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 0) {
    x$reviews[[1]]$ratings[[1]]$value
  } else { NA }})
reviews$r1.type <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 0 && !is.null(x$reviews[[1]]$proposed_contrib_type)) {
    x$reviews[[1]]$proposed_contrib_type$name
  } else { NA }})
reviews$r1.comment <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 0) {
    x$reviews[[1]]$comment
  } else { NA }})

reviews$r2.act <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 1) {
    x$reviews[[2]]$proposed_action
  } else { NA }})
reviews$r2.score <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 1) {
    x$reviews[[2]]$ratings[[1]]$value
  } else { NA }})
reviews$r2.type <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 1 && !is.null(x$reviews[[2]]$proposed_contrib_type)) {
    x$reviews[[2]]$proposed_contrib_type$name
  } else { NA }})
reviews$r2.comment <- sapply(abstracts, function(x) {
  if(length(x$reviews) > 1) {
    x$reviews[[2]]$comment
  } else { NA }})


write.csv(reviews, file="~/Desktop/dynamics2024/reviews.csv")

#############################################

n.abstracts <- length(dne$abstracts)
n.tracks <- sapply(dne$abstracts, function(x) 
  length(x$reviewed_for_tracks))

tracks <- sapply(dne$abstracts, function(x) {
  sapply(x$reviewed_for_tracks, function(y) y$title)
  })

# construct a table
abstracts <- data.frame(
  id = sapply(dne$abstracts, function(x) x$friendly_id),
  title = sapply(dne$abstracts, function(x) x$title),
  n.authors = sapply(dne$abstracts, function(x) length(x$persons)),
  n.tracks = sapply(tracks, length),
  track.geno = grepl("Genomics", tracks),
  track.clus = grepl("Transmission", tracks),
  track.zoo = grepl("Zoonoses", tracks),
  track.phy = grepl("Phylo", tracks),
  track.imm = grepl("Vaccines", tracks),
  track.host = grepl("Within", tracks),
  track.code = grepl("Software", tracks)
)
abstracts$curator <- NULL
abstracts$curator[abstracts$n.tracks > 1] <- 
  rep(c("Jeff", "Art"), length.out=sum(abstracts$n.tracks > 1))

write.csv(abstracts, "~/Desktop/dne-abstracts.csv")

labels <- unique(unlist(tracks))[c(4,1,2,3,5,6,7)]

par(mar=c(5,10,1,1))
barplot(apply(abstracts[abstracts$n.tracks==1, 5:11], 2, sum), 
        horiz=TRUE, las=1, col=hcl.colors(n=7))
        #names.arg = labels, cex.names=0.8)


