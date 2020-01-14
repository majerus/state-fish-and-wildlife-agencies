
function(input, output){ 
  
  # source geocoding script to geocode any new locations to googlesheet  
  source("geocoding.R")
  
  # make popup text with name, address, notes, and link to website
  df <-
    df %>% 
    mutate(popup = paste(first_name, last_name))
  
  # create leaflet map output
  output$my_map <- renderLeaflet({
    
    # setup basemap
   df %>%  
      leaflet() %>% 
      addTiles() %>% 
      addCircleMarkers(popup = ~popup)
  })
  
  # create data table of locations that are visible on the map
  output$my_table <- DT::renderDataTable({
    
    # get current bounds of map
    bounds <- input$my_map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    df %>% 
      # apply map filters
      filter(longitude >= lngRng[1],
             longitude <= lngRng[2],
             latitude >= latRng[1],
             latitude <= latRng[2]) %>% 
      select(first_name, last_name, organization, division_department)
  }, rownames = FALSE) # because rownames :(
  
}