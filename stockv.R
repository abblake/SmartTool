
#Stock Market Volatility -- start

#Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, RPostgres, lubridate, haven, stringr, svDialogs, janitor, devtools)

#Preprocessing link tables

#Link gvkeys to permno.
comp <- tbl(wrds, sql("select a.*, b.* from comp.security as a, comp.company as b
                      where a.gvkey = b.gvkey"))
comp <- comp %>% filter(!is.na(isin))
comp <- comp %>% collect()
comp <- comp %>% filter(gvkey %in% u_gvkey)
comp <- comp %>% mutate(cusip_8 = substr(comp$cusip,1,8))
u_cusip <- unique(comp$cusip_8)

#Here is the main script used to compute stock market volatility
crsp <- tbl(wrds, sql("select * from crsp.dsf"))
crsp <- crsp %>% filter(cusip %in% u_cusip) %>% mutate(year_var = year(date)) %>% group_by(cusip, year_var) %>% summarise(stockv = sd(ret, na.rm = T), .groups = 'keep') %>% ungroup
crsp <- crsp %>% filter(between(year_var,year_start,year_end))
tsr_calc <- crsp %>% collect


#Here we are merging linking information so that stockv can be merged to our larger dataframe.
comp <- comp %>% select(gvkey,cusip,cusip_8)
tsr_calc <- merge(tsr_calc, comp, by.x = 'cusip', by.y = 'cusip_8', all.x = T)
tsr_calc <- tsr_calc %>% rename(cusip_9 = cusip.y) %>% rename(year = year_var)
df <- merge(df, tsr_calc, by = c('gvkey','year'), all.x = T)

rm(crsp)
