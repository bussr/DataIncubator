
# The Data Incubator Challenge Question 1
# Author: Ryan Buss, ryanpbuss@gmail.com
# Created April 8, 2015

dice.rolls.to.M <- function(M) {
  #returns a vector of dice rolls that reached max M
  current.sum = 0
  rolls = vector()
  while(current.sum <M){
    rolls = append(rolls, sample.int(6,1))
    current.sum = sum(rolls)
  }
  return(rolls)
}

mean.sum.minus.m <- function(M, iterations=9001){
  #returns the mean of a number of iterations of the sum of dice.rolls.to.M minus M
  return(mean(replicate(iterations, sum(dice.rolls.to.M(M))-M)))
}
cat("What is the mean of the sum minus $M$ when $M = 20$?\n")
mean.sum.minus.m(20)

cat("\nWhat is the mean of the sum minus $M$ when $M = 10000$?\n")
mean.sum.minus.m(10000)

sd.sum.minus.m <- function(M, iterations=9001){
  #returns the standard deviation of a number of iterations of the sum of dice.rolls.to.M minus M
  return(sd(replicate(iterations, sum(dice.rolls.to.M(M))-M)))
}
cat("\nWhat is the standard deviation of the sum minus $M$ when $M = 20$?\n")
sd.sum.minus.m(20)

cat("\nWhat is the standard deviation of the sum minus $M$ when $M = 10000$?\n")
sd.sum.minus.m(10000)

mean.rolls <- function(M, iterations=9001){
  #returns the mean number of rolls of a number of iterations of dice.rolls.to.M 
  return(mean(replicate(iterations, length(dice.rolls.to.M(M)))))
}
cat("\nWhat is the mean of the number of rolls when $M = 20$?\n")
mean.rolls(20)

cat("\nWhat is the mean of the number of rolls when $M = 10000$?\n")
mean.rolls(10000)


sd.rolls <- function(M, iterations=9001){
  #returns the standard deviation of the number of rolls of a number of iterations of dice.rolls.to.M 
  return(sd(replicate(iterations, length(dice.rolls.to.M(M)))))
}
cat("\nWhat is the standard deviation of the number of rolls when $M = 20$?\n")
sd.rolls(20)

cat("\nWhat is the standard deviation of the number of rolls when $M = 10000$?")
sd.rolls(10000)


#######################################################################################
# The Data Incubator Challenge Question 2
# Author: Ryan Buss, ryanpbuss@gmail.com
# Created April 9, 2015

fare = read.csv(file = "~/DataIncubator_Fares/trip_fare_3.csv")
trip = read.csv(file="~/DataIncubator_Fares/trip_data_3.csv")
# good thing I have a 64-bit OS and 16GB of RAM
full.fare = merge(fare, trip) #I didn't do this blindly. 
#Checked that the medallion, hack_license, and pickup_datetime columns matched up before merging. Also, exact same number of rows.

# Based on a convincing argument by Vijay Pandurangan, the hack_license value "CFCD208495D565EF66E7DFF9F98764DA" results from a data collection error
# https://medium.com/@vijayp/of-taxis-and-rainbows-f6bc289679a1
# For measures like 'Fraction of Credit Card payments under $5', the hack_license isn't particularly relevant
# But for anything that examines the behavior of individual drivers:
# full.fare = subset(full.fare, full.fare$hack_license != "CFCD208495D565EF66E7DFF9F98764DA")

cat("\nWhat fraction of payments under $5 use a credit card?\n")
# exclude fare totals of $5 or above, and $0 or below.
# I assume a fare of 0 does not count as a "payment".
fare.lessthan5 = subset(fare, fare$total_amount<5 & fare$total_amount>0) 
payment.types.table = table(fare.lessthan5$payment_type)
# For payment_types
#   Assuming: 'CRD' = Credit Card, 'CSH' = Cash, 'DIS' = Disputed fare, 'NOC' = No charge, 'UNK' = Unknown
#
# Therefore, DIS, NOC, and UNK payment types are excluded, as these seem to indicate that there was no payment
# Fraction of payments that use Credit: Credit / (Credit + Cash)
print(payment.types.table[1] / (payment.types.table[1]+payment.types.table[2])) # [1] is CRD, [2] is CSH


