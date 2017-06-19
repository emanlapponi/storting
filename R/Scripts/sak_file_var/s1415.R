source("./Scripts/sak_file_var/getMeta.R")

soFar <- getMeta(pathToData = "../../talk-of-norway/data/ton.csv",
                 sakfolderPath = "/media/martigso/Data/referat_raw/stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/",
                 session = "2014-2015")

save(soFar, file = paste0("./Data/sak_filerefs/sakfiles", unique(soFar$session), ".rda"))
cat("Done!")
