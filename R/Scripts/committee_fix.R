# Removing duplicates of same person in same parliamentary period
committee <- taler_meta %>%
  group_by(rep_id, parl_period) %>%
  summarize(committee = unique(committee))

# Extracting the dates of membership and assigning with id
com_dates <- str_extract_all(committee$committee, "([0-9]+\\.[0-9]+\\.[0-9]+\\s*\\-\\s*[0-9]+\\.[0-9]+\\.[0-9]+)")
names(com_dates) <- paste(committee$rep_id, "-",committee$parl_period)

# Extracting role and committee, removing empty strings, and giving NA to character(0) occurances
com_tmp <- str_split(committee$committee, "([0-9]+\\.[0-9]+\\.[0-9]+\\s*\\-\\s*[0-9]+\\.[0-9]+\\.[0-9]+)")
com_tmp <- lapply(com_tmp, function(x) x[which(x != "")])
for(i in 1:length(com_tmp)){
  if(identical(com_tmp[[i]], character(0))){
    com_tmp[[i]] <- NA
  }
}

# Assigning ids to the committees as well
names(com_tmp) <- paste(committee$rep_id, "-",committee$parl_period) 

# Melting dates and committees to symmetric data frames, then insert the dates to the tmp data frame, and removing the date object
com_dates <- melt(com_dates, na.rm = FALSE)
com_tmp <- melt(com_tmp, na.rm = FALSE)
com_tmp$dates <- com_dates$value
rm(com_dates)

# Splitting the id up into rep_id and parliamentary period
com_tmp$rep_id <- sapply(strsplit(com_tmp$L1, " \\- "), "[[", 1)
com_tmp$parl_period <- sapply(strsplit(com_tmp$L1, " \\- "), "[[", 2)
com_tmp$rep_id[which(com_tmp$rep_id == "NA")] <- NA
com_tmp$L1 <- NULL

# Assigning better names to the variables
names(com_tmp) <- c("committee", "com_date", "rep_id", "parl_period")

# Trimming, removing commas in the end of string, and extracting the committee role
com_tmp$committee <- str_trim(com_tmp$committee)
com_tmp$committee <- gsub("\\,$", "", com_tmp$committee)
com_tmp$com_role <- sapply(strsplit(com_tmp$committee, "\\, "), "[[", 1)

# Fixing tripple name committees, and extracting the name of the committee, the fixing NA
com_tmp$committee <- gsubfn("([A-ZÆØÅ][a-zæøå]+\\-\\,)", ~ gsub("\\,", "", x), com_tmp$committee)
com_tmp$committee <- sapply(sapply(strsplit(com_tmp$committee, "\\, "), rev), "[[", 1)
com_tmp$committee[which(com_tmp$committee == "NA")] <- NA

# Cleaning up
committee <- com_tmp # This is is the committee data on committee level 
# e.g a representative can be member of several committes
# in the same parliamentary period
rm(com_tmp)

# Aggregating to representative, parliamentary period
committee <- committee %>%
  group_by(rep_id, parl_period) %>%
  summarize(com_member = paste(committee, collapse = " // "),
            com_date = paste(com_date, collapse = " // "),
            com_role = paste(com_role, collapse = " // "))