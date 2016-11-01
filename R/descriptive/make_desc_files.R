
rm(list = setdiff(ls(), "taler"));cat("\014");gc()
library(dplyr)

if(("taler" %in% ls())==FALSE){
  taler <- read.csv("../../taler/id_taler_meta.csv", stringsAsFactors = FALSE)
}

summary_table <- function(variable, data = taler, save_table_as){
  tab <- data %>%
    mutate_(holder = 1) %>%
    group_by_(variable) %>%
    summarise(n_speech = length(holder)) %>%
    ungroup() %>% arrange(desc(n_speech))
  write.table(tab, file = save_table_as, row.names = FALSE, quote = FALSE, col.names = FALSE)
  rm(tab)
}
lapply(names(taler), function(x) summary_table(x, save_table_as = paste0("./descriptive/", x)))
# Deleted the nonsense files manually