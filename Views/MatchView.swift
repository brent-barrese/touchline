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
    let match: Match
    var onMatchEnded: (() -> Void)? = nil

    @State private var now = Date()              // live clock
    @State private var showEndConfirmation = false
    @State private var timerCancellable: Cancellable?

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
                showEndConfirmation = true
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
                        .disabled(match.isEnded)
                    }
                }

                Section("Bench") {
                    ForEach(match.matchPlayers.filter { !$0.isOnField }) { mp in
                        PlayerRow(
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now
                        )
                        .disabled(match.isEnded)
                    }
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .alert("End Match?", isPresented: $showEndConfirmation) {
            Button("End Match", role: .destructive) {
                endMatch()
            }
            Button("Cancel", role: .cancel) {
            }
        } message: {
            Text("This will finalize the match and lock all player stats.")
        }
    }

    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { newTime in
                if !match.isEnded {
                    now = newTime
                }
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
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

        // Stop timer immediately
        stopTimer()

        // Notify parent
        onMatchEnded?()
    }
}