cat("\nWhat fraction of payments over $50 use a credit card?\n")
fare.morethan50 = subset(fare, fare$total_amount>50)
payment.types.table = table(fare.morethan50$payment_type)
# Assumptions about payment_type codes listed previously
payment.types.table[1] / (payment.types.table[1]+payment.types.table[2]) # [1] is CRD, [2] is CSH




# Notes:
# erroneous values for pickup lat/lon - make sure to screen for bad values
# erroneous values for passenger_count (e.g. 255) - make sure to screen for bad values
# store_and_fwd_flag missing for some entries
# rate_code possibly has erroneous values (e.g. 210) 

cat("\nWhat is the mean fare per minute driven?\n")
# There are 26,878 recorded trips that report a trip time of 0 seconds,
# and 92,707 that are less than 60 seconds.
# Choosing a somewhat arbitrary break point:
# Entries with trip times less than 60 seconds are excluded as being implausibly short
# This excludes only about .6 percent of observations
# However, the exclusion of these short trips significantly impacts the mean fare per minute
# ~ 1.09 with min trip time = 60 seconds
# ~ 1.41 with min trip time = 1 seconds
fare.durations <- subset(full.fare, full.fare$trip_time_in_secs >= 60)

mean(fare.durations$fare_amount/ (fare.durations$trip_time_in_secs/60)) # seconds / 60 = minutes
# 1.09




cat("\nWhat is the median of the taxi's fare per mile driven?\n")
# Similar to trip time, there are 87133 entries with a trip distance less than .01 miles
# .01 miles is about 50 feet
# These are excluded as implausibly short taxi trips
fare.per.mile <- subset(full.fare, full.fare$trip_distance > .01)
                        #& (full.fare$pickup_latitude > 15)
                        #& (full.fare$pickup_longitude < -60))
median(fare.per.mile$fare_amount / fare.per.mile$trip_distance)
# 5
# Many of the trips with absurdly large fare per mile values (e.g. $1000/mile) 
# are missing latitude/longitude coordinates.
# Therefore it seems likely that the distances are being incorrectly computed.
# However, excluding these entries does not influence the median fare per mile in this case



cat("\nWhat is the 95 percentile of the taxi's average driving speed in miles per hour?\n")
# Erroneously short trip durations and distances are excluded, 
# as per reasoning previously mentioned
fare.speed <- subset(full.fare, (full.fare$trip_time_in_secs >=60) 
                     & (full.fare$trip_distance    > .01)
                     & (full.fare$pickup_latitude  > 15)
                     & (full.fare$pickup_latitude  < 60)
                     & (full.fare$pickup_longitude > -90)
                     & (full.fare$pickup_longitude < -60))

# avg speed = distance / time (convert sec to hour)
fare.speed$speed = fare.speed$trip_distance / (fare.speed$trip_time_in_secs / 360)
# Some entries with improbabably fast average speeds (over 100mph) were not caught by the previous filter
# Thus, average speeds over 100mph are excluded, as these are certainly erroneous
fare.speed = subset(fare.speed, fare.speed$speed<100)
quantile(fare.speed$speed, probs = c(.95))
#2.65 MPH


cat("\nWhat is the average ratio of the distance between the pickup and dropoff divided by the distance driven?\n")
# Using the geosphere package to compute haversine distances
require(geosphere)
# There are some bad coordinate entries, but it will be easier to exclude absurd distances 
# than fiddle with precise coordinate restrictions
# earth.radius.miles = 20925524.9 / 5280.0

