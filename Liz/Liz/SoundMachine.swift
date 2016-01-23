import XCGLogger
import AudioToolbox

class SoundMachine {

	enum Sound: String {
		case CorrectAnswer = "correct_answer"
		case WrongAnswer = "wrong_anwer"
	}

	func playSound(sound: Sound) {
		guard Config.Features.isSoundEnabled else {
			return
		}

        guard let audioFilePath = NSBundle.mainBundle().URLForResource(sound.rawValue, withExtension:".aiff") else {
        	return
        }

        var soundID: SystemSoundID = 0
        let errorCode = AudioServicesCreateSystemSoundID(audioFilePath, &soundID)
        if errorCode != 0 {
            log.error("Sound file was not played because the file was not found.")
        } else {
            AudioServicesPlaySystemSound(soundID)
		}
	}
}
