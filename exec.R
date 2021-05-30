#exec pull
u_gvkey <- unique(df$gvkey)
first_pull_exec <- tbl(wrds, sql("select * from comp_execucomp.anncomp where year between '",year_start,"'"," and '", year_end,"'"))
first_pull_exec <- first_pull_exec %>% filter(gvkey %in% u_gvkey)
pull_exec <- first_pull_exec %>% collect()
