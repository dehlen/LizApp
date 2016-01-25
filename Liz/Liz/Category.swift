import UIKit

class Category {
    var categoryId: String
    var name: String
    var description: String
    var questions: [Question]
    var requiresPurchase: Bool //if free or purchased return false
    var leaderboardIdentifier: String
    var productIdentifier: String
    var themeColor: UIColor
    var icon: UIImage
    var createdAt: NSDate
    var timeBased: Bool
    var online: Bool
    var questionLimit: Int

    init(categoryId: String, name: String, description: String, questions: [Question],
        requiresPurchase: Bool, leaderboardIdentifier: String, productIdentifier: String,
        themeColor: UIColor, icon: UIImage, createdAt: NSDate, timeBased: Bool, online: Bool,
        questionLimit: Int) {
            self.categoryId = categoryId
            self.name = name
            self.description = description
            self.questions = questions
            self.requiresPurchase = requiresPurchase
            self.leaderboardIdentifier = leaderboardIdentifier
            self.productIdentifier = productIdentifier
            self.themeColor = themeColor
            self.icon = icon
            self.createdAt = createdAt
            self.timeBased = timeBased
            self.online = online
            self.questionLimit = questionLimit
    }
}
