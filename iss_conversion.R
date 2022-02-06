# Quigley et al. Data Patch for ISS/Risk Metric
# Write up comming soon.
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, dbplyr, RPostgres, lubridate, haven, stringr, svDialogs, janitor, devtools)
#Adjusting post 2007 ISS/Risk Metric data
iss_sql <- tbl(wrds, sql('select * from risk.rmdirectors'))
iss_sql <- iss_sql %>% filter(between(year,year_start,year_end))
iss <- iss_sql %>% collect()
iss <- iss %>% select(-priorserv)
iss <- iss %>% rename(cusip9 = cusip, coname = name,nomine_type = nominee)

iss <- iss %>% mutate(age =  ifelse(age == '1' | age == '2015', '.',age))
iss <- iss %>% mutate(dirsince = ifelse(dirsince == '0', '.',dirsince))
iss <- iss %>% mutate(year_term_ends = ifelse(year_term_ends == '3010', '2010',year_term_ends))
iss <- iss %>% mutate(stringlength = nchar(cusip9))
iss <- iss %>% mutate(cusip9 = case_when(
  stringlength == 8 ~ paste0('0',cusip9),
  stringlength == 7 ~ paste0('00',cusip9),
  stringlength == 6 ~ paste0('000',cusip9),
  TRUE ~ as.character(cusip9)
))


iss$audit_chair <- grepl('chair', iss$audit_membership, ignore.case = T) %>% as.numeric()
iss$cg_chair <- grepl('chair', iss$cg_membership, ignore.case = T) %>% as.numeric()
iss$comp_chair<- grepl('chair', iss$comp_membership, ignore.case = T) %>% as.numeric()
nom_chair <- grepl('chair', iss$nom_membership, ignore.case = T) %>% as.numeric()

iss$audit_membership <-grepl(c('chair|member'), iss$audit_membership, ignore.case = T) %>% as.numeric()
iss$cg_membership <- grepl('chair|member', iss$cg_membership, ignore.case = T) %>% as.numeric()
iss$comp_membership  <- grepl('chair|member', iss$comp_membership, ignore.case = T) %>% as.numeric()
iss$nom_membership <- grepl('chair|member', iss$nom_membership, ignore.case = T) %>% as.numeric()


yes_nolst <- c("attend_less75_pct","business_transaction","charity","designated","employment_ceo","employment_cfo","employment_chairman","employment_coo","employment_evp","employment_president","employment_secretary","employment_svp","employment_treasurer","employment_vicechairman","employment_vp","female","financial_expert","former_employee_yn","interlocking","otherlink","ownless1","prof_services_yn","relative_yn","succ_comm")
iss <- iss %>% mutate_at(yes_nolst, ~ if_else(. == "YES", "1","0") )

#Patching known issues with data
iss <- iss %>% mutate(cusip9 = case_when(
  coname=="AMERICAN EAGLE OUTFITTERS, INC." ~  "02553E10",
  coname=="AMERISOURCEBERGEN CORP" ~ "03073E105",
  coname=="ARQULE, INC." ~ "04269E107",
  coname=="BRE PROPERTIES, INC." ~ "05564E106",
  coname=="CKE RESTAURANTS, INC." ~ "12561E105",
  coname=="EDWARDS LIFESCIENCES CORPORATION" ~ "28176E108",
  coname=="EMBARQ CORP" ~ "29078E105",
  coname=="INVENTIV HEALTH, INC." ~ "46122E105",
  coname=="J2 GLOBAL COMMUNICATIONS, INC." ~ "46626E106",
  coname=="JAKKS PACIFIC, INC." ~ "47012E106",
  coname=="NCR CORPORATION" ~ "62886E108",
  coname=="NEWS CORPORATION" ~ "65248E104",
  coname=="NSTAR" ~ "67019E107",
  coname=="QUANTA SERVICES, INC." ~ "74762E102",
  coname=="TARGET CORPORATION" ~ "87612E106",
  coname=="THE DUN & BRADSTREET CORP" ~ "26483E100",
  coname=="THE TRAVELERS COMPANIES, INC." ~ "89417E109",
  coname=="VERISIGN, INC." ~ "92343E102",
  coname=="CAPTARIS, INC." ~ "14071N104",
  coname=="SECURE COMPUTING CORP." ~ "813705100",
  TRUE ~ as.character(cusip9)
))

