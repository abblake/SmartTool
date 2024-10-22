#load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, dbplyr,RPostgres, lubridate, haven, stringr, svDialogs, janitor)



#social aspirations
#pad sic codes with 0 if not length 4
df$sich <- stringr::str_pad(df$sich, 4, 'left', '0')
#get sic 2 code
df$sic_2 <- stringr::str_sub(df$sich,1,2)
#drop duplicates into list
sic2 <- unique(df$sic_2)
#drop NA
sic2 <- sic2[!is.na(sic2)]

#initial lazy pull
industry_pull <- tbl(wrds, sql("select lpad(sich::text, 4,'0') as SICH, fyear as YEAR, at, ni, gvkey
                   from compa.funda"))
#filter year based on what we want
industry_pull <- industry_pull %>% filter(between(year, year_start,year_end))

#replace missing sich with SIC codes
industry_pull <- industry_pull %>% collect()
missing_sich <- unique(industry_pull$gvkey)
sich_pull <- tbl(wrds, sql('select * from comp.company'))
sich_pull <- sich_pull %>% filter(gvkey %in% missing_sich)
sich_pull <- sich_pull %>% collect()
sich_pull <- sich_pull %>% select(gvkey, sic)
industry_pull <- merge(industry_pull, sich_pull, by='gvkey', all.x = T)
industry_pull$sich <- ifelse(is.na(industry_pull$sich), industry_pull$sic, industry_pull$sich)
industry_pull <- industry_pull %>% select(-sic)
rm(sich_pull, missing_sich)


#drop NA sic codes
industry_pull <- industry_pull %>% filter(!is.na(sich))
#create sic 2 codes
industry_pull <- industry_pull %>% mutate(sic_2 = substr(sich,1,2))
#filter sic 2 codes based on what we have in original pull
industry_pull <- industry_pull %>% filter(sic_2 %in% sic2)

#compute average sic2 roa per year
industry_pull <- industry_pull %>% group_by(gvkey) %>% arrange(year, .by_group = T) %>% mutate(roa_temp = ni/at) %>% ungroup()
industry_pull <- industry_pull %>% group_by(sic_2, year) %>% filter(!is.infinite(roa_temp)) %>% mutate(social_a = mean(roa_temp, na.rm=T)) %>% ungroup()
industry_pull <- industry_pull %>% select(sic_2,year,social_a)
#drop duplicates
industry_pull <- industry_pull %>% distinct(sic_2, year, .keep_all = F)

#actual data pull
df$year <- df$fyear
df <- merge(df,industry_pull, by=c('sic_2', 'year'), all.x=T)
rm(industry_pull)
if(length(df$total_assets) > 0){
df$at <- df$total_assets
  }
df <- df %>% group_by(gvkey) %>% mutate(temp_roa = ni/at) %>% mutate(historical_a = dplyr::lag(temp_roa,1,order_by=fyear)) %>% select(-temp_roa)

