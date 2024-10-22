#crsp tsr -- start

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

###checks for duplicates QA
###review <- comp[duplicated(comp$gvkey),] 
###ends

#pulls in RET data from CRSP
crsp <- tbl(wrds, sql('select *, extract(year from date) as year, lag(ret,1) over(partition by cusip order by date) ret_l1,
                      lag(ret,2) over(partition by cusip order by date) ret_l2,
                      lag(ret,3) over(partition by cusip order by date) ret_l3,
                      lag(ret,4) over(partition by cusip order by date) ret_l4,
                      lag(ret,5) over(partition by cusip order by date) ret_l5,
                      lag(ret,6) over(partition by cusip order by date) ret_l6,
                      lag(ret,7) over(partition by cusip order by date) ret_l7,
                      lag(ret,8) over(partition by cusip order by date) ret_l8,
                      lag(ret,9) over(partition by cusip order by date) ret_l9,
                      lag(ret,10) over(partition by cusip order by date) ret_l10,
                      lag(ret,11) over(partition by cusip order by date) ret_l11
                      from crsp.msf'))


#we create function here to add 1 to all RET values.
add_one <- function(x) {x+1}
#create sequence of the years you specified. this is important for filtering data
year_seq <- seq(year_start, year_end,1)
#filter by year sequence
crsp <- crsp %>% filter(year %in% year_seq)
#filter by cusip
crsp <- crsp %>% filter(cusip %in% u_cusip)
#collect data from crsp
crsp <- crsp %>% collect(); print('This part usually takes about 5 minutes, please be patient. Do not worry, the heavy processing is being done by WRDS server.')
crsp <- crsp %>% distinct(permno, permco, date, ret, .keep_all = T) #drop duplicates
crsp <- crsp %>% mutate_at(vars(matches("ret")), add_one) #add one to TSR


#this created the mutate formula -- paste0('ret','_',"l",seq(1:11), collapse = "*") get formula
#calculate tsr
tsr_calc <- crsp %>% group_by(permno, year) %>% filter(date==max(date)) %>% mutate(tsr1 = ((ret*ret_l1*ret_l2*ret_l3*ret_l4*ret_l5*ret_l6*ret_l7*ret_l8*ret_l9*ret_l10*ret_l11)-1)*100) %>% ungroup()
#isolate specific variables.
tsr_calc <- tsr_calc %>% select(cusip, permno, permco, date, year, tsr1)

rm(crsp)

#here we are merging linking information so that TSR can be merged to our larger dataframe.
comp <- comp %>% select(gvkey,cusip,cusip_8)
tsr_calc <- merge(tsr_calc, comp, by.x = 'cusip', by.y = 'cusip_8', all.x = T)
tsr_calc <- tsr_calc %>% rename(cusip_9 = cusip.y) %>% rename(cusip_8 = cusip)
df <- merge(df, tsr_calc, by = c('gvkey','year'), all.x = T)

rm(tsr_calc,comp)

