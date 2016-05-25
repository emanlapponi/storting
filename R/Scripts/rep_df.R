storting_rep_df <- function(file) {
  require(XML, quietly = TRUE)
  base_file <- xmlInternalTreeParse(file)
  
  
  rep_list <- xmlToList(base_file, xmlChildren(xmlRoot(base_file))[["representanter_liste"]])
  rep_list <- unlist(rep_list$representanter_liste)
  
  
  # vars <- unique(names(rep_list))
  rep_list <- as.character(rep_list)
  
  reps <- data.frame(
    version = rep_list[seq(1, length(rep_list), 13)],
    death = rep_list[seq(2, length(rep_list), 13)],
    last_name = rep_list[seq(3, length(rep_list), 13)],
    birth = rep_list[seq(4, length(rep_list), 13)],
    first_name = rep_list[seq(5, length(rep_list), 13)],
    id = rep_list[seq(6, length(rep_list), 13)],
    gender = rep_list[seq(7, length(rep_list), 13)],
    fylke_version = rep_list[seq(8, length(rep_list), 13)],
    fylke_id = rep_list[seq(9, length(rep_list), 13)],
    fylke_name = rep_list[seq(10, length(rep_list), 13)],
    party_version = rep_list[seq(11, length(rep_list), 13)],
    party_id = rep_list[seq(12, length(rep_list), 13)],
    party_name = rep_list[seq(13, length(rep_list), 13)],
    stringsAsFactors = FALSE)
  return(reps)
}


allfiles <- list.files("./Data/reps", pattern = ".xml", full.names = TRUE)

rep_list <- list(`1997-2001` = storting_rep_df(allfiles[1]),
                 `2001-2005` = storting_rep_df(allfiles[2]),
                 `2005-2009` = storting_rep_df(allfiles[3]),
                 `2009-2013` = storting_rep_df(allfiles[4]),
                 `2013-2017` = storting_rep_df(allfiles[5]))


rep_df <- do.call(rbind, rep_list)
rep_df$session <- gsub("\\.[0-9]+$", "", rownames(rep_df))
rownames(rep_df) <- 1:nrow(rep_df)
reps <- rep_df[, c("last_name", "first_name", "id", "session", "party_name", "party_id", "gender", "birth", "death",
                   "fylke_name", "fylke_id", "version", "party_version", "fylke_version")]
reps$cabinet_short <- NA
reps_9701Bondevik <- reps[which(reps$session == "1997-2001"), ]
reps_9701Bondevik$cabinet_short <- "Bondevik I"
reps_9701BStoltenberg <- reps[which(reps$session == "1997-2001"), ]
reps_9701BStoltenberg$cabinet_short <- "Stoltenberg I"

reps <- rbind(reps_9701Bondevik, reps_9701BStoltenberg, reps[which(reps$session != "1997-2001"), ])

reps$cabinet_short <- ifelse(reps$session == "2001-2005", "Bondevik II", reps$cabinet_short)
reps$cabinet_short <- ifelse(reps$session == "2005-2009", "Stoltenberg II", reps$cabinet_short)
reps$cabinet_short <- ifelse(reps$session == "2009-2013", "Stoltenberg III", reps$cabinet_short)
reps$cabinet_short <- ifelse(reps$session == "2013-2017", "Solberg I", reps$cabinet_short)



rm(allfiles, rep_list, storting_rep_df, rep_df, reps_9701Bondevik, reps_9701BStoltenberg)