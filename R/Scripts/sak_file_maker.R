
getMeta <- function(pathToData = "../../taler/taler_meta.csv", biosfolderPath, session){
  require(dplyr)
  
  taler <- read.csv(pathToData, stringsAsFactors = FALSE)
  taler <- arrange(taler, date, order)
  taler <- taler[which(taler$session == session), ]
  taler$text <- substring(taler$text, 1, 100)
  taler$folderdate <- format(as.Date(taler$date), "%y%m%d")
  
  
  truthFinder <- vector("list", nrow(taler))
  trueFile <- vector()
  prog <- progress_estimated(nrow(taler))
  
  for(i in 1:nrow(taler)){
    filesToSearch <- list.files(paste0(biosfolderPath, taler$session[i], "/", taler$folderdate[i]),
                                full.names = TRUE, recursive = TRUE, pattern = ".html")
    stringToSearch <- lapply(filesToSearch, function(x) readLines(x, warn = FALSE))
    stringToSearch <- lapply(stringToSearch, function(x) paste(x, collapse = " "))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s+\\,\\s+", ", ", x))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s+\\.\\s+", ". ", x))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s{2,}", " ", gsub("<.*?>", " ", x)))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s+\\,\\s+", ", ", x))
    
    
    for(j in 1:length(stringToSearch)){
      truthFinder[[i]][j] <- vector(length = length(stringToSearch[[j]]))
      if(nchar(taler$text[i])>50){
        truthFinder[[i]][j] <- agrepl(taler$text[i], stringToSearch[[j]], 3, fixed = TRUE)
      } else if(nchar(taler$text[i])>20){
        truthFinder[[i]][j] <- agrepl(taler$text[i], stringToSearch[[j]], 2, fixed = TRUE)
      } else if(nchar(taler$text[i])>10){
        truthFinder[[i]][j] <- agrepl(taler$text[i], stringToSearch[[j]], 1, fixed = TRUE)
      } else {
        truthFinder[[i]][j] <- grepl(taler$text[i], stringToSearch[[j]], fixed = TRUE)
      }
    }
    
    if(length(which(truthFinder[[i]]==TRUE))==1){
      trueFile[i] <- filesToSearch[which(truthFinder[[i]]==TRUE)] 
    } else {
      trueFile[i] <- NA
    }
    prog$pause(0.1)$tick()$print()
  }
  return(trueFile)
}

soFar <- getMeta(pathToData = "../../taler/taler_meta.csv",
                 biosfolderPath = "../../../../../../referat_raw/stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/",
                 session = "1998-1999")

save(soFar, file = paste0("biosfiles", session,".rda"))
