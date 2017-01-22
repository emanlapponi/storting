source("./Scripts/sak_file_var/getMeta.R")

soFar <- getMeta(pathToData = "../../taler/id_taler_meta.csv",
                 sakfolderPath = "/media/martigso/Data/referat_raw/stortinget.no/no/Saker-og-publikasjoner/Publikasjoner/Referater/Stortinget/",
                 session = "2015-2016")

save(soFar, file = paste0("./Data/sak_filerefs/sakfiles", unique(soFar$session), ".rda"))
cat("Done!")
