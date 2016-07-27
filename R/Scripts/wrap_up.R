rm(list = ls());cat("\014");gc()
# install.packages("./Data/uacd/uacd_0.14.tar.gz", repos = NULL)
library(stringr);library(uacd);library(dplyr);library(rvest);library(parallel);library(zoo);library(gsubfn)
library(XML)

ncores <- detectCores()-1

source("./Scripts/session_prep.R") # Dates of all parliament periods (election cycle)
source("./Scripts/cab_prep.R") # Cabinet attributes (name, coal.partner, date from/to, etc)
source("./Scripts/rep_df.R") # Each parliamentary period's representatives
source("./Scripts/seats_prep.R") # Seat distribution between parties over parliamentary periods
source("./Scripts/taler_prep.R") # The actual debates
source("./Scripts/bios.R") # Large script for structuring the biographies


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
bios <- merge(x = bios, y = unique(wrapup_rep[, c("rep_id", "rep_gender")]), by = c("rep_id"), all.x = TRUE)
bios <- bios[, c("rep_id", "rep_first_name", "rep_last_name", "rep_name", "party_id", "rep_gender", 
                 "parl_period", "rep_from", "rep_to", "type", "county", "list_number", 
                 "rep_birth", "rep_death")]
bios <- arrange(bios, rep_id, rep_from)
rm(all, sessions_df)

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

# Arranging the columns
taler_meta <- taler_meta[, c("rep_id", "rep_first_name", "rep_last_name", "rep_name", "rep_from", "rep_to",
                             "type", "county", "list_number",
                             "party_id", "party_name", "party_role", "party_seats",
                             "cabinet_short", "cabinet_start", "cabinet_end", "cabinet_composition", 
                             "rep_gender", "rep_birth", "rep_death", # "rep_fylke_id", "rep_fylke_name",
                             "parl_period", "parl_size", "party_seats_lagting", "party_seats_odelsting",
                             "transcript", "order", "session", "time", "date", "title", "text"), ]

# Arranging the rows
taler_meta <- arrange(taler_meta, rep_name, date)

######### Writing the data frame
write.csv(taler_meta, "../../taler/taler_meta.csv", row.names = FALSE)
#########

# Also writing a data frame without the text
taler_notext <- taler_meta[,setdiff(names(taler_meta), "text")]
write.csv(taler_notext, "../../taler/taler_notext.csv", row.names = FALSE)

# This will not work in R, but will work in the terminal
# system("../python/add_ids.py ../../taler/taler_meta.csv ../../taler/id_taler_meta.csv")
# system("../python/add_ids.py ../../taler/taler_notext.csv ../../taler/id_taler_notext.csv")

