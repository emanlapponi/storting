#### Getting seat information from stortinget.no ####
lapply(elections, function(x) 
  system(paste0("wget -O Data/seats/", x, " https://www.stortinget.no/no/Representanter-og-komiteer/Partiene/Partioversikt/?pid=", x)))


seats <- lapply(elections, function(yeah) read_html(paste0("Data/seats/", yeah)))
seats <- lapply(seats, function(mhm) data.frame((mhm %>% html_node("table") %>% html_table())))
seats <- lapply(seats, function(ohh) data.frame(ohh, parl_size = ohh$Storting[nrow(ohh)]))
seats <- lapply(seats, function(heyhey) heyhey[-(nrow(heyhey)), ])

names(seats) <- elections

seats$`2009-2013`$Odelsting <- NA
seats$`2013-2017`$Odelsting <- NA

seats$`2009-2013`$Lagting <- NA
seats$`2013-2017`$Lagting <- NA


seats <- do.call(rbind, seats)

seats$session <- gsub("\\.[0-9]", "", rownames(seats))
rownames(seats) <- 1:nrow(seats)
colnames(seats) <- c("party_name", "seats", "seats_odelsting", "seats_lagting", "parl_size", "session")
