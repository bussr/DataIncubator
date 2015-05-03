
# LoLMatchesGraph2 ui.R
# author: Ryan Buss, ryanpbuss@gmail.com


library(shiny)

shinyUI(fluidPage(

  titlePanel("League of Legends Warding Influence on Win Rate"),

  sidebarLayout(
    sidebarPanel(
      sliderInput("size",
                  "Size of Points",
                  min = 1,
                  max = 10,
                  value = 3),
      checkboxInput('lmodel', 'Linear Regression Line', F)
    ),

    mainPanel(
      plotOutput("distPlot")
    )
  )
))
