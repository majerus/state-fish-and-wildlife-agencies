# load from googlesheets and geocode new rows 

# helpful examples: https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples
                  # https://stackoverflow.com/questions/32537882/adding-rows-to-a-google-sheet-using-the-r-package-googlesheets

# sheet id (needs to be published and public on the web)
# see https://github.com/jennybc/googlesheets/issues/308
sheet_id <- "1oCeMj34imY9oytROS5CjxRjegibM6scZ1Vj9i--npgY"

# turn off auth
# sheets_deauth()

# read sheet into into a dataframe 
df <- read_sheet(sheet_id)

# preserve orginal col names
og_names <- colnames(df)

# clean col names
df <- clean_names(df)

# create df of new members without lat/lon
new_locations <- 
  df %>% 
  filter(is.na(longitude)) %>% 
  # TODO: should handle missing values here somehow...
  mutate(location = paste(address, city, state_province, sep = ", ")) %>% 
  select(-longitude, -latitude) 


# create geocoding function
# create OSM geocoding function
nominatim_osm <- function(address = NULL){
  
  out <- tryCatch({
    
    d <- jsonlite::fromJSON(
      gsub('\\@addr\\@', gsub('\\s+', '\\%20', address),
           'http://nominatim.openstreetmap.org/search/@addr@?format=json&addressdetails=0')
    )
    
    if(length(d) == 0){
      
      return(data.frame(longitude = NA, latitude = NA))
      
    }else{
      
      return(data.frame(longitude = as.numeric(d$lon), latitude = as.numeric(d$lat)))
      
    }
  },
  
  error = function(e){
    return(data.frame(longitude = NA, latitude = NA))
  }
  
  )
  return(out)
}


# TODO: sheet writing without auth not working with googlesheets4
# will need to auth via following function for now
# sheets_auth()

# if there are new locations (i.e. non-geocoded locations) geocode them 
# then combine back with previously geocoded locations
# and replace exisiting data in google sheet
if(nrow(new_locations) > 0){
  # geocode new locations 
  new_locations <- 
    new_locations %>%
    pull(location) %>% 
    map_df(~nominatim_osm(.)) %>% 
    bind_cols(new_locations, .) %>% 
    select(-location)
  
  # create df of locations with lat/lon 
  old_locations <- 
    df %>% 
    filter(!is.na(longitude))
  
  # combine new and old locations 
  df <- 
    new_locations %>% 
    bind_rows(old_locations) 
  
  # restore original col names 
  colnames(df) <- og_names
  
  # write data with new lat/lon to googlesheet
  sheets_write(data = df, 
               ss = sheet_id,
                sheet = "Form Responses 1")
}
