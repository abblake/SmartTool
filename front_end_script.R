div_code <- FALSE
  asip_code <- FALSE
	`%notin%` <- Negate(`%in%`)
    #need to ask you a few questions

    #where do you want the file saved?
    setwd(choose.dir())

    #what do you want the file named?
    file_name <- dlg_input(message = "Name of file? (without extension)")$res

      #what type of file?
      current_export_list <- c('Stata', 'CSV')
        file_type <- dlg_list(current_export_list, multiple = F)$res


          #sample start year
          year_start <- dlg_input(message = "What year should your sample start? (e.g., 2000)")$res %>% as.numeric()
            year_end <- dlg_input(message = "What year should your sample end? (e.g., 2000)")$res %>% as.numeric()

print('*******Database pull has begun. This will take some time (5-10 minutes), please be patient.*******')
              ###adapted from https://wrds-www.wharton.upenn.edu/, connects you to WRDS DB
            print("Please enter your WRDS credentials.")
            wrds <- dbConnect(Postgres(),
                                  host='wrds-pgdata.wharton.upenn.edu',
                                  port=9737,
                                  dbname='wrds',
                                  sslmode='require',
                                  user=rstudioapi::askForPassword("WRDS Username") %>% tolower(),
                                  password=rstudioapi::askForPassword("WRDS password"))


if(!exists('wrds')){
  print('You did not enter your WRDS credentials accurately. Please try again.')
}
              if(!exists('wrds')){
                wrds <- dbConnect(Postgres(),
                                  host='wrds-pgdata.wharton.upenn.edu',
                                  port=9737,
                                  dbname='wrds',
                                  sslmode='require',
                                  user=rstudioapi::askForPassword("WRDS username")  %>% tolower(),
                                  password=rstudioapi::askForPassword("WRDS password"))
              }
              if(!exists('wrds')){
                print('Your WRDS creentials are still not accurate. Please verify your username and password with WRDS. The script will not work otherwise.')
              }

            ###connect and pull compustat data based on year
                pulled <- dbSendQuery(wrds, paste0("select *
                   from comp.funda
                   where fyear between '",year_start,"'","
                   and '",year_end,"'
                   and datafmt = 'STD'
                   and consol = 'C'
                   and indfmt = 'INDL'
                   and popsrc = 'D'
		   and exchg = '11' 
		   or exchg = '14' 
		   or exchg = '15'  "))
                  df <- dbFetch(pulled, n=-1)
                    dbClearResult(pulled)
                    df$year <- df$fyear
#get vector of unique gvkeys
u_gvkey <- unique(df$gvkey)
#this will be used to create the 'small' dataframe at the end of the script
cols_to_remove <- names(df)
cols_to_remove <- cols_to_remove[cols_to_remove %notin% c('gvkey','fyear','year','tic','sich','cusip','cik')]