iss <- iss %>% mutate(cusip6 = substr(cusip9,1,6))

iss <- iss %>% mutate(cusip6 = case_when(
  year==2007 & coname=="AMERICAN INTERNATIONAL GROUP, INC." ~ "026874",
  year==2007 & coname=="AUTONATION, INC." ~ "05329W",
  year==2007 & coname=="BANK OF AMERICA CORP." ~ "060505",
  year==2007 & coname=="BASIC ENERGY SERVICES, INC" ~ "06985P",
  year==2007 & coname=="BE AEROSPACE, INC." ~ "073302",
  year==2007 & coname=="CIT GROUP INC" ~ "125581",
  year==2007 & coname=="CITIGROUP INC." ~ "172967",
  year==2007 & coname=="DOWNEY FINANCIAL CORP." ~ "261018",
  year==2007 & coname=="DYNEGY, INC." ~ "26816Q",
  year==2007 & coname=="ELECTRONIC DATA SYSTEMS CORP." ~ "285661",
  year==2007 & coname=="FORD MOTOR COMPANY" ~ "345370",
  year==2007 & coname=="FRANKLIN BANK CORP." ~ "352451",
  year==2007 & coname=="GENERAL ELECTRIC CO." ~ "369604",
  year==2007 & coname=="IRWIN FINANCIAL CORP." ~ "464119",
  year==2007 & coname=="JPMORGAN CHASE & CO." ~ "46625H",
  year==2007 & coname=="LANDAMERICA FINANCIAL GROUP, INC." ~ "514936",
  year==2007 & coname=="LEHMAN BROTHERS HOLDINGS INC." ~ "524908",
  year==2007 & coname=="MANHATTAN ASSOCIATES, INC." ~ "562750",
  year==2007 & coname=="MENTOR CORP." ~ "587188",
  year==2007 & coname=="MOLSON COORS BREWING CO" ~ "60871R",
  year==2007 & coname=="ORACLE CORP." ~ "68389X",
  year==2007 & coname=="PIPER JAFFRAY COS" ~ "724078",
  year==2007 & coname=="PLAINS EXPLORATION & PRODUCTION CO" ~ "726505",
  year==2007 & coname=="PRINCIPAL FINANCIAL GROUP, INC." ~ "74251V",
  year==2007 & coname=="QUICKSILVER RESOURCES INC." ~ "74837R",
  year==2007 & coname=="REGENCY CENTERS CORP." ~ "758849",
  year==2007 & coname=="SELECT COMFORT CORPORATION" ~ "81616X",
  year==2007 & coname=="STANDARD REGISTER CO." ~ "853887",
  year==2007 & coname=="THE BEAR STEARNS COMPANIES INC." ~ "073902",
  year==2007 & coname=="THE BOEING CO." ~ "097023",
  year==2007 & coname=="THE STANLEY WORKS" ~ "854616",
  year==2007 & coname=="TUESDAY MORNING CORP." ~ "899035",
  year==2007 & coname=="UNITED PARCEL SERVICE, INC." ~ "911312",
  year==2007 & coname=="VALERO ENERGY CORP." ~ "91913Y",
  year==2007 & coname=="VOLT INFORMATION SCIENCES, INC." ~ "928703",
  year==2007 & coname=="WELLS FARGO AND COMPANY" ~ "949746",
  year==2007 & coname=="WENDY'S INTERNATIONAL, INC." ~ "950590",
  year==2007 & coname=="WILLIAMS-SONOMA, INC." ~ "969904",
  TRUE ~ as.character(cusip6)
))

#Download legacy pre-2007 data
iss_legacy <- tbl(wrds, sql('select * from risk.directors'))
iss_legacy <- iss_legacy %>% rename(cusip6 = cusip, coname = name, nom_chair = nomchair)
iss_legacy <- iss_legacy %>% filter(between(year,year_start,year_end))
iss_legacy <- iss_legacy %>% collect()

#Final data adjustments before append/rbind/joining the two datasets together
iss_legacy <- type.convert(iss_legacy, na.strings = 'NA', as.is=T)
iss <- type.convert(iss, na.strings = 'NA', as.is=T)
iss$female <- grepl('yes', iss$female, ignore.case = T) %>% as.numeric()
iss$age <- as.numeric(iss$age)
iss$dirsince <- as.numeric(iss$dirsince)

