//
//  MatchView.swift
//  TouchLine
//
//  Created by Brent Barrese on 1/5/26.
//

import SwiftUI
import SwiftData
import Combine

struct MatchView: View {
    // Injected match from parent
    let match: Match
    
    // Optional callback to notify parent when match ends
    var onMatchEnded: (() -> Void)? = nil


    @State private var showSetup = false
    @State private var now = Date()  // live clock

    // Timer for the match clock
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            // Match clock
            MatchClockView(elapsedSeconds: match.elapsedSeconds(at: now))
                .opacity(match.isEnded ? 0.5 : 1.0)

            // Suggestions only if match is active
            if !match.isEnded {
                SubSuggestionsView(match: match, now: now)
            }

            // End match button
            Button(role: .destructive) {
                endMatch()
            } label: {
                Text("End Match")
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .disabled(match.isEnded)

            // Player lists
            List {
                Section("On the Field") {
                    ForEach(match.matchPlayers.filter { $0.isOnField }) { mp in
                        PlayerRow(
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now
                        )
                    }
                }

                Section("Bench") {
                    ForEach(match.matchPlayers.filter { !$0.isOnField }) { mp in
                        PlayerRow(
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now
                        )
                    }
                }
            }
        }
        .onReceive(timer) { newTime in
            if !match.isEnded {
                now = newTime
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
        
        // Notify parent that match ended
        onMatchEnded?()
    }
}
