rm(list = ls());gc();cat("\014")
library(dplyr);library(parallel);library(pbmcapply);library(XML);library(reshape2)

case_structure <- function(file){
  # cat(paste(file, "\n"))
  
  sak <- xmlToList(file)
  
  # Level: top
  versjon <- sak$versjon ; dokumentgruppe <- sak$dokumentgruppe ; ferdigbehandlet <- sak$ferdigbehandlet
  henvisning <- ifelse(is.null(sak$henvisning), NA, sak$henvisning) 
  id <- sak$id
  innstillingstekst <- ifelse(is.null(sak$innstillingstekst), NA, sak$innstillingstekst)
  korttitel <- sak$korttittel 
  kortvedtak <- ifelse(is.null(sak$kortvedtak), NA, sak$kortvedtak)
  parentestekst <- as.character(ifelse(sak$parentestekst == "true", NA, sak$parentestekst))
  sak_nummer <- sak$sak_nummer; sak_sesjon <- sak$sak_sesjon ; status <- sak$status
  tittel <- sak$tittel ; type <- sak$type ; vedtakstekst <- sak$vedtakstekst
  
  # Level: emne_liste
  emne_versjon <- emne_er_hovedemne <- hovedemne_id <- emne_id <- emne_navn <- underemne_liste <- character()
  if(is.null(sak$emne_liste)==FALSE){
    for(i in 1:length(sak$emne_liste)){
      emne_versjon <- c(emne_versjon, sak$emne_liste[[i]]$versjon)
      emne_er_hovedemne <- c(emne_er_hovedemne, sak$emne_liste[[i]]$er_hovedemne)
      hovedemne_id <- c(hovedemne_id, sak$emne_liste[[i]]$hovedemne_id)
      emne_id <- c(emne_id, sak$emne_liste[[i]]$id)
      emne_navn <- c(emne_navn, sak$emne_liste[[i]]$navn)
      underemne_liste <- c(underemne_liste, ifelse(is.null(sak$emne_liste[[i]]$underemne_liste), NA, sak$emne_liste[[i]]$underemne_liste))
      
  }
  } else {
    emne_versjon <- emne_er_hovedemne <- hovedemne_id <- emne_id <- emne_navn <- underemne_liste <- NA
  }
  emner <- apply(data.frame(emne_versjon, emne_er_hovedemne, hovedemne_id, emne_id, emne_navn, underemne_liste),
                 2, function(x) paste(x, collapse = " ; "))
  rm(emne_versjon, emne_er_hovedemne, hovedemne_id, emne_id, emne_navn, underemne_liste)
  
  # Level: komite
  if(sak$komite != "true"){
    komite_versjon <- sak$komite$versjon
    komite_id <- sak$komite$id
    komite_navn <- sak$komite$navn
  } else {
    komite_versjon <- NA
    komite_id <- NA
    komite_navn <- NA
  }
  
  
  # Level: publikasjon_referanse_liste
  prl_versjon <- prl_eksport_id <- prl_lenke_tekst <- prl_lenke_url <- prl_type <- prl_undertype <- character()
  for(i in 1:length(sak$publikasjon_referanse_liste)){
    prl_versjon <- c(prl_versjon, sak$publikasjon_referanse_liste[[i]]$versjon)
    prl_eksport_id <- c(prl_eksport_id, as.character(ifelse(sak$publikasjon_referanse_liste[[i]]$eksport_id == "true", NA, 
                                                            sak$publikasjon_referanse_liste[[i]]$eksport_id)))
    prl_lenke_tekst <- c(prl_lenke_tekst, sak$publikasjon_referanse_liste[[i]]$lenke_tekst)
    prl_lenke_url <- c(prl_lenke_url, sak$publikasjon_referanse_liste[[i]]$lenke_url)
    prl_type <- c(prl_type, sak$publikasjon_referanse_liste[[i]]$type)
    prl_undertype <- c(prl_undertype, sak$publikasjon_referanse_liste[[i]]$undertype)
  }
  prl <- apply(data.frame(prl_versjon, prl_eksport_id, prl_lenke_tekst, prl_lenke_url, prl_type, prl_undertype),
               2, function(x) paste(x, collapse = " ; "))
  rm(prl_versjon, prl_eksport_id, prl_lenke_tekst, prl_lenke_url, prl_type, prl_undertype)
  
  
  # Level: sak_opphav
  if(is.null(sak$sak_opphav$forslagstiller_liste)==FALSE){
    sak_opphav_rep_id <- character()
    for(i in 1:length(sak$sak_opphav$forslagstiller_liste)){
      sak_opphav_rep_id <- c(sak_opphav_rep_id, sak$sak_opphav$forslagstiller_liste[[i]]$id)
    }
  } else {
    sak_opphav_rep_id <- NA
  }
  sak_opphav_rep_id <- paste(sak_opphav_rep_id, collapse = " ; ")
  
  
  # Level: sak_relasjon_liste
  srl_versjon <- srl_relasjon_type <- srl_relatert_sak_id <- srl_relatert_sak_korttittel <- character()
  if(is.null(sak$sak_relasjon_liste)==FALSE){
    for(i in 1:length(sak$sak_relasjon_liste)){
      srl_versjon <- c(srl_versjon, sak$sak_relasjon_liste[[i]]$versjon)
      srl_relasjon_type <- c(srl_relasjon_type, sak$sak_relasjon_liste[[i]]$relasjon_type)
      srl_relatert_sak_id <- c(srl_relatert_sak_id, sak$sak_relasjon_liste[[i]]$relatert_sak_id)
      srl_relatert_sak_korttittel <- c(srl_relatert_sak_korttittel, sak$sak_relasjon_liste[[i]]$relatert_sak_korttittel)
    }
  } else {
    srl_versjon <- srl_relasjon_type <- srl_relatert_sak_id <- srl_relatert_sak_korttittel <- NA
  }
  srl <- apply(data.frame(srl_versjon, srl_relasjon_type, srl_relatert_sak_id, srl_relatert_sak_korttittel),
               2, function(x) paste(x, collapse = " ; "))
  rm(srl_versjon, srl_relasjon_type, srl_relatert_sak_id, srl_relatert_sak_korttittel)
  
  
  # Level: saksgang
  ssl_versjon <- ssl_id <- ssl_navn <- ssl_steg_nummer <- ssl_uaktuell <- character()
  for(i in 1:length(sak$saksgang$saksgang_steg_liste)){
    ssl_versjon <- c(ssl_versjon, sak$saksgang$saksgang_steg_liste[[i]]$versjon)
    ssl_id <- c(ssl_id, sak$saksgang$saksgang_steg_liste[[i]]$id)
    ssl_navn <- c(ssl_navn, sak$saksgang$saksgang_steg_liste[[i]]$navn)
    ssl_steg_nummer <- c(ssl_steg_nummer, sak$saksgang$saksgang_steg_liste[[i]]$steg_nummer)
    ssl_uaktuell <- c(ssl_uaktuell, sak$saksgang$saksgang_steg_liste[[i]]$uaktuell)
  }
  ssl <- apply(data.frame(ssl_versjon, ssl_id, ssl_navn, ssl_steg_nummer, ssl_uaktuell),
               2, function(x) paste(x, collapse = " ; "))
  rm(ssl_versjon, ssl_id, ssl_navn, ssl_steg_nummer, ssl_uaktuell)
  
  # Level: saksordfoerer_liste
  if(is.null(sak$saksordfoerer_liste)==FALSE){
    saksordfoerer_liste_rep_id <- character()
    for(i in 1:length(sak$saksordfoerer_liste)){
      saksordfoerer_liste_rep_id <- c(saksordfoerer_liste_rep_id, sak$saksordfoerer_liste[[i]]$id)
    }
  } else {
    saksordfoerer_liste_rep_id <- NA
  }
  saksordfoerer_liste_rep_id <- paste(saksordfoerer_liste_rep_id, collapse = " ; ")
  
  # Level: stikkord
  stikkord <- paste(sak$stikkord_liste, collapse = " ; ")
  
  data <- data.frame(versjon, dokumentgruppe, t(emner), ferdigbehandlet, henvisning, id, innstillingstekst,
                     dokumentgruppe, komite_versjon, komite_id, komite_navn, 
                     korttitel, kortvedtak, parentestekst, t(prl), sak_nummer, sak_opphav_rep_id, t(srl), 
                     sak_sesjon, t(ssl), saksordfoerer_liste_rep_id, status, stikkord, tittel, type, vedtakstekst)
  
  return(data)
  
}

files <- list.files("/media/martin/Data/saker_raw", full.names = TRUE, pattern = ".xml")
saker_detailed <- pbmclapply(rev(files), function(x) case_structure(x), mc.cores = 6)
saker_detailed <- do.call(rbind, saker_detailed)
write.csv(saker_detailed, file = "./Data/saker_detailed.csv")
