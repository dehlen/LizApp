import GameKit

class GameCenterManager {
    private var earnedAchievementCache = Dictionary<String, GKAchievement>()

    var delegate: GameCenterManagerDelegate?
		
	func isGameCenterAvailable() -> Bool {
		let requiredSystemVersion = "4.1"
		let currentSystemVersion = UIDevice.currentDevice().systemVersion
		let osVersionSupported = currentSystemVersion.compare(requiredSystemVersion, options:[.NumericSearch]) != .OrderedAscending
		
		return (NSClassFromString("GKLocalPlayer") != nil) && osVersionSupported
	}
	
	func authenticateLocalUser() {
		let localPlayer = GKLocalPlayer.localPlayer()
		
		if localPlayer.authenticated == false {
			localPlayer.authenticateHandler = {[weak self] (viewController, error) -> Void in
				guard (error != nil) else {
					log.error("Could not authenticate local user.")
                    return
				}
                
                self?.delegate?.processGameCenterAuth(error)
			}
		}
	}
	
	func reloadHighScoresForCategory(category:String) {
		let leaderBoard = GKLeaderboard()
		leaderBoard.identifier = category
		leaderBoard.timeScope = .AllTime
		leaderBoard.range = NSMakeRange(1,1)
		leaderBoard.loadScoresWithCompletionHandler() {[weak self] (scores, error) in
			guard (error != nil) else {
				log.error("Could not load scores for category.")
				return
			}
			self?.delegate?.reloadScoresComplete(leaderBoard, error: error)
        }
	}
	
	func reportScore(score:Int, category:String) {
		let localPlayer = GKLocalPlayer.localPlayer()
		
		guard localPlayer.authenticated else {
			NSUserDefaults.standardUserDefaults().setInteger(score, forKey:category)
			NSUserDefaults.standardUserDefaults().synchronize()
            return
		}
		
		let previousScore = NSUserDefaults.standardUserDefaults().integerForKey(category)
		let scoreReporter = GKScore(leaderboardIdentifier:category)
		scoreReporter.value = Int64(score) + previousScore
        GKScore.reportScores([scoreReporter]) { error in
			if (error != nil) {
				log.error("Score report failed with score: \(score) and category: \(category)")
				NSUserDefaults.standardUserDefaults().setInteger(score+previousScore, forKey:category)
				NSUserDefaults.standardUserDefaults().synchronize()
			} else {
				NSUserDefaults.standardUserDefaults().removeObjectForKey(category)
				NSUserDefaults.standardUserDefaults().synchronize()
				log.info("Score reported and removed cached score")
			}
		}
	}
	
	func submitAchievement(identifier:String, percentComplete:Double) {
		if self.earnedAchievementCache.count != 0 {
            GKAchievement.loadAchievementsWithCompletionHandler() {[weak self] (achievementsArray, error) in
				guard let _ = error else {
					log.error("Could not submit achievement. We'll try again the next time achievements are submitted.")
					self?.delegate?.achievementSubmitted(nil, error: error)
                    return
				}
                
                guard let achievements = achievementsArray else {
                    log.error("Could not submit achievement. We'll try again the next time achievements are submitted.")
                    self?.delegate?.achievementSubmitted(nil, error: error)
                    return
                }
				
                var tempCache:Dictionary = Dictionary<String, GKAchievement>()
				for achievement:GKAchievement in achievements {
					tempCache[achievement.identifier!] = achievement
				}
                
				self?.earnedAchievementCache = tempCache
				self?.submitAchievement(identifier, percentComplete: percentComplete)
			}
		} else {
            guard let achievement = self.earnedAchievementCache[identifier] else {
                let newAchievement = GKAchievement(identifier:identifier)
                newAchievement.percentComplete = percentComplete
                self.earnedAchievementCache[newAchievement.identifier!] = newAchievement
                return
            }
            
            guard achievement.percentComplete >= 100.0 || achievement.percentComplete >= percentComplete else {
                return
            }
            
            achievement.percentComplete = percentComplete
            GKAchievement.reportAchievements([achievement]) {[weak self] (error) in
               self?.delegate?.achievementSubmitted(achievement, error: error)
            }
        }
	}

	func resetAchievements() {
        self.earnedAchievementCache = [:]
		GKAchievement.resetAchievementsWithCompletionHandler() { [weak self] (error) in
			self?.delegate?.achievementResetResults(error)
		}
	}
	
	func mapPlayerIDtoPlayer(playerID:String) {
		GKPlayer.loadPlayersForIdentifiers([playerID]) { [weak self] (playerArray, error) in
            guard let playerArr = playerArray else {
                return
            }
            
			let player = playerArr.filter{ $0.playerID == playerID }.first
            self?.delegate?.mappedPlayerIDToPlayer(player, error:error)
        }
	}
}