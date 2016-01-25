import Foundation

class QuestionOption {
    var text: String
    var isCorrect: Bool

    init(text: String, isCorrect: Bool) {
        self.text = text
        self.isCorrect = isCorrect
    }
}
