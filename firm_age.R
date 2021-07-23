###firm_age
#extract ipodate
ipodate <- tbl(wrds, sql("select gvkey, ipodate from comp_na_daily_all.company"))
#create object with only unique gvkeys
f_gvkey <- unique(df$gvkey)
#filter by object
ipodate <- ipodate %>% filter(gvkey %in% f_gvkey)
#collect data from wrds
ipo_df <- ipodate %>% collect()
#merge
df <- merge(df, ipo_df, by='gvkey', all.x = T)
df <- df %>% mutate(ipo_year = year(ipodate))
df <- df %>% mutate(firm_age1 = year - ipo_year)
rm(ipo_df, ipodate)
