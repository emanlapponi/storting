rm(list=ls());gc();cat("\014")
library(rvest);library(dplyr);library(zoo);library(parallel);library(pbmcapply)


taler_notext <- read.csv("../../taler/id_taler_notext.csv")
allFiles <- paste0("./Data/sak_filerefs/sakfiles", seq(1998, 2015, 1), "-", seq(1999, 2016, 1), ".rda")

tmp <- list()
for(i in 1:length(allFiles)){
  load(allFiles[i])
  tmp[[i]] <- soFar
  tmp[[i]]$taler.title <- NULL
  if(is.null(tmp[[i]]$sak_file)==TRUE){

    tmp[[i]]$sak_file <- tmp[[i]]$bios_file
    tmp[[i]]$bios_file <- NULL
    tmp[[i]] <- tmp[[i]][, c("id", "sak_file", "session", "date")]
  }
}

names(tmp) <- paste0("sakfiles", seq(1998, 2015, 1), seq(1999, 2016, 1))
rm(soFar)

soFar <- lapply(tmp, function(x) merge(x = x, y = taler_notext[, c("id", "transcript", "order")], 
                                       by = "id", all.x = TRUE))
rm(taler_notext)

soFar <- lapply(soFar, function(x) arrange(x, date, transcript, order))

soFar <- lapply(soFar, function(x){
  x <- x %>%
    group_by(date, transcript) %>%
    mutate(sak_file = na.locf(sak_file, na.rm = FALSE), # This might be slightly ambitious on behalf of the data...
           sak_file = na.locf(sak_file, na.rm = FALSE, fromLast = TRUE)) # ...
  
})

subs <- unlist(lapply(soFar, function(x) unique(x$sak_file[which(is.na(x$sak_file)==FALSE)])))

content_list <- list()

saker_meta_raw <- pbmclapply(1:length(subs), function(i){
  # cat(paste0("Starting ", i, " ...\n"))
  start <- read_html(subs[i])
  
  cat("Starting processing html ...")
    content <- start %>% html_nodes("meta") %>% html_attr("content")
    name <- c((start %>% html_nodes("meta") %>% html_attr("name")),
              (start %>% html_nodes("meta") %>% html_attr("property")),
              (start %>% html_nodes("meta") %>% html_attr("http-equiv")))
    name <- name[which(is.na(name)==FALSE)]
    content_list <- data.frame(t(content))
    colnames(content_list) <- name
    cat(paste0("Done with ", i, " ...\n"))
    return(content_list)
}, mc.cores = 6)

saker_meta_raw <- suppressMessages(reshape2::melt(saker_meta_raw))
saker_meta_raw$file <- subs

soFar <- do.call(rbind, soFar)
saker_meta_raw <- merge(x = soFar, y = saker_meta_raw, by.x = "sak_file", 
                        by.y = "file", all.x = TRUE)
saker_meta_raw <- arrange(saker_meta_raw, date, transcript, order)

write.csv(saker_meta_raw, file = "./Data/saker_meta_raw.csv", row.names = FALSE)

