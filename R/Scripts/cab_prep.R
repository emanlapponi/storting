load("./Data/norCabinet.rda")
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

# Removing redundant variables
norCabinet <- norCabinet[, c("cabinet_short", "CabinetPartiesNor", "From", "To", "composition")]
norCabinet$To[which(norCabinet$cabinet_short == "Solberg I")] <- "2017-10-01"
norCabinet$session <- c("1997-2001", "1997-2001", "2001-2005", "2005-2009", "2009-2013", "2013-2017")
norCabinet$CabinetPartiesNor <- gsub("Ap", "A", norCabinet$CabinetPartiesNor)
norCabinet$CabinetPartiesNor <- gsub("Frp", "FrP", norCabinet$CabinetPartiesNor)



