
st <- read.csv("../../taler/id_taler_notext.csv")



votes_detailed_agg <- votes_detailed %>%
  mutate(vote = ifelse(vote == "for", 1, ifelse(vote == "mot", 0, NA))) %>%
  group_by(case_id, vote_rep_id) %>%
  summarize(votes_prop_for = mean(vote, na.rm = TRUE)) %>%
  mutate(votes_prop_for = ifelse(is.nan(votes_prop_for), NA, votes_prop_for))


lol <- merge(x = votes_detailed_agg, y = st, by.x = c("case_id", "vote_rep_id"), by.y = c("case_id", "rep_id"), all.y = TRUE)

lol <- lol[which(is.na(lol$votes_prop_for) == FALSE), ]