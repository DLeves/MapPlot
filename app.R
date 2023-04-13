# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(BAMMtools)
library(tidyverse)
library(sf)
library(leaflet)
library(shiny)

vardf = read.csv("Data/FullDatasetUnpredicted")
jaras_nev = read.csv("Data/jarasnev.csv")[,1]
df = st_read("HunMap/hun_admbnda_adm2_osm_20220720.shp")
df = st_make_valid(df)

df$jaras_wBP <- ifelse(grepl("district",df$ADM2_HU),"Budapest",df$ADM2_HU)
df2 <- rbind(df[!grepl("district",df$ADM2_HU),],head(df[df$jaras_wBP == "Budapest",],n=1))
bpshape <- st_union(df[df$jaras_wBP == "Budapest",])
df2[df2$jaras_wBP == "Budapest",]$geometry <- bpshape
jarasdf = data.frame("JARAS_NEV" = jaras_nev, "jaras_wBP" = stringi::stri_trans_general(str = jaras_nev, id = "Latin-ASCII"))
jarasdf = jarasdf[order(jarasdf$jaras_wBP),]
JARAS_NEV = jarasdf$JARAS_NEV
df2 <- df2[order(df2$jaras_wBP),]
df2 = cbind(df2, JARAS_NEV)
df2 <- df2[order(df2$JARAS_NEV),]
rm(df, bpshape, jaras_nev, jarasdf, JARAS_NEV)


# lakas$VALUE[is.na(lakas$VALUE)] = 0

getInput = function(var, year){
  inputdf = vardf %>%
    filter(EV == year)
  # inputdf = inputdf[order(inputdf$JARAS_NEV),]
  return(inputdf[,var])
}

ui = fluidPage(
  fluidRow(
    column(2,       
           selectInput("var","Variable:", choices = c("Tízezer lakosra jutó lakásépítés" = "LAKAS",
                                                      "CSOK keresési trend" = "CSOK",
                                                      "Személyi jövedelemadóalapot képező jövedelem egy állandó lakosra" = "SZJA" ,
                                                      "Foglalkoztatottsági ráta" = "MUNKA" ,
                                                      "Beruházási teljesítményérték/lakosok száma" = "BERUHAZAS",
                                                      "X koordináta" = "X",
                                                      "Y koordináta" = "Y"), selected = "Lakas"),
           selectInput("year","Year:", choices = c(2012:2021), selected = 2018)),
    column(10,
           leafletOutput("mymap", height = 1000))
))

server = function(input, output, session){
  
  
  dataInput = reactive({
    getInput(input$var,input$year)
  })
  
  
  output$mymap = renderLeaflet({
    
    # bins = c(0,quantile(dataInput(), probs = c(.2,.4,.6,.8)), Inf)
    if(sum(dataInput(), na.rm = TRUE) == 0){
      bins = c(0,1)
    }else{
      bins = c(0,quantile(na.omit(dataInput()), probs = c(.2,.4,.6,.8)), Inf)
    }
    
    pal = colorBin("YlGnBu", domain = dataInput(), bins = bins)
    
    leaflet(df2) %>%
      addTiles() %>%
      addPolygons(
        weight = 1,
        opacity = 1, color = "white",
        dashArray = "3",
        highlightOptions = highlightOptions(
          weight = 5, color = "grey",
          dashArray = "", fillOpacity = .7),
        fillColor = ~pal(dataInput()), fillOpacity = .7,
        popup = paste0(df2$JARAS_NEV, "<br>", round(dataInput(),2))
      ) %>%
      addLegend(pal=pal, values = dataInput(), position = "topright")
  })
  
}

shinyApp(ui,server)

