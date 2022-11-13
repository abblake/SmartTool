#Stock Volatility -- start

if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, RPostgres, lubridate, haven, stringr, svDialogs, janitor, devtools)



#let's do some prep work to make things easy on us after the data is pulled

#first off, we need to link gvkeys to permno.
comp <- tbl(wrds, sql("select a.*, b.* from comp.security as a, comp.company as b
                      where a.gvkey = b.gvkey"))
comp <- comp %>% filter(!is.na(isin))
#comp <- comp %>% filter(exchg==11) #this is no longer needed
comp <- comp %>% collect()
#u_gvkey <- head(unique(comp$gvkey), 500)
comp <- comp %>% filter(gvkey %in% u_gvkey)
comp <- comp %>% mutate(cusip_8 = substr(comp$cusip,1,8))
u_cusip <- unique(comp$cusip_8)


crsp <- tbl(wrds, sql("select * from crsp.dsf"))
crsp <- crsp %>% filter(cusip %in% u_cusip) %>% mutate(year_var = year(date)) %>% group_by(cusip, year_var) %>% summarise(stockv = sd(ret, na.rm = T), .groups = 'keep') %>% ungroup
crsp <- crsp %>% filter(between(year_var,year_start,year_end))
tsr_calc <- crsp %>% collect
rm(crsp)

#here we are merging linking information so that TSR can be merged to our larger dataframe.
comp <- comp %>% select(gvkey,cusip,cusip_8)
tsr_calc <- merge(tsr_calc, comp, by.x = 'cusip_8', by.y = 'cusip_8', all.x = T)
tsr_calc <- tsr_calc %>% select(-gvkey.y) %>% rename(gvkey = gvkey.x) %>% rename(year = year_var)
df <- merge(df, tsr_calc, by = c('gvkey','year'), all.x = T)

