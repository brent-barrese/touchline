//
//  MatchSummaryView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI

struct MatchSummaryView: View {
    let match: Match

    var body: some View {
        List {
            Section("Players") {
                ForEach(match.matchPlayers) { mp in
                    HStack {
                        Text("#\(mp.snapshotJerseyNumber) \(mp.snapshotName)")
                        Spacer()
                        Text(formatTime(mp.totalSecondsPlayed))
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
            
            Section("Score") {
                HStack {
                    Text("Us")
                    Spacer()
                    Text("\(match.goalsFor)")
                }

                HStack {
                    Text("Opponent")
                    Spacer()
                    Text("\(match.goalsAgainst)")
                }
            }
            
            Section("Goals") {
                ForEach(match.matchPlayers) { mp in
                    let count = match.goals(for: mp.player)
                    if count > 0 {
                        HStack {
                            Text(mp.snapshotName) // <-- use snapshot here too
                            Spacer()
                            Text("\(count)")
                        }
                    }
                }
            }
        }
        .navigationTitle(match.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(match.name)
                        .font(.headline)

                    Text(match.startTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
