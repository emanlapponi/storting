files <- unlist(lapply(list.dirs("data/processed"), function(x) list.files(x, pattern = ".txt", full.names = TRUE)))

files[sample(0:length(files), size = 10)]

partyName <- gsub("[0-9]|data/processed/|.txt", "", files)

dataTest <- data.frame(date = as.Date(substr(gsub("[^0-9]", "", files), 1, 6), format = "%y%m%d"),
                       time = (substr(gsub("[^0-9]", "", files), 7, 12)),
                       party = sapply(strsplit(partyName, "/"), "[[", 1),
                       name = gsub("_", " ", sapply(strsplit(partyName, "/"), "[[", 2)))



dataList <- list(dataTest, lapply(files, function(x) readLines(x)))


dataList[[2]][903]
dataList[[1]][903,]
