import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var soundsSwitch: UISwitch!
    @IBOutlet weak var showExplanationSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.soundsSwitch.on = Config.Features.isSoundEnabled
        self.showExplanationSwitch.on = Config.Game.showsExplanations
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        log.error("Did receive memory warning. Might be a memory leak.")
    }

    @IBAction func switchedSoundSetting(sender: UISwitch) {
        Config.Features.isSoundEnabled = sender.on
    }

    @IBAction func switchedShowExplanationSetting(sender: UISwitch) {
        Config.Game.showsExplanations = sender.on
    }
}
