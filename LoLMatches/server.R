
# LoLMatches server.R
# author: Ryan Buss, ryanpbuss@gmail.com

library(shiny)
library(ggplot2)


lol = read.csv("LeagueData.csv")
lol$matchMin = lol$matchDuration/60

shinyServer(function(input, output) {

  titlePanel("Match Length for Selected League of Legends Champions")

  output$matchMinPlot <- renderPlot({
    champions=c()
    if(input$ezreal)    {champions = append(champions, 'Ezreal')}
    if(input$teemo)     {champions = append(champions, 'Teemo')}
    if(input$shaco)     {champions = append(champions, 'Shaco')}
    if(input$blitzcrank){champions = append(champions, 'Blitzcrank')}
    if(input$lux)       {champions = append(champions, 'Lux')}
    if(input$jax)       {champions = append(champions, 'Jax')}
    if(input$zed)       {champions = append(champions, 'Zed')}
    if(input$fizz)      {champions = append(champions, 'Fizz')}
    if(input$nidalee)   {champions = append(champions, 'Nidalee')}
    lol.sub = subset(lol, lol$championName %in% champions)
    
    ggplot(lol.sub, aes(x=championName, y=matchMin, fill=championName)) + geom_boxplot() + labs(title='Game Duration by Champion', x="Champion", y="Match Duration in Minutes")
    

  })
})