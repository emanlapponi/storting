# Getting file names
html_path <- "/media/martin/Data/getbio/www.stortinget.no/no/Representanter-og-komiteer/Representantene/Representantfordeling/Representant/"
html_files <- list.files(html_path)
html_files <- html_files[-which(grepl("Biography|ProcAndPubl", html_files))]
bios_raw <- lapply(paste0(html_path, html_files), function(x) read_html(x))

# Producing the person ids
id_tags <- sapply(strsplit(html_files, "\\="), "[[", 2)

# Extracting the relevant html node from each html file (DO NOT USE MCLAPPLY!)
bios_block <- lapply(bios_raw, function(x) (html_nodes(x, "#main-content div .article-content")))

# Converting to plain text
bios_all <- mclapply(bios_block, function(x) html_text(x, trim = TRUE), mc.cores = ncores)

# Extracting what is to be variables from html node
vars <- mclapply(bios_block, function(x) html_text(html_nodes(x, "h3")), mc.cores = ncores)
vars <- mclapply(vars, function(x) str_trim(x), mc.cores = ncores)

# Producing a splitter for getting the values from each html-file for each variable
vars_pattern <- mclapply(vars, function(x) paste0(x, collapse = "|"), mc.cores = ncores)
vars_pattern <- mclapply(vars_pattern, function(x) gsub("^\\||\\|$", "", x), mc.cores = ncores)

