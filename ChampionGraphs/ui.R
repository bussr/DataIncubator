
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)



shinyUI(fluidPage(
  
  # Application title
  titlePanel("League of Legends Champion Frequency"),
  
  sidebarLayout(
    sidebarPanel(
      htmlOutput('selectUI'),
      #selectizeInput('champion', 'Champion', choices=champ.names, multiple=TRUE),
      sliderInput('minFreq', 'Minimum Champion Frequency', min=1, max= max(lol$championFreq) + 1, value=100, step=10)
    ),
    
    mainPanel(
      tabsetPanel(type='tabs',
                  tabPanel('Champion Representation', plotOutput('freqPlot')),
                  tabPanel('Match Outcomes', plotOutput('balanceBar'))
      )
    )
  )

))
