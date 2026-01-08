//
//  MatchActiveView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/7/26.
//

import SwiftUI
import SwiftData
import Combine

struct MatchActiveView: View {
    let match: Match  // SwiftData @Model
    @State private var now = Date()  // live clock

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            // Match clock
            MatchClockView(elapsedSeconds: match.elapsedSeconds(at: now))
                .opacity(match.isEnded ? 0.5 : 1.0)

            SubSuggestionsView(match: match, now: now)

            Button(role: .destructive) {
                endMatch()
            } label: {
                Text("End Match")
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .disabled(match.isEnded)

            List {
                Section("On the Field") {
                    ForEach(match.matchPlayers.filter { $0.isOnField }) { mp in
                        PlayerRow(
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now  // <- pass binding
                        )
                    }
                }

                Section("Bench") {
                    ForEach(match.matchPlayers.filter { !$0.isOnField }) { mp in
                        PlayerRow(
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now  // <- pass binding
                        )
                    }
                }
            }
        }
        .onReceive(timer) { newTime in
            if !match.isEnded {
                now = newTime  // triggers redraw in PlayerRow via binding
            }
        }
    }

    private func endMatch() {
        let end = now

        for mp in match.matchPlayers where mp.isOnField {
            if let lastIn = mp.lastSubInTime {
                mp.totalSecondsPlayed += end.timeIntervalSince(lastIn)
            }
            mp.isOnField = false
            mp.lastSubInTime = nil
        }

        match.endTime = end
    }
}