# Some manual fixing, ofc
bios_all <- mclapply(bios_all, function(x) gsub("Litteraturanmelder", "litteraturanmelder", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verv Hammerfest", "verv Hammerfest", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verv Amnesty", "verv Amnesty", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Sprog og Litteratur", "Sprog og litteratur", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verv Osloregionens", "verv Osloregionens", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Litteraturkritiker", "litteraturkritiker", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Litteraturmedarbeider", "litteraturmedarbeider", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verv AUF", "verv AUF", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verv kirkelig", "verv kirkelig", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Vervet i UNIFIL", "vervet i UNIFIL", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verveleder", "verveleder", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verv NFF", "verv NFF", x), mc.cores = ncores)
bios_all <- mclapply(bios_all, function(x) gsub("Verv Romerike", "verv Romerike", x), mc.cores = ncores)

# Splitting to get the values, and cleaning up the noise
bios_split <- mclapply(1:length(bios_all), function(x) strsplit(bios_all[[x]], vars_pattern[[x]]), mc.cores = ncores)
bios_split <- unlist(bios_split, recursive = FALSE)
bios_split <- mclapply(bios_split, function(x) gsub("[\r\n]", "", x), mc.cores = ncores)
bios_split <- mclapply(bios_split, function(x) gsub("[\t]", "", x), mc.cores = ncores)
bios_split <- mclapply(bios_split, function(x) str_trim(x), mc.cores = ncores)

# Cleaning variable names
vars <- mclapply(vars, function(x) str_trim(x), mc.cores = ncores)
vars <- mclapply(vars, function(x) c("rep_id", x[which(nchar(x)!=0)]), mc.cores = ncores)

# Giving the firts variable the correct ID for each list item
for(i in 1:length(vars)){
  bios_split[[i]][1] <- id_tags[i]
}

# Binding the values to exclusive rows
bios <- mclapply(bios_split, function(x) data.frame(rbind(x), stringsAsFactors = FALSE), mc.cores = ncores)

# Giving the correct names to each variable
for(i in 1:length(bios)){
  names(bios[[i]]) <- vars[[i]]
}

# A check for all variables; there should not be any noise now
m <- levels(factor(unlist(vars)))

##### A series of assigning NA to MPs with no value on certain variables ####
for(i in 1:length(bios)){
  bios[[i]]$`rep_id` <- ifelse(is.null(bios[[i]]$`rep_id`), NA, 
                                                  as.character(bios[[i]]$`rep_id`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Litteratur` <- ifelse(is.null(bios[[i]]$`Litteratur`), NA, 
                                   as.character(bios[[i]]$`Litteratur`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Medlemskap i delegasjoner` <- ifelse(is.null(bios[[i]]$`Medlemskap i delegasjoner`), NA, 
                                                  as.character(bios[[i]]$`Medlemskap i delegasjoner`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Medlemskap i gruppestyrer` <- ifelse(is.null(bios[[i]]$`Medlemskap i gruppestyrer`), NA, 
                                                  as.character(bios[[i]]$`Medlemskap i gruppestyrer`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Medlemskap i presidentskapet` <- ifelse(is.null(bios[[i]]$`Medlemskap i presidentskapet`), NA, 
                                                     as.character(bios[[i]]$`Medlemskap i presidentskapet`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Medlemskap i regjering` <- ifelse(is.null(bios[[i]]$`Medlemskap i regjering`), NA, 
                                               as.character(bios[[i]]$`Medlemskap i regjering`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Medlemskap i spesialkomiteer, interne styrer og utvalg m.m.` <- ifelse(is.null(bios[[i]]$`Medlemskap i spesialkomiteer, interne styrer og utvalg m.m.`), 
                                                                                    NA, 
                                                                                    as.character(bios[[i]]$`Medlemskap i spesialkomiteer, interne styrer og utvalg m.m.`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Medlemskap i stortingskomiteer` <- ifelse(is.null(bios[[i]]$`Medlemskap i stortingskomiteer`), NA, 
                                                       as.character(bios[[i]]$`Medlemskap i stortingskomiteer`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Personalia` <- ifelse(is.null(bios[[i]]$`Personalia`), NA, 
                                   as.character(bios[[i]]$`Personalia`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Stortingsperioder` <- ifelse(is.null(bios[[i]]$`Stortingsperioder`), NA, 
                                          as.character(bios[[i]]$`Stortingsperioder`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Utdanning og yrkeserfaring` <- ifelse(is.null(bios[[i]]$`Utdanning og yrkeserfaring`), NA, 
                                                   as.character(bios[[i]]$`Utdanning og yrkeserfaring`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Vararepresentasjoner` <- ifelse(is.null(bios[[i]]$`Vararepresentasjoner`), NA, 
                                             as.character(bios[[i]]$`Vararepresentasjoner`))
}
for(i in 1:length(bios)){
  bios[[i]]$`Verv` <- ifelse(is.null(bios[[i]]$`Verv`), NA, 
                             as.character(bios[[i]]$`Verv`))
}
##### END #####

# The beauty of rbind helps making this a data frame
all <- do.call(rbind, bios)

# Fixing rownames
rownames(all) <- 1:nrow(all)

# Assigning MP full names / first names / last names to the correct rows
name <- mclapply(bios_raw, function(x) (x %>% html_nodes("h1") %>% html_text()), mc.cores = ncores)
name <- str_trim(gsub("[\r\n]", "", unlist(name)))
name <- str_trim(sapply(strsplit(name, " \\("), "[[", 1))
first_name <- str_trim(sapply(strsplit(name, ","), "[[", 2))
last_name <- str_trim(sapply(strsplit(name, ","), "[[", 1))
all$rep_first_name <- first_name
all$rep_last_name <- last_name

# Assigning birth/death to the correct MPs
person <- str_split(str_trim(gsub("[^0-9\\.]", " ", all$Personalia)), "[[:space:]]{1,100}")
all$rep_birth <- sapply(person, "[[", 1)
all$rep_death <- unlist(lapply(person, function(x) ifelse(length(x) > 1, x[2], NA)))
all$rep_death <- ifelse(nchar(all$rep_death) == 4, NA, all$rep_death)
all$rep_death <- ifelse(nchar(all$rep_death) == 0, NA, all$rep_death)


# This was used to validate that the dates were correct; now they are, but it is still nice to look at
# bide <- sapply(strsplit(all$name_birth, "[[:space:]]{2,100}"), "[[", 2)
# bide <- gsub("\\(|\\)", "", bide)
# bide <- strsplit(bide, "\\-")
# bide <- plyr::rbind.fill(lapply(bide, function(x) as.data.frame(t(x))))
# names(bide) <- c("birth", "death")

# Constructing MP name that fits with format of other data
all$rep_name <- paste(all$rep_first_name, all$rep_last_name)


rm(bios, bios_split, bios_all, bios_block, bios_raw, first_name, 
   last_name, html_files, html_path, id_tags, m, name, person, vars, vars_pattern)

##### Section to make session rows ####

# trying to get session rows from bios
bios <- all[, c("rep_id", "Stortingsperioder", "Medlemskap i stortingskomiteer")]

source("./Scripts/manual_bios_fix.R")

# Replacing full stops in dates that interfere with some shit below
bios$Stortingsperioder <- gsubfn("([0-9]+)\\.([0-9]+)\\.([0-9]+)", ~ paste0(x, "/", y, "/", z), bios$Stortingsperioder)

# Replacing full stops from "[0-9]. krets" occurances
bios$Stortingsperioder <- gsubfn("([0-9]+)\\.", ~ paste0(x, ""), bios$Stortingsperioder)

# Splitting on [party]. & trimming
periods <- ifelse(grepl("\\(([^\\)]+)\\)", bios$Stortingsperioder),
                  strsplit(bios$Stortingsperioder, "[[:space:]]{2,100}", perl=TRUE),
                  strsplit(bios$Stortingsperioder, "(?<=[\\.])", perl=TRUE))
#periods <- strsplit(bios$Stortingsperioder, "(?<=[\\.])", perl=TRUE)

periods <- mclapply(periods, function(x) str_trim(x), mc.cores = ncores)

# Finding the number of reps to do, repping, and data framing
hm <- sapply(periods, length)
bios <- lapply(1:nrow(bios), function(x) data.frame(rep_id = rep(bios$rep_id[x], hm[x]), 
                                                    Stortingsperioder = rep(bios$Stortingsperioder[x], hm[x]),
                                                    stringsAsFactors = FALSE))
rm(hm)
bios <- do.call(rbind, bios)

# Giving the row the right value
bios$Stortingsperioder <- unlist(periods)
rm(periods)

# Finding value Representant | Vararepresentant
bios$type <- sapply(strsplit(bios$Stortingsperioder, " "), "[[", 1)

# The MP/stand in's number on the county list after count
list_number <- strsplit(gsub("[^0-9]", " ", bios$Stortingsperioder), "[[:space:]]{1,100}")
list_number <- mclapply(list_number, function(x) x[which(nchar(x) > 0)], mc.cores = ncores)
list_number <- mclapply(list_number, function(x) ifelse(length(x) == 0, NA, x), mc.cores = ncores)
bios$list_number <- unlist(list_number)
rm(list_number)

# Remaining trash and cleanup
rest <- strsplit(bios$Stortingsperioder, "[A-Za-z]{12,16} [a-z]{2,2} [0-9]{1,3} [a-z]{3,3} ")
rest <- mclapply(rest, function(x) x[which(nchar(x) > 0)], mc.cores = ncores)
rest <- unlist(mclapply(rest, function(x) ifelse(x == "NA", NA, x), mc.cores = ncores))

# Finding county elected from
bios$county <- sapply(strsplit(rest, ","), "[[", 1)

# Finding session elected in 
bios$parl_period <- sapply(strapply(rest, "[0-9]{4,4}"), function(x) paste0(x, collapse = "-"))
bios$parl_period <- ifelse(bios$parl_period == "", NA, bios$parl_period)
bios$parl_period <- ifelse(nchar(bios$parl_period) > 9, NA, bios$parl_period)

# Specifying the party id
rep_party <- strsplit(rest, ",")
rep_party <- lapply(rep_party, function(x) rev(x))
rep_party <- gsub("\\.", "", sapply(rep_party, "[[", 1))
bios$rep_party <- gsub("\\(([^\\)]+)\\)", "", rep_party)
bios$rep_party <- str_trim(bios$rep_party)
rm(rest, rep_party)


session_date <- strapply(bios$Stortingsperioder, "\\(([^\\)]+)\\)")
session_date <- mclapply(session_date, function(x) ifelse(is.null(x), NA, x), mc.cores = ncores)
bios$rep_date <- unlist(session_date)
bios$rep_date <- ifelse(grepl("[[:alpha:]]", bios$rep_date) == FALSE, bios$rep_date, NA)

bios$rep_from <- NA
dropper <- which(is.na(bios$rep_date) == FALSE)
bios$rep_from[dropper] <- sapply(strsplit(bios$rep_date[dropper]," - "), "[[", 1)
bios$rep_from <- as.Date(bios$rep_from, "%d/%m/%Y")

bios$rep_to <- NA
bios$rep_to[dropper] <- sapply(strsplit(bios$rep_date[dropper], " - "), "[[", 2)
bios$rep_to <- as.Date(bios$rep_to, "%d/%m/%Y")
rm(session_date, dropper)

bios <- merge(x = bios, y = sessions_df[, c("from", "to", "parl_period")], by = "parl_period", all.x = TRUE)
bios <- arrange(bios, rep_id, parl_period)

bios$rep_from[which(is.na(bios$from) == FALSE)] <- bios$from[which(is.na(bios$from) == FALSE)]
bios$rep_to[which(is.na(bios$to) == FALSE)] <- bios$to[which(is.na(bios$to) == FALSE)]

bios$rep_date <- NULL;bios$from <- NULL;bios$to <- NULL

bios$party_id <- gsub("Uav", "Uavhengig", bios$rep_party)

# write.csv(all, "/media/martin/Data/getbio/prepreproc.csv")
