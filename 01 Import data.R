
# Load packages
if(!require(httr)){
  install.packages("httr")
  library(httr)
}

if(!require(jsonlite)){
  install.packages("jsonlite")
  library(jsonlite)
}

if(!require(xlsx)){
  install.packages("xlsx")
  library(xlsx)
}

# Task 1: Download the ACAPS dataset

  ## Post credentials to get an authentication token
  credentials <- list(username="XXX", password="XXX")
  auth_token_response <- httr::POST("https://api.acaps.org/api/v1/token-auth/", body=credentials)
  auth_token <- httr::content(auth_token_response)$token

  ## Pull data from ACAPS API and loop through the pages
  df <- data.frame()
  request_url <- "https://api.acaps.org/api/v1/government-measures/" # Replace with the URL of the dataset you want to access
  last_request_time <- Sys.time()
  while (TRUE) {
  
  ## Wait to avoid throttling
  while (as.numeric(Sys.time()-last_request_time) < 1) {
    Sys.sleep(0.1)
  }
  
  ## Make the request
  response <- httr::GET(request_url, add_headers(Authorization=paste("Token", auth_token, sep=" ")))
  last_request_time <- Sys.time()
  
  ## Append to the dataframe
  df_results <- jsonlite::fromJSON(content(response, "text"))$results
  df <- rbind(df, df_results)
  
  ## Loop to the next page; if we are on the last page, break the loop
  if (("next" %in% names(content(response))) && (typeof(content(response)[["next"]]) != "NULL")) {
    request_url <- content(response)[["next"]]
  }
  else {
    break
   }
  }
  
  ##rename to measures
  measures<-df

  ## Save the dataset in excel
  write.xlsx(measures,"~/GitHub/covid-data-ODI-submittion/govmes_acaps.xlsx")

#Task2: Download the Johns Hopkins COVID-19 cases dataset

  ## Download datasets of daily cases and deaths
  cases<-read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv",header=TRUE,sep=",",dec=".")
  deaths<-read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv",header=TRUE,sep=",",dec=".")
  ISO3<-read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv",header=TRUE,sep=",",dec=".")

#Import regional groups dataset
  countries<-read.csv("~/GitHub/covid-data-ODI-submittion/Lists.csv",header = TRUE,sep=",")
  
  # Clean the environment
rm(list=setdiff(ls(), c("measures","cases","deaths","ISO3","countries")))
  