//
//  MatchPlayer.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftData
import SwiftUI

@Model
class MatchPlayer {
    var player: Player
    // SNAPSHOT fields from Player (frozen at match start)
    var snapshotName: String
    var snapshotJerseyNumber: Int
    
    var totalSecondsPlayed: TimeInterval = 0
    var isOnField: Bool = false
    var lastSubInMatchSeconds: TimeInterval?
    var lastSubOutMatchSeconds: TimeInterval?
    var currentPosition: Position?

    init(player: Player) {
        self.player = player
        self.snapshotName = player.name
        self.snapshotJerseyNumber = player.jerseyNumber
    }

    func secondsPlayed(match: Match, at now: Date) -> TimeInterval {
        var total = totalSecondsPlayed

        if isOnField, let last = lastSubInMatchSeconds {
            total += match.elapsedSeconds(at: now) - last
        }

        return total
    }
}

extension MatchPlayer {
    func isUnderplayed(
        match: Match,
        at now: Date,
        comparedTo average: TimeInterval,
        threshold: TimeInterval = 60
    ) -> Bool {
        secondsPlayed(match: match, at: now) + threshold < average
    }
    
    // player been in their current on-field or off-field state
    func currentStintSeconds(match: Match, at now: Date) -> TimeInterval {
        guard isOnField, let last = lastSubInMatchSeconds else { return 0 }
        return match.elapsedSeconds(at: now) - last
    }

    func benchSeconds(match: Match, at now: Date) -> TimeInterval {
        guard !isOnField, let last = lastSubOutMatchSeconds else { return 0 }
        return match.elapsedSeconds(at: now) - last
    }
}
