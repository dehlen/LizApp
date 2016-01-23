import GameKit

protocol GameCenterManagerDelegate {
    func processGameCenterAuth(error: NSError?)
	func reloadScoresComplete(leaderBoard: GKLeaderboard, error: NSError?)
	func achievementSubmitted(achievement: GKAchievement?, error: NSError?)
	func achievementResetResults(error: NSError?)
    func mappedPlayerIDToPlayer(player: GKPlayer?, error: NSError?)
}
