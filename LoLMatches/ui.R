
# LoLMatches ui.R
# author: Ryan Buss, ryanpbuss@gmail.com

library(shiny)

shinyUI(fluidPage(
  
  titlePanel("Game Duration Boxplot"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Select Champions to be Displayed"),
      checkboxInput("ezreal", "Ezreal", T),
      checkboxInput('teemo', 'Teemo', T),
      checkboxInput('shaco', 'Shaco', F),
      checkboxInput('blitzcrank', 'Blitzcrank', F),
      checkboxInput('lux', 'Lux', F),
      checkboxInput('jax', 'Jax', F),
      checkboxInput('zed', 'Zed', F),
      checkboxInput('fizz', 'Fizz', F),
      checkboxInput('nidalee', 'Nidalee', T)
      
    ),
    
    mainPanel(
      h3(textOutput("caption")),
      
      plotOutput("matchMinPlot")
    )
  )
))