require(plyr) # used for applying a function to multiple columns of a data frame
fare.speed = ddply(fare.speed, .(pickup_longitude, pickup_latitude, dropoff_longitude, dropoff_latitude), 
              mutate, 
              havDist = distHaversine( c(pickup_longitude, pickup_latitude), 
                                       c(dropoff_longitude, dropoff_latitude), 
                                       r=earth.radius.miles), 
              .progress="text")


gcd.hf <- function(long1, lat1, long2, lat2) {
  R <- 20925524.9 / 5280.0 # Earth mean radius [miles]
  delta.long <- (long2 - long1)
  delta.lat <- (lat2 - lat1)
  a <- sin(delta.lat/2)^2 + cos(lat1) * cos(lat2) * sin(delta.long/2)^2
  c <- 2 * asin(min(1,sqrt(a)))
  d = R * c
  return(d) 
}

test2 = mutate(test, havDist = gcd.hf( pickup_longitude, pickup_latitude, dropoff_longitude, dropoff_latitude))


# JFK is approximately between Lat 40.667, Lon -73.812 and Lat 40.630, -73.767
if(F){ # UNUSED BLOCK
JFK.pickup <- function(lat, lon) {
  #returns True if lat, lon is approximately within JFK, False otherwise
  # if passed a bool for lat or lon, uses that as default value for comparison
  if(is.numeric(lat)){JFK.lat = F} else {JFK.lat = lat}
  if(is.numeric(lon)){JFK.lon = F} else {JFK.lon = lon}
  
  if(lat < 40.667 && lat > 40.630){JFK.lat=T} 
  if(lon < -73.767 && lon > -73.812){JFK.lon=T} #lat is positive nums, lon is negative, verify inequalities
  return(JFK.lat && JFK.lon)
}

# To be generally on the East Coast of the US: 15<Latitude<60, -90<Longitude<-60
bad.latitude.check <- function(lat){
  return(lat>15 & lat<60)
}
bad.longitude.check <- function(lon){
  return(lon>-90 & lon< -60)
}
}

# JFK is approximately between 40.630 < Lat < 40.666 and -73.767 > Lon > -73.812
cat("\nWhat is the average tip for rides from JFK?")
JFK.fare = subset(full.fare, full.fare$pickup_latitude < 40.666 
                  & full.fare$pickup_latitude > 40.630 #if pickup lon is in JFK
                  & full.fare$pickup_longitude < -73.767 
                  & full.fare$pickup_longitude > -73.812) # and pickup lat is in JFK
                  

mean(JFK.fare$tip_amount) # $4.48
# Low average largely due to most recorded tip amounts being zero.
# There are a few very high tip amounts that are suspicious, sich as row 1805713
#    which indicates a fare of $6.5 dollars, and an implausibly large tip of $78.
#    While this is likely a mistake or fabrication, it is theoretically possible 
#    the driver received an exorbitant tip for a short ride.
# However, in this case such outliers have only a minor influence on the average.



















# league matches csv header
# matchMode,season,matchDuration,queueType,matchType,mapId,
# p1championId,p1highestAchievedSeasonTier,p1item0,p1item1,p1item2,p1item3,p1item4,p1item5,p1item6,
# p1sightWardsBoughtInGame,p1visionWardsBoughtInGame,wardsKilled,wardsPlaced,winner

lol = read.csv("LeagueOfLegendsMatches.csv", header=F)
colnames(lol) = c('gameNumber', 'matchNumber', 'matchMode','season','matchDuration','queueType','matchType','mapId', 'playerId',
                  'championId','highestAchievedSeasonTier','item0','item1','item2','item3','item4','item5','item6',
                  'sightWardsBoughtInGame','visionWardsBoughtInGame','wardsKilled','wardsPlaced',
                  'firstInhibitorAssist', 'firstInhibitorKill', 'lane', 'winner',
                  'baronKills', 'dragonKills', 'firstBaron', 'firstBlood', 'firstDragon', 'firstInhibitor', 'firstTower',
                  'inhibitorKills', 'towerKills', 'deleteme')