#Append/rbind/joining
if(nrow(iss) > 0){
new_iss <- bind_rows(iss_legacy, iss)
rm(iss,iss_legacy)}else{
  new_iss <- iss_legacy
  rm(iss,iss_legacy)
}

#Patching known issues with data
new_iss <- new_iss %>% mutate(meetingdate = case_when(
  cusip6=="55261F" & year==1996 ~ '1996-04-16',
  cusip6=="989390" & year==1996 ~ '1996-05-22',
  cusip6=="989922" & year==2008 ~ '2008-01-20',
  cusip6=="G98255" & year==2008 ~ '2008-05-25',
  TRUE ~ as.character(meetingdate)

)) %>% mutate(fullname = case_when(
  cusip6=="009158" & year==1997 & is.na(fullname)  ~ "JAMES F. HARDYMON",
  cusip6=="019589" & year==2007 & fullname=="LEON J LEVEL" ~ "DENNIS R. HENDRIX",
  cusip6=="233293" & year==2007 & fullname=="FRANK F GALLAGHER" ~ "ERNIE GREEN"      ,
  cusip6=="115236" & year==2008 & fullname=="J BROWN" & first_name=="J. HYATT" ~ "J. HYATT BROWN"   ,
  cusip6=="115236" & year==2008 & fullname=="J BROWN" & first_name=="J. POWELL" ~ "J. POWELL BROWN"  ,
  cusip6=="691497" & year==2008 & fullname=="J LANIER" & first_name=="J. HICKS" ~ "J. HICKS LANIER"  ,
  cusip6=="691497" & year==2008 & fullname=="J LANIER" & first_name=="J. REESE" ~ "J. REESE LANIER"  ,
  TRUE ~ as.character(fullname)

)) %>% mutate(first_name = case_when(

  cusip6=="009158" & year==1997 & fullname=="JAMES F. HARDYMON" ~ "JAMES F." ,
  cusip6=="019589" & year==2007 & fullname=="DENNIS R. HENDRIX" ~ "DENNIS R.",
  cusip6=="233293" & year==2007 & fullname=="ERNIE GREEN" ~ "ERNIE"  ,
  TRUE ~ as.character(first_name)
)) %>% mutate(last_name = case_when(
  cusip6=="009158" & year==1997 & fullname=="JAMES F. HARDYMON" ~  "HARDYMON",
  cusip6=="019589" & year==2007 & fullname=="DENNIS R. HENDRIX" ~ "HENDRIX"  ,
  cusip6=="233293" & year==2007 & fullname=="ERNIE GREEN" ~ "GREEN"    ,
  TRUE ~ as.character(last_name)
)) %>% filter(!(cusip6=="05367P" & year==2007 & fullname=="JOHN H PARK")) %>%
  filter(!(cusip6=="179895" & year==2007 & fullname=="ARTHUR B LAFFER")) %>%
  filter(!(cusip6=="03761U")) %>%
  filter(!(fullname=="JANET HILL" & cusip6=="448407")) %>%
  filter(!(fullname=="TRIP HAWKINS")) %>%
  filter(!(cusip6=="030954" & year==1997 & mtgmonth==7)) %>%
  filter(!(cusip6=="089159" & year==1999 & mtgmonth==11)) %>%
  filter(!(cusip6=="268039" & year==1997 & mtgmonth==5)) %>%
  filter(!(cusip6=="313135" & year==1997 & mtgmonth==12)) %>%
  filter(!(cusip6=="31787A" & year==2001 & mtgmonth==6)) %>%
  filter(!(cusip6=="461202" & year==1999 & mtgmonth==1)) %>%
  filter(!(cusip6=="591695" & year==1997 & mtgmonth==5)) %>%
  filter(!(cusip6=="595112" & year==1996 & mtgmonth==1)) %>%
  filter(!(cusip6=="595112" & year==2000 & mtgmonth==1)) %>%
  filter(!(cusip6=="867910" & year==1996 & mtgmonth==4)) %>%
  filter(!(cusip6=="913283" & year==1998 & mtgmonth==6)) %>%
  filter(!(cusip6=="929903" & year==2001 & mtgmonth==7)) %>%
  filter(!(cusip6=="247909" & year==1997 & fullname=="BUCK A MICKEL" & age==71)) %>%
  mutate(classification = case_when(
    year==2006 & fullname=="URSULA O FAIRBAIRN" & ticker=="CC" ~ "I",
    cusip6=="009158" & year==1997 & fullname=="JAMES F. HARDYMON" ~ "I",
    cusip6=="019589" & year==2007 & fullname=="DENNIS R. HENDRIX" ~ "I",
    cusip6=="912909" & year==1999 & fullname=="THOMAS J USHER" ~ "E",
    cusip6=="912909" & year==1999 & fullname=="ROBERT M HERNANDEZ"  ~ "E",
    cusip6=="912909" & year==1999 & is.na(classification) ~ "I",
    cusip6=="03662Q" & year==2007 & fullname=="WILLIAM R MCDERMOTT"  ~ "I",
    cusip6=="03662Q" & year==2007 & fullname=="MICHAEL C THURK" ~ "I",
    cusip6=="07556Q" & year==2005 & fullname=="PETER G LEEMPUTTE" ~ "I",
    cusip6=="233293" & year==2007 & fullname=="ERNIE GREEN" ~ "I",
    cusip6=="354613" & year==2005 & fullname=="JOSEPH R HARDIMAN" ~ "I",
    cusip6=="354613" & year==2005 & fullname=="LAURA STEIN" ~ "I",
    cusip6=="759148" & year==2007 & fullname=="CHRISTOPHER T HJELM"  ~ "I",
    cusip6=="830879" & year==2007 & fullname=="JAMES L WELCH" ~ "I",
    classification=="NA" ~ "I",
    classification=="ND" ~ "E",
    TRUE ~ as.character(classification)
  )) %>% mutate(age = case_when(
    year==1996 & fullname=="AARON I FLEISCHMAN" ~ 56,
    year==1997 & fullname=="AARON I FLEISCHMAN" ~ 57,
    year==2001 & fullname=="ALLEN B MORGAN" ~ 58,
    year==1997 & fullname=="DAVID W BURKHOLDER" ~ 54,
    year==1997 & fullname=="DONALD S PERKINS" ~ 69,
    year==1998 & fullname=="DONALD S PERKINS" ~ 70,
    year==1997 & fullname=="JACK W BUSBY" ~ 54,
    year==1997 & fullname=="JAMES C TAYLOR" ~ 59,
    year==1997 & fullname=="JOHN P MAMANA" ~ 54,
    year==1998 & fullname=="LOWELL P WEIKER JR" ~ 67,
    year==1999 & fullname=="MARVIN P BUSH" ~ 42,
    year==2000 & fullname=="MARVIN P BUSH" ~ 43,
    year==2001 & fullname=="MARVIN P BUSH" ~ 44,
    year==1996 & fullname=="MARY A MALONE" ~ 46,
    year==2001 & fullname=="PHILIP LADER" ~ 55,
    year==1999 & fullname=="R DOUGLAS BRADBURY" ~ 48,
    year==1996 & fullname=="ROBERT A STINE" ~ 49,
    year==1996 & fullname=="ROBERT ALPERT" ~ 64,
    year==1998 & fullname=="ROBERT D ROSENTHAL" ~ 49,
    year==1999 & fullname=="ROBERT D ROSENTHAL" ~ 50,
    year==2004 & fullname=="SHAREE ANN UMPIERRE" ~ 44,
    year==1998 & fullname=="STACY S DICK" ~ 42,
    year==1999 & fullname=="STACY S DICK" ~ 43,
    year==2007 & fullname=="JOHN ADAMS" ~ 59,
    year==2007 & fullname=="STEVEN H BAER" ~ 57,
    year==2007 & fullname=="RONALD C BALDWIN" ~ 60,
    year==2007 & fullname=="GEOFFREY BALLOTTI" ~ 44,
    year==2007 & fullname=="ALFRED CASTINO" ~ 54,
    year==2007 & fullname=="TZAU-JIN (T CHUNG" ~ 44,
    year==2007 & fullname=="GLOSTER B CURRENT JR." ~ 61,
    year==2007 & fullname=="THOMAS A GERKE" ~ 50,
    year==2007 & fullname=="ANDERS GUSTAFSSON" ~ 46,
    year==2007 & fullname=="CHRISTOPHER T HJELM" ~ 45,
    year==2007 & fullname=="ROBERT T JACKSON" ~ 61,
    year==2007 & fullname=="JAMES B JENNINGS" ~ 66,
    year==2005 & fullname=="MICHAEL LINTON" ~ 48,
    year==2007 & fullname=="NEIL J METVINER" ~ 48,
    year==2007 & fullname=="JOHN J MOSES" ~ 48,
    year==2007 & fullname=="PHILIPPE R ROLLIER" ~ 65,
    year==2007 & fullname=="F SCHIEWITZ" ~ 57,
    year==2007 & fullname=="DANIEL C STEVENS" ~ 51,
    year==2007 & fullname=="JAMES L WELCH" ~ 52,
    year==2007 & fullname=="CARL P ZEITHAML" ~ 57,
    year==2006 & fullname=="JOHN R BIRK" ~ 54,
    year==2009 & fullname=="RON HARBOUR" ~ 52,
    year==2009 & fullname=="JOHN D. WAKELIN" ~ 73,
    TRUE ~ as.numeric(age)

  )) %>% mutate(year = case_when(
    cusip6=="00204C" & year==1998 & mtgmonth==1 ~ 1997,
    cusip6=="247357" & year==2000 & mtgmonth==3 ~ 1999,
    cusip6=="269246" & year==1999 & mtgmonth==3 ~ 1998,
    cusip6=="291525" & year==2001 & mtgmonth==1 ~ 2000,
    cusip6=="461202" & year==1996 & mtgmonth==11 ~ 1997,
    cusip6=="637657" & year==2000 & mtgmonth==12 ~ 2001,
    cusip6=="668367" & year==1997 & mtgmonth==12 ~ 1998,
    cusip6=="682680" & year==1996 & mtgmonth==12 ~ 1997,
    cusip6=="918914" & year==1997 & mtgmonth==10 ~ 1998,
    cusip6=="693262" & year==2000 & coname=='P-COM "1999"' ~ 1999,
    TRUE ~ as.numeric(year)
  )) %>% mutate(outside_public_boards = ifelse(year==2001 & fullname=="SHIRLEY A JACKSON", 4, outside_public_boards)) %>%
  mutate(pcnt_ctrl_votingpower = ifelse(pcnt_ctrl_votingpower==8190, '.', pcnt_ctrl_votingpower))  %>%
  mutate(meetingdate = ifelse(year==2007 & fullname=="NANCY H KARP" & ticker=="CATT", '2007-01-30', meetingdate)) %>%
  mutate(dirsince = ifelse(year==2006 & fullname=="URSULA O FAIRBAIRN" & ticker=="CC", 2005, meetingdate)) %>%
  mutate(num_of_shares = ifelse(year==2006 & fullname=="URSULA O FAIRBAIRN" & ticker=="CC", 13020, num_of_shares))
