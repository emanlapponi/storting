# Loading data ######
dagsorden <- read.csv2("./Data/dagsorden.csv", stringsAsFactors = FALSE)
saker_meta <- read.csv("./Data/saker_meta_raw.csv", stringsAsFactors = FALSE)
saker_detailed <- read.csv("./Data/saker_detailed.csv", stringsAsFactors = FALSE)
questions_detailed <- read.csv("./Data/questions_detailed.csv", stringsAsFactors = FALSE)
interpellations_detailed <- read.csv("./Data/interpellations_detailed.csv", stringsAsFactors = FALSE)
allquestions <- rbind(questions_detailed, interpellations_detailed)
rm(questions_detailed, interpellations_detailed)
# moter <- read.csv2("./Data/moter.csv", stringsAsFactors = FALSE)
# taler <- read.csv("../../taler/tale.2016-04-20.csv")
##################

# Fixing saker_meta
saker_meta$sak_file <- saker_meta$viewport <- saker_meta$DC.Publisher <- saker_meta$DC.Language <- NULL
saker_meta$og.url <- saker_meta$og.title <- saker_meta$og.locale <- saker_meta$og.type <- saker_meta$Content.Type <- NULL
saker_meta$og.image <- saker_meta$og.image.secure_url <- saker_meta$og.site_name <- saker_meta$og. <- NULL
saker_meta$DC.Title <- saker_meta$MA.Unique.Id <- saker_meta$MA.Pdf.url <- saker_meta$MA.Case.type <- NULL
saker_meta$MA.Case.id <- NULL

saker_meta$DC.Type <- tolower(saker_meta$DC.Type)
saker_meta$DC.Type <- ifelse(grepl("^referat", saker_meta$DC.Type) == TRUE, "referatsaker", saker_meta$DC.Type)
saker_meta$DC.Type <- ifelse(grepl("^sporretime$|^spørretimespørsmål$", saker_meta$DC.Type) == TRUE, "ordinarsporretime", saker_meta$DC.Type)
saker_meta$DC.Type <- ifelse(grepl("votering", saker_meta$DC.Type) == TRUE, "voteringer", saker_meta$DC.Type)
saker_meta$DC.Description <- ifelse(saker_meta$DC.Type == "muntligsporretime", "Muntlig spørretime",
                                    ifelse(saker_meta$DC.Type == "ordinarsporretime", "Ordinær spørretime", saker_meta$DC.Description))
saker_meta$saker_meta_id <- paste0("saker_", id(saker_meta[, c("date", "DC.Description")]))

# Merging questions to dagsorden
allquestions <- allquestions[which(duplicated(allquestions$sporsmal_id) == FALSE), ]
dagsorden <- merge(x = dagsorden, y = allquestions, by = "sporsmal_id", all.x = TRUE)

dagsorden <- dagsorden[which(dagsorden$mote_ting == "storting"), ]
dagsorden$date <- as.Date(dagsorden$mote_dato_tid)
dagsorden$dagsordensak_tekst <- ifelse(dagsorden$dagsordensak_type == "SpTim", "Ordinær spørretime",
                                       ifelse(dagsorden$dagsordensak_type == "MSpTim", "Muntlig spørretime",
                                              dagsorden$dagsordensak_tekst))
dagsorden <- arrange(dagsorden, date, dagsordensak_nummer)
dagsorden$dagsorden_id <- paste0("dagsorden_", 1:nrow(dagsorden))


innstillinger <- dagsorden[which(grepl("Innst.|INT|FORO|DOK8", dagsorden$dagsordensak_type)), ]
innstillinger$dagsordensak_tekst <- gsub("\\s{2,}", " ", gsub("<.*?>", " ", innstillinger$dagsordensak_tekst))

unique_saker_meta <- saker_meta %>%
  group_by(date, DC.Description) %>%
  summarise(paste(unique(DC.Type), collapse = "|"),
            saker_meta_id = unique(saker_meta_id)) %>%
  filter(DC.Description != "")

# unique_saker_meta$saker_meta_id <- paste0("unique_", 1:nrow(unique_saker_meta))


matcher <- pbmclapply(1:nrow(innstillinger), function(i) { #### 
  rows <- which(as.character(innstillinger$date[i]) == as.character(unique_saker_meta$date))
  if(innstillinger$dagsordensak_type[i] == "INT"){
    match <- agrepl(innstillinger$dagsordensak_tekst[i], sapply(strsplit(unique_saker_meta$DC.Description[rows], ":"), "[[", 1), 5)
  } else {
    match <- agrepl(innstillinger$dagsordensak_tekst[i], unique_saker_meta$DC.Description[rows], 5)
  }
  
  saker_meta_id <- unique_saker_meta$saker_meta_id[rows]
  saker_meta_id <- saker_meta_id[match]
  
  tmp <- 
    c(unique(na.omit(ifelse(match==TRUE, innstillinger$dagsorden_id[i], NA))),
      innstillinger$dagsordensak_tekst[i], 
      as.character(innstillinger$date[i]), paste(saker_meta_id, collapse = "|"))
  if(length(tmp)==3){
    tmp <- c(NA, tmp)
  }
  return(tmp)
}, mc.cores = 6)

