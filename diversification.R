###diversification
#loading packages
if (!require('pacman')) install.packages('pacman')
pacman::p_load(dplyr, RPostgres, lubridate, haven, stringr, svDialogs, janitor)

#pulling historical segments
  lazy_pull <- tbl(wrds, sql("select * from comp.wrds_segmerged"))
  lazy_pull <- lazy_pull %>% filter(gvkey %in% u_gvkey)
  lazy_pull <- lazy_pull %>% filter(stype == "BUSSEG")
#downloading data
div <- lazy_pull %>% collect()
#create year variable and drop duplicates to source date clostest to fiscal year
  div$datadate <- ymd(div$datadate)
  div$srcdate <- ymd(div$srcdate)
  div$year <- year(div$datadate)
  div <- div %>% filter(between(year, year_start,year_end))
  #drop duplicates by the date that is closests to fiscal year
  div <- div %>% group_by(stype, gvkey, datadate) %>% filter(srcdate==min(srcdate))
#compute diversification
  div <- div %>% group_by(stype, gvkey, datadate) %>% mutate(total_sales = sum(sales, na.rm = T))
  div <- div %>% group_by(stype, gvkey, datadate, sid) %>% mutate(p_ia = sales/total_sales)
  div <- div %>% group_by(stype, gvkey, datadate, sid) %>% mutate(p_ia_formula = p_ia*log(1/p_ia))
  div <- div %>% group_by(stype, gvkey, datadate) %>% mutate(diversification1 = sum(p_ia_formula, na.rm = T)) %>% ungroup()
  div <- div %>% select(gvkey, datadate, year, diversification1)
  div <- div %>% distinct(gvkey, datadate, .keep_all = T)


####follow these steps to merge this data with CSV datafile computed with START
df <- merge(df, div, by=c('gvkey', 'year'), all.x=T)
rm(div)


