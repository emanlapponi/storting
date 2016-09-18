getReps <- function(file){
  reps <- xmlToList(file)
  versjon <- doedsdato <- etternavn <- foedselsdato <- character()
  fornavn <- id <- kjoenn <- fylke_versjon <- fylke_id <- fylke_navn <- character()
  parti_versjon <- parti_id <- parti_navn <-mote_ting <- referat_id <- tilleggsdagsorden <- character()
  
  for(i in 1:length(reps[["representanter_liste"]])){
    versjon <- c(versjon, reps[["representanter_liste"]][[i]]$versjon)
    doedsdato <- c(doedsdato, reps[["representanter_liste"]][[i]]$doedsdato)
    etternavn <- c(etternavn, reps[["representanter_liste"]][[i]]$etternavn)
    foedselsdato <- c(foedselsdato, reps[["representanter_liste"]][[i]]$foedselsdato)
    fornavn <- c(fornavn, reps[["representanter_liste"]][[i]]$fornavn)
    id <- c(id, reps[["representanter_liste"]][[i]]$id)
    kjoenn <- c(kjoenn, reps[["representanter_liste"]][[i]]$kjoenn)
    fylke_versjon <- c(fylke_versjon, reps[["representanter_liste"]][[i]]$fylke$versjon)
    fylke_id <- c(fylke_id, reps[["representanter_liste"]][[i]]$fylke$id)
    fylke_navn <- c(fylke_navn, reps[["representanter_liste"]][[i]]$fylke$navn)
    parti_versjon <- c(parti_versjon, reps[["representanter_liste"]][[i]]$parti$versjon)
    parti_id <- c(parti_id, reps[["representanter_liste"]][[i]]$parti$id)
    parti_navn <- c(parti_navn, reps[["representanter_liste"]][[i]]$parti$navn)
    
  }
  
  
  tmp <- data.frame(versjon, doedsdato, etternavn, foedselsdato, fornavn, id, kjoenn, fylke_versjon, fylke_id, fylke_navn,
                    parti_versjon, parti_id, parti_navn, stringsAsFactors = FALSE)
  tmp$parl_period <- unlist(stringr::str_extract_all(file, "[0-9]{4}\\-[0-9]{4}"))
  
  return(tmp)
}

allfiles <- list.files("./Data/reps", pattern = ".xml", full.names = TRUE)

reps <- lapply(allfiles, getReps)

reps <- do.call("rbind", reps)



rownames(reps) <- 1:nrow(reps)
colnames(reps) <- c("version", "death", "last_name", "birth", "first_name", "id", "gender", "fylke_version", "fylke_id",
                    "fylke_name", "party_version", "party_id", "party_name", "parl_period")

reps <- reps[, c("last_name", "first_name", "id", "parl_period", "party_name", "party_id", "gender", "birth", "death",
                   "fylke_name", "fylke_id", "version", "party_version", "fylke_version")]

reps$cabinet_short <- NA
reps_9701Bondevik <- reps[which(reps$parl_period == "1997-2001"), ]
reps_9701Bondevik$cabinet_short <- "Bondevik I"
reps_9701BStoltenberg <- reps[which(reps$parl_period == "1997-2001"), ]
reps_9701BStoltenberg$cabinet_short <- "Stoltenberg I"

reps <- rbind(reps_9701Bondevik, reps_9701BStoltenberg, reps[which(reps$parl_period != "1997-2001"), ])

reps$cabinet_short <- ifelse(reps$parl_period == "2001-2005", "Bondevik II", reps$cabinet_short)
reps$cabinet_short <- ifelse(reps$parl_period == "2005-2009", "Stoltenberg II", reps$cabinet_short)
reps$cabinet_short <- ifelse(reps$parl_period == "2009-2013", "Stoltenberg III", reps$cabinet_short)
reps$cabinet_short <- ifelse(reps$parl_period == "2013-2017", "Solberg I", reps$cabinet_short)



rm(allfiles, reps_9701Bondevik, reps_9701BStoltenberg, getReps)
