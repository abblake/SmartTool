comp_gvkeyfix <- tbl(wrds, sql("select a.*, b.* , a.gvkey as gvkey_link from security as a, company as b
                      where a.gvkey = b.gvkey"))
comp_gvkeyfix <- comp_gvkeyfix %>% filter(!is.na(isin))
comp_gvkeyfix <- comp_gvkeyfix %>% filter(exchg==11)
comp_gvkeyfix <- comp_gvkeyfix %>% select(gvkey_link, cusip) %>% distinct()
comp_gvkeyfix <- comp_gvkeyfix %>% mutate(cusip6 = substr(cusip,1,6))
comp_gvkeyfix <- comp_gvkeyfix %>% collect()
comp_gvkeyfix <- comp_gvkeyfix %>% rename(gvkey = gvkey_link) %>% select(gvkey, cusip6)
new_iss_m <- merge(new_iss_m, comp_gvkeyfix, by='cusip6')
