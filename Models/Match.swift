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
    var isPaused: Bool { pausedAt != nil && endTime == nil }
    var hasStartedPlay: Bool { playStartedAt != nil }
    
    var playersSortedForDisplay: [MatchPlayer] {
        matchPlayers.sorted {
            $0.snapshotJerseyNumber < $1.snapshotJerseyNumber
        }
    }

    init(name: String, players: [Player], sport: SportType = .soccer) {
        self.name = name
        self.sport = sport
        self.name = name
        self.matchPlayers = players.map {
            let mp = MatchPlayer(player: $0)
            mp.snapshotName = $0.name
            mp.snapshotJerseyNumber = $0.jerseyNumber
            return mp
        }
    }

    func elapsedSeconds(at now: Date) -> TimeInterval {
        guard let playStarted = playStartedAt else { return 0 }

        var paused = totalPausedSeconds
        if let pausedStart = pausedAt {
            paused += now.timeIntervalSince(pausedStart)  // add ongoing pause
        }

        return now.timeIntervalSince(playStarted) - paused
    }
    
    var finalElapsedSeconds: TimeInterval? {
        guard let end = endTime, let start = playStartedAt else { return nil }
        return end.timeIntervalSince(start) - totalPausedSeconds
    }

    func pause(at now: Date) {
        guard pausedAt == nil else { return }
        pausedAt = now
    }

    func resume(at now: Date) {
        guard let pausedAt else { return }
        totalPausedSeconds += now.timeIntervalSince(pausedAt)
        self.pausedAt = nil
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
    
    func startPlay(at now: Date) {
        playStartedAt = now
        totalPausedSeconds = 0
        pausedAt = nil

        for mp in matchPlayers {
            if mp.isOnField {
                mp.lastSubInMatchSeconds = 0
                mp.lastSubOutMatchSeconds = nil
            } else {
                mp.lastSubOutMatchSeconds = 0
                mp.lastSubInMatchSeconds = nil
            }
        }
    }

    func subIn(player: MatchPlayer, at now: Date) {
        guard !player.isOnField else { return }

        player.isOnField = true
        player.lastSubOutMatchSeconds = nil

        let matchSeconds = isPaused
            ? elapsedSeconds(at: pausedAt!)
            : elapsedSeconds(at: now)
        player.lastSubInMatchSeconds = matchSeconds
    }

    func subOut(player: MatchPlayer, at now: Date) {
        guard player.isOnField else { return }

        let matchSeconds = isPaused
            ? elapsedSeconds(at: pausedAt!)
            : elapsedSeconds(at: now)

        if let last = player.lastSubInMatchSeconds {
            player.totalSecondsPlayed += matchSeconds - last
        }

        player.isOnField = false
        player.lastSubInMatchSeconds = nil
        player.lastSubOutMatchSeconds = matchSeconds
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
            print(
                " - \(mp.snapshotName):",
                "isOnField=\(mp.isOnField)",
                "lastSubInMatchSeconds=\(String(describing: mp.lastSubInMatchSeconds))",
                "totalSecondsPlayed=\(mp.totalSecondsPlayed)",
                "secondsPlayed(now)=\(formatTime(playerTime))"
            )
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
        guard !isEnded else { return }

        // Use pausedAt time if match is currently paused
        let endMatchSeconds = isPaused ? elapsedSeconds(at: pausedAt!) : elapsedSeconds(at: now)

        for mp in matchPlayers where mp.isOnField {
            if let last = mp.lastSubInMatchSeconds {
                mp.totalSecondsPlayed += endMatchSeconds - last
            }
            mp.isOnField = false
            mp.lastSubInMatchSeconds = nil
            mp.lastSubOutMatchSeconds = endMatchSeconds
        }

        pausedAt = nil
        pauseReason = nil
        endTime = now
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
    
    func addPlayerToMatch(_ player: Player, at now: Date) {
        // Prevent duplicates
        if matchPlayers.contains(where: { $0.player == player }) {
            return
        }

        let mp = MatchPlayer(player: player)

        // If match already started, they join "from the bench now"
        if hasStartedPlay {
            mp.isOnField = false
            mp.lastSubOutMatchSeconds = elapsedSeconds(at: now)
        }

        matchPlayers.append(mp)
    }
    
    func removePlayerFromMatch(_ mp: MatchPlayer) {
        // Do not allow removing someone currently on field
        guard !mp.isOnField else { return }

        matchPlayers.removeAll { $0 === mp }
    }
    
}
