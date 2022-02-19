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
      }else if(input$choice == "crime"){
        crime$CRIME_COUNT_2021
      }
      else {
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
      "Crime count: ", crime$CRIME_COUNT_2021,";",crime$PRECINCT,"<br/>") %>%
      #"Expected Infection Rate Next Week: ", predictions_perp,"%<br/>") %>%
      lapply(htmltools::HTML)
    # map <- crime %>%
    #   select(the_geom) %>%
    #   leaflet(options = leafletOptions(minZoom = 8, maxZoom = 18)) %>%
    #   setView(-73.93, 40.70, zoom = 10) %>%
    #   addTiles() %>%
    #   addProviderTiles("CartoDB.Positron") %>%
    #   addPolygons(
    #     fillColor = ~pal(parameter),
    #     weight = 1,
    #     opacity = .5,
    #     color = "white",
    #     dashArray = "2",
    #     fillOpacity = 0.7,
    #     highlight = highlightOptions(weight = 1,
    #                                  color = "yellow",
    #                                  dashArray = "",
    #                                  fillOpacity = 0.7,
    #                                  bringToFront = TRUE),
    #     label = labels) %>%
    #   addLegend(pal = pal, 
    #             values = ~parameter,
    #             opacity = 0.7, 
    #             title = htmltools::HTML(input$radio),
    #             position = "bottomright")
    # 
    map <- geo_data %>%
      select(-geometry) %>%
      leaflet(options = leafletOptions(minZoom = 8, maxZoom = 18)) %>%
      setView(-73.93, 40.70, zoom = 10) %>%
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
                        clusterOptions = markerClusterOptions(),
                        label = lapply(
                          lapply(seq(nrow(covid_vaccination)), function(i){
                            paste0('Address: ',covid_vaccination[i, "Location"], '<br/>',
                                   'Zipcode: ',covid_vaccination[i, "Zip_code"], '<br/>',
                                   'Type: ',covid_vaccination[i, "Type"],'<br/>',
                                   'Vaccine offered: ',covid_vaccination[i, "Vaccine_offered"]) }), htmltools::HTML), 
                        icon = awesomeIcons(markerColor= "lightred",
                                            text = fa("syringe")))
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
                        clusterOptions = markerClusterOptions(),
                        label = lapply(
                          lapply(seq(nrow(flu_vaccination)), function(i){
                            paste0('Address: ',flu_vaccination[i, "Address"], '<br/>',
                                   'Zipcode: ',flu_vaccination[i, "ZIP.Code"], '<br/>',
                                   'Vaccine For Children: ',flu_vaccination[i, "Children"],'<br/>',
                                   'Walk-in: ',flu_vaccination[i, "Walk.in"]) }), htmltools::HTML), 
                        icon = awesomeIcons(markerColor= "darkblue",
                                            text = fa("syringe")))
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
                        clusterOptions = markerClusterOptions(),
                        label = lapply(
                          lapply(seq(nrow(wifi)), function(i){
                            paste0('Address: ',wifi[i, "ADDRESS"], '<br/>',
                                   'Wifi Status: ',wifi[i, "WIFI.STATUS"], '<br/>',
                                   'Tablet Status: ',wifi[i, "TABLET.STATUS"],'<br/>',
                                   'Phone Status: ',wifi[i, "PHONE.STATUS"]) }), htmltools::HTML), 
                        icon = awesomeIcons(markerColor= "green",
                                            text = fa("wifi")))
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
                        clusterOptions = markerClusterOptions(),
                        label = lapply(
                          lapply(seq(nrow(food)), function(i){
                            paste0('Address: ',food[i, "Address"], '<br/>',
                                   'Center Name: ',food[i, "Name"], '<br/>',
                                   'Contact Number: ',food[i, "Contact"],'<br/>'
                            ) }), htmltools::HTML), 
                        icon = awesomeIcons(markerColor= "black",
                                            text = fa("utensils")))
    
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
                        clusterOptions = markerClusterOptions(),
                        label = lapply(
                          lapply(seq(nrow(drop_in)), function(i){
                            paste0('Address: ',drop_in[i, "Address"], '<br/>',
                                   'Zip Code: ',drop_in[i, "Postcode"], '<br/>',
                                   'Center Name: ',drop_in[i, "Center.Name"],'<br/>'
                            ) }), htmltools::HTML), 
                        icon = awesomeIcons(markerColor= "orange",
                                            text = fa("building")))
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
                        clusterOptions = markerClusterOptions(),
                        label = lapply(
                          lapply(seq(nrow(job)), function(i){
                            paste0('Address: ',job[i, "Address"], '<br/>',
                                   'Zip Code: ',job[i, "AGENCY"], '<br/>',
                                   'Agency: ',job[i, "Center.Name"],'<br/>',
                                   'Contact Number: ',job[i, "Contact.Number"], '<br/>'
                            ) }), htmltools::HTML), 
                        icon = awesomeIcons(markerColor= "beige",
                                            text = fa("briefcase")))
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
                        clusterOptions = markerClusterOptions(),
                        label = lapply(
                          lapply(seq(nrow(youth_drop_in)), function(i){
                            paste0('Address: ',youth_drop_in[i, "Number.and.Street.Address"], '<br/>',
                                   'Zip Code: ',drop_in[i, "Postcode"], '<br/>',
                                   'Agency: ',youth_drop_in[i, "AGENCY"],'<br/>',
                                   'Contact Number: ',youth_drop_in[i, "Contact.Number"], '<br/>'
                            ) }), htmltools::HTML), 
                        icon = awesomeIcons(markerColor= "purple",
                                            text = fa("bed")))
  })
  
})