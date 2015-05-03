# league matches csv header
# matchMode,season,matchDuration,queueType,matchType,mapId,
# p1championId,p1highestAchievedSeasonTier,p1item0,p1item1,p1item2,p1item3,p1item4,p1item5,p1item6,
# p1sightWardsBoughtInGame,p1visionWardsBoughtInGame,wardsKilled,wardsPlaced,winner

#lol = read.csv("LeagueOfLegendsMatches.csv", header=F)
lol = read.csv('G:/data/lolParse.csv', header=F)
colnames(lol) = c('gameNumber', 'matchNumber', 'matchMode','season','matchDuration','queueType','matchType','mapId', 'playerId',
                  'championId','highestAchievedSeasonTier','item0','item1','item2','item3','item4','item5','item6',
                  'sightWardsBoughtInGame','visionWardsBoughtInGame','wardsKilled','wardsPlaced',
                  'firstInhibitorAssist', 'firstInhibitorKill', 'lane', 'winner',
                  'baronKills', 'dragonKills', 'firstBaron', 'firstBlood', 'firstDragon', 'firstInhibitor', 'firstTower',
                  'inhibitorKills', 'towerKills', 'deleteme')

lol$deleteme = NULL

champs = read.csv('G:/data/ChampionIds.txt', header=F)
colnames(champs) = c("championId", "name")


convertChampIdToName <- function(id) {
  return(champs$name[which(champs$championId==id)])
}

for(i in 1:nrow(lol)){
  lol$championName[i] = as.character(convertChampIdToName(lol$championId[i]))}

popular = as.data.frame(table(lol$championName))
popular = popular[order(popular$Freq, decreasing=T),]

#average match duration based on champion 


#graphs to create
# Frequency of Champions in the dataset


# Winrate of champions in the dataset
# average baronKills by champion
# average dragonKills by champion

#champion$winnerNum = NA
#champion$winnerNum[which(champion$winner == 'True')] = 1
#champion$winnerNum[which(champion$winner == 'False')] = 0

balanceMeasures <- function(lol, champions=NULL) {
  require(reshape)
  # from a data frame containing league matches, and a vector of champion names
  # return a data frame with columns:
  # championName, winPct, firstDragonPct, firstBaronPct, firstInhibitorPct
  if(is.null(champions)){
    champions = levels(factor(lol$championName))
  }
  
  if(! all(champions %in% unique(lol$championName))){
    stop('balanceMeasures failed because it was passed unknown Champions')
  }
  
  
  balance = data.frame()
  
  for(champion in champions){
    #print(champion) #debug
    champ = subset(lol, lol$championName==champion)
    
    champ$winnerNum = NA
    champ$winnerNum[which(champ$winner == 'True')] = 1
    champ$winnerNum[which(champ$winner == 'False')] = 0
    
    champ$firstBaronNum = NA
    champ$firstBaronNum[which(champ$firstBaron == 'True')] = 1
    champ$firstBaronNum[which(champ$firstBaron == 'False')] = 0
    
    champ$firstDragonNum = NA
    champ$firstDragonNum[which(champ$firstDragon == 'True')] = 1
    champ$firstDragonNum[which(champ$firstDragon == 'False')] = 0
    
    champ$firstInhibitorNum = NA
    champ$firstInhibitorNum[which(champ$firstInhibitor == 'True')] = 1
    champ$firstInhibitorNum[which(champ$firstInhibitor == 'False')] = 0
    
    champ.bal = data.frame( Champion = champion,
                            winPct = round( 100 * mean(champ$winnerNum)),
                            firstDragonPct = round( 100 * mean(champ$firstDragonNum)),
                            firstBaronPct = round(100 * mean(champ$firstBaronNum)),
                            firstInhibitorPct = round(100 * mean(champ$firstInhibitorNum)))
      
      
    if(nrow(balance) > 0){
      balance = rbind(balance, champ.bal)
    }
    else balance = champ.bal
    
  }
  
  balance$Champion = as.factor(balance$Champion)
  balance = melt(balance)
  return(balance)
}

# ggplot(test4, aes(x=championName, y=winPct*100, fill=championName)) + geom_bar(stat='identity') + ylim(25,75) + labs(x='Champion', y='Win Percentage')


# probability of firstDragon by champion
# probability of firstInhibitor by champion
# average number of inhibitor kills by champion





test = function(t, n){
  C = 0
  for k in 0:((t-n)/6){
    C = C + (-1)^k * 
  }
}



