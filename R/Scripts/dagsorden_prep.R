rm(list=ls());cat("\014");gc()
library(XML);library(reshape2)

# file <- "./Data/dagsorden/dagsorden?moteid=9896"

getDagsorden <- function(file){

  dagsorden <- xmlToList(file)
  versjon <- dagsordensak_henvisning <- dagsordensak_nummer <- dagsordensak_tekst <- dagsordensak_type <- character()
  fotnote <- innstilling_id <- komite_id <- loseforslag <- sak_id <- character()
  sporretime_type <- sporsmal_id <- character()
  
  for(i in 1:length(dagsorden[["dagsordensak_liste"]])){
    versjon <- c(versjon, dagsorden[["dagsordensak_liste"]][[i]]$versjon)
    dagsordensak_henvisning <- c(dagsordensak_henvisning, dagsorden[["dagsordensak_liste"]][[i]]$dagsordensak_henvisning)
    dagsordensak_nummer <- c(dagsordensak_nummer, dagsorden[["dagsordensak_liste"]][[i]]$dagsordensak_nummer)
    dagsordensak_tekst <- c(dagsordensak_tekst, dagsorden[["dagsordensak_liste"]][[i]]$dagsordensak_tekst)
    dagsordensak_type <- c(dagsordensak_type, dagsorden[["dagsordensak_liste"]][[i]]$dagsordensak_type)
    fotnote <- c(fotnote, ifelse(is.null(dagsorden[["dagsordensak_liste"]][[i]]$fotnote)==TRUE, NA, dagsorden[["dagsordensak_liste"]][[i]]$fotnote))
    innstilling_id <- c(innstilling_id, dagsorden[["dagsordensak_liste"]][[i]]$innstilling_id)
    komite_id <- c(komite_id, dagsorden[["dagsordensak_liste"]][[i]]$komite_id)
    loseforslag <- c(loseforslag, dagsorden[["dagsordensak_liste"]][[i]]$loseforslag)
    sak_id <- c(sak_id, dagsorden[["dagsordensak_liste"]][[i]]$sak_id)
    sporretime_type <- c(sporretime_type, dagsorden[["dagsordensak_liste"]][[i]]$sporretime_type)
    sporsmal_id <- c(sporsmal_id, dagsorden[["dagsordensak_liste"]][[i]]$sporsmal_id)
  }
  
  if(is.null(dagsorden[["dagsordensak_liste"]])==FALSE){
    tmp <- data.frame(versjon, dagsordensak_henvisning, dagsordensak_nummer, dagsordensak_tekst, dagsordensak_type, 
                      fotnote, innstilling_id, komite_id, loseforslag, sak_id, sporretime_type, sporsmal_id)
    tmp$dagsorden_nummer <- dagsorden[["dagsorden_nummer"]]
    tmp$mote_dato_tid <- dagsorden[["mote_dato_tid"]]
    tmp$mote_id <- dagsorden[["mote_id"]]
    tmp$mote_ting <- dagsorden[["mote_ting"]]
    tmp[, 1:ncol(tmp)] <- apply(tmp[, 1:ncol(tmp)], 2, function(x) ifelse(x == "true" | x == "false" | x == "-1", NA, x))
  } else {
    tmp <- data.frame(versjon = NA, dagsordensak_henvisning = NA, dagsordensak_nummer = NA, dagsordensak_tekst = NA, dagsordensak_type = NA, 
                      fotnote = NA, innstilling_id = NA, komite_id = NA, loseforslag = NA, sak_id = NA, sporretime_type = NA, sporsmal_id = NA)
    tmp$dagsorden_nummer <- dagsorden[["dagsorden_nummer"]]
    tmp$mote_dato_tid <- dagsorden[["mote_dato_tid"]]
    tmp$mote_id <- dagsorden[["mote_id"]]
    tmp$mote_ting <- dagsorden[["mote_ting"]]
    # tmp[, 1:ncol(tmp)] <- apply(tmp[, 1:ncol(tmp)], 2, function(x) ifelse(x == "true" | x == "false" | x == "-1", NA, x))
    }
  
  
  return(tmp)
}

allfiles <- list.files("./Data/dagsorden", pattern = "moteid", full.names = TRUE)

dagsorden <- lapply(allfiles, getDagsorden)

dagsorden <- do.call("rbind", dagsorden)

rm(allfiles, getDagsorden)
write.csv2(dagsorden, "./Data/dagsorden.csv", row.names = FALSE)


