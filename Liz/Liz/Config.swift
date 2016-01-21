import UIKit

struct Config {
	
	static let appName = "Liz"
	static let applicationiTunesLink = "http://"
	static let aboutScreenTextOrURL = ""
	struct ui {
    	static let appTextColor = UIColor.whiteColor()
		static let isHighlightCorrectAnswerEnabled = true
	}
	
	struct features {
		static let isGameCenterSupported = true
		static let isInAppPurchaseSupported = true
		static let isParentalGateEnabled = true
		static let isMultiplayerSupportEnabled = true
		static let isSoundEnabled = true
	}
	
	struct game {
		static let isShuffleAnswersEnabled = true
		static let isShuffleQuestionsEnabled = true
		static let isTimerBasedScoreEnabled = true
		static let fullPointsBeforeSeconds = 5
		static let showsExplanations = true
	}
	
	struct achievements {
		static let achievementsForWins = [Achievement(id: "com.david-ehlen.liz.Beginner", wins: 10), 
		Achievement(id: "com.david-ehlen.liz.Intermediate", wins: 50), 
		Achievement(id: "com.david-ehlen.liz.Expert", wins: 100), 
		Achievement(id: "com.david-ehlen.liz.Beast", wins: 500)]
		static let totalWinsLeaderboardId = "com.david-ehlen.liz.totalwins"
	}
}