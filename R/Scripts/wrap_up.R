rm(list = ls());cat("\014");gc()
# install.packages("./Data/uacd/uacd_0.14.tar.gz", repos = NULL)
library(stringr);library(dplyr);library(rvest)
library(parallel);library(zoo);library(gsubfn);library(XML)
library(reshape2); library(pbmcapply)

ncores <- detectCores()-1

# source("./Scripts/session_prep.R") # Dates of all parliament periods (election cycle)
# source("./Scripts/cab_prep.R") # Cabinet attributes (name, coal.partner, date from/to, etc)
# source("./Scripts/rep_df.R") # Each parliamentary period's representatives
# source("./Scripts/seats_prep.R") # Seat distribution between parties over parliamentary periods
# source("./Scripts/taler_prep.R") # The actual debates
# source("./Scripts/bios.R") # Large script for structuring the biographies
# source("./Scripts/committee.R") # Script for extracting committee membership
# source("./Scripts/wrapup_saker.R") # Getting a crapton of data on the case level
# save.image("./Data/tmp_image.rda") # These two lines are just a cheat to reduce wait when running multiple tests on script

load("./Data/tmp_image.rda")

# Making all possible combinations of cabinet name and party name
wrapup <- expand.grid(cabinet_short = norCabinet$cabinet_short, party_id = levels(factor(reps$party_id)))

# Merge in cabinet attributes, arrange data, and manual assignment of cabinet role (opposition vs cabinet vs support)
wrapup <- merge(x = wrapup, y = norCabinet, by = "cabinet_short", all.x = TRUE)
wrapup <- arrange(wrapup, parl_period)
wrapup$role <- NA

for(i in 1:nrow(wrapup)){
  wrapup$role[i] <- ifelse(grepl(wrapup$party_id[i], wrapup$CabinetPartiesNor[i])==TRUE, "Cabinet", "Opposition")
}
wrapup$role <- ifelse(grepl("Stoltenberg", wrapup$cabinet_short) & wrapup$party_id == "V", "Opposition", wrapup$role)

# Merge in full party name based on id and parliamentary period
fullname <- unique(reps[, c("party_id", "party_name", "parl_period")])
wrapup <- merge(x = wrapup, y = fullname, by = c("party_id", "parl_period"))

# Merge in N of seats in chambers and plenary + total parliament size, and arrange rows and columns
wrapup <- merge(x = wrapup, y = seats, by = c("party_name", "parl_period"))
wrapup <- arrange(wrapup, parl_period, cabinet_short, party_id)
wrapup <- wrapup[, c("party_id", "parl_period", "seats", "role", "composition", 
                     "cabinet_short", "From", "To", "party_name", 
                     "parl_size", "seats_lagting", "seats_odelsting")]

# Manual fix of cabinet role for KrF and V under the Solberg I cabinet
wrapup$role <- ifelse(wrapup$party_id == "KrF" & wrapup$cabinet_short == "Solberg I", "Support", wrapup$role)
wrapup$role <- ifelse(wrapup$party_id == "V" & wrapup$cabinet_short == "Solberg I", "Support", wrapup$role)

# Merging the party-level data with representative level data + thrash clean
wrapup <- merge(x = reps, y = wrapup, by = c("party_id", "cabinet_short", "parl_period", "party_name"), all.x = TRUE)
rm(reps, fullname, norCabinet, seats, i)

# Making full name variable
wrapup$name <- paste(wrapup$first_name, wrapup$last_name)

# Arranging columns, again...and renaming according to level of measurement
wrapup <- wrapup[, c("id", "first_name", "last_name", "name",
                     "party_id", "party_name", "role", "seats",
                     "cabinet_short", "From", "To", "composition", 
                     "gender", "birth", "death", "fylke_id", "fylke_name",
                     "parl_period", "parl_size", "seats_lagting", "seats_odelsting"), ]

names(wrapup) <- c("rep_id", "rep_first_name", "rep_last_name", "rep_name",
                   "party_id", "party_name", "party_role", "party_seats",
                   "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition", 
                   "rep_gender", "rep_birth", "rep_death", "rep_fylke_id", "rep_fylke_name",
                   "parl_period", "parl_size", "party_seats_lagting", "party_seats_odelsting")

# Assigning cabinet name to the speech data for merging later
cab_name_date <- wrapup %>%
  group_by(cabinet_short) %>%
  summarise(cabinet_start = cabinet_start[1],
            cabinet_end = cabinet_end[1])

taler$cabinet_short <- NA
cab_name_by_date <- function(cabinet_name){
  new <- ifelse(taler$date >= cab_name_date$cabinet_start[which(cab_name_date$cabinet_short == cabinet_name)] & 
                  taler$date <= cab_name_date$cabinet_end[which(cab_name_date$cabinet_short == cabinet_name)],
                cabinet_name, taler$cabinet_short)
  return(new)
}

taler$cabinet_short <- cab_name_by_date("Bondevik I")
taler$cabinet_short <- cab_name_by_date("Bondevik II")
taler$cabinet_short <- cab_name_by_date("Stoltenberg I")
taler$cabinet_short <- cab_name_by_date("Stoltenberg II")
taler$cabinet_short <- cab_name_by_date("Stoltenberg III")
taler$cabinet_short <- cab_name_by_date("Solberg I")
rm(cab_name_date)

# Vector of party and representative variables
party_vars <- c("party_id", "party_name", "party_role", "party_seats", "party_seats_lagting", "party_seats_odelsting",
                "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition",
                "parl_period", "parl_size")
rep_vars <- c("rep_id", "rep_first_name", "rep_last_name", "rep_gender", "rep_birth", "rep_death")

# Unique representative variables for clean merging
wrapup_rep <- unique(wrapup[, c(setdiff(colnames(wrapup), party_vars), "party_id")])

# Unique party variables for clean merging
wrapup_party <- unique(wrapup[, party_vars])

# Ensure that party id is a character variable class
wrapup_party$party_id <- as.character(wrapup_party$party_id)


# Cleaning the biography data
all <- all[, c("rep_id", "rep_first_name", "rep_last_name", "rep_name", "rep_birth", "rep_death")]

# Complete the bios data by merging the different sources and arranging columns + rows
bios <- merge(x = bios, y = all, by = "rep_id", all.x = TRUE)
bios$url_rep_id <- bios$rep_id
bios$rep_id <- NULL

bios <- merge(x = bios, y = unique(wrapup_rep[, c("rep_name", "rep_id", "rep_gender")]), by = c("rep_name"), all.x = TRUE)
bios <- bios[, c("url_rep_id", "rep_id", "rep_first_name", "rep_last_name", "rep_name", "party_id", "rep_gender", 
                 "parl_period", "rep_from", "rep_to", "type", "county", "list_number", 
                 "rep_birth", "rep_death")]
bios <- merge(x = bios, y = committee, by.x = c("url_rep_id", "parl_period"), by.y = c("rep_id", "parl_period"), all.x = TRUE)

bios <- arrange(bios, url_rep_id, rep_from)
rm(all, sessions_df, committee)

# Fixing a period bug before merge
period_fix <- data.frame(session = c("1997-1998", levels(factor(taler$session)), "2016-2017"),
                         parl_period = unlist(lapply(levels(factor(wrapup$parl_period)), function(x) rep(x, 4))))


# Merging party variables with speech-level data
taler_meta <- merge(x = taler, y = wrapup_party, by = c("cabinet_short", "party_id"), all.x = TRUE)
taler_meta$parl_period <- NULL
taler_meta <- merge(x = taler_meta, y = period_fix, by = "session")

# Merging representative variables with speech-level data
taler_meta <- merge(x = taler_meta, y = bios, 
                    by = c("rep_name", "party_id", "parl_period"),
                    all.x = TRUE)

# Spilitting up the commitee variable
taler_meta$committee <- as.character(taler_meta$committee)

# Running committee clean up script
source("./Scripts/committee_fix.R")

# Merging in the new variables
taler_meta <- merge(x = taler_meta, y = committee, by = c("url_rep_id", "parl_period"), all.x = TRUE)
taler_meta$com_date[which(taler_meta$com_date == "NA")] <- NA
taler_meta$com_member[which(taler_meta$com_member == "NA")] <- NA
taler_meta$com_role[which(taler_meta$com_role == "NA")] <- NA

# Arranging the columns
taler_meta$rep_type <- taler_meta$type
taler_meta$type <- NULL
taler_meta$rep_type <- ifelse(taler_meta$rep_type == "Representant" & taler_meta$title == "Statsråd", NA,
                              ifelse(taler_meta$rep_type == "Representant" & taler_meta$title == "Utenriksminister", NA,
                                     ifelse(taler_meta$rep_type == "Representant" & taler_meta$title == "Statsminister", NA,
                                            ifelse(taler_meta$rep_type == "Representant" & taler_meta$title == "President", NA,
                                                   ifelse(taler_meta$rep_type == "Representant" & taler_meta$title == "Visepresident", NA,
                                                          ifelse(taler_meta$rep_type == "Vararepresentant" & taler_meta$title == "Statsråd", NA, 
                                                                 taler_meta$rep_type))))))


