

session_list <- xmlToList("./Data/sessions/stortingsperioder.xml", xmlChildren(xmlRoot(base_file))[["stortingsperioder_liste"]])


sessions <- unlist(session_list$stortingsperioder_liste, use.names = FALSE)

sessions_df <- data.frame(version = sessions[seq(1, length(sessions), 4)],
                          from = sessions[seq(2, length(sessions), 4)],
                          session = sessions[seq(3, length(sessions), 4)],
                          to = sessions[seq(4, length(sessions), 4)], stringsAsFactors = FALSE)

sessions_df$session <- ifelse(nchar(sessions_df$session) == 7,
                              paste0(substr(sessions_df$session, 1, 5), "19", 
                                     substr(sessions_df$session, 6, 7)), sessions_df$session)
sessions_df$parl_period <- sessions_df$session
sessions_df$session <- NULL
sessions_df$from <- as.Date(sessions_df$from)
sessions_df$to <- as.Date(sessions_df$to)

rm(session_list, sessions)
