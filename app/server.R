
source("global.R")
library(shinydashboard)

shinyServer(function(input, output, session) {
    
    ## homepage box output #############################################

    ## map output #############################################
    output$map <- renderLeaflet({
        #covid cases parameters
        parameter <- if(input$choice == "positive cases") {
            data$people_positive
            } else if(input$choice == "cumulative cases") {
                data2$COVID_CASE_COUNT
            } else {
                data2$COVID_DEATH_COUNT
            }
    
        #create palette
        pal <- colorNumeric(
            palette = "Reds",
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
    

})
