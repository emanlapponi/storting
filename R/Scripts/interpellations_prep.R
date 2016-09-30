rm(list = ls());gc();cat("\014")
library(dplyr);library(parallel);library(pbmcapply);library(XML);library(reshape2)

files <- list.files("./Data/interpellations", full.names = TRUE, pattern = ".xml")
# files <- files[which(grepl("2000-2001", files))]
interpellations_df_list <- list()

for(x in 1:length(files)){
  
  interpellations <- xmlToList(files[x])

  
  interpellations_df <- pbmclapply(1:length(interpellations$sporsmal_liste), function(i){
    interpellations_df <- data.frame(
      versjon = interpellations$sporsmal_liste[[i]]$versjon,
      besvart_av_id = interpellations$sporsmal_liste[[i]]$besvart_av$id,
      besvart_av_minister_id = interpellations$sporsmal_liste[[i]]$besvart_av_minister_id,
      besvart_av_minister_tittel = interpellations$sporsmal_liste[[i]]$besvart_av_minister_tittel,
      besvart_dato = interpellations$sporsmal_liste[[i]]$besvart_dato,
      besvart_pa_vegne_av_id = as.character(ifelse(interpellations$sporsmal_liste[[i]]$besvart_pa_vegne_av == "true", NA,
                                                   as.character(interpellations$sporsmal_liste[[i]]$besvart_pa_vegne_av$id))[i]),
      besvart_pa_vegne_av_minister_id = as.character(ifelse(interpellations$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_id == "true", NA,
                                                            as.character(interpellations$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_id))),
      besvart_pa_vegne_av_minister_tittel = as.character(ifelse(interpellations$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_tittel == "true", NA,
                                                                as.character(interpellations$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_tittel))),
      datert_dato = interpellations$sporsmal_liste[[i]]$datert_dato,
      emne_er_hovedemne = interpellations$sporsmal_liste[[i]]$emne_liste$emne$er_hovedemne,
      emne_hovedemne_id = interpellations$sporsmal_liste[[i]]$emne_liste$emne$hovedemne_id,
      emne_id = interpellations$sporsmal_liste[[i]]$emne_liste$emne$id,
      emne_navn = interpellations$sporsmal_liste[[i]]$emne_liste$emne$navn,
      emne_underemne_liste = as.character(ifelse(is.null(interpellations$sporsmal_liste[[i]]$emne_liste$emne$underemne_liste)==TRUE, NA,
                                                 interpellations$sporsmal_liste[[i]]$emne_liste$emne$underemne_liste)),
      flyttet_til = interpellations$sporsmal_liste[[i]]$flyttet_til,
      fremsatt_av_annen_id = as.character(ifelse(interpellations$sporsmal_liste[[i]]$fremsatt_av_annen == "true", NA,
                                              interpellations$sporsmal_liste[[i]]$fremsatt_av_annen$id)),
      sporsmal_id = interpellations$sporsmal_liste[[i]]$id,
      rette_vedkommende_id = as.character(ifelse(interpellations$sporsmal_liste[[i]]$rette_vedkommende == "true", NA,
                                              interpellations$sporsmal_liste[[i]]$rette_vedkommende$id)[1]), # nil
      rette_vedkommende_minister_id = as.character(ifelse(interpellations$sporsmal_liste[[i]]$rette_vedkommende_minister_id == "true", NA,
                                                          interpellations$sporsmal_liste[[i]]$rette_vedkommende_minister_id)),
      rette_vedkommende_minister_tittel = as.character(ifelse(interpellations$sporsmal_liste[[i]]$rette_vedkommende_minister_tittel == "true", NA,
                                                              interpellations$sporsmal_liste[[i]]$rette_vedkommende_minister_tittel)),
      sendt_dato = interpellations$sporsmal_liste[[i]]$sendt_dato,
      sesjon_id = interpellations$sporsmal_liste[[i]]$sesjon_id,
      sporsmal_fra_id = interpellations$sporsmal_liste[[i]]$sporsmal_fra$id,
      sporsmal_nummer = interpellations$sporsmal_liste[[i]]$sporsmal_nummer,
      sporsmal_til_id = interpellations$sporsmal_liste[[i]]$sporsmal_til$id,
      sporsmal_til_minister_id = interpellations$sporsmal_liste[[i]]$sporsmal_til_minister_id,
      sporsmal_til_minister_tittel = interpellations$sporsmal_liste[[i]]$sporsmal_til_minister_tittel,
      sporsmal_status = interpellations$sporsmal_liste[[i]]$status,
      sporsmal_title = interpellations$sporsmal_liste[[i]]$tittel,
      sporsmal_type = interpellations$sporsmal_liste[[i]]$type,
      stringsAsFactors = FALSE)
    return(interpellations_df)
  }, mc.cores = 6)
  
  interpellations_df_list[[x]] <- do.call(rbind, interpellations_df)
}

interpellations_df_list[[19]] <- NULL
interpellations_df <- do.call(rbind, interpellations_df_list)


write.csv(interpellations_df, file = "./Data/interpellations_detailed.csv", row.names = FALSE)

