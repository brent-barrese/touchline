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
    var totalSecondsPlayed: TimeInterval = 0
    var isOnField: Bool = false
    var lastSubInTime: Date?

    init(player: Player) {
        self.player = player
    }

    // Compute seconds including current on-field time
    func secondsPlayed(match: Match, at now: Date) -> TimeInterval {
        var total = totalSecondsPlayed
        if isOnField, let lastIn = lastSubInTime {
            total += match.effectiveNow(at: now).timeIntervalSince(lastIn)
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
}
