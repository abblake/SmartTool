###diversification
#loading packages
if (!require('pacman')) install.packages('pacman')
pacman::p_load(dplyr, RPostgres, lubridate, haven, stringr, svDialogs, janitor)

#converting years for compustat
date_start <- paste0(year_start,'-01-01')
date_end <- paste0(year_end,'-12-31')

#connecting to historical segments
res <- dbSendQuery(wrds, paste0("select * from comp_segments_hist_daily.wrds_segmerged
                   where stype = 'BUSSEG'
                   and datadate between '",date_start,"'
                   and '",date_end,"'"))
div <- dbFetch(res, n=-1)
dbClearResult(res)

#converting back to year for later
div <- div %>% mutate(date_ymd = lubridate::ymd(datadate)) %>% mutate(year = lubridate::year(date_ymd))
#remove NA sectors
div <- div %>% filter(!is.na(sics1))
#remove NA sales variable
div <- div %>% filter(!is.na(sales))
#suming all sales by sector and year
div <- div %>% group_by(sics1, year) %>% mutate(sector_sales = sum(sales, na.rm = T))
#remove sectors with zero sales
div <- div %>% filter(sector_sales != 0)
#calulating p ratio
div <- div %>% group_by(gvkey,year) %>% mutate(p_ratio = sales / sector_sales)
#calculate entropy according to #CEO POLITICAL IDEOLOGIES AND PAYEGALITARIANISM WITHIN TOP MANAGEMENTTEAMS
div <- div %>% group_by(gvkey,year) %>% mutate(pre_calculation = p_ratio * log(p_ratio)) %>% mutate(entropy = sum(pre_calculation, na.rm = T))

#get final numbers for year
div <- div %>% distinct(gvkey,year, .keep_all = T) %>% select(gvkey,year,datadate, entropy)


####follow these steps to merge this data with CSV datafile computed with START
df$year <- df$fyear
df <- merge(df, div, by=c('gvkey', 'year'), all.x=T)
rm(div)


