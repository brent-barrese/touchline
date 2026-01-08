//
//  Match.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftData
import Foundation

@Model
class Match {
    var startTime: Date
    var endTime: Date?

    @Relationship(deleteRule: .cascade)
    var matchPlayers: [MatchPlayer] = []
    
    var isEnded: Bool {
            endTime != nil
        }

    init(players: [Player]) {
        self.startTime = Date()
        self.matchPlayers = players.map { MatchPlayer(player: $0) }
    }
    
    func elapsedSeconds(at now: Date) -> TimeInterval {
            let end = endTime ?? now
            return end.timeIntervalSince(startTime)
        }
}

extension Match {
    func averageSecondsPlayed(at now: Date) -> TimeInterval {
        guard !matchPlayers.isEmpty else { return 0 }

        let total = matchPlayers.reduce(0) {
            $0 + $1.secondsPlayed(at: now)
        }

        return total / Double(matchPlayers.count)
    }
    
    var isFinished: Bool {
        endTime != nil
    }
}
