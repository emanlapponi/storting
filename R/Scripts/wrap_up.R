rm(list = ls());cat("\014");gc()
# install.packages("./Data/uacd/uacd_0.14.tar.gz", repos = NULL)
library(stringr);library(uacd);library(dplyr);library(rvest);library(parallel);library(zoo);library(gsubfn)
library(XML)

ncores <- detectCores()-2

source("./Scripts/session_prep.R")
source("./Scripts/cab_prep.R")
source("./Scripts/rep_df.R")
source("./Scripts/seats_prep.R")
source("./Scripts/taler_prep.R")
source("./Scripts/bios.R")
# source("./Scripts/bios_struc.R")


wrapup <- expand.grid(cabinet_short = norCabinet$cabinet_short, party_id = levels(factor(reps$party_id)))
wrapup <- merge(x = wrapup, y = norCabinet, by = "cabinet_short", all.x = TRUE)

wrapup$role <- NA

for(i in 1:nrow(wrapup)){
  wrapup$role[i] <- ifelse(grepl(wrapup$party_id[i], wrapup$CabinetPartiesNor[i])==TRUE, "Cabinet", "Opposition")
}
wrapup$role <- ifelse(grepl("Stoltenberg", wrapup$cabinet_short) & wrapup$party_id == "V", "Opposition", wrapup$role)

fullname <- unique(reps[, c("party_id", "party_name", "session")])

wrapup <- merge(x = wrapup, y = fullname, by = c("party_id", "session"))

wrapup <- merge(x = wrapup, y = seats, by = c("party_name", "session"))

wrapup <- arrange(wrapup, session, cabinet_short, party_id)

wrapup <- wrapup[, c("party_id", "session", "seats", "role", "composition", 
                     "cabinet_short", "From", "To", "party_name", 
                     "parl_size", "seats_lagting", "seats_odelsting")]

wrapup$role <- ifelse(wrapup$party_id == "KrF" & wrapup$cabinet_short == "Solberg I", "Support", wrapup$role)
wrapup$role <- ifelse(wrapup$party_id == "V" & wrapup$cabinet_short == "Solberg I", "Support", wrapup$role)


wrapup <- merge(x = reps, y = wrapup, by = c("party_id", "cabinet_short", "session", "party_name"), all.x = TRUE)

rm(reps, fullname, norCabinet, seats, i)

wrapup$name <- paste(wrapup$first_name, wrapup$last_name)

wrapup <- wrapup[, c("id", "first_name", "last_name", "name",
                     "party_id", "party_name", "role", "seats",
                     "cabinet_short", "From", "To", "composition", 
                     "gender", "birth", "death", "fylke_id", "fylke_name",
                     "session", "parl_size", "seats_lagting", "seats_odelsting"), ]

names(wrapup) <- c("rep_id", "rep_first_name", "rep_last_name", "rep_name",
                   "party_id", "party_name", "party_role", "party_seats",
                   "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition", 
                   "rep_gender", "rep_birth", "rep_death", "rep_fylke_id", "rep_fylke_name",
                   "parl_session", "parl_size", "party_seats_lagting", "party_seats_odelsting")

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

party_vars <- c("party_id", "party_name", "party_role", "party_seats", "party_seats_lagting", "party_seats_odelsting",
                "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition",
                "parl_session", "parl_size")
rep_vars <- c("rep_id", "rep_first_name", "rep_last_name", "rep_gender", "rep_birth", "rep_death")


wrapup_rep <- unique(wrapup[, c(setdiff(colnames(wrapup), party_vars), "party_id")])

wrapup_party <- unique(wrapup[, party_vars])
wrapup_party$party_id <- as.character(wrapup_party$party_id)

all <- all[, c("rep_id", "rep_first_name", "rep_last_name", "rep_name", "rep_birth", "rep_death")]
bios <- merge(x = bios, y = all, by = "rep_id", all.x = TRUE)
bios <- merge(x = bios, y = unique(wrapup_rep[, c("rep_id", "rep_gender")]), by = c("rep_id"), all.x = TRUE)

bios <- bios[, c("rep_id", "rep_first_name", "rep_last_name", "rep_name", "party_id", "rep_gender", 
                 "parl_session", "rep_from", "rep_to", "type", "county", "list_number", 
                 "rep_birth", "rep_death")]

bios <- arrange(bios, rep_id, rep_from)
rm(all, sessions_df)

taler_meta <- merge(x = taler, y = wrapup_party, by = c("cabinet_short", "party_id"), all.x = TRUE)

taler_meta <- merge(x = taler_meta, y = bios, 
                    by = c("rep_name", "party_id", "parl_session"),
                    all.x = TRUE)

taler_meta <- taler_meta[, c("rep_id", "rep_first_name", "rep_last_name", "rep_name", "rep_from", "rep_to",
                             "type", "county", "list_number",
                             "party_id", "party_name", "party_role", "party_seats",
                             "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition", 
                             "rep_gender", "rep_birth", "rep_death", #"rep_fylke_id", "rep_fylke_name",
                             "parl_session", "parl_size", "party_seats_lagting", "party_seats_odelsting",
                             "transcript", "order", "session", "time", "date", "title", "text"), ]

taler_meta <- arrange(taler_meta, rep_name, date)

#########
write.csv(taler_meta, "../../taler/taler_meta.csv", row.names = FALSE)
#########

taler_notext <- taler_meta[,setdiff(names(taler_meta), "text")]
write.csv(taler_notext, "../../taler/taler_notext.csv", row.names = FALSE)
