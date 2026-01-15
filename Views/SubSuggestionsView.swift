//
//  SubSuggestionsView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI

struct SubSuggestionsView: View {
    let match: Match
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sub Suggestions")
                .font(.headline)
                .padding(.bottom, 4)

            if underplayedPlayers.isEmpty {
                Text("All players are roughly equal on play time.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(underplayedPlayers, id: \.player.id) { mp in
                    HStack {
                        Text("#\(mp.player.jerseyNumber) \(mp.player.name)")
                        Spacer()
                        Text(formatTime(average - mp.secondsPlayed(match: match, at: now)))
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }

    private var average: TimeInterval {
        match.averageSecondsPlayed(at: now)
    }

    private var underplayedPlayers: [MatchPlayer] {
        // filter underplayed
        let filtered = match.matchPlayers.filter { mp in
            mp.isUnderplayed(match: match, at: now, comparedTo: average)
        }

        // sort by how far behind they are (most underplayed first)
        let sorted = filtered.sorted { mp1, mp2 in
            let deficit1 = average - mp1.secondsPlayed(match: match, at: now)
            let deficit2 = average - mp2.secondsPlayed(match: match, at: now)
            return deficit1 > deficit2
        }

        // limit to top 3
        return Array(sorted.prefix(3))
    }
}
