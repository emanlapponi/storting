rm(list = ls());gc();cat("\014")
library(dplyr); library(pbmcapply)


# Loading data ######
dagsorden <- read.csv2("./Data/dagsorden.csv", stringsAsFactors = FALSE)
url_base <- "https://data.stortinget.no/eksport/sak?sakid="
path <- "/media/martin/Data/saker_raw/"
done <- sort(gsub("[^0-9]", "", list.files(path)))
sak_ids <- sort(as.character(unique(dagsorden$sak_id)))

sak_ids <- sak_ids[which((sak_ids %in% done)==FALSE)]

for(i in sak_ids){
  system(paste0("wget -O ", path, "sak_", i, ".xml ", url_base, i, " "))
  Sys.sleep(abs(2+rnorm(1)))
}

