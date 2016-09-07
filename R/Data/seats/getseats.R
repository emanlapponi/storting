### Add elections if more are neccessary ###
elections <- c("1997-2001", "2001-2005", "2005-2009", "2009-2013", "2013-2017")

#### Getting seat information from stortinget.no ####
lapply(elections, function(x)
 system(paste0("wget -O Data/seats/", x, ".html ", "https://www.stortinget.no/no/",
               "Representanter-og-komiteer/Partiene/Partioversikt/?pid=",
               x)))