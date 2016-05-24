bios$Stortingsperioder[which(bios$rep_id == "ANAL")] <- 
  gsub("Representant nr 1 for Kjøpstedene i Møre og Romsdal fylke \\(Kristiansund, Molde, Ålesund\\), 1922 - 1924",
       "Representant nr 1 for Kjøpstedene i Møre og Romsdal fylke (Kristiansund, Molde, Ålesund), 1922 - 1924, A.",
       bios$Stortingsperioder[which(bios$rep_id == "ANAL")])

bios$Stortingsperioder[which(bios$rep_id == "ANAL")] <- 
  gsub("Representant nr 1 for Kjøpstedene i Møre og Romsdal fylke \\(Kristiansund, Molde, Ålesund\\), 1925 - 1927",
       "Representant nr 1 for Kjøpstedene i Møre og Romsdal fylke (Kristiansund, Molde, Ålesund), 1925 - 1927, A.",
       bios$Stortingsperioder[which(bios$rep_id == "ANAL")])

bios$Stortingsperioder[which(bios$rep_id == "OMM")] <- 
  gsub("Vararepresentant nr 1 for Oppland, 1925 - 1927",
       "Vararepresentant nr 1 for Oppland, 1925 - 1927, B.",
       bios$Stortingsperioder[which(bios$rep_id == "OMM")])

bios$Stortingsperioder[which(bios$rep_id == "OMM")] <-
  gsub("Vararepresentant nr 2 for Oppland, 1928 - 1930",
       "Vararepresentant nr 2 for Oppland, 1928 - 1930, B.",
       bios$Stortingsperioder[which(bios$rep_id == "OMM")])