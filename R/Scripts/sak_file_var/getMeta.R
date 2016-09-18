getMeta <- function(pathToData = "../../taler/id_taler_meta.csv", sakfolderPath, session){
  
  # Using dplyr to arrange data because it is quick
  suppressMessages(require(dplyr))
  
  # Reading data, arranging by date and order, then subsetting the session
  taler <- read.csv(pathToData, stringsAsFactors = FALSE)
  taler <- arrange(taler, date, order)
  taler <- taler[which(taler$session == session), ]
  
  # Extracting string to be matched in .html-files later
  taler$text <- substring(taler$text, 1, 100)
  
  # Formatting the date to fit the folder structure of the html-files
  taler$folderdate <- format(as.Date(taler$date), "%y%m%d")
  cat("Data loaded and reduced to session \n")
  
  # Making empty vectors to be used in the loop below, and a progress bar for fun
  truthFinder <- vector("list", nrow(taler))
  trueFile <- vector()
  pb <- txtProgressBar(min = 0, max = nrow(taler), initial = 0, style = 3)
  
  # Uncomment this to test function on small subset of the data
  # taler <- taler[100:110, ]
  
  # Looping over each row of the data to conserve memory
  for(i in 1:nrow(taler)){
    # Giving a tick to the progress bar
    setTxtProgressBar(pb, i)
    
    # Minimizing files to search through by only listing html-files on the relevant date
    filesToSearch <- list.files(paste0(sakfolderPath, taler$session[i], "/", taler$folderdate[i]),
                                full.names = TRUE, recursive = TRUE, pattern = ".html")
    
    # If we do not have the date in html, give it NA and move to next
      # This is, as far as I know, only speeches in start of the session
    if(identical(filesToSearch, character())){
      trueFile[i] <- NA
      next
    }
    
    # Reading the files as text, and giving them a searchable format (removing html-tags for example)
    stringToSearch <- lapply(filesToSearch, function(x) readLines(x, warn = FALSE))
    stringToSearch <- lapply(stringToSearch, function(x) paste(x, collapse = " "))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s+\\,\\s+", ", ", x))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s+\\.\\s+", ". ", x))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s{2,}", " ", gsub("<.*?>", " ", x)))
    stringToSearch <- lapply(stringToSearch, function(x) gsub("\\s+\\,\\s+", ", ", x))
    
    # Here we grep through each file for the "i"
      # If "i" is longer than 50, 20, 10, less than 10 characters, I use approximate matching
      # with allowing 3, 2, 1, and zero differences respectively
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
    
    # Here I only assign filename if there was 1, and only 1, match
     # 0 or > 1 matches gives NA -- this to be sure that we identifi the correct file.
    if(length(which(truthFinder[[i]]==TRUE))==1){
      trueFile[i] <- filesToSearch[which(truthFinder[[i]]==TRUE)] 
    } else {
      trueFile[i] <- NA
    }
  }
  # Closing the progress bar
  close(pb)

  # Aligning the html-filename with id and session in a data frame
  trueFile <- data.frame(id = taler$id, sak_file = trueFile, session = session, date = taler$date, taler$title,
                         stringsAsFactors = FALSE)
  
  # Returning the data frame
  return(trueFile)
}