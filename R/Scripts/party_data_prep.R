rm(list = ls());cat("\014")
library(uacd);library(dplyr);library(rvest)


# Do we need this?
# cab_grid <- expand.grid(data.frame(party_name = levels(factor(seats$party_name)), session = levels(factor(seats$session))))
# cab_grid <- arrange(cab_grid, party_name, session)
# cab_grid$party_name_short <- factor(cab_grid$party_name, levels = c(""))
################ 

load("Data/norCabinet.rda")
load("./Data/legislators.rda")

legislators <- legislators[which(as.numeric(legislators$period) >= 1997), 
                           c("name", "period", "initials", "state", "party", "gender", "birth", "death")]

names(legislators)


# The following file is used with permission from its makers "HolderDeOrd" -- https://github.com/holderdeord
taler <- read.csv("../../taler/tale.2016-04-20.csv", sep = ",")
taler <- taler[, 1:7]
taler$date <- as.Date(taler$time)

legislators$party <- factor(legislators$party, labels = c("A", "FrP", "H", "Kp", "KrF", "MDG", "Sp", "SV", "TF", "V"))
summary(legislators$party)


# Danger!!! ###########################
# weird <- taler[which(taler$title == ""), ]
####################################

norCabinet$from_year <- as.numeric(substr(norCabinet$From, 1, 4))
norCabinet$to_year <- as.numeric(substr(norCabinet$To, 1, 4))
norCabinet$to_year[which(norCabinet$Cabinet == "Erna Solberg's government")] <- 2017

norCabinet <- norCabinet[which(norCabinet$from_year >= 1997), ]

norCabinet$cabinet_short <- c("Bondevik I", "Stoltenberg I", "Bondevik II", "Stoltenberg II", "Stoltenberg III", "Solberg I")
norCabinet[, c("Cabinet", "cabinet_short")]

parties <- strsplit(norCabinet$CabinetPartiesNor, "\\+")

norCabinet$composition <- ifelse(sapply(parties, function(x) length(x)) <= 1, "Single-party", "Coalition")

rm(parties)
str(norCabinet)
names(legislators)


taler$name <- as.character(taler$name)
name_merge <- strsplit(taler$name, " ")

name_merge <- lapply(name_merge, function(x) rev(x))

# for(i in 1:length(taler$name_merge)){
#   taler$name_merge[[i]][1] <- paste0(toupper(taler$name_merge[[i]][1]), ",")
# }

name_merge_one <- lapply(1:length(name_merge), function(x) paste0(toupper(name_merge[[x]][1]), ","))
name_merge_one[1]

taler$name_merge <- unlist(lapply(1:length(name_merge), function(x) paste0(name_merge_one[[x]], " ", paste(name_merge[[x]][-1], collapse = " "))))
taler$name_merge <- ifelse(taler$name == "Presidenten", taler$name, taler$name_merge)
cbind(taler$name[1:100], taler$name_merge[1:100])

speakers <- paste(levels(factor(taler$name_merge)), collapse = "\n")
cat(speakers)
writeLines(speakers, "./Data/speakers.txt")
