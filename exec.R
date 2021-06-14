#exec pull
#create object with unique gkvey
u_gvkey <- unique(df$gvkey)
#lazy pull execucomp data
first_pull_exec <- tbl(wrds, sql("select * from comp_execucomp.anncomp"))
#filter by input years
first_pull_exec <- first_pull_exec %>% filter(between(year, year_start,year_end))
#filter by gvkey object
first_pull_exec <- first_pull_exec %>% filter(gvkey %in% u_gvkey)
#full data pull
exec <- first_pull_exec %>% collect()
#for clean up later
cols_to_remove <- c(names(df),names(exec))
cols_to_remove <- cols_to_remove[cols_to_remove %notin% c('gvkey','fyear','year','tic','sich','cusip','cik','execid')]
