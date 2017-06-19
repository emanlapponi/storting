library(xml2)
library(pbmcapply)

vote_nodes_to_text <- function(file){
  raw <- read_xml(file)
  if(grepl("<sak_votering>", xml_children(read_xml(file))[4]) == TRUE){
    
    tmp <- data.frame(case_id = xml_text(xml_find_all(raw, "//d1:sak_votering//d1:sak_id")),
                      dl_date = unique(as.Date(xml_text(xml_find_all(raw, "//d1:respons_dato_tid")))),
                      alt_vote = xml_text(xml_find_all(raw, "//d1:alternativ_votering_id")),
                      votes_for = xml_text(xml_find_all(raw, "//d1:antall_for")),
                      vote_absent = xml_text(xml_find_all(raw, "//d1:antall_ikke_tilstede")),
                      votes_against = xml_text(xml_find_all(raw, "//d1:antall_mot")),
                      vote_order = xml_text(xml_find_all(raw, "//d1:behandlingsrekkefoelge")),
                      vote_free = xml_text(xml_find_all(raw, "//d1:fri_votering")),
                      vote_comment = xml_text(xml_find_all(raw, "//d1:kommentar")),
                      vote_personal = xml_text(xml_find_all(raw, "//d1:personlig_votering")),
                      vote_president_id = xml_text(xml_find_all(raw, "//d1:president/d1:id")),
                      vote_passed = xml_text(xml_find_all(raw, "//d1:vedtatt")),
                      vote_id = xml_text(xml_find_all(raw, "//d1:votering_id")),
                      vote_method = xml_text(xml_find_all(raw, "//d1:votering_metode")),
                      vote_result_type = xml_text(xml_find_all(raw, "//d1:votering_resultat_type")),
                      vote_result_type_text = xml_text(xml_find_all(raw, "//d1:votering_resultat_type_tekst")),
                      vote_subject = xml_text(xml_find_all(raw, "//d1:votering_tema")),
                      vote_time = xml_text(xml_find_all(raw, "//d1:votering_tid")),
                      stringsAsFactors = FALSE)
    return(tmp)
  }
}

files <- list.files("./Data/votes", pattern = "voteringer", full.names = TRUE)

all <- pbmclapply(files, function(x) vote_nodes_to_text(x), mc.cores = detectCores()-2)

votes <- do.call(rbind, all)

write.csv(votes, file = "./Data/votes.csv", row.names = FALSE)
