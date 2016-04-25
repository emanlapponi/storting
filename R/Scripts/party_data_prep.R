rm(list = ls());cat("\014")
library(stringr);library(uacd);library(dplyr);library(rvest);library(parallel)

# Do we need this?
# cab_grid <- expand.grid(data.frame(party_name = levels(factor(seats$party_name)), session = levels(factor(seats$session))))
# cab_grid <- arrange(cab_grid, party_name, session)
# cab_grid$party_name_short <- factor(cab_grid$party_name, levels = c(""))
################ 

load("Data/norCabinet.rda")
load("./Data/legislators.rda")

legislators <- legislators[which(as.numeric(legislators$period) >= 1990), 
                           c("name", "period", "initials", "state", "party", "gender", "birth", "death")]

names(legislators)


# The following file is used with permission from its makers "HolderDeOrd" -- https://github.com/holderdeord
taler <- read.csv("../../taler/tale.2016-04-20.csv", sep = ",")
taler <- taler[, 1:7]
taler$date <- as.Date(taler$time)

legislators$party <- factor(legislators$party, labels = c("A", "FrP", "H", "Kp", "KrF", "MDG", "Sp", "SV", "TF", "V"))
summary(factor(legislators$party))


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


taler$name <- as.character(taler$name)
name_merge <- strsplit(taler$name, " ")

name_merge2 <- lapply(name_merge, function(x) rev(x))
name_merge2 <- unlist(lapply(name_merge, function(x) ifelse(length(x) != 0, rev(x)[1], x)))

name_merge <- lapply(name_merge, function(x) str_trim(paste(x, collapse = " ")))
name_merge <- sapply(1:length(name_merge), function(x) gsub(name_merge2[[x]], "", name_merge[[x]]))
name_merge <- paste(toupper(name_merge2), name_merge, sep = ", ")
taler$name_merge <- str_trim(name_merge)

taler$name_merge <- ifelse(taler$name == "Presidenten", taler$name, taler$name_merge)
taler$name_merge <- ifelse(taler$name_merge == "BALLO, Gunnar", "BALLO, Olav Gunnar", taler$name_merge)
taler$name_merge <- ifelse(taler$name_merge == "BALLO, Ole Gunnar", "BALLO, Olav Gunnar", taler$name_merge)



speakers <- paste(levels(factor(taler$name_merge)), collapse = "\n")

cat(speakers)
writeLines(speakers, "./Data/speakers")

isitthere <- mclapply(taler$name_merge, function(x) any(grepl(x, legislators$name)), mc.cores = 6)

isitthere <- unlist(isitthere)
levels(factor(taler$name_merge))[1:10]
notfound <- which(isitthere == FALSE)

tester <- taler[notfound, c("name", "name_merge", "title", "date")]

tester <- tester[-which(tester$name == "Presidenten" | tester$title == "Statsråd" | duplicated(tester$name)), ]

tester <- tester[-which(tester$date > as.Date("2013-10-01")), ]

tester <- arrange(tester, name_merge)


legislators[which(grepl("ANDERSEN", legislators$name)), ]



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






