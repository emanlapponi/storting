rm(list = ls());cat("\014")
library(stringr);library(uacd);library(dplyr);library(rvest);library(parallel)

source("./Scripts/cab_prep.R")
source("./Scripts/rep_df.R")
source("./Scripts/seats_prep.R")
source("./Scripts/taler_prep.R")

wrapup <- expand.grid(cabinet_short = norCabinet$cabinet_short, party_id = levels(factor(reps$party_id)))
wrapup <- merge(x = wrapup, y = norCabinet, by = "cabinet_short", all.x = TRUE)

wrapup$role <- NA

for(i in 1:nrow(wrapup)){
  wrapup$role[i] <- ifelse(grepl(wrapup$party_id[i], wrapup$CabinetPartiesNor[i])==TRUE, "Cabinet", "Opposition")
}

fullname <- unique(reps[, c("party_id", "party_name", "session")])

wrapup <- merge(x = wrapup, y = fullname, by = c("party_id", "session"))

wrapup <- merge(x = wrapup, y = seats, by =c("party_name", "session"))

wrapup <- arrange(wrapup, session, cabinet_short, party_id)
names(wrapup)
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

names(taler)
taler_meta <- merge(x = taler, y = wrapup, by = c("rep_name", "cabinet_short"), all.x = TRUE)
str(taler_meta)


write.csv(taler_meta, "../../taler/taler_meta.csv")
