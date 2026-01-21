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
            Text(match.name)
                .font(.title2)
                .bold()
                .padding(.top)

            if !match.isEnded {
                if match.isPaused {
                    Button { match.resume(at: now) } label: {
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
                    // Pause / Halftime buttons
                    HStack {
                        if match.hasStartedPlay {
                            Button { match.startHalftime(at: now) } label: {
                                Label("Halftime", systemImage: "pause.circle")
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            .disabled(match.hasHadHalftime)
                            .opacity(match.hasHadHalftime ? 0.4 : 1.0)

                            Button { match.pause(at: now) } label: {
                                Label("Pause", systemImage: "pause.fill")
                            }
                        }
                    }
                }
            }

            // Start Play Button
            if !match.hasStartedPlay && !match.isEnded {
                Button {
                    let kickoff = Date()
                    match.playStartedAt = kickoff
                    match.totalPausedSeconds = 0
                    match.pausedAt = nil

                    // Initialize players on field
                    for mp in match.matchPlayers where mp.isOnField {
                        mp.lastSubInTime = kickoff
                    }

                    now = kickoff
                } label: {
                    Label("Start Play", systemImage: "play.circle.fill")
                }
            }

            MatchClockView(elapsedSeconds: match.elapsedSeconds(at: now))
                .opacity(match.isEnded ? 0.5 : 1.0)

            if !match.isEnded && !match.isPaused {
                SubSuggestionsView(match: match, now: now)
            }

            Button(role: .destructive) {
                showEndConfirmation = true
            } label: {
                Text("End Match")
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            .disabled(match.isEnded)

            // Players
            List {
                Section("On the Field") {
                    ForEach(match.matchPlayers.filter { $0.isOnField }) { mp in
                        PlayerRow(match: match, matchPlayer: mp, isMatchEnded: match.isEnded, now: $now)
                    }
                }
                Section("Bench") {
                    ForEach(match.matchPlayers.filter { !$0.isOnField }) { mp in
                        PlayerRow(match: match, matchPlayer: mp, isMatchEnded: match.isEnded, now: $now)
                    }
                }
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .alert("End Match?", isPresented: $showEndConfirmation) {
            Button("End Match", role: .destructive) { endMatch() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { newTime in
                now = newTime
                match.debugStatus(at: now)
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func endMatch() {
        match.end(at: now)
        
        // 🔍 DEBUG — remove later
        print("=== MATCH EVENTS ===")
        for event in match.events {
            print(
                event.type.rawValue,
                "player:",
                event.player?.name ?? "-",
                "from:",
                event.fromPosition as Any,
                "to:",
                event.toPosition as Any,
                "@",
                event.timestamp
            )
        }
        print("====================")
        
        stopTimer()
        onMatchEnded?()
    }
}
