
# The following file is used with permission from its makers "HolderDeOrd" -- https://github.com/holderdeord
# Data from:
#  system("wget -O ../../taler/tale.2016-04-20.csv https://files.holderdeord.no/data/csv/tale.2016-04-20.csv")
taler <- read.csv("../../taler/tale.2016-04-20.csv", sep = ",")

taler$date <- as.Date(taler$time)

taler$rep_name <- taler$name
taler$name <- NULL
# Danger!!! ###########################
# weird <- taler[which(taler$title == ""), ]
####################################



