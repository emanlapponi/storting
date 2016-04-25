rm(list = ls());cat("\014")

# The uacd package is included in the repo:
# install.packages("Data/uacd/uacd_0.14.tar.gz", repos = NULL)
# read the documentatiton "Data/uacd/uacd.pdf" for more information on the package


data("ParlGov") # from the uacd-package

# names(ParlGov)
ParlGov$election_date <- as.numeric(gsub("-", "", ParlGov$election_date))

nor <- ParlGov %>%
  filter(country_name == "Norway" &  election_date > 19951230) %>%
  select(party_name, cabinet_name, seats, election_date) %>%
  group_by(party_name, cabinet_name) %>%
  summarise(seats = mean(seats),
            election_date = election_date[1])

rm(ParlGov)

parties <- c(levels(factor(nor$party_name)), "Miljøpartiet De Grønne")
elections <- c("1997-2001", "2001-2005", "2005-2009", "2009-2013", "2013-2017")