matcher <- data.frame(do.call(rbind, matcher), stringsAsFactors = FALSE)
names(matcher) <- c("dagsorden_id", "dagsordensak_tekst", "date", "saker_meta_id")
matcher$saker_meta_id <- ifelse(matcher$saker_meta_id == "", NA, matcher$saker_meta_id)

tale_sak <- merge(x = saker_meta, y = matcher[, c("saker_meta_id", "dagsorden_id")], by = "saker_meta_id", all.x = TRUE)
tale_sak <- tale_sak[which(duplicated(tale_sak$id)==FALSE), ]
tale_sak <- arrange(tale_sak, date, transcript, order)

dagsorden$date <- NULL

tale_sak <- merge(x = tale_sak, y = dagsorden, by = "dagsorden_id", all.x = TRUE)
tale_sak <- arrange(tale_sak, date, transcript, order)
# hm <- tale_sak[which(is.na(tale_sak$mote_id) & grepl("saksref", tale_sak$DC.Type)), ]

tale_sak <- tale_sak[, c("id", "TITLE", "DC.Type", "DC.Identifier", "KEYWORDS", "DC.Subject", "dagsordensak_henvisning",
                         "dagsordensak_nummer", "dagsordensak_tekst", "dagsordensak_type", "innstilling_id", "komite_id", "sak_id",
                         "sporsmal_id", "sporsmal_nummer", "sporsmal_type", "sporsmal_title", 
                         "sporsmal_fra_id" , "besvart_av_id", "sporsmal_til_id",
                         "besvart_av_minister_id", "besvart_av_minister_tittel", "besvart_pa_vegne_av_id", "emne_navn",
                         "dagsorden_nummer", "mote_id")]


tale_sak$DC.Identifier <- gsub("https://www.stortinget.no/no/", "", tale_sak$DC.Identifier)

saker_detailed$komite_id <- NULL
dagsorden$emne_id <- dagsorden$emne_er_hovedemne <- dagsorden$emne_navn <- NULL

saker <- merge(x = dagsorden, y = saker_detailed, by.x = "sak_id", by.y = "id", all.x = TRUE)
saker <- saker[which(is.na(saker$dagsordensak_nummer) == FALSE), 
               c("sak_id", "sak_sesjon", "dagsordensak_henvisning", "dagsordensak_nummer", "dagsordensak_tekst", "dagsordensak_type",
                 "innstilling_id", "komite_id", "komite_navn", "sporretime_type", "sporsmal_id", "dagsorden_nummer", "mote_dato_tid",
                 "mote_id", "mote_ting", "dokumentgruppe", "emne_id", "emne_navn", "emne_er_hovedemne", "hovedemne_id",
                 "ferdigbehandlet", "henvisning", "innstillingstekst", "korttitel", "kortvedtak", "parentestekst",
                 "prl_eksport_id", "prl_lenke_tekst", "prl_lenke_url", "prl_type", "prl_undertype", "sak_nummer",
                 "sak_opphav_rep_id", "srl_relasjon_type", "srl_relatert_sak_id", "srl_relatert_sak_korttittel",
                 "ssl_id", "ssl_navn", "ssl_steg_nummer", "ssl_uaktuell", "saksordfoerer_liste_rep_id", "status",
                 "stikkord", "tittel", "type", "vedtakstekst")]


ref_url <- lapply(strsplit(saker$prl_lenke_url, " ; "), function(x) x[which(grepl("Publikasjoner/Referater/Stortinget", x))])
ref_url <- lapply(1:length(ref_url), function(x) c(ref_url[[x]],
                                                   paste(as.character(format(as.Date(saker$mote_dato_tid[x]), "%y%m%d")),
                                                         saker$dagsordensak_nummer[x], "+", sep = "/")))
ref_url <- lapply(1:length(ref_url), function(x) ref_url[[x]][which(grepl(ref_url[[x]][length(ref_url[[x]])], ref_url[[x]]))])
saker$ref_url <- sapply(ref_url, function(x) paste(x, collapse = " ; "))

saker$ref_url <- gsub("^[0-9]+\\/[0-9]+\\/\\+$", NA, saker$ref_url)
saker$ref_url[which(duplicated(saker$ref_url) & (is.na(saker$ref_url)==FALSE))] <- sapply(strsplit(saker$prl_lenke_url[which(duplicated(saker$ref_url) & (is.na(saker$ref_url)==FALSE))], " ; "), "[[", 2)

saker$ref_url <- gsub(" ; [0-9]+\\/[0-9]+\\/\\+$", "", saker$ref_url)
saker$ref_url <- gsub("//www.stortinget.no/no/", "", saker$ref_url)


######
# QUESTIONS CAN BE PREPPED HERE
#####


case_data <- merge(x = tale_sak[, setdiff(names(tale_sak), names(saker))], by.x = "DC.Identifier", 
                   y = saker[which(is.na(saker$ref_url) == FALSE), ], by.y = "ref_url", all.x = TRUE)

rm(dagsorden, innstillinger, matcher, saker, saker_meta, unique_saker_meta, saker_detailed, tale_sak, ref_url, allquestions)
# write.csv(moredata, file = "./Data/wrapup_saker.csv")

