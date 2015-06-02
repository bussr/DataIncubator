# -*- coding: utf-8 -*-
"""
Python Script to Harvest League of Legends Matches
Created on Sat Apr 11 11:54:53 2015

@author: Ryan Buss, ryanpbuss@gmail.com

"""



import requests
import io
import os
import json
import time
import sys, getopt

# steps
# get info from riot with requests.get
# parse to dictionary with json.loads( request.text)
# output the data into a csv format
#
# Add delay timer so rate limit is not hit
#  count requests
# use time.clock() to get a current time

# predictors of several success measures:
# first Baron, first Dragon, first Inhibitor, and Win
# variety of possible factors: Champions, Items, Number of Wards Placed, Number of Wards Killed, Summoner Rank







class LoLpy:
    """
    Requests various info from Riot League of Legends API
    
    Attributes:
            api_key    Required to make API calls - used for rate limiting
            region     LoL Server region
            rate       A number indicating the max API calls per 10 mins
            debug      True for debug messages, default is False
            allMatchIds      Set of all matches retrieved
    
    """
    
    def __init__(self, api_key, region = 'na', rate = 500, debug=False):
        self.api_key = api_key
        self.region = region
        self.rate = rate
        self.stepDelay = 600.0/rate + .001
        self.allMatchIDs = set()
        self.debug = debug
        self.wd = os.getcwd()
        
        
    def getMatch(self, matchID):
        if self.debug:
            print('getMatch called with matchID: ' + str(matchID))
            
        # retrieves a match by its matchID
        page = "https://na.api.pvp.net/api/lol/" + self.region + "/v2.2/match/" + str(matchID) + "?api_key=" + str(self.api_key)
        r = requests.get(page)
        while r.status_code == 429:
            self.waitAfterCall(time.time())
            r = requests.get(page)
            
        # check for failure
        if self.debug and not r.status_code == requests.codes.ok:
            print("Request for matchID: " + str(matchID) + " failed with status code: " + str(r.status_code))
            #return(r)
        else:
            return(r)
        
    def getMatchID(self, beginDate):
        if self.debug:
            print('getMatchID called with beginDate: ' + str(beginDate))
            
        
        #retrieves matchIDs by Epoch time
        # beginDate must be a multiple of 5 mins
        if(beginDate % 300 != 0):
            if self.debug:
                print("Invalid beginDate passed to getMatchID. beginDate: " + str(beginDate) + " Rounding to lowest 5 min")
            beginDate = beginDate - (beginDate % 300)
        
        beginDate = int(beginDate)
        page = "https://na.api.pvp.net/api/lol/" + self.region + "/v4.1/game/ids?beginDate=" + str(beginDate) + "&api_key=" + str(self.api_key)
        r = requests.get(page)
        
        while r.status_code == 429:
            self.waitAfterCall(time.time())
            r = requests.get(page)
        
        if self.debug and not r.status_code == requests.codes.ok:
            print("Request for matches at timestamp: " + str(beginDate) + " failed.")
            return(r)
        else:
            return(r)
    

    def waitAfterCall(self, startTime):
        while (time.time() - startTime) < self.stepDelay:
            time.sleep(.111)
            #if self.debug:
                #print('Sleeping for ' + str(round(self.stepDelay + startTime - time.time(), 1)) + ' more seconds')
    
        return
    
    
    
    def scrapeMatches(self, filename, inputMatches=None):
        # Saves to file a number of matches, based on the Master League summoners
        #    save with json.dump( req.json(), file)
        #    load with json.load(file)
        # added additional checking for over-rate limit - response code 429, 
        #also checking to avoid double-retrieval of the same match
        
        gotMatches = 0
        startTime = time.time()
        masters = self.getMasterLeague()
        self.waitAfterCall(startTime)
        #assume that self.allMatchIDs has previous matches in it, avoid retreving them twice
        matchIDs = set() #matchIDs to be retrieved
        
        if not inputMatches:
            for player in masters:
                startTime = time.time()
                matchIDs = matchIDs.union(self.getSummonerHistory(player))
                self.waitAfterCall(startTime)
                
        else:
            matchIDs = inputMatches
            
        #only retrieve new matches
        matchIDs = matchIDs - self.allMatchIDs
        self.allMatchIDs = self.allMatchIDs.union(matchIDs) #update allMatchIDs after excluding retrieved matches
        
        if self.debug:
            print('Current Matches to Retrieve: ')
            print(matchIDs)
        
        matchIDs = list(matchIDs) #convert to list for iteration - set properties not needed past this point

        for matchID in matchIDs:
            startTime = time.time()
            match = self.getMatch(matchID)
            gotMatches +=1
            #allMatchIDs.remove(matchID) #this call will throw an error if matchID isn't in the set
            if not os.path.exists(self.wd + '/LoLScrape'):
                os.mkdir(self.wd + '/LoLScrape')
                
            try:
                with open(self.wd + '/LoLScrape/'+ filename + '_' + str(gotMatches) + '.txt', 'w') as outfile:
                    json.dump(match.json(), outfile)
            
            except AttributeError:
                print('Match ' + str(matchID) + ' failed to retrieve a match.')
                
            self.waitAfterCall(startTime)
    

    
    
    def OLDcrawlMatches(self, numMatches, filename):
        # previous version. Makes different assumptions about source of matches.
        # crawl a number of matches from the LoL API
        # save them in filename
        #   Grab a number of matchIDs
        #    For each matchID, grab the match data
        #    save with json.dump( req.json(), file)
        #    load with json.load(file)
        # added additional checking for over-rate limit - response code 429, 
        #also checking to avoid double-retrieval of the same match
        
        allMatchIDs = set()
        gotMatches = 0
        startTime = time.time()
        referenceTime = int(startTime - 43200 - startTime%300) #start 12 hours ago, 5 minute increments
        while gotMatches < numMatches:
            matchIDs = self.getMatchID(referenceTime)
            # if status_code is 429, rate limit is exceeded, delay
            while int(matchIDs.status_code) == 429:
                time.sleep(0.51)
                matchIDs = self.getMatchID(referenceTime)
                startTime = time.time()
                            
            startTime += 1.2 #account for the getMatchID call in delay timer
            referenceTime += 300 # increment to next 5 min interval
            
            try:
                for matchID in matchIDs.json():
                    if int(matchID) not in allMatchIDs: #make sure this match id hasn't been retrieved alrady
                        match = self.getMatch(matchID)
                        gotMatches +=1
                        allMatchIDs.add(int(matchID))
                        with open('G:/data/LoLCrawl/'+ filename + str(gotMatches) + '.txt', 'w') as outfile:
                            json.dump(match.json(), outfile)
                    
            except AttributeError:
                print('referenceTime: ' + str(referenceTime) + ' failed to retrieve a game.\n')
            
            #check if 1.2 seconds has elapsed since starTime, wait if not
            while (time.time() - startTime) < 1.201:
                time.sleep(0.21)
                print("sleeping. Time difference is: " + str(time.time() - startTime))
                    
            startTime = time.time() #reset the delay timer
                


    def appendTeamData(self, exportlist, team):
        assert type(exportlist) is list
        assert type(team) is dict
        exportlist.append(team['baronKills'])
        exportlist.append(team['dragonKills'])
        exportlist.append(team['firstBaron'])
        exportlist.append(team['firstBlood'])
        exportlist.append(team['firstDragon'])
        exportlist.append(team['firstInhibitor'])
        exportlist.append(team['firstTower'])
        exportlist.append(team['inhibitorKills'])
        exportlist.append(team['towerKills'])
        # return exportlist # no need to return it, the appends modify the list
        
            
    def parseMatches(self, folder = 'G:/data/LoLCrawl', outfile = 'G:/data/lolParse.csv'):
        #load and restructure json saved lol matches
        files = os.listdir(folder)
        gameCount = 0
        allMatchIds = set() #used for checking if the match has already been processed
        for file in files:
            print('Loading ' + folder + "/" + file) #debug
            with open(folder + "/" + file, 'r') as matchFile:
                if os.stat(folder + "/" + file).st_size > 10000: # if the file has a match in it (non-empty)
                    game = json.load(matchFile)
                    
            if game['matchId'] in allMatchIds:
                print('Match ' + str(game['matchId']) + ' already processed, skipping')
                continue #skip this file if its match has already been loaded
                
            allMatchIds.add(game['matchId'])
                
            if not isinstance(game, dict):
                print('Failed to correctly load file: ' + file)
            else: #grab each relevant thing and add it to a list
                gameCount += 1
                team1 = game['teams'][0]
                team2 = game['teams'][1]
                for player in game['participants']:
                    exportlist = [str(gameCount), game['matchId'], game['matchMode'], game['season'], str(game['matchDuration']),
                                  game['queueType'], game['matchType'], str(game['mapId'])]
                    exportlist.append(str(player['participantId']))
                    exportlist.append(str(player['championId']))
                    exportlist.append(player['highestAchievedSeasonTier'])
                    exportlist.append(str(player['stats']['item0']))
                    exportlist.append(str(player['stats']['item1']))
                    exportlist.append(str(player['stats']['item2']))
                    exportlist.append(str(player['stats']['item3']))
                    exportlist.append(str(player['stats']['item4']))
                    exportlist.append(str(player['stats']['item5']))
                    exportlist.append(str(player['stats']['item6']))
                    exportlist.append(str(player['stats']['sightWardsBoughtInGame']))
                    exportlist.append(str(player['stats']['visionWardsBoughtInGame']))
                    exportlist.append(str(player['stats']['wardsKilled']))
                    exportlist.append(str(player['stats']['wardsPlaced']))
                    exportlist.append(str(player['stats']['firstInhibitorAssist']))
                    exportlist.append(str(player['stats']['firstInhibitorKill']))
                    exportlist.append(player['timeline']['lane'])
                    exportlist.append(player['stats']['winner'])
                    # add team data
                    if int(player['teamId']) == int(team1['teamId']):
                        self.appendTeamData(exportlist, team1)
                    elif int(player['teamId']) == int(team2['teamId']):
                        self.appendTeamData(exportlist, team2)
                    else:
                        print('Warning: player teamId ' + str(player['teamId']) + ' does not match either teamId')
                    
                    with open(outfile, 'a') as out:
                        for item in exportlist:
                            out.write(str(item) + ",") #redundant casting probably not necessary, but whatever
                
                        out.write('\n')
            
                    
                
    def getChampIds(self, outfile='G:/data/ChampionIds.txt'):
        champs = requests.get('https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion?champData=all&api_key=' + self.api_key)
        champs = champs.json()['keys']
        with open(outfile, 'a') as out:
            for key in champs:
                out.write(str(key) + "," + champs[key] + "\n")
                
                
    def getMasterLeague(self, league=None):
        if self.debug:
            print('getMasterLeague called')
        
        
        #return a list of summoner Ids from the master league
        summonerIds = list()
        if league:
            page = 'https://na.api.pvp.net/api/lol/' + self.region + '/v2.5/league/' + str(league) + '?type=RANKED_SOLO_5x5&api_key=' + self.api_key
        else:
            page = 'https://na.api.pvp.net/api/lol/' + self.region + '/v2.5/league/master?type=RANKED_SOLO_5x5&api_key=' +  self.api_key
            
        master = requests.get(page)
        while master.status_code == 429:
            self.waitAfterCall(time.time())
            master = requests.get(page)
        
        for entry in master.json()['entries']:
            summonerIds.append(entry['playerOrTeamId'])
        
        return(summonerIds)
    
    def getSummonerHistory(self, summonerId):
        if self.debug:
            print('getSummonerHistory called with summonerId: ' + str(summonerId))
            
        #return a set of matchIds from the match history of a summonerId
        matches = set()
        page = 'https://na.api.pvp.net/api/lol/' + self.region + '/v2.2/matchhistory/' + str(summonerId) + '?rankedQueues=RANKED_SOLO_5x5&api_key=' + self.api_key
        summoner = requests.get(page)
        while summoner.status_code == 429:
            self.waitAfterCall(time.time())
            summoner = requests.get(page)
        
        try:
            for match in summoner.json()['matches']:
                matches.add(int(match['matchId']))
            
        except ValueError:
            print('Failed to find matches for summonerId: ' + str(summonerId))
            
        else:
            return(matches)
                
            
        
    