taler_meta <- taler_meta[, c("url_rep_id", "rep_id", "rep_first_name", "rep_last_name", "rep_name", "rep_from", "rep_to",
                             "rep_type", "county", "list_number",
                             "party_id", "party_name", "party_role", "party_seats",
                             "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition", 
                             "rep_gender", "rep_birth", "rep_death", # "rep_fylke_id", "rep_fylke_name",
                             "parl_period", "parl_size", "party_seats_lagting", "party_seats_odelsting",
                             "com_member", "com_date", "com_role",
                             "transcript", "order", "session", "time", "date", "title", "text"), ]

# Fixing rep name bug from HDO
taler_meta$rep_name <- ifelse(taler_meta$rep_name == "", NA, taler_meta$rep_name)

# Fixing transcript variable from HDO, so that it sorts properly
taler_meta$transcript <- gsub("\\.sgm$", "", taler_meta$transcript)
taler_meta$transcript <- ifelse(grepl("k$", taler_meta$transcript), 
                                gsub("k", "b", taler_meta$transcript), 
                                paste0(taler_meta$transcript, "a")) 
# Arranging the rows
taler_meta <- arrange(taler_meta, date, transcript, order)

# Removing objects
rm(bios, committee, period_fix, taler, wrapup, wrapup_party, wrapup_rep, i, j, #gen,
   party_vars, rep_vars, cab_name_by_date)

######### Writing the data frame first time
write.csv(taler_meta, "../../taler/taler_meta.csv", row.names = FALSE)
#########

# Add id tags
system("python ../python/add_ids.py ../../taler/taler_meta.csv ../../taler/id_taler_meta.csv")

# Reading in the data again
taler_meta <- read.csv("../../taler/id_taler_meta.csv", stringsAsFactors = FALSE)

# backup <- taler_meta
# taler_meta <- backup
# Merging case data
case_data$transcript <- case_data$order <- case_data$session <- case_data$date <- NULL
taler_meta <- merge(x = taler_meta, y = case_data, by = "id", all.x = TRUE)
# rm(case_data)

# Adding data on language (nynorsk vs. bokmål)
lang <- read.csv("./Data/language.csv", header = FALSE)
names(lang) <- c("id", "language")

taler_meta <- merge(x = taler_meta, y = lang, by = "id", all.x = TRUE)

# Filling in manually coded gender based on first name only
taler_meta$gender_name <- sapply(strsplit(taler_meta$rep_name, " "), "[[", 1)
gen <- read.csv("./Data/gender.csv", stringsAsFactors = FALSE)

taler_meta <- merge(x = taler_meta, y = gen, by.x = "gender_name", by.y = "just_first_name", all.x = TRUE)
taler_meta$rep_gender <- taler_meta$gender_handcoded

# Removing redundant variables
taler_meta <- taler_meta[, c("id", "url_rep_id", "rep_id", "rep_first_name", "rep_last_name", "rep_name", "rep_from", "rep_to",
                             "rep_type", "county", "list_number",
                             "party_id", "party_name", "party_role", "party_seats",
                             "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition", 
                             "rep_gender", "rep_birth", "rep_death", # "rep_fylke_id", "rep_fylke_name",
                             "parl_period", "parl_size", "party_seats_lagting", "party_seats_odelsting",
                             "com_member", "com_date", "com_role",
                             "sak_id", "DC.Identifier", "TITLE", "tittel", "DC.Type", "innstilling_id", "innstillingstekst",
                             "dokumentgruppe", "henvisning", "korttitel", "kortvedtak", "parentestekst",
                             "sak_opphav_rep_id", "saksordfoerer_liste_rep_id", "type", "vedtakstekst",
                             "sporsmal_nummer", "sporsmal_type", "sporsmal_title", "sporretime_type", "sporsmal_id",
                             "sporsmal_fra_id", "fremsatt_av_annen_id", "status",
                             "sporsmal_til_id", "sporsmal_til_minister_id", "sporsmal_til_minister_tittel",
                             "sendt_dato", "besvart_dato", "besvart_av_id", "besvart_av_minister_id", "besvart_av_minister_tittel",
                             "besvart_pa_vegne_av_id", "besvart_pa_vegne_av_minister_id", 
                             "besvart_pa_vegne_av_minister_tittel",
                             "rette_vedkommende_id", "rette_vedkommende_minister_id", "rette_vedkommende_minister_tittel",
                             "emne_id", "emne_navn", "emne_er_hovedemne", "hovedemne_id",
                             "komite_id", "komite_navn", 
                             "dagsordensak_nummer", "dagsordensak_henvisning", "dagsordensak_tekst", "dagsordensak_type",
                             "dagsorden_nummer", "mote_id",  "sak_nummer", 
                             "ssl_id", "ssl_navn", "ssl_steg_nummer", 
                             "prl_eksport_id", "prl_lenke_tekst", "prl_lenke_url", "prl_type", "prl_undertype",
                             "srl_relatert_sak_id", "srl_relasjon_type", "srl_relatert_sak_korttittel",
                             "KEYWORDS", "stikkord", "language",
                             "transcript", "order", "session", "time", "date", "title", "text"), ]

# Prettying up the data
taler_meta$DC.Type <- ifelse(is.na(taler_meta$sporsmal_type) == FALSE & taler_meta$sporsmal_type == "interpellasjon",
                             taler_meta$sporsmal_type, taler_meta$DC.Type)
taler_meta$tittel <- ifelse(is.na(taler_meta$sporsmal_title) == FALSE, taler_meta$sporsmal_title, taler_meta$tittel)
taler_meta$sporsmal_type <- taler_meta$sporsmal_title <- NULL

names(taler_meta)[which(names(taler_meta)=="sak_id")] <- "case_id"
names(taler_meta)[which(names(taler_meta)=="DC.Identifier")] <- "debate_reference"
names(taler_meta)[which(names(taler_meta)=="TITLE")] <- "debate_title"
names(taler_meta)[which(names(taler_meta)=="tittel")] <- "debate_subject"
names(taler_meta)[which(names(taler_meta)=="DC.Type")] <- "debate_type"
names(taler_meta)[which(names(taler_meta)=="innstilling_id")] <- "proposition_id"
names(taler_meta)[which(names(taler_meta)=="innstillingstekst")] <- "proposition_text"
names(taler_meta)[which(names(taler_meta)=="dokumentgruppe")] <- "document_group"
names(taler_meta)[which(names(taler_meta)=="henvisning")] <- "document_references"
names(taler_meta)[which(names(taler_meta)=="korttitel")] <- "document_subject_short"
names(taler_meta)[which(names(taler_meta)=="kortvedtak")] <- "decision_short"
names(taler_meta)[which(names(taler_meta)=="parentestekst")] <- "document_note"
names(taler_meta)[which(names(taler_meta)=="sak_opphav_rep_id")] <- "case_source_id"
names(taler_meta)[which(names(taler_meta)=="saksordfoerer_liste_rep_id")] <- "case_chair_id"
names(taler_meta)[which(names(taler_meta)=="type")] <- "case_type"
names(taler_meta)[which(names(taler_meta)=="vedtakstekst")] <- "decision_text"
names(taler_meta)[which(names(taler_meta)=="sporsmal_nummer")] <- "question_number"
names(taler_meta)[which(names(taler_meta)=="sporsmal_fra_id")] <- "question_from_id"
names(taler_meta)[which(names(taler_meta)=="sporsmal_til_id")] <- "question_to_id"
names(taler_meta)[which(names(taler_meta)=="besvart_av_id")] <- "question_answered_by_id"
names(taler_meta)[which(names(taler_meta)=="besvart_av_minister_id")] <- "question_answered_by_ministry_id"
names(taler_meta)[which(names(taler_meta)=="besvart_av_minister_tittel")] <- "question_answered_by_minister_title"
names(taler_meta)[which(names(taler_meta)=="emne_id")] <- "subject_ids"
names(taler_meta)[which(names(taler_meta)=="emne_navn")] <- "subject_names"
names(taler_meta)[which(names(taler_meta)=="emne_er_hovedemne")] <- "is_main_subject"
names(taler_meta)[which(names(taler_meta)=="hovedemne_id")] <- "main_subject_id"
names(taler_meta)[which(names(taler_meta)=="komite_id")] <- "subject_committee_id"
names(taler_meta)[which(names(taler_meta)=="komite_navn")] <- "subject_committee_name"
names(taler_meta)[which(names(taler_meta)=="dagsordensak_nummer")] <- "agenda_case_number"
names(taler_meta)[which(names(taler_meta)=="dagsordensak_henvisning")] <- "agenda_case_reference"
names(taler_meta)[which(names(taler_meta)=="dagsordensak_tekst")] <- "agenda_case_text"
names(taler_meta)[which(names(taler_meta)=="dagsordensak_type")] <- "agenda_case_type"
names(taler_meta)[which(names(taler_meta)=="dagsorden_nummer")] <- "agenda_number"
names(taler_meta)[which(names(taler_meta)=="mote_id")] <- "meeting_id"
names(taler_meta)[which(names(taler_meta)=="ssl_id")] <- "procedure_id"
names(taler_meta)[which(names(taler_meta)=="ssl_navn")] <- "procedure_name"
names(taler_meta)[which(names(taler_meta)=="ssl_steg_nummer")] <- "procedure_stepnumber"
names(taler_meta)[which(names(taler_meta)=="prl_eksport_id")] <- "publication_export_id"
names(taler_meta)[which(names(taler_meta)=="prl_lenke_tekst")] <- "publication_link_text"
names(taler_meta)[which(names(taler_meta)=="prl_lenke_url")] <- "publication_link_url"
names(taler_meta)[which(names(taler_meta)=="prl_type")] <- "publication_type"
names(taler_meta)[which(names(taler_meta)=="prl_undertype")] <- "publication_undertype"
names(taler_meta)[which(names(taler_meta)=="srl_relatert_sak_id")] <- "related_case_id"
names(taler_meta)[which(names(taler_meta)=="srl_relasjon_type")] <- "related_case_type"
names(taler_meta)[which(names(taler_meta)=="srl_relatert_sak_korttittel")] <- "related_case_title_short"
names(taler_meta)[which(names(taler_meta)=="KEYWORDS")] <- "keyword" # These two here
names(taler_meta)[which(names(taler_meta)=="stikkord")] <- "keywords"   # Are not from the same source -- hence the difference.
names(taler_meta)[which(names(taler_meta)=="title")] <- "speaker_role"
names(taler_meta)[which(names(taler_meta)=="besvart_dato")] <- "question_answered_date"
names(taler_meta)[which(names(taler_meta)=="besvart_pa_vegne_av_id")] <- "question_answered_on_behalf_of_id"
names(taler_meta)[which(names(taler_meta)=="besvart_pa_vegne_av_minister_id")] <- "question_answered_on_behalf_of_ministry_id"
names(taler_meta)[which(names(taler_meta)=="besvart_pa_vegne_av_minister_tittel")] <- "question_answered_on_behalf_of_ministry_title"
names(taler_meta)[which(names(taler_meta)=="fremsatt_av_annen_id")] <- "question_presented_by_other"
names(taler_meta)[which(names(taler_meta)=="rette_vedkommende_id")] <- "question_correct_person"
names(taler_meta)[which(names(taler_meta)=="rette_vedkommende_minister_id")] <- "question_correct_person_ministry_id"
names(taler_meta)[which(names(taler_meta)=="rette_vedkommende_minister_tittel")] <- "question_correct_person_ministry_title"
names(taler_meta)[which(names(taler_meta)=="sak_nummer")] <- "case_number"
names(taler_meta)[which(names(taler_meta)=="sendt_dato")] <- "question_date_sent"
names(taler_meta)[which(names(taler_meta)=="sporretime_type")] <- "question_hour_type"
names(taler_meta)[which(names(taler_meta)=="sporsmal_til_minister_id")] <- "question_to_minister_id" # These two here
names(taler_meta)[which(names(taler_meta)=="sporsmal_til_minister_tittel")] <- "question_to_minister_title"   # Are not from the same source -- hence the difference.
names(taler_meta)[which(names(taler_meta)=="sporsmal_id")] <- "question_id"
names(taler_meta)[which(names(taler_meta)=="status")] <- "question_status"



# Removing line breaks
taler_meta <- apply(taler_meta, 2, function(x) gsub("[\r\n]", " ", x))
taler_meta <- data.frame(taler_meta, stringsAsFactors = FALSE)


# Arranging the data again
taler_meta <- arrange(taler_meta, id)

write.csv(taler_meta, "../../taler/id_taler_meta.csv", row.names = FALSE)

# Also writing a data frame without the text
taler_notext <- taler_meta[,setdiff(names(taler_meta), "text")]
write.csv(taler_notext, "../../taler/id_taler_notext.csv", row.names = FALSE)

