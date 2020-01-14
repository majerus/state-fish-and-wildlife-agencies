# create shinydashboard page
dashboardPage(
  
  # dashboard header
  dashboardHeader(title = "Map"),
  
  # dashboard sidebar
  dashboardSidebar(
    # could put filter here
  ),
  
  # dashboard body
  dashboardBody(
    
    # map
    fluidRow(
      box(
        width = 12, 
        title = "Map", 
        status = "primary", 
        solidHeader = TRUE,
        collapsible = TRUE,
        leafletOutput("my_map")
      )
    ),
    
    # data table
    fluidRow(
      box(
        width = 12, 
        title = "Table",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        DT::dataTableOutput("my_table")
      )
    ))
)
