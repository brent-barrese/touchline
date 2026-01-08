//
//  PlayerRow.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/8/26.
//

import SwiftUI
import SwiftData

struct PlayerRow: View {
    @Bindable var matchPlayer: MatchPlayer
    let isMatchEnded: Bool
    @Binding var now: Date  // <- pass as binding

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(matchPlayer.player.name)
                    .bold()
                Text(timeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(matchPlayer.isOnField ? "Sub Out" : "Sub In") {
                toggleSub()
            }
            .buttonStyle(.bordered)
            .disabled(isMatchEnded)
        }
        .padding(.vertical, 4)
    }

    private var timeString: String {
        let seconds = matchPlayer.secondsPlayed(at: now)
        let minutes = Int(seconds / 60)
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }

    private func toggleSub() {
        let current = now
        if matchPlayer.isOnField {
            if let lastIn = matchPlayer.lastSubInTime {
                matchPlayer.totalSecondsPlayed += current.timeIntervalSince(lastIn)
            }
            matchPlayer.isOnField = false
            matchPlayer.lastSubInTime = nil
        } else {
            matchPlayer.isOnField = true
            matchPlayer.lastSubInTime = current
        }
    }
}
