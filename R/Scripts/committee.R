committee <- all$`Medlemskap i stortingskomiteer`
names(committee) <- all$rep_id
com_tmp <- strsplit(committee, "[0-9]{4}\\-[0-9]{2,4}")
com_tmp <- mclapply(com_tmp, str_trim, mc.cores = ncores)
com_tmp <- mclapply(com_tmp, function(x) x[-which(x == "")], mc.cores = ncores)
# com_tmp <- mclapply(com_tmp, function(x) str_replace_all(x, "[0-9]|\\.|\\-", ""))
# com_tmp <- sapply(com_tmp, function(x) if(identical(x, character(0))==FALSE) str_extract_all(x, "[A-Z]+[a-z]+\\s*"), simplify = TRUE)
com_period <- list()
for(i in names(com_tmp)){
  if(identical(com_tmp[[i]], character(0))==FALSE){
    names(com_tmp[[i]]) <- as.character(str_extract_all(committee[[i]], "[0-9]{4}\\-[0-9]{2}", simplify = TRUE))
    com_period[[i]] <- names(com_tmp[[i]])
  }
}
for(i in names(com_tmp)){
  if(is.null(com_tmp[[i]])==FALSE){
    for(j in names(com_tmp[[i]])){
      com_tmp[[i]][[j]] <- str_trim(com_tmp[[i]][[j]])
    }
  }
}

for(i in names(com_tmp)){
  if(is.null(com_tmp[[i]])==FALSE){
    for(j in names(com_tmp[[i]])){
      com_tmp[[i]][[j]] <- com_tmp[[i]][[j]][which(com_tmp[[i]][[j]] != "")]
    }
  }
}

committee <- melt(com_tmp)
committee$com_period <- as.character(unlist(com_period))
committee$com_period <- factor(committee$com_period, 
                              labels = c("1919-1921", "1925-1927", "1928-1930", "1931-1933", "1934-1936", "1937-1945", 
                                         "1945-1949", "1950-1953", "1954-1957", "1958-1961", "1961-1965", "1965-1969", 
                                         "1969-1973", "1973-1977", "1977-1981", "1981-1985", "1985-1989", "1989-1993", 
                                         "1993-1997", "1997-2001", "2001-2005", "2005-2009", "2009-2013", "2013-2017"))
names(committee) <- c("committee", "rep_id", "parl_period")

rm(com_tmp, com_period)

