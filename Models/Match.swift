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
    var sport: SportType = SportType.soccer
    var startTime: Date
    var endTime: Date?
    var name: String

    @Relationship(deleteRule: .cascade)
    var matchPlayers: [MatchPlayer] = []
    
    var pausedAt: Date?
    var totalPausedSeconds: TimeInterval = 0
    var pauseReason: MatchPauseReason?
    var isEnded: Bool { endTime != nil }
    var isPaused: Bool { pausedAt != nil }
    var hasHadHalftime: Bool = false

    init(name: String, players: [Player], sport: SportType = .soccer) {
        self.name = name
        self.startTime = Date()
        self.sport = sport
        self.matchPlayers = players.map { MatchPlayer(player: $0) }
    }
    
    func elapsedSeconds(at now: Date) -> TimeInterval {
        let effectiveEnd = endTime ?? now

        var elapsed = effectiveEnd.timeIntervalSince(startTime)
        elapsed -= totalPausedSeconds

        if let pausedAt {
            elapsed -= now.timeIntervalSince(pausedAt)
        }

        return max(elapsed, 0)
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
    
    func pause(at now: Date) {
        guard pausedAt == nil else { return }
        pausedAt = now

        // Freeze player time
        for mp in matchPlayers where mp.isOnField {
            if let lastIn = mp.lastSubInTime {
                mp.totalSecondsPlayed += now.timeIntervalSince(lastIn)
                mp.lastSubInTime = nil
            }
        }
    }

    func resume(at now: Date) {
        guard let pausedAt else { return }

        totalPausedSeconds += now.timeIntervalSince(pausedAt)
        self.pausedAt = nil

        // Restart player timers
        for mp in matchPlayers where mp.isOnField {
            mp.lastSubInTime = now
        }
    }
    
    func startHalftime(at now: Date) {
        guard !hasHadHalftime else { return }

        pause(at: now)
        hasHadHalftime = true
    }

    func endHalftime(at now: Date) {
        guard pauseReason == .halftime else { return }
        pauseReason = nil
        resume(at: now)
    }
}
