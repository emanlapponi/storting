isitthere <- mclapply(taler$name, function(x) any(grepl(x, reps$name)), mc.cores = 6)

isitthere <- unlist(isitthere)
levels(factor(taler$name))[1:10]
notfound <- which(isitthere == FALSE)

tester <- taler[notfound, c("name", "title", "date")]

tester <- tester[-which(tester$name == "Presidenten" | tester$title == "Statsråd" | duplicated(tester$name)), ]

tester <- arrange(tester, name)
tester$name[1:10]

reps[which(grepl("Sjaastad", reps$name)), ]

tester$id <- NA
tester$id[which(grepl("Åge Austheim", tester$name))] <- "AGEA"
tester$id[which(grepl("Åge Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Aina Stenersen", tester$name))] <- "AICS"
tester$id[which(grepl("Akhtar Chaudhry", tester$name))] <- "AC"
tester$id[which(grepl("Alf E. Jakobsen", tester$name))] <- "ALJA"
tester$id[which(grepl("Allan Johansen", tester$name))] <- "AJO"
tester$id[which(grepl("Alvhild Hedstein", tester$name))] <- "AHE"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"
tester$id[which(grepl("Tovan", tester$name))] <- "_AGET"






