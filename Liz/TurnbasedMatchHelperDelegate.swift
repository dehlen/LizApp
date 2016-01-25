import GameKit

protocol TurnbasedMatchHelperDelegate {
    func enterNewGame(match: GKTurnBasedMatch)
    func layoutMatch(match: GKTurnBasedMatch)
    func takeTurn(match: GKTurnBasedMatch)
}
