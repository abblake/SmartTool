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
industry_pull <- tbl(wrds, sql("select lpad(sich::text, 4,'0') as SICH, fyear as YEAR, at, ni
                   from compa.funda"))
#drop NA sic codes
industry_pull <- industry_pull %>% filter(!is.na(sich))
#create sic 2 codes
industry_pull <- industry_pull %>% mutate(sic_2 = substr(sich,1,2))
#filter sic 2 codes based on what we have in original pull
industry_pull <- industry_pull %>% filter(sic_2 %in% sic2)
#filter year based on what we want
industry_pull <- industry_pull %>% filter(between(year, year_start,year_end))
#drop observations that equal 0 for assets
industry_pull <- industry_pull %>% filter(at != 0)
#drop observations that equal 0 for net income
industry_pull <- industry_pull %>% filter(ni != 0)
#compute average sic2 roa per year
industry_pull <- industry_pull %>% group_by(sic_2, year) %>% mutate(social_a = mean(ni/at, na.rm = T)) %>% ungroup()
#drop duplicates
industry_pull <- industry_pull %>% distinct(year,sic_2, social_a, .keep_all = F)

#actual data pull
social_asip <- industry_pull %>% collect()
df$year <- df$fyear
df <- merge(df,social_asip, by=c('sic_2', 'year'), all.x=T)
if(length(df$total_assets) > 0){
df$at <- df$total_assets
  ]
df <- df %>% arrange(gvkey,year) %>% mutate(temp_roa = ni/at) %>% mutate(historical_a = dplyr::lag(temp_roa,1)) %>% select(-temp_roa)

rm(social_asip)
