
# LoLMatchesGraph2 server.R
# author: Ryan Buss, ryanpbuss@gmail.com


library(shiny)
library(ggplot2)
library(plyr)

lol = read.csv("LeagueData.csv")
lol$won=NA
lol$won[which(lol$winner=='False')] = 0
lol$won[which(lol$winner=='True')] = 1
winrate = ddply(lol, .(wardsPlaced), summarize, WinRate = mean(won))
winrate = subset(winrate, winrate$wardsPlaced < 60)
winrate = subset(winrate, winrate$WinRate > 0 & winrate$WinRate < 1)

shinyServer(function(input, output) {

  output$distPlot <- renderPlot({
    model = lm(WinRate ~ wardsPlaced, data=winrate)
    p = ggplot(winrate, aes(x=wardsPlaced, y=WinRate, color=WinRate)) + 
      geom_point(size=input$size) +
      labs(title="Average Win Rate by Number of Wards Placed", x="Wards Placed", y="Win Rate")
    
    if (input$lmodel){
      p = p + geom_abline(intercept = model$coefficients[1], slope = model$coefficients[2], size=1.8, color='green', alpha=.5)}
    
    p
  })

})