new_iss$meetingdate <- ymd(new_iss$meetingdate)


#Downloading CRSP link table to add PERMCO identifier
u_cusip6 <- unique(new_iss$cusip6)
cusip_permco_link <- tbl(wrds, sql('select extract(year from date) as year,date,comnam, ncusip, permco from crsp.dse'))
cusip_permco_link <- cusip_permco_link %>% mutate(cusip6 = substr(ncusip,1,6))
cusip_permco_link <- cusip_permco_link %>% filter(cusip6 %in% u_cusip6)
cusip_permco_link <- cusip_permco_link %>% distinct()
cusip_permco_link <- cusip_permco_link %>% filter(year >= 1968) %>% select(-year)
cusip_permco_link <- cusip_permco_link %>% collect()
cusip_permco_link <- cusip_permco_link %>% distinct()

#Merging
new_iss_m <- merge(new_iss, cusip_permco_link, by='cusip6', all = F)
new_iss_m <- new_iss_m %>% distinct()
new_iss_m <- new_iss_m %>% rename(coname_crsp = comnam, lpermco = permco, tic = ticker) %>% arrange(lpermco, year)

#Adding GVKEY with CCM Link table.
u_lpermco <- unique(new_iss_m$lpermco)
tryccm <- try(tbl(wrds, sql('select gvkey, lpermco from crsp.ccmxpf_linktable')), silent = T)
if(grepl('Error', tryccm) == F){
ccm_link <- tbl(wrds, sql('select gvkey, lpermco from crsp.ccmxpf_linktable'))} else{print("Permission denied to CCMXPF linktable. Using alternative method to gather link information.")}
if(exists('ccm_link')){
ccm_link <- ccm_link %>% filter(!is.na(lpermco)) %>% filter(lpermco %in% u_lpermco)
ccm_link <- ccm_link %>% collect()
new_iss_m <- merge(new_iss_m, ccm_link, by='lpermco')}


#If CCM link table is not available, an alternative method will be triggered to link GVKEYS to data.
if(!exists('ccm_link')){
  p_load(devtools)
  devtools::source_url('https://raw.githubusercontent.com/abblake/START/main/gvkey-cusip-link.R')}
  if(exists('ccm_link')){rm(ccm_link)}


     ###Add in compustat vars for ownership
     comp_iss <- tbl(wrds, sql("select gvkey, datadate, fyear as year, prcc_f, csho as csho_iss from comp.funda where
                   datafmt = 'STD'
                   and consol = 'C'
                   and indfmt = 'INDL'
                   and popsrc = 'D'
		               and exchg = '11'"))
     u_gvkey_iss <- unique(df$gvkey)
     comp_iss <- comp_iss %>% filter(gvkey %in% u_gvkey_iss)
     comp_iss <- comp_iss %>% filter(between(year, year_start, year_end))
     comp_iss <- comp_iss %>% collect()

     #Merge files
     new_iss_m <- merge(new_iss_m, comp_iss, by=c('gvkey','year'), all.x = T)

     #Known issue with meeting year, this fixes. See write up for details
     new_iss_m <- new_iss_m %>% mutate(yearcheck=ymd(datadate) - ymd(meetingdate))
     new_iss_m <- new_iss_m %>% mutate(year = ifelse(yearcheck<0, year+1, year))
     new_iss_m <- new_iss_m %>% select(-yearcheck, -datadate, -prcc_f,-csho_iss)
     new_iss_m <- merge(new_iss_m, comp_iss, by=c('gvkey','year'), all=T)
     new_iss_m <- new_iss_m %>% mutate(yearcheck=ymd(datadate) - ymd(meetingdate))
     new_iss_m <- new_iss_m %>% filter(!is.na(year))
     new_iss_m <- new_iss_m %>% distinct(cusip6, year, meetingdate, fullname, .keep_all = T)

     #Boardsize calculations -- boardsize variable name
     new_iss_m <- new_iss_m %>% arrange(cusip6, year, meetingdate, fullname) %>% group_by(cusip6, year, meetingdate) %>% mutate(boardsize=n()) %>% ungroup()
     #Outsiders calculations -- outsiders variable name
     new_iss_m <- new_iss_m %>% arrange(cusip6, year, meetingdate, fullname) %>% group_by(cusip6, year, meetingdate) %>% mutate(outsiders = sum(classification=="I")) %>% ungroup()
     #Outsider ratio calculations -- board_independence variable name
     new_iss_m <- new_iss_m %>% arrange(cusip6, year, meetingdate, fullname) %>% group_by(cusip6, year, meetingdate) %>% mutate(board_independence = I(outsiders/boardsize)) %>% ungroup()

     #Director ownership calculations -- director_ownership_avg variable name
     new_iss_m <- new_iss_m %>% arrange(cusip6, year, meetingdate, fullname) %>% group_by(cusip6, year, meetingdate) %>% mutate(director_ownership = I(num_of_shares*prcc_f/1000)) %>% ungroup()
     new_iss_m <- new_iss_m %>% arrange(cusip6, year, meetingdate, fullname) %>% group_by(cusip6, year, meetingdate) %>% mutate(director_ownership_avg = mean(director_ownership, na.rm=T)) %>% ungroup()

     #Number of female board members -- countfemale variable name
     new_iss_m <- new_iss_m %>% arrange(cusip6, year, meetingdate, fullname) %>% group_by(cusip6, year, meetingdate) %>% mutate(countfemale = sum(female, na.rm=T)) %>% ungroup()

     #Drop down to single year
     new_iss_m <- new_iss_m %>% distinct(gvkey,year, .keep_all = T)
     new_iss_m_small <- new_iss_m %>% select(gvkey, year, cusip6,ncusip, boardsize, meetingdate, board_independence, director_ownership_avg, countfemale)


     df <- merge(df, new_iss_m_small, by=c('gvkey', 'year'), all.x=T)

     rm(new_iss, new_iss_m,new_iss_m_small)
