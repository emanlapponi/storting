rm(list = ls())
library(xml2)
library(pbmcapply)

vote_nodes_to_text <- function(file){
  raw <- read_xml(file)
  
  vote_id <- xml_text(xml_find_all(raw, "//d1:votering_id"))
  dl_date <- paste(unique(as.Date(xml_text(xml_find_all(raw, "//d1:respons_dato_tid")))), collapse = " // ")
  
  if(identical(xml_text(xml_find_all(raw, "//d1:representant/d1:id")), character())){
    vote_rep_id <- NA
  } else {
    vote_rep_id <- xml_text(xml_find_all(raw, "//d1:representant/d1:id"))
  }
  
  if(identical(xml_text(xml_find_all(raw, "//d1:representant_voteringsresultat/d1:votering")), character())){
    vote <- NA
  } else {
    vote <- xml_text(xml_find_all(raw, "//d1:representant_voteringsresultat/d1:votering"))
  }
  
  
  if(identical(xml_text(xml_find_all(raw, "//d1:fast_vara_for")), character())){
    vote_insteadof_rep_id <- NA
  } else {
    vote_insteadof_rep_id <- ifelse(xml_text(xml_find_all(raw, "//d1:fast_vara_for")) == "", NA,
                                    xml_text(xml_find_all(raw, "//d1:fast_vara_for//d1:id")))
  }
  
  tmp <- data.frame(vote_id, dl_date, vote_rep_id, vote, vote_insteadof_rep_id,
                    stringsAsFactors = FALSE)
  
  return(tmp)
}

files <- list.files("./Data/votes_detailed/", pattern = "voterings", full.names = TRUE)

all <- pbmclapply(files, function(x) vote_nodes_to_text(x), mc.cores = detectCores()-2)

votes_detailed <- do.call(rbind, all)

# All should be 169 or 1...I think -- but they aren't
# table(factor(data.frame(votes_detailed %>% group_by(vote_id) %>% summarize(length(vote_id)))[, 2]))

votes <- read.csv("./Data/votes.csv")

votes_detailed <- merge(x = votes_detailed[, c("vote_id", "vote_rep_id", "vote", "vote_insteadof_rep_id")], y = votes, by = "vote_id", all.x = TRUE)

write.csv(votes_detailed, "./Data/votes_detailed.csv")
