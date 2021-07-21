
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
                      #actual data pull
                        industry_roa_b <- industry_pull %>% collect()
                      #create lag variable for at
                        industry_roa_b <- industry_roa_b %>% arrange(sich, year) %>% mutate(at_l = dplyr::lag(at, 1))
                      #compute average sic2 roa per year
                        industry_roa_b <- industry_roa_b %>% group_by(sic_2, year) %>% mutate(ind_roa2 = mean(ni/((at+at_l/2)), na.rm = T)) %>% ungroup()
                        #drop duplicates
                        industry_roa_b <- industry_roa_b %>% distinct(year,sic_2, ind_roa2, .keep_all = F)




                        df <- merge(df,industry_roa_b, by=c('sic_2', 'year'), all.x=T)
                        rm(industry_roa_b)
