rm(list=ls());cat("\014");gc()

moteid <- read.csv2("Data/moter.csv")$id
moteid <- moteid[-which(moteid == "-1")]

setwd("Data/saker/")
for(i in moteid){
  system(paste0("wget 'https://data.stortinget.no/eksport/dagsorden?moteid=", i, "'"))
  Sys.sleep(2)
}
setwd("../../")