# example game ID request
# https://na.api.pvp.net/api/lol/na/v4.1/game/ids?beginDate=1428775200&api_key=3bcb84f4-416b-4ab6-b345-53c95fb3f607

def main(argv):
    
    lol = LoLpy('3bcb84f4-416b-4ab6-b345-53c95fb3f607')
    filename = 'LoLScrape'
    runtime = 86400
    
    #handle arguments
    try:
        opts, args = getopt.getopt(argv, 'hdf:r:', ["help", "debug", "filename=", "runtime="])
    except getopt.GetOptError:
        print('LoL_Scrape.py -f filename')
        sys.exit(2)
    for opt, arg in opts:
        if opt in ('-h', '--help'):
            print('pythondotest.py -f filename')
            sys.exit()
        elif opt in ('-d', '--debug'):
            lol.debug = True
            #print('Debug flag set')
        elif opt in ('-f', '--filename'):
            filename = arg
        elif opt in ('-r', '--runtime'):
            runtime = arg
            #print('filename set:', filename)

        
    
    print("Beginning League Scrape")
    start_time = round(time.time())
    while start_time + int(runtime) > round(time.time()):
        lol.scrapeMatches(filename)
        time.sleep(1200) #wait 10 minutes between scrapes
        
        
if __name__ == "__main__":
    main(sys.argv[1:])
    