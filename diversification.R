###diversification
#loading packages
if (!require('pacman')) install.packages('pacman')
pacman::p_load(dplyr, RPostgres, lubridate, haven, stringr, svDialogs, janitor)

#converting years for compustat
date_start <- paste0(year_start,'-01-01')
date_end <- paste0(year_end,'-12-31')

#connecting to historical segments
segment <- tbl(wrds, sql("select *, extract(year from datadate) AS year from comp_segments_hist_daily.wrds_segmerged
                   where stype = 'BUSSEG'
                   ")))
#remove NA sectors
segment <- segment %>% filter(!is.na(sics1))
#remove NA sales variable
segment <- segment %>% filter(!is.na(sales))
#filter just what I need
segment <- segment %>% filter(gvkey %in% f_gvkey)
#collect information
div <- segment %>% collect()
#add in cols to remove
cols_to_remove <- c(cols_to_remove, names(div))
cols_to_remove <- cols_to_remove[cols_to_remove %notin% c('gvkey','fyear','year','tic','sich','cusip','cik','execid')]
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


