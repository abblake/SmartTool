#exec pull
u_gvkey <- unique(df$gvkey)
first_pull_exec <- tbl(wrds, sql("select * from comp_execucomp.anncomp"))
first_pull_exec <- first_pull_exec %>% filter(between(year, year_start,year_end))
first_pull_exec <- first_pull_exec %>% filter(gvkey %in% u_gvkey)
exec <- first_pull_exec %>% collect()
cols_to_remove <- c(names(df),names(exec))
cols_to_remove <- cols_to_remove[cols_to_remove %notin% c('gvkey','fyear','year','tic','sich','cusip','cik','execid')]
