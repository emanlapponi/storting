rm(list = ls());cat("\014")
library(stringr);library(uacd);library(dplyr);library(rvest);library(parallel)

# Cabinet level data from 1884-2017 -- creds to Rasch(xxxx)
load("./Data/norCabinet.rda")
reps <- read.csv("./Data/reps.csv")
# The following file is used with permission from its makers "HolderDeOrd" -- https://github.com/holderdeord
taler <- read.csv("../../taler/tale.2016-04-20.csv", sep = ",")
taler <- taler[, 1:7]
taler$date <- as.Date(taler$time)

# Danger!!! ###########################
# weird <- taler[which(taler$title == ""), ]
####################################

norCabinet$from_year <- as.numeric(substr(norCabinet$From, 1, 4))
norCabinet$to_year <- as.numeric(substr(norCabinet$To, 1, 4))
norCabinet$to_year[which(norCabinet$Cabinet == "Erna Solberg's government")] <- 2017

# Subsetting to the scope of our data
norCabinet <- norCabinet[which(norCabinet$from_year >= 1997), ]

# Cabinet name more easily ordered: A I < A II < A III... < A k
norCabinet$cabinet_short <- c("Bondevik I", "Stoltenberg I", "Bondevik II", "Stoltenberg II", "Stoltenberg III", "Solberg I")

# Cabinet composition dummy: coalition if N parties > 1
parties <- strsplit(norCabinet$CabinetPartiesNor, "\\+")
norCabinet$composition <- ifelse(sapply(parties, function(x) length(x)) <= 1, "Single-party", "Coalition")
rm(parties)

reps$name <- paste(reps$first_name, reps$last_name)



isitthere <- mclapply(taler$name, function(x) any(grepl(x, reps$name)), mc.cores = 6)

isitthere <- unlist(isitthere)
levels(factor(taler$name))[1:10]
notfound <- which(isitthere == FALSE)

tester <- taler[notfound, c("name", "title", "date")]

tester <- tester[-which(tester$name == "Presidenten" | tester$title == "Statsråd" | duplicated(tester$name)), ]

tester <- arrange(tester, name)
tester$name[1:10]

reps[which(grepl("Austheim", reps$last_name)), ]



tester$id <- NA
tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
tester$id[which(grepl("ÅMLAND", tester$name_merge))] <- "TAML"
tester$id[which(grepl("ANDERSEN, Geir", tester$name_merge))] <- "GEA"
tester$id[which(grepl("ANDERSEN, Vidar", tester$name_merge))] <- "VA"
tester$id[which(grepl("ANDREASSEN, Brit I. H.", tester$name_merge))] <- "BIA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"
# tester$id[which(grepl("AKSNES", tester$name_merge))] <- "MGRA"






