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

    @State private var now = Date()
    @State private var showEndConfirmation = false
    @State private var timerCancellable: Cancellable?

    var body: some View {
        VStack {
            // Match name
            Text(match.name)
                .font(.title2)
                .bold()
                .padding(.top)
            
            if !match.isEnded {
                if match.isPaused {
                    Button {
                        match.resume(at: now)
                    } label: {
                        Label("Resume", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.green)
                    .padding(.horizontal)

                    if let reason = match.pauseReason {
                        Text(reason == .halftime ? "Halftime" : "Paused")
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding(.bottom, 4)
                    }
                } else {
                    VStack(spacing: 6) {
                        HStack {
                            Button {
                                match.startHalftime(at: now)
                            } label: {
                                Label("Halftime", systemImage: "pause.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            .disabled(match.hasHadHalftime || match.isEnded)
                            .opacity(match.hasHadHalftime ? 0.4 : 1.0)

                            Button {
                                match.pause(at: now)
                            } label: {
                                Label("Pause", systemImage: "pause.fill")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)

                        if match.hasHadHalftime {
                            Text("Halftime already completed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Match clock
            MatchClockView(elapsedSeconds: match.elapsedSeconds(at: now))
                .opacity(match.isEnded ? 0.5 : 1.0)

            // Sub suggestions only if match active
            if !match.isEnded && !match.isPaused {
                SubSuggestionsView(match: match, now: now)
            }

            // End Match button
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
                        .disabled(match.isEnded || match.isPaused)
                    }
                }

                Section("Bench") {
                    ForEach(match.matchPlayers.filter { !$0.isOnField }) { mp in
                        PlayerRow(
                            matchPlayer: mp,
                            isMatchEnded: match.isEnded,
                            now: $now
                        )
                        .disabled(match.isEnded || match.isPaused)
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
            Button("Cancel", role: .cancel) { }
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
        stopTimer()
        onMatchEnded?()
    }

    private func togglePause() {
        if match.isPaused {
            match.resume(at: now)
        } else {
            match.pause(at: now)
        }
    }
}

