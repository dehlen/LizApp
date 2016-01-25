import Foundation

class Question {
    var type: QuestionType
    var text: String
    var options: [QuestionOption]
    var points: Int
    var negativePoints: Int
    var duration: Int //in seconds
    var correctAnswerExplanation: String
    var wrongAnswerExplanation: String

    init(type: QuestionType, text: String, options: [QuestionOption], points: Int,
        negativePoints: Int, duration: Int, correctAnswerExplanation: String,
        wrongAnswerExplanation: String) {
            self.type = type
            self.text = text
            self.options = options
            self.points = points
            self.negativePoints = negativePoints
            self.duration = duration
            self.correctAnswerExplanation = correctAnswerExplanation
            self.wrongAnswerExplanation = wrongAnswerExplanation
    }
}
