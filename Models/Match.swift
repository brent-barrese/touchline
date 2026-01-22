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
    var startTime: Date = Date()
    var endTime: Date?
    var name: String

    @Relationship(deleteRule: .cascade)
    var matchPlayers: [MatchPlayer] = []
    
    @Relationship(deleteRule: .cascade)
    var events: [MatchEvent] = []
    var pausedAt: Date?
    var totalPausedSeconds: TimeInterval = 0
    var pauseReason: MatchPauseReason?
    var playStartedAt: Date?
    var hasHadHalftime: Bool = false
    var isEnded: Bool { endTime != nil }
    var isPaused: Bool { pausedAt != nil }
    var hasStartedPlay: Bool { playStartedAt != nil }

    init(name: String, players: [Player], sport: SportType = .soccer) {
        self.name = name
        self.sport = sport
        self.name = name
        self.matchPlayers = players.map { MatchPlayer(player: $0) }
    }

    func elapsedSeconds(at now: Date) -> TimeInterval {
        guard let playStarted = playStartedAt else { return 0 }

        var paused = totalPausedSeconds
        if let pausedStart = pausedAt {
            paused += now.timeIntervalSince(pausedStart)  // add ongoing pause
        }

        return now.timeIntervalSince(playStarted) - paused
    }

    func effectiveNow(at now: Date) -> Date {
        pausedAt ?? endTime ?? now
    }

    func pause(at now: Date) {
        guard pausedAt == nil else { return }
        pausedAt = now

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

        for mp in matchPlayers where mp.isOnField {
            mp.lastSubInTime = now
        }
    }

    func startHalftime(at now: Date) {
        guard !hasHadHalftime else { return }
        pause(at: now)
        hasHadHalftime = true
        pauseReason = .halftime
    }

    func endHalftime(at now: Date) {
        guard pauseReason == .halftime else { return }
        pauseReason = nil
        resume(at: now)
    }

    func subIn(player: MatchPlayer, at now: Date) {
        guard !player.isOnField else { return }
        
        player.isOnField = true
        player.lastSubOutTime = nil

        if hasStartedPlay && !isPaused {
            player.lastSubInTime = now
        } else {
            player.lastSubInTime = nil
        }
    }

    func subOut(player: MatchPlayer, at now: Date) {
        guard player.isOnField else { return }
        
        if let lastIn = player.lastSubInTime {
            player.totalSecondsPlayed += now.timeIntervalSince(lastIn)
        }
        player.isOnField = false
        player.lastSubInTime = nil
        player.lastSubOutTime = now
    }
    
    // debuggin - delete later
    func debugStatus(at now: Date) {
        let mainClock = elapsedSeconds(at: now)
        print("=== Match Debug Status ===")
        print("Match: \(name)")
        print("Has Started Play: \(hasStartedPlay)")
        print("Play Started At: \(String(describing: playStartedAt))")
        print("Paused At: \(String(describing: pausedAt))")
        print("Total Paused Seconds: \(totalPausedSeconds)")
        print("Main Clock: \(formatTime(mainClock))")
        print("Players:")

        for mp in matchPlayers {
            let playerTime = mp.secondsPlayed(match: self, at: now)
            print(" - \(mp.player.name): isOnField=\(mp.isOnField), lastSubInTime=\(String(describing: mp.lastSubInTime)), totalSecondsPlayed=\(mp.totalSecondsPlayed), secondsPlayed(now)=\(formatTime(playerTime))")
        }
        print("==========================\n")
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds / 60)
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    func addGoal(for player: Player, at now: Date) {
        guard hasStartedPlay, !isEnded else { return }
        
        let ts = elapsedSeconds(at: now)
        events.append(MatchEvent(type: .goal, timestamp: ts, player: player))
    }
    
    func addOpponentGoal(at now: Date) {
        guard hasStartedPlay else { return }
        let ts = elapsedSeconds(at: now)
        events.append(MatchEvent(type: .opponentGoal, timestamp: ts))
    }
    
    func changePosition(
        for mp: MatchPlayer,
        to newPosition: Position,
        at now: Date
    ) {
        let ts = elapsedSeconds(at: now)

        events.append(
            MatchEvent(
                type: .positionChange,
                timestamp: ts,
                player: mp.player,
                fromPosition: mp.currentPosition,
                toPosition: newPosition
            )
        )

        mp.currentPosition = newPosition
    }
    
    func end(at now: Date) {
        let effectiveEnd = effectiveNow(at: now)

        for mp in matchPlayers where mp.isOnField {
            if let lastIn = mp.lastSubInTime {
                mp.totalSecondsPlayed += effectiveEnd.timeIntervalSince(lastIn)
            }
            mp.isOnField = false
            mp.lastSubInTime = nil
        }

        endTime = effectiveEnd // was a bug and was at just `now`
    }
    
    func removeLastOpponentGoal() {
        guard let index = events.lastIndex(where: { $0.type == .opponentGoal }) else {
            return
        }
        events.remove(at: index)
    }
    
}

extension Match {
    func averageSecondsPlayed(at now: Date) -> TimeInterval {
        let onFieldPlayers = matchPlayers.filter { $0.isOnField || $0.totalSecondsPlayed > 0 }
        guard !onFieldPlayers.isEmpty else { return 0 }
        
        let total = onFieldPlayers.reduce(0) { partialResult, mp in
            partialResult + mp.secondsPlayed(match: self, at: now)
        }
        return total / Double(onFieldPlayers.count)
    }
    
    var goalsFor: Int {
        events.filter { $0.type == .goal }.count
    }

    var goalsAgainst: Int {
        events.filter { $0.type == .opponentGoal }.count
    }

    func goals(for player: Player) -> Int {
        events.filter {
            $0.type == .goal && $0.player == player
        }.count
    }
}
