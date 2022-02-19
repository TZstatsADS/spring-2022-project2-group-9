if (!require("shiny")) install.packages("shiny")
library(shiny)
if (!require("dplyr")) { install.packages("dplyr")}
library(dplyr)
if (!require("tidyverse")) { install.packages("tidyverse")}
library(tidyverse)
if (!require("DT")) { install.packages("DT")}
library(DT)
if (!require("ggplot2")) { install.packages("ggplot2")}
library(ggplot2)
if (!require("lubridate")) { install.packages("lubridate")}
library(lubridate)
if (!require("plotly")) { install.packages("plotly")}
library(plotly)
if (!require("hrbrthemes")) { install.packages("hrbrthemes")}
library(hrbrthemes)
if (!require("highcharter")) { install.packages("highcharter")}
library(highcharter)
if (!require("RColorBrewer")) { install.packages("RColorBrewer")}
library(RColorBrewer)
if(!require(fontawesome)) devtools::install_github("rstudio/fontawesome")
if (!require("geojsonio")) { install.packages("geojsonio")}
library(geojsonio)
if (!require("readr")) { install.packages("readr")}
library(readr)
if (!require("leaflet")) { install.packages("leaflet")}
library(leaflet)
if (!require("fontawesome")) { install.packages("fontawesome")}
library(fontawesome)

source("global.R")
library(shinydashboard)

