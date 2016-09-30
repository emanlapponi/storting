rm(list = ls());gc();cat("\014")
library(dplyr);library(parallel);library(pbmcapply);library(XML);library(reshape2)

files <- list.files("./Data/questions/", full.names = TRUE, pattern = ".xml")
# files <- files[which(grepl("2015-2016", files))]

questions_df_list <- list()
for(x in 1:length(files)){
  
  question <- xmlToList(files[x])
  
  questions_df <- pbmclapply(1:length(question$sporsmal_liste), function(i){
    
    question_df <- data.frame(
      versjon = question$sporsmal_liste[[i]]$versjon,
      besvart_av_id = question$sporsmal_liste[[i]]$besvart_av$id,
      besvart_av_minister_id = question$sporsmal_liste[[i]]$besvart_av_minister_id,
      besvart_av_minister_tittel = question$sporsmal_liste[[i]]$besvart_av_minister_tittel,
      besvart_dato = question$sporsmal_liste[[i]]$besvart_dato,
      besvart_pa_vegne_av_id = as.character(ifelse(question$sporsmal_liste[[i]]$besvart_pa_vegne_av == "true", NA, 
                                   as.character(question$sporsmal_liste[[i]]$besvart_pa_vegne_av$id))[1]), 
      besvart_pa_vegne_av_minister_id = as.character(ifelse(question$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_id == "true", NA,
                                               question$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_id)),
      besvart_pa_vegne_av_minister_tittel = as.character(ifelse(question$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_tittel == "true",
                                                   NA, question$sporsmal_liste[[i]]$besvart_pa_vegne_av_minister_tittel)),
      datert_dato = question$sporsmal_liste[[i]]$datert_dato,
      emne_er_hovedemne = as.character(ifelse(is.null(question$sporsmal_liste[[i]]$emne_liste$emne$er_hovedemne) == TRUE, NA,
                                              question$sporsmal_liste[[i]]$emne_liste$emne$er_hovedemne)),
      emne_hovedemne_id = as.character(ifelse(is.null(question$sporsmal_liste[[i]]$emne_liste$emne$hovedemne_id) == TRUE, NA,
                                              question$sporsmal_liste[[i]]$emne_liste$emne$hovedemne_id)),
      emne_id = as.character(ifelse(is.null(question$sporsmal_liste[[i]]$emne_liste) == TRUE, NA,
                       question$sporsmal_liste[[i]]$emne_liste$emne$id)),
      emne_navn = as.character(ifelse(is.null(question$sporsmal_liste[[i]]$emne_liste$emne$navn) == TRUE, NA,
                                      question$sporsmal_liste[[i]]$emne_liste$emne$navn)),
      emne_underemne_liste = ifelse(is.null(question$sporsmal_liste[[i]]$emne_liste$emne$underemne_liste), NA,
                                    question$sporsmal_liste[[i]]$emne_liste$emne$underemne_liste),# NULL
      flyttet_til = question$sporsmal_liste[[i]]$flyttet_til,
      fremsatt_av_annen_id = as.character(ifelse(question$sporsmal_liste[[i]]$fremsatt_av_annen == "true", NA,
                                                     as.character(question$sporsmal_liste[[i]]$fremsatt_av_annen$id))[1]),
      sporsmal_id = question$sporsmal_liste[[i]]$id,
      rette_vedkommende_id = as.character(ifelse(question$sporsmal_liste[[i]]$rette_vedkommende == "true", NA,
                                                     as.character(question$sporsmal_liste[[i]]$rette_vedkommende$id))[1]),
      rette_vedkommende_minister_id = as.character(ifelse(question$sporsmal_liste[[i]]$rette_vedkommende_minister_id == "true", NA,
                                                          question$sporsmal_liste[[i]]$rette_vedkommende_minister_id)),
      rette_vedkommende_minister_tittel = as.character(ifelse(question$sporsmal_liste[[i]]$rette_vedkommende_minister_tittel == "true", NA,
                                                 question$sporsmal_liste[[i]]$rette_vedkommende_minister_tittel)),
      sendt_dato = question$sporsmal_liste[[i]]$sendt_dato,
      sesjon_id = question$sporsmal_liste[[i]]$sesjon_id,
      sporsmal_fra_id = question$sporsmal_liste[[i]]$sporsmal_fra$id,
      sporsmal_nummer = question$sporsmal_liste[[i]]$sporsmal_nummer,
      sporsmal_til_id = question$sporsmal_liste[[i]]$sporsmal_til$id,
      sporsmal_til_minister_id = question$sporsmal_liste[[i]]$sporsmal_til_minister_id,
      sporsmal_til_minister_tittel = question$sporsmal_liste[[i]]$sporsmal_til_minister_tittel,
      sporsmal_status = question$sporsmal_liste[[i]]$status,
      sporsmal_title = question$sporsmal_liste[[i]]$tittel,
      sporsmal_type = question$sporsmal_liste[[i]]$type,
      stringsAsFactors = FALSE)
    
    return(question_df)
  }, mc.cores = 6)
  
  questions_df_list[[x]] <- do.call(rbind, questions_df)
}  

questions_df_list[[19]] <- NULL # Remove this if 16/17 is implemented

questions_df <- do.call(rbind, questions_df_list)

write.csv(questions_df, file = "./Data/questions_detailed.csv", row.names = FALSE)


