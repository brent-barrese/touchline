//
//  PlayerRow.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/8/26.
//

import SwiftUI
import SwiftData

struct PlayerRow: View {
    let match: Match
    @Bindable var matchPlayer: MatchPlayer
    let isMatchEnded: Bool
    @Binding var now: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(matchPlayer.player.name)
                    .bold()
                Text(timeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let position = matchPlayer.currentPosition {
                    Text(position.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("No position")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Button(matchPlayer.isOnField ? "Sub Out" : "Sub In") { toggleSub() }
                .buttonStyle(.bordered)
                .disabled(isMatchEnded)
            Menu("Position") {
                ForEach(Position.allCases, id: \.self) { pos in
                    Button(pos.rawValue.capitalized) {
                        match.changePosition(
                            for: matchPlayer,
                            to: pos,
                            at: now
                        )
                    }
                }
            }
            .disabled(!matchPlayer.isOnField || isMatchEnded)
        }
        .padding(.vertical, 4)
        .opacity(isMatchEnded ? 0.5 : 1.0)
    }

    private var timeString: String {
        let rawSeconds = matchPlayer.secondsPlayed(match: match, at: now)
        let seconds = max(0, rawSeconds)   // never show negative time
        let minutes = Int(seconds / 60)
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func toggleSub() {
        let current = now

        if matchPlayer.isOnField {
            match.subOut(player: matchPlayer, at: current)
        } else {
            match.subIn(player: matchPlayer, at: current)
        }
    }
}
