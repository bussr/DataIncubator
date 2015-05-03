
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(ggplot2)

# Load data set and champs - only run once on startup
lol = read.csv('LeagueMatchData.csv', header=T)
balance = read.csv('LeagueChampionBalanceStats.csv', header=T)
champs = read.csv('ChampionIds.csv', header=F)
colnames(champs) = c('championId', 'name')
champs$championId = NULL
champ.names = champs[order(champs$name),]



# actual server stuff
shinyServer(function(input, output) {
  
  
  #lol.champ <- reactive({
  #  if (! all(input$champion %in% champs$name))
  #    stop('Unknown Champion Selected')
    
  #  subset(lol, (lol$championName %in% input$champion)) # & lol$championFreq > input$minFreq)
  #})
  
  
  
  output$selectUI <- renderUI({
    selectizeInput('champion', 'Champion', choices=reduceChampNames(), multiple=TRUE)
  })
  
  reduceChampNames <- reactive({
    champ.names = subset(lol, lol$championFreq >= input$minFreq)
    levels(champ.names$championName)
    
  })
  
  

  output$freqPlot <- renderPlot({
    
    if(! is.null(input$champion)) {
      lol.champ = subset(lol, (lol$championName %in% input$champion))
    }
    else {
      lol.champ = subset(lol, lol$championName %in% c('Graves', 'Thresh', 'Morgana', 'Sona', 'Lux', 'Kayle', 'Taric'))
    }
    
    
    p = ggplot(lol.champ, aes(x=championName, fill=championName)) + 
      geom_bar() + 
      ylim(0,round(max(lol$championFreq)+10, -1)) +
      labs(title="Champion Frequency in Dataset", x="Champion", y='Number of Matches Picked')
      
    print(p)
    #if (length(input$champion) == 0) {
    #  p = p + geom_blank()
    #}
    
    #p
    
  })
  
  output$balanceBar <- renderPlot({
    
    if(! is.null(input$champion)) {
      bal = subset(balance, (balance$Champion %in% input$champion))
    }
    else {
      bal = subset(balance, balance$championName %in% c('Graves', 'Thresh', 'Morgana', 'Sona', 'Lux', 'Kayle', 'Taric'))
    }
    
    p = ggplot(bal, mapping = aes(x=Champion, fill=variable, y=value)) + 
      geom_bar(stat='identity', position='dodge') +
      ylim(0,80) +
      labs(title='Key Match Outcome Rates by Champion', x='Champion', y='Percent of Matches') +
      geom_hline(yintercept=50)
      
    
    print(p)
  })

})