champs = read.csv('G:/data/ChampionIds.txt', header=F)
colnames(champs) = c("championId", "name")


convertChampIdToName <- function(id) {
  return(champs$name[which(champs$championId==id)])
}

for(i in 1:nrow(lol)){
  lol$championName[i] = as.character(convertChampIdToName(lol$championId[i]))}

popular = as.data.frame(table(lol$championName))
popular = popular[order(popular$Freq),]

#average match duration based on champion 


#graphs to create
# Frequency of Champions in the dataset
# Winrate of champions in the dataset
# average baronKills by champion
# average dragonKills by champion
# probability of firstDragon by champion
# probability of firstInhibitor by champion
# average number of inhibitor kills by champion







if(F){ #old code
  colnames(lol) = c('matchMode','season','matchDuration','queueType','matchType','mapId',
                  'p1championId','p1highestAchievedSeasonTier','p1item0','p1item1','p1item2','p1item3','p1item4','p1item5','p1item6',
                  'p1sightWardsBoughtInGame','p1visionWardsBoughtInGame','p1wardsKilled','p1wardsPlaced','p1winner',
                  'p2championId','p2highestAchievedSeasonTier','p2item0','p2item1','p2item2','p2item3','p2item4','p2item5','p2item6',
                  'p2sightWardsBoughtInGame','p2visionWardsBoughtInGame','p2wardsKilled','p2wardsPlaced','p2winner',
                  'p3championId','p3highestAchievedSeasonTier','p3item0','p3item1','p3item2','p3item3','p3item4','p3item5','p3item6',
                  'p3sightWardsBoughtInGame','p3visionWardsBoughtInGame','p3wardsKilled','p3wardsPlaced','p3winner',
                  'p4championId','p4highestAchievedSeasonTier','p4item0','p4item1','p4item2','p4item3','p4item4','p4item5','p4item6',
                  'p4sightWardsBoughtInGame','p4visionWardsBoughtInGame','p4wardsKilled','p4wardsPlaced','p4winner',
                  'p5championId','p5highestAchievedSeasonTier','p5item0','p5item1','p5item2','p5item3','p5item4','p5item5','p5item6',
                  'p5sightWardsBoughtInGame','p5visionWardsBoughtInGame','p5wardsKilled','p5wardsPlaced','p5winner',
                  'p6championId','p6highestAchievedSeasonTier','p6item0','p6item1','p6item2','p6item3','p6item4','p6item5','p6item6',
                  'p6sightWardsBoughtInGame','p6visionWardsBoughtInGame','p6wardsKilled','p6wardsPlaced','p6winner',
                  'p7championId','p7highestAchievedSeasonTier','p7item0','p7item1','p7item2','p7item3','p7item4','p7item5','p7item6',
                  'p7sightWardsBoughtInGame','p7visionWardsBoughtInGame','p7wardsKilled','p7wardsPlaced','p7winner',
                  'p8championId','p8highestAchievedSeasonTier','p8item0','p8item1','p8item2','p8item3','p8item4','p8item5','p8item6',
                  'p8sightWardsBoughtInGame','p8visionWardsBoughtInGame','p8wardsKilled','p8wardsPlaced','p8winner',
                  'p9championId','p9highestAchievedSeasonTier','p9item0','p9item1','p9item2','p9item3','p9item4','p9item5','p9item6',
                  'p9sightWardsBoughtInGame','p9visionWardsBoughtInGame','p9wardsKilled','p9wardsPlaced','p9winner',
                  'p0championId','p0highestAchievedSeasonTier','p0item0','p0item1','p0item2','p0item3','p0item4','p0item5','p0item6',
                  'p0sightWardsBoughtInGame','p0visionWardsBoughtInGame','p0wardsKilled','p0wardsPlaced','p0winner')}