shinyServer(function(input, output, session) {
  
  ## homepage box output #############################################
  
  ## map output #############################################
  output$map <- renderLeaflet({
    #covid cases parameters
    parameter <- if(input$choice == "7 day positive case count") {
      data$people_positive
    } else if(input$choice == "cumulative cases") {
      data2$COVID_CASE_COUNT
    } else {
      data2$COVID_DEATH_COUNT
    }
    
    #create palette  
    pal <- colorNumeric(
      palette = "Blues",
      domain = parameter)
    
    #create labels
    #Cleaned by emphasizing %Pos, case rate is other option
    labels <- paste(
      data$zip, " - ",
      data$modzcta_name, "<br/>",
      "Confirmed Cases: ", data$people_positive,"<br/>",
      "Cumulative cases: ", data2$COVID_CASE_COUNT,"<br/>",
      "Cumulative deaths: ", data2$COVID_DEATH_COUNT,"<br/>",
      "Tested number:",data$people_tested,"<br/>",
      "<b>Infection Rate: ", perp_zipcode[nrow(perp_zipcode),],"%</b><br/>",
      "Expected Infection Rate Next Week: ", predictions_perp,"%<br/>") %>%
      lapply(htmltools::HTML)
    
    map <- geo_data %>%
      select(-geometry) %>%
      leaflet(options = leafletOptions(minZoom = 8, maxZoom = 18)) %>%
      setView(-73.93, 40.80, zoom = 10) %>%
      addTiles() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addPolygons(
        fillColor = ~pal(parameter),
        weight = 1,
        opacity = .5,
        color = "white",
        dashArray = "2",
        fillOpacity = 0.7,
        highlight = highlightOptions(weight = 1,
                                     color = "yellow",
                                     dashArray = "",
                                     fillOpacity = 0.7,
                                     bringToFront = TRUE),
        label = labels) %>%
      addLegend(pal = pal, 
                values = ~parameter,
                opacity = 0.7, 
                title = htmltools::HTML(input$radio),
                position = "bottomright")
  })
  

  #covid vaccination button
  observeEvent(input$covid_vaccination, {
    proxy <- leafletProxy("map", data = covid_vaccination)
    proxy %>% clearControls()
    
    # clear the map
    # leafletProxy("map", data = covid_vaccination) %>%
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addProviderTiles("CartoDB.Voyager") %>%
    #   fitBounds(-74.354598, 40.919500, -73.761545, 40.520024)
    
    leafletProxy("map", data = covid_vaccination) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addAwesomeMarkers(~Longitude, ~Latitude, 
                        icon = awesomeIcons(markerColor= "lightred",
                                            text = fa("syringe")), label= ~Name,                                  
                        popup = paste(
                          "<b>Address:</b>", covid_vaccination$Location,", ", covid_vaccination$Zip_code,  "<br>",
                          "<b>Type:</b>", covid_vaccination$Type, "<br>",
                          "<b>Vaccine offered:</b>", covid_vaccination$Vaccine_offered, "<br>"))
  })     
  
  #Flu vaccination Button
  observeEvent(input$flu_vaccination, {
    proxy <- leafletProxy("map", data = flu_vaccination)
    proxy %>% clearControls()
    
    # clear the map
    # leafletProxy("map", data = covid_vaccination) %>%
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addProviderTiles("CartoDB.Voyager") %>%
    #   fitBounds(-74.354598, 40.919500, -73.761545, 40.520024)
    
    leafletProxy("map", data = flu_vaccination) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addAwesomeMarkers(~Longitude, ~Latitude, 
                        icon = awesomeIcons(markerColor= "darkblue",
                                            text = fa("syringe")),                                 
                        popup = paste(
                          "<b>Address:</b>", flu_vaccination$Address,", ", flu_vaccination$ZIP.Code,  "<br>",
                          "<b>For Children:</b>", flu_vaccination$Children, "<br>",
                          "<b>Walk-in:</b>", flu_vaccination$Walk.in, "<br>"))
  })
  
  
  #Wifi Spot Button
  observeEvent(input$wifi, {
    proxy <- leafletProxy("map", data = wifi)
    proxy %>% clearControls()
    
    # clear the map
    # leafletProxy("map", data = covid_vaccination) %>%
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addProviderTiles("CartoDB.Voyager") %>%
    #   fitBounds(-74.354598, 40.919500, -73.761545, 40.520024)
    
    leafletProxy("map", data = wifi) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addAwesomeMarkers(~LONGITUDE, ~LATITUDE, 
                        icon = awesomeIcons(markerColor= "green",
                                            text = fa("wifi")),                                 
                        popup = paste(
                          "<b>Address:</b>", wifi$ADDRESS,", ", wifi$POSTCODE,  "<br>",
                          "<b>Wifi Status:</b>", wifi$WIFI.STATUS, "<br>",
                          "<b>Tablet Status:</b>", wifi$TABLET.STATUS, "<br>",
                          "<b>Phone Status:</b>", wifi$PHONE.STATUS, "<br>"))
  })
  
  
  #Food Center Button
  observeEvent(input$food, {
    proxy <- leafletProxy("map", data = food)
    proxy %>% clearControls()
    
    # clear the map
    # leafletProxy("map", data = covid_vaccination) %>%
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addProviderTiles("CartoDB.Voyager") %>%
    #   fitBounds(-74.354598, 40.919500, -73.761545, 40.520024)
    
    leafletProxy("map", data = food) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addAwesomeMarkers(~Longitude, ~Latitude, 
                        icon = awesomeIcons(markerColor= "black",
                                            text = fa("utensils")),                                 
                        popup = paste(
                          "<b>Address:</b>", food$Address,", ", food$Zip.Code,  "<br>",
                          "<b>Center Name:</b>", food$Name, "<br>",
                          "<b>Contact Number:</b>", food$Contact, "<br>"
                        ))
  })
  
  
  #Drop In Center Button
  observeEvent(input$drop_in, {
    proxy <- leafletProxy("map", data = drop_in)
    proxy %>% clearControls()
    
    # clear the map
    # leafletProxy("map", data = covid_vaccination) %>%
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addProviderTiles("CartoDB.Voyager") %>%
    #   fitBounds(-74.354598, 40.919500, -73.761545, 40.520024)
    
    leafletProxy("map", data = drop_in) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addAwesomeMarkers(~Longitude, ~Latitude, 
                        icon = awesomeIcons(markerColor= "orange",
                                            text = fa("building")),                                 
                        popup = paste(
                          "<b>Address:</b>", drop_in$Address,", ", drop_in$Postcode,  "<br>",
                          "<b>Center Name:</b>", drop_in$Center.Name, "<br>"
                        ))
  })
  
  #Job Center Button
  observeEvent(input$job, {
    proxy <- leafletProxy("map", data = job)
    proxy %>% clearControls()
    
    # clear the map
    # leafletProxy("map", data = covid_vaccination) %>%
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addProviderTiles("CartoDB.Voyager") %>%
    #   fitBounds(-74.354598, 40.919500, -73.761545, 40.520024)
    
    leafletProxy("map", data = job) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addAwesomeMarkers(~Longitude, ~Latitude, 
                        icon = awesomeIcons(markerColor= "beige",
                                            text = fa("briefcase")),                                 
                        popup = paste(
                          "<b>Address:</b>", job$Address,", ", job$Postcode,  "<br>",
                          "<b>Agency:</b>", job$AGENCY, "<br>",
                          "<b>Contact Number:</b>", job$Contact.Number, "<br>"
                        ))
  })
  
  #Youth Drop=in Button
  observeEvent(input$youth_drop_in, {
    proxy <- leafletProxy("map", data = youth_drop_in)
    proxy %>% clearControls()
    
    # clear the map
    # leafletProxy("map", data = covid_vaccination) %>%
    #   clearShapes() %>%
    #   clearMarkers() %>%
    #   addProviderTiles("CartoDB.Voyager") %>%
    #   fitBounds(-74.354598, 40.919500, -73.761545, 40.520024)
    
    leafletProxy("map", data = youth_drop_in) %>%
      clearMarkers() %>%
      clearMarkerClusters() %>%
      addAwesomeMarkers(~Longitude, ~Latitude, 
                        icon = awesomeIcons(markerColor= "purple",
                                            text = fa("bed")),                                 
                        popup = paste(
                          "<b>Address:</b>", youth_drop_in$Number.and.Street.Address,", ", youth_drop_in$Postcode,  "<br>",
                          "<b>Agency:</b>", youth_drop_in$AGENCY, "<br>",
                          "<b>Contact Number:</b>", youth_drop_in$Contact.Number, "<br>"
                        ))
  })
  
})