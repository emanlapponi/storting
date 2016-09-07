rm(list=ls());cat("\014");gc()
library(XML);library(reshape2)


getMoter <- function(file){
  moter <- xmlToList(file)
  versjon <- dagsorden_nummer <- fotnote <- fotnote <- id <- ikke_motedag_tekst <- character()
  kveldsmote <- merknad <- mote_dato_tid <- mote_rekkefolge <- character()
  mote_ting <- referat_id <- tilleggsdagsorden <- character()
  
  for(i in 1:length(moter[["moter_liste"]])){
    versjon <- c(versjon, moter[["moter_liste"]][[i]]$versjon)
    dagsorden_nummer <- c(dagsorden_nummer, moter[["moter_liste"]][[i]]$dagsorden_nummer)
    fotnote <- c(fotnote, ifelse(is.null(moter[["moter_liste"]][[i]]$fotnote)==TRUE, NA, moter[["moter_liste"]][[i]]$fotnote))
    id <- c(id, moter[["moter_liste"]][[i]]$id)
    ikke_motedag_tekst <- c(ikke_motedag_tekst, moter[["moter_liste"]][[i]]$ikke_motedag_tekst)
    kveldsmote <- c(kveldsmote, moter[["moter_liste"]][[i]]$kveldsmote)
    merknad <- c(merknad, moter[["moter_liste"]][[i]]$merknad)
    mote_dato_tid <- c(mote_dato_tid, moter[["moter_liste"]][[i]]$mote_dato_tid)
    mote_rekkefolge <- c(mote_rekkefolge, moter[["moter_liste"]][[i]]$mote_rekkefolge)
    mote_ting <- c(mote_ting, moter[["moter_liste"]][[i]]$mote_ting)
    referat_id <- c(referat_id, moter[["moter_liste"]][[i]]$referat_id)
    tilleggsdagsorden <- c(tilleggsdagsorden, moter[["moter_liste"]][[i]]$tilleggsdagsorden)
  }
  
  
  tmp <- data.frame(versjon, dagsorden_nummer, fotnote, id, ikke_motedag_tekst, kveldsmote, merknad, mote_dato_tid, mote_rekkefolge,
                    mote_ting, referat_id, tilleggsdagsorden)
  tmp[, 1:ncol(tmp)] <- apply(tmp[, 1:ncol(tmp)], 2, function(x) ifelse(x == "true" | x == "false", NA, x))
  tmp$parl_session <- unlist(stringr::str_extract_all(file, "[0-9]{4}\\-[0-9]{4}"))
  
  return(tmp)
}

allfiles <- list.files("./Data/moter/", pattern = "sesjon", full.names = TRUE)

moter <- lapply(allfiles, getMoter)
moter <- do.call("rbind", moter)
rm(allfiles, getMoter)
write.csv2(moter, "./Data/moter.csv", row.names = FALSE)